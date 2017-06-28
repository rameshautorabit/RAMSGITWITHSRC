public with sharing class Order_RHOMNotesIntCtrlExt {
	
	private final RH_Order__c rhOrder;
	RH_Order__c theRHOrder = new RH_Order__c();
	List<OrderRHOMNote> orderRHOMNotes = new List<OrderRHOMNote>();
                  
    public Order_RHOMNotesIntCtrlExt(ApexPages.StandardController stdController){
    
       	this.rhOrder = (RH_Order__c)stdController.getRecord();
       	theRHOrder = [Select EXT_Order_Number__c from RH_Order__c where Id =: this.rhOrder.Id];

       	System.debug('Ext Order Id: ' + theRHOrder.EXT_Order_Number__c);
    }

	public List<OrderRHOMNote> getOrderRHOMNoteList(){
       
		if (orderRHOMNotes.size()==0) {
        	try{       
        		orderRHOMNotes = CWCalloutService.retrieveOrderRHOMNoteData(theRHOrder.EXT_Order_Number__c);
              }
              catch(Exception e){
              	System.debug('Order RHOM Notes Error' + e);
              	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error retrieving data from external data source.'));
                return null;
              }
            }
            return orderRHOMNotes;
        }    
}