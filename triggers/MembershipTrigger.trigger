trigger MembershipTrigger on Membership__c (before insert, after insert, before update, after update) {

   TriggerManager__c orgVal = TriggerManager__c.getOrgDefaults();
   TriggerManager__c profileVal = TriggerManager__c.getInstance(UserInfo.getProfileId());
        
   if(Test.isRunningTest() || orgVal.runMembershipTriggers__c || (profileVal != null && profileVal.runMembershipTriggers__c)){ 
    
      if(Trigger.isBefore){
         if(Trigger.isInsert){         
           	MembershipService.SetDefaults(Trigger.New, Trigger.oldMap);
            MembershipService.validationRules(Trigger.New, null);
            MembershipService.quebecoisCheck(Trigger.New);
            MembershipService.logiqueDesQuebecois(Trigger.New, null);
         }
         if(Trigger.isUpdate){
            if(!TriggerStopper.stopMembership){
				MembershipService.SetDefaults(Trigger.New, Trigger.oldMap);              
				MembershipService.validationRules(Trigger.New, Trigger.oldMap);
            }
            MembershipService.logiqueDesQuebecois(Trigger.New, Trigger.oldMap);
            MembershipService.quebecoisCheck(Trigger.New);
         }      
      }
      if(Trigger.isAfter){
         if(Trigger.isInsert){ 
            MembershipService.setMemberNumber(Trigger.New);
            MembershipService.attachEmail(Trigger.New, null);
         }
         if(Trigger.isUpdate){
            if(!TriggerStopper.stopMembership){
               MembershipService.attachEmail(Trigger.New, Trigger.oldMap);
            }
            MembershipService.monitorEligibleForMemberBenefits(Trigger.New, Trigger.oldMap);
            MembershipService.handleMembershipContactChange(Trigger.new, Trigger.oldMap);
         }
      }
      
   }
   
}