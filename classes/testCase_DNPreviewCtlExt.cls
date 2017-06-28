@isTest
private class testCase_DNPreviewCtlExt {
	
	/*
	 *	Test methods for Case_DNPreviewCtlExt.cls and DelayNotification.cls
	 */
	
	// Create Delay Notification test data
	@testSetup static void dnTestData() {
		
		PrepareData.populateCustomSettings();
		
		Account acc = PrepareData.createAccount();
		insert acc;
		
		Contact con = PrepareData.createContact(acc.Id);
		insert con;
		
		Opportunity opp = PrepareData.createOpportunity(acc.Id);
		opp.Ops_Contact__c = UserInfo.getUserId();
		insert opp;
		
        Delayed_Order_Rule__c dor = PrepareData.rcDelayedOrderRule('Standard');
		
		List<RH_Order__c> orderList = new List<RH_Order__c>();
		orderList.add(PrepareData.createOrder('dnOrderW'));
		orderList[0].Order_Type_Code__c = 'W';
		
		orderList.add(PrepareData.createOrder('dnOrderE'));
		orderList[1].Order_Type_Code__c = 'W';
		orderList[1].Sold_to_Email__c = '';
		
		orderList.add(PrepareData.createOrder('dnOrderZ'));
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
		oliList.add(PrepareData.createOrderLine(orderList[0].Id, shipToList[0].Id, '001', product.Id));
		oliList[0].Backorder_Quantity__c = 1;
        oliList[0].In_Warehouse_Date__c = system.today() + 30;
        oliList[0].Available_Date__c = system.today() + 30 + 14;
        oliList[0].Coordinate_Group__c = '0';
        
		oliList.add(PrepareData.createOrderLine(orderList[1].Id, shipToList[1].Id, '001', product.Id));
		oliList[1].Backorder_Quantity__c = 1;
        oliList[1].In_Warehouse_Date__c = system.today() + 30;
        oliList[1].Available_Date__c = system.today() + 30 + 14;
        oliList[1].Coordinate_Group__c = '0';
        
		oliList.add(PrepareData.createOrderLine(orderList[2].Id, shipToList[2].Id, '001', product.Id));
		oliList[2].Backorder_Quantity__c = 1;
        oliList[2].In_Warehouse_Date__c = system.today() + 30;
        oliList[2].Available_Date__c = system.today() + 30 + 14;
        oliList[2].Coordinate_Group__c = '0';
        insert oliList;
        
        String tDate = String.valueOf(system.today());
        String dfDate = String.valueOf(oliList[0].Available_Date__c + 8);
        oliList[0].Delay_Feed__c = '{"CD":"' + dfDate + '","ND":"' + tDate + '"}';
        dfDate = String.valueOf(oliList[1].Available_Date__c + 8);
        oliList[1].Delay_Feed__c = '{"CD":"' + dfDate + '","ND":"' + tDate + '"}';
        dfDate = String.valueOf(oliList[2].Available_Date__c + 8);
        oliList[2].Delay_Feed__c = '{"CD":"' + dfDate + '","ND":"' + tDate + '"}';
        update oliList;
        
        List<Order_Line_Items__c> orderLines = new List<Order_Line_Items__c>();
        orderLines = [select Id, Delay_Feed_History__c, Backorder_Quantity__c, Coordinate_Group__c, Current_Available_Date__c, 
                        Current_Delay_Date__c, Available_Date__c, Original_Available_Date__c, In_Warehouse_Date__c, 
                        Days_Since_Original_Available_Date__c, DelayFeed__c, StaleDate__c, CW_SKU_ID__c, Line_Total__c, Line_Status_Description__c, 
                        RH_Order_Number__c, RH_Order_Number__r.Order_Type_Code__c 
                        from Order_Line_Items__c where Id = :oliList[0].Id or Id = :oliList[1].Id or Id = :oliList[2].Id];
        DelayedOrderActions.takeAction(orderLines);
	}
	
	// Test with valid parameters and a non-Contract case/order
	static testMethod void dnPreviewTest1() {
		
		List<Case> cList = new List<Case>();
        cList = [select Id, CaseNumber, Record_Type_Dev_Name__c, Request_Category__c, RH_Order_Number__c 
                from Case where Record_Type_Dev_Name__c = 'Delay_Notifications' and IsClosed = false and RH_Order_Number__r.Name = 'dnOrderW'];
        
        system.assertEquals(1, cList.size());
        
        // Now test the controller extension
    	ApexPages.StandardController std = new ApexPages.StandardController(cList[0]);
    	ApexPages.currentPage().getParameters().put('caseId', cList[0].Id);
		ApexPages.currentPage().getParameters().put('retURL', '/' + cList[0].Id);
		Case_DNPreviewCtlExt ctl = new Case_DNPreviewCtlExt(std);
		
		Test.startTest();
		ctl.sendNotification();
		Test.stopTest();
		
		cList = [select Id, CaseNumber, Record_Type_Dev_Name__c, Request_Category__c, RH_Order_Number__c 
                from Case where Record_Type_Dev_Name__c = 'Delay_Notifications' and IsClosed = true and RH_Order_Number__r.Name = 'dnOrderW'];
        
        system.assertEquals(1, cList.size());
	}
	
	// Test with valid parameters and a Contract case/order
	static testMethod void dnPreviewTest2() {
		
		List<Case> cList = new List<Case>();
        cList = [select Id, CaseNumber, Record_Type_Dev_Name__c, Request_Category__c, RH_Order_Number__c 
                from Case where Record_Type_Dev_Name__c = 'Delay_Notifications' and IsClosed = false and RH_Order_Number__r.Name = 'dnOrderZ'];
        
        system.assertEquals(1, cList.size());
        
        // Now test the controller extension
    	ApexPages.StandardController std = new ApexPages.StandardController(cList[0]);
    	ApexPages.currentPage().getParameters().put('caseId', cList[0].Id);
		ApexPages.currentPage().getParameters().put('retURL', '/' + cList[0].Id);
		Case_DNPreviewCtlExt ctl = new Case_DNPreviewCtlExt(std);
		
		Test.startTest();
		ctl.sendNotification();
		Test.stopTest();
		
		cList = [select Id, CaseNumber, Record_Type_Dev_Name__c, Request_Category__c, RH_Order_Number__c 
                from Case where Record_Type_Dev_Name__c = 'Delay_Notifications' and IsClosed = true and RH_Order_Number__r.Name = 'dnOrderZ'];
        
        system.assertEquals(1, cList.size());
	}
	
	// Test with bad data
	static testMethod void dnPreviewTest3() {
		
		List<Case> cList = new List<Case>();
        cList = [select Id, CaseNumber, Record_Type_Dev_Name__c, Request_Category__c, RH_Order_Number__c 
                from Case where Record_Type_Dev_Name__c = 'Delay_Notifications' and IsClosed = false and RH_Order_Number__r.Name = 'dnOrderE'];
        
        system.assertEquals(1, cList.size());
        
        // Now test the controller extension with incomplete or bad data
        ApexPages.StandardController std = new ApexPages.StandardController(cList[0]);
		Case_DNPreviewCtlExt ctl = new Case_DNPreviewCtlExt(std);
        
    	std = new ApexPages.StandardController(cList[0]);
    	ApexPages.currentPage().getParameters().put('caseId', cList[0].Id);
		ApexPages.currentPage().getParameters().put('retURL', '/' + cList[0].Id);
		ctl = new Case_DNPreviewCtlExt(std);
		
		ctl.sendNotification();
		ctl.cancelDNPreview();
		
		cList = [select Id, CaseNumber, Record_Type_Dev_Name__c, Request_Category__c, RH_Order_Number__c, Opportunity_PM__c, Gift_Card_Status__c, Notification_Type__c 
                from Case where Record_Type_Dev_Name__c = 'Delay_Notifications' and IsClosed = false and RH_Order_Number__r.Name = 'dnOrderZ'];
        cList[0].Opportunity_PM__c = null;
        update cList;
		std = new ApexPages.StandardController(cList[0]);
		ApexPages.currentPage().getParameters().put('caseId', cList[0].Id);
		ApexPages.currentPage().getParameters().put('retURL', '/' + cList[0].Id);
		ctl = new Case_DNPreviewCtlExt(std);
		
		cList[0].Gift_Card_Status__c = 'Pending';
		update cList;
		std = new ApexPages.StandardController(cList[0]);
		ApexPages.currentPage().getParameters().put('caseId', cList[0].Id);
		ApexPages.currentPage().getParameters().put('retURL', '/' + cList[0].Id);
		ctl = new Case_DNPreviewCtlExt(std);
		
		cList[0].Notification_Type__c = '';
		update cList;
		std = new ApexPages.StandardController(cList[0]);
		ApexPages.currentPage().getParameters().put('caseId', cList[0].Id);
		ApexPages.currentPage().getParameters().put('retURL', '/' + cList[0].Id);
		ctl = new Case_DNPreviewCtlExt(std);
	}
}