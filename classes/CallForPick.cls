public with sharing class CallForPick {
	 public List<Case> Caselist{get;set;}
	  List<Case> caseUpList = new List<Case>();
	  Set<Id> caseIds = new Set<Id>();
	  RH_Web_Services__c rohc = RH_Web_Services__c.getInstance('Release Order Hold Callout'); 
	   public static String xmlResponse{get;set;}
	   public CallForPick(){
		Caselist=[Select Id,Record_Type_Dev_Name__c,Case_Order__c,Status,HTTP_POST_In_Progress__c,RH_Order_Number__c  from Case where Id=:ApexPages.currentPage().getParameters().get('caseId')];
		}
		public PageReference CaseRedirect(){
		if(CaseList[0].Record_Type_Dev_Name__c=='Reorders' && CaseList[0].RH_Order_Number__c!=null){
	 	 String orderNumber=CaseList[0].Case_Order__c;
	 	 HttpRequest req = new HttpRequest();
	 	 HttpResponse resp = new HttpResponse();
         Http http = new Http();
         req.setEndpoint(rohc.Service_URL__c);
         req.setMethod('GET');
         req.setBody(EncodingUtil.urlEncode(orderNumber, 'UTF-8'));
         req.setBody(orderNumber);
         req.setCompressed(false); 
         req.setHeader('Content-Type', 'application/xml');
         //System.debug(LoggingLevel.Debug, '>>>>>> POSTing Order #: '+ orderNumber + ' <<<<<<');
         try{
    // create the response object
   		 	resp = http.send(req);
   		 	System.debug('>>>>>> POSTing Order #: '+ orderNumber + ' <<<<<<');
   			}
   		catch(System.CalloutException e) {
    	System.debug('Callout error: '+ e);
    	System.debug('**************' +resp.toString());
    	apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Status of the response ' + e);
    	apexpages.addmessage(msg);
   		}
   		xmlResponse=String.valueOf(resp.getBody()).replace('\n', '');
   		System.debug('////////' +resp.getBody());
   		System.debug('+++++++++ XMLContent is'+ xmlResponse);
	 }
		
		PageReference RedirectToCaseDetail= new PageReference('/' +CaseList[0].Id);
		return RedirectToCaseDetail;
	}
	public PageReference Cancel() {
  		PageReference CancelPage = new PageReference('/' +CaseList[0].Id);
  		return CancelPage;
 	}
	public void invokeCW(){
	/*  if(CaseList[0].Record_Type_Dev_Name__c=='Reorders' && CaseList[0].RH_Order_Number__c!=null){
	 	 String orderNumber=CaseList[0].Case_Order__c;
	 	 HttpRequest req = new HttpRequest();
	 	 HttpResponse resp = new HttpResponse();
         Http http = new Http();
         req.setEndpoint(rohc.Service_URL__c);
         req.setMethod('GET');
         req.setBody(EncodingUtil.urlEncode(orderNumber, 'UTF-8'));
         req.setBody(orderNumber);
         req.setCompressed(false); 
         req.setHeader('Content-Type', 'application/xml');
         try{
    // create the response object
   		 	resp = http.send(req);
   		 	System.debug('>>>>>> POSTing Order #: '+ orderNumber + ' <<<<<<');
   			}
   		catch(System.CalloutException e) {
    	System.debug('Callout error: '+ e);
    	System.debug('**************' +resp.toString());
    	apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Status of the response ' + e);
    	apexpages.addmessage(msg);
   		}
   		xmlResponse=String.valueOf(resp.getBody()).replace('\n', '');
   		System.debug('////////' +resp.getBody());
   		System.debug('+++++++++ XMLContent is'+ xmlResponse);
	 }*/
	 }   
}