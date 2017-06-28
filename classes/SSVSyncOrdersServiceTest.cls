@isTest
private class SSVSyncOrdersServiceTest {

    @isTest static void testLinkSingleOrder() {

		Source_System_View__c testSSV1 = TestDataFactory.createSSV(1, false)[0];
		testSSV1.Source_Table__c = 'Salesforce Account';
		insert testSSV1;

		// query created record
		List<Source_System_View__c> records = SSVSelector.getSSVsById(new Set<Id>{testSSV1.Id});

		// link record
		SSVSyncOrdersService testSyncService = new SSVSyncOrdersService(new SSVBatchSelectorBuilder());
		
		Test.startTest();
		
		testSyncService.linkOrders(records);

        Test.stopTest();
        
        // query (hopefully) updated record
        List<Source_System_View__c> updatedRecords = SSVSelector.getSSVsById(new Set<Id>{testSSV1.Id});
        
        system.assertEquals(SSVSelector.PROCESSING_STATUS_COMPLETE, updatedRecords[0].Processing_Status__c);
    }
}