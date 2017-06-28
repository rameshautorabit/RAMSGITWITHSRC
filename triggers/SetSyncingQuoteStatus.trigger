/***************************************************************************/
/*                                                                         */
/*  This Trigger sets the Status on the syncing Quote if the Opportunity   */
/*  reaches a given Stage.                                                 */
/*                                                                         */
/***************************************************************************/

trigger SetSyncingQuoteStatus on Opportunity (after update) {
/*	
	// Declare local variables
	Set<Id>	opportunityIds = new Set<Id>(); // A Set of Ids of Opportunities in the given Stage
	String	stage; // The Stage on which the syncing Quote's Status should be set
	
	// Get the Stage
	stage = Application_Settings__c.getInstance('QuoteCloneStatusToCreatePortalUser').Value_Text__c;
	
	// Loop through the Opportunities, adding the IDs to the Set if they have reached the given Stage
	for (Opportunity o : Trigger.new)
	{
		
		// If the Stage Name has change from something else to the given stage, add the ID to the array
		if (o.StageName == stage && Trigger.oldMap.get(o.Id).StageName != stage)
		{
			opportunityIds.add(o.Id);
		} // END IF the Stage Name has change from something else to the given stage, add the ID to the array
		
	} // END LOOP through the Opportunities, adding the IDs to the Set if they have reached the given Stage
	
	// If there are IDs then pass them into the Class for processing
	if (opportunityIds.size() > 0)
	{
		SetQuoteStatusFromOpportunity.setQuoteStatusFromOpportunity(opportunityIds);
	}
*/
}