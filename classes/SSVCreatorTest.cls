/**
 *  SSVCreatorTest.cls
 *  @description Apex Unit tests for data spawn
 *  @author Ernesto Valdes, Traction On Demand
 */
@isTest
private class SSVCreatorTest {
	
    @testSetup
    static void setup() {
    	TestDataFactory.turnMdmFeatureFlagsOn();
    }	

	/**
	 *  @description Tests data creation for a single unique company account
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2016-02-10
	 */
	@isTest static void testCreateUniqueCompany() {

		// Given
		// Create a unique source system view record for a company
		List<Source_System_View__c> testSSVList = TestDataFactory.createSSV(1, false);
		testSSVList[0].Source_Table__c = 'Salesforce Account';
		insert testSSVList;

		// Query the created object and all necessary fields using field selector
		testSSVList = SSVSelector.getSSVsById(new Map<Id, Source_System_View__c>(testSSVList).keySet());

		Test.startTest();

		// When
		// Call SSVCreator to spawn data from single given source system view record
		SSVCreator testSSVCreator = new SSVCreator(testSSVList);
		testSSVCreator.syncToCustomers().spawnData();

		Test.stopTest();

		// Then
		// Query source system view record and verify that it was linked to a created account
		Source_System_View__c testSSV = [
			SELECT Account__c, Contact__c
			FROM Source_System_View__c
			WHERE Id = :testSSVList[0].Id
		];
		system.assertNotEquals(null, testSSV.Account__c);
		system.assertEquals(null, testSSV.Contact__c);

		// Query created account and verify mappings
		Account testSpawnedAccount = [
			SELECT Id
			FROM Account
			WHERE Id = :testSSV.Account__c
		];
	}

	/**
	 *  @description Tests data creation for a single unique contact
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2016-02-10
	 */
	@isTest static void testCreateUniqueContactNewCompany() {

		// Given
		// Create a unique source system view record for a contact
		List<Source_System_View__c> testSSVList = TestDataFactory.createSSV(1, false);
		testSSVList[0].Source_Table__c = 'CW Customer';
		insert testSSVList;

		// Query the created object and all necessary fields using field selector
		testSSVList = SSVSelector.getSSVsById(new Map<Id, Source_System_View__c>(testSSVList).keySet());

		// Verify that record was linked to a created parent company record
		system.assertNotEquals(null, testSSVList[0].Source_System_View_CW_Company__c);

		// Verify that parent record is a company record
		List<Source_System_View__c> testParentSSVList = SSVSelector.getSSVsById(new Set<Id>{testSSVList[0].Source_System_View_CW_Company__c});
		system.assertEquals('Company', testParentSSVList[0].Match_Type__c);
		testSSVList.addAll(testParentSSVList);
		
		Test.startTest();
		//Reporter.startLogging();

		// When
		// Call SSVCreator to spawn data from single given source system view record
		SSVCreator testSSVCreator = new SSVCreator(testSSVList);
		testSSVCreator.syncToCustomers().spawnData();
		
		//Reporter.stopLogging();
		Test.stopTest();

		// Then
		// Query source system view record and verify that it was linked to a created account and contact
		Source_System_View__c testSSV = [
			SELECT Account__c, Contact__c, Source_System_View_CW_Company__c, Source_System_View_CW_Company__r.Account__c
			FROM Source_System_View__c
			WHERE Id = :testSSVList[0].Id
		];
		system.assertNotEquals(null, testSSV.Contact__c);
		system.assertNotEquals(null, testSSV.Source_System_View_CW_Company__c);
		system.assertNotEquals(null, testSSV.Account__c);
		system.assertEquals(testSSV.Source_System_View_CW_Company__r.Account__c, testSSV.Account__c);

		// Query created account and verify mappings
		Account testSpawnedAccount = [
			SELECT Id
			FROM Account
			WHERE Id = :testSSV.Account__c
		];

		// Query created contact and verify mappings
		Contact testSpawnedContact = [
			SELECT Id
			FROM Contact
			WHERE Id = :testSSV.Contact__c
		];
		
		// Verify contact information was created
		List<Contact_Information__c> testContactInfos = [
			SELECT Id
			FROM Contact_Information__c
			WHERE Contact__c = :testSpawnedContact.Id
		];
		system.assertNotEquals(true, testContactInfos.isEmpty(), 'No contact information was created.');
		system.assertEquals(2, testContactInfos.size());

		// Verify address information was created
		List<Customer_Address__c> testCustomerAddresses = [
			SELECT Id, Address__c
			FROM Customer_Address__c
			WHERE Contact__c = :testSpawnedContact.Id
		];
		system.assertNotEquals(true, testCustomerAddresses.isEmpty(), 'No customer address was created.');
		system.assertEquals(1, testCustomerAddresses.size());

		// Verify address was created
		List<Address__c> testAddress = [
			SELECT Id
			FROM Address__c
			WHERE Id = :testCustomerAddresses[0].Address__c
		];
		system.assertNotEquals(true, testAddress.isEmpty(), 'No address was created.');
		system.assertEquals(1, testAddress.size());
	}

	/**
	 *  @description Tests data creation for a single unique contact
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2016-02-10
	 */
	@isTest static void testCreateUniqueContactExistingCompany() {

		// Given

		// CREATE EXISTING COMPANY
		// Create a source system view record for an existing company
		List<Source_System_View__c> testSSVList = TestDataFactory.createSSV(1, false);
		testSSVList[0].Source_Table__c = 'Salesforce Account';
		testSSVList[0].Duplicate_Set_ID__c = 'TESTDUPLICATEID';
		insert testSSVList;

		// Query the created object and all necessary fields using field selector
		testSSVList = SSVSelector.getSSVsById(new Map<Id, Source_System_View__c>(testSSVList).keySet());

		// Call SSVCreator to spawn data from single given source system view record
		SSVCreator testSSVCreator = new SSVCreator(testSSVList);
		testSSVCreator.syncToCustomers().spawnData();

		// Query source system view record and verify that it was linked to a created account
		Source_System_View__c testExistingSSV = [
			SELECT Account__c, Contact__c
			FROM Source_System_View__c
			WHERE Id = :testSSVList[0].Id
		];
		system.assertNotEquals(null, testExistingSSV.Account__c);
		system.assertEquals(null, testExistingSSV.Contact__c);
		Id existingAccountId = testExistingSSV.Account__c;

		// CREATE NEW CONTACT FOR EXISTING COMPANY
		// Create a unique source system view record for a contact
		testSSVList = TestDataFactory.createSSV(1, false);
		testSSVList[0].Source_Table__c = 'CW Customer';
		insert testSSVList;

		// Query the created object and all necessary fields using field selector
		testSSVList = SSVSelector.getSSVsById(new Map<Id, Source_System_View__c>(testSSVList).keySet());

		// Verify that record was linked to a created parent company record
		system.assertNotEquals(null, testSSVList[0].Source_System_View_CW_Company__c);

		// Verify that parent record is a company record
		// set its duplicate id and link to an existing company
		List<Source_System_View__c> testParentSSVList = SSVSelector.getSSVsById(new Set<Id>{testSSVList[0].Source_System_View_CW_Company__c});
		system.assertEquals('Company', testParentSSVList[0].Match_Type__c);
		testParentSSVList[0].Duplicate_Set_ID__c = 'TESTDUPLICATEID';
		testParentSSVList[0].Account__c = existingAccountId;
		update testParentSSVList;

		Test.startTest();

		// When
		// Call SSVCreator to spawn data from single given source system view record
		testSSVCreator = new SSVCreator(testSSVList);
		testSSVCreator.syncToCustomers().spawnData();

		Test.stopTest();

		// Then
		// Query source system view record and verify that it was linked to an existing account and new contact
		Source_System_View__c testSSV = [
			SELECT Account__c, Contact__c, Duplicate_Set_ID__c,
					Source_System_View_CW_Company__c, Source_System_View_CW_Company__r.Account__c
			FROM Source_System_View__c
			WHERE Id = :testSSVList[0].Id
		];
		system.assertNotEquals(null, testSSV.Contact__c);
		system.assertNotEquals(null, testSSV.Source_System_View_CW_Company__c);
		system.assertNotEquals(null, testSSV.Account__c);
		system.assertEquals(testSSV.Source_System_View_CW_Company__r.Account__c, testSSV.Account__c);
		system.assertEquals(existingAccountId, testSSV.Account__c);

		// Query created account and verify mappings
		Account testSpawnedAccount = [
			SELECT Id, Duplicate_Set_ID__c
			FROM Account
			WHERE Id = :testSSV.Account__c
		];
		system.assertEquals('TESTDUPLICATEID', testSpawnedAccount.Duplicate_Set_ID__c);

		// Query created contact and verify mappings
		Contact testSpawnedContact = [
			SELECT Id
			FROM Contact
			WHERE Id = :testSSV.Contact__c
		];
		
		// Verify contact information was created
		List<Contact_Information__c> testContactInfos = [
			SELECT Id
			FROM Contact_Information__c
			WHERE Contact__c = :testSpawnedContact.Id
		];
		system.assertNotEquals(true, testContactInfos.isEmpty(), 'No contact information was created.');
		system.assertEquals(2, testContactInfos.size());

		// Verify address information was created
		List<Customer_Address__c> testCustomerAddresses = [
			SELECT Id, Address__c
			FROM Customer_Address__c
			WHERE Contact__c = :testSpawnedContact.Id
		];
		system.assertNotEquals(true, testCustomerAddresses.isEmpty(), 'No customer address was created.');
		system.assertEquals(1, testCustomerAddresses.size());

		// Verify address was created
		List<Address__c> testAddress = [
			SELECT Id
			FROM Address__c
			WHERE Id = :testCustomerAddresses[0].Address__c
		];
		system.assertNotEquals(true, testAddress.isEmpty(), 'No address was created.');
		system.assertEquals(1, testAddress.size());
		
	}

	/**
	 *  @description Tests data creation for a single unique person account
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2016-02-10
	 */
	@isTest static void testCreateUniquePerson() {

		// Given
		// Create a unique source system view record for a company
		List<Source_System_View__c> testSSVList = TestDataFactory.createSSV(1, false);
		testSSVList[0].Company_Name__c = null;
		testSSVList[0].Address_2__c = null;
		insert testSSVList;

		// Query the created object and all necessary fields using field selector
		testSSVList = SSVSelector.getSSVsById(new Map<Id, Source_System_View__c>(testSSVList).keySet());

		Test.startTest();

		// When
		// Call SSVCreator to spawn data from single given source system view record
		SSVCreator testSSVCreator = new SSVCreator(testSSVList);
		testSSVCreator.syncToCustomers().spawnData();

		Test.stopTest();

		// Then
		// Query source system view record and verify that it was linked to a created account
		Source_System_View__c testSSV = [
			SELECT Account__c, Contact__c
			FROM Source_System_View__c
			WHERE Id = :testSSVList[0].Id
		];
		system.assertNotEquals(null, testSSV.Account__c);
		system.assertNotEquals(null, testSSV.Contact__c);

		// Query created account and verify mappings
		Account testSpawnedAccount = [
			SELECT Id, IsPersonAccount, BillingStreet
			FROM Account
			WHERE Id = :testSSV.Account__c
		];
		system.assertEquals(true, testSpawnedAccount.IsPersonAccount);
		System.debug(LoggingLevel.ERROR, 'BillingStreet: ' + testSpawnedAccount.BillingStreet);

		// Verify address information was created
		List<Customer_Address__c> testCustomerAddresses = [
			SELECT Id, Address__c
			FROM Customer_Address__c
			WHERE Contact__c = :testSSV.Contact__c
		];
		system.assertNotEquals(true, testCustomerAddresses.isEmpty(), 'No customer address was created.');
		system.assertEquals(1, testCustomerAddresses.size());

		// Verify address was created
		List<Address__c> testAddress = [
			SELECT Id
			FROM Address__c
			WHERE Id = :testCustomerAddresses[0].Address__c
		];
		system.assertNotEquals(true, testAddress.isEmpty(), 'No address was created.');
		system.assertEquals(1, testAddress.size());
	}

	/**
	 *  @description Tests data creation for a single duplicate company account
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2016-02-10
	 */
	@isTest static void testCreateDuplicateCompany() {

		// Given
		// Create duplicate source system view records for a company
		Source_System_View__c testSSV1 = TestDataFactory.createSSV(1, false)[0];
		Source_System_View__c testSSV2 = TestDataFactory.createSSV(1, false)[0];
		testSSV1.Source_Table__c = 'Salesforce Account';
		testSSV2.Source_Table__c = 'Salesforce Account';
		testSSV1.Duplicate_Set_ID__c = 'TESTDUPLICATEID';
		testSSV2.Duplicate_Set_ID__c = 'TESTDUPLICATEID';
		List<Source_System_View__c> testSSVList = new List<Source_System_View__c>{testSSV1, testSSV2};
		insert testSSVList;

		// Query the created object and all necessary fields using field selector
		testSSVList = SSVSelector.getSSVsById(new Map<Id, Source_System_View__c>(testSSVList).keySet());

		// Create a consolidated grouping of duplicate records
		List<SSVConsolidated> consolidatedRecords = new List<SSVConsolidated>();
		SSVConsolidated consolidatedRecord = new SSVConsolidated(new SSVCleansed(testSSVList[0]));
		consolidatedRecord.addSSV(new SSVCleansed(testSSVList[1]));
		consolidatedRecords.add(consolidatedRecord);

		Test.startTest();
		
		// When
		// Call SSVCreator to spawn data from single given source system view record
		SSVCreator testSSVCreator = new SSVCreator(consolidatedRecords);
		testSSVCreator.syncToCustomers().spawnData();

		Test.stopTest();

		// Then
		// Query source system view records and verify that they were linked to a created account
		testSSVList = [
			SELECT Account__c, Contact__c
			FROM Source_System_View__c
			WHERE Id IN :testSSVList
		];
		system.assertEquals(2, testSSVList.size());
		system.assertNotEquals(null, testSSVList[0].Account__c);
		system.assertEquals(null, testSSVList[0].Contact__c);
		system.assertNotEquals(null, testSSVList[1].Account__c);
		system.assertEquals(null, testSSVList[1].Contact__c);
		system.assertEquals(testSSVList[0].Account__c, testSSVList[1].Account__c);
		system.assertEquals(testSSVList[0].Contact__c, testSSVList[1].Contact__c);

		// Query created account and verify mappings
		Account testSpawnedAccount = [
			SELECT Id, Duplicate_Set_ID__c
			FROM Account
			WHERE Id = :testSSVList[0].Account__c
		];
		system.assertEquals('TESTDUPLICATEID', testSpawnedAccount.Duplicate_Set_ID__c);
	}

	/**
	 *  @description Tests data creation for a single Duplicate person account
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2016-02-10
	 */
	@isTest static void testCreateDuplicatePerson() {

		// Given
		// Create duplicate source system view records for a person
		Source_System_View__c testSSV1 = TestDataFactory.createSSV(1, false)[0];
		Source_System_View__c testSSV2 = TestDataFactory.createSSV(1, false)[0];
		testSSV1.Duplicate_Set_ID__c = 'TESTDUPLICATEID';
		testSSV2.Duplicate_Set_ID__c = 'TESTDUPLICATEID';
		testSSV1.Company_Name__c = null;
		testSSV2.Company_Name__c = null;
		List<Source_System_View__c> testSSVList = new List<Source_System_View__c>{testSSV1, testSSV2};
		insert testSSVList;

		// Query the created object and all necessary fields using field selector
		testSSVList = SSVSelector.getSSVsById(new Map<Id, Source_System_View__c>(testSSVList).keySet());

		// Create a consolidated grouping of duplicate records
		List<SSVConsolidated> consolidatedRecords = new List<SSVConsolidated>();
		SSVConsolidated consolidatedRecord = new SSVConsolidated(new SSVCleansed(testSSVList[0]));
		consolidatedRecord.addSSV(new SSVCleansed(testSSVList[1]));
		consolidatedRecords.add(consolidatedRecord);

		Test.startTest();
		Reporter.startLogging();
		
		// When
		// Call SSVCreator to spawn data from single given source system view record
		SSVCreator testSSVCreator = new SSVCreator(consolidatedRecords);
		testSSVCreator.syncToCustomers().spawnData();

		Reporter.stopLogging();
		Test.stopTest();

		// Then
		// Query source system view records and verify that they were linked to a created account
		testSSVList = [
			SELECT Account__c, Contact__c
			FROM Source_System_View__c
			WHERE Id IN :testSSVList
		];
		system.assertEquals(2, testSSVList.size());
		system.assertNotEquals(null, testSSVList[0].Account__c);
		system.assertNotEquals(null, testSSVList[0].Contact__c);
		system.assertNotEquals(null, testSSVList[1].Account__c);
		system.assertNotEquals(null, testSSVList[1].Contact__c);
		system.assertEquals(testSSVList[0].Account__c, testSSVList[1].Account__c);
		system.assertEquals(testSSVList[0].Contact__c, testSSVList[1].Contact__c);

		// Query created account and verify mappings
		Account testSpawnedAccount = [
			SELECT Id, IsPersonAccount, Duplicate_Set_ID__c
			FROM Account
			WHERE Id = :testSSVList[0].Account__c
		];
		system.assertEquals(true, testSpawnedAccount.IsPersonAccount);
		system.assertEquals('TESTDUPLICATEID', testSpawnedAccount.Duplicate_Set_ID__c);

		// Verify address information was created
		List<Customer_Address__c> testCustomerAddresses = [
			SELECT Id, Address__c
			FROM Customer_Address__c
			WHERE Contact__c = :testSSVList[0].Contact__c
		];
		system.assertNotEquals(true, testCustomerAddresses.isEmpty(), 'No customer address was created.');
		system.assertEquals(1, testCustomerAddresses.size());

		// Verify address was created
		List<Address__c> testAddress = [
			SELECT Id
			FROM Address__c
			WHERE Id = :testCustomerAddresses[0].Address__c
		];
		system.assertNotEquals(true, testAddress.isEmpty(), 'No address was created.');
		system.assertEquals(1, testAddress.size());
	}
}