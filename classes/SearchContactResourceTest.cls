@isTest
public with sharing class SearchContactResourceTest {

	public static testMethod void testSearchParamterLogic() {
		// given
		SearchContactResource.SearchParameters parameters = new SearchContactResource.SearchParameters();
		// when
		parameters.Company = 'test-company';
		// then
		System.assertEquals(true, parameters.hasAccountFilter());
		// when
		parameters.Company = '';
		// then
		System.assertEquals(false, parameters.hasAccountFilter());
		// when
		parameters.PhoneNumber = '123456789';
		// then
		System.assertEquals(true, parameters.hasContactInformationFilter());
		// when
		parameters.PhoneNumber = '';
		// then
		System.assertEquals(false, parameters.hasContactInformationFilter());
		// when
		parameters.PostalCode = 'MK11 1DG';
		// then
		System.assertEquals(true, parameters.hasContactAddressFilter());
		// when
		parameters.PostalCode = '';
		// then
		System.assertEquals(false, parameters.hasContactAddressFilter());
	}

	public static testMethod void testFilterPersonAccount() {
		RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'RH End Customer' and SObjectType = 'Account'];
		RecordType vendorAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Vendor' and SObjectType = 'Account'];
		System.assertNotEquals(null, SearchContactResource.ACCOUNT_RECORD_TYPES, 'record types not initialized');
		SearchContactResource.SearchParameters clientRequest = new SearchContactResource.SearchParameters();
		clientRequest.accountTypes = 'RH End Customer';
		// System.assertEquals(personAccountRecordType.Id, SearchContactResource.buildRecordTypeFilter(clientRequest).get(0)); // fix
		clientRequest.accountTypes = 'Vendor';
		// System.assertEquals(vendorAccountRecordType.Id, SearchContactResource.buildRecordTypeFilter(clientRequest).get(0)); // fix
		clientRequest.accountTypes = null;
		System.assertEquals(null, SearchContactResource.buildRecordTypeFilter(clientRequest));
		clientRequest.accountTypes = '';
		System.assertEquals(null, SearchContactResource.buildRecordTypeFilter(clientRequest));
	}

	public static testMethod void testBuildSearchParameters() {
		String jsonRequest = '{"ClientLookupRequest":{"FirstName":"Paulie", "LastName":"Hemmings"}}';
		SearchContactResource.SearchParameters convertedRequest = SearchContactResource.buildSearchParameters(jsonRequest);
		System.assertEquals('Paulie', convertedRequest.firstName);
		System.assertEquals('Hemmings', convertedRequest.lastName);
	}

	public static testMethod void testAppendContactDetails() {

		PrepareData.populateCustomSettings();
		
		// given membership specific records

		initializeMembershipTables();
		
		// given (user to insert records)

		User u = TestDataFactory.createUser();
        u.Single_View_of_Customer_Process_User__c = false;

        // given (new order)

        Rh_Order__c rhOrder = new Rh_Order__c();
        System.runAs(u) {
        	database.insert(rhOrder);
        }

		// given (new person account)

		Id personAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('RH End Customer').getRecordTypeId();
		Account testAccount = new Account(RecordTypeId = personAccountRecTypeId,
								  FirstName='paul',
								  LastName='hemmings',
								  PersonMailingStreet='123 Mailing Street',
								  PersonMailingPostalCode='94949',
								  PersonMailingCity='Burnaby',
								  PersonEmail='paul@paul.com');

        System.runAs(u) {
			insert testAccount;
        }

        // then (get Contact)

        Contact contact = [ SELECT ID FROM Contact WHERE AccountID = :testAccount.Id];
        Set<ID> foundContactIds = new Set<ID>();
        foundContactIds.add(contact.Id);
        Map<Id, Contact> contactMap = SearchContactResource.getContactMap(foundContactIds, 40);

        // given search response populated with that account and contact

        SearchContactResource.SearchResponse searchResponse = new SearchContactResource.SearchResponse();

        searchResponse.accountMap = new Map<String, SearchContactResource.AccountDet>();
        searchResponse.accountMap.put(testAccount.Id, new SearchContactResource.AccountDet(testAccount));

        searchResponse.accountMap.get(testAccount.Id).contactMap = new Map<String, SearchContactResource.ContactDet>();
        searchResponse.accountMap.get(testAccount.Id).contactMap.put(contact.Id, new SearchContactResource.ContactDet(contactMap.get(contact.Id)));

        // when.

        SearchContactResource.SearchResponse appendedResponse = SearchContactResource.appendContactDetails(searchResponse, foundContactIds);

        // then (membership id is null)

        system.assertEquals(null, appendedResponse.accountMap.get(testAccount.Id).contactMap.get(contact.Id).RHMemberId);

        // given (add membership)
        // if ((membershipRecords.get(index).Cancellation_Type__c != 'RH Terminated' && membershipRecords.get(index).Cancellation_Reason__c != 'Created in error' && membershipRecords.get(index).Cancellation_Reason__c != 'Duplicate membership')

        List<Membership__c> newMemberships = new List<Membership__c>();
        newMemberships.add(new Membership__c (
	        	Contact__c = contact.Id
	        	,Member_Email__c = 'paul@paul.com'
	        	,Cancellation_Type__c = 'RH Terminated'
	        	,Cancellation_Reason__c = 'Created in error'
//	            ,Once_was_Quebecois__c = false
	        )
        );
        newMemberships.add(new Membership__c (
	        	Contact__c = contact.Id
	        	,Member_Email__c = 'aiden@paul.com'
	        	,Cancellation_Type__c = 'RH Terminated'
	        	,Cancellation_Reason__c = 'Duplicate membership'	        	
//	            ,Once_was_Quebecois__c = false
	        )
        );

        System.runAs(u) {
			insert newMemberships;
        }

        // when

		appendedResponse = SearchContactResource.appendContactDetails(searchResponse, foundContactIds);

		// then (membership id is not null)

		system.assertNotEquals(null, appendedResponse.accountMap.get(testAccount.Id).contactMap.get(contact.Id).RHMemberId);
		system.assertNotEquals(true, appendedResponse.accountMap.get(testAccount.Id).contactMap.get(contact.Id).EligibleForMemberBenefits);
		system.assertEquals('Duplicate membership', appendedResponse.accountMap.get(testAccount.Id).contactMap.get(contact.Id).MemberCancellationReason);
		
		// when (added a membership that is elligible)
		
        System.runAs(u) {
			insert new Membership__c (
	        	Contact__c = contact.Id
	        	,Member_Email__c = 'tyler@paul.com'
				,Enrollment_Date_Time__c = Date.today().addDays(-1)  
				,Expiration_Date_Time__c = Date.today().addDays(1)    	        	
//	            ,Once_was_Quebecois__c = false
	        );
        }
        
        // when (check that there is a membership that is eligible)
        
        system.assertEquals(1, [SELECT ID FROM Membership__c WHERE Contact__c = :contact.Id AND Eligible_for_Member_Benefits__c = true].size());
        
        // when

		appendedResponse = SearchContactResource.appendContactDetails(searchResponse, foundContactIds);        
        
		// then (that membership id is returned)

		system.assertNotEquals(null, appendedResponse.accountMap.get(testAccount.Id).contactMap.get(contact.Id).RHMemberId);
		system.assertEquals(true, appendedResponse.accountMap.get(testAccount.Id).contactMap.get(contact.Id).EligibleForMemberBenefits);
		system.assertEquals(null, appendedResponse.accountMap.get(testAccount.Id).contactMap.get(contact.Id).MemberCancellationReason);
        
		
	}

    public static testMethod void testAccount() {

    	// GIVEN (account created)
    	String testCompanyName = 'test company name';
    	String testTradeId = '123456789123';
    	Account testAccount = new Account(
    		Name = testCompanyName,
    		X12_Digit_Member__c = testTradeId,
    		BillingStreet = '1 Street',
    		ShippingStreet = '1 Avenue'
    	);
    	database.insert(testAccount);
		// WHEN (invalid company name)
    	SearchContactResource.SearchParameters companyParams = new SearchContactResource.SearchParameters();
    	companyParams.company = 'paul';

    	// THEN (none returned)
    	Map<Id, Account> matchingAccounts = SearchContactResource.filterAccounts(companyParams);
    	System.assertEquals(0, matchingAccounts.values().size());

    	// WHEN (valid company name)
    	companyParams.company = testCompanyName;

    	// THEN (one returned)
    	matchingAccounts = SearchContactResource.filterAccounts(companyParams);
    	System.assertEquals(1, matchingAccounts.size());

    	// WHEN (valid tradeId)
    	companyParams.company = null;
    	companyParams.tradeId = testTradeId;

    	// THEN (one returned)
    	matchingAccounts = SearchContactResource.filterAccounts(companyParams);
    	System.assertEquals(1, matchingAccounts.values().size());
    }

    public static testMethod void testContact() {
		// GIVEN (contact created)
		List<Contact> contacts = new List<Contact>();
    	contacts.add(new Contact(FirstName = 'paul', LastName = 'hemmings', Email = 'test@test.com', Phone = '6501231234', Membership_ID__c = 'some-id'));
    	contacts.add(new Contact(FirstName = 'other', LastName = 'person', Email = 'email@email.com', Phone = '4151231234'));
    	database.insert(contacts);

    	// WHEN (valid name filter)
    	SearchContactResource.SearchParameters filterParams = new SearchContactResource.SearchParameters();
    	filterParams.firstName = 'paul';
    	filterParams.lastName = 'hemmings';
		// THEN (one returned)
		List<Contact> searchResults = SearchContactResource.filterContacts(filterParams);
		System.assertEquals(1, searchResults.size());

    	// WHEN (valid email)
    	filterParams.firstName = null;
    	filterParams.lastName = null;
    	filterParams.email = 'test@test.com';
		// THEN (one returned)
		searchResults = SearchContactResource.filterContacts(filterParams);
		System.assertEquals(1, searchResults.size());
		System.assertEquals(contacts.get(0).Id, searchResults.get(0).Id);
    	// WHEN (valid phone)
    	filterParams.firstName = null;
    	filterParams.lastName = null;
    	filterParams.email = null;
    	filterParams.phoneNumber = '6501231234';
		// THEN (one returned)
		searchResults = SearchContactResource.filterContacts(filterParams);
		System.assertEquals(1, searchResults.size());

		// WHEN (nothing valid - negative test)
    	filterParams.firstName = 'waldo';
    	filterParams.lastName = null;
    	filterParams.email = null;
    	filterParams.phoneNumber = '1231234123';
		// THEN (none returned)
		searchResults = SearchContactResource.filterContacts(filterParams);
		System.assertEquals(0, searchResults.size());

    	// WHEN (valid tradeId)
    	filterParams.firstName = null;
    	filterParams.lastName = null;
    	filterParams.email = null;
    	filterParams.phoneNumber = null;
    	filterParams.rhMemberId = 'some-id';

    	// THEN (one returned)
		searchResults = SearchContactResource.filterContacts(filterParams);
		System.assertEquals(1, searchResults.size());

    }
    
    public static testMethod void testContactAddress() {
    	
		// GIVEN (contact address feature flag enabled)
		
		Feature_Flags__c featureFlags = new Feature_Flags__c(
			Single_Pane_CCLU_Feature__c = true,
			MDM_Address_Feature__c = true,
			MDM_Merge_feature__c = true
		);
		insert featureFlags;
				
    	// GIVEN (account)
    	Account testAccount = new Account(Name = 'test company name', X12_Digit_Member__c = '123456789123');
    	database.insert(testAccount);

    	// GIVEN (contact)
    	Contact testContact = new Contact(AccountId = testAccount.Id, FirstName = 'paul', LastName = 'hemmings');
    	database.insert(testContact);

    	// GIVEN - Contact_Address
    	Contact_Address__c testAddress = new Contact_Address__c(
    		Contact__c = testContact.Id,
    		Address_1__c = 'test one',
    		Address_2__c = 'test two',
    		City__c = 'test three',
    		State__c = 'CA',
    		Country__c = 'US',
    		Zip__c = '94949-1234',
    		First_Name__c = 'paul',
    		Last_Name__c = 'hemmings',
    		Company_Name__c = 'company name',
    		Is_Inactive__c = false,
    		is_Sold_To_Address__c = true
    	);
    	database.insert(testAddress);
    	
    	// WHEN (valid name filter)
    	SearchContactResource.SearchParameters filterParams = new SearchContactResource.SearchParameters();
    	filterParams.firstName = 'paul';
    	filterParams.lastName = 'hemmings';
    	filterParams.PostalCode = '94949';

    	// THEN (one returned)
		List<Contact_Address__c> searchResults = SearchContactResource.filterContactAddress(filterParams);
		System.assertEquals(1, searchResults.size());

    	// WHEN (valid name filter)
    	filterParams = new SearchContactResource.SearchParameters();
    	filterParams.Company = 'test company name';
    	filterParams.PostalCode = '94949';

    	// THEN (one returned)
		searchResults = SearchContactResource.filterContactAddress(filterParams);
		System.assertEquals(1, searchResults.size());

		// WHEN (invalid name filter)
    	filterParams = new SearchContactResource.SearchParameters();
    	filterParams.Company = 'mr blobbies fun factory';
    	filterParams.PostalCode = '94949';

    	// THEN (none returned)
		searchResults = SearchContactResource.filterContactAddress(filterParams);
		System.assertEquals(0, searchResults.size());
    }
    
    public static testMethod void testFindMembership() {
    	
		PrepareData.populateCustomSettings();
		
		// GIVEN - membership records

		initializeMembershipTables();    	
    	
    	// GIVEN (account)
    	Account testAccount = new Account(Name = 'test company name', X12_Digit_Member__c = '123456789123');
    	database.insert(testAccount);
    	
    	// GIVEN (contact)
    	Contact testContact = new Contact(AccountId = testAccount.Id, FirstName = 'paul', LastName = 'hemmings');
    	database.insert(testContact);
    	
    	// GIVEN (membership)
		Membership__c testMembership = new Membership__c(
			 Contact__c = testContact.Id
        	,Member_Email__c = 'paul@paul.com'
//            ,Once_was_Quebecois__c = false			
		);
		database.insert(testMembership);    	
		
		// WHEN (query for inserted membership)
		List<Membership__c> fullMembershipList = [SELECT Name FROM Membership__c WHERE Contact__c = :testContact.Id];
		
		// THEN (membership record returned)
		system.assertEquals(1, fullMembershipList.size());
		
    	// WHEN (valid filter using inserted membership Id)
    	SearchContactResource.SearchParameters filterParams = new SearchContactResource.SearchParameters();
    	filterParams.RhMemberId = fullMembershipList.get(0).Name;    	
    	
    	// THEN (membership returned)
    	List<Membership__c> searchResults = SearchContactResource.filterMembership(filterParams);
    	System.assertNotEquals(null, searchResults);
    	System.assertEquals(1, searchResults.size());    	
    }

    public static testMethod void testFindContactInformation() {

    	// GIVEN (account)
    	Account testAccount = new Account(Name = 'test company name', X12_Digit_Member__c = '123456789123');
    	database.insert(testAccount);

    	// GIVEN (contact created)
    	Contact testContact = new Contact(AccountId = testAccount.Id, FirstName = 'paul', LastName = 'hemmings');
    	database.insert(testContact);

    	// GIVEN (contact information created)
    	Contact_Information__c ci = new Contact_Information__c(
    		Contact__c = testContact.Id,
    		Contact_Information_Medium__c = 'Email',
    		Email__c = 'email@email.com',
    		Contact_Information_Match_Key_Hash__c = SSVCleaner.encodeHash('Email' + 'email@email.com')
    	);

    	database.insert(ci);
		// WHEN (query for all CI)
		List<Contact_Information__c> fullContactList = database.query('SELECT ID, Contact_Information_Match_Key_Hash__c FROM Contact_Information__c');

		// THEN (one returned)
		system.debug('countact loaded: ' + fullContactList);
		System.assertNotEquals(null, fullContactList);
		System.assertEquals(1, fullContactList.size());

		// WHEN (valid filter)
    	SearchContactResource.SearchParameters filterParams = new SearchContactResource.SearchParameters();
    	filterParams.firstName = 'paul';
    	filterParams.lastName = 'hemmings';
    	filterParams.email = 'email@email.com';
		// THEN (one returned)
		List<Contact_Information__c> searchResults = SearchContactResource.filterContactInformation(filterParams);
		System.assertEquals(1, searchResults.size());

		// WHEN (valid email filter)
    	filterParams = new SearchContactResource.SearchParameters();
    	filterParams.email = 'email@email.com';

		// THEN (one returned)
    	searchResults = SearchContactResource.filterContactInformation(filterParams);
    	System.assertNotEquals(null, searchResults);
    	System.assertEquals(1, searchResults.size());

    	// WHEN (valid name filter)
    	filterParams = new SearchContactResource.SearchParameters();
    	filterParams.email = 'email@email.com';
    	filterParams.PostalCode = '94949';


    	// THEN (one returned)
		searchResults = SearchContactResource.filterContactInformation(filterParams);
		System.assertEquals(1, searchResults.size());
    }

    public static testMethod void testFilterCustomerAddress() {

    	// GIVEN (account)
    	Account testAccount = new Account(Name = 'test company name', X12_Digit_Member__c = '123456789123');
    	database.insert(testAccount);

    	// GIVEN (contact)
    	Contact testContact = new Contact(AccountId = testAccount.Id, FirstName = 'paul', LastName = 'hemmings');
    	database.insert(testContact);

    	// GIVEN (Address)
    	Address__c testAddress = new Address__c(
    		Address_1__c = 'test one',
    		Address_2__c = 'tes two',
    		City__c = 'test three',
    		State__c = 'CA',
    		Country__c = 'US',
    		Zip__c = '94949-1234'
    	);
    	database.insert(testAddress);
		// GIVEN (customer address)
		Customer_Address__c ca = new Customer_Address__c(
			Contact__c = testContact.Id,
			Is_Inactive__c = false,
			Is_Principal_Address__c = true,
			Address__c = testAddress.Id
		);
		database.insert(ca);

    	// WHEN (valid name filter)
    	SearchContactResource.SearchParameters filterParams = new SearchContactResource.SearchParameters();
    	filterParams.firstName = 'paul';
    	filterParams.lastName = 'hemmings';
    	filterParams.PostalCode = '94949';

    	// THEN (one returned)
		List<Customer_Address__c> searchResults = SearchContactResource.filterCustomerAddress(filterParams);
		System.assertEquals(1, searchResults.size());

    	// WHEN (valid name filter)
    	filterParams = new SearchContactResource.SearchParameters();
    	filterParams.Company = 'test company name';
    	filterParams.PostalCode = '94949';

    	// THEN (one returned)
		searchResults = SearchContactResource.filterCustomerAddress(filterParams);
		System.assertEquals(1, searchResults.size());

		// WHEN (invalid name filter)
    	filterParams = new SearchContactResource.SearchParameters();
    	filterParams.Company = 'mr blobbies fun factory';
    	filterParams.PostalCode = '94949';

    	// THEN (none returned)
		searchResults = SearchContactResource.filterCustomerAddress(filterParams);
		System.assertEquals(0, searchResults.size());
    }

    public static testMethod void testFindMatchingRecords() {
    	
		// GIVEN (test User)    			
		User u = TestDataFactory.createUser();
		u.Single_View_of_Customer_Process_User__c = true;
		    	
    	// GIVEN - MDM triggers on     	
		TriggerManager__c triggerManager = new TriggerManager__c(SetupOwnerId = u.Id, runTriggers__c=true, runMDMTriggers__c=true);		
		insert triggerManager;
		
		Feature_Flags__c featureFlags = new Feature_Flags__c(Single_Pane_CCLU_Feature__c = false);
		insert featureFlags;		

    	// GIVEN (company account)
    	Account testAccount = new Account(
    	    Name = 'test company name',
    		X12_Digit_Member__c = '123456789123',
    		BillingStreet = '1 Street',
    		ShippingStreet = '1 Avenue'
    	);
    	database.insert(testAccount);

    	// GIVEN (valid company filter)
    	SearchContactResource.SearchParameters filterParams = new SearchContactResource.SearchParameters();
    	filterParams.company = 'test company name';

    	// WHEN (get matching records)
		SearchContactResource.MatchingRecords records = SearchContactResource.findMatchingRecords(filterParams);

		// THEN (one returned)
		System.assertEquals(0, records.matchingContactIds.size());
		System.assertEquals(1, records.matchingAccounts.size());

		// GIVEN (add a contact to existing account)
		Contact testContact = new Contact(
			AccountId = testAccount.Id,
			FirstName = 'paul',
			LastName = 'hemmings',
			Email = 'email@email.com',
			Phone = '6501231234',
			Membership_ID__c = 'some-id'
		);

		// GIVEN (insert contact so no contactinformation created)
        System.runAs(u) {
			database.insert(testContact);
        }

    	// WHEN (get matching records)
		records = SearchContactResource.findMatchingRecords(filterParams);

		// THEN (one returned)
		System.assertEquals(1, records.matchingContactIds.size());
		System.assertEquals(null, records.matchingAccounts);

		// GIVEN (add email to filter)
		filterParams.Email = 'email@email.com';

    	// WHEN (get matching records)
		records = SearchContactResource.findMatchingRecords(filterParams);

		// THEN (none returned - no CI yet created)
		System.assertEquals(0, records.matchingContactIds.size());
		System.assertEquals(null, records.matchingAccounts);

		// GIVEN (contact information created)
    	Contact_Information__c ci = new Contact_Information__c(
    		Contact__c = testContact.Id,
    		Contact_Information_Medium__c = 'Email',
    		Email__c = 'email@email.com',
    		Contact_Information_Match_Key_Hash__c = SSVCleaner.encodeHash('Email' + 'email@email.com')
    	);
    	database.insert(ci);

    	// WHEN (get matching records)
		records = SearchContactResource.findMatchingRecords(filterParams);

		// THEN (one returned)
		System.assertEquals(1, records.matchingContactIds.size());
		System.assertEquals(null, records.matchingAccounts);

    }

    public static testMethod void testHandleRequest() {
    	
		// given (user to insert records)
		User u = TestDataFactory.createUser();
        u.Single_View_of_Customer_Process_User__c = true;    
        
		// GIVEN - MDM triggers on     	
		TriggerManager__c triggerManager = new TriggerManager__c(SetupOwnerId = u.Id, runTriggers__c=true, runMDMTriggers__c=true);
		insert triggerManager;
		
		Feature_Flags__c featureFlags = new Feature_Flags__c(
			Single_Pane_CCLU_Feature__c = false,
			MDM_Address_Feature__c = true,
			MDM_Merge_feature__c = true
		);
		insert featureFlags;		

    	// GIVEN (account created)
    	String testCompanyName = 'test company name';
    	String testTradeId = '123456789123';

    	Account testAccount = new Account(
    	    Name = testCompanyName,
    		X12_Digit_Member__c = testTradeId,
    		BillingStreet = '1 Street',
    		ShippingStreet = '1 Avenue'
    	);
    	System.runAs(u) {
    		database.insert(testAccount);
    	}
    	
		// GIVEN (contact created and linked)
		List<Contact> testContacts = new List<Contact>();
    	testContacts.add(new Contact(
    		AccountId = testAccount.Id, 
    		FirstName = 'paul', 
    		LastName = 'hemmings', 
    		Email = 'email@email.com', 
    		Phone = '6501231234', 
    		Membership_ID__c = 'some-id')
    	);
    	System.runAs(u) {
    		database.insert(testContacts);
    	}

    	// GIVEN (Address)
    	Address__c testAddress = new Address__c(
    		Address_1__c = 'test one',
    		Address_2__c = 'tes two',
    		City__c = 'test three',
    		State__c = 'CA',
    		Country__c = 'US',
    		Zip__c = '94949'
    	);    	
    	database.insert(testAddress);
    	
		// GIVEN (customer address)
		Customer_Address__c ca = new Customer_Address__c(
			Contact__c = testContacts.get(0).Id,
			Is_Inactive__c = false,
			Is_Principal_Address__c = true,
			Address__c = testAddress.Id
		);
		database.insert(ca);

		// GIVEN (contact information created)
		List<Contact_Information__c> ciList = new List<Contact_Information__c>();
    	ciList.add(new Contact_Information__c(
    		Contact__c = testContacts.get(0).Id,
    		Contact_Information_Medium__c = 'Email',
    		Email__c = 'email@email.com',
    		Contact_Information_Match_Key_Hash__c = SSVCleaner.encodeHash('Email' + 'email@email.com')
    	));
    	ciList.add(new Contact_Information__c(
    		Contact__c = testContacts.get(0).Id,
    		Contact_Information_Medium__c = 'Phone',
    		Phone__c = '123-123-1234',
    		Contact_Information_Match_Key_Hash__c = SSVCleaner.encodeHash('Phone' + '123-123-1234')
    	));    	
    	database.insert(ciList);

    	// WHEN (valid name filter)
    	SearchContactResource.SearchParameters filterParams = new SearchContactResource.SearchParameters();
    	filterParams.firstName = 'paul';
    	filterParams.lastName = 'hemmings';

    	// THEN (one returned)
		SearchContactResource.SearchResponse searchResponse = SearchContactResource.handleRequest(filterParams);
		System.assertNotEquals(null, searchResponse.accounts);
		System.assertEquals(1, searchResponse.accountMap.values().size());
		System.assertEquals(testAccount.Id, searchResponse.accountMap.values().get(0).Id);
    	System.assertEquals(1, searchResponse.accountMap.get(testAccount.Id).contactMap.values().size());
    	System.assertEquals(testContacts.get(0).Id, searchResponse.accountMap.get(testAccount.Id).contactMap.values().get(0).Id);
    	System.assertEquals('paul', searchResponse.accountMap.get(testAccount.Id).contactMap.get(testContacts.get(0).Id).FirstName);
    	System.assertEquals('hemmings', searchResponse.accountMap.get(testAccount.Id).contactMap.get(testContacts.get(0).Id).LastName);
    	System.assertEquals('test company name', searchResponse.accountMap.get(testAccount.Id).contactMap.get(testContacts.get(0).Id).Company);
    	System.assertEquals(1, searchResponse.accountMap.get(testAccount.Id).contactMap.get(testContacts.get(0).Id).addresses.size());
    	System.assertEquals(1, searchResponse.accountMap.get(testAccount.Id).contactMap.get(testContacts.get(0).Id).emails.size());
    	System.assertEquals(1, searchResponse.accountMap.get(testAccount.Id).contactMap.get(testContacts.get(0).Id).phoneNumbers.size());

    	// WHEN (invalid filter)
		filterParams = new SearchContactResource.SearchParameters();
    	filterParams.firstName = 'invalid';
    	filterParams.lastName = 'name';

    	// THEN (none returned)
		searchResponse = SearchContactResource.handleRequest(filterParams);
		System.assertNotEquals(null, searchResponse.accounts);
		System.assertEquals(0, searchResponse.accountMap.values().size());

		// WHEN (valid account level filter)
    	filterParams = new SearchContactResource.SearchParameters();
    	filterParams.firstName = null;
    	filterParams.lastName = null;
    	filterParams.Company = testCompanyName;

    	// THEN (one returned)
		searchResponse = SearchContactResource.handleRequest(filterParams);
		System.assertEquals(1, searchResponse.TotalRecords);
		System.assertEquals(1, searchResponse.accountMap.get(testAccount.Id).contacts.size());
    	System.assertEquals('paul', searchResponse.accountMap.get(testAccount.Id).contactMap.get(testContacts.get(0).Id).FirstName);
    	System.assertEquals('1 Street', searchResponse.accountMap.get(testAccount.Id).Addresses.get(0).StreetAddress1);
    	System.assertEquals('1 Avenue', searchResponse.accountMap.get(testAccount.Id).Addresses.get(1).StreetAddress1);
    }

    public static testMethod void testRecordTypeFilter() {
    	
		// given (user to insert records)
		User u = TestDataFactory.createUser();
        u.Single_View_of_Customer_Process_User__c = true;            	
    	
    	// GIVEN - MDM triggers on     	
		TriggerManager__c triggerManager = new TriggerManager__c(SetupOwnerId = u.Id, runTriggers__c=true, runMDMTriggers__c=true);
		insert triggerManager;
		    	
		// GIVEN (vendor record type)
		RecordType vendorAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Vendor' and SObjectType = 'Account'];

    	// GIVEN (account created)
    	String testCompanyName = 'test company name';
    	String testTradeId = '123456789123';
    	Account testAccount = new Account(Name = testCompanyName, X12_Digit_Member__c=testTradeId, RecordTypeId = vendorAccountRecordType.Id);
    	database.insert(testAccount);

		// GIVEN (contact created and linked)
		List<Contact> testContacts = new List<Contact>();
    	testContacts.add(new Contact(AccountId = testAccount.Id, FirstName = 'paul', LastName = 'hemmings', Email = 'email@email.com', Phone = '6501231234', Membership_ID__c = 'some-id'));
    	testContacts.add(new Contact(AccountId = testAccount.Id, FirstName = 'other', LastName = 'person', Email = 'test@test.com', Phone = '4151231234'));
    	testContacts.add(new Contact(FirstName = 'unlrelated', LastName = 'person', Email = 'email@email.com', Phone = '4151231234'));
    	database.insert(testContacts);

    	// WHEN (name, person, invalid record type)
		SearchContactResource.SearchParameters filterParams = new SearchContactResource.SearchParameters();
    	filterParams.tradeId = '123456789123';
    	filterParams.lastName = 'hemmings';
    	filterParams.accountTypes = 'RH End Customer';

    	// THEN
    	SearchContactResource.SearchResponse searchResponse = SearchContactResource.handleRequest(filterParams);
		System.assertNotEquals(null, searchResponse.accounts);
		System.assertEquals(0, searchResponse.accountMap.values().size());

		// WHEN (name, person, valid record type)
		filterParams = new SearchContactResource.SearchParameters();
    	filterParams.tradeId = '123456789123';
    	filterParams.lastName = 'hemmings';
    	filterParams.accountTypes = 'Vendor';

    	// THEN
    	searchResponse = SearchContactResource.handleRequest(filterParams);
		System.assertNotEquals(null, searchResponse.accounts);
		System.assertEquals(1, searchResponse.accountMap.values().size());
		System.assertEquals('Vendor', searchResponse.accountMap.get(testAccount.Id).AccountType);

    }
    
	private static void initializeMembershipTables() {
  	
		TriggerManager__c settings = TriggerManager__c.getOrgDefaults();
		settings.runMembershipTriggers__c = true;
		upsert settings TriggerManager__c.Id;
     
		/*
		MembershipNumber__c settings2 = MembershipNumber__c.getOrgDefaults();
		settings2.Adjustor__c = 1000000000;
		upsert settings2 MembershipNumber__c.Id;     
     
		List<SObject> customSettings = new List<SObject>();
		customSettings.add(new Quebecois__c(
			CountryValue__c = 'CA:C.A.:CAN:C.A.N.:CANADA',
    	    ProvinceValue__c = 'QC:QC:Q.C.:QUE.:QUEBEC:QU�BEC'
		));        
		database.insert(customSettings);      
	
	     MembershipExpiration__c me = new MembershipExpiration__c();
	     me.Cancellation_Type__c = 'Member Cancelled';
	     me.Name = 'Default';
	     database.insert(me);	
		*/
	      
	     Member_Renewal_SKU__c mr = new Member_Renewal_SKU__c();
	     mr.SKU_Names__c = '91020003BC30:91020005RH30:91020006EXPR:91020007EXPR:91020009BC1Y:91020008RH1Y:91020001RH';
	     mr.Name = 'a2G2C0000008PQq';
	     database.insert(mr);
	      
	     MembershipSKU__c msku = new MembershipSKU__c();
	     msku.SKU__c = '91020001RH';
	     msku.Name = '01t50000002ZvLDAA0';
	     database.insert(msku);
	    
	     MembershipAmount__c ma = new MembershipAmount__c();
	     ma.Name = 'Annual';
	     ma.Unit__c = 'year';
	     ma.Amount__c = 100;
	     ma.Tax__c = 15;
	     database.insert(ma);   
		
		/*
	     RH_Brand__c brand = new RH_Brand__c();
	     brand.Name = '999';
	     brand.RH_Members_Program_Profile_URL__c = 'https://www.restorationhardware.com/my-account/membership.jsp';
	     database.insert(brand);
	     
		 RH_Web_Services__c dataSource = new RH_Web_Services__c();
		 dataSource.Name = 'getPaymentDetail';   
         dataSource.Service_URL__c = 'test-url';
         database.insert(dataSource);
		*/
	}    
}