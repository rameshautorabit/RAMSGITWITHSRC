/**
 *  ReporterTest.cls
 *  @description Verifies that APEX error reporting functionality
 *               works as expected
 *  @author Ernesto Valdes, Salesforce + Traction On Demand
 */
@isTest
private class ReporterTest {

	private class TestException extends Exception {}

	@isTest static void testReporting() {

		// Assert default starting state
		system.assertEquals(false, Reporter.logging);
		system.assertEquals(1, Reporter.logCount);

		// Verify start logging
		Reporter.startLogging();
		system.assertEquals(true, Reporter.logging);

		// Verify debug
		Reporter.log('test debug');
		system.assertEquals(2, Reporter.logCount);

		// Verify error message from text
		Reporter.report('test error message');
		system.assertEquals(3, Reporter.logCount);
		system.assertEquals(1, Reporter.logs.size());

		// Verify error message from exception
		Reporter.report(new TestException('test error exception'));
		system.assertEquals(4, Reporter.logCount);
		system.assertEquals(2, Reporter.logs.size());

		// Verify error message from database save result
		List<Account> testSObject = new List<Account>{new Account(FirstName='Test SObject')};
		Reporter.report(Database.insert(testSObject, false));
		system.assertEquals(5, Reporter.logCount);
		system.assertEquals(3, Reporter.logs.size());

		// Verify stop logging
		Reporter.stopLogging();
		system.assertEquals(false, Reporter.logging);

		// Verify logs created
		Reporter.createErrorLogs();
		List<Error_Log__c> testLogs = [SELECT Id FROM Error_Log__c];
		system.assertNotEquals(true, testLogs.isEmpty());
		system.assertEquals(3, testLogs.size());
	}

	@isTest static void testIntegrationReporting() {
		Source_System_View__c ssv = TestDataFactory.createSSV(true);
		SSVCustomer ssvCust = new SSVCustomer(ssv);
		ssvCust.ssvCleansedList.add(new SSVCleansed(ssv));
		List<Account> testSObject = new List<Account>{new Account(FirstName='Test SObject')};

		Reporter.startLogging();
		Reporter.integrationReport(
			new List<SSVCustomer> {ssvCust},
			testSObject,
			Database.insert(testSObject, false)
		);
		Reporter.createErrorLogs();
		List<Error_Log__c> testLogs = [SELECT Id FROM Error_Log__c];
		List<Stewardship_Request__c> reqs = [SELECT Id FROM Stewardship_Request__c];
		system.assert(!testLogs.isEmpty());
		system.assert(!reqs.isEmpty());
	}

	@isTest static void testIntegrationReporting_invalidLists() {
		Source_System_View__c ssv = TestDataFactory.createSSV(true);
		SSVCustomer ssvCust = new SSVCustomer(ssv);
		ssvCust.ssvCleansedList.add(new SSVCleansed(ssv));
		List<Account> testSObject = new List<Account>{
			TestDataFactory.createAccount(false)
		};

		Reporter.startLogging();
		Reporter.integrationReport(
			new List<SSVCustomer> {ssvCust, ssvCust}, // List is of wrong length
 			testSObject,
			Database.insert(testSObject, false)
		);
		Reporter.createErrorLogs();
		List<Error_Log__c> testLogs = [SELECT Message__c FROM Error_Log__c];
		System.assertEquals(0, testLogs.size());
		//System.assertEquals(Reporter.INVALID_CALL_ERROR, testLogs[0].Message__c);
	}

	@isTest static void testIntegrationReporting_invalidLists_2() {
		List<Account> accs = new List<Account>{
			new Account(FirstName='Test SObject')
		};

		Reporter.startLogging();
		List<Database.SaveResult> results = Database.insert(accs, false);
		accs.add(new Account());
		Reporter.integrationReport(
 			accs,
			results // List lengths do not match
		);
		Reporter.createErrorLogs();
		List<Error_Log__c> testLogs = [SELECT Message__c FROM Error_Log__c];
		System.assertEquals(1, testLogs.size());
		System.assertEquals(Reporter.INVALID_CALL_ERROR, testLogs[0].Message__c);
	}

	@isTest static void testReporting_invalidLists() {
		List<Account> accs = new List<Account>{
			new Account(FirstName='Test SObject')
		};

		Reporter.startLogging();
		List<Database.SaveResult> results = Database.insert(accs, false);
		accs.add(new Account());
		Reporter.report(
 			accs,
			results // List lengths do not match
		);
		Reporter.createErrorLogs();
		List<Error_Log__c> testLogs = [SELECT Message__c FROM Error_Log__c];
		System.assertEquals(1, testLogs.size());
		System.assertEquals(Reporter.INVALID_CALL_ERROR, testLogs[0].Message__c);
	}

	@isTest static void testDMLErrorReport_delete() {
		List<Source_System_View__c> ssvs = TestDataFactory.createSSV(1, true);
		Reporter.startLogging();
		Reporter.report(ssvs, Database.delete(ssvs, false));
		Reporter.createErrorLogs();
		List<Error_Log__c> testLogs = [SELECT Message__c FROM Error_Log__c];
		System.assertEquals(0, testLogs.size());
	}

	@isTest static void testDMLErrorReport_ssv() {
		List<Source_System_View__c> ssvs = TestDataFactory.createSSV(1, false);
		ssvs[0].Country__c = 'Entering more than 80 characters to break validation rule. Entering more than 80 characters to break validation rule.';
		Reporter.startLogging();
		Reporter.integrationReport(ssvs, Database.insert(ssvs, false));
		Reporter.createErrorLogs();
		Stewardship_Request__c req = [SELECT Source_System_View__c FROM Stewardship_Request__c];
		System.assertEquals(req.Source_System_View__c, ssvs[0].Id);
	}

	@isTest static void testDMLErrorReport_order() {
		List<RH_Order__c> os = TestDataFactory.createRhOrders(1, false);
		os[0].Sold_To_Country__c = 'Entering more than 80 characters to break validation rule. Entering more than 80 characters to break validation rule.';
		Reporter.startLogging();
		Reporter.integrationReport(os, Database.insert(os, false));
		Reporter.createErrorLogs();
		Stewardship_Request__c req = [SELECT Source_Order__c FROM Stewardship_Request__c];
		System.assertEquals(req.Source_Order__c, os[0].Id);
	}

	@isTest static void testDMLErrorReport_ship_to() {
		List<Ship_To__c> shts = TestDataFactory.createShipTos(1, false);
		shts[0].New_Ship_to_Country__c = 'Entering more than 80 characters to break validation rule. Entering more than 80 characters to break validation rule.';
		Reporter.startLogging();
		Reporter.integrationReport(shts, Database.insert(shts, false));
		Reporter.createErrorLogs();
		Stewardship_Request__c req = [SELECT Source_Ship_To__c FROM Stewardship_Request__c];
		System.assertEquals(req.Source_Ship_To__c, shts[0].Id);
	}
}