public with sharing class ProjectService {
    
    public static void associateConvertedOpportunityToNewlyCreatedProject(List<Project__c> newList){
        
        Map<Id,Id> opptyProjMap = new Map<Id, Id>();
        List<Id> updateOpptyIds = new List<Id>();
        List<Opportunity> updateOpptys = new List<Opportunity>();
        
        for(Project__c p: newList){
            if(!String.isBlank(p.Opportunity_Id__c)){
                Id opptyId = Id.valueOf(p.Opportunity_Id__c);
                opptyProjMap.put(opptyId, p.Id);
                updateOpptyIds.add(opptyId);
            }
            
            System.debug('opptyProjMap: ' + opptyProjMap);
            System.debug('updateOpptyIds: ' + updateOpptyIds);  
        }
        
        if (!opptyProjMap.isEmpty()) {
            for (Opportunity o : [select Id, Parent_Project__c from Opportunity where Id in :updateOpptyIds]) {
                if (opptyProjMap.containsKey(o.Id)) {
                    o.Parent_Project__c = opptyProjMap.get(o.Id);
                    updateOpptys.add(o);
                }
            }   
        }
        
        System.debug('updateOpptys: ' + updateOpptys);
        
        Utility.logUpdate(updateOpptys);
    }
}