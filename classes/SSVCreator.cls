/**
 *  SSVCreator.cls
 *  @description Spawns customer data from unique Source System View records
 *               as well as duplicate Source System View records consolidated
 *               under the SSVConsolidated class
 *  @author Ernesto Valdes, Salesforce + Traction On Demand
 */
public class SSVCreator /* implements ISSVCreator */ {

	List<SSVConsolidated> consolidatedRecords;
	List<Source_System_View__c> records;

	List<SSVCustomer> customers {
		get {
			if (customers == null) {
				customers = new List<SSVCustomer>();
			}
			return customers;
		}
		set;
	}

	private Set<Id> parentSSVIds {
		get {
			if (parentSSVIds == null) {
				parentSSVIds = new Set<Id>();

				// Collect record ids from consolidated records, if available
				for (SSVCustomer customer : customers) {
					for (SSVCleansed ssvcl : customer.getSSVCleansedRecords()) {
						parentSSVIds.add(ssvcl.parentSSV);
					}
				}
			}
			return parentSSVIds;
		}
		set;
	}

	private Set<Id> ssvIds {
		get {
			if (ssvIds == null) {
				ssvIds = new Set<Id>();

				// Collect record ids
				for (SSVCustomer customer : customers) {
					for (SSVCleansed ssvcl : customer.getSSVCleansedRecords()) {
						ssvIds.add(ssvcl.recordId);
					}
				}
			}
			return ssvIds;
		}
		set;
	}

	private @testVisible Map<Id, Source_System_View__c> ssvById {
		get {
			if (ssvById == null) {

				Set<Id> recordIds = new Set<Id>();
				recordIds.addAll(ssvIds);
				recordIds.addAll(parentSSVIds);

				ssvById = new Map<Id, Source_System_View__c>(
					SSVSelector.getSSVsById(recordIds)
					);
			}
			return ssvById;
		}
		set;
	}

	private @testVisible Map<String, Address__c> existingAddressByKey {
		get {
			if (existingAddressByKey == null) {
				existingAddressByKey = new Map<String, Address__c>();

				Set<String> ssvAddresses = new Set<String>();
				for (Source_System_View__c ssv : ssvById.values())
					ssvAddresses.add(ssv.Address_Match_Key__c);

				for (Address__c addr : [SELECT Id, Full_Address__c
										FROM Address__c 
										WHERE Full_Address__c IN :ssvAddresses]) {
					existingAddressByKey.put(addr.Full_Address__c, addr);
				}
			}
			return existingAddressByKey;
		}
		set;
	}
	
	public SSVCreator(List<SSVConsolidated> consolidatedRecords) {
		this.consolidatedRecords = consolidatedRecords;
	}

	public SSVCreator(List<Source_System_View__c> records) {
		this.records = records;
	}
	
	public SSVCreator() {
		// no initialization		
	}
	
	public void setRecords(List<Source_System_View__c> records) {
		this.records = records;
	}
	
	public void setRecords(List<SSVConsolidated> consolidatedRecords) {
		this.consolidatedRecords = consolidatedRecords;
	}	
	
	public SSVCreator syncToCustomers() {

		if (records != null) {
			for (Source_System_View__c ssv : records) {
	
				// Create customer container
				SSVCustomer currentCustomer = new SSVCustomer(ssv);
	
				// add to customer list
				customers.add(currentCustomer);
			}
		}

		// Convert consolidated records to customer records
		if (consolidatedRecords != null) {
			for (SSVConsolidated ssvc : consolidatedRecords) {
	
				// Create customer container
				SSVCustomer currentCustomer = new SSVCustomer(ssvc);
	
				// add to customer list
				customers.add(currentCustomer);
			}
		}

		return this;
	}

	public List<Source_System_View__c> spawnData() {
		
		List<Source_System_View__c> updated = new List<Source_System_View__c>();
		
		if (this.customers.isEmpty()) {
			return updated;
		}
		
		spawnAccounts();
		updated.addAll(linkCustomerDataToSSV());
		spawnContacts();

		if (FeatureFlagService.isMdmAddressFeatureActive()) {
			spawnContactInformation();
			spawnAddresses();
			spawnCustomerAddresses();
		}
		
		updated.addAll(linkCustomerDataToSSV());		
		return updated;
	}

	private void spawnAccounts() {

		// Create customer accounts
		for (SSVCustomer customer : customers) {

			if (!customer.hasExistingAccount()) {
				// create a new account for new customers
				customer.createAccount();
			}
		}

		// Insert created customer accounts
		List<SSVCustomer> linkedCusts = new List<SSVCustomer>();
		List<Account> customerAccounts = new List<Account>();
		for (SSVCustomer customer : customers) {
			if (customer.isNew() && customer.hasSpawnedAccount()) {
				linkedCusts.add(customer);
				customerAccounts.add(customer.accountSpawned);
			}
		}
		if (!customerAccounts.isEmpty()) {
			Reporter.integrationReport(
					linkedCusts, 
					(List<SObject>) customerAccounts, 
					Database.insert(customerAccounts, false)
			);
		}

		// Query created accounts for a person contact id
		Map<Id, Id> createdAccountsContactId = new Map<Id, Id>();
		for (Account acc :[SELECT Id, PersonContactId
							FROM Account
							WHERE Id IN :customerAccounts]) {
			if (acc.PersonContactId != null) {
				createdAccountsContactId.put(acc.Id, acc.PersonContactId);
			}
		}
		for (SSVCustomer customer : customers) {
			customer.personAccountIdToContactId = createdAccountsContactId;
		}
	}

	public void spawnContacts() {
		
		// Create customer contacts
		for (SSVCustomer customer : customers) {
			if (customer.matchType == 'Contact') {
				if (!customer.hasExistingContact()) {					
					// create a new contact for new customers
					Source_System_View__c parentSSV = ssvById.get(customer.parentSSVId);
					if (parentSSV != null) {					
						customer.createContact(parentSSV.Account__c, parentSSV.Account__r.RecordTypeId);
					}					
				}
			}
		}

		// Insert created customer contacts
		List<Contact> customerContacts = new List<Contact>();
		List<SSVCustomer> linkedCusts = new List<SSVCustomer>();
		for (SSVCustomer customer : customers) {
			if (customer.hasSpawnedContact()) {
				linkedCusts.add(customer);
				customerContacts.add(customer.contactSpawned);
			}
		}
		if (!customerContacts.isEmpty()) {
			Database.DMLOptions dml = new Database.DMLOptions();
			dml.DuplicateRuleHeader.AllowSave = true;
			Reporter.integrationReport(
					linkedCusts, 
					(List<SObject>) customerContacts, 
					Database.insert(customerContacts, dml)
			);
		}

	}

	public void spawnContactInformation() {

		// Create customer contact info
		for (SSVCustomer customer : customers) {

			if (customer.matchType != 'Contact' && customer.matchType != 'Person') continue;

			// create contact info for current customer
			customer.createContactInfos();
		}

		// Collect created contact information
		List<Contact_Information__c> contactInfos = new List<Contact_Information__c>();
		List<SSVCustomer> linkedCusts = new List<SSVCustomer>();
		for (SSVCustomer customer : customers) {
			if (customer.hasContactInfo()) {
				for (Contact_Information__c ci : customer.contactInfos) {
					contactInfos.add(ci);
					linkedCusts.add(customer);
				}
			}
		}

		List<Contact_Information__c> uniqueContactInfos = removeContactInformationDuplicates(contactInfos);
		if (!uniqueContactInfos.isEmpty()) {
			Reporter.integrationReport(
					linkedCusts, 
					(List<SObject>) uniqueContactInfos, 
					Database.insert(uniqueContactInfos, false)
			);
		}
	}

	public List<Contact_Information__c> removeContactInformationDuplicates(List<Contact_Information__c> contactInfos) {

		// Query existing contact information
		// to prevent the insertion of duplicates
		Map<String, Contact_Information__c> newContactInfosByKey = new Map<String, Contact_Information__c>();
		for (Contact_Information__c ci : contactInfos) {
			
			// if record in map already, then replace only if record in map is not primary
			if (newContactInfosByKey.containsKey(ci.Contact_Information_Match_Key_Hash__c) &&
				newContactInfosByKey.get(ci.Contact_Information_Match_Key_Hash__c).Is_Primary__c) continue;

			// collect contact info match key
			newContactInfosByKey.put(ci.Contact_Information_Match_Key_Hash__c, ci);
		}
		// Query existing contact info using match keys
		List<Contact_Information__c> existingContactInfos = [
			SELECT Id, Contact_Information_Match_Key_Hash__c
			FROM Contact_Information__c
			WHERE Contact_Information_Match_Key_Hash__c IN :newContactInfosByKey.keySet()
		];
		// Iterate through existing records and remove from new record list
		for (Contact_Information__c ci : existingContactInfos) {
			// if match key exists in new map, then remove from map
			if (newContactInfosByKey.containsKey(ci.Contact_Information_Match_Key_Hash__c)) {
				newContactInfosByKey.remove(ci.Contact_Information_Match_Key_Hash__c);
			}
		}
		return newContactInfosByKey.values();
	}

	public void spawnAddresses() {

		// Create customer contacts
		for (SSVCustomer customer : customers) {

			if (customer.matchType != 'Contact' && customer.matchType != 'Person') continue;

			// create new addresses for new customers
			customer.createAddresses();
		}

		// Collect created customer addresses
		List<Address__c> addresses = new List<Address__c>();
		List<SSVCustomer> linkedCusts = new List<SSVCustomer>();
		for (SSVCustomer customer : customers) {
			if (customer.hasAddress()) {
				for (Address__c a : customer.addressMap.values()) {
					addresses.add(a);
					linkedCusts.add(customer);
				}
			}
		}

		Reporter.log('check if addresses exists. Total Address count: ' + addresses.size());
		List<Address__c> uniqueAddresses = removeAddressDuplicates(addresses);
		if (!uniqueAddresses.isEmpty()) {
			Reporter.integrationReport(
					linkedCusts, 
					(List<SObject>) uniqueAddresses, 
					Database.insert(uniqueAddresses, false)
			);
		}

	}

	public List<Address__c> removeAddressDuplicates(List<Address__c> addresses) {

		// Query existing address information
		// to prevent insertion of duplicates
		Map<String, Address__c> newAddressesByKey = new Map<String, Address__c>();
		for (Address__c addr : addresses) {
			// collect address match key
			if (addr.Address_Match_Key_Hash__c != null) {			
				newAddressesByKey.put(addr.Address_Match_Key_Hash__c, addr);
			} else {
				Reporter.log('the address match key has was null, and so excluded from query');
			}
		}
		// Query existing addresses using match keys
		List<Address__c> existingAddresses = [
			SELECT Id, Address_Match_Key_Hash__c
			FROM Address__c
			WHERE Address_Match_Key_Hash__c IN :newAddressesByKey.keySet()
		];
		// Iterate through existing records and remove from new list
		for (Address__c addr : existingAddresses) {
			// if match key exists in new map, then remove from map
			if (newAddressesByKey.containsKey(addr.Address_Match_Key_Hash__c)) {

				// populate existing address id for existing addresses
				newAddressesByKey.get(addr.Address_Match_Key_Hash__c).Id = addr.Id;

				// remove from map
				newAddressesByKey.remove(addr.Address_Match_Key_Hash__c);
			}
		}

		return newAddressesByKey.values();
	}

	public void spawnCustomerAddresses() {

		// Create customer contacts
		for (SSVCustomer customer : customers) {

			// create a new contact for new customers
			customer.createCustomerAddresses();
		}

		// Collect created customer contacts
		List<Customer_Address__c> customerAddresses = new List<Customer_Address__c>();
		List<SSVCustomer> linkedCusts = new List<SSVCustomer>();
		for (SSVCustomer customer : customers) {
			if (customer.hasCustomerAddress()) {
				for (Customer_Address__c ca : customer.customerAddresses) {
					customerAddresses.add(ca);
					linkedCusts.add(customer);
				}
			}
		}

		List<Customer_Address__c> uniqueCustomerAddresses = removeCustomerAddressDuplicates(customerAddresses);
		if (!uniqueCustomerAddresses.isEmpty()) {
			Reporter.integrationReport(
					linkedCusts, 
					(List<SObject>) uniqueCustomerAddresses, 
					Database.insert(uniqueCustomerAddresses, false)
			);
		}

	}

	public List<Customer_Address__c> removeCustomerAddressDuplicates(List<Customer_Address__c> customerAddresses) {

		// Query existing customer address information
		// to prevent insertion of duplicates
		Set<Id> accountIds = new Set<Id>();
		Set<Id> addressIds = new Set<Id>();
		Map<String, Customer_Address__c> newCustomerAddressesByKey = new Map<String, Customer_Address__c>();
		for (Customer_Address__c ca : customerAddresses) {
			accountIds.add(ca.Contact__c);
			addressIds.add(ca.Address__c);
			newCustomerAddressesByKey.put(getCustomerAddressKey(ca), ca);
		}
		Reporter.log('New Customer Addresses: ' + newCustomerAddressesByKey);
		// Query existing customer addresses using account and address lookups
		List<Customer_Address__c> existingCustomerAddresses = [
			SELECT Id, Contact__c, Address__c
			FROM Customer_Address__c
			WHERE Contact__c IN :accountIds
				AND Address__c IN :addressIds
		];
		// Iterate through existing records and remove from new list
		for (Customer_Address__c ca : existingCustomerAddresses) {
			String existingAddressMatchKey = getCustomerAddressKey(ca);

			// if match key exists in new map, then remove from map
			if (newCustomerAddressesByKey.containsKey(existingAddressMatchKey)) {
				// remove from map
				newCustomerAddressesByKey.remove(existingAddressMatchKey);
			}
		}

		return newCustomerAddressesByKey.values();
	}

	private String getCustomerAddressKey(Customer_Address__c ca) {
		return ca.Contact__c + ';' + ca.Address__c;
	}

	/**
	 *  @description For each customer, links ssv records to customer data
	 *               then updates the linked ssv records
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2016-02-24
	 *  @return      Updated SSV records
	 */
	public List<Source_System_View__c> linkCustomerDataToSSV() {

		// Create list of updated source system view records		
		List<Source_System_View__c> updatedSSVRecords = new List<Source_System_View__c>();
		for (SSVCustomer customer : this.customers) {
			updatedSSVRecords.addAll(customer.linkCustomerDataToSSV());
		}

		// Query customer addresses for SSV's and linked account
		Set<String> addressMatchKeys = new Set<String>();
		Set<String> contactIds = new Set<String>();
		for (Source_System_View__c ssv :updatedSSVRecords) {
			addressMatchKeys.add(ssv.Address_Match_Key_Hash__c);
			contactIds.add(ssv.Contact__c);
		}

		// Create map of contact+addresskey to customer address record
		Map<String, Id> customerAddressesByKeyAndContact = new Map<String, Id>();
		for (Customer_Address__c ca :[SELECT Id, Contact__c, Address__r.Address_Match_Key_Hash__c
										FROM Customer_Address__c
										WHERE Address__r.Address_Match_Key_Hash__c IN :addressMatchKeys
											AND Contact__c IN :contactIds]) {
			Reporter.log('Queried Customer Address: ' + ca.Contact__c + ':' + ca.Address__r.Address_Match_Key_Hash__c);
			customerAddressesByKeyAndContact.put(
				ca.Contact__c + ':' + ca.Address__r.Address_Match_Key_Hash__c, 
				ca.Id);
		}
		// Populate ssv customer address lookup with matching customer address under matching contact
		for (Source_System_View__c ssv : updatedSSVRecords) {
			Reporter.log('Linking customer address for: ' + ssv.Contact__c + ':' + ssv.Address_Match_Key_Hash__c);
			ssv.Customer_Address__c = customerAddressesByKeyAndContact.get(ssv.Contact__c + ':' + ssv.Address_Match_Key_Hash__c);
			Reporter.log('Linked: ' + ssv.Customer_Address__c);
		}

		// Update source system view records with links to spawned data
		Reporter.log('Updating: ' + updatedSSVRecords);
		if (!updatedSSVRecords.isEmpty()) {
			Reporter.integrationReport(updatedSSVRecords, Database.update(updatedSSVRecords, false));
		}

		return updatedSSVRecords;
	}

	/**
	 *  @description Queries unlinked orders for a given list of ssv records
	 *               then links orders to the ssv record's customer data
	 *               and updates the orders
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2016-02-24
	 *  @param       ssvCustomers  The Source System View records for which to link orders
	 */
	 
	public static void linkOrdersToCustomers(List<Source_System_View__c> ssvList) {

		// Collect ssv ext ids
		Set<String> ssvCustomerIds = new Set<String>();
		for (Source_System_View__c ssv : ssvList) {
			ssvCustomerIds.add(ssv.EXT_Source_System_Customer_ID__c);
		}

		Reporter.log('Linking orders for customer ids: ' + ssvCustomerIds);

		// Query unlinked orders with matching ext ids
		List<RH_Order__c> ordersToLink = [
			SELECT Sold_To_Customer_Number__c, Source_System_View_Sold_To__c, Account_Sold_To__c,
					Contact_Sold_To__c, Customer_Address_Sold_To__c
			FROM RH_Order__c
			WHERE Sold_To_Customer_Number__c IN :ssvCustomerIds
		];

		Reporter.log('Linking existing orders: ' + ordersToLink);
		if (!ordersToLink.isEmpty()) {
		
			// Link orders to created customer data
			RH_Orders.setOrderLookupsFromSSV(ordersToLink, ssvList);	
			Reporter.integrationReport(ordersToLink, Database.update(ordersToLink, false));

			// Link order Ship To records that share same "ship to" as orders
			RH_Orders.setShipToLookupsFromOrder(ordersToLink);
		}

		// Query unlinked ship to records with matching ext ids
		List<Ship_To__c> shipTosToLink = [
			SELECT Ship_To_Customer_Number__c, Order__c, CW_Customer_Ship_To__c, 
					Account_Ship_To__c, Contact_Ship_To__c, Customer_Address_Ship_To__c
            FROM Ship_To__c
            WHERE Ship_To_Customer_Number__c IN :ssvCustomerIds
		];

		if (!shipTosToLink.isEmpty()) {
			Ship_Tos.setShipToLookupsFromSSV(shipTosToLink, ssvList);
			Reporter.integrationReport(shipTosToLink, Database.update(shipTosToLink, false));
		}
	}
}