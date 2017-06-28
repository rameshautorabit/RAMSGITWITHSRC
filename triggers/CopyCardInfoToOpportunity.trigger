/*******************************************************/
/*                                                     */
/*  This Trigger copies the Card info to the           */
/*  Opportunity when it is submitted.                  */
/*                                                     */
/*******************************************************/

trigger CopyCardInfoToOpportunity on Quote_Clone__c (after update) {
	
	// Declare local variables
	String					errorMessage; // An error message
	Map<Id, Opportunity>	opportunityMap; // A Map of Opportunities to be updated
	Set<Id>					opportunityIds = new Set<Id>(); // A Set of IDs of Opportunities to be updated
	Map<Id, Quote_Clone__c>	quoteClonesToProcess = new Map<Id, Quote_Clone__c>(); // A Map of Quote Clone records to process
	Opportunity				theOpportunity; // An Opportunity being processed 
	
	// Loop through the Trigger, ceating an array of Quote Clone objects that have just been submitted
	for (Quote_Clone__c qc : Trigger.new)
	{
		// If the record is newly submitted then add it to the Map
		if (qc.Submitted__c && !Trigger.oldMap.get(qc.Id).Submitted__c)
		{
			quoteClonesToProcess.put(qc.Opportunity__c, qc);
			
		} // END IF the record is newly submitted then add it to the Map
		
	} // END LOOP through the Trigger, ceating an array of Quote Clone objects that have just been submitted
	
	// If there are Opportunities to process then proceed
	if (quoteClonesToProcess.size() > 0)
	{
	
		// Get the Opportunities for the Quote Clone Items
		opportunityIds = quoteClonesToProcess.keySet();
		opportunityMap = new Map<Id, Opportunity>([SELECT Id, Card_Billing_City__c, Card_Billing_Country__c, Card_Billing_Postal_Code__c, Card_Billing_State__c,
			Card_Billing_Street__c, Card_Expiration_Month__c, Card_Expiration_Year__c, Card_Holder_Name__c, Card_Number__c FROM
			Opportunity WHERE Id IN : opportunityIds]);
		
		// Loop through the Quote Clones populating the Card info on the Opportunity
		for (Quote_Clone__c qc : quoteClonesToProcess.values())
		{
			if (qc.Opportunity__c != null && opportunityMap.containsKey(qc.Opportunity__c))
			{
				theOpportunity = opportunityMap.get(qc.Opportunity__c);
				theOpportunity.Amount_To_Be_Applied__c = qc.Amount_To_Be_Applied__c;
				theOpportunity.Card_Billing_City__c = qc.Card_Billing_City__c;
				theOpportunity.Card_Billing_Country__c = qc.Card_Billing_Country__c;
				theOpportunity.Card_Billing_Postal_Code__c = qc.Card_Billing_Postal_Code__c;
				theOpportunity.Card_Billing_State__c = qc.Card_Billing_State__c;
				theOpportunity.Card_Billing_Street__c = qc.Card_Billing_Street__c;
				theOpportunity.Card_Expiration_Month__c = qc.Card_Expiration_Month__c;
				theOpportunity.Card_Expiration_Year__c = qc.Card_Expiration_Year__c;
				theOpportunity.Card_Holder_Name__c = qc.Card_Holder_Name__c;
				theOpportunity.Card_Number__c = qc.Card_Number__c;
				theOpportunity.Second_Amount_To_Be_Applied__c = qc.Second_Amount_To_Be_Applied__c;
				theOpportunity.Second_Bill_To_City__c = qc.Second_Bill_To_City__c;
				theOpportunity.Second_Bill_To_Country__c = qc.Second_Bill_To_Country__c;
				theOpportunity.Second_Bill_To_Postal_Code__c = qc.Second_Bill_To_Postal_Code__c;
				theOpportunity.Second_Bill_To_State__c = qc.Second_Bill_To_State__c;
				theOpportunity.Second_Bill_To_Street__c = qc.Second_Bill_To_Street__c;
				theOpportunity.Second_Card_Expiration_Month__c = qc.Second_Card_Expiration_Month__c;
				theOpportunity.Second_Card_Expiration_Year__c = qc.Second_Card_Expiration_Year__c;
				theOpportunity.Second_Card_Holder_Name__c = qc.Second_Card_Holder_Name__c;
				theOpportunity.Second_Card_Number__c = qc.Second_Card_Number__c;
				
			} else {
				errorMessage = 'Quote Clone ' + qc.Id + ' is missing its Opportunity.';
				UtilityFunctions.sendEmail('Quote Clone Missing Opportunity', errorMessage, 'salesforce@restorationhardware.com');
			}
			
		} // END LOOP through the Quote Clones populating the Card info on the Opportunity
		
		// Update the Opportunities
		UtilityFunctions.databaseUpdate(opportunityMap.values(), false, 'CopyCardInfoToOpportunity.trigger');
	}
}