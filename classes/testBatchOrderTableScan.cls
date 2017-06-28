@isTest
private class testBatchOrderTableScan {
	
	/*
	 *	Test methods for BatchOrderTableScan.cls.
	 *
	 */
	
	// Create test data
	@testSetup static void botsTestData() {
		
		Id orderShellRTID = '012500000009tf5AAA';
		Id orderNonShellRTID = '012500000009tf4AAA';
		PrepareData.populateCustomSettings();
		
		PrepareData.productClass p1 = PrepareData.createProduct('63420784BRN', 100, '63420784BRN', 100);
		PrepareData.productClass p2 = PrepareData.createProduct('17050042WHT', 100, '17050042WHT', 100);
		//PrepareData.productClass p3 = PrepareData.createProduct('63190021WHT', 100, '63190021WHT', 100);
		//PrepareData.productClass p4 = PrepareData.createProduct('62210002NATL', 100, '62210002NATL', 100);
		
		List<RH_Order__c> orderList = new List<RH_Order__c>();
		orderList.add(PrepareData.createOrder('botsO1'));
		orderList.add(PrepareData.createOrder('bots02'));
		orderList.add(PrepareData.createOrder('bots03'));
		orderList[0].RecordTypeId = orderNonShellRTID;
		orderList[1].RecordTypeId = orderNonShellRTID;
		orderList[2].RecordTypeId = orderShellRTID;
		insert orderList;
		
		List<Ship_To__c> stList = new List<Ship_To__c>();
		stList.add(PrepareData.createShipTo(orderList[0].Id, '1'));
		stList.add(PrepareData.createShipTo(orderList[1].Id, '1'));
		stList.add(PrepareData.createShipTo(orderList[2].Id, '1'));
		insert stList;
		
		List<Order_Line_Items__c> oliList = new List<Order_Line_Items__c>();
		oliList.add(PrepareData.createOrderLine(orderList[0].Id, stList[0].Id, '1', p1.p.Id));
		oliList.add(PrepareData.createOrderLine(orderList[0].Id, stList[0].Id, '2', p2.p.Id));
		insert oliList;
	}
	
	static testMethod void botsTest1() {
		
		Test.startTest();
		
		BatchOrderTableScan batch = new BatchOrderTableScan(); 
		Database.executeBatch(batch, 2000);
		
		Test.stopTest();
		
		List<Log__c> resultLogList = new List<Log__c>();
		resultLogList = [select Id, Log_Message__c, Script_Event__c from Log__c];
		
		system.assertEquals(1, resultLogList.size());
		system.assert(resultLogList[0].Script_Event__c.contains('BatchOrderTableScan: found 1 non-shell orders without order lines'));
		system.assert(resultLogList[0].Log_Message__c.contains('bots02'));
	}
}