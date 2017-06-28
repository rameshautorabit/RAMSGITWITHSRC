@isTest
private class testManualReservation_PreviewCtlExt {
	
	/*
	 *	Test methods for ManualReservation_PreviewCtlExt.cls and ManualReservation.cls.
	 *
	 */
	
	// Create Manual Reservation test data
	@testSetup static void mrTestData() {
		
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
        
        List<Manual_Reservation__c> mrList = new List<Manual_Reservation__c>();
        mrList.add(new Manual_Reservation__c(
        	Company__c = '100',
        	Order_Number__c = orderList[0].Id,
        	Ship_To__c = shipToList[0].Id,
        	Early_Delivery_Date__c = system.today().addDays(30),
        	Late_Delivery_Date__c = system.today().addDays(35),
        	Email_Subject_Brand__c = 'RH',
    		Email_To_Address__c = orderList[0].Sold_to_Email__c,
    		Order_Lines__c = '["' + orderList[0].Name + '-' + shipToList[0].Name + '-' + oliList[0].Name + '"]')
    	);
    	insert mrList;
	}
	
	// Test with valid parameters and a non-Contract order
	static testMethod void mrPreviewTest1() {
		
		List<Manual_Reservation__c> mrList = new List<Manual_Reservation__c>();
        mrList = [select Id, Order_Number__c from Manual_Reservation__c where Order_Number__r.Name = 'mrOrderW'];
        
        system.assertEquals(1, mrList.size());
        
        // Now test the controller extension
    	ApexPages.StandardController std = new ApexPages.StandardController(mrList[0]);
    	ApexPages.currentPage().getParameters().put('mrId', mrList[0].Id);
		ApexPages.currentPage().getParameters().put('retURL', '/' + mrList[0].Id);
		ManualReservation_PreviewCtlExt ctl = new ManualReservation_PreviewCtlExt(std);
		
		ctl.sendNotification();
		ctl.cancelMRPreview();
	}
	
	// Test with invalid parameters and a non-Contract order
	static testMethod void mrPreviewTest2() {
		
		List<Manual_Reservation__c> mrList = new List<Manual_Reservation__c>();
        mrList = [select Id, Order_Number__c from Manual_Reservation__c where Order_Number__r.Name = 'mrOrderW'];
        
        system.assertEquals(1, mrList.size());
        
        // Now test the controller extension
    	ApexPages.StandardController std = new ApexPages.StandardController(mrList[0]);
    	ApexPages.currentPage().getParameters().put('mrId', mrList[0].Id);
		ManualReservation_PreviewCtlExt ctl = new ManualReservation_PreviewCtlExt(std);
		
		ctl.cancelMRPreview();
	}
}