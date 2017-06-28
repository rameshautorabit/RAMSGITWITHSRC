public with sharing class Order_NotesIntCtrlExt {
	
	private final RH_Order__c rhOrder;
	RH_Order__c theRHOrder = new RH_Order__c();
	List<CW_Order_Note__x> orderNotes = new List<CW_Order_Note__x>();
                  
    public Order_NotesIntCtrlExt(ApexPages.StandardController stdController){
    
       	this.rhOrder = (RH_Order__c)stdController.getRecord();
       	theRHOrder = [Select EXT_Order_Number__c from RH_Order__c where Id =: this.rhOrder.Id];

       	System.debug('Ext Order Id: ' + theRHOrder.Ext_Order_Number__c);
    }

	public List<CW_Order_Note__x> getOrderNotesList(){
       
		if (orderNotes.size()==0) {
        	try{       
            	//orderNotesList = [SELECT Date__c, Message__c, Message_Type__c, Order_Number__c, Sequence_Number__c, Ship_To__c, User__c FROM CW_Order_Note__x where Order_Number__c = :theRHOrder.Ext_Order_Number__c];
                orderNotes = CWConnection.getCWOrderNotesAllFields(theRHOrder.Ext_Order_Number__c);  
              }
              catch(Exception e){
              	System.debug('Order Notes Error' + e);
              	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error retrieving data from external data source.'));
                return null;
              }
            }
            return orderNotes;
        }    
}