@isTest
public class TestReleaseOrderHoldCalloutTrigger {
    public static testmethod void TestReleaseOrderHoldCalloutTrigger() {
    
        //Create and insert test data then update case to Status of 'test', this will make the trigger run the test route and not attempt to call the ReleaseOrderHoldCallout class
    	PrepareData.populateCustomSettings();
    	RH_Order__c o = new RH_Order__c();
        o.RecordTypeId = [Select Id, SobjectType, Name From RecordType Where Name = 'Master' and SobjectType = 'RH_Order__c' limit 1].id;
        o.Name = '7777777';
        insert o;
        
        Order_Line_Items__c ol = new Order_Line_Items__c();
        ol.Name = '77';
        ol.RH_Order_Number__c = o.Id;
        insert ol;
        
        Case c = new Case();
        c.RecordTypeId = [Select Id, SobjectType, Name From RecordType Where Name = 'Reorders' and SobjectType = 'Case' limit 1].id;     
        c.RH_Order_Number__c = o.Id;
        //c.Queue_Type__c = 'Reorders';
        c.Client_Type__c = 'Customer';
        c.Send_to_First_Name__c = 'John';
        c.Send_to_Last_Name__c = 'Doe';
        c.Send_to_Address_1__c = '1234 Main Street';
        c.Send_to_City__c = 'San Francisco';
        c.Send_to_State__c = 'CA';
        c.Send_to_Country__c = 'USA';
        c.Send_to_Zip__c = '94107';
        c.Send_to_Day_Phone__c = '777-777-7777';           
        insert c;
        
        Case_Line_Items__c cl= new Case_Line_Items__c();
        cl.RecordTypeId = [Select Id, SobjectType, Name From RecordType Where Name = 'Reorders' and SobjectType = 'Case_Line_Items__c' limit 1].id;
        cl.Order__c = o.Id;
        cl.Case_Number__c = c.Id;
        cl.Reorder_Reason__c = 'Customer Preference'; 
        insert cl;
        
       	Test.setMock(HttpCalloutMock.class, new MockROHCResponseGenerator());
        c.Status = 'Call for Pick'; 
        update c;
               
        Case c2 = new Case();       
        c2.Status = [Select Id, Status from Case where Id = :c.Id].Status;
        System.AssertEquals('Call for Pick', c2.Status);  
        
        }
}