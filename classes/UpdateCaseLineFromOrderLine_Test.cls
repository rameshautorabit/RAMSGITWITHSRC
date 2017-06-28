@isTest(SeeAllData=true)
private class UpdateCaseLineFromOrderLine_Test 
{
    static testMethod void myUnitTest() 
    {
        Test.startTest();
        
        //Create RH Order
        RH_Order__c rho=new RH_Order__c();
        rho.Name='ORDER 123';
        rho.Designer__c='Designer A';
        rho.Sold_To_Address_1__c='123 Test Street';
        rho.Sold_To_Address_2__c='456 Test Street';
        rho.Gallery_Number__c='5';
        rho.Total_Order_Amount__c=1500.00;
        insert rho;
        
        System.debug(rho);
        
        //Create Order line items
        Order_Line_Items__c oli1=new Order_Line_Items__c();
        oli1.RH_Order_Number__c=rho.Id;
        oli1.Order_Quantity__c=2;
        oli1.Unit_Price__c=10.0;
        oli1.Line_Total__c=20.0;
        insert oli1;
        
        Order_Line_Items__c oli2=new Order_Line_Items__c();
        oli2.RH_Order_Number__c=rho.Id;
        oli2.Order_Quantity__c=3;
        oli2.Unit_Price__c=15.0;
        oli2.Line_Total__c=45.0;
        insert oli2;
        
        
        //Create Case
        Case c=new Case();
        List<RecordType> caseRecordType = [SELECT Id, Name, Description FROM RecordType WHERE SobjectType='Case' LIMIT 1]; 
        if(caseRecordType.size()>0){
            c.RecordTypeId=caseRecordType[0].Id;
        	}
        
        c.RH_Order_Number__c=rho.Id;
        c.Status='New';
        //c.Queue_Type__c='Accommodations';
        insert c;
        
        System.debug(c);
        
        //Create Case line items
        Case_Line_Items__c cli1=new Case_Line_Items__c();
        cli1.Case_Number__c=c.Id;
        cli1.Line_Number__c=oli1.Id;
        cli1.Order__c=rho.Id;
        insert cli1;
        
        //Create Case line items
        Case_Line_Items__c cli2=new Case_Line_Items__c();
        cli2.Case_Number__c=c.Id;
        cli2.Line_Number__c=oli2.Id;
        cli2.Order__c=rho.Id;
        insert cli2;
        
        //Update RHOrder
        rho.Name='ORDER 123';
        rho.Designer__c='Designer B';
        rho.Sold_To_Address_1__c='1234 Test Street';
        rho.Sold_To_Address_2__c='4567 Test Street';
        rho.Gallery_Number__c='5';
        rho.Total_Order_Amount__c=2500.00;
        update rho;
        
        System.debug(rho);
        
        //Update Order Line Items
        oli1.Order_Quantity__c=2;
        oli1.Unit_Price__c=15.0;
        oli1.Line_Total__c=30.0;
        update oli1;
        
        oli2.Order_Quantity__c=1;
        oli2.Unit_Price__c=25.0;
        oli2.Line_Total__c=25.0;
        update oli2;
        
        Test.stopTest();
    }
}