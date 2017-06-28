/**
    Test Class for: Apex class "UpdateCase" called from the CaseTrigger
**/

//@isTest(SeeAllData=true)
@isTest
private class CaseTrigger_Test 
{ 
    static RH_Order__c o;
    static Order_Line_Items__c orderline;
    //static String opQId = Groups__c.getInstance('Order Processing Queue').GroupId__c;

    //static RH_User__c rhu;
    
    private static void setup(){
       
       PrepareData.populateCustomSettings();
       PrepareData.createGenericRHData();
       o = PrepareData.createOrder('111111');
       insert o;
       //
       Product2 p = new Product2(Actual_Product_Name__c = 'test', Direct_Current_Price__c = 1.0, DMMSSku__c = 'test123', ELC__c = 1.0, IsActive = true, Name = 'test', ProductCode = 'test', SKU_Ship_Via__c = 'Ship');
       insert p;
       Ship_To__c st = PrepareData.createShipTo(o.Id, 'TEST1');
       insert st;
       orderline = PrepareData.createOrderLine(o.Id, st.Id, '1', p.Id);
       orderline.Reorder_Count__c = 3;
       insert orderline;
       //Create RH User
      // rhu = new RH_User__c();
       //rhu.Name = 'Test RH User';
       //rhu.User__c = UserInfo.getUserId();
       //insert rhu;
       //
       //List<CaseLineToOrderLineMapping__c> listCaseLineMapToOrderLine = PrepareData.createCaseLineToOrderLineMappingList();
       //insert listCaseLineMapToOrderLine;
    }
    
    static testMethod void testDecrementReorderCount(){
        setup();
        Case c = PrepareData.createCase('Reorders');
        c.Status = 'New';
        //c.RecordTypeId = Utility.getRecordTypeId(Case.sObjectType, 'Reorders');
        c.Original_Requested_Percentage__c=.95;
        insert c;
        //TriggerStopper.stopCase = false;
        //case line items
        Case_Line_Items__c cli = PrepareData.createCaseLineItem(c);
        cli.Reason__c = 'Photos';
        cli.Line_Number__c = orderline.Id;
        cli.Reorder_Reason__c = 'Mold';
        insert cli; 
        c.Status = 'Closed - Created in Error';
        c.Sold_to_Name__c = 'TEST';
        c.Sold_to_Company__c = 'TESTCO'; 
        c.Original_Requested_Percentage__c=.85;
        TriggerStopper.stopCase = false;
        update c;
    }
    
    static testMethod void testCaseStatusTransferAndAssignmentRules(){
        setup();
        Case c = PrepareData.createCase('Credit Card Declines');
        c.Order_Type_Code__c = 'Z';
        insert c;
        //processDeclinedCreditCardCases, applyAssignmentRules
        Case c2 = PrepareData.createCase('Credit Card Declines');
        c2.Order_Type_Code__c = 'A';
        c2.SendGrid_In_Process__c = false;
         c2.Original_Requested_Percentage__c=.95;
        insert c2;
    }
    
    static testMethod void testCaseBeforeUpdate(){
        setup();
        // Tests CaseService.populateOrderInformation 
        Case c = PrepareData.createCase('Credit Card Declines');
        c.Order_Type_Code__c = 'Z';
        c.RH_Order_Number__c = o.Id;
        //c.OwnerId=opQId;
        c.Original_Requested_Percentage__c=.95;
        insert c;
        c.RH_Order_Number__c = o.Id;
        update c;       
        Case c2 = PrepareData.createCase('Credit Card Declines');
        c2.Status = 'New';
        //c2.RH_User__c = rhu.Id;
        c2.RecordTypeId = Utility.getRecordTypeId(Case.sObjectType, 'Standard');
        insert c2;
        //case line items
        Case_Line_Items__c cli = PrepareData.createCaseLineItem(c2);
        cli.Reason__c = 'Photos';
        insert cli; 
        //
        c2.RecordTypeId = Utility.getRecordTypeId(Case.sObjectType, 'Product Information');
        c2.Status = 'Warm Transfer';
        c2.Sold_to_Name__c = 'TEST';
        c2.Sold_to_Company__c = 'TESTCO'; 
        update c2;          
    }    
     
    static testMethod void testDefaultCaseFields(){
        setup();
        // CaseService.defaultCaseFields tester 
        Case c = PrepareData.createCase('Delay Notifications');
        c.Order_Type_Code__c = 'Z';
        c.RH_Order_Number__c = o.Id;
        c.Original_Requested_Percentage__c=.95;
        c.Status = 'Re-Open';
        insert c;
        //case line items
        Case_Line_Items__c cli = PrepareData.createCaseLineItem(c);
        cli.Reason__c = 'Photos';
        insert cli;     
        c.Status = 'Closed - Successful';
        c.Action_Required__c = true;
        update c;
        c.Status = 'Warm Transfer';
        c.RecordTypeId = Utility.getRecordTypeId(Case.sObjectType, 'Product Information');
        c.Sold_to_Name__c = 'test';
        c.Sold_to_Company__c = 'test';
        update c;               
    }     
     
    //Test method to test the Case Assignment rules when the Case Status changes, Milestone Completion and Pop Alerts
    static testMethod void myUnitTest() 
    {
        PrepareData.populateCustomSettings();
        
        //test.startTest();
        //Create a case with Record type
        List<RecordType> rtype=[SELECT Id, Name FROM RecordType WHERE SObjectType='Case' AND Name= 'Accommodations - Order Header' LIMIT 1];
        
        //Get Case Record type
        Case c=new Case();
        c.Original_Requested_Percentage__c=.95;
        c.Send_to_First_Name__c = 'Bob';
        c.Send_to_Last_Name__c = 'Jones';
        c.Send_to_City__c = 'Santa Cruz';
        c.Send_to_State__c = 'CA';
        c.Send_to_Zip__c = '94500';
        c.Send_to_Country__c = 'USA';
        c.Send_to_Day_Phone__c = '555-555-5555';
        if(rtype.size()>0)
        {
            c.RecordTypeId=rtype[0].Id;
        }
        insert c;
        
        test.startTest();
        
        //Change the case status
        c.Status='Callout Team';
        c.New_Address__c = 'Address';
        c.Sold_to_Name__c = 'Test Sold Name';
        update c;
        
        //Create RH User
       /* rhu=new RH_User__c();
        rhu.Name='Test RH User';
        rhu.User__c=UserInfo.getUserId();
        insert rhu;
        
        c.Accommodation_Approved_By__c=rhu.Id;
        c.Accommodation_Requested_By__c=rhu.Id;
        update c;*/
        
        //Set the Milestone Status 
        c.Milestone_Status__c='Open Violation';
        c.Milestone_Violated__c=true;
        c.Sold_To_Name__c = 'Testing Sold to Name';
        update c;
        
        c.Milestone_Status__c='Closed Violation';
        update c;
        
        test.stopTest();
    } 
    
    //******** TEST THE CASE FUTURE PROCESSING UPDATE *********
    static testMethod void testCaseFutureProcessingUpdate()
    {
        PrepareData.populateCustomSettings();
        
        test.startTest();
        //Create a case with Record type
        List<RecordType> rtype=[SELECT Id, Name FROM RecordType WHERE SObjectType='Case' AND Name= 'Accommodations - Order Header' LIMIT 1];
        
        //Get Case Record type
        Case c=new Case();
        c.Future_Processing__c = false;
        c.Future_Processing_Date__c = Date.today().addDays(5);
        c.New_Address__c = 'TestAddress';
        c.Send_to_First_Name__c = 'Bob';
        c.Send_to_Last_Name__c = 'Jones';
        c.Send_to_City__c = 'Santa Cruz';
        c.Send_to_State__c = 'CA';
        c.Send_to_Zip__c = '94500';
        c.Send_to_Country__c = 'USA';
        c.Send_to_Day_Phone__c = '555-555-5555';
         c.Original_Requested_Percentage__c=.95;
        if(rtype.size()>0)
        {
            c.RecordTypeId=rtype[0].Id;
        }
        insert c;
        
        //Change the case status
        c.Future_Processing_Date__c = Date.today().addDays(6);
        update c;
         Case data = [SELECT Id, Future_Processing_Date__c, Future_Processing__c FROM Case Where Id =:c.Id Limit 1];
        System.assertEquals(true, data.Future_Processing__c);
        
        test.stopTest();
        
    }
    
    //********* TEST THE CASE STATUS WHEN ACTION REQUIRED FIELD IS SET TO TRUE *******
    
    static testMethod void testCaseStatus()
    {
        //Create RH User
       /* rhu = new RH_User__c();
        rhu.Name = 'Test RH User';
        rhu.User__c = UserInfo.getUserId();
        insert rhu;*/
        
        PrepareData.populateCustomSettings();
        
        //test.startTest();
        Case c=new Case();
        c.New_Address__c = 'TestAddress';
       // c.Accommodation_Approved_By__c=rhu.Id;
        c.Send_to_First_Name__c = 'Bob';
        c.Send_to_Last_Name__c = 'Jones';
        c.Send_to_City__c = 'Santa Cruz';
        c.Send_to_State__c = 'CA';
        c.Send_to_Zip__c = '94500';
        c.Send_to_Country__c = 'USA';
        c.Send_to_Day_Phone__c = '555-555-5555';
        c.Original_Requested_Percentage__c=.95;
        
        insert c;
        
        //c.Accommodation_Approved_By__c=rhu.Id;
        //update c;
        c.Status='In Progress';
        //c.Accommodation_Approved_By__c=rhu.Id;
        //c.Accommodation_Requested_By__c=rhu.Id;
        c.Sold_to_Name__c = 'Test Sold Name';
        update c;
        
        test.startTest();
        
        c.Status='Closed - Invalid';
        update c;
        
        c.Action_Required__c=true;
        update c;
        test.stopTest();
    }
    
    //***********TEST ORDER TO CASE INFO FUNCTIONALITY AND REMOVE ORDER INFORMATION ON CASE WHEN ORDER NO LONGER EXISTS FOR THE CASE *******
    
    static testmethod void testOrderToCase()
    {
        PrepareData.populateCustomSettings();
        
        test.startTest();
        
        //Create Case
        Case c=new Case();
        c.New_Address__c = 'TestAddress';
        c.Send_to_First_Name__c = 'Bob';
        c.Send_to_Last_Name__c = 'Jones';
        c.Send_to_City__c = 'Santa Cruz';
        c.Send_to_State__c = 'CA';
        c.Send_to_Zip__c = '94500';
        c.Send_to_Country__c = 'USA';
        c.Send_to_Day_Phone__c = '555-555-5555';
        c.Original_Requested_Percentage__c=.95;
        insert c;
        
        //Create Order
        RH_Order__c rho=new RH_Order__c();
        rho.ShipTo1_Address__c='Test Street';
        rho.ShipTo1_Day_Phone__c='111-222-3344';
        rho.ShipTo1_Email__c='test@testrh.com';
        rho.Designer__c='Test Designer';
        insert rho;
        
        //Assign Order to Case
        c.RH_Order_Number__c=rho.Id;
        update c;
        
        test.stopTest();
    }
    
    static testmethod void testLockAndUnlock()
    {
        PrepareData.populateCustomSettings();
        
        //test.startTest();
        //processCaseLocks
        //Create RH User
       /* rhu = new RH_User__c();
        rhu.Name='Test RH User';
        rhu.User__c=UserInfo.getUserId();
        insert rhu;*/
        
        //Create Case
        Case c=new Case();
        //c.Accommodation_Approved_By__c=rhu.Id;
        c.Send_to_First_Name__c = 'Bob';
        c.Send_to_Last_Name__c = 'Jones';
        c.Send_to_City__c = 'Santa Cruz';
        c.Send_to_State__c = 'CA';
        c.Send_to_Zip__c = '94500';
        c.Send_to_Country__c = 'USA';
        c.Send_to_Day_Phone__c = '555-555-5555';
        c.Original_Requested_Percentage__c=.95;
        insert c;
            
        //c.Accommodation_Approved_By__c=rhu.Id;
        //update c;
        
        //Create Case Lines
        List<Case_Line_Items__c> lstOfCLI=new List<Case_Line_Items__c>();
        
        for(Integer j=0;j<100;j++)
        {
            Case_Line_Items__c cli=new Case_Line_Items__c();
            cli.Case_Number__c=c.Id;
            lstOfCLI.add(cli);
        }
        insert lstOfCLI;
        
        test.startTest();
        
        c.Status='In Progress';
        //c.Accommodation_Approved_By__c=rhu.Id;
        //c.Accommodation_Requested_By__c=rhu.Id;
        c.Sold_to_Name__c = 'Test Sold Name';
        update c;
        
        //Lock
        c.Status = 'Closed - Successful';
        c.Submitted_for_Lock__c = false;
        update c; 
        
        //Unlock
        c.Status = 'Re-Open';
        c.Submitted_for_Lock__c = true;
        update c;
        
        Case_Comments__c cc=new Case_Comments__c();
        cc.Case__c=c.Id;
        cc.Comment__c='Test Case Comment';
        cc.Action_Required__c=true;
        insert cc;
        test.stopTest();
        
    }
    
    /*static testmethod void testProcessCaseTimerEntries(){
        setup();
        List<Case> cases = new List<Case>();
        cases.add(PrepareData.createCase('Credit Card Declines'));
        cases.add(PrepareData.createCase('Credit Card Declines'));
        cases.add(PrepareData.createCase('Credit Card Declines'));
        cases.add(PrepareData.createCase('Credit Card Declines'));
        cases.add(PrepareData.createCase('Credit Card Declines'));
        cases.add(PrepareData.createCase('Credit Card Declines'));
        insert cases;//
        TriggerStopper.stopCase = false;
        //
        cases[4].Status = 'Callout Team';
        //cases[4].To__c = 'NOT DC';
        update cases[4];
        TriggerStopper.stopCase = false;
        //cases[5].To__c = 'NOT QA/Audit';
        update cases[5];
        TriggerStopper.stopCase = false;
        //
        cases[0].Status = 'Callout Team';
        cases[0].Interim_Update__c = 'Order Cancel';
        cases[1].Status = 'Tier 2';
        cases[1].Interim_Update__c = 'Order Cancel';
        cases[2].Status = 'Modified Coaching';
        cases[2].Interim_Update__c = 'Order Cancel';
        cases[3].Status = 'Closed - Successful';
        cases[3].Interim_Update__c = 'Order Cancel';
        //cases[4].Status = 'Transfer';       
        //cases[4].To__c = 'DC';
        cases[4].Interim_Update__c = 'Order Cancel';
        //cases[5].To__c = 'QA/Audit';
        cases[5].Interim_Update__c = 'Order Cancel';        
        cases[5].Attempted_Contact__c = 3;
        update cases;       
    }*/
}