trigger QuestionnaireUpdate on Lead (after update) {
    
  List<Questionnaire_Implementation__c> updateQuestions = new List<Questionnaire_Implementation__c>();
  map<id,id> leadCOnvertedOptyId = new Map<id,id>();
  For (Lead l : Trigger.new)
       {
             if (l.isConverted && l.convertedOpportunityId != null)
             {
                      leadCOnvertedOptyId.put(l.id, l.convertedOpportunityId);
             }
       }
  
  List<Questionnaire_Implementation__c> questionObjList = [select id,Lead__c,Opportunity__c from Questionnaire_Implementation__c where Lead__c in : leadCOnvertedOptyId.keyset()]; 
  system.debug('@@'+questionObjList); 
  if(questionObjList.size()>0)
  {
    for(Questionnaire_Implementation__c questObj: questionObjList){
        
         questObj.Opportunity__c = leadCOnvertedOptyId.get(questObj.Lead__c);
           updateQuestions.add(questObj);
            }
        }
        
        update updateQuestions;
    }