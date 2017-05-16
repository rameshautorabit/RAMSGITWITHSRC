public class OrderFormController
{

    public OrderFormController(ApexPages.StandardController controller) {
     
        quoteObjid = ApexPages.currentPage().getParameters().get('id'); 
        quoteObj = [select id,Accountid,name from Quote where id =: ApexPages.currentPage().getParameters().get('id')];
        orderObj = new order__C();
        orderObj.Account__c = quoteObj.accountid;
        orderObj.Quote__c = quoteObjid;
        
    }
    public quote quoteObj{get;set;}
    public Order__c orderObj {get;set;}
    public string accountid{get;set;}
    public string quoteid{get;set;}
    public string quantitystr{get;set;}
    public id quoteObjid{get;set;}
      
    public pagereference save()
    {
        orderObj.Quantity__c= quantitystr;
        insert orderObj;
        pagereference pg = new pagereference('/' + quoteObjid);
        pg.setRedirect(true);
        return pg;
    }

}