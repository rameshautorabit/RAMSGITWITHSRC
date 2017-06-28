trigger DesignAtelierQuoteTrigger on Design_Atelier_Quote__c (after insert) {
	
	Set<String> daqQuoteIds = new Set<String>();
	List<Design_Atelier_Quote__c> ToBeDeleted = new List<Design_Atelier_Quote__c>();
	
	// Collect a set of unique Quote Ids of DAQ records inserted
	for (Design_Atelier_Quote__c daq : Trigger.new) {
    	daqQuoteIds.add(daq.Quote_Id__c);
    }
	
	//  Gather DAQ records that have a Quote Id that is on the list of those inserted but where the record id is not part of the trigger => preexisting  
	for(Design_Atelier_Quote__c daq : [SELECT Id FROM Design_Atelier_Quote__c WHERE Quote_Id__c in: daqQuoteIds AND (Id NOT IN: Trigger.newMap.keyset())]){
    	ToBeDeleted.add(daq);
   	}
    
    // Delete preexisting records 
	if(ToBeDeleted.size() > 0){
		//System.debug('To be deleted: '+ ToBeDeleted);
    	delete ToBeDeleted;   	
	}
}