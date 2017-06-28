public class Quote_To_CW_VFExtension {

private final Quote q;String qid;

    public Quote_To_CW_VFExtension(ApexPages.StandardController controller) {
    
     this.q=(Quote)controller.getRecord();
     
     qid=[Select OpportunityId,Id,Conversion_Status__c from Quote where Id=:this.q.Id].id;

    }
    

public PageReference VFRedirect(){


PageReference p=new PageReference('/apex/Quote_CW_Redirect?');

p.getParameters().put('quoteId', qid);


return p;



}



}