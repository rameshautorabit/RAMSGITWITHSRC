/**
 *  SSVCustomer.cls
 *  @description	Contains data for customers created from Source System View records
 *  @author Ernesto Valdes, Traction On Demand
 */
public class SSVCustomer {
	
	public static final Map<Id,Schema.RecordTypeInfo> ACCOUNTS_RECORD_TYPE_IDS = Schema.SObjectType.Account.getRecordTypeInfosById();

	Boolean isNew;

	public Id accountId, contactId, masterSSVId, parentSSVId;
	
	public Id consolidatedAccountId, consolidatedContactId;

	public String matchType;

	public Source_System_View__c masterSSV;

	Contact_Information__c primaryPhone, primaryEmail;
	Address__c primaryAddress;

	public Account accountSpawned;
	public Contact contactSpawned;

	public Map<Id, Id> personAccountIdToContactId {
		get {
			if (personAccountIdToContactId == null) {
				personAccountIdToContactId = new Map<Id, Id>();
			}
			return personAccountIdToContactId;
		}
		set;
	}

	public SSVCleansed ssvCleansedMaster;
	public List<SSVCleansed> ssvCleansedList;

	List<Source_System_View__c> ssvList;
	public Set<Contact_Information__c> contactInfos {
		get {
			if (contactInfos == null) contactInfos = new Set<Contact_Information__c>();
			return contactInfos;
		}
		set;
	}
	public Map<String, Address__c> addressMap {
		get {
			if (addressMap == null) addressMap = new Map<String, Address__c>();
			return addressMap;
		}
		set;
	}
	public Set<Customer_Address__c> customerAddresses {
		get {
			if (customerAddresses == null) customerAddresses = new Set<Customer_Address__c>();
			return customerAddresses;
		}
		set;
	}
	
	private static RecordType businessContactAccountRecType {
		get {
			if (businessContactAccountRecType == null) {
				businessContactAccountRecType = [
					SELECT Id
					FROM RecordType
					WHERE DeveloperName = 'Business_Contact'
						AND SObjectType = 'Contact'
				];
			}
			return businessContactAccountRecType;
		}
		set;
	}	
	
	private static RecordType personAccountRecType {
		get {
			if (personAccountRecType == null) {
				personAccountRecType = [
					SELECT Id
					FROM RecordType
					WHERE DeveloperName = 'RH_End_Customer'
						AND SObjectType = 'Account'
				];
			}
			return personAccountRecType;
		}
		set;
	}	

	private static RecordType unclassifiedCompanyAccountRecType {
		get {
			if (unclassifiedCompanyAccountRecType == null) {
				unclassifiedCompanyAccountRecType = [
					SELECT Id
					FROM RecordType
					WHERE DeveloperName = 'Unclassified_Business_Account'
						AND SObjectType = 'Account'
				];
			}
			return unclassifiedCompanyAccountRecType;
		}
		set;
	}

	private static Map<String, Schema.RecordTypeInfo> contactInfoRecordTypes {
		get {
			if (contactInfoRecordTypes == null) {
				contactInfoRecordTypes = Schema.SObjectType.Contact_Information__c.getRecordTypeInfosByName();
			}
			return contactInfoRecordTypes;
		}
		set;
	}

	public SSVCustomer(Source_System_View__c ssv) {

		isNew = (ssv.Account__c == null && ssv.Contact__c == null);

		matchType = ssv.Match_Type__c;
		parentSSVId = ssv.Source_System_View_CW_Company__c;

		// Set primary record
		masterSSV = ssv;
		ssvCleansedMaster = new SSVCleansed(ssv);
		ssvCleansedList = new List<SSVCleansed>();

		// Set existing account and contact to sync to, if any
		accountId = ssv.Account__c;
		contactId = ssv.Contact__c;		
	}

	public SSVCustomer(SSVConsolidated ssvc) {
		
		isNew = ssvc.isNew(); // FALSE if any SSV in consolidated list has account or contact. 

		// Set primary record
		ssvCleansedMaster = ssvc.getPrimaryRecord();
		masterSSV = ssvCleansedMaster.ssv;
		matchType = ssvCleansedMaster.matchType;
		parentSSVId = ssvCleansedMaster.ssv.Source_System_View_CW_Company__c;

		// Set non primary record
		ssvCleansedList = ssvc.getNonPrimaryRecords();
		ssvList = new List<Source_System_View__c>();
		ssvList.add(ssvCleansedMaster.ssv);
		for (SSVCleansed ssvcl : ssvCleansedList) {
			ssvList.add(ssvcl.ssv);
		}

		// Set existing account and contact to sync to, if any
		this.accountId = ssvc.accountId;
		this.consolidatedAccountId = ssvc.consolidatedAccountId;
		this.contactId = ssvc.contactId;
		this.consolidatedContactId = ssvc.consolidatedContactId;
	}

	public List<SSVCleansed> getSSVCleansedRecords() {
		List<SSVCleansed> ssvcList = new List<SSVCleansed>();
		ssvcList.add(ssvCleansedMaster);
		ssvcList.addAll(ssvCleansedList);
		return ssvcList;
	}

	public Boolean isNew() {
		return isNew;
	}
	
	public Boolean needsAccount() {
		return (masterSSV.Account__c == null && masterSSV.Match_Type__c == 'Company' && String.isBlank(masterSSV.Duplicate_Set_ID__c));        		
	}
	
	// PSH :: Return if SSV had existing account, or primary consolidated SSV had account
	public boolean hasExistingAccount() {
		return this.accountId != null || this.consolidatedAccountId != null;
	}
	
	// PSH :: Return if SSV had existing contact, or primary consolidated SSV had contact
	public boolean hasExistingContact() {
		return this.contactId != null || this.consolidatedContactId != null;
	}

	public Boolean hasSpawnedAccount() {
		return this.accountSpawned != null;
	}

	public Boolean hasSpawnedContact() {
		return this.contactSpawned != null;
	}

	public Boolean hasContactInfo() {
		return contactInfos != null && !contactInfos.isEmpty();
	}

	public Boolean hasAddress() {
		return this.addressMap != null && !this.addressMap.isEmpty();
	}
	
	public Boolean hasAddress(String matchKey) {
		return this.hasAddress() && this.addressMap.containsKey(matchKey);
	}	

	public Boolean hasCustomerAddress() {
		return customerAddresses != null && !customerAddresses.isEmpty();
	}

	public Account createAccount() {

		Reporter.log('Creating Account with Duplicate Set Id: ' + masterSSV.Duplicate_Set_ID__c);

		if (matchType == 'Person') {
			this.accountSpawned = createPersonAccount(masterSSV);
		} else if (matchType == 'Company') {
			this.accountSpawned = createCompanyAccount(masterSSV);
		}
		return this.accountSpawned;
	}

	public Contact createContact(Id accountId, Id recordTypeId) {

		if (matchType == 'Contact') {
			this.accountId = accountId;
			this.contactSpawned = createContactAtAccount(masterSSV, accountId, recordTypeId);
		}
		return this.contactSpawned;
	}

	public void createContactInfos() {

		// create contact information for new source system view records
		if (ssvCleansedMaster.isNew() || !hasContactInfo() ) {
			createContactInfo(ssvCleansedMaster.ssv, true);
		}

		for (SSVCleansed ssvc : ssvCleansedList) {
			if (ssvc.isNew() || !hasContactInfo()) {
				createContactInfo(ssvc.ssv, false);
			}
		}
	}

	public void createContactInfo(Source_System_View__c ssv, Boolean isPrimary) {

		// Determine the master contact id from available contact, or person account contact
		Id masterContactId = getMasterContactId();
		Reporter.log('Master Contact Id for Contact Info: ' + masterContactId);

		if (ssv == null || masterContactId == null) {
			return;
		}

		String phone = getSSVPhone(ssv);

		Reporter.log('Creating Contact Information for: ' + masterContactId);
		Reporter.log('Is Primary: ' + isPrimary);
		Reporter.log('Email Exists: ' + ssv.Email__c);
		Reporter.log('Day Phone Exists: ' + ssv.Day_Phone__c + ', and copying: ' + phone);
		Reporter.log('Alt Phone Exists: ' + ssv.Alternative_Phone__c);

		if (ssv.Email__c != null) {
			Contact_Information__c newContactInfo;

			// if no primary email exists
			if (primaryEmail == null) {
				// then make current email primary
				newContactInfo = createEmailContactInformation(masterContactId, ssv.Email__c, true);
				primaryEmail = newContactInfo;
			} else {
				newContactInfo = createEmailContactInformation(masterContactId, ssv.Email__c, isPrimary);		
			}

			if (newContactInfo != null) {
				contactInfos.add(newContactInfo);
			}
		}
		
		if (phone != null) {
			Contact_Information__c newContactInfo;

			// if no primary phone exists
			if (primaryPhone == null) {
				// then make current phone primary
				newContactInfo = createPhoneContactInformation(masterContactId, phone, true);
				primaryPhone = newContactInfo;
			} else {
				newContactInfo = createPhoneContactInformation(masterContactId, phone, isPrimary);
			}
			
			if (newContactInfo != null) {
				contactInfos.add(newContactInfo);
			}
		}
		
		if (ssv.Alternative_Phone__c != null && ssv.Alternative_Phone__c != '0') {
			
			Contact_Information__c newContactInfo = createPhoneContactInformation(masterContactId, ssv.Alternative_Phone__c, false);
			
			if (newContactInfo != null) {
				contactInfos.add(newContactInfo);
			}
		}

		Reporter.log('Contact Infos Created: ' + contactInfos.size());
	}

	public void createAddresses() {

		// create addresses for new records
		if (!hasAddress(ssvCleansedMaster.ssv.Address_Match_Key__c)) {
			Reporter.log('Creating Address...');

			Address__c newAddress = createAddress(ssvCleansedMaster.ssv);
			if (newAddress != null && newAddress.Address_Match_Key_Hash__c != null) {
				this.addressMap.put(ssvCleansedMaster.ssv.Address_Match_Key__c, newAddress);
			}

			// Set address of master record as primary address
			primaryAddress = newAddress;

			Reporter.log('Created Address:');
		}

		for (SSVCleansed ssvc : ssvCleansedList) {
			if (!hasAddress(ssvc.ssv.Address_Match_Key__c)) {
				Address__c newAddress = createAddress(ssvc.ssv);

				// set as primary address if no primary address exists
				if (primaryAddress == null) {
					primaryAddress = newAddress;
				}
				
				if (newAddress != null && newAddress.Address_Match_Key_Hash__c != null) {
					this.addressMap.put(ssvc.ssv.Address_Match_Key__c, newAddress);
				}
			}
		}
		Reporter.log('Addresses Created: ' + this.addressMap.values().size());
	}

	public void createCustomerAddresses() {

		// Determine the master contact id from available contact, or person account contact
		Id masterContactId = getMasterContactId();
		Reporter.log('Master Contact Id for Customer Address: ' + masterContactId);

		// create customer addresses for new records
		// iterate through addresses and link to contact
		for (Address__c addr : this.addressMap.values()) {

			// Determine if current address is primary address
			Boolean isPrimary = primaryAddress != null && primaryAddress.Address_Match_Key_Hash__c == addr.Address_Match_Key_Hash__c;

			Customer_Address__c newCustomerAddress = createCustomerAddress(masterContactId, addr, isPrimary, (matchType == 'Person' ? 'Residence' : 'Business'));
			if (newCustomerAddress != null) {
				customerAddresses.add(newCustomerAddress);
			}
		}
	}

	public List<Source_System_View__c> linkCustomerDataToSSV() {

		// Determine the master account id from created account, or existing account
		Id masterAccountId = getMasterAccountId();
		Reporter.log('Master Account Id: ' + masterAccountId);

		// Determine the master contact id from created contact, or created person account contact, or existing contact
		// PSH :: or the contactID of the primary consolidated SSV 
		Id masterContactId = getMasterContactId();
		Reporter.log('Master Contact Id: ' + masterContactId);

		List<Source_System_View__c> ssvLinked = new List<Source_System_View__c>();

		for (SSVCleansed ssvc : getSSVCleansedRecords())  {
			
			// PSH :: Set either the contact or account if null
			// This allows for when one or more are null
			// Before only handled if both were null.
			
			if (ssvc.ssv.Contact__c == null || ssvc.ssv.Account__c == null) {
				if (ssvc.ssv.Contact__c == null) {
					ssvc.ssv.Contact__c = masterContactId;
				}
				if (ssvc.ssv.Account__c == null) {
					ssvc.ssv.Account__c = masterAccountId;
				}
				ssvLinked.add(ssvc.ssv);
			}
			/*
			if (ssvc.isNew()) {
				ssvc.ssv.Contact__c = masterContactId;
				ssvc.ssv.Account__c = masterAccountId;
				ssvLinked.add(ssvc.ssv);
			}
			*/
		}

		return ssvLinked;
	}

	public Id getMasterAccountId() {

		// Determine the master account id from created account, or existing account
		Id masterAccountId;
		if (this.accountSpawned != null) {
			masterAccountId = this.accountSpawned.Id;
		} else if (this.contactSpawned != null) {
			masterAccountId = this.contactSpawned.AccountId;
		} else {
			masterAccountId = this.accountId;
		}
		return masterAccountId;
	}

	public Id getMasterContactId() {

		// Determine the master contact id from created contact, or created person account contact, or existing contact
		Id masterContactId;
		if (this.contactSpawned != null) {
			masterContactId = this.contactSpawned.Id;
		} else if (this.accountSpawned != null && personAccountIdToContactId.containsKey(this.accountSpawned.Id)) {
			masterContactId = personAccountIdToContactId.get(this.accountSpawned.Id);
		} else if (this.contactId != null) {
			masterContactId = this.contactId;
		} else if (this.consolidatedContactId != null) {
			// PSH :: Return the contact ID of the master consolidated record
			masterContactId = this.consolidatedContactId;
		}
		return masterContactId;
	}

	public static Account createPersonAccount(Source_System_View__c ssv) {

		return new Account(
			RecordTypeId = personAccountRecType.Id,
			Type = 'Consumer',
			FirstName = ssv.First_Name__c,
			LastName = ssv.Last_Name__c,
			PersonMailingStreet = (ssv.Address_1__c != null && ssv.Address_2__c != null) ? 
							ssv.Address_1__c + '\r\n' + ssv.Address_2__c
							: (ssv.Address_1__c != null) ? ssv.Address_1__c : '',
			PersonMailingCity = ssv.City__c,
			PersonMailingState = ssv.State__c,
			PersonMailingPostalCode = ssv.Zip__c,
			PersonMailingCountry = ssv.Country__c,
			// PersonMailingCountryCode = ssv.Country_Code__c, // cannot set this field, why?
			PersonEmail = ssv.Email__c,
			BillingStreet = (ssv.Address_1__c != null && ssv.Address_2__c != null) ? 
							ssv.Address_1__c + '\r\n' + ssv.Address_2__c
							: (ssv.Address_1__c != null) ? ssv.Address_1__c : '',
			BillingCity = ssv.City__c,
			BillingState = ssv.State__c,
			BillingPostalCode = ssv.Zip__c,
			BillingCountry = ssv.Country__c,
			// BillingCountryCode = ssv.Country_Code__c, // cannot set this field, why?
			Phone = getSSVPhone(ssv),
			Duplicate_Set_ID__c = ssv.Duplicate_Set_ID__c, 
			Fraud_Warning__c = ssv.Fraud_Warning__c
		);
	}

	public static Account createCompanyAccount(Source_System_View__c ssv) {

		return new Account(
			Name = ssv.Company_Name__c,
			RecordTypeId = unclassifiedCompanyAccountRecType.Id,
			Type = 'Unclassified Business',
			BillingStreet = (ssv.Address_1__c != null && ssv.Address_2__c != null) ? 
							ssv.Address_1__c + '\r\n' + ssv.Address_2__c
							: (ssv.Address_1__c != null) ? ssv.Address_1__c : '',
			BillingCity = ssv.City__c,
			BillingState = ssv.State__c,
			BillingPostalCode = ssv.Zip__c,
			BillingCountry = ssv.Country__c,
			// BillingCountryCode = ssv.Country_Code__c, // cannot set this field, why?
			Phone = getSSVPhone(ssv),
			Duplicate_Set_ID__c = ssv.Duplicate_Set_ID__c, 
			Fraud_Warning__c = ssv.Fraud_Warning__c
		);
	}
	
    private static String getAccountRecordTypeName(Id recordTypeId) {
    	if (ACCOUNTS_RECORD_TYPE_IDS.containsKey(recordTypeId)) {    	
    		return ACCOUNTS_RECORD_TYPE_IDS.get(recordTypeId).Name;
    	}
    	return null;
    }	
    
    private static Boolean isContactUnauthorized(String parentAccountRecordTypeName) {
    	return String.isNotBlank(parentAccountRecordTypeName) && (parentAccountRecordTypeName == 'Trade' || parentAccountRecordTypeName == 'Contract');
    }
	
	public static Contact createContactAtAccount(Source_System_View__c ssv, Id accountId, Id recordTypeId) {

		// create a contact only if a last name is present
		if (ssv.Last_Name__c == null) return null;

		return new Contact(
			RecordTypeId = businessContactAccountRecType.Id,
			FirstName = ssv.First_Name__c,
			LastName = ssv.Last_Name__c,
			MailingStreet = (ssv.Address_1__c != null && ssv.Address_2__c != null) ? 
							ssv.Address_1__c + '\r\n' + ssv.Address_2__c
							: (ssv.Address_1__c != null) ? ssv.Address_1__c : '',
			MailingCity = ssv.City__c,
			MailingState = ssv.State__c,
			MailingPostalCode = ssv.Zip__c,
			MailingCountry = ssv.Country__c,
			// MailingCountryCode = ssv.Country_Code__c, // cannot set this field, why?
			Email = ssv.Email__c,
			Phone = getSSVPhone(ssv),
			Duplicate_Set_ID__c = ssv.Duplicate_Set_ID__c,
			AccountId = accountId, 
			Unauthorized_Contact_Checkbox__c = isContactUnauthorized(getAccountRecordTypeName(recordTypeId))
			);
	}

	public static Customer_Address__c createCustomerAddress(Id contactId, 
															Address__c address, 
															Boolean isPrimary,
															String addressType) {
		
		if (contactId == null || address == null) {
			return null;
		}
		
		if (address.Id == null) {
			Reporter.log('attempted to create customer address with no address: ' + contactId);
			return null;
		}

		return new Customer_Address__c(
			Contact__c = contactId,
			Address__c = address.Id,
			Is_Principal_Address__c = isPrimary, // data scrub later to set true primary customer address
			Is_Inactive__c = false,
			Address_Type__c = addressType 
		);
	}

	public static Address__c createAddress(Source_System_View__c ssv) {
		
		// Do not create an empty address
		if (String.isEmpty(ssv.Address_1__c) && String.isEmpty(ssv.City__c) && String.isEmpty(ssv.State__c) && String.isEmpty(ssv.Zip__c) ) {
			return null;
		}
		
		// Build address
		Address__c newAddress = new Address__c(
			Address_1__c = ssv.Address_1__c,
			Address_2__c = ssv.Address_2__c,
			City__c = ssv.City__c,
			State__c = ssv.State__c,
			Zip__c = ssv.Zip__c,
			Country__c = ssv.Country__c,
			Country_Code__c = ssv.Country_Code__c
		);

		// Set address match keys
		newAddress.Address_Match_Key__c = SSVCleaner.buildAddressMatchKey(newAddress);
		newAddress.Address_Match_Key_Hash__c = SSVCleaner.encodeHash(newAddress.Address_Match_Key__c);

		return newAddress;
	}

	public static Contact_Information__c createEmailContactInformation(	Id contactId,
																	String email, 
																	Boolean isPrimary) {
		// Build contact information record
		Contact_Information__c newContactInformation = new Contact_Information__c(
				Contact__c = contactId,
				Is_Primary__c = isPrimary, // data scrub later to set true primary customer email
				Contact_Information_Medium__c = 'Email',
				Name = email,
				Email__c = email
			);

		// Set record type
		newContactInformation.RecordTypeId = contactInfoRecordTypes.get('Email').getRecordTypeId();

		// Set contact information match keys
		newContactInformation.Contact_Information_Match_Key__c = 
			SSVCleaner.buildContactInfoMatchKey(newContactInformation);
		newContactInformation.Contact_Information_Match_Key_Hash__c = 
			SSVCleaner.encodeHash(newContactInformation.Contact_Information_Match_Key__c);

		return newContactInformation;
	}

	public static Contact_Information__c createPhoneContactInformation(	Id contactId,
																	String phone,
																	Boolean isPrimary) {
		// Build contact information record
		Contact_Information__c newContactInformation = new Contact_Information__c(
				Contact__c = contactId,
				Is_Primary__c = isPrimary, // data scrub later to set true primary customer phone
				Name = phone,
				Contact_Information_Medium__c = 'Phone',
				Phone__c = phone
			);

		// Set record type
		newContactInformation.RecordTypeId = contactInfoRecordTypes.get('Phone').getRecordTypeId();

		// Set contact information match keys
		newContactInformation.Contact_Information_Match_Key__c = 
			SSVCleaner.buildContactInfoMatchKey(newContactInformation);
		newContactInformation.Contact_Information_Match_Key_Hash__c = 
			SSVCleaner.encodeHash(newContactInformation.Contact_Information_Match_Key__c);

		return newContactInformation;
	}

	public static String getSSVPhone(Source_System_View__c ssv) {

		// Original
		//return ssv.Day_Phone__c;

		// Option A
		return (ssv.Day_Phone__c != '0') ? ssv.Day_Phone__c : null;
		
		// Option B
		//return ssv.Day_Phone_Match_Key__c;

	}
}