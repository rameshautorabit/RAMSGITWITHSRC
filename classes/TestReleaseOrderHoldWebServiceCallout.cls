@isTest(SeeAllData=true)
private class TestReleaseOrderHoldWebServiceCallout {
    
    /*
     *	Test methods for ReleaseOrderHoldWebServiceCallOut.cls and ReleaseOrderHoldCalloutTrigger.trigger
     *
     */
	
    
    /*
    static testmethod void test_Notification(){
    releaseOrderHoldWebServiceCallout rel = new releaseOrderHoldWebServiceCallout();
    
    String retVal = rel.testNotification();
    
    String expectedResult = 'Successful Notification Test';
    System.assertEquals(retVal, expectedResult);
    }
    */
    
    static testmethod void test_Notification() {
    	
    	List<Id> caseIds = new List<Id>();
    	//Create the test data
    	RH_Order__c o = new RH_Order__c();
        o.RecordTypeId = [select Id from RecordType where Name = 'Master' and SobjectType = 'RH_Order__c' limit 1].Id;
        o.Name = '7777777';
        insert o;
        
        Order_Line_Items__c ol = new Order_Line_Items__c();
        ol.Name = '77';
        ol.RH_Order_Number__c = o.Id;
        insert ol;
        
        Case c = new Case();
        c.RecordTypeId = [Select Id from RecordType where Name = 'Reorders' and SobjectType = 'Case' limit 1].Id;     
        c.RH_Order_Number__c = o.Id;
       // c.Queue_Type__c = 'Reorders';
        c.Client_Type__c = 'Customer';
        c.Send_to_First_Name__c = 'John';
        c.Send_to_Last_Name__c = 'Doe';
        c.Send_to_Address_1__c = '1234 Main Street';
        c.Send_to_City__c = 'San Francisco';
        c.Send_to_State__c = 'CA';
        c.Send_to_Country__c = 'USA';
        c.Send_to_Zip__c = '94107';
        c.Send_to_Day_Phone__c = '777-777-7777';       
        c.Original_Requested_Percentage__c=.95;
        // c.HTTP_POST_In_Progress__c=True;    
        insert c;
        
        Case_Line_Items__c cl= new Case_Line_Items__c();
        cl.RecordTypeId = [Select Id, SobjectType, Name From RecordType Where Name = 'Reorders' and SobjectType = 'Case_Line_Items__c' limit 1].id;
        cl.Order__c = o.Id;
        cl.Case_Number__c = c.Id;
        cl.Reorder_Reason__c = 'Customer Preference'; 
        insert cl;
        
        // Run the test
    	//Test.StartTest();
    	Test.setMock(HttpCalloutMock.class, new MockROHCResponseGenerator());
        c.Status = 'Call for Pick'; 
        try{
        update c;
        }
        catch(DmlException e){
        System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , e.getDmlStatusCode(0));
        }
        //Test.StopTest();
        
        // Verify results
        c = [select Id, HTTP_POST_In_Progress__c from Case where Id = :c.Id];
        caseIds.add(c.Id);
        ReleaseOrderHoldWebServiceCallout.sendNotification(caseIds);
        system.assertEquals(true, c.HTTP_POST_In_Progress__c);
    }
}