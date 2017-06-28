public with sharing class OrderLine_HistoryIntCtrlExt {
	
	private final Order_Line_Items__c rhOrderLine;
	Order_Line_Items__c theRHOrderLine = new Order_Line_Items__c();
	List<CWOrderLineHistory> orderLineHistories = new List<CWOrderLineHistory>();
                  
    public OrderLine_HistoryIntCtrlExt(ApexPages.StandardController stdController){
    
       	this.rhOrderLine = (Order_Line_Items__c)stdController.getRecord();
       	theRHOrderLine = [Select EXT_OrderShipToLine_Number__c from Order_Line_Items__c where Id =: this.rhOrderLine.Id];

       	System.debug('Ext Order Line Id: ' + theRHOrderLIne.EXT_OrderShipToLine_Number__c);
    }

	public List<CWOrderLineHistory> getOrderLineHistoryList(){
       
		if (orderLineHistories.size()==0) {
        	try{       
        		String[] olhExtId = (theRHOrderLine.EXT_OrderShipToLine_Number__c).split('-');
        		System.debug('Order: ' + olhExtId[0] + ' Ship To: ' + olhExtId[1] + ' Line: ' + olhExtId[2]);
            	orderLineHistories = CWCalloutService.retrieveOrderLineHistoryData(olhExtId[0], olhExtId[1], olhExtId[2]);
              }
              catch(Exception e){
              	System.debug('Order Line History Error' + e);
              	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error retrieving data from external data source.'));
                return null;
              }
            }
            return orderLineHistories;
        }    
}