trigger ClearCardInfo on Opportunity (before update) {
/*	
	// Declare Local Variables
	Set<Id> 					oppIds = new Set<Id>(); // Set of Opportunity Ids
	List<Quote_Clone__c>		qcList = new List<Quote_Clone__c>(); //List of Quote Clone records
	
	for (Opportunity opp : Trigger.new) {
		if (opp.Order_Number__c != null && opp.Order_Number__c != Trigger.oldMap.get(opp.Id).Order_Number__c){
			oppIds.add(opp.Id);
			
			// Clear the Opportunity card number field
			opp.Card_Expiration_Month__c = null;
			opp.Card_Expiration_Year__c = null;
			opp.Card_Number__c = null;
			opp.Second_Card_Expiration_Month__c = null;
			opp.Second_Card_Expiration_Year__c = null;
			opp.Second_Card_Number__c = null;
			
			// Set the Card Info Cleared fields
			opp.Card_Info_Cleared_Date_Time__c = System.now();
			opp.Card_Info_Cleared_By__c = UserInfo.getUserId();
		}
	}
	
	if (!oppIds.isEmpty()) {
		qcList = [
			SELECT Id, Card_Expiration_Month__c, Card_Expiration_Year__c, Card_Number__c,
				Second_Card_Expiration_Month__c, Second_Card_Expiration_Year__c, Second_Card_Number__c,
				Card_Info_Cleared_Date_Time__c, Card_Info_Cleared_By__c
			FROM Quote_Clone__c
			WHERE Opportunity__c IN :oppIds
		];
	}
	
	for (Quote_Clone__c qc : qcList) {
		qc.Card_Expiration_Month__c = null;
		qc.Card_Expiration_Year__c = null;
		qc.Card_Number__c = null;
		qc.Second_Card_Expiration_Month__c = null;
		qc.Second_Card_Expiration_Year__c = null;
		qc.Second_Card_Number__c = null;
		qc.Card_Info_Cleared_Date_Time__c = System.now();
		qc.Card_Info_Cleared_By__c = UserInfo.getUserId();
	}
	
	if (!qcList.isEmpty()) {
		update qcList;
	}
*/	
}