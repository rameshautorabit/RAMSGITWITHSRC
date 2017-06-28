/*
 *	Methods to test DelayNotificationsHold.cls
 *
 */

@isTest(SeeAllData=true)
private class testDelayNotificationsHold {
	
	public static String dnh_CRON_EXP = '0 0 0 15 3 ? 2022';
	
    // Test Delay Notifications cases being put on hold
	static testMethod void dnhTest1() {
		
		// Create the test data
		Delayed_Order_Rule__c dor = PrepareData.rcDelayedOrderRule('Standard');
		
		List<RH_Order__c> orderList = new List<RH_Order__c>();
		String orderNumber = 'dnhT1O1';
		RH_Order__c order = PrepareData.createOrder(orderNumber);
		orderList.add(order);
		orderNumber = 'dnhT1O2';
		order = PrepareData.createOrder(orderNumber);
		order.Sold_to_Email__c = null;
		orderList.add(order);
		insert orderList;
		
		List<Ship_To__c> shipToList = new List<Ship_To__c>();
		Ship_To__c shipTo = PrepareData.createShipTo(orderList[0].Id, '1');
		shipToList.add(shipTo);
		shipTo = PrepareData.createShipTo(orderList[1].Id, '1');
		shipToList.add(shipTo);
		insert shipToList;
		
		List<Id> oIds = new List<Id>();
		for (RH_Order__c o :orderList) {
			oIds.add(o.Id);
		}
		
		List<Product2> pList = new List<Product2>();
		pList = [select Id from Product2 where IsActive = true and Name like '%ABRS' limit 5];
		system.assertEquals(5, pList.size());
		
		
		List<Order_Line_Items__c> oliList = new List<Order_Line_Items__c>();
		Order_Line_Items__c oli;
		for (Integer i=0; i<pList.size(); i++) {
			oli = PrepareData.createOrderLine(orderList[0].Id, shipToList[0].Id, String.valueOf(i+1), pList[i].Id);
			oli.EXT_OrderShipToLine_Number__c = orderList[0].Name + '-1-' + String.valueOf(i+1);
			oliList.add(oli);
			
			oli = PrepareData.createOrderLine(orderList[1].Id, shipToList[1].Id, String.valueOf(i+1), pList[i].Id);
			oli.EXT_OrderShipToLine_Number__c = orderList[1].Name + '-1-' + String.valueOf(i+1);
			oliList.add(oli);
		}
		oliList[0].Backorder_Quantity__c = 1;
		oliList[0].In_Warehouse_Date__c = system.today() + 30;
		oliList[0].Available_Date__c = system.today() + 30 + 14;
		oliList[0].Coordinate_Group__c = '0';
		
		oliList[1].Backorder_Quantity__c = 1;
		oliList[1].In_Warehouse_Date__c = system.today() + 30;
		oliList[1].Available_Date__c = system.today() + 30 + 14;
		oliList[1].Coordinate_Group__c = '0';
		
		insert oliList;
		
		String tDate = String.valueOf(system.today());
		String dfDate = String.valueOf(oliList[0].Available_Date__c + 8);
		oliList[0].Delay_Feed__c = '{"CD":"' + dfDate + '","ND":"' + tDate + '"}';
		dfDate = String.valueOf(oliList[1].Available_Date__c + 8);
		oliList[1].Delay_Feed__c = '{"CD":"' + dfDate + '","ND":"' + tDate + '"}';
		update oliList;
		
		List<Order_Line_Items__c> orderLines = new List<Order_Line_Items__c>();
		orderLines = [select Id, Delay_Feed_History__c, Backorder_Quantity__c, Coordinate_Group__c, Current_Available_Date__c, 
						Current_Delay_Date__c, Available_Date__c, Original_Available_Date__c, In_Warehouse_Date__c, 
						Days_Since_Original_Available_Date__c, DelayFeed__c, StaleDate__c, CW_SKU_ID__c, Line_Total__c, Line_Status_Description__c, 
						RH_Order_Number__c, RH_Order_Number__r.Order_Type_Code__c 
						from Order_Line_Items__c where Id = :oliList[0].Id or Id = :oliList[1].Id];
		
		DelayedOrderActions.takeAction(orderLines);
		
		// Set today as a hold date
		List<Date_Range_Hold__c> drHoldList = new List<Date_Range_Hold__c>();
		drHoldList = [select Id, Delayed_Order_Rule__c, Start_Date__c, End_Date__c from Date_Range_Hold__c where Active__c = true];
		
		Date_Range_Hold__c drh = new Date_Range_Hold__c(
			Active__c = true,
			Delayed_Order_Rule__c = dor.Id,
			Start_Date__c = system.today(),
			End_Date__c = system.today() + 1
		);
		
		Test.startTest();
		insert drh;
		Test.stopTest();
		
		List<Case> cList = new List<Case>();
		cList = [select Id from Case where RH_Order_Number__c in :oIds and On_Hold__c = true];
		system.assertEquals(2, cList.size());
		
		drh.End_Date__c = system.today() + 2;
		update drh;
		
		// Test (execute the code) the schedulable class
		String jobId = System.schedule('ScheduleDelayNotificationsHoldTEST', dnh_CRON_EXP, new ScheduleDelayNotificationsHold());
    }
}