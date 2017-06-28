public class CWCalloutService {

    public static List<CWInvoice> invoiceData(String orderNumber){
       String url;
       if(Test.isRunningTest()){
          url = 'https://servicesuat.restorationhardware.com:10000/lightning/billing?OrderNumber=331971';
       }else{
          RH_Web_Services__c dataSource = RH_Web_Services__c.getInstance('External Data Source - Billing');   
          url = dataSource.Service_URL__c + orderNumber;
       }
       HttpResponse response = doCallout(url);
       Dom.Document doc = new Dom.Document();
       doc.load(response.getBody());         
       System.Debug('XML Response ================> '+ response.getBody());
       
       // FOR THOSE TIMES WHEN THE WEBSERVICE IS DOWN!
       //   Document d = [select id, name, body from Document where id = '0154B000000DVda']; 
       //   doc.load(d.body.toString());     
       //   System.Debug('XML Response ================> '+ d.body.toString());
        
       //Retrieve the root element for this document.
       Dom.XMLNode billingDetails = doc.getRootElement();       
       
       List<CWInvoice> invoices = new List<CWInvoice>();
       
       Set<String> allSkus = new Set<String>();
       for(Dom.XMLNode InvoiceHeader : billingDetails.getChildElements()){          
       
          if(InvoiceHeader.getName() == 'InvoiceHeader'){       
             CWInvoice inv = new CWInvoice(InvoiceHeader.getChildElements());
             invoices.add(inv);
             allSkus.addAll(inv.setSkus);
           }
       
          //CWInvoice inv = new CWInvoice(InvoiceHeader.getChildElements());
          //invoices.add(inv);
          //allSkus.addAll(inv.setSkus);
       }
       // get product details
       Map<String, Product2> skuMap = new Map<String, Product2>();
       for(Product2 p:[select Id, CW_External_Id__c, CW_Item_Description__c, ECommerce_Display_Name__c, SKU_Type__c 
                         from Product2 
                         where CW_External_Id__c != null 
                           AND CW_External_Id__c in :allSkus]){
             skuMap.put(p.CW_External_Id__c, p);
       }
       for(CWInvoice inv:invoices){
         for(CWInvoice.CWInvoiceLine invLine:inv.invoiceLine){
           if(skuMap.ContainsKey(invLine.skuId)){
              invLine.skuProduct = skuMap.get(invLine.skuId);
           }
         }
         //inv.invoiceLine.sort();
       }
        
       return invoices;
    }
    
    
  public static List<CWInvoice> retrieveInvoiceData(String OrderNumber){
    List<CWInvoice> invList = new List<CWInvoice>();
    invList = CWCalloutService.invoiceData(OrderNumber);//sort on InvoiceNumber
    
    System.Debug('INVOICE LIST=================> ' + invList);
    
    if (invList.isEmpty()) {
        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'There is no invoice data for order ' + OrderNumber + '.'));
    }
    invList.sort();
    return invList;
 } 
 
 public static List<CWOrderLineHistory> orderLineHistoryData(String orderNumber, String shipToNumber, String orderLineNumber){
       
       String url;
       if(Test.isRunningTest()){
          url = 'https://servicesuat.restorationhardware.com:10000/lightning/olh?OrderNumber=331971&shipToNumber=1&orderLineNum=1';
       }else{
          RH_Web_Services__c dataSource = RH_Web_Services__c.getInstance('Order Line History');   
          url = dataSource.Service_URL__c + orderNumber + '&shipToNumber=' + shipToNumber + '&orderLineNum=' + orderLineNumber ;
       }
       HttpResponse response = doCallout(url);
       Dom.Document doc = new Dom.Document();
       doc.load(response.getBody());         
       System.Debug('XML Response ================> '+ response.getBody());
       
       // FOR THOSE TIMES WHEN THE WEBSERVICE IS DOWN!
       /*
       Dom.Document doc = new Dom.Document();
       Document d = [select id, name, body from Document where id = '015Q0000000OiSa']; 
       doc.load(d.body.toString());     
       System.Debug('XML Response ================> '+ d.body.toString());
       */ 
       //Retrieve the root element for this document.
       Dom.XMLNode OrderLineActivities = doc.getRootElement();
               
       List<CWOrderLineHistory> orderLineHistories = new List<CWOrderLineHistory>();
        
       CWOrderLineHistory olh = new CWOrderLineHistory();
       orderLineHistories.addall(olh.CWOrderLineHistory(OrderLineActivities));
            
       return orderLineHistories;
    }
    
    
  public static List<CWOrderLineHistory> retrieveOrderLineHistoryData(String OrderNumber, String ShipToNumber, String OrderLineNumber){
    List<CWOrderLineHistory> olhList = new List<CWOrderLineHistory>();
    olhList = CWCalloutService.orderLineHistoryData(OrderNumber, ShipToNumber, OrderLineNumber);
    
    System.Debug('ORDER LINE HISTORY LIST=================> ' + olhList);
    /*
    if (olhList.isEmpty()) {
        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'There is no order line history data for order line ' + OrderLineNumber + '.'));
    }
    */
    //olhList.sort();
    return olhList;
 } 
 
  public static List<OrderRHOMNote> orderRHOMNotesData(String orderNumber){
       
       String url;
       if(Test.isRunningTest()){
          url = ' http://s1devmule1:8086/lightning/rhomnotes?OrderNumber=325307';
       }else{
          RH_Web_Services__c dataSource = RH_Web_Services__c.getInstance('Order RHOM Notes');   
          url = dataSource.Service_URL__c + orderNumber;
       }
       
       HttpResponse response = doCallout(url);
       Dom.Document doc = new Dom.Document();
       doc.load(response.getBody());         
       System.Debug('XML Response ================> '+ response.getBody());
       
       // FOR THOSE TIMES WHEN THE WEBSERVICE IS DOWN!
       /*
       Dom.Document doc = new Dom.Document();
       Document d = [select id, name, body from Document where id = '015Q0000000PEh8']; 
       doc.load(d.body.toString());     
       System.Debug('XML Response ================> '+ d.body.toString());
        */
       //Retrieve the root element for this document.
       
       Dom.XMLNode OrderRHOMItems = doc.getRootElement();
               
       List<OrderRHOMNote> orderRHOMNotes = new List<OrderRHOMNote>();
        
       OrderRHOMNote orn = new OrderRHOMNote();
       orderRHOMNotes.addall(orn.OrderRHOMNote(OrderRHOMItems));
            
       return orderRHOMNotes;
    }
    
    
  public static List<OrderRHOMNote> retrieveOrderRHOMNoteData(String OrderNumber){
    List<OrderRHOMNote> ornList = new List<OrderRHOMNote>();
    ornList = CWCalloutService.orderRHOMNotesData(OrderNumber);
    
    System.Debug('ORDER RHOM NOTES LIST=================> ' + ornList);
    /*
    if (ornList.isEmpty()) {
        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'There is no RHOM data for order' + OrderNumber + '.'));
    }
    */
    
    return ornList;
 } 
 
 public static List<CWOrderLinePersonalization> orderLinePersonalizationData(String orderNumber, String shipToNumber, String orderLineNumber){
       
       String url;
       if(Test.isRunningTest()){
          url = 'https://servicesuat.restorationhardware.com:10000/lightning/olpersonalize?OrderNumber=331971&shipToNumber=1&orderLineNum=1';
       }else{
          RH_Web_Services__c dataSource = RH_Web_Services__c.getInstance('Order Line Personalization');   
          url = dataSource.Service_URL__c + 'OrderNumber=' + orderNumber + '&shipToNumber=' + shipToNumber + '&orderLineNum=' + orderLineNumber ;
          
          System.debug('Personalization Request URL: ' + url);
       }
       
       HttpResponse response = doCallout(url);
       Dom.Document doc = new Dom.Document();
       doc.load(response.getBody());         
       System.Debug('XML Response ================> '+ response.getBody());
       
       
       // FOR THOSE TIMES WHEN THE WEBSERVICE IS DOWN!
       /*
       Dom.Document doc = new Dom.Document();
       Document d = [select id, name, body from Document where id = '0150S000000DT7M']; 
       doc.load(d.body.toString());     
       System.Debug('XML Response ================> '+ d.body.toString());
       */
       //Retrieve the root element for this document.
       Dom.XMLNode OrderLinePersonalizationItems = doc.getRootElement();
               
       List<CWOrderLinePersonalization> orderLinePersonalizations = new List<CWOrderLinePersonalization>();
        
       CWOrderLinePersonalization olp = new CWOrderLinePersonalization();
       OrderLinePersonalizations.addall(olp.CWOrderLinePersonalizations(OrderLinePersonalizationItems));
            
       return orderLinePersonalizations;
    }
      
  public static List<CWOrderLinePersonalization> retrieveOrderLinePersonalizationData(String OrderNumber, String ShipToNumber, String OrderLineNumber){
    List<CWOrderLinePersonalization> olpList = new List<CWOrderLinePersonalization>();
    olpList = CWCalloutService.orderLinePersonalizationData(OrderNumber, ShipToNumber, OrderLineNumber);
    
    System.Debug('ORDER LINE PERSONALIZATION LIST=================> ' + olpList);
    /*
    if (olhList.isEmpty()) {
        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'There is no order line history data for order line ' + OrderLineNumber + '.'));
    }
    */
    //olpList.sort();
    return olpList;
 }  
    
 	/**
     *   Helper method to make the HTTP GET call.
     *   The url argument is the URL of the external system.
     *   Returns the response from the external system.
     **/
     
    public static HttpResponse doCallout(String url) {

	    HttpResponse response = new HttpResponse();
	    
	    HttpRequest request = new HttpRequest();
	    request.setEndPoint(url);
	    request.setMethod('GET');
	    
		try{
		    response = new Http().send(request);      
		} catch(Exception ex) {
		    Utility.logException(ex, url); 
		}
		       
		return response;  
    }   
    
    /**
     *   Helper method to make the HTTP POST call.
     *   The url argument is the URL of the external system.
     *   Returns the response from the external system.
     **/
     
    public static HttpResponse doPostCallout(String url, String xmlString) {
		  
		HttpResponse response = new HttpResponse();
		    
		HttpRequest request = new HttpRequest();       
		request.setEndpoint(url);
		request.setMethod('POST');
		request.setBody(xmlString);
		request.setCompressed(false); 
		request.setHeader('Content-Type', 'application/xml');
		
		try{
		    response = new Http().send(request);      
		} catch(Exception ex) {
		    Utility.logException(ex, url); 
		} 
		
      	return response;      	  
    }
    
}