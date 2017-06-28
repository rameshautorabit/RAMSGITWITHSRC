/**

    *   Class: CaseAssignmentClass
    *   Test Class: CaseAssignmentClass_Test
    *   Description: This class transfers the ownership of a case to the current user based on criteria (Skill Set, Priority, Escalation, Client type and Last Modified Date)
    *   Author: vk@ff
    *   CHANGE LOG:
        - V0.1 07/23/2014
        - V1.0 07/24/2014 Added criteria for Escalated Cases
        - v1.1 2014/10/14 Carl Weiss/Forefront added redirect to LoadTimer to start the timer and then redirect to the page.
        - v1.2 2014/10/16 Carl Weiss/Forefront comment out LoadTimer redirect
        - v1.3 2014/11/04 Carl Weiss/Forefront added conditional timer start
        - v1.4 2014/11/26 Carl Weiss/Forefront comment out LoadTimer
        - v1.5 2014/12/02 Howard Li/ForeFront Add "FOR UPDATE" logic to prevent race conditions
        - v1.5 2014/12/11 Carl Weiss/Forefront uncomment out the commented out LoadTimer
        - v1.6 05/05/2016 Raghu Cheruvu commented out the code pertaining to Skill Set and Updating of case ownership
**/

public with sharing class CaseAssignmentClass
{
    private ApexPages.StandardsetController stdCon;
    private static List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

    public String listViewName {get; set;}
    public Boolean listViewExclusion {get; set;}
    
    public Integer listSize {
        get{
            if(stdCon != null){
                return stdCon.getResultSize();
            }
            return 0;
        }
        private set;
    }

    public void cherryPicking(){
        Set<String> cherryPickingNames = CherryPicking__c.getAll().keySet();
        if(cherryPickingNames.contains(listViewName)){
            listViewExclusion = false;
        }else{
            listViewExclusion = true;
        }
    }
    
    public CaseAssignmentClass(ApexPages.StandardsetController stdCon){
        this.stdCon = stdCon;
        listSize = stdCon.getResultSize();
        listViewName = '';
    }
    
    public PageReference findCase(){
        String dept = '';
        Set<Id> caseIdList = new Set<Id>();
        Set<String> requestCatList = new Set<String>();
        Boolean seeAllCase = false;
        Integer listSize;
        Integer pageSize;
        
        /*Commenting the below try catch block as a part of CSC Case refactoring*/
        
       /* try{
            dept = String.valueOf(stdCon.getRecords().get(0).get('Queue_Type__c'));
        }catch(Exception e){}*/
        
        /*
        for(Case c: (List<Case>)stdCon.getRecords()){
            caseIdList.add(c.Id);
        }
        */
        listSize = stdCon.getResultSize();
        stdCon.setPageSize(2000);
        pageSize = stdCon.getPageSize();
        for (Integer i=0; i<listSize; i+=pageSize) {
        	if (i == 0) {
        		stdCon.first();
        	} else {
        		stdCon.next();
        	}
        	for (Case c :(List<Case>)stdCon.getRecords()) {
        		caseIdList.add(c.Id);
        	}
        }
        
         system.debug('*****CaseAssignmentClass listSize = ' + listSize + ' pageSize = ' + pageSize + ' caseIdList.size = ' + caseIdList.size() );
        
        /*system.debug('*****CaseAssignmentClass listSize = ' + listSize + ' pageSize = ' + pageSize + ' caseIdList.size = ' + caseIdList.size() + ' dept = ' + dept);*/
        
        //Find a list of skills sets for the User
     /*   List<Skill_Set__c> skillSetList = [SELECT Request_Category__c FROM Skill_Set__c WHERE User__c =: UserInfo.getUserId() AND Active__c = true AND Queue_Type__c =: dept];
      
        for(Skill_Set__c sk: skillSetList){
            if(String.isNotBlank(sk.Request_Category__c) && (sk.Request_Category__c.equals('Callout') || sk.Request_Category__c.equals('All'))){
                seeAllCase = true;
                break;
            }else{
                requestCatList.add(sk.Request_Category__c);
            }
        }*/
   
        List<CaseAssignmentCriteria__c> caseSortCriteria = [SELECT Case_Field__c FROM CaseAssignmentCriteria__c ORDER BY Order__c];

        
        String query = 'SELECT Id, OwnerId, CaseNumber FROM Case WHERE Id IN: caseIdList';
        
    /*    if(!seeAllCase)query += ' AND Request_Category__c IN: requestCatList';*/
        
        if(!caseSortCriteria.isEmpty()){
            query += ' ORDER BY ';
            
            for(CaseAssignmentCriteria__c caseSort: caseSortCriteria){
                query += caseSort.Case_Field__c + ', ';
            }
        }
        query = query.removeEnd(', ');
        query += ' LIMIT 10';
      /*  System.debug('*****CaseAssignmentClass query = ' + query + ' requestCatList = ' + requestCatList);*/
      
      System.debug('*****CaseAssignmentClass query = ' + query );
        
        List<Case> caseList = Database.query(query);
        System.debug('*****CaseAssignmentClass caseList: ' + caseList);
        if (!caseList.isEmpty()) {
                for (Case c1: caseList) {
                Case c = [select OwnerId, Status, CaseNumber, CaseAssignment__c FROM Case WHERE Id =: c1.Id];
                // add the filter for public group membership.....
                if(c.OwnerId!=null){
               return new PageReference('/' + c.Id);
               
               }
            }
            
       return null;
		} 
		
		else {
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, 'NO CASE FOUND'));
			return null;
		}
    }
    
    //Update the case
    //If an error was encountered, send an email to the User and the email 
    //addresses specificied in the Case Notification Email custom setting
  /*  private static Boolean UpdateCaseOwner(Case c)
    {       
        try{
            update c;
        }catch(DmlException e){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'There was an error updating the Case, your system administrator was notified. Error = ' + e.getMessage()));
            sendCaseErrorEmail(e.getMessage(),c.CaseNumber);
            return false;
        }
        return true;
    }*/
    
   /* public static void sendCaseErrorEmail(String errorMessage, String caseNumber){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
        List<String> toAddress = new List<String>();
        if([SELECT To_Address__c FROM CaseNotificationEmail__c WHERE Name='Get a Case Error Notification'].To_Address__c != null){
            toAddress = new List<String>{[SELECT To_Address__c FROM CaseNotificationEmail__c WHERE Name='Get a Case Error Notification'].To_Address__c};
        }
            
        if([SELECT To_Address__c, Notify_Current_User__c FROM CaseNotificationEmail__c WHERE Name='Get a Case Error Notification'].Notify_Current_User__c){
            toAddress.add(UserInfo.getUserEmail());
        }
            
        mail.setToAddresses(toAddress);
        if([SELECT CC_Address__c FROM CaseNotificationEmail__c WHERE Name='Get a Case Error Notification'].CC_Address__c != null){
            mail.setCcAddresses(new List<String>{[SELECT CC_Address__c FROM CaseNotificationEmail__c WHERE Name='Get a Case Error Notification'].CC_Address__c});
        }
        mail.setSubject('Error Updating Case');
        mail.setPlainTextBody('Case ' + caseNumber + ' encountered an error while updating. \r\n ERROR MESSAGE: ' + errorMessage);
        emailList.add(mail);
    }*/
}