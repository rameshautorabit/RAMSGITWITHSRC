trigger Case_CompleteMilestone on Case (after update) {
    
    /*
     *  For all Case records, complete all active Milestones anytime a Case is closed, the OwnerId changes, 
     *  the case is put on hold, or a new Future Processing Date has been set.
     *
     */
    
    if (UserInfo.getUserType() == 'Standard') {
        
        Map<Id, Case> caseCompMilestones = new Map<Id, Case>();
        for (Case c :trigger.new) {
            if ( (c.IsClosed && trigger.oldMap.get(c.Id).IsClosed == false) ||
                 (c.OwnerId != trigger.oldMap.get(c.Id).OwnerId) ||
                 (c.On_Hold__c && trigger.oldMap.get(c.Id).On_Hold__c == false) ||
                 (c.Future_Processing_Date__c != null && trigger.oldMap.get(c.Id).Future_Processing_Date__c == null) ) {
                caseCompMilestones.put(c.Id, c);
            }
        }
        
        system.debug('*****Case_CompleteMilestone caseCompMilestones.size = ' + caseCompMilestones.size());
        
        // Make sure we don't attempt to complete milestones on a case where we have already done that in this context
        if (!caseCompMilestones.isEmpty()) {
            Map<Id, Case> casesToCompleteMap = new Map<Id, Case>();
            casesToCompleteMap = CaseTriggerHelper.checkCompletedCases(caseCompMilestones);
            
            system.debug('*****Case_CompleteMilestone casesToCompleteMap.size = ' + casesToCompleteMap.size());
            
            // Mark the Case Milestone records complete
            if (!casesToCompleteMap.isEmpty()) {
                List<CaseMilestone> cmList = new List<CaseMilestone>();
                DateTime compDate = system.now();
                
                cmList = [select Id, CaseId, CompletionDate from CaseMilestone where CompletionDate = null and CaseId in :casesToCompleteMap.keySet()];
                for (CaseMilestone cm :cmList) {
                    cm.CompletionDate = compDate;
                }
                if (!cmList.isEmpty()) {
                    update cmList;
                }
            }
        }
    }
}