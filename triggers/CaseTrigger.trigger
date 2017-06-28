/*
    Purpose: Case Trigger checks for case statuses and adds case records in list/map to kickoff assignments, set pop alert messages,
             Stop milestones, default entitlement on a case, lock case and case lines when a case is closed/ reopened, populate order info on a case, 
             set action required field on Case and reopen the case, default the transfer and To fields for certain record types.
             Trigger calls the methods in the Apex Class UpdateCase to implement the above functionality.
             
    Authors: VK,RC,SP,HL,CW -Forefront, Peter Alexander Mandy (Rewrite on 03.02.2016).
             
    Entry points: After Insert, After Update, Before Insert and Before Update of Case
*/
trigger CaseTrigger on Case(after insert, after update, before update, before insert)
{
   if(Trigger.isInsert){
      if(Trigger.isBefore){
         CaseService.processEmailWebOrderNumber(Trigger.New);
         CaseService.populateOrderInformation(Trigger.New, Trigger.oldMap, Trigger.isInsert);
         CaseService.updateCaseStatusTransfer(Trigger.New);
         CaseService.populateOpportunityPM(Trigger.New, Trigger.oldMap, Trigger.isInsert);
         //CaseService.membershipAutoRenewalOrder(trigger.new, null, trigger.isInsert);
      }
      if(Trigger.isAfter){
         CaseService.processDeclinedCreditCardCases(Trigger.New);
      }
   }
   if(Trigger.isUpdate){
      if(Trigger.isBefore){
         CaseService.populateOrderInformation(Trigger.New, Trigger.oldMap, Trigger.isInsert);
         CaseService.defaultCaseFields(Trigger.New, Trigger.oldMap);
         CaseService.populateOpportunityPM(Trigger.New, Trigger.oldMap, Trigger.isInsert);
         CaseService.verifyCaseTransfer(trigger.newMap, trigger.oldMap);
         CaseService.verifyCaseClose(trigger.new, trigger.oldMap);
         //CaseService.membershipAutoRenewalOrder(trigger.new, trigger.oldMap, trigger.isInsert);
      }
      if(Trigger.isAfter){
         if(!TriggerStopper.stopCase){
            CaseService.processCaseLocks(Trigger.New, Trigger.oldMap);
            CaseService.processCaseUnlocks(Trigger.New, Trigger.oldMap);
            CaseService.creditCardDecline(Trigger.newMap, Trigger.oldMap);
            CaseService.decrementReorderCount(Trigger.newMap, Trigger.oldMap);
            TriggerStopper.stopCase = true;
         }     
      }
   }
}