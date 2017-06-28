/**
 *  SSVCLeanerTest.cls
 *  @description Test class for SSVCLeaner utility methods
 *               and functionality
 *  @author Ernesto Valdes, Traction On Demand
 */
@isTest
private class SSVCleanerTest {

    @testSetup
    static void setup() {
    	TestDataFactory.turnMdmFeatureFlagsOn(); 
    }
    
	@isTest static void cleansePhoneTest() {

		system.assertEquals('5555555555', SSVCleaner.cleansePhone(' 555 555 5555'));
		system.assertEquals('5555555555', SSVCleaner.cleansePhone('(555).555.5555 '));
		system.assertEquals('5555555555', SSVCleaner.cleansePhone('1-555-555-5555'));
		system.assertEquals('5555555555', SSVCleaner.cleansePhone('+1 555 555 5555'));
		system.assertEquals('5555555555', SSVCleaner.cleansePhone('+1.555.555.5555'));
		system.assertEquals('5555555555', SSVCleaner.cleansePhone('+1 (555) 555-5555'));
	}

	@isTest static void cleanseEmailTest() {

		system.assertEquals('TEST@DOMAIN.COM', SSVCleaner.cleanseEmail('test@domain.com'));
		system.assertEquals('TEST+EMAIL@DOMAIN.COM', SSVCleaner.cleanseEmail(' test+email@domain.com'));
		system.assertEquals('TEST+EMAIL@DOMAIN.SUBDOMAIN.COM', SSVCleaner.cleanseEmail('test+email@domain.subdomain.com '));
		system.assertEquals(null, SSVCleaner.cleanseEmail('test@domain'));
		system.assertEquals(null, SSVCleaner.cleanseEmail('domain.com'));
		system.assertEquals(null, SSVCleaner.cleanseEmail('testdomaincom'));

	}

	@isTest static void cleanseNameTest() {

		// First Name
		system.assertEquals('FIRSTNAME', SSVCleaner.cleanseFirstName('firstname'));
		system.assertEquals('FIRSTNAME', SSVCleaner.cleanseFirstName('first name'));
		system.assertEquals('FIRSTNAME', SSVCleaner.cleanseFirstName(' firstname '));
		system.assertEquals('FIRSTNAME', SSVCleaner.cleanseFirstName(' first-name '));

		// Last Name
		system.assertEquals('LASTNAME', SSVCleaner.cleanseLastName('lastname'));
		system.assertEquals('LASTNAME', SSVCleaner.cleanseLastName(' lastname '));
	}

	@isTest static void cleanseAddressTest() {

		system.assertEquals('123TESTSTAPT456ASANFRANCISCOCA12345', 
							SSVCLeaner.cleanseAddress('123 Test St ',
														' Apt 456A',
														' San Francisco',
														' CA ',
														'12345 ',
														'US'));
	}

	@isTest static void prepareMatchFieldsTest() {

		// Given
		SSVCLeaner ssvCleanerTest = new SSVCLeaner(TestDataFactory.createSSV(1, false));

		// When
		ssvCleanerTest.prepareMatchFields();

		// Then
		system.assertEquals('5555550001', ssvCleanerTest.records[0].Day_Phone_Match_Key__c);
		system.assertEquals('TEST1+EMAIL@DOMAIN.TEST.COM', ssvCleanerTest.records[0].Email_Match_Key__c);
		system.assertEquals('TESTFIRST1', ssvCleanerTest.records[0].Cleansed_First_Name__c);
		system.assertEquals('TESTLAST1', ssvCleanerTest.records[0].Cleansed_Last_Name__c);
		system.assertEquals('0001TESTSTAPT456ASANFRANCISCOCA12345', ssvCleanerTest.records[0].Address_Match_Key__c);
	}

	@isTest static void companyNameAliasReplacementTest() {

		// Initialize alias table
		SSVCleaner testCleaner = new SSVCleaner(new List<Source_System_View__c>());
		testCleaner.companyNameAliases = new List<Cleanse_Company_Name__c>{
			new Cleanse_Company_Name__c(Word_Match_String__c = 'COMPANY NAME', 
										Word_Replace_String__c = 'NORMALIZED COMPANY NAME', 
										Match_Type__c = 'A'),
			new Cleanse_Company_Name__c(Word_Match_String__c = 'INC.', 
										Word_Replace_String__c = 'INCORPORATED', 
										Match_Type__c = 'A'),
			new Cleanse_Company_Name__c(Word_Match_String__c = 'COMPANY: ', 
										Word_Replace_String__c = '', 
										Match_Type__c = 'S'),
			new Cleanse_Company_Name__c(Word_Match_String__c = 'LTD.', 
										Word_Replace_String__c = 'LIMITED' , 
										Match_Type__c = 'E')
		};

		// Verify that names are normalized upon cleanse
		system.assertEquals('NORMALIZED COMPANY NAME', testCleaner.normalizeCompanyName('COMPANY NAME'));
		system.assertEquals('COMPANY INCORPORATED SUBSIDIARY INCORPORATED', testCleaner.normalizeCompanyName('COMPANY INC. SUBSIDIARY INC.'));
		system.assertEquals('NAME', testCleaner.normalizeCompanyName('COMPANY: NAME'));
		system.assertEquals('NORMALIZED COMPANY NAME LIMITED', testCleaner.normalizeCompanyName('COMPANY NAME LTD.'));
	}

	@isTest static void firstNameAliasReplacementTest() {

		// Initialize alias table
		SSVCleaner testCleaner = new SSVCleaner(new List<Source_System_View__c>());
		testCleaner.firstNameAliasMap = new Map<String, String>{
			'TEST1' => 'TESTER1'
		};

		// Verify that names are normalized upon cleanse
		system.assertEquals('TESTER1', testCleaner.normalizeFirstName(
											SSVCleaner.cleanseFirstName('test1')));
		system.assertEquals('TESTER1', testCleaner.normalizeFirstName(
											SSVCleaner.cleanseFirstName(' test1 ')));
		system.assertEquals('TESTER1', testCleaner.normalizeFirstName(
											SSVCleaner.cleanseFirstName(' test 1 ')));
		system.assertEquals('TESTER1', testCleaner.normalizeFirstName(
											SSVCleaner.cleanseFirstName(' test-1 ')));
	}

	@isTest static void excludedPhoneMatchTest() {

		// Initialize match table
		SSVCleaner testCleaner = new SSVCleaner(new List<Source_System_View__c>());
		testCleaner.excludedPhoneNumbers = new Set<String>{
			'5555555555',
			'0'
		};

		// Verify that excluded phones are removed by cleaner
		system.assertEquals(null, testCleaner.matchExcludedPhones(
											SSVCleaner.cleansePhone(' 555 555 5555')));
		system.assertEquals(null, testCleaner.matchExcludedPhones(
											SSVCleaner.cleansePhone('(555).555.5555 ')));
		system.assertEquals(null, testCleaner.matchExcludedPhones(
											SSVCleaner.cleansePhone('1-555-555-5555')));
		system.assertEquals(null, testCleaner.matchExcludedPhones(
											SSVCleaner.cleansePhone('+1 555 555 5555')));
		system.assertEquals(null, testCleaner.matchExcludedPhones(
											SSVCleaner.cleansePhone('+1.555.555.5555')));
		system.assertEquals(null, testCleaner.matchExcludedPhones(
											SSVCleaner.cleansePhone('+1 (555) 555-5555')));
		system.assertEquals(null, testCleaner.matchExcludedPhones(
											SSVCleaner.cleansePhone('0')));
	}

	@isTest static void excludedEmailDomainsMatchTest() {

		// Initialize domain match table
		SSVCleaner testCleaner = new SSVCleaner(new List<Source_System_View__c>());
		testCleaner.excludedEmailDomains = new Set<String>{
			'RH.COM'
		};

		system.assertEquals(null, testCleaner.matchExcludedEmailDomains(
													SSVCleaner.cleanseEmail('test@rh.com')));
		system.assertEquals(null, testCleaner.matchExcludedEmailDomains(
													SSVCleaner.cleanseEmail(' test+email@rh.com')));
		system.assertEquals(null, testCleaner.matchExcludedEmailDomains(
													SSVCleaner.cleanseEmail('test+email@rh.com ')));
	}

	@isTest static void excludedCompanyNameMatchTest() {

		// Initialize domain match table
		SSVCleaner testCleaner = new SSVCleaner(new List<Source_System_View__c>());
		testCleaner.excludedCompanyNames = new Set<String>{
			'OR CURRENT RESIDENT',
			'...',
			'N/A',
			'SM:',
			'LANE OFFICE',
			'TEST',
			'NA',
			'SIGNATURE REQUIRED',
			'`',
			'0',
			'ATTN: KELLY'
		};

		system.assertEquals(null, testCleaner.matchExcludedCompanyNames('OR CURRENT RESIDENT'));
		system.assertEquals(null, testCleaner.matchExcludedCompanyNames('...'));
		system.assertEquals(null, testCleaner.matchExcludedCompanyNames('N/A'));
		system.assertEquals(null, testCleaner.matchExcludedCompanyNames('SM:'));
		system.assertEquals(null, testCleaner.matchExcludedCompanyNames('LANE OFFICE'));
		system.assertEquals(null, testCleaner.matchExcludedCompanyNames('TEST'));
		system.assertEquals(null, testCleaner.matchExcludedCompanyNames('N/A'));
		system.assertEquals(null, testCleaner.matchExcludedCompanyNames('SIGNATURE REQUIRED'));
		system.assertEquals(null, testCleaner.matchExcludedCompanyNames('`'));
		system.assertEquals(null, testCleaner.matchExcludedCompanyNames('0'));
		system.assertEquals(null, testCleaner.matchExcludedCompanyNames('ATTN: KELLY'));
	}


	@isTest static void cleanseOnInsertTest() {

		// When
		Test.startTest();

		List<Source_System_View__c> testSSVList = TestDataFactory.createSSV(1, true);

		Test.stopTest();

		// Then
		// Query ssv records and verify cleansed fields
		testSSVList = SSVSelector.getSSVsById(new Map<Id, Source_System_View__c>(testSSVList).keySet());
		system.assertEquals(1, testSSVList.size());
		system.assertEquals('TESTCOMPANY1', testSSVList[0].Cleansed_Company_Name__c);
		system.assertEquals('5555550001', testSSVList[0].Day_Phone_Match_Key__c);
		system.assertEquals('test1+email@domain.test.com', testSSVList[0].Email_Match_Key__c);
		system.assertEquals('TESTFIRST1', testSSVList[0].Cleansed_First_Name__c);
		system.assertEquals('TESTLAST1', testSSVList[0].Cleansed_Last_Name__c);
		system.assertEquals('0001TESTSTAPT456ASANFRANCISCOCA12345', testSSVList[0].Address_Match_Key__c);

		// Verify record is ready for duplicate check and processing
		system.assertEquals(true, testSSVList[0].Is_Ready_For_Duplicate_Check__c);
		system.assertEquals('Ready for Match Step', testSSVList[0].Processing_Status__c);
		system.assertNotEquals(null, testSSVList[0].Processing_Ready_Time__c);
	}

	@isTest static void cleanseOnInsertExclusionTest() {

		// Given
		Cleanse_Match_Exclusion__c testExcludedPhone = new Cleanse_Match_Exclusion__c(
			Exclusion_Type__c = 'Phone',
			Exclusion_Value__c = '0'
			);
		insert new List<Cleanse_Match_Exclusion__c>{testExcludedPhone};

		// When
		Test.startTest();

		List<Source_System_View__c> testSSVList = TestDataFactory.createSSV(1, false);
		testSSVList[0].Day_Phone__c = '0';
		insert testSSVList;

		Test.stopTest();

		// Then
		// Query ssv records and verify cleansed fields
		testSSVList = SSVSelector.getSSVsById(new Map<Id, Source_System_View__c>(testSSVList).keySet());
		system.assertEquals(1, testSSVList.size());
		system.assertEquals('TESTCOMPANY1', testSSVList[0].Cleansed_Company_Name__c);
		system.assertEquals(null, testSSVList[0].Day_Phone_Match_Key__c);
		system.assertEquals('test1+email@domain.test.com', testSSVList[0].Email_Match_Key__c);
		system.assertEquals('TESTFIRST1', testSSVList[0].Cleansed_First_Name__c);
		system.assertEquals('TESTLAST1', testSSVList[0].Cleansed_Last_Name__c);
		system.assertEquals('0001TESTSTAPT456ASANFRANCISCOCA12345', testSSVList[0].Address_Match_Key__c);

		// Verify record is ready for duplicate check and processing
		system.assertEquals(true, testSSVList[0].Is_Ready_For_Duplicate_Check__c);
		system.assertEquals('Ready for Match Step', testSSVList[0].Processing_Status__c);
		system.assertNotEquals(null, testSSVList[0].Processing_Ready_Time__c);
	}

	@isTest static void cleanseOnUpdateTest() {

		// Given
		// SSV record that has already been cleansed and processed
		List<Source_System_View__c> testSSVList = TestDataFactory.createSSV(1, true);
		testSSVList[0].Processing_Status__c = 'Processing Complete';
		testSSVList[0].Is_Ready_For_Duplicate_Check__c = false;
		update testSSVList;

		Test.startTest();

		// When
		// Integration fields are changed
		testSSVList[0].Last_Name__c = 'New Last Name';
		testSSVList[0].Company_Name__c = 'New Company Name';
		update testSSVList;

		Test.stopTest();

		// Then
		// Query ssv records and verify cleansed fields
		testSSVList = SSVSelector.getSSVsById(new Map<Id, Source_System_View__c>(testSSVList).keySet());
		system.assertEquals(1, testSSVList.size());
		system.assertEquals('NEWCOMPANYNAME', testSSVList[0].Cleansed_Company_Name__c);
		system.assertEquals('5555550001', testSSVList[0].Day_Phone_Match_Key__c);
		system.assertEquals('test1+email@domain.test.com', testSSVList[0].Email_Match_Key__c);
		system.assertEquals('TESTFIRST1', testSSVList[0].Cleansed_First_Name__c);
		system.assertEquals('NEWLASTNAME', testSSVList[0].Cleansed_Last_Name__c);
		system.assertEquals('0001TESTSTAPT456ASANFRANCISCOCA12345', testSSVList[0].Address_Match_Key__c);

		// Verify record is ready for duplicate check and processing
		system.assertEquals(true, testSSVList[0].Is_Ready_For_Duplicate_Check__c);
		system.assertEquals('Ready for Match Step', testSSVList[0].Processing_Status__c);
		system.assertNotEquals(null, testSSVList[0].Processing_Ready_Time__c);

	}

	@isTest static void cleanseOnUpdateNegativeTest() {

		// Given
		// SSV record that has already been cleansed and processed
		List<Source_System_View__c> testSSVList = TestDataFactory.createSSV(1, true);
		testSSVList[0].Processing_Status__c = 'Processing Complete';
		testSSVList[0].Is_Ready_For_Duplicate_Check__c = false;
		update testSSVList;

		Test.startTest();

		// When
		// Integration fields are not changed
		testSSVList[0].Alternative_Phone__c = '813 555 5555';
		update testSSVList;

		Test.stopTest();

		// Then
		// Query ssv records and verify it has not been cleansed (since no integration field were changed)
		testSSVList = SSVSelector.getSSVsById(new Map<Id, Source_System_View__c>(testSSVList).keySet());
		system.assertEquals(1, testSSVList.size());
		system.assertEquals(false, testSSVList[0].Is_Ready_For_Duplicate_Check__c);
		system.assertEquals('Processing Complete', testSSVList[0].Processing_Status__c);
	}
}