/***************************************************************************************
    CLIENT
        Restoration Hardware
            
    PURPOSE
        Create a timer entry to track cases that are Transfered back to the queue.

    TEST CLASS
        CaseTimerEntries_TEST
         
    ENTRY POINTS
        CaseTrigger              
    
    CHANGE LOG
        [[Version; Date; Author; Description]]
        v0.1; 2014/11/03; Carl Weiss/Forefront; Initial Build
        Peter Alexander Mandy 03.02.2016 17:06:22.84 - refactored code, removed SOQL FROM for Loop and combined all sources into single collection.
***************************************************************************************/
public with sharing class CaseTimerEntries {

  /*  public static void CreateTransferTimerEntry(Map<String, Map<Id, Case>> sourceCases)
    {
        Set<Id> setCaseIds = new Set<Id>();
        for(String source:sourceCases.keySet()){
           setCaseIds.addAll(sourceCases.get(source).keySet());
        }    
        List<Timer_Entry__c> relatedCaseTimers = new List<Timer_Entry__c>();
        List<Timer_Entry__c> te = [SELECT id, CreatedById, Case__c 
                                     FROM Timer_Entry__c
                                    WHERE Case__c in :setCaseIds  
                                      AND EndTime__c = null];
        Set<Id> timerIds = new Set<Id>();                            
        for(String source:sourceCases.keySet()){    
           for (Timer_Entry__c t : te){    
              if(sourceCases.get(source).containsKey(t.Case__c)
                 && t.CreatedById == sourceCases.get(source).get(t.Case__c).LastModifiedById
                 ){
                     if(sourceCases.get(source).get(t.Case__c).Future_Processing_Date__c != null 
                        && source == 'Transfer Back'){
                        t.Source__c = 'Future Process';
                     }else{
                        t.Source__c = source;
                     }
                     if(!timerIds.Contains(t.Id)){
                        relatedCaseTimers.add(t);              
                        timerIds.add(t.Id);
                     }
                  }
            }      
         }
        
        if (!relatedCaseTimers.isEmpty()){
            update relatedCaseTimers;
        }
    }*/
}