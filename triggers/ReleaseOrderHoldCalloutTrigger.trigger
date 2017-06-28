/*Trigger that is activated when a Case of type Reorder has its Status set to Call for Pick*/


trigger ReleaseOrderHoldCalloutTrigger on Case (after update) {

    
    List<Case> caseList = new List<Case>();
    List<Id> caseIds = new List<Id>();
    List<Case> caseUpList = new List<Case>();
    
        
    for (Case c : Trigger.new) 
    {
        //Collect previous and current values for key fields Status and HTTP POST In Progress (not on page layout)
        
        Case oldCase = Trigger.oldMap.get(c.Id);
         
        //Boolean oldCaseIsCallForPick = oldCase.Status.equals('Call for Pick');
        //Boolean newCaseIsCallForPick = c.Status.equals('Call for Pick');
        
        Boolean oldCaseIsCallForPick = false;
        if (oldCase.Status == 'Call for Pick') {
        	oldCaseIsCallForPick = true;
        }
        Boolean newCaseIsCallForPick = false;
        if (c.Status == 'Call for Pick') {
        	newCaseIsCallForPick = true;
        }
        
        Boolean oldCaseIsHTTPInProgress = oldCase.HTTP_POST_In_Progress__c;
        Boolean newCaseIsHTTPInProgress = c.HTTP_POST_In_Progress__c;
        
        //Gather relevant Cases for processing - of type 'Reorders', Order Number cannot be null, Status must have changed to 'Call for Pick', both the old and current version must not have HTTP POST In Progress flag set
        
        if (c.Record_Type_Dev_Name__c =='Reorders' && c.RH_Order_Number__c != null && !oldCaseIsCallForPick && newCaseIsCallForPick && !oldCaseIsHTTPInProgress && !newCaseIsHTTPInProgress)    
                { 
                caseList.add(c);
                caseIds.add(c.Id);
                }
     }          
                
     //Set the HTTP POST In Progress flag to TRUE for the relevant Cases
     
     for (Case CROH :caseList) 
     {                      
        caseUpList.add(new Case(
        Id = CROH.Id,
        HTTP_POST_In_Progress__c = True)
        );
     } 
     
     //Update the relevant Cases  
     if(!caseUpList.isEmpty()){
     update caseUpList;
     }
     
     //Pass the Ids of the relevant Cases through to the ReleaseOrderHoldWebServiceCallout class for processing
     if(!caseIds.isEmpty()){
     ReleaseOrderHoldWebServiceCallout.sendNotification(caseIds);
     } 
     
}