trigger IssueTrigger on Issue__c (after insert, after update) {
    
    if (trigger.isAfter){   
        if (trigger.isInsert){
            IssueService.processIssueSharing(trigger.new, trigger.isInsert);
            IssueService.contractCaseStatus(trigger.new);
        }
        if (trigger.isUpdate){
            IssueService.processIssueSharing(trigger.new, trigger.isInsert);
        }   
    }
}