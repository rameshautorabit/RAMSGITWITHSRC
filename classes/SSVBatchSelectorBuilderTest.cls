@isTest
private class SSVBatchSelectorBuilderTest {
    
	@isTest static void testDefaultQueryIsBuilt() {
		SSVBatchSelectorBuilder builder = new SSVBatchSelectorBuilder().withProcessingReadyTime(null);
		String baseQuery = builder.buildQuery();
		system.assertEquals('SELECT', baseQuery.substring(0,6));
		system.assertEquals(false, baseQuery.contains('AND Duplicate_Set_ID__c != NULL'));
		system.assertEquals(false, baseQuery.contains('AND Duplicate_Set_ID__c = NULL'));		
	}
	
	@isTest static void testDuplicatesOnlyOrderServiceQueryBuilt() {
		SSVBatchSelectorBuilder builder = new SSVBatchSelectorBuilder()
											.withBatchLimit(100)
											.withProcessingReadyTime(Datetime.now())
											.withProcessStatus('SomeRandomStatus')
											.withIncludingDuplicates(true)
											.withCustomFilter(' AND filter=true')
											.withOrderByMasterRecordScoreOn(true);			

		String query = builder.buildQuery();
		system.assertEquals('SELECT', query.substring(0,6));
		system.assertEquals(true, query.contains('AND Duplicate_Set_ID__c != NULL'));
		system.assertEquals(false, query.contains('AND Duplicate_Set_ID__c = NULL'));
		system.assertEquals(true, query.contains(' AND filter=true'));
		system.assertEquals(true, query.contains(' ORDER BY Master_Record_Score__c DESC'));
		system.assertEquals(true, query.contains(' LIMIT 100'));
		system.assertEquals(true, query.contains(' AND Processing_Status__c = \'SomeRandomStatus\' '));
	}

	@isTest static void testNoDuplicatesOrderServiceQueryBuilt() {
		SSVBatchSelectorBuilder builder = new SSVBatchSelectorBuilder()
											.withBatchLimit(100)
											.withProcessingReadyTime(Datetime.now())
											.withProcessStatus('SomeRandomStatus')
											.withIncludingDuplicates(false)
											.withCustomFilter(' AND filter=true')
											.withOrderByMasterRecordScoreOn(true);			

		String query = builder.buildQuery();
		system.assertEquals('SELECT', query.substring(0,6));
		system.assertEquals(true, query.contains('AND Duplicate_Set_ID__c = NULL'));
		system.assertEquals(false, query.contains('AND Duplicate_Set_ID__c != NULL'));
		system.assertEquals(true, query.contains(' AND filter=true'));
		system.assertEquals(true, query.contains(' ORDER BY Master_Record_Score__c DESC'));
		system.assertEquals(true, query.contains(' LIMIT 100'));
		system.assertEquals(true, query.contains(' AND Processing_Status__c = \'SomeRandomStatus\' '));
	}
	
	/*
	@isTest static void testNewBuiltQueryMatchesOldQuery() {
		
		// given
		Datetime processingReadyTime = Datetime.now();
		Integer batchLimit = null;
		
		// when
		SSVBatchSelectorBuilder builder = new SSVBatchSelectorBuilder()
											.withBatchLimit(batchLimit)
											.withProcessingReadyTime(processingReadyTime)
											.withProcessStatus(SSVSelector.PROCESSING_STATUS_READY);											
		
		String oldQuery = SSVSelector.getBatchSyncQuery(batchLimit, processingReadyTime);

		// then
		system.assertEquals(true, oldQuery.replace(':PROCESSING_STATUS_READY', '\'Ready for Match Step\'').equals(builder.buildQuery()));
		
	}
	*/
	
}