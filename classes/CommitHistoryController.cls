public with sharing class CommitHistoryController {
    
    @AuraEnabled
    public static List<Commit_History__c> getCommitHistory(){
        List<Commit_History__c> commitHistoryList = [select id, createddate, Name, Ez_Commit_Label__c, Createdby.name, Comment__c, Target_Repository__c, Branch__c, Work_Story__c,Sprint__c from Commit_History__c];
        System.debug('getCommitHistory return list==' + commitHistoryList);
        
        return commitHistoryList;
    }

}