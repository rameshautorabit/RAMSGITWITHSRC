/*
Class:          CreateCoachingCaseClass
Page:           CreateCoachingCasePage
Test Class:     CreateCoachingCaseClass_Test
Description:    Used to Create a coaching case. This page is navigated to, parent case is created and then redirected back to the case page.
Dev:            Chris Del Fattore / ForeFront Corp. / October 3, 2014
*/
public with sharing class CreateCoachingCaseClass {

   public Id ccaseId {get;set;}
    public Case parentCase {get;Set;}
    public Case coachingCase {get;Set;}

    public CreateCoachingCaseClass() 
    {
        coachingCase=new Case();
    }

    public PageReference createCoachingCase() 
    {
        //query for the parent case
        
        System.debug(ApexPages.currentPage().getParameters());
        
        List<String> paramSplit=ApexPages.currentPage().getParameters().values();
        List<String> idSplit=paramSplit.get(0).split('=');
        String parCaseId=idSplit.get(0);
                
        //String parCaseId = ApexPages.currentPage().getParameters().get('id');
                
        System.debug(parCaseId);
        parentCase = [SELECT Id, RH_Order_Number__c, Sold_To_Name__c, Record_Type_Dev_Name__c, Send_to_First_Name__c, Send_to_Last_Name__c, Sold_to_First_Name__c, Sold_to_Last_Name__c FROM Case where Id = :parCaseId LIMIT 1];
        System.debug(parentCase);
        
        //create the coaching case and relate it to the parent case
        //Case coachingCase = new Case();
        coachingCase.ParentId = parentCase.Id;
        coachingCase.RH_Order_Number__c = parentCase.RH_Order_Number__c;
        coachingCase.Sold_To_Name__c = parentCase.Sold_To_Name__c;
        //System.debug(parentCase.Record_Type_Dev_Name__c);
        //coachingCase.Record_Type_Dev_Name__c = parentCase.Record_Type_Dev_Name__c;
        
       
        /*coachingCase.Sold_to_First_Name__c = parentCase.Sold_to_First_Name__c != '' ? parentCase.Sold_to_First_Name__c : parentCase.Send_to_First_Name__c;
        coachingCase.Sold_to_Last_Name__c = parentCase.Sold_to_Last_Name__c != '' ? parentCase.Sold_to_Last_Name__c : parentCase.Send_to_Last_Name__c;*/

        
        //get the recordtypeId for the coaching case
        //
        // Peter Alexander Mandy discussion with Stuart Thompto to comment out this code for now.  We will deprecate this later.
        //
        //RecordType coachingRecTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Coaching' LIMIT 1];
        //coachingCase.RecordTypeId = coachingRecTypeId.Id;
        //System.debug(coachingCase);

        System.debug(coachingCase);
        try {
            insert coachingCase;            
        } catch (DmlException e) {
            System.debug('DML Exception: ' + e.getMessage());
        }
        
        ccaseId=coachingCase.Id;
        //PageReference pageRef = new PageReference('/'+coachingCase.Id+'/e?retURL=%2F'+coachingCase.Id);
        
        PageReference pageRef = new PageReference('/'+coachingCase.Id);
        pageRef.setRedirect(true);
        return pageRef;
        
    }
}