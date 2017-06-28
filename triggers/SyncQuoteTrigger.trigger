/*************************************************************/
/*                                                           */
/*  This Trigger Calls the Class to Sync Quote records with  */
/*  the custom Quote object.                                 */
/*                                                           */
/*************************************************************/

trigger SyncQuoteTrigger on Quote (before delete, after insert, after undelete, 
after update) {
	
	// Declare Local variables
	Map<Id, Quote>	records = new Map<Id, Quote>(); // The records to be passed into the class to sync
	String			triggerEvent; // The event of the Trigger.
	
	// Get the array of records for the class
	if (Trigger.isDelete)
	{
		records = Trigger.oldMap;
	} else {
		records = Trigger.newMap;
	}
	
	// Set the event for the Trigger
	if (Trigger.isInsert)
	{
		triggerEvent = 'Insert';
	} else if (Trigger.isUpdate) {
		triggerEvent = 'Update';
	} else if (Trigger.isDelete) {
        for(Quote q: trigger.old){
            triggerEvent = 'Delete';
            Opportunity opp = [SELECT StageName from Opportunity WHERE id = :q.Opportunityid];        
            System.debug('Oppportunity Stage='+opp.StageName);
            
            if(opp.StageName == 'Closed Won'){
                //Don't delete                    
                q.addError('Quotes for which payment has been made cannot be deleted.');
                system.debug(q.id + ' was not deleted in SyncQuoteTrigger' );
            }           
        }
        
	} else {
		triggerEvent = 'Undelete';
	}
	
    
    
	// Call the class to sync the Quotes
	SyncQuotes sq = new SyncQuotes();
	System.debug('Calling SyncQuotes Class with ' + records.size() + ' records: ' + records);
	sq.syncQuotes(triggerEvent, records);

}