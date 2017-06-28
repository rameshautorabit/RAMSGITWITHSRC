/*
 *  Methods to test BatchProcessDelayNotifications.cls
 *
 */

@isTest(SeeAllData=true)
private class testBatchProcessDelayNotifications {
    
public static String bpdn_CRON_EXP = '0 0 0 15 3 ? 2022';
    
    static testMethod void bpdnTest1() {
    String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Case' and Name ='Delay Notifications'].Id;
        
        
        // Create the test data
        // Create a test Delay Notifications Schedule
        Delay_Notifications_Schedule__c DNS = new Delay_Notifications_Schedule__c(
                Name = 'bpdnTest1 Schedule',
                Active__c = false,
                Start_Time__c = '9:00 AM',
                End_Time__c = '3:00 PM',
                Interval_Minutes__c = 30,
                Max_Cases__c = 15,
                Catch_Up_Run_Time__c = '1:00 PM',
                Sunday__c = true,
                Monday__c = true,
                Tuesday__c = true,
                Wednesday__c = true,
                Thursday__c = true,
                Friday__c = true,
                Saturday__c = true
        );
        insert DNS;
        
        // Create the test data
        Delayed_Order_Rule__c dor = PrepareData.rcDelayedOrderRule('Standard');
        
        List<RH_Order__c> orderList = new List<RH_Order__c>();
        String orderNumber = 'bpdnT1O1';
        RH_Order__c order = PrepareData.createOrder(orderNumber);
        order.Sold_to_Email__c = 'billybob-example123456789012345678901234567890@rh.com';
        orderList.add(order);
        orderNumber = 'bpdnT1O2';
        order = PrepareData.createOrder(orderNumber);
        order.Total_Order_Amount__c = 95;
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
        oliList[0].Line_Status_Description__c = 'Open';
        oliList[0].In_Warehouse_Date__c = system.today() + 30;
        oliList[0].Available_Date__c = system.today() + 30 + 14;
        oliList[0].Coordinate_Group__c = '0';
        oliList[0].Line_Total__c = 70;
        
        oliList[1].Backorder_Quantity__c = 1;
        oliList[1].Line_Status_Description__c = 'Open';
        oliList[1].In_Warehouse_Date__c = system.today() + 30;
        oliList[1].Available_Date__c = system.today() + 30 + 14;
        oliList[1].Coordinate_Group__c = '0';
        oliList[1].Line_Total__c = 20;
        
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
        
        /*
        cList = [select Id, CaseNumber,  Request_Category__c, RH_Order_Number__c, IsClosed, Actual_Gift_Card_Amount__c 
                from Case where RH_Order_Number__c in :oIds 
                and Record_Type_Dev_Name__c = 'Delay Notifications' and Request_Category__c = 'Automatic Email' 
                and IsClosed = false];
        */
        
        cList = [select Id, CaseNumber,  Request_Category__c, RH_Order_Number__c, IsClosed, Actual_Gift_Card_Amount__c 
                from Case where RH_Order_Number__c in :oIds 
                and RecordTypeId=:strRecordTypeId];
        for (Case c :cList) {
            system.debug('*****TESTBATCHPROCESSDELAY c.IsClosed = ' + c.IsClosed + ' c.Request_Category = ' + c.Request_Category__c + ' c.Actual_Gift_Card_Amount = ' + c.Actual_Gift_Card_Amount__c);
        }
        
        
        system.assert(cList.size() > 0);
        //system.assertEquals(2, cList.size());
        
        // Make sure a gift card is generated
        cList[0].Actual_Gift_Card_Amount__c = 100;
        update clist[0];
        
        Test.startTest();
        
        BatchProcessDelayNotifications BA =  new BatchProcessDelayNotifications();
        String queryFields = 'Id, Sold_to_Email__c';
        String whereClause = 'RecordType.DeveloperName = \'Delay_Notifications\' AND Request_Category__c = \'Automatic Email\' AND IsClosed = false AND On_Hold__c = false AND RH_Order_Number__r.Name LIKE \'bpdnT1%\' ORDER BY CreatedDate';
        whereClause += ' LIMIT ' + DNS.Max_Cases__c;
        BA.bpdnQueryString = 'SELECT ' + queryFields + ' FROM Case WHERE ' + whereClause;
        system.debug('*****testBatchProcessDelayNotifications querystring = ' + BA.bpdnQueryString);
        Database.executeBatch(BA, 5);
         
        Test.stopTest();
        
        /*
        cList = [select Id, CaseNumber, Request_Category__c, RH_Order_Number__c, SendGrid_Result__c, Gift_Card_Status__c, IsClosed 
                from Case where RH_Order_Number__c in :oIds 
                and RecordTypeId=:strRecordTypeId and Request_Category__c = 'Automatic Email' 
                and (IsClosed = true or Gift_Card_Status__c = 'Pending')];
        
        for (Case c :cList) {
            system.debug('*****TESTBATCHPROCESSDELAY c.IsClosed = ' + c.IsClosed + ' c.Gift_Card_Status = ' + c.Gift_Card_Status__c);
        }
        */
        
        cList = [select Id, CaseNumber, Request_Category__c, RH_Order_Number__c, SendGrid_Result__c, Gift_Card_Status__c, IsClosed 
                from Case where RH_Order_Number__c in :oIds and RecordTypeId=:strRecordTypeId];
        system.debug('*****testBatchProcessDelayNotifications cList = ' + clist);
        
        for (Case c :cList) {
        	system.assertEquals('Automatic Email', c.Request_Category__c);
        	system.assert(c.IsClosed || c.Gift_Card_Status__c == 'Pending');
        }
        
        system.assert(cList.size() > 0);
        //system.assertEquals(2, cList.size());
        //for (Case c :cList) {
            //system.assert(c.SendGrid_Result__c.contains('SUCCESS'));
        //}
        
        // Test (execute the code) the schedulable class
        String jobId = System.schedule('ScheduleBatchProcessDelayNotificationsTEST', bpdn_CRON_EXP, new ScheduleBatchProcessDelayNotifications());
    }
}