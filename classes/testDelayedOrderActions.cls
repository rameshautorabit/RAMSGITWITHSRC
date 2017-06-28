/*
 *  Methods to test DelayedOrderActions.cls
 *
 */

@isTest(SeeAllData=true)
private class testDelayedOrderActions {
    
    //Test stale date on a new order line
    static testMethod void doaTest1() {
        
        // Create the test data
        Delayed_Order_Rule__c dor = PrepareData.rcDelayedOrderRule('Standard');
        
        String orderNumber = 'doaT1O1';
        RH_Order__c order = PrepareData.createOrder(orderNumber);
        
        system.debug('*****doaTest1 order.EXT_Order_Number__c = ' + order.EXT_Order_Number__c);
        
        insert order;
        
        Ship_To__c shipTo = PrepareData.createShipTo(order.Id, '1');
        insert shipTo;
        
        List<Product2> pList = new List<Product2>();
        pList = [select Id from Product2 where IsActive = true and Name like '%ABRS' limit 5];
        system.assertEquals(5, pList.size());
        
        List<Order_Line_Items__c> oliList = new List<Order_Line_Items__c>();
        Order_Line_Items__c oli;
        for (Integer i=0; i<pList.size(); i++) {
            oli = PrepareData.createOrderLine(order.Id, shipTo.Id, String.valueOf(i+1), pList[i].Id);
            oli.EXT_OrderShipToLine_Number__c = orderNumber + '-1-' + String.valueOf(i+1);
            oliList.add(oli);
        }
        
        oliList[2].Backorder_Quantity__c = 1;
        oliList[2].In_Warehouse_Date__c = system.today() - 1;
        oliList[2].Line_Status_Description__c = 'Open';
        
        Test.startTest();
        insert oliList;
        List<Order_Line_Items__c> orderLines = new List<Order_Line_Items__c>();
        orderLines = [select Id, Delay_Feed_History__c, Backorder_Quantity__c, Coordinate_Group__c, Current_Available_Date__c, 
                        Current_Delay_Date__c, Available_Date__c, Original_Available_Date__c, In_Warehouse_Date__c, 
                        Days_Since_Original_Available_Date__c, DelayFeed__c, StaleDate__c, CW_SKU_ID__c, Line_Total__c, Line_Status_Description__c, 
                        RH_Order_Number__c, RH_Order_Number__r.Order_Type_Code__c 
                        from Order_Line_Items__c where Id = :oliList[2].Id];
        
        DelayedOrderActions.takeAction(orderLines);
        Test.stopTest();
        
        List<Case> cList = new List<Case>();
        cList = [select Id, CaseNumber, Record_Type_Dev_Name__c, Request_Category__c, RH_Order_Number__c 
                from Case where RH_Order_Number__c = :order.Id 
                and Record_Type_Dev_Name__c = 'Delay_Notifications' and Request_Category__c = 'Stale Date'];
        
        system.assertEquals(1, cList.size());
    }
    
    // Test new backorder dates on order lines - automatic email
    static testMethod void doaTest2() {
        
        // Create the test data
        Delayed_Order_Rule__c dor = PrepareData.rcDelayedOrderRule('Standard');
        
        String orderNumber = 'doaT2O1';
        RH_Order__c order = PrepareData.createOrder(orderNumber);
        
        system.debug('*****doaTest1 order.EXT_Order_Number__c = ' + order.EXT_Order_Number__c);
        
        insert order;
        
        Ship_To__c shipTo = PrepareData.createShipTo(order.Id, '1');
        insert shipTo;
        
        List<Product2> pList = new List<Product2>();
        pList = [select Id from Product2 where IsActive = true and Name like '%ABRS' limit 5];
        system.assertEquals(5, pList.size());
        
        List<Order_Line_Items__c> oliList = new List<Order_Line_Items__c>();
        Order_Line_Items__c oli;
        for (Integer i=0; i<pList.size(); i++) {
            oli = PrepareData.createOrderLine(order.Id, shipTo.Id, String.valueOf(i+1), pList[i].Id);
            oli.EXT_OrderShipToLine_Number__c = orderNumber + '-1-' + String.valueOf(i+1);
            oliList.add(oli);
        }
        oliList[0].Backorder_Quantity__c = 1;
        oliList[0].In_Warehouse_Date__c = system.today() + 30;
        oliList[0].Available_Date__c = system.today() + 30 + 14;
        oliList[0].Coordinate_Group__c = '0';
        
        oliList[1].Backorder_Quantity__c = 1;
        oliList[1].In_Warehouse_Date__c = system.today() + 30;
        oliList[1].Available_Date__c = system.today() + 30 + 14;
        oliList[1].Coordinate_Group__c = '5';
        
        oliList[2].Backorder_Quantity__c = 1;
        oliList[2].In_Warehouse_Date__c = system.today() + 30;
        oliList[2].Available_Date__c = system.today() + 30 + 21;
        oliList[2].Coordinate_Group__c = '5';
        
        Test.startTest();
        insert oliList;
        String tDate = String.valueOf(system.today());
        String dfDate = String.valueOf(oliList[0].Available_Date__c + 8);
        oliList[0].Delay_Feed__c = '{"CD":"' + dfDate + '","ND":"' + tDate + '"}';
        dfDate = String.valueOf(oliList[1].Available_Date__c + 15);
        oliList[1].Delay_Feed__c = '{"CD":"' + dfDate + '","ND":"' + tDate + '"}';
        update oliList;
        
        List<Order_Line_Items__c> orderLines = new List<Order_Line_Items__c>();
        orderLines = [select Id, Delay_Feed_History__c, Backorder_Quantity__c, Coordinate_Group__c, Current_Available_Date__c, 
                        Current_Delay_Date__c, Available_Date__c, Original_Available_Date__c, In_Warehouse_Date__c, 
                        Days_Since_Original_Available_Date__c, DelayFeed__c, StaleDate__c, CW_SKU_ID__c, Line_Total__c, Line_Status_Description__c, 
                        RH_Order_Number__c, RH_Order_Number__r.Order_Type_Code__c 
                        from Order_Line_Items__c where Id = :oliList[0].Id or Id = :oliList[1].Id];
        DelayedOrderActions.takeAction(orderLines);
        
        Test.stopTest();
        
        List<Case> cList = new List<Case>();
        cList = [select Id, CaseNumber, Record_Type_Dev_Name__c, Request_Category__c, RH_Order_Number__c 
                from Case where RH_Order_Number__c = :order.Id 
                and Record_Type_Dev_Name__c = 'Delay_Notifications' and Request_Category__c = 'Automatic Email'];
        
        system.assertEquals(1, cList.size());
        
        oliList[0].Backorder_Quantity__c = 0;
        oliList[1].Backorder_Quantity__c = 0;
        oliList[2].Line_Status_Description__c = 'Cancelled';
        update oliList;
        
        cList = [select Id, CaseNumber, Record_Type_Dev_Name__c, Request_Category__c, RH_Order_Number__c 
                from Case where RH_Order_Number__c = :order.Id 
                and Record_Type_Dev_Name__c = 'Delay_Notifications' and IsClosed = false];
        
        system.assertEquals(0, cList.size());
    }
    
    // Test new backorder dates on order lines - callout and special attention
    static testMethod void doaTest3() {
        
        // Create the test data
        Delayed_Order_Rule__c dor = PrepareData.rcDelayedOrderRule('Standard');
        
        String orderNumber = 'doaT3O1';
        RH_Order__c order = PrepareData.createOrder(orderNumber);
        
        system.debug('*****doaTest1 order.EXT_Order_Number__c = ' + order.EXT_Order_Number__c);
        
        order.Sold_to_Email__c = null;
        insert order;
        
        Ship_To__c shipTo = PrepareData.createShipTo(order.Id, '1');
        insert shipTo;
        
        List<Product2> pList = new List<Product2>();
        pList = [select Id from Product2 where IsActive = true and Name like '%ABRS' limit 5];
        system.assertEquals(5, pList.size());
        
        List<Order_Line_Items__c> oliList = new List<Order_Line_Items__c>();
        Order_Line_Items__c oli;
        for (Integer i=0; i<pList.size(); i++) {
            oli = PrepareData.createOrderLine(order.Id, shipTo.Id, String.valueOf(i+1), pList[i].Id);
            oli.EXT_OrderShipToLine_Number__c = orderNumber + '-1-' + String.valueOf(i+1);
            oliList.add(oli);
        }
        oliList[0].Backorder_Quantity__c = 1;
        oliList[0].In_Warehouse_Date__c = system.today() + 30;
        oliList[0].Available_Date__c = system.today() + 30 + 14;
        oliList[0].Coordinate_Group__c = '0';
        
        oliList[1].Backorder_Quantity__c = 1;
        oliList[1].In_Warehouse_Date__c = system.today() + 30;
        oliList[1].Available_Date__c = system.today() + 30 + 14;
        oliList[1].Coordinate_Group__c = '5';
        
        oliList[2].Backorder_Quantity__c = 1;
        oliList[2].In_Warehouse_Date__c = system.today() + 30;
        oliList[2].Available_Date__c = system.today() + 30 + 21;
        oliList[2].Coordinate_Group__c = '5';
        
        Test.startTest();
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
        
        List<Case> cList = new List<Case>();
        cList = [select Id, CaseNumber, Record_Type_Dev_Name__c, Request_Category__c, RH_Order_Number__c 
                from Case where RH_Order_Number__c = :order.Id 
                and Record_Type_Dev_Name__c = 'Delay_Notifications' and Request_Category__c = 'Callout'];
        
        system.assertEquals(1, cList.size());
        
        dfDate = String.valueOf(oliList[0].Available_Date__c + 200);
        oliList[0].Delay_Feed__c = '{"CD":"' + dfDate + '","ND":"' + tDate + '"}';
        update oliList;
        
        orderLines = new List<Order_Line_Items__c>();
        orderLines = [select Id, Delay_Feed_History__c, Backorder_Quantity__c, Coordinate_Group__c, Current_Available_Date__c, 
                        Current_Delay_Date__c, Available_Date__c, Original_Available_Date__c, In_Warehouse_Date__c, 
                        Days_Since_Original_Available_Date__c, DelayFeed__c, StaleDate__c, CW_SKU_ID__c, Line_Total__c, Line_Status_Description__c, 
                        RH_Order_Number__c, RH_Order_Number__r.Order_Type_Code__c 
                        from Order_Line_Items__c where Id = :oliList[0].Id];
        DelayedOrderActions.takeAction(orderLines);
        
        Test.stopTest();
        
        cList = [select Id, CaseNumber, Record_Type_Dev_Name__c, Request_Category__c, RH_Order_Number__c 
                from Case where RH_Order_Number__c = :order.Id 
                and Record_Type_Dev_Name__c = 'Delay_Notifications' and Request_Category__c = 'Special Attention'];
        
        system.assertEquals(1, cList.size());
    }
    
    public static String doa_CRON_EXP = '0 0 0 15 3 ? 2022';
    
    // Test batch processing of stale date order lines - BatchDelayedOrderActions
    static testMethod void doaTest4() {
        // Create the test data
        Delayed_Order_Rule__c dor = PrepareData.rcDelayedOrderRule('Standard');
        
        List<RH_Order__c> orderList = new List<RH_Order__c>();
        String orderNumber = 'doaT4O1';
        RH_Order__c order = PrepareData.createOrder(orderNumber);
        orderList.add(order);
        orderNumber = 'doaT4O2';
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
        
        for (Order_Line_Items__c ol :oliList) {
            ol.Backorder_Quantity__c = 1;
            ol.In_Warehouse_Date__c = system.today() - 5;
            ol.Available_Date__c = system.today() - 1;
            ol.Line_Status_Description__c = 'Open';
            ol.Coordinate_Group__c = '0';
        }
        
        insert oliList;
        
        List<Case> cList = new List<Case>();
        cList = [select Id, RH_Order_Number__c from Case where RH_Order_Number__c in :oIds];
        system.assertEquals(0, cList.size());
        
        oliList.clear();
        oliList = [select Id from Order_Line_Items__c where RH_Order_Number__c in :oIds and StaleDate__c = true];
        system.assertEquals(10, oliList.size());
        
        String query = 'SELECT Id, DelayFeed__c, StaleDate__c, Delay_Feed_History__c, Backorder_Quantity__c, Coordinate_Group__c, '
                + 'Current_Available_Date__c, Current_Delay_Date__c, RH_Order_Number__c, Available_Date__c, Original_Available_Date__c, '
                + 'In_Warehouse_Date__c, Days_Since_Original_Available_Date__c, CW_SKU_ID__c, Line_Total__c, Line_Status_Description__c '
                + 'FROM Order_Line_Items__c WHERE DelayFeed__c = true AND RH_Order_Number__r.Name like \'doaT4%\'';
        
        Test.startTest();
        BatchDelayedOrderActions batch = new BatchDelayedOrderActions(query); 
        Database.executeBatch(batch, 20);
        Test.stopTest();
        
        cList = [select Id, RH_Order_Number__c from Case where RH_Order_Number__c in :oIds];
        system.assertEquals(2, cList.size());
        
        oliList.clear();
        oliList = [select Id from Order_Line_Items__c where RH_Order_Number__c in :oIds and StaleDate__c = true];
        system.assertEquals(0, oliList.size());
        
        // Test (execute the code) the schedulable class
        String jobId = System.schedule('ScheduleBatchDelayedOrderActionsTEST', doa_CRON_EXP, new ScheduleBatchDelayedOrderActions());
    }
    
    // Test batch processing of stale date order lines - BatchStaleDate
    static testMethod void doaTest5() {
        // Create the test data
        Delayed_Order_Rule__c dor = PrepareData.rcDelayedOrderRule('Standard');
        
        List<RH_Order__c> orderList = new List<RH_Order__c>();
        String orderNumber = 'doaT5O1';
        RH_Order__c order = PrepareData.createOrder(orderNumber);
        orderList.add(order);
        orderNumber = 'doaT5O2';
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
        
        for (Order_Line_Items__c ol :oliList) {
            ol.Backorder_Quantity__c = 1;
            ol.In_Warehouse_Date__c = system.today() - 1;
            ol.Line_Status_Description__c = 'Open';
            ol.Available_Date__c = system.today() - 1;
            ol.Coordinate_Group__c = '0';
        }
        
        insert oliList;
        
        List<Case> cList = new List<Case>();
        cList = [select Id, RH_Order_Number__c from Case where RH_Order_Number__c in :oIds];
        system.assertEquals(0, cList.size());
        
        oliList.clear();
        oliList = [select Id from Order_Line_Items__c where RH_Order_Number__c in :oIds and StaleDate__c = true];
        system.assertEquals(10, oliList.size());
        
        String query = 'SELECT Id, DelayFeed__c, StaleDate__c, Delay_Feed_History__c, Backorder_Quantity__c, Coordinate_Group__c, '
                + 'Current_Available_Date__c, Current_Delay_Date__c, RH_Order_Number__c, Available_Date__c, Original_Available_Date__c, '
                + 'In_Warehouse_Date__c, Days_Since_Original_Available_Date__c, CW_SKU_ID__c, Line_Total__c, Line_Status_Description__c '
                + 'FROM Order_Line_Items__c '
                + 'WHERE In_Warehouse_Date__c = YESTERDAY AND Backorder_Quantity__c > 0 AND RH_Order_Number__r.Name like \'doaT5%\'';
        
        Test.startTest();
        BatchStaleDate batch = new BatchStaleDate(query); 
        Database.executeBatch(batch, 20);
        Test.stopTest();
        
        cList = [select Id, RH_Order_Number__c from Case where RH_Order_Number__c in :oIds];
        system.assertEquals(2, cList.size());
        
        oliList.clear();
        oliList = [select Id from Order_Line_Items__c where RH_Order_Number__c in :oIds and StaleDate__c = true];
        system.assertEquals(0, oliList.size());
        
        // Test (execute the code) the schedulable class
        String jobId = System.schedule('ScheduleBatchStaleDateTEST', doa_CRON_EXP, new ScheduleBatchStaleDate());
    }
    
    /*
    // Test automatic updating of open Delay Notification cases because of changed Order Line data
    static testMethod void doaTest6() {
        
        // Create the test data
        Delayed_Order_Rule__c dor = PrepareData.rcDelayedOrderRule('Standard');
        
        List<RH_Order__c> oList = new List<RH_Order__c>();
        String orderNumber = 'doaT6O1';
        RH_Order__c order = PrepareData.createOrder(orderNumber);
        oList.add(order);
        orderNumber = 'doaT6O2';
        order = PrepareData.createOrder(orderNumber);
        oList.add(order);
        
        //system.debug('*****doaT6 oList = ' + oList);
        
        insert oList;
        
        List<Ship_To__c> shipToList = new List<Ship_To__c>();
        Ship_To__c shipTo = PrepareData.createShipTo(oList[0].Id, '1');
        shipToList.add(shipTo);
        shipTo = PrepareData.createShipTo(oList[1].Id, '1');
        shipToList.add(shipTo);
        insert shipToList;
        
        List<Product2> pList = new List<Product2>();
        pList = [select Id from Product2 where IsActive = true and Name like '%ABRS' limit 5];
        system.assertEquals(5, pList.size());
        
        List<Order_Line_Items__c> oliList = new List<Order_Line_Items__c>();
        Order_Line_Items__c oline;
        for (Integer i=0; i<pList.size(); i++) {
            oline = PrepareData.createOrderLine(oList[0].Id, shipToList[0].Id, String.valueOf(i+1), pList[i].Id);
            oline.EXT_OrderShipToLine_Number__c = oList[0].Name + '-' + shipToList[0].Name + '-' + String.valueOf(i+1);
            oliList.add(oline);
            oline = PrepareData.createOrderLine(oList[1].Id, shipToList[1].Id, String.valueOf(i+1), pList[i].Id);
            oline.EXT_OrderShipToLine_Number__c = oList[1].Name + '-' + shipToList[1].Name + '-' + String.valueOf(i+1);
            oliList.add(oline);
        }
        oliList[0].Backorder_Quantity__c = 1;
        oliList[0].Line_Status_Description__c = 'Open';
        oliList[0].In_Warehouse_Date__c = system.today() + 30;
        oliList[0].Available_Date__c = system.today() + 30 + 14;
        oliList[0].Coordinate_Group__c = '0';
        
        oliList[2].Backorder_Quantity__c = 1;
        oliList[2].Line_Status_Description__c = 'Open';
        oliList[2].In_Warehouse_Date__c = system.today() + 30;
        oliList[2].Available_Date__c = system.today() + 30 + 21;
        oliList[2].Coordinate_Group__c = '5';
        
        oliList[1].Backorder_Quantity__c = 1;
        oliList[1].Line_Status_Description__c = 'Open';
        oliList[1].In_Warehouse_Date__c = system.today() + 30;
        oliList[1].Available_Date__c = system.today() + 30 + 14;
        oliList[1].Coordinate_Group__c = '0';
        
        oliList[3].Backorder_Quantity__c = 1;
        oliList[3].Line_Status_Description__c = 'Open';
        oliList[3].In_Warehouse_Date__c = system.today() - 30;
        oliList[3].Available_Date__c = system.today() + 30 + 21;
        oliList[3].Coordinate_Group__c = '6';
        
        insert oliList;
        Set<Id> oliIds = new Set<Id>();
        for (Order_Line_Items__c oli :oliList) {
            oliIds.add(oli.Id);
        }
        
        List<Order_Line_Items__c> orderLines = new List<Order_Line_Items__c>();
        
        String tDate = String.valueOf(system.today());
        String dfDate = String.valueOf(oliList[0].Available_Date__c + 8);
        oliList[0].Delay_Feed__c = '{"CD":"' + dfDate + '","ND":"' + tDate + '"}';
        dfDate = String.valueOf(oliList[1].Available_Date__c + 15);
        oliList[1].Delay_Feed__c = '{"CD":"' + dfDate + '","ND":"' + tDate + '"}';
        update oliList;
        
        orderLines = [select Id, Delay_Feed_History__c, Backorder_Quantity__c, Coordinate_Group__c, Current_Available_Date__c, 
                        Current_Delay_Date__c, Available_Date__c, Original_Available_Date__c, In_Warehouse_Date__c, 
                        Days_Since_Original_Available_Date__c, DelayFeed__c, StaleDate__c, CW_SKU_ID__c, Line_Total__c, Line_Status_Description__c, 
                        RH_Order_Number__c, RH_Order_Number__r.Order_Type_Code__c 
                        from Order_Line_Items__c where Id = :oliIds];
        
        system.debug('*****doaT6 orderLines 2 = ' + orderLines);
        
        DelayedOrderActions.takeAction(orderLines);
        
        Test.startTest();
        List<Case> cList = new List<Case>();
        
        cList = [select Id, CaseNumber, Record_Type_Dev_Name__c, Request_Category__c, RH_Order_Number__c 
                from Case where (RH_Order_Number__c = :oList[0].Id or RH_Order_Number__c = :oList[1].Id) and 
                Record_Type_Dev_Name__c = 'Delay_Notifications' and (Request_Category__c = 'Callout' or Request_Category__c = 'Stale Date')];
        
        system.assertEquals(2, cList.size());
        
        // Change to order line data - one no longer on backorder, one no longer with stale date
        oliList[0].Backorder_Quantity__c = 0;
        oliList[3].In_Warehouse_Date__c = system.today() + 14;
        update oliList;
        
        // Execute batch job to update cases due to updated order line data
        Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
        String dnRecordTypeId = rtMap.get('Delay Notifications').getRecordTypeId();
        String queryString = 'SELECT Id, CaseNumber, Status, Request_Category__c '
            + 'FROM Case '
            + 'WHERE RecordTypeId = \'' + dnRecordTypeId + '\' AND IsClosed = false AND Gift_Card_Status__c != \'Pending\' AND RH_Order_Number__r.Name LIKE \'doaT6%\'';
        BatchDelayNotificationCases batch = new BatchDelayNotificationCases(queryString); 
        Database.executeBatch(batch, 5);
        
        Test.stopTest();
        
        cList = [select Id, CaseNumber, Record_Type_Dev_Name__c, Request_Category__c, RH_Order_Number__c 
                from Case where (RH_Order_Number__c = :oList[0].Id or RH_Order_Number__c = :oList[1].Id) and 
                Record_Type_Dev_Name__c = 'Delay_Notifications' and (Request_Category__c = 'Callout' or Request_Category__c = 'Stale_Date')];
                
        //system.debug('*****doaT6 cList 2 = ' + cList);
        
        system.assertEquals(1, cList.size());
        
        // Test (execute the code) the schedulable class
        String jobId = System.schedule('ScheduleBatchDelayNotificationCasesTEST', doa_CRON_EXP, new ScheduleBatchDelayNotificationCases());
    }
    
    // Test batch job that pumps existing order lines back through the delayed order actions/rules
    static testMethod void doaTest7() {
        
        // Create the test data
        Delayed_Order_Rule__c dor = PrepareData.rcDelayedOrderRule('Standard');
        
        List<RH_Order__c> oList = new List<RH_Order__c>();
        String orderNumber = 'doaT7O1';
        RH_Order__c order = PrepareData.createOrder(orderNumber);
        oList.add(order);
        orderNumber = 'doaT7O2';
        order = PrepareData.createOrder(orderNumber);
        oList.add(order);
        
        //system.debug('*****doaT7 oList = ' + oList);
        
        insert oList;
        
        List<Ship_To__c> shipToList = new List<Ship_To__c>();
        Ship_To__c shipTo = PrepareData.createShipTo(oList[0].Id, '1');
        shipToList.add(shipTo);
        shipTo = PrepareData.createShipTo(oList[1].Id, '1');
        shipToList.add(shipTo);
        insert shipToList;
        
        List<Product2> pList = new List<Product2>();
        pList = [select Id from Product2 where IsActive = true and Name like '%ABRS' limit 5];
        system.assertEquals(5, pList.size());
        
        List<Order_Line_Items__c> oliList = new List<Order_Line_Items__c>();
        Order_Line_Items__c oline;
        for (Integer i=0; i<pList.size(); i++) {
            oline = PrepareData.createOrderLine(oList[0].Id, shipToList[0].Id, String.valueOf(i+1), pList[i].Id);
            oline.EXT_OrderShipToLine_Number__c = oList[0].Name + '-' + shipToList[0].Name + '-' + String.valueOf(i+1);
            oliList.add(oline);
            oline = PrepareData.createOrderLine(oList[1].Id, shipToList[1].Id, String.valueOf(i+1), pList[i].Id);
            oline.EXT_OrderShipToLine_Number__c = oList[1].Name + '-' + shipToList[1].Name + '-' + String.valueOf(i+1);
            oliList.add(oline);
        }
        oliList[0].Backorder_Quantity__c = 1;
        oliList[0].Line_Status_Description__c = 'Open';
        oliList[0].In_Warehouse_Date__c = system.today() + 30;
        oliList[0].Available_Date__c = system.today() + 30 + 14;
        oliList[0].Coordinate_Group__c = '0';
        
        oliList[2].Backorder_Quantity__c = 1;
        oliList[2].Line_Status_Description__c = 'Open';
        oliList[2].In_Warehouse_Date__c = system.today() + 30;
        oliList[2].Available_Date__c = system.today() + 30 + 21;
        oliList[2].Coordinate_Group__c = '5';
        
        oliList[1].Backorder_Quantity__c = 1;
        oliList[1].Line_Status_Description__c = 'Open';
        oliList[1].In_Warehouse_Date__c = system.today() + 30;
        oliList[1].Available_Date__c = system.today() + 30 + 14;
        oliList[1].Coordinate_Group__c = '0';
        
        oliList[3].Backorder_Quantity__c = 1;
        oliList[3].Line_Status_Description__c = 'Open';
        oliList[3].In_Warehouse_Date__c = system.today() - 30;
        oliList[3].Available_Date__c = system.today() + 30 + 21;
        oliList[3].Coordinate_Group__c = '6';
        
        insert oliList;
        Set<Id> oliIds = new Set<Id>();
        for (Order_Line_Items__c oli :oliList) {
            oliIds.add(oli.Id);
        }
        
        List<Order_Line_Items__c> orderLines = new List<Order_Line_Items__c>();
        
        String tDate = String.valueOf(system.today());
        String dfDate = String.valueOf(oliList[0].Available_Date__c + 8);
        oliList[0].Delay_Feed__c = '{"CD":"' + dfDate + '","ND":"' + tDate + '"}';
        dfDate = String.valueOf(oliList[1].Available_Date__c + 15);
        oliList[1].Delay_Feed__c = '{"CD":"' + dfDate + '","ND":"' + tDate + '"}';
        update oliList;
        
        orderLines = [select Id, Delay_Feed_History__c, Backorder_Quantity__c, Coordinate_Group__c, Current_Available_Date__c, 
                        Current_Delay_Date__c, Available_Date__c, Original_Available_Date__c, In_Warehouse_Date__c, 
                        Days_Since_Original_Available_Date__c, DelayFeed__c, StaleDate__c, CW_SKU_ID__c, Line_Total__c, Line_Status_Description__c, 
                        RH_Order_Number__c, RH_Order_Number__r.Order_Type_Code__c 
                        from Order_Line_Items__c where Id = :oliIds];
        
        //system.debug('*****doaT7 orderLines 2 = ' + orderLines);
        
        DelayedOrderActions.takeAction(orderLines);
        
        Test.startTest();
        List<Case> cList = new List<Case>();
        cList = [select Id, CaseNumber, Record_Type_Dev_Name__c, Request_Category__c, RH_Order_Number__c, IsClosed 
                from Case where (RH_Order_Number__c = :oList[0].Id or RH_Order_Number__c = :oList[1].Id) and 
                Record_Type_Dev_Name__c = 'Delay_Notifications' and (Request_Category__c = 'Callout' or Request_Category__c = 'Stale Date')];
                
        system.debug('*****doaT7 cList = ' + cList);
        
        system.assertEquals(2, cList.size());
        
        // Execute batch job to send send order line data related to delay notification cases back through the rules
        Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
        String dnRecordTypeId = rtMap.get('Delay Notifications').getRecordTypeId();
        String queryString = 'SELECT Id, CaseNumber, Status, Request_Category__c, Delay_Notification_Reason__c '
            + 'FROM Case '
            + 'WHERE RecordTypeId = \'' + dnRecordTypeId + '\' AND IsClosed = false AND Gift_Card_Status__c != \'Pending\' AND RH_Order_Number__r.Name LIKE \'doaT7%\'';
        BatchDNCaseExecuteRules batch = new BatchDNCaseExecuteRules(queryString); 
        Database.executeBatch(batch, 5);
        
        Test.stopTest();
        
        cList = [select Id, CaseNumber, Record_Type_Dev_Name__c, Request_Category__c, RH_Order_Number__c, IsClosed 
                from Case where (RH_Order_Number__c = :oList[0].Id or RH_Order_Number__c = :oList[1].Id) and 
                Record_Type_Dev_Name__c = 'Delay_Notifications' and (Request_Category__c = 'Callout' or Request_Category__c = 'Stale Date')];
                
        system.debug('*****doaT7 cList 2 = ' + cList);
        
        system.assertEquals(2, cList.size());
        
        // Test (execute the code) the schedulable class
        String jobId = System.schedule('ScheduleBatchDNCaseExecuteRulesTEST', doa_CRON_EXP, new ScheduleBatchDNCaseExecuteRules());
    }
    */
}