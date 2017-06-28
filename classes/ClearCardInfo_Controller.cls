/*****************************************************************/
/*                                                               */
/*  This class clears all Credit Card info from an Opportunity   */
/*  and its Quote Clone object.                                  */
/*                                                               */
/*****************************************************************/

public class ClearCardInfo_Controller {
	
	// Declare Class Variables
	public Opportunity 	theOpportunity {get; set;} // The Opportunity on the calling Visualforce page
    public String		errorMessage {get; set;} // An error message from the update of Quote Clobe Objects
    
    public ClearCardInfo_Controller(ApexPages.StandardController controller)
    {
        this.theOpportunity = (Opportunity) controller.getRecord();    
        this.errorMessage = '';    
    }
    
    public PageReference clearCardInfo ()
	{
		// Declare Local Variables
		List<Quote_Clone__c>	qcList = new List<Quote_Clone__c>(); // The List of Quote Clone objects
		
		// Clear the Opportunity card number field
		theOpportunity.Card_Expiration_Month__c = null;
		theOpportunity.Card_Expiration_Year__c = null;
		theOpportunity.Card_Number__c = null;
		theOpportunity.Second_Card_Expiration_Month__c = null;
		theOpportunity.Second_Card_Expiration_Year__c = null;
		theOpportunity.Second_Card_Number__c = null;
		
		// Set the Card Info Cleared fields
		theopportunity.Card_Info_Cleared_Date_Time__c = System.now();
		theOpportunity.Card_Info_Cleared_By__c = UserInfo.getUserId();
		
		// Update the Opportunity
		try
		{
			update theOpportunity;
		} catch (Exception e) {
			UtilityFunctions.sendError('Failure to Clear Credit Card Data', e, new List<String>{'marc.friedman@cadalys.com','tgibson@restorationhardware.com'});
		}
		
		// Get the Quote Clone objects. There should only ever be one, but since the database
		// can support multiples we will be on the safe side and select as many as exist
		qcList = [SELECT Id, Card_Expiration_Month__c, Card_Expiration_Year__c, Card_Number__c
			FROM Quote_Clone__c WHERE Opportunity__c = :theOpportunity.Id];
		
		// Loop through the records clearing the card fields and setting the Card Info Cleared fields
		for (Quote_Clone__c qc : qcList)
		{
			qc.Card_Expiration_Month__c = null;
			qc.Card_Expiration_Year__c = null;
			qc.Card_Number__c = null;
			qc.Second_Card_Expiration_Month__c = null;
			qc.Second_Card_Expiration_Year__c = null;
			qc.Second_Card_Number__c = null;
			qc.Card_Info_Cleared_Date_Time__c = System.now();
			qc.Card_Info_Cleared_By__c = UserInfo.getUserId();
		}
		
		// Update the Quote Clone Items
		List<Database.Saveresult> lsr = UtilityFunctions.databaseUpdate(qcList, false, 'ClearCardInfo_Controller');
		for (integer i = 0; i < lsr.size(); i++)
		{
			if (!lsr[i].isSuccess())
			{
				errorMessage += 'Failed to clear card data for Quote Clone ' + qcList[i].Id + '.' + '\n\r';
				
				// Loop through the error messages adding them to the main message
    			for (Database.error de : lsr[i].getErrors())
    			{
    				errorMessage += de.getMessage() + ';\n\r';
    			}
			}
		}
		
		// If there are errors, send an email to the admins.
		if (errorMessage.length() > 0)
		{
			UtilityFunctions.sendEmail('Failure to Clear Credit Card Data', errorMessage, new List<String>{'marc.friedman@cadalys.com', 'tgibson@restorationhardware.com'});
		}
		
		// Return the URL for the Opportunity
		return new PageReference('/' + theOpportunity.Id);
	}
}