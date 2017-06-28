public without sharing class SalesAttributionService {
    
    public static void populateAttributionName(List<Sales_Attribution__c> newList) {
		
		List<String> attributionIDs = new List<String>();
		Map<String, Sales_Attribution__c> attribUserAttribIdMap = New Map<String, Sales_Attribution__c>();
		List<Sales_Attribution__c> SAtoUpdateList = new List<Sales_Attribution__c>();		
		List<Sales_Attribution__c> SAUpdateList = new List<Sales_Attribution__c>();
		
		System.debug('New Trigger: ' + newList);
		
		// Gather list of Attribution Ids to use to find relevant users.
		// Make map of Attribution Ids and associated Sales Attribution records. 
		
		for (Sales_Attribution__c sa :newList) {
			if(!String.isEmpty(sa.Attribution_Id__c)){
				attributionIds.add(sa.Attribution_ID__c);
				attribUserAttribIdMap.put(sa.Attribution_ID__c.toLowerCase(), sa);
			}
			
			System.debug('Attribution Ids: ' + attributionIds);
			System.debug('AttributionIdMap: ' + attribUserAttribIdMap);
		}
		
		// For User records with Associate Ids that match Attribution Id entries in list of Attribution Ids get
		// the corresponding Sales Attribution record and set the Associate Name to be equal to the User Name.
		// Add this Sales Attribution record to the SAtoUpdateList to be updated.
		
		if(!attribUserAttribIdMap.isEmpty()){
			for (User u: [SELECT Name, Associate_ID__c, Id FROM User WHERE Associate_ID__c IN :attributionIDs]){
				if(attribUserAttribIdMap.containsKey(u.Associate_ID__c.toLowerCase())){
				
					Sales_Attribution__c SAtoUpdate = new Sales_Attribution__c();
					
					SAtoUpdate = attribUserAttribIdMap.get(u.Associate_ID__c);
					SAtoUpdate.Associate_Name__c = u.Id;
					
					System.debug('SAtoUpdate: ' + SAtoUpdate);
				}
			}
		}
  	}
}