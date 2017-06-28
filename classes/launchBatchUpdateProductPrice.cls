public with sharing class launchBatchUpdateProductPrice {
	
	public static void launchBatchUpdateProductPrice(Boolean IsTest) {
		
		String queryString;
		
		// Build the query string - dependent on whether this is being run as a test or not
		if (IsTest) {
			queryString = 'SELECT Id, Direct_Original_Price__c, IsActive FROM Product2 WHERE Name LIKE \'BatchUpdateProductPrice%\'';
		} else {
			queryString = 'SELECT Id, Direct_Original_Price__c, IsActive FROM Product2 WHERE LastModifiedDate >= YESTERDAY';
		}
		
		// Launch the batch apex job to update the prices
		BatchUpdateProductPrice bupp = new BatchUpdateProductPrice();
		bupp.buppQueryString = queryString;
		Id batchprocessId = Database.executeBatch(bupp, 2000);
	}
}