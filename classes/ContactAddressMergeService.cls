public with sharing class ContactAddressMergeService {

	/*
	 * Record types - used when spawning Contact and Account
	 */
	 
	public static final Map<Id,Schema.RecordTypeInfo> ACCOUNTS_RECORD_TYPE_IDS = Schema.SObjectType.Account.getRecordTypeInfosById();
	public static final Map<String,Schema.RecordTypeInfo> ACCOUNTS_RECORD_TYPE_NAMES = Schema.SObjectType.Account.getRecordTypeInfosByName();
	public static final Map<String,Schema.RecordTypeInfo> CONTACTS_RECORD_TYPE_NAMES = Schema.SObjectType.Contact.getRecordTypeInfosByName();

	/*
	 * Helper methods
	 */
	 
    private @testvisible static String getRecordTypeById(Map<Id,Schema.RecordTypeInfo> infoMap, Id recordTypeId) {
    	return infoMap.containsKey(recordTypeId) ? infoMap.get(recordTypeId).Name : null;
    }
        
	private @testvisible static Id getRecordTypeByName(Map<String,Schema.RecordTypeInfo> infoMap, String recordName) {
    	return infoMap.containsKey(recordName) ? infoMap.get(recordName).getRecordTypeId() : null;
    }   
                
    private static Boolean isContactUnauthorized(String parentAccountRecordTypeName) {
    	return String.isNotBlank(parentAccountRecordTypeName) && (parentAccountRecordTypeName == 'Trade' || parentAccountRecordTypeName == 'Contract');
    }  
    
    /*
     * Classes to store data during spawn process
     */
	
	public class OrdersPersonAccount {
		public Account spawnedAccount;
		public ID accountId;
		public ID contactId;
	}	
	public class OrdersSpawnedContact {
		public Contact spawnedContact;
		public List<Rh_Order__c> matchingOrders;
		public OrdersSpawnedContact() {
			this.matchingOrders = new List<Rh_Order__c>();
		}
	}
	public class OrdersSpawnedContactAccount {
		public Account spawnedAccount;
		public Map<String, OrdersSpawnedContact> spawnedContactsByContactMatchKey;
		public OrdersSpawnedContactAccount() {
			this.spawnedContactsByContactMatchKey = new Map<String, OrdersSpawnedContact>();
		}
	}	 		
	    
	/*
	 * ENTRY POINT
	 * Builds any missing Accounts and/or Contacts for new Orders
	 */
	 
	public static List<Rh_Order__c> buildCustomerForOrders(List<RH_Order__c> orders) {
		
		Map<String, List<Rh_Order__c>> ordersByAccountMatchKey = new map<String, List<RH_Order__c>>();
		Map<String, List<Rh_Order__c>> ordersByContactMatchKey = new map<String, List<RH_Order__c>>();
		  				
		// 1. build set of required account/contact match keys. next step will be to make use of the exclude tables and all that malarky. 
		
		for (RH_Order__c rhOrder : orders) {			
			if (rhOrder.Contact_Sold_To__c == null && rhOrder.SOLD_TO_LAST_NAME__c != NULL && String.isNotEmpty(rhOrder.SOLD_TO_LAST_NAME__c.trim())) {
				
				Contact_Address__c contactAddress = ContactAddressService.generateSoldToContactAddress(rhOrder);
				
				if (rhOrder.Sold_to_Company__c != null) {		
					if (!ordersByAccountMatchKey.containsKey(contactAddress.ACCOUNT_MATCH_KEY_HASH__C)) {						
						ordersByAccountMatchKey.put(contactAddress.ACCOUNT_MATCH_KEY_HASH__C, new List<Rh_Order__c>());	
					}				
					system.debug('buildCustomerForOrder -> add order to company contact list: ' + rhOrder);
					ordersByAccountMatchKey.get(contactAddress.ACCOUNT_MATCH_KEY_HASH__C).add(rhOrder);					
				} else {
					if (!ordersByContactMatchKey.containsKey(contactAddress.CONTACT_MATCH_KEY_HASH__C)) {
						ordersByContactMatchKey.put(contactAddress.CONTACT_MATCH_KEY_HASH__C, new List<Rh_Order__c>());
					}
					system.debug('buildCustomerForOrder -> add order to person account list: ' + rhOrder);
					ordersByContactMatchKey.get(contactAddress.CONTACT_MATCH_KEY_HASH__C).add(rhOrder);	
				}
			}
		}
		
		// 2. build person accounts
		
		List<Rh_Order__c> ordersUpdated = new List<Rh_Order__c>();		
		ordersUpdated.addAll(buildPersonAccountsForOrders(ordersByContactMatchKey));
		ordersUpdated.addAll(buildCompanyContactsForOrders(ordersByAccountMatchKey));	
		
		// 3. return updated orders
			
		return ordersUpdated;		
	}
		
	/*
	 * Generate all orders that require person accounts
	 * Quite simple. Look to see if a matching Contact exists, if not generate it.
	 * Associate with all orders.
	 */
	
	private @testVisible static List<Rh_Order__c> buildPersonAccountsForOrders(Map<String, List<RH_Order__c>> ordersByContactMatchKey) {
		
		Map<Object, List<SObject>> contactAddressByContactMatchKey = new map<Object, List<SObject>>();			
		Map<String, OrdersPersonAccount> personAccountByContactMatchKey = new Map<String, OrdersPersonAccount>();
		
		// 1. Find all matching Contacts.
		
		List<Contact_Address__c> matchingContactAddressRecords = [
			SELECT ID, Contact__r.AccountId, Contact__c, Contact_Match_Key_Hash__c, Address_Match_Key_Hash__c
			FROM Contact_Address__c
			WHERE Contact_Match_Key_Hash__c IN :ordersByContactMatchKey.keySet()
			AND Contact__c != NULL
		];
		contactAddressByContactMatchKey = Utility.mapByProperty(Contact_Address__c.Contact_Match_Key_Hash__c, matchingContactAddressRecords);
		
		// 2. Generate any person accounts that do not already exist
		
		for (String contactMatchKey : ordersByContactMatchKey.keySet()) {			
			OrdersPersonAccount opa = null;
			if (contactAddressByContactMatchKey.containsKey(contactMatchKey)) {
				system.debug('buildPersonAccountsForOrders -> found matching contact address with match key: ' + contactMatchKey);
				// get ids from first contact address
				Contact_Address__c matchingContactAddress = (Contact_Address__c)contactAddressByContactMatchKey.get(contactMatchKey).get(0);
				opa = new OrdersPersonAccount();
				opa.accountId = matchingContactAddress.Contact__r.AccountId;
				opa.contactId = matchingContactAddress.Contact__c;
			} else {
				system.debug('buildPersonAccountsForOrders -> found NO matching contact address with match key: ' + contactMatchKey);
				// build contact from first order
				Rh_Order__c contactOrder = ordersByContactMatchKey.get(contactMatchKey).get(0);
				opa = new OrdersPersonAccount();
				system.debug('buildPersonAccountsForOrders -> generate new person account for order: ' + contactOrder);
				opa.spawnedAccount = generateAccountFromOrder(contactOrder);
			}			
			personAccountByContactMatchKey.put(contactMatchKey, opa);
		}

		// 3. Insert new Person Accounts
		
		List<Account> personAccountsToSpawn = new List<Account>();
		for (OrdersPersonAccount opa : personAccountByContactMatchKey.values()) {
			if (opa.spawnedAccount != null) {
				system.debug('buildPersonAccountsForOrders -> add new person account to list for insertion: ' + opa.spawnedAccount);
				personAccountsToSpawn.add(opa.spawnedAccount);
			}
		}
		if (personAccountsToSpawn.size() > 0) {
			system.debug('buildPersonAccountsForOrders -> inserting new person accounts: ' + personAccountsToSpawn);
			database.insert(personAccountsToSpawn);
		}
				
		// 3.5 get the account and contact Ids from the spawned person accounts
		// TODO:: this won't scale!! We need to SELECT the ID from the contact in a separate query
		
		for (String contactMatchKey : personAccountByContactMatchKey.keySet()) {
			OrdersPersonAccount opa = personAccountByContactMatchKey.get(contactMatchKey);
			if (opa.spawnedAccount != null) {
				system.debug('buildPersonAccountsForOrders -> extracting accountId and contactId from spawned person account: ' + opa.spawnedAccount);
				opa.accountId = opa.spawnedAccount.Id;
				opa.contactId = [SELECT ID FROM Contact WHERE AccountID = :opa.spawnedAccount.Id].ID; // opa.spawnedAccount.PersonContactID; 
			}
		}
		
		// 4. Update Orders (and spawned Contact Address)
		
		List<Rh_Order__c> ordersToUpdate = new List<Rh_Order__c>();
		for (String contactMatchKey : personAccountByContactMatchKey.keySet()) {
			OrdersPersonAccount opa = personAccountByContactMatchKey.get(contactMatchKey);
			// set original orders
			for (Rh_Order__c contactOrder : ordersByContactMatchKey.get(contactMatchKey)) {
				system.debug('buildPersonAccountsForOrders -> adding order to list for updating: ' + contactOrder.Id);
				ordersToUpdate.add(new Rh_Order__c(
					ID = contactOrder.Id,
					Account_Sold_To__c = opa.accountId,
					Contact_Sold_To__c = opa.contactId
				));				
			}
		}
		
		// 5.0 Return the updated orders
		
		system.debug('buildPersonAccountsForOrders -> return orders for update: ' + ordersToUpdate);
		return ordersToUpdate;
	}
	
	/*
	 * Generate all orders that require company/contact accounts
	 * Look to see if matching account exists. 
	 * If it does look to see if matching contact under account exists
	 * If Contact exists, associate with all orders with matching contact. Otherwise generate new Contact.
	 * If Account doesn't exist either, create both account and contact.
	 */
		
	private @testVisible static List<Rh_Order__c> buildCompanyContactsForOrders(Map<String, List<RH_Order__c>> ordersByAccountMatchKey) {	
		
		Map<Object, List<SObject>> contactAddressByAccountMatchKey = new map<Object, List<SObject>>();		
		List<OrdersSpawnedContactAccount> spawnedContactAccounts = new List<OrdersSpawnedContactAccount>();
		Map<ID, Rh_Order__c> ordersToUpdate = new Map<Id, Rh_Order__c>();
				
		// drop out if there are no orders requiring contacts + poss accounts
		
		if (ordersByAccountMatchKey.values().size() < 1) {
			system.debug('buildCompanyContactsForOrders -> no orders with account match key passed in');
			return new List<Rh_Order__c>();
		}
		
		// 2. Find any Contact Address records that have a matching Account match key
		
		List<Contact_Address__c> matchingContactAddressRecords = [
			SELECT ID, Contact__r.AccountId, Contact__c, Account_Match_Key_Hash__c, Contact_Match_Key_Hash__c
			FROM Contact_Address__c
			WHERE Account_Match_Key_Hash__c IN :ordersByAccountMatchKey.keySet()
			AND Contact__c != NULL
		];
		contactAddressByAccountMatchKey = Utility.mapByProperty(Contact_Address__c.Account_Match_Key_Hash__c, matchingContactAddressRecords);

		// 3. Go through all Account Match Keys. Find matching accounts/contacts				
		
		for (String accountMatchKey : ordersByAccountMatchKey.keySet()) {
			system.debug('buildCompanyContactsForOrders -> start processing account match key' + accountMatchKey);
			// create a store for this account match key			
			
			OrdersSpawnedContactAccount spawnedContactAccount = new OrdersSpawnedContactAccount();
						
			// go through all the orders that need an account with that match key (as each may need different contact)
			
			for (Rh_Order__c accountOrder : ordersByAccountMatchKey.get(accountMatchKey)) {
				system.debug('buildCompanyContactsForOrders -> process account Order: ' + accountOrder);
				
				// create a contact match key for that order
				
				String contactMatchKey = ContactAddressService.generateSoldToContactAddress(accountOrder).CONTACT_MATCH_KEY_HASH__C;
			
				// is there matching account for that order
						
				if (contactAddressByAccountMatchKey.containsKey(accountMatchKey)) {
					system.debug('buildCompanyContactsForOrders -> contact address found that has a match on the account match key ' + accountMatchKey);
						
					// record that a matching accounts was found
					
					spawnedContactAccount.spawnedAccount = new Account( ID = ((Contact_Address__c)contactAddressByAccountMatchKey.get(accountMatchKey).get(0)).Contact__r.AccountId );
					
					// search contacts associated with matching account, associate order if one found
					
					for (SObject contactAddress : contactAddressByAccountMatchKey.get(accountMatchKey)) {
						if (((Contact_Address__c)contactAddress).CONTACT_MATCH_KEY_HASH__C.equals(contactMatchKey)) {
							system.debug('buildCompanyContactsForOrders -> found contact that matches the order contact match key ' + contactAddress);
							// add this order to the list to update
							if (!ordersToUpdate.containsKey(accountOrder.Id)) {
								ordersToUpdate.put(accountOrder.Id, new Rh_Order__c());
							}
							ordersToUpdate.get(accountOrder.Id).Id = accountOrder.Id;							
							ordersToUpdate.get(accountOrder.Id).Address_Sold_To__c = ((Contact_Address__c)contactAddress).Id;
							ordersToUpdate.get(accountOrder.Id).Contact_Sold_To__c = ((Contact_Address__c)contactAddress).Contact__c;
							ordersToUpdate.get(accountOrder.Id).Account_Sold_To__c = ((Contact_Address__c)contactAddress).Contact__r.AccountId;
							break;
						}
					}
				}
				
				// if there is no matching contact for that order
										
				if (!ordersToUpdate.containsKey(accountOrder.Id)) {
					system.debug('buildCompanyContactsForOrders -> no contact found that matches the contact match key ' + contactMatchKey);
					
					// create an account if one not already created
					
					if (spawnedContactAccount.spawnedAccount == null) {
						system.debug('buildCompanyContactsForOrders -> process account from order: ' + accountOrder);
						spawnedContactAccount.spawnedAccount = generateAccountFromOrder(accountOrder);						
					}
										
					// create a contact if one not already created
					
					if (!spawnedContactAccount.spawnedContactsByContactMatchKey.containsKey(contactMatchKey)) {
						system.debug('buildCompanyContactsForOrders -> process contact from order: ' + accountOrder);
						OrdersSpawnedContact osc = new OrdersSpawnedContact();
						osc.spawnedContact = generateContactFromOrder(accountOrder, null, null);								
						spawnedContactAccount.spawnedContactsByContactMatchKey.put(contactMatchKey, osc);
					}
					
					// add this order to the list of orders requiring this spawned contact
					
					spawnedContactAccount.spawnedContactsByContactMatchKey.get(contactMatchKey).matchingOrders.add(accountOrder);		
											
				}							
			}			
			spawnedContactAccounts.add(spawnedContactAccount);
		} 
		
		// 4. Insert the accounts that need inserting
		
		List<Account> accountsToSpawn = new List<Account>();
		for (OrdersSpawnedContactAccount osca : spawnedContactAccounts) {
			if (osca.spawnedAccount != null && osca.spawnedAccount.Id == null) {
				system.debug('buildCompanyContactsForOrders -> adding account to list to be inserted: ' + osca.spawnedAccount);
				accountsToSpawn.add(osca.spawnedAccount);
			}
		}	
		if (accountsToSpawn.size() > 0) {	
			system.debug('buildCompanyContactsForOrders -> inserting account '+ accountsToSpawn);
			database.insert(accountsToSpawn);
		}
		
		// 5. Insert the contacts that need inserting
		
		List<Contact> contactsToSpawn = new List<Contact>();
		for (OrdersSpawnedContactAccount osca : spawnedContactAccounts) {
			for (OrdersSpawnedContact osc : osca.spawnedContactsByContactMatchKey.values()) {
				system.debug('buildCompanyContactsForOrders -> adding contact to list to be inserted: ' + osc.spawnedContact);
				osc.spawnedContact.AccountId = osca.spawnedAccount.Id;
				contactsToSpawn.add(osc.spawnedContact);
			}
		}
		if (contactsToSpawn.size() > 0) {
			system.debug('buildCompanyContactsForOrders -> inserting contacts: ' + contactsToSpawn);
			database.insert(contactsToSpawn);
		}
		
		// 6. Update the orders with those Contact Ids
		
		for (OrdersSpawnedContactAccount osca : spawnedContactAccounts) {
			for (OrdersSpawnedContact osc : osca.spawnedContactsByContactMatchKey.values()) {
				// update the orders with the spawned contact id
				for (Rh_Order__c contactOrder : osc.matchingOrders) {
					system.debug('buildCompanyContactsForOrders -> associating order with contact: ' + contactOrder + '<=>' + osc.spawnedContact);
					if (!ordersToUpdate.containsKey(contactOrder.Id)) {
						ordersToUpdate.put(contactOrder.Id, new Rh_Order__c());
					}
					ordersToUpdate.get(contactOrder.Id).Id = contactOrder.Id;
					ordersToUpdate.get(contactOrder.Id).Account_Sold_To__c = osc.spawnedContact.AccountId;
					ordersToUpdate.get(contactOrder.Id).Contact_Sold_To__c = osc.spawnedContact.Id;
				}
			}
		}
		
		// 7. Return updated orders

		system.debug('buildCompanyContactsForOrders -> returning orders for update ' + ordersToUpdate.values()); 
		return ordersToUpdate.values();		
	}
	
    
    /*
     * Build the Account from the details stored within an Order
     */    
    
    private @testVisible static Account generateAccountFromOrder(Rh_Order__c rhOrder) {
    	if (rhOrder.Sold_to_Company__c != null) {
			return new Account(
				Name = rhOrder.Sold_to_Company__c,
				RecordTypeId = getRecordTypeByName(ACCOUNTS_RECORD_TYPE_NAMES, 'Unclassified Business Account'),
				Type = 'Unclassified Business',
				BillingStreet = (rhOrder.SOLD_TO_ADDRESS_1__C != null && rhOrder.SOLD_TO_ADDRESS_2__C != null) ? rhOrder.SOLD_TO_ADDRESS_1__C + '\r\n' + rhOrder.SOLD_TO_ADDRESS_2__C: (rhOrder.SOLD_TO_ADDRESS_1__C != null) ? rhOrder.SOLD_TO_ADDRESS_1__C : '',
				BillingCity = rhOrder.BILL_TO_CITY__C,
				BillingState = rhOrder.BILL_TO_STATE__C,
				BillingPostalCode = rhOrder.BILL_TO_ZIP__C,
				BillingCountry = rhOrder.BILL_TO_COUNTRY__C,
				Phone = rhOrder.BILL_TO_DAY_PHONE__C,
				Fraud_Warning__c = rhOrder.Fraud_Warning__c
			);
    	}
    	
    	// return person account
		return new Account(
			RecordTypeId = getRecordTypeByName(ACCOUNTS_RECORD_TYPE_NAMES, 'RH End Customer'),
			Type = 'Consumer',
			FirstName = rhOrder.SOLD_TO_FIRST_NAME__C,
			LastName = rhOrder.SOLD_TO_LAST_NAME__C,
			PersonMailingStreet = (rhOrder.SOLD_TO_ADDRESS_1__C != null && rhOrder.SOLD_TO_ADDRESS_2__C != null) ? rhOrder.SOLD_TO_ADDRESS_1__C + '\r\n' + rhOrder.SOLD_TO_ADDRESS_2__C: (rhOrder.SOLD_TO_ADDRESS_1__C != null) ? rhOrder.SOLD_TO_ADDRESS_1__C : '',
			PersonMailingCity = rhOrder.SOLD_TO_CITY__C,
			PersonMailingState = rhOrder.SOLD_TO_STATE__C,
			PersonMailingPostalCode = rhOrder.SOLD_TO_ZIP__C,
			PersonMailingCountry = rhOrder.SOLD_TO_COUNTRY__C,
			PersonEmail = rhOrder.SOLD_TO_EMAIL__C,
			BillingStreet = (rhOrder.SOLD_TO_ADDRESS_1__C != null && rhOrder.SOLD_TO_ADDRESS_2__C != null) ? rhOrder.SOLD_TO_ADDRESS_1__C + '\r\n' + rhOrder.SOLD_TO_ADDRESS_2__C: (rhOrder.SOLD_TO_ADDRESS_1__C != null) ? rhOrder.SOLD_TO_ADDRESS_1__C : '',
			BillingCity = rhOrder.BILL_TO_CITY__C,
			BillingState = rhOrder.BILL_TO_STATE__C,
			BillingPostalCode = rhOrder.BILL_TO_ZIP__C,
			BillingCountry = rhOrder.BILL_TO_COUNTRY__C,
			Phone = rhOrder.SOLD_TO_DAY_PHONE__C,
			Fraud_Warning__c = rhOrder.Fraud_Warning__c
		);
    }
    
    private @testVisible static Contact generateContactFromOrder(Rh_Order__c rhOrder, ID accountId, ID accountRecordTypeId) {
		return new Contact(
			RecordTypeId = getRecordTypeByName(CONTACTS_RECORD_TYPE_NAMES, 'Business Contact'),
			FirstName = rhOrder.SOLD_TO_FIRST_NAME__C,
			LastName = rhOrder.SOLD_TO_LAST_NAME__C,
			MailingStreet = (rhOrder.SOLD_TO_ADDRESS_1__C != null && rhOrder.SOLD_TO_ADDRESS_2__C != null) ? rhOrder.SOLD_TO_ADDRESS_1__C + '\r\n' + rhOrder.SOLD_TO_ADDRESS_2__C: (rhOrder.SOLD_TO_ADDRESS_1__C != null) ? rhOrder.SOLD_TO_ADDRESS_1__C : '',
			MailingCity = rhOrder.SOLD_TO_CITY__C,
			MailingState = rhOrder.SOLD_TO_STATE__C,
			MailingPostalCode = rhOrder.SOLD_TO_ZIP__C,
			MailingCountry = rhOrder.SOLD_TO_COUNTRY__C,
			Email = rhOrder.SOLD_TO_EMAIL__C,
			Phone = rhOrder.SOLD_TO_DAY_PHONE__C,
			AccountId = accountId, 
			Unauthorized_Contact_Checkbox__c = accountRecordTypeId == null ? false : isContactUnauthorized(getRecordTypeById(ACCOUNTS_RECORD_TYPE_IDS, accountRecordTypeId))
		);
    }	
 
}