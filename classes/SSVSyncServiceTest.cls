/**
 *  SSVSyncServiceTest.cls
 *  @description Apex Unit tests for source system view sync scheduler
 *  @author Ernesto Valdes, Traction On Demand
 */
@isTest
private class SSVSyncServiceTest {

    static String TEST_CUSTOMER_NUMBER = 'TESTNUMBER';

    @testSetup static void initExistingData() {
    	
    	PrepareData.populateCustomSettings();
    	
    	TestDataFactory.turnMdmFeatureFlagsOn();    	

        // create a new order
        RH_Order__c testOrder = TestDataFactory.createRhOrder(false);
        testOrder.Sold_To_Customer_Number__c = TEST_CUSTOMER_NUMBER;
        insert testOrder;

        // create ship to record under order
        Ship_To__c shipToSoldTo = TestDataFactory.createShipTo(false);
        shipToSoldTo.Ship_To_Customer_Number__c = '0';
        shipToSoldTo.Order__c = testOrder.Id;

        Ship_To__c shipToOther = TestDataFactory.createShipTo(false);
        shipToOther.Ship_To_Customer_Number__c = TEST_CUSTOMER_NUMBER;
        shipToOther.Order__c = testOrder.Id;

        insert new List<Ship_To__c>{shipToSoldTo, shipToOther};
    }

    @isTest static void testSyncToExistingDuplicateCompany() {

        // create new ssv record
        Source_System_View__c testSSV1 = TestDataFactory.createSSV(1, false)[0];
        testSSV1.Source_Table__c = 'Salesforce Account';
        insert testSSV1;

        // query created record
        List<Source_System_View__c> records = SSVSelector.getSSVsById(new Set<Id>{testSSV1.Id});

        // sync record
        SSVSyncService testSyncService = new SSVSyncService(records);
        testSyncService.sync(testSyncService.records);

        // create duplicate ssv record
        Source_System_View__c testSSV2 = TestDataFactory.createSSV(1, false)[0];
        testSSV2.Source_Table__c = 'Salesforce Account';
        insert testSSV2;

        // set duplicate set id on ssv records
        testSSV1.Duplicate_Set_ID__c = 'TESTDUPLICATESET';
        testSSV2.Duplicate_Set_ID__c = 'TESTDUPLICATESET';
        update new List<Source_System_View__c>{testSSV1,testSSV2};

        // sync duplicate record
        Test.startTest();
        //Reporter.startLogging();
        
        SSVSyncService.enqueueBatchSync(false, Datetime.now().addMinutes(1));

        //Reporter.stopLogging();
        Test.stopTest();

        // verify that records were consolidated and spawned the same account
        testSSV1 = SSVSelector.getSSVsById(new Set<Id>{testSSV1.Id})[0];
        testSSV2 = SSVSelector.getSSVsById(new Set<Id>{testSSV2.Id})[0];
        system.assertNotEquals(null, testSSV1.Account__c);
        system.assertNotEquals(null, testSSV2.Account__c);
        system.assertEquals(testSSV1.Account__c, testSSV2.Account__c);

        // Query created account and verify mappings
        Account testSpawnedAccount = [
            SELECT Id, IsPersonAccount, Duplicate_Set_ID__c
            FROM Account
            WHERE Id = :testSSV1.Account__c
        ];
        system.assertEquals(false, testSpawnedAccount.IsPersonAccount);
        //system.assertEquals('TESTDUPLICATESET', testSpawnedAccount.Duplicate_Set_ID__c);
    }

    @isTest static void testSyncNewDuplicateCompanies() {

        // create new ssv record
        Source_System_View__c testSSV1 = TestDataFactory.createSSV(1, false)[0];
        testSSV1.Source_Table__c = 'Salesforce Account';
        insert testSSV1;

        // create duplicate ssv record
        Source_System_View__c testSSV2 = TestDataFactory.createSSV(1, false)[0];
        testSSV2.Source_Table__c = 'Salesforce Account';
        insert testSSV2;

        // set duplicate set id on ssv records
        testSSV1.Duplicate_Set_ID__c = 'TESTDUPLICATESET';
        testSSV2.Duplicate_Set_ID__c = 'TESTDUPLICATESET';
        update new List<Source_System_View__c>{testSSV1,testSSV2};

        // sync duplicate record
        Test.startTest();
        Reporter.startLogging();
        
        SSVSyncService.enqueueBatchSync(false, Datetime.now().addMinutes(1));

        Reporter.stopLogging();
        Test.stopTest();

        // verify that records were consolidated and spawned the same account
        testSSV1 = SSVSelector.getSSVsById(new Set<Id>{testSSV1.Id})[0];
        testSSV2 = SSVSelector.getSSVsById(new Set<Id>{testSSV2.Id})[0];
        system.assertNotEquals(null, testSSV1.Account__c);
        system.assertNotEquals(null, testSSV2.Account__c);
        system.assertEquals(testSSV1.Account__c, testSSV2.Account__c);

        // Query created account and verify mappings
        Account testSpawnedAccount = [
            SELECT Id, IsPersonAccount, Duplicate_Set_ID__c
            FROM Account
            WHERE Id = :testSSV1.Account__c
        ];
        system.assertEquals(false, testSpawnedAccount.IsPersonAccount);
        system.assertEquals('TESTDUPLICATESET', testSpawnedAccount.Duplicate_Set_ID__c);

    }

    @isTest static void testSyncNewDuplicateContacts() {

        // create new ssv record
        Source_System_View__c testSSV1 = TestDataFactory.createSSV(1, false)[0];
        testSSV1.Source_Table__c = 'CW Customer';
        testSSV1.EXT_Source_System_Customer_ID__c = '1000';
        insert testSSV1;

        // create duplicate ssv record
        Source_System_View__c testSSV2 = TestDataFactory.createSSV(1, false)[0];
        testSSV2.Source_Table__c = 'CW Customer';
        testSSV2.EXT_Source_System_Customer_ID__c = '1001';
        insert testSSV2;

        // set duplicate set id on ssv records
        testSSV1.Duplicate_Set_ID__c = 'TESTDUPLICATESET1';
        testSSV2.Duplicate_Set_ID__c = 'TESTDUPLICATESET1';
        update new List<Source_System_View__c>{testSSV1,testSSV2};

        // query created duplicate record
        List<Source_System_View__c> records = SSVSelector.getSSVsById(new Set<Id>{testSSV1.Id, testSSV2.Id});

        // query parent ssv records
        List<Source_System_View__c> parentRecords = SSVSelector.getSSVsById(
            new Set<Id>{records[0].Source_System_View_CW_Company__c, records[1].Source_System_View_CW_Company__c}
        );

        // set duplicate set id on parent ssv records
        parentRecords[0].Duplicate_Set_ID__c = 'TESTDUPLICATESET2';
        parentRecords[1].Duplicate_Set_ID__c = 'TESTDUPLICATESET2';
        update parentRecords;

        // sync duplicate record
        Test.startTest();
        //Reporter.startLogging();
        
        SSVSyncService.enqueueBatchSync(false, Datetime.now().addMinutes(1));

        //Reporter.stopLogging();
        Test.stopTest();

        // verify that records were consolidated and spawned the same account and contact
        testSSV1 = SSVSelector.getSSVsById(new Set<Id>{testSSV1.Id})[0];
        testSSV2 = SSVSelector.getSSVsById(new Set<Id>{testSSV2.Id})[0];
        system.assertNotEquals(null, testSSV1.Account__c);
        system.assertNotEquals(null, testSSV2.Account__c);
        system.assertNotEquals(null, testSSV1.Contact__c);
        system.assertNotEquals(null, testSSV2.Contact__c);
        system.assertEquals(testSSV1.Account__c, testSSV2.Account__c);
        system.assertEquals(testSSV1.Contact__c, testSSV2.Contact__c);

        // Query created account and verify mappings
        Account testSpawnedAccount = [
            SELECT Id, IsPersonAccount, Duplicate_Set_ID__c
            FROM Account
            WHERE Id = :testSSV1.Account__c
        ];
        system.assertEquals(false, testSpawnedAccount.IsPersonAccount);
        system.assertEquals('TESTDUPLICATESET2', testSpawnedAccount.Duplicate_Set_ID__c);

        verifyContactInformation(testSSV1, 2);
        verifyAddress(testSSV1, 1);
    }

    @isTest static void testSyncToExistingDuplicateContact() {

        // create new ssv record
        Source_System_View__c testSSV1 = TestDataFactory.createSSV(1, false)[0];
        testSSV1.Source_Table__c = 'CW Customer';
        testSSV1.EXT_Source_System_Customer_ID__c = 'testSTEDC1000';
        insert testSSV1;

        // query created record
        List<Source_System_View__c> records1 = SSVSelector.getSSVsById(new Set<Id>{testSSV1.Id});

        // query parent ssv record
        List<Source_System_View__c> parentRecords1 = SSVSelector.getSSVsById(
            new Set<Id>{records1[0].Source_System_View_CW_Company__c}
        );

        // sync record and parent record
        records1.addAll(parentRecords1);
        SSVSyncService testSyncService = new SSVSyncService(records1);
        testSyncService.sync(testSyncService.records);

        // create duplicate ssv record
        Source_System_View__c testSSV2 = TestDataFactory.createSSV(1, false)[0];
        testSSV2.Source_Table__c = 'CW Customer';
        testSSV2.EXT_Source_System_Customer_ID__c = 'testSTEDC1001';
        insert testSSV2;

        // set duplicate set id on ssv records
        testSSV1.Duplicate_Set_ID__c = 'TESTDUPLICATESET1';
        testSSV2.Duplicate_Set_ID__c = 'TESTDUPLICATESET1';
        update new List<Source_System_View__c>{testSSV1,testSSV2};

        // query created duplicate records
        List<Source_System_View__c> records2 = SSVSelector.getSSVsById(new Set<Id>{testSSV1.Id, testSSV2.Id});

        // query created parent ssv records
        List<Source_System_View__c> parentRecords2 = SSVSelector.getSSVsById(
            new Set<Id>{records2[0].Source_System_View_CW_Company__c, records2[1].Source_System_View_CW_Company__c}
        );

        // set duplicate set id on parent ssv records
        parentRecords2[0].Duplicate_Set_ID__c = 'TESTDUPLICATESET2';
        parentRecords2[1].Duplicate_Set_ID__c = 'TESTDUPLICATESET2';
        update parentRecords2;

        // sync duplicate record
        Test.startTest();
        //Reporter.startLogging();
        
        SSVSyncService.enqueueBatchSync(false, Datetime.now().addMinutes(1));

        //Reporter.stopLogging();
        Test.stopTest();

        // verify that records were consolidated and spawned the same account and contact
        testSSV1 = SSVSelector.getSSVsById(new Set<Id>{testSSV1.Id})[0];
        testSSV2 = SSVSelector.getSSVsById(new Set<Id>{testSSV2.Id})[0];
        system.assertNotEquals(null, testSSV1.Account__c);
        system.assertNotEquals(null, testSSV2.Account__c);
        system.assertNotEquals(null, testSSV1.Contact__c);
        system.assertNotEquals(null, testSSV2.Contact__c);
        system.assertEquals(testSSV1.Account__c, testSSV2.Account__c);
        system.assertEquals(testSSV1.Contact__c, testSSV2.Contact__c);

        // Query created account and verify mappings
        Account testSpawnedAccount = [
            SELECT Id, IsPersonAccount, Duplicate_Set_ID__c
            FROM Account
            WHERE Id = :testSSV1.Account__c
        ];
        system.assertEquals(false, testSpawnedAccount.IsPersonAccount);
        //system.assertEquals('TESTDUPLICATESET2', testSpawnedAccount.Duplicate_Set_ID__c);

        verifyContactInformation(testSSV1, 2);
        verifyAddress(testSSV1, 1);
    }

    @isTest static void testSyncToExistingDuplicatePerson() {

        // create new ssv record
        Source_System_View__c testSSV1 = TestDataFactory.createSSV(1, false)[0];
        testSSV1.Company_Name__c = null;
        insert testSSV1;

        // query created record
        List<Source_System_View__c> records = SSVSelector.getSSVsById(new Set<Id>{testSSV1.Id});

        // sync record
        SSVSyncService testSyncService = new SSVSyncService(records);
        testSyncService.sync(testSyncService.records);

        // create duplicate ssv record
        Source_System_View__c testSSV2 = TestDataFactory.createSSV(1, false)[0];
        testSSV2.Company_Name__c = null;
        insert testSSV2;

        // set duplicate set id on ssv records
        testSSV1.Duplicate_Set_ID__c = 'TESTDUPLICATESET';
        testSSV2.Duplicate_Set_ID__c = 'TESTDUPLICATESET';
        update new List<Source_System_View__c>{testSSV1,testSSV2};

        // sync duplicate record
        Test.startTest();
        //Reporter.startLogging();
        
        SSVSyncService.enqueueBatchSync(false, Datetime.now().addMinutes(1));

        //Reporter.stopLogging();
        Test.stopTest();

        // verify that records were consolidated and spawned the same account
        testSSV1 = SSVSelector.getSSVsById(new Set<Id>{testSSV1.Id})[0];
        testSSV2 = SSVSelector.getSSVsById(new Set<Id>{testSSV2.Id})[0];
        system.assertNotEquals(null, testSSV1.Account__c);
        system.assertNotEquals(null, testSSV2.Account__c);
        system.assertEquals(testSSV1.Account__c, testSSV2.Account__c);

        // Query created account and verify mappings
        Account testSpawnedAccount = [
            SELECT Id, IsPersonAccount, Duplicate_Set_ID__c
            FROM Account
            WHERE Id = :testSSV1.Account__c
        ];
        system.assertEquals(true, testSpawnedAccount.IsPersonAccount);
        //system.assertEquals('TESTDUPLICATESET', testSpawnedAccount.Duplicate_Set_ID__c);

        verifyAddress(testSSV1, 1);
    }

    @isTest static void testSyncNewDuplicatePersons() {

        // create new ssv record
        Source_System_View__c testSSV1 = TestDataFactory.createSSV(1, false)[0];
        testSSV1.Company_Name__c = null;
        insert testSSV1;

        // create duplicate ssv record
        Source_System_View__c testSSV2 = TestDataFactory.createSSV(1, false)[0];
        testSSV2.Company_Name__c = null;
        insert testSSV2;

        // set duplicate set id on ssv records
        testSSV1.Duplicate_Set_ID__c = 'TESTDUPLICATESET';
        testSSV2.Duplicate_Set_ID__c = 'TESTDUPLICATESET';
        update new List<Source_System_View__c>{testSSV1,testSSV2};

        // sync duplicate record
        Test.startTest();
        //Reporter.startLogging();
        
        SSVSyncService.enqueueBatchSync(false, Datetime.now().addMinutes(1));

        //Reporter.stopLogging();
        Test.stopTest();

        // verify that records were consolidated and spawned the same account
        testSSV1 = SSVSelector.getSSVsById(new Set<Id>{testSSV1.Id})[0];
        testSSV2 = SSVSelector.getSSVsById(new Set<Id>{testSSV2.Id})[0];
        system.assertNotEquals(null, testSSV1.Account__c);
        system.assertNotEquals(null, testSSV2.Account__c);
        system.assertEquals(testSSV1.Account__c, testSSV2.Account__c);

        // Query created account and verify mappings
        Account testSpawnedAccount = [
            SELECT Id, IsPersonAccount, Duplicate_Set_ID__c
            FROM Account
            WHERE Id = :testSSV1.Account__c
        ];
        system.assertEquals(true, testSpawnedAccount.IsPersonAccount);
        system.assertEquals('TESTDUPLICATESET', testSpawnedAccount.Duplicate_Set_ID__c);

        verifyAddress(testSSV1, 1);
    }

    @isTest static void testSyncUniquePerson() {

        // create new ssv record
        Source_System_View__c testSSV1 = TestDataFactory.createSSV(1, false)[0];
        testSSV1.Company_Name__c = null;
        testSSV1.EXT_Source_System_Customer_ID__c = 'testSUP' + TEST_CUSTOMER_NUMBER + '1';
        insert testSSV1;

        // sync ssv record
        Test.startTest();
        //Reporter.startLogging();
    
		User u = TestDataFactory.createUser();
        u.Single_View_of_Customer_Process_User__c = false;

		TriggerManager__c triggerManager = new TriggerManager__c(SetupOwnerId = u.Id, runTriggers__c=true, runMDMTriggers__c=true);
		insert triggerManager;
		
        System.runAs(u) {      
        	SSVSyncService.enqueueBatchSync(false, Datetime.now().addMinutes(1));
        }
        
        //Reporter.stopLogging();
        Test.stopTest();

        // Get record
        testSSV1 = SSVSelector.getSSVsById(new Set<Id>{testSSV1.Id})[0];

        // Query created account and verify mappings
        Account testSpawnedAccount = [
            SELECT Id, IsPersonAccount, Duplicate_Set_ID__c
            FROM Account
            WHERE Id = :testSSV1.Account__c
        ];
        system.assertEquals(true, testSpawnedAccount.IsPersonAccount);
        system.assertNotEquals(null, testSSV1.Contact__c);
        system.assertNotEquals(null, testSSV1.Account__c);
        //system.assertNotEquals(null, testSSV1.Customer_Address__c);

        verifyContactInformation(testSSV1, 2);
        verifyAddress(testSSV1, 1);
        //verifyOrderLink(testSSV1);
    }

    @isTest static void testSyncUniqueContact() {

        // create new ssv record
        Source_System_View__c testSSV1 = TestDataFactory.createSSV(1, false)[0];
        testSSV1.Source_Table__c = 'CW Customer';
        testSSV1.EXT_Source_System_Customer_ID__c = 'testSUC' + TEST_CUSTOMER_NUMBER + '1';
        insert testSSV1;

        // sync ssv record and parent
        Test.startTest();
        //Reporter.startLogging();

        SSVSyncService.enqueueBatchSync(false, Datetime.now().addMinutes(1));

        //SSVSyncService testSyncService = new SSVSyncService(SSVSelector.getSSVsById(new Set<Id>{testSSV1.Id}));
        //testSyncService.sync(testSyncService.records);
        
        //Reporter.stopLogging();
        Test.stopTest();

        // verify that records spawned an account and contact
        testSSV1 = SSVSelector.getSSVsById(new Set<Id>{testSSV1.Id})[0];
        system.assertNotEquals(null, testSSV1.Contact__c);
        system.assertNotEquals(null, testSSV1.Account__c);
        system.assertNotEquals(null, testSSV1.Customer_Address__c);

        // Query created account and verify mappings
        Account testSpawnedAccount = [
            SELECT Id, IsPersonAccount, Duplicate_Set_ID__c, Phone
            FROM Account
            WHERE Id = :testSSV1.Account__c
        ];
        system.assertEquals(false, testSpawnedAccount.IsPersonAccount);
        system.assertEquals('+1.(555)-555-0001', testSpawnedAccount.Phone);

        verifyContactInformation(testSSV1, 2);
        verifyAddress(testSSV1, 1);
        // verifyOrderLink(testSSV1);

    }

    @isTest static void testSyncUniqueContactZeroPhoneNumber() {

        // create new ssv record
        Source_System_View__c testSSV1 = TestDataFactory.createSSV(1, false)[0];
        testSSV1.Source_Table__c = 'CW Customer';
        testSSV1.Day_Phone__c = '0';
        testSSV1.EXT_Source_System_Customer_ID__c = 'testSUCZPN' + TEST_CUSTOMER_NUMBER + '1';
        insert testSSV1;

        // sync ssv record and parent
        Test.startTest();
        Reporter.startLogging();

        SSVSyncService.enqueueBatchSync(false, Datetime.now().addMinutes(1));

        //SSVSyncService testSyncService = new SSVSyncService(SSVSelector.getSSVsById(new Set<Id>{testSSV1.Id}));
        //testSyncService.sync(testSyncService.records);
        
        Reporter.stopLogging();
        Test.stopTest();

        // verify that records spawned an account and contact
        testSSV1 = SSVSelector.getSSVsById(new Set<Id>{testSSV1.Id})[0];
        system.assertNotEquals(null, testSSV1.Contact__c);
        system.assertNotEquals(null, testSSV1.Account__c);
        system.assertNotEquals(null, testSSV1.Customer_Address__c);

        // Query created account and verify mappings
        Account testSpawnedAccount = [
            SELECT Id, IsPersonAccount, Duplicate_Set_ID__c, Phone
            FROM Account
            WHERE Id = :testSSV1.Account__c
        ];
        system.assertEquals(false, testSpawnedAccount.IsPersonAccount);
        system.assertEquals(null, testSpawnedAccount.Phone);

        verifyContactInformation(testSSV1, 1);
        verifyAddress(testSSV1, 1);
        // verifyOrderLink(testSSV1);

    }

    @isTest static void testSyncUniqueContactNoName() {

        // create new ssv record
        Source_System_View__c testSSV1 = TestDataFactory.createSSV(1, false)[0];
        testSSV1.Last_Name__c = null;
        testSSV1.First_Name__c = null;
        testSSV1.Source_Table__c = 'CW Customer';
        testSSV1.EXT_Source_System_Customer_ID__c = 'testSUCNN' + TEST_CUSTOMER_NUMBER + '1';
        insert testSSV1;
    
        // sync ssv record and parent
        Test.startTest();
        //Reporter.startLogging();

        SSVSyncService.enqueueBatchSync(false, Datetime.now().addMinutes(1));
        
        //Reporter.stopLogging();
        Test.stopTest();

        // verify that records spawned an account but no contact (due to missing last name)
        testSSV1 = SSVSelector.getSSVsById(new Set<Id>{testSSV1.Id})[0];
        system.assertEquals('Contact', testSSV1.Match_Type__c);
        system.assertEquals(null, testSSV1.Contact__c);
        system.assertEquals(null, testSSV1.Customer_Address__c);
        system.assertNotEquals(null, testSSV1.Account__c);

        // Query created account and verify mappings
        Account testSpawnedAccount = [
            SELECT Id, IsPersonAccount, Duplicate_Set_ID__c
            FROM Account
            WHERE Id = :testSSV1.Account__c
        ];
        system.assertEquals(false, testSpawnedAccount.IsPersonAccount);

        // verifyOrderLink(testSSV1);

    }
    
    private static void verifyAddress(Source_System_View__c ssv, Integer verifyCount) {

        // Verify address information was created
        List<Customer_Address__c> testCustomerAddresses = [
            SELECT Id, Address__c
            FROM Customer_Address__c
            WHERE Contact__c = :ssv.Contact__c
        ];
        system.assertNotEquals(true, testCustomerAddresses.isEmpty(), 'No customer address was created.');
        system.assertEquals(verifyCount, testCustomerAddresses.size());

        // Verify address was created
        List<Address__c> testAddress = [
            SELECT Id
            FROM Address__c
            WHERE Id = :testCustomerAddresses[0].Address__c
        ];
        system.assertNotEquals(true, testAddress.isEmpty(), 'No address was created.');
        system.assertEquals(verifyCount, testAddress.size());
    }

    private static void verifyContactInformation(Source_System_View__c ssv, Integer verifyCount) {

        // Verify contact information was created
        List<Contact_Information__c> testContactInfos = [
            SELECT Id, Is_Primary__c
            FROM Contact_Information__c
            WHERE Contact__c = :ssv.Contact__c
        ];

        system.assertNotEquals(true, testContactInfos.isEmpty(), 'No contact information was created.');
        system.assertEquals(verifyCount, testContactInfos.size());
/*
        for (Contact_Information__c ci : testContactInfos) {
            system.assertEquals(true, ci.Is_Primary__c);
        }
*/     
    }

    private static void verifyOrderLink(Source_System_View__c ssv) {

        RH_Order__c testOrder = [
            SELECT Source_System_View_Sold_To__c, Account_Sold_To__c, Contact_Sold_To__c
            FROM RH_Order__c
            WHERE Source_System_View_Sold_To__c = :ssv.Id
        ];
        system.assertEquals(ssv.Contact__c, testOrder.Contact_Sold_To__c);
        system.assertEquals(ssv.Account__c, testOrder.Account_Sold_To__c);

        List<Ship_To__c> testShipTo = [
            SELECT CW_Customer_Ship_To__c, Account_Ship_To__c, Contact_Ship_To__c
            FROM Ship_To__c
            WHERE CW_Customer_Ship_To__c = :ssv.Id
        ];
        system.assertNotEquals(true, testShipTo.isEmpty());
        for (Ship_To__c st : testShipTo) {
            system.assertEquals(ssv.Contact__c, st.Contact_Ship_To__c);
            system.assertEquals(ssv.Account__c, st.Account_Ship_To__c);
        }
    }
}