/********************************************************************************/
/*                                                                              */
/*  This Class sets the syncing Quote's Status based on the Opportunity Stage.  */
/*                                                                              */
/********************************************************************************/

public with sharing class SetQuoteStatusFromOpportunity {
/*	
	public static void setQuoteStatusFromOpportunity (Set<Id> opportunityIds)
	{
		// Declare local variables
		List<Quote>	quotes = new List<Quote>(); // The Syncing Quotes to have their Statuses Changed
		String		status; // The status to set the Quotes
		
		// Get the Quote status from the Custom Setting
		status = Application_Settings__c.getInstance('QuoteCloneStatusToCreatePortalUser').Value_Text__c;
		
		// Loop through the Syncing Quotes for the Opportunities, setting the Status
		for (Quote q : [SELECT Id, Status FROM Quote WHERE IsSyncing = true AND OpportunityId IN :opportunityIds])
		{
			q.Status = status;
			quotes.add(q);
		} // END LOOP through the Syncing Quotes for the Opportunities, setting the Status
		
		// Update the Quotes
		UtilityFunctions.databaseUpdate(quotes, false, 'SetQuoteStatusFromOpportunity');
	}
*/
}