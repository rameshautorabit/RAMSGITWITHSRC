/**
 * Test methods for testing BatchUpdateProductPrice
 */
@isTest(SeeAllData=true)
private class testBatchUpdateProductPrice {

    static testMethod void testBUPP1() {
    	
    	// Create test data
    	List<Product2> pList = new List<Product2>();
    	pList.add(new Product2(
    		Name = 'BatchUpdateProductPrice1',
    		Direct_Original_Price__c = 100,
    		IsActive = true)
    	);
    	pList.add(new Product2(
    		Name = 'BatchUpdateProductPrice2',
    		Direct_Original_Price__c = 200,
    		IsActive = true)
    	);
    	pList.add(new Product2(
    		Name = 'BatchUpdateProductPrice3',
    		Direct_Original_Price__c = 300,
    		IsActive = false)
    	);
    	pList.add(new Product2(
    		Name = 'BatchUpdateProductPrice4',
    		Direct_Original_Price__c = 400,
    		IsActive = true)
    	);
    	pList.add(new Product2(
    		Name = 'BatchUpdateProductPrice5',
    		Direct_Original_Price__c = 500,
    		IsActive = false)
    	);
    	insert pList;
    	
    	List<Id> pIds = new List<Id>();
    	for (Product2 p :pList) {
    		pIds.add(p.Id);
    	}
    	
    	List<Pricebook2> pbList = new List<Pricebook2>();
    	pbList = [select Id from Pricebook2 where IsStandard = true];
    	
    	List<PricebookEntry> pbeList = new List<PricebookEntry>();
    	pbeList.add(new PricebookEntry(
			IsActive = true,
			CurrencyIsoCode = 'USD',
			UnitPrice = 1,
			Pricebook2Id = pbList[0].Id,
			Product2Id = pList[0].Id)
		);
		pbeList.add(new PricebookEntry(
			IsActive = false,
			CurrencyIsoCode = 'USD',
			UnitPrice = 2,
			Pricebook2Id = pbList[0].Id,
			Product2Id = pList[1].Id)
		);pbeList.add(new PricebookEntry(
			IsActive = false,
			CurrencyIsoCode = 'USD',
			UnitPrice = 3,
			Pricebook2Id = pbList[0].Id,
			Product2Id = pList[2].Id)
		);
		insert pbeList;
		
		// Launch the test of the batch job leadReassignment
		Test.StartTest();
		launchBatchUpdateProductPrice.launchBatchUpdateProductPrice(true);
		Test.StopTest();
		
		// Verify results
		List<PricebookEntry> pbeVList = new List<PricebookEntry>();
		pbeVList = [select Id, IsActive, UnitPrice from PricebookEntry where Product2Id in :pIds and Pricebook2Id = :pbList[0].Id];
		
		system.assertEquals(5, pbeVList.size());
		system.assertEquals(100, pbeVList[0].UnitPrice);
		system.assertEquals(200, pbeVList[1].UnitPrice);
		system.assertEquals(300, pbeVList[2].UnitPrice);
		system.assertEquals(400, pbeVList[3].UnitPrice);
		system.assertEquals(500, pbeVList[4].UnitPrice);
		system.assertEquals(true, pbeVList[0].IsActive);
		system.assertEquals(false, pbeVList[1].IsActive);
		system.assertEquals(false, pbeVList[2].IsActive);
		system.assertEquals(true, pbeVList[3].IsActive);
		system.assertEquals(false, pbeVList[4].IsActive);
    }
}