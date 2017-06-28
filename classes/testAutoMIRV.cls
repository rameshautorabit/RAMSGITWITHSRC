@isTest
private class testAutoMIRV {
	
	/*
	 *	Test methods for AutoMIRV.cls.
	 *
	 */
	
	// Create Auto MIRV test data
	@testSetup static void amTestData() {
		
		PrepareData.populateCustomSettings();
		
		Account acc = PrepareData.createAccount();
		insert acc;
		
		Contact con = PrepareData.createContact(acc.Id);
		insert con;
		
		Opportunity opp = PrepareData.createOpportunity(acc.Id);
		opp.Ops_Contact__c = UserInfo.getUserId();
		insert opp;
		
		List<RH_Order__c> orderList = new List<RH_Order__c>();
		orderList.add(PrepareData.createOrder('mrOrderW'));
		orderList[0].Order_Type_Code__c = 'W';
		
		orderList.add(PrepareData.createOrder('mrOrderE'));
		orderList[1].Order_Type_Code__c = 'W';
		orderList[1].Sold_to_Email__c = '';
		
		orderList.add(PrepareData.createOrder('mrOrderZ'));
		orderList[2].Order_Type_Code__c = 'Z';
		orderList[2].Opportunity__c = opp.Id;
		insert orderList;
    	
    	List<Ship_To__c> shipToList = new List<Ship_To__c>();
    	for (Integer i=0; i<orderList.size(); i++) {
    		shipToList.add(PrepareData.createShipTo(orderList[i].Id, '1'));
    	}
        insert shipToList;
        
        Product2 product = new Product2(
        	Name = '23580079PN',
        	CW_External_Id__c = '23580079PN',
        	Sku_Status__c = 'A',
        	STSSku__c = '23580080',
        	DMMSSku__c = '23580079PN'
        );
        insert product;
        
        List<Order_Line_Items__c> oliList = new List<Order_Line_Items__c>();
		oliList.add(PrepareData.createOrderLine(orderList[0].Id, shipToList[0].Id, '1', product.Id));
		oliList.add(PrepareData.createOrderLine(orderList[1].Id, shipToList[1].Id, '1', product.Id));
		oliList.add(PrepareData.createOrderLine(orderList[2].Id, shipToList[2].Id, '1', product.Id));
        insert oliList;
	}
	
	// Test a valid auto MIRV message
	static testMethod void amTest1() {
		String amMessage = '<?xml version="1.0" encoding="utf-8"?><MirvEmail><Company>100</Company><Order_Number>mrOrderW</Order_Number><ShipTo_Number>1</ShipTo_Number><Early_Delivery_Date>2016-10-20</Early_Delivery_Date><Late_Delivery_Date>2016-10-27</Late_Delivery_Date><Order_Details><Order_Line_Seq>1</Order_Line_Seq></Order_Details></MirvEmail>';
		
		Test.startTest();
		String response = AutoMIRV.autoMIRVMessage(amMessage);
		Test.stopTest();
		
		system.assert(response.contains('SUCCESS'));
		
	}
}