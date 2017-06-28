public with sharing class OrderLine_PersonalizationIntCtrlExt {
    
    private final Order_Line_Items__c rhOrderLine;
	Order_Line_Items__c theRHOrderLine = new Order_Line_Items__c();
	List<CWOrderLinePersonalization> orderLinePersonalizationList = new List<CWOrderLinePersonalization>();
                  
    public OrderLine_PersonalizationIntCtrlExt(ApexPages.StandardController stdController){
    
       	this.rhOrderLine = (Order_Line_Items__c)stdController.getRecord();
       	
       	System.debug('This Order Line: ' + this.rhOrderLine);
       	
       	theRHOrderLine = [Select EXT_OrderShipToLine_Number__c from Order_Line_Items__c where Id =: this.rhOrderLine.Id];

       	System.debug('Ext Order Id: ' + theRHOrderLine.EXT_OrderShipToLine_Number__c);
    }

	public List<CWOrderLinePersonalization> getOrderLinePersonalizationList(){
       
		if (orderLinePersonalizationList.size()==0) {
        	try{       
        		String[] olpExtId = (theRHOrderLine.EXT_OrderShipToLine_Number__c).split('-');
        		System.debug('Order: ' + olpExtId[0] + ' Ship To: ' + olpExtId[1] + ' Line: ' + olpExtId[2]);
            	orderLinePersonalizationList = CWCalloutService.retrieveOrderLinePersonalizationData(olpExtId[0], olpExtId[1], olpExtId[2]);
              }
              catch(Exception e){
              	System.debug('Order Line Personalizations Notes Error' + e);
              	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error retrieving data from external data source.'));
                return null;
              }
            }
            return orderLinePersonalizationList;
	}    
}