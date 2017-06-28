@isTest(SeeAlldata=true)
private class AddNewCaseLineItemsClass_Test 
{
    static testMethod void myUnitTest() 
    {
        //Creating a RH Order
        RH_Order__c rhOrder=new RH_Order__c();
        rhOrder.Name='ORDER 123';
        insert rhOrder;
        
        //Creating a Ship To
        Ship_To__c shipTo=new Ship_To__c();
        shipTo.Order__c=rhOrder.Id;
        shipTo.Ship_to_Number__c='1';
        insert shipTo;
        
        //Creating RH Order Lines
        Order_Line_Items__c oli1=new Order_Line_Items__c();
        oli1.RH_Order_Number__c=rhOrder.Id;
        oli1.Line_Number__c='1';
        oli1.Ship_To__c=shipTo.Id;  
        insert oli1;
        
        Order_Line_Items__c oli2=new Order_Line_Items__c();
        oli2.RH_Order_Number__c=rhOrder.Id;
        oli2.Line_Number__c='2';
        oli2.Ship_To__c=shipTo.Id;  
        insert oli2;
        
        //Creating Case
        Case c=new Case();
        c.Order_Number__c=rhOrder.Id;
        insert c;
        
        //Instantiating a PageReference
        
        PageReference pr=Page.AddNewCaseLineItems;
        Test.setCurrentPage(pr);
        ApexPages.currentPage().getParameters().put('caseId',c.Id);
        ApexPages.currentPage().getParameters().put('OrderId',rhOrder.Id);
        AddNewCaseLineItemsClass con=new AddNewCaseLineItemsClass();
        con.getSelectedOrderLineList();
        con.save();
        con.gethasNext();
        con.next();
        con.saveandSelectMore();
        con.filter();
        con.gettotalPages();
        con.gethasPrevious();
        con.previous();
        con.gethasLast();
        con.last();
        con.gethasFirst();
        con.first();
        con.sortLineNumber();
        String sortColumn = con.getsortColumn();
        system.assertEquals('LineNumber', sortColumn);
        con.sortItemNumber();
        con.sortItemDescription();
        con.sortDC();
        con.sortOrderQuantity();
        con.sortReturnQuantity();
        con.sortShipDate();
        con.sortLineTotal();
        con.sortShiptoNum();
        con.sortCollection();
        con.sortMonogram_able();
        con.sortSPO();
        con.sortSPO();
        con.cancel();
        
    }
}