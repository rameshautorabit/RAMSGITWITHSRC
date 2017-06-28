/* Author SP- ForeFront
 * Purpose Test the Increment and decrement counts of OrderLines for CaseLines Added/Modified in Cases
 * Dates/Sections modified 8-25-14
 * V2.0- Added Test method to unit test "Case Line Item" Record type default functionality 
       - Author:  vk@ff
 */
@isTest
(SeeAllData=true)
public class CaseLineItemsTrigger_Test {
  
    
    /*****Added by vk@ff to unit test default case line record type, order line to case line and Reorder_Count update functionality*****/
  
    static testmethod void testOrderToCase()
    {
        test.startTest();
        RecordType r=[SELECT Id FROM RecordType WHERE SobjectType='Case' AND Name='Reorders'];
        
        //Create Case
        Case c=new Case();
        c.RecordTypeId=r.Id;
        c.New_Address__c = 'TestAddress';
        c.Send_to_First_Name__c = 'Bob';
        c.Send_to_Last_Name__c = 'Jones';
        c.Send_to_City__c = 'Santa Cruz';
        c.Send_to_State__c = 'CA';
        c.Send_to_Zip__c = '94500';
        c.Send_to_Country__c = 'USA';
        c.Send_to_Day_Phone__c = '555-555-5555';
        c.Original_Requested_Percentage__c=.95;
        c.Status='New';
        insert c;
        
        Case c1=[SELECT Id,CaseNumber, Owner.Name FROM Case WHERE Id=:c.Id];
        System.debug(' Case CREATED ' + c1);
        
        //Create Order 
        RH_Order__c rho=new RH_Order__c();
        rho.ShipTo1_Address__c='Test Street';
        rho.ShipTo1_Day_Phone__c='111-222-3344';
        rho.ShipTo1_Email__c='test@testrh.com';
        rho.Designer__c='Test Designer';
        insert rho;
        
        //Create Order lines
                
       List<Order_Line_Items__c> lstOfOLI=new List<Order_Line_Items__c>();
        
        for(Integer i=0;i<100;i++)
        {
            Order_Line_Items__c ol=new Order_Line_Items__c();
            ol.RH_Order_Number__c=rho.Id;
            ol.Line_Number__c='00'+(i+1);
            ol.Unit_Price__c=50.00;
            ol.Line_Total__c=100.00;
            ol.Order_Quantity__c=2;
            lstOfOLI.add(ol);
        }
        insert lstOfOLI;
        
        
        c.RH_Order_Number__c=rho.Id;
        update c;
        
       //Create Case line items
        
       List<Case_Line_Items__c> lstOfCLI=new List<Case_Line_Items__c>();
        
        RecordType clRT=[Select Id From RecordType Where SobjectType = 'Case_Line_Items__c' AND Name = 'Reorders' Limit 1];
        for(Integer j=0;j<100;j++)
        {
            Case_Line_Items__c cli=new Case_Line_Items__c();
            cli.Case_Number__c=c.Id;
            cli.Order__c=rho.Id;
            cli.Line_Number__c=lstOfOLI[j].Id;
            cli.RecordTypeId=clRT.Id;
            lstOfCLI.add(cli);
        }
        insert lstOfCLI;
        
        //Update Line numbers
        for(Integer i=99;i>49;i--)
        {
            for(Case_Line_Items__c cli:lstOfCLI)
            {
                cli.Line_Number__c=lstOfOLI[i].Id;
                
            }
        }
        update lstOfCLI;
        
        //Remove Order line number
        for(Case_Line_Items__c cli:lstOfCLI)
        {
            cli.Line_Number__c=null;
        }
        
        update lstOfCLI;
                
        //Delete Case line items
        delete lstOfCLI;
        
        //System.debug('Case LINE CREATED' + cli.Id);
        
        test.stopTest();
    }
    
    static testmethod void testProductToCaseLine()
    {
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
        
        //Create Product
        Product2 p=new Product2();
        p.Name='Test PRODUCT';
        p.Class__c='Test CLASS';
        p.Collection__c='Test Collection';
        p.CW_Color__c='WHITE';
        p.CW_Item_Description__c='This is product description';
        p.Web_Description__c='Test Web Description';
        insert p;
        
        //Create Case Line Item
        Case_Line_Items__c cli=new Case_Line_Items__c();
        cli.Case_Number__c=c.Id;
        cli.CW_SKU_ID__c=p.Id;
        insert cli;
        
        test.stopTest();
        
    }
}