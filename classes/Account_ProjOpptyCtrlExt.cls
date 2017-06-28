public with sharing class Account_ProjOpptyCtrlExt {   
    
    private final Account rhAccount;
    List<Project__c> projects = new List<Project__c>();
    List<Opportunity> orphanOpportunities = new List<Opportunity>();

    public Account_ProjOpptyCtrlExt(ApexPages.StandardController stdController) {
        this.rhAccount = (Account)stdController.getRecord();
    }
    
    public List<Project__c> getProjects(){
        projects = [Select Id, Name, Total_Project_Budget__c, Total_Project_Amount__c, (Select Id, Name, StageName, Amount, Project_Budget__c, CloseDate, Installation__c, Final_Opportunity_Number__c, PO__c, Order_Number__c from Opportunities1__r) from Project__c where Account__c = :this.RhAccount.Id];   
        return projects;
    }
        
    public List<Opportunity> getOrphanOpportunities(){
        orphanOpportunities = [Select Id, Name, StageName, Amount, Project_Budget__c, CloseDate, Installation__c, Final_Opportunity_Number__c, PO__c, Order_Number__c from Opportunity where Account.Id = :this.RhAccount.Id and Parent_Project__c = null];
        return orphanOpportunities;
    }
}