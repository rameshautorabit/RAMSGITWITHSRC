/*This class processes a list of Reorder cases for HTTP POSTing of the associated Order #s to an external URL being monitored by Mule*/


public class ReleaseOrderHoldWebServiceCallout {

    //HTTP callouts have to be done asynchronously
    
    @future (callout=true) 
    
    public static void sendNotification(List <Id> CaseIds) {
    
        //Get the parameters for the external target

        RH_Web_Services__c rohc = RH_Web_Services__c.getInstance('Release Order Hold Callout'); 
        
        
        //Build a list of cases from the case ids passed by ReleaseOrderHoldCalloutTrigger
        
        List<Case> caseList = new List<Case>();  
        CaseList.add([Select Id, RH_Order_Number__c, HTTP_POST_In_Progress__c from Case where Id in :CaseIds]); 
        
        //Step through the cases and POST the associated Order # to the external target
        
        for (Case c :CaseList) 
        {        
            Id OrderId = c.RH_Order_Number__c;  
            
            Map<Id, RH_Order__c> ordersMap = new Map<Id, RH_Order__c>([Select Id, Name from RH_Order__c where Id = :OrderId]);  
                    
            String orderNumber = (ordersMap.get(c.RH_Order_Number__c).Name);           
            
            
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http(); 

            req.setEndpoint(rohc.Service_URL__c);
            req.setMethod('POST');
            //req.setBody(EncodingUtil.urlEncode(orderNumber, 'UTF-8'));
            req.setBody(orderNumber);
            req.setCompressed(false); 
            req.setHeader('Content-Type', 'application/xml');
        
            System.debug('>>>>>> POSTing Order #: '+ orderNumber + ' <<<<<<');
                   
            try {
				if (!Test.isRunningTest()) {
					res = http.send(req);
				}
			} catch(System.CalloutException e) {
				System.debug('Callout error: '+ e);
				System.debug(res.toString());
			}
                    
           //Update the flag to reflect that the HTTP POST is no longer in progress         
           
           c.HTTP_Post_In_Progress__c = FALSE; 
           //Update c;        
        }
        if (!CaseList.isEmpty()) {
        	update CaseList;
        }     
    }  
    
/*
    //The following section is for testing purposes to enable deploy. This should be revisited.
       
    public String testNotification(){ 
            
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        
        RH_Web_Services__c rohc = RH_Web_Services__c.getInstance('Release Order Hold Callout');
        
        String result = 'Successful Notification Test';
        
        req.setMethod('POST');
        req.setBody(EncodingUtil.urlEncode(result, 'UTF-8'));
        req.setCompressed(false);
           
        return result;
        }
*/        
}