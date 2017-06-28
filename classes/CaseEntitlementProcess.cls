/***************************************************************************************
    CLIENT
        Restoration Hardware
            
    PURPOSE
        When the user changes the status of a case, set the current active case milestone to have
        a completed date of now(), which effectively completes the case milestone.

    TEST CLASS
        caseEntitlementProcess_Test
        
    ENTRY POINTS
        CaseTrigger                    
    
    CHANGE LOG
        [[Version; Date; Author; Description]]
        v1.0; 2014/08/01; Ryan Cerankowski/Forefront;
***************************************************************************************/

public class CaseEntitlementProcess{
   /* public static void completeMilestone(Map<Id,CaseMilestone> caseMilestones){
        //System.debug('Howard ' + milestones);
        System.debug('Ryan Test2: ' + caseMilestones);
        
        for(CaseMilestone cm : caseMilestones.values()){
                cm.CompletionDate = dateTime.now();
        }
        
        update caseMilestones.values();  
          
    }
    
    public static void caseMilestoneList(Map<Id,Case> cases){
        System.debug('Ryan Test: ' + cases.size());
        //Set<String> exemptStatuses = new Set<String>{'Working'};
        
        List<CaseMilestone> milestones = new List<CaseMilestone>(
        [SELECT CaseId, IsCompleted FROM CaseMilestone WHERE
        CaseId in : cases.keySet() AND IsCompleted = false]);
        
        for(CaseMilestone cm : milestones)
        {
        //    if(!exemptStatuses.contains(cases.get(cm.CaseId).Status)){
                ValidatorClass.caseMilestoneMap.put(cm.Id, cm);
        //    }
            
        }
        
    
            
            
    }*/
}