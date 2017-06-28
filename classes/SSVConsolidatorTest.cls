/**
 *  SSVConsolidatorTest.cls
 *  @description Apex Unit tests for consolidation match rules
 *  @author Ernesto Valdes, Traction On Demand
 */
@isTest
private class SSVConsolidatorTest {
	
    @testSetup
    static void setup() {
    	TestDataFactory.turnMdmFeatureFlagsOn();
    }	
	
	@isTest static void testConsolidatePersonSimple() {

		// Given
		// Create a test account for the "existing" ssv record
		Account testAccount = TestDataFactory.createAccount(true);

		// Insert a ssv record with a duplicate set
		Source_System_View__c ssv1 = new Source_System_View__c(
			Duplicate_Set_ID__c = 'DUPLICATESET1',
			First_Name__c = 'William',
			Last_Name__c = 'Windsor',
			Email__c = 'wwindsor@monarchy.com',
			Day_Phone__c = '(555) 555-5555',
			Match_Type__c = 'Person',
			Address_1__c = '123 Test St ',
			Address_2__c = ' Apt 456A',
			City__c = 'San Francisco',
			State__c = ' CA ',
			Zip__c = '12345 ',
			Country_Code__c = 'US'
			);
		insert ssv1;

		// Verify that record was cleansed
		ssv1 = [
			SELECT Duplicate_Set_ID__c, Cleansed_First_Name__c, Cleansed_Last_Name__c,
					Email_Match_Key__c, Day_Phone_Match_Key__c, Address_Match_Key__c, Is_Ready_For_Duplicate_Check__c
			FROM Source_System_View__c
			WHERE Id = :ssv1.Id
		];
		System.assertEquals('DUPLICATESET1', ssv1.Duplicate_Set_ID__c);
		System.assertEquals('WILLIAM', ssv1.Cleansed_First_Name__c);
		System.assertEquals('WINDSOR', ssv1.Cleansed_Last_Name__c);
		System.assertEquals('wwindsor@monarchy.com', ssv1.Email_Match_Key__c);
		System.assertEquals('5555555555', ssv1.Day_Phone_Match_Key__c);
		System.assertEquals('123TESTSTAPT456ASANFRANCISCOCA12345', ssv1.Address_Match_Key__c);
		System.assertEquals(true, ssv1.Is_Ready_For_Duplicate_Check__c);

		// Mark record as "processing complete" to signify that this is an existing record
		ssv1.Account__c = testAccount.Id;
		ssv1.Processing_Status__c = SSVSelector.PROCESSING_STATUS_COMPLETE;
		update ssv1;
		
		// When
		// Insert a second ssv record with same duplicate set and matching criteria
		// should match first name, last name, and email
		Source_System_View__c ssv2 = new Source_System_View__c(
			Duplicate_Set_ID__c = 'DUPLICATESET1',
			Cleansed_First_Name__c = 'WILLIAM',
			Cleansed_Last_Name__c = 'WINDSOR',
			Email_Match_Key__c = 'wwindsor@monarchy.com',
			Match_Type__c = 'Person'
			);
		insert ssv2;

		Source_System_View__c ssv3 = new Source_System_View__c(
			Duplicate_Set_ID__c = 'DUPLICATESET1',
			Cleansed_First_Name__c = 'WILLIAM',
			Cleansed_Last_Name__c = 'WINDSOR',
			Address_Match_Key__c = '123TESTSTAPT456ASANFRANCISCOCA12345',
			Match_Type__c = 'Person'
			);
		insert ssv3;

		Reporter.startLogging();										
		List<SSVConsolidated> groups = SSVConsolidator.getConsolidatedGroups(new List<Source_System_View__c>{ssv2, ssv3});											
		Reporter.stopLogging();
		
		// Then
		// Verify that ssv records were grouped into the same consolidation group
		System.assertEquals(1, groups.size());
		System.assertEquals(3, groups[0].getConsolidatedRecords().size());

		for (SSVCleansed ssvc : groups[0].getConsolidatedRecords()) {
			Reporter.log('Record: ' 
						+ ssvc.firstNameMatchKey + ' '
						+ ssvc.lastNameMatchKey + ', '
						+ ssvc.emailMatchKey + ', '
						+ ssvc.phoneMatchKey);
		}
	}

	@isTest static void testConsolidateCompanySimple() {

		// Given
		// Create a test account for the "existing" ssv record
		Account testAccount = TestDataFactory.createAccount(true);

		// Insert a ssv record with a duplicate set
		Source_System_View__c ssv1 = new Source_System_View__c(
			Duplicate_Set_ID__c = 'DUPLICATESET1',
			Company_Name__c = 'Company Name',
			Address_1__c = '1234 Test St',
			State__c = 'CA',
			Zip__c = '12345',
			Country__c = 'United States',
			Match_Type__c = 'Company'
			);
		insert ssv1;

		// Verify that record was cleansed
		ssv1 = [
			SELECT Duplicate_Set_ID__c, Cleansed_Company_Name__c, Address_Match_Key__c, Is_Ready_For_Duplicate_Check__c
			FROM Source_System_View__c
			WHERE Id = :ssv1.Id
		];
		System.assertEquals('DUPLICATESET1', ssv1.Duplicate_Set_ID__c);
		System.assertEquals('COMPANYNAME', ssv1.Cleansed_Company_Name__c);
		System.assertEquals('1234TESTSTCA12345', ssv1.Address_Match_Key__c);
		System.assertEquals(true, ssv1.Is_Ready_For_Duplicate_Check__c);

		// Mark record as "processing complete" to signify that this is an existing record
		ssv1.Account__c = testAccount.Id;
		ssv1.Processing_Status__c = SSVSelector.PROCESSING_STATUS_COMPLETE;
		update ssv1;

		// When
		// Insert a second ssv record with same duplicate set and matching criteria
		// should match first name, last name, and email
		Source_System_View__c ssv2 = new Source_System_View__c(
			Duplicate_Set_ID__c = 'DUPLICATESET1',
			Cleansed_Company_Name__c = 'COMPANY NAME',
			Address_Match_Key__c = '1234TESTSTCA12345UNITEDSTATES',
			Match_Type__c = 'Company'
			);
		insert ssv2;
										
		List<SSVConsolidated> groups = SSVConsolidator.getConsolidatedGroups(new List<Source_System_View__c>{ssv2});

		// Then
		// Verify that ssv records were grouped into the same consolidation group
		System.assertEquals(1, groups.size());
		System.assertEquals(2, groups[0].getConsolidatedRecords().size());

		for (SSVCleansed ssvc : groups[0].getConsolidatedRecords()) {
			Reporter.log('Record: ' 
						+ ssvc.companyNameMatchKey + ' '
						+ ssvc.addressMatchKey);
		}
	}

	@isTest static void testConsolidateContactSimple() {

		// Given
		// Create a test account for the "existing" ssv record
		Account testAccount = TestDataFactory.createAccount(true);

		// Insert a ssv record with a duplicate set
		Source_System_View__c ssv1 = new Source_System_View__c(
			Duplicate_Set_ID__c = 'DUPLICATESET1',
			Company_Name__c = 'Company Name',
			First_Name__c = 'William',
			Last_Name__c = 'Windsor',
			Email__c = 'wwindsor@monarchy.com',
			Day_Phone__c = '(555) 555-5555',
			Address_1__c = '1234 Test St',
			State__c = 'CA',
			Zip__c = '12345',
			Country__c = 'United States',
			Match_Type__c = 'Contact'
			);
		insert ssv1;

		// Verify that record was cleansed
		ssv1 = [
			SELECT Duplicate_Set_ID__c, Cleansed_Company_Name__c, Cleansed_First_Name__c, Cleansed_Last_Name__c,
					Email_Match_Key__c, Day_Phone_Match_Key__c, Address_Match_Key__c, Is_Ready_For_Duplicate_Check__c
			FROM Source_System_View__c
			WHERE Id = :ssv1.Id
		];
		System.assertEquals('DUPLICATESET1', ssv1.Duplicate_Set_ID__c);
		System.assertEquals('COMPANYNAME', ssv1.Cleansed_Company_Name__c);
		System.assertEquals('WILLIAM', ssv1.Cleansed_First_Name__c);
		System.assertEquals('WINDSOR', ssv1.Cleansed_Last_Name__c);
		System.assertEquals('wwindsor@monarchy.com', ssv1.Email_Match_Key__c);
		System.assertEquals('5555555555', ssv1.Day_Phone_Match_Key__c);
		System.assertEquals('1234TESTSTCA12345', ssv1.Address_Match_Key__c);
		System.assertEquals(true, ssv1.Is_Ready_For_Duplicate_Check__c);

		// Mark record as "processing complete" to signify that this is an existing record
		ssv1.Account__c = testAccount.Id;
		ssv1.Processing_Status__c = SSVSelector.PROCESSING_STATUS_COMPLETE;
		update ssv1;

		// When
		// Insert a second ssv record with same duplicate set and matching criteria
		// should match first name, last name, and email
		Source_System_View__c ssv2 = new Source_System_View__c(
			Duplicate_Set_ID__c = 'DUPLICATESET1',
			Cleansed_Company_Name__c = 'COMPANYNAME',
			Cleansed_First_Name__c = 'WILLIAM',
			Cleansed_Last_Name__c = 'WINDSOR',
			Email_Match_Key__c = 'wwindsor@monarchy.com',
			Address_Match_Key__c = '1234TESTSTCA12345',
			Match_Type__c = 'Contact'
			);
		insert ssv2;

		// Insert a third ssv record with same duplicate set and matching criteria
		// should match first name, last name, and phone
		Source_System_View__c ssv3 = new Source_System_View__c(
			Duplicate_Set_ID__c = 'DUPLICATESET1',
			Cleansed_Company_Name__c = 'COMPANYNAME',
			Cleansed_First_Name__c = 'WILLIAM',
			Cleansed_Last_Name__c = 'WINDSOR',
			Day_Phone_Match_Key__c = '5555555555',
			Address_Match_Key__c = '1234TESTSTCA12345',
			Match_Type__c = 'Contact'
			);
		insert ssv3;

		// Insert a fourth ssv record with same duplicate set and matching criteria
		// should match first name, last name, and address
		Source_System_View__c ssv4 = new Source_System_View__c(
			Duplicate_Set_ID__c = 'DUPLICATESET1',
			Cleansed_Company_Name__c = 'COMPANYNAME',
			Cleansed_First_Name__c = 'WILLIAM',
			Cleansed_Last_Name__c = 'WINDSOR',
			Address_Match_Key__c = '1234TESTSTCA12345',
			Match_Type__c = 'Contact'
			);
		insert ssv4;
		
		List<SSVConsolidated> groups = SSVConsolidator.getConsolidatedGroups(new List<Source_System_View__c>{ssv2, ssv3, ssv4});
		
		// Then
		// Verify that ssv records were grouped into the same consolidation group
		System.debug('test consolidated records generated:: ' + groups);
		System.assertEquals(1, groups.size());
		System.assertEquals(4, groups[0].getConsolidatedRecords().size());

		for (SSVCleansed ssvc : groups[0].getConsolidatedRecords()) {
			Reporter.log('Record: ' 
							+ ssvc.companyNameMatchKey + ' '
							+ ssvc.addressMatchKey);
		}
	}
}