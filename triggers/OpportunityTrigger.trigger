/* updateProjectAmount method added by Surbhi Dubey on 05/23/2017*/
trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, after update, after delete) {

    if (trigger.isBefore) {
        if (trigger.isInsert) {
            OpportunityService.creatorGallery(trigger.new);
            OpportunityService.Purchasing_DesignOwnerPopulate(trigger.new);
            /*
            for (Opportunity o :trigger.new) {
                system.debug('QUOTESYNC OpportunityTrigger isBefore/isInsert = ' + trigger.isBefore + '/' + trigger.isInsert + ' OppId = ' + o.Id + ' SyncedQuoteId = ' + o.SyncedQuoteId);
            }
            */
        }

        if (trigger.isUpdate) {
            OpportunityService.clearCardInfo(trigger.new, trigger.oldMap, trigger.isBefore);
            OpportunityService.Purchasing_DesignOwnerPopulate(trigger.new);
            /*
            for (Opportunity o :trigger.new) {
                system.debug('QUOTESYNC OpportunityTrigger isBefore/isInsert = ' + trigger.isBefore + '/' + trigger.isInsert + ' OppId = ' + o.Id  + ' SyncedQuoteId = ' + o.SyncedQuoteId + ' Old SyncedQuoteId = ' + trigger.oldMap.get(o.Id).SyncedQuoteId);
            }
            */
        }
    }

    if (trigger.isAfter) {
        if(trigger.isInsert){
            
            OpportunityService.processOpportunityAttachments(trigger.new);
            OpportunityService.updateProjectFields(trigger.new, null);
            OpportunityService.updateProjectAmount(trigger.new,null,trigger.isInsert,false);
        }
        if (trigger.isUpdate) {
            
            OpportunityService.updateProjectFields(trigger.new, trigger.oldMap);
            OpportunityService.opportunityPM(trigger.newMap, trigger.oldMap);
            OpportunityService.clearCardInfo(trigger.new, trigger.oldMap, trigger.isBefore);
            OpportunityService.setSyncingQuoteStatus(trigger.new, trigger.oldMap);
            OpportunityService.updateProjectAmount(trigger.new,trigger.oldMap,false,false);
            //OpportunityService.notifyOps(trigger.new, trigger.oldMap);

            /*
            for (Opportunity o :trigger.new) {
                system.debug('QUOTESYNC OpportunityTrigger isBefore/isInsert = ' + trigger.isBefore + '/' + trigger.isInsert + ' OppId = ' + o.Id  + ' SyncedQuoteId = ' + o.SyncedQuoteId + ' Old SyncedQuoteId = ' + trigger.oldMap.get(o.Id).SyncedQuoteId);
            }
            */
        }
        if (trigger.isDelete){
            OpportunityService.updateProjectFields(trigger.old, null);
            OpportunityService.updateProjectAmount(trigger.old, null,false,trigger.isDelete);
        }
    }
}