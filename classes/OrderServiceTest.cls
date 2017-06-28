@isTest
public with sharing class OrderServiceTest {

	public static testMethod void testHandleSoldToContactChange() {

		PrepareData.populateCustomSettings();
		
		// given a contact

		List<Contact> testContacts = new List<Contact>();
		testContacts.add(new Contact(
			FirstName = 'paul', 
			LastName = 'hemmings'
		));
		database.insert(testContacts);

		// given an order (pointing to contact)

		List<Rh_Order__c> testOrders = new List<Rh_Order__c>();
		testOrders.add(new Rh_Order__c(
			Name='test order',
			SOLD_TO_ADDRESS_1__C = '4 cielo lane',
			BILL_TO_ADDRESS_1__C = '4 cielo lane',			 
			Contact_Sold_To__c = testContacts.get(0).Id
		));
		database.insert(testOrders);

		// when (order processed)

		database.update(ContactAddressService.buildAddressForOrders(testOrders, ContactAddressService.ORDER_ADDRESS_TYPE.SOLD_TO));
		database.update(ContactAddressService.buildAddressForOrders(testOrders, ContactAddressService.ORDER_ADDRESS_TYPE.BILL_TO));

		// when (order with associations retrieved)

		List<Rh_Order__c> processedOrders = [
			SELECT ID, Contact_Sold_To__c, Address_Sold_To__c, Address_Bill_To__c FROM Rh_Order__c
		];

		// then order is linked to a contact-address

		for (Rh_Order__c order : processedOrders) {
			system.assertNotEquals(null, order.Address_Sold_To__c);
			system.assertNotEquals(null, order.Address_Bill_To__c);
		}

		// when (the contact sold-to address is changed for that order)

		for (Rh_Order__c order : processedOrders) {
			order.SOLD_TO_ADDRESS_1__C = '112 Somerset Drive';
		}
		database.update(processedOrders);

		// then (the order should have no link to the contact-address for sold to)

		for (Rh_Order__c order : [SELECT ID, Contact_Sold_To__c, Address_Sold_To__c, Address_Bill_To__c FROM Rh_Order__c]) {
			system.assertEquals(null, order.Address_Sold_To__c);
			system.assertNotEquals(null, order.Address_Bill_To__c);
		}

		// when (the contact bill-to address is changed for that order)

		for (Rh_Order__c order : processedOrders) {
			order.BILL_TO_ADDRESS_1__C = '112 Somerset Drive';
		}
		database.update(processedOrders);

		// then (the order should have no link to the contact-address for bill to)

		for (Rh_Order__c order : [SELECT ID, Contact_Sold_To__c, Address_Sold_To__c, Address_Bill_To__c FROM Rh_Order__c]) {
			system.assertNotEquals(null, order.Address_Sold_To__c);
			system.assertEquals(null, order.Address_Bill_To__c);
		}
	}


    public static testMethod void testLinkMemberships() {
    	
		PrepareData.populateCustomSettings();
		
		// GIVEN - MDM feature flags on
		     	
		Feature_Flags__c featureFlags = new Feature_Flags__c(
			MDM_Address_Feature__c = true,
			MDM_Merge_feature__c = true
		);
		insert featureFlags;    	

  		// GIVEN

  		setup();

    	// GIVEN - an ssv user

		User su = TestDataFactory.createUser();
        su.Single_View_of_Customer_Process_User__c = true;

		// GIVEN (account)

    	Account testAccount = new Account(Name = 'test company name', X12_Digit_Member__c = '123456789123');
    	database.insert(testAccount);

    	// GIVEN (contact created)

    	Contact testContact = new Contact(AccountId = testAccount.Id, FirstName = 'paul', LastName = 'hemmings');
    	database.insert(testContact);

    	// GIVEN - a membership record

		Membership__c testMembership = new Membership__c(
     		Member_Email__c = 'paul@testemail.com.net',
     		Once_was_Quebecois__c = false,
	 		Enrollment_Date_Time__c = Date.today().addDays(-1),
     		Member_State__c = 'QC',
     		Member_Country__c = 'CA',
     		Expiration_Date_Time__c = System.Today().AddDays(1)
     	);
     	database.insert(testMembership);

    	// GIVEN - a new order with a link to that membership record

    	RH_Order__C testOrder = new Rh_Order__c(
			Sold_to_Customer_Number__c = 'test-customer',
      		Sold_to_First_Name__c = 'paul',
      		Sold_to_Last_Name__c = 'hemmings-03',
			Sold_to_Company__c = NULL,
    		fraud_warning__c = true,
    		Membership_ID__c = [SELECT Name FROM Membership__c].Name,
    		Contact_Sold_To__c = testContact.Id
    	);
    	database.insert(testOrder);

  		// WHEN - link membership run

  		List<SObject> recordsToUpdate = new List<SObject>();
  		Map<Id, RH_Order__c> oldMap = null;
  		OrderService.linkMembership(recordsToUpdate, new List<RH_Order__c>{testOrder}, oldMap);

		// WHEN - update database with changes

  		database.update(Utility.compileUpdates(recordsToUpdate));

  		// THEN - records to update should include order, membership record, but not Contact

  		system.assertEquals(testOrder.id, [SELECT Created_By_Order_ID__c FROM Membership__c WHERE ID = :testMembership.Id].Created_By_Order_ID__c);
  		system.assertEquals(testMembership.id, [SELECT Membership_ID_Lookup__c FROM RH_Order__c WHERE ID = :testOrder.Id].Membership_ID_Lookup__c);
  		system.assertEquals(testContact.id, [SELECT Contact__c FROM Membership__c WHERE ID = :testMembership.Id].Contact__c);
  		system.assertEquals(true, [SELECT Has_Membership__c FROM Contact WHERE ID = :testContact.Id].Has_Membership__c);

    }


	public static testMethod void testFraudFlagRemovedWhenOrderUpdated() {
		
		PrepareData.populateCustomSettings();
		
		// GIVEN - MDM feature flags on
		     	
		Feature_Flags__c featureFlags = new Feature_Flags__c(
			MDM_Address_Feature__c = true,
			MDM_Merge_feature__c = true
		);
		insert featureFlags;    			

    	// GIVEN - an ssv user

		User su = TestDataFactory.createUser();
        su.Single_View_of_Customer_Process_User__c = true;

    	// GIVEN - a new order

    	RH_Order__C testOrder = new Rh_Order__c(
			Sold_to_Customer_Number__c = 'test-customer',
      		Sold_to_First_Name__c = 'paul',
      		Sold_to_Last_Name__c = 'hemmings-03',
			Sold_to_Company__c = NULL,
    		fraud_warning__c = true
    	);
    	database.insert(testOrder);

        // WHEN - process that order
		Test.startTest();
        SSVSyncService.enqueueBatchSync(false, Datetime.now().addMinutes(1));
        Test.stopTest();

        // THEN	- created source system view has fraud warning

    	Source_System_View__c ssv = [SELECT ID, Account__c, fraud_warning__c FROM Source_System_View__c where EXT_Source_System_Customer_ID__c = :testOrder.Sold_to_Customer_Number__c];
    	system.assertEquals(true, ssv.fraud_warning__c);

    	// THEN	- created account has fraud warning

    	Account createdAccount = [SELECT ID, fraud_warning__c FROM Account WHERE ID = :ssv.Account__c];
    	system.assertEquals(true, createdAccount.fraud_warning__c);

        // WHEN - order updated (as SSV so trigger runs synchronously)

        testOrder.fraud_warning__c = false;
        System.runAs(su) {
        	database.update(testOrder);
        }

        // THEN - created account has no fraud warning
    	createdAccount = [SELECT ID, fraud_warning__c FROM Account WHERE ID = :ssv.Account__c];
    	//system.assertEquals(false, createdAccount.fraud_warning__c);
    }

    public static testMethod void testGatherPersonsNeedingFraudWarningWithNewOrder() {
    	
		PrepareData.populateCustomSettings();
		
		// GIVEN - MDM feature flags on
		     	
		Feature_Flags__c featureFlags = new Feature_Flags__c(
			MDM_Address_Feature__c = true,
			MDM_Merge_feature__c = true
		);
		insert featureFlags;    	
    	

    	// GIVEN - an ssv user

		User u = TestDataFactory.createUser();
        u.Single_View_of_Customer_Process_User__c = false;

    	// GIVEN - a new order

    	RH_Order__C testOrder = new Rh_Order__c(
			Sold_to_Customer_Number__c = 'test-customer',
      		Sold_to_First_Name__c = 'paul',
      		Sold_to_Last_Name__c = 'hemmings-01',
			Sold_to_Company__c = NULL,
    		fraud_warning__c = false
    	);
    	database.insert(testOrder);

        // WHEN - process that order
        Test.startTest();
        SSVSyncService.enqueueBatchSync(false, Datetime.now().addMinutes(1));
        Test.stopTest();

        // THEN	- created source system view has no fraud warning

    	Source_System_View__c ssv = [SELECT ID, Account__c, fraud_warning__c FROM Source_System_View__c where EXT_Source_System_Customer_ID__c = :testOrder.Sold_to_Customer_Number__c];
    	system.assertEquals(false, ssv.fraud_warning__c);

    	// THEN	- created account has no fraud warning

    	Account createdAccount = [SELECT ID, fraud_warning__c FROM Account WHERE ID = :ssv.Account__c];
    	system.assertEquals(false, createdAccount.fraud_warning__c);

    	// GIVEN - a second order to the same customer number

    	RH_Order__c testFraudulantOrder = new Rh_Order__c(
			Sold_to_Customer_Number__c = 'test-customer',
      		Sold_to_First_Name__c = 'paul',
      		Sold_to_Last_Name__c = 'hemmings-02',
			Sold_to_Company__c = NULL,
			Account_Sold_To__c = NULL,
    		fraud_warning__c = false
    	);

    	// WHEN - that order is inserted
		// Insert without SSV so the RH_ORder trigger fires (which associates this order with existing account)
    	System.runAs(u) {
    		database.insert(testFraudulantOrder);
    	}

    	// THEN - the before insert trigger will have added the created account to this fraudulant order

    	RH_Order__c storedOrder = [SELECT Id, Account_Sold_To__c, fraud_warning__c FROM RH_Order__c WHERE ID = :testFraudulantOrder.Id];
    	system.assertEquals(storedOrder.Id, testFraudulantOrder.Id);
    	system.assertEquals(storedOrder.fraud_warning__c, false);
    	system.assertEquals(storedOrder.Account_Sold_To__c, ssv.Account__c);

    	// WHEN - update the stored order (as SSV user so the update is run immediately and not in a @future)

		User su = TestDataFactory.createUser();
        su.Single_View_of_Customer_Process_User__c = true;

    	storedOrder.fraud_warning__c = true;
    	System.runAs(su) {
    		database.update(storedOrder);
    	}

    	// THEN	- created account now has fraud warning

    	Account updatedAccount = [SELECT ID, fraud_warning__c FROM Account WHERE ID = :ssv.Account__c];
    	//system.assertEquals(true, updatedAccount.fraud_warning__c);
    }

    public static testMethod void testGatherPersonsNeedingFraudWarningWithExistingAccount() {

    	PrepareData.populateCustomSettings();
    	
    	// GIVEN - the person account record type

    	RecordType personAccountRecType = [
			SELECT Id
			FROM RecordType
			WHERE DeveloperName = 'RH_End_Customer'
			AND SObjectType = 'Account'
		];

		User u = TestDataFactory.createUser();
        u.Single_View_of_Customer_Process_User__c = true;

    	// GIVEN - test account with no fraud warning

    	Account personAccount = new Account(
			RecordTypeId = personAccountRecType.Id,
			Type = 'Consumer',
    		FirstName = 'paul',
    		LastName = 'hemmings',
    		Phone = '6501231234',
    		fraud_warning__c = false
    	);
    	database.insert(personAccount);
		// WHEN - add an order for that account with a fraud warning

    	RH_Order__C testOrder = new Rh_Order__c(
    		fraud_warning__c = true,
    		Account_Sold_To__c = personAccount.Id
    	);

    	// WHEN - insert that order (and so kick off the trigger)

    	Test.startTest();
    	System.runAs(u) {
    		database.insert(testOrder);
    	}
    	Test.stopTest();

    	// THEN - account now has fraud warning

    	Account updatedAccount = [SELECT ID, fraud_warning__c FROM ACCOUNT where ID = :personAccount.Id];
    }

    @isTest
    public static void testProcessDAOrders() {


    	// Create Test User with Gallery populated
    	Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

	 	User testUser = new User(Alias = 'testUser',Country='United States',
      		Email='testuser@randomdemodomain.com',EmailEncodingKey='UTF-8',
      	  	LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
      	  	ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testUser@randomdemodomain.com', Gallery__c = 'Gallery 006 - Corte Madera');
        insert testUser;

    	System.runAs(testUser){

        	// Populate Custom Settings

	    	PrepareData.populateCustomSettings();

	    	// Create test Account and insert
	    	Account testDAAccount = new Account();
		 	testDAAccount = PrepareData.createAccount();
		 	insert testDAAccount;

		 	// Create test Contact and insert
		 	Contact testDAContact = new Contact();
		 	testDAContact = PrepareData.createContact(testDAAccount.Id);
		 	insert testDAContact;

		 	// Create two test Design Atelier Opportunities and insert
		 	Opportunity testDAOppty = new Opportunity();
		 	Opportunity testDAOppty2 = new Opportunity();

		 	testDAOppty = PrepareData.createOpportunity(testDAAccount.Id);

			RecordType daOpptyRecType = [
				SELECT Id
				FROM RecordType
				WHERE DeveloperName = 'Design_Atelier'
				AND SobjectType = 'Opportunity'];
			testDAOppty.RecordTypeId = daOpptyRecType.Id;
			testDAOppty.Name = 'Test DA Opportunity';
			testDAOppty.StageName = 'Engage &amp; Discover';
			testDAOppty.Gallery__c = 'Gallery 006 - Corte Madera';

			insert testDAOppty;

			testDAOppty2 = PrepareData.createOpportunity(testDAAccount.Id);
			testDAOppty2.RecordTypeId = daOpptyRecType.Id;
			testDAOppty2.Name = 'Test DA Opportunity';
			testDAOppty2.StageName = 'Engage &amp; Discover';
			testDAOppty2.Gallery__c = 'Gallery 006 - Corte Madera';

			insert testDAOppty2;


	  		// Create two test DA Quotes associated with test DA Opptys and insert
	  		Design_Atelier_Quote__c testDAQuote = new Design_Atelier_Quote__c();
		 	testDAQuote = PrepareData.createDAQuote(testDAOppty, '12345');

		 	insert testDAQuote;

		 	Design_Atelier_Quote__c testDAQuote2 = new Design_Atelier_Quote__c();
		 	testDAQuote2 = PrepareData.createDAQuote(testDAOppty, '54321');

		 	insert testDAQuote2;

	    	// Create two test Orders that associated with the test DA Quotes and insert to fire trigger
	    	RH_Order__c testDAOrder = new RH_Order__c();
	    	testDAOrder = PrepareData.createOrder('666666');
	    	testDAOrder.Opportunity__c = testDAOppty.Id;
	    	testDAOrder.Quote_Id__c = testDAQuote.Quote_Id__c;
	    	insert testDAOrder;

	    	RH_Order__c testDAOrder2 = new RH_Order__c();
	    	testDAOrder2 = PrepareData.createOrder('777777');
	    	testDAOrder2.Opportunity__c = testDAOppty2.Id;
	    	testDAOrder2.Quote_Id__c = testDAQuote2.Quote_Id__c;
	    	insert testDAOrder2;

	    	// Update the Order to fire trigger again (force update using Order Update flag)
	    	testDAOrder2.DA_Order_Update__c = true;
	    	testDAOrder.DA_Order_Update__c = true;

	    	update testDAOrder;
	    	update testDAOrder2;

	    	// Update the Order to fire trigger again (change associated Oppty)
	    	testDAOrder.Opportunity__c= testDAOppty2.Id;
	    	testDAOrder2.Opportunity__c = testDAOppty.Id;

	    	update testDAOrder;
	    	update testDAOrder2;

	    	// Update the Order to fire trigger again (change associated Quote)
	    	testDAOrder.Quote_Id__c = testDAQuote2.Quote_Id__c;
	    	testDAOrder2.Quote_Id__c = testDAQuote.Quote_Id__c;

	    	update testDAOrder;
	    	update testDAOrder2;
    	}
    }
    
	private static void setup() {

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
		*/
	}
	    
}