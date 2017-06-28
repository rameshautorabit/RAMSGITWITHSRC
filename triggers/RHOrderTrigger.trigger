trigger RHOrderTrigger on RH_Order__c(
        before insert,
        before update,
        before delete,
        after insert,
        after update,
        after delete,
        after undelete)
{

    SObjectDomain.domainTriggerHandler(new RH_Orders());

    if (trigger.isBefore) {
        if(Trigger.isInsert) {
            OrderService.setOrderFieds(Trigger.New);
            OrderService.handleAddressChange(trigger.new, Trigger.oldMap);
        } else if(Trigger.isUpdate) {
            OrderService.setOrderFieds(Trigger.New);
            OrderService.handleSoldToContactChange(trigger.new, Trigger.oldMap);
            OrderService.handleAddressChange(trigger.new, Trigger.oldMap);
        }
    }

    if (trigger.isAfter) {

    	 // create a list to store all records for updating

    	 List<SObject> recordsToUpdate = new List<SObject>();

    	 // call the methods that do the work

         if(Trigger.isInsert) {
            OrderService.processDAOrders(recordsToUpdate, trigger.new,  null, trigger.isInsert);
            OrderService.gatherPersonsNeedingRollup(recordsToUpdate, Trigger.New, null, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete);
            OrderService.linkMembership(recordsToUpdate, Trigger.New, null);
            OrderService.accountTaxExemptVerification(recordsToUpdate, trigger.new, null, trigger.isInsert);
            OrderService.gatherPersonsNeedingFraudWarning(recordsToUpdate, trigger.new, null);
            OrderService.operationsRequest(recordsToUpdate, trigger.new,  null, trigger.isInsert);
            OrderService.renewMembership(trigger.new, trigger.oldMap);
            // OrderService.buildContactAddressForOrders(recordsToUpdate, trigger.new, null);
         }
         if(Trigger.isUpdate) {
           OrderService.processDAOrders(recordsToUpdate, trigger.new, Trigger.oldMap, trigger.isInsert);
           OrderService.sendEmail(recordsToUpdate, Trigger.New, Trigger.oldMap);
           OrderService.gatherPersonsNeedingRollup(recordsToUpdate, Trigger.New, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete);
           OrderService.CopyToRelatedCases(recordsToUpdate, Trigger.New, Trigger.oldMap);
           OrderService.linkMembership(recordsToUpdate, Trigger.New, Trigger.oldMap);
           OrderService.updateDNCases(recordsToUpdate, trigger.new, trigger.oldMap);
           OrderService.accountTaxExemptVerification(recordsToUpdate, trigger.new, trigger.oldMap, trigger.isInsert);
           OrderService.gatherPersonsNeedingFraudWarning(recordsToUpdate, trigger.new, trigger.oldMap);
           OrderService.operationsRequest(recordsToUpdate, trigger.new,  trigger.oldMap, trigger.isInsert);
           OrderService.renewMembership(trigger.new, trigger.oldMap);
           // OrderService.buildContactAddressForOrders(recordsToUpdate, trigger.new, null);
           OrderService.updateCCDMembership(recordsToUpdate, trigger.new, trigger.oldMap);
         }
         if(Trigger.isDelete) {
            OrderService.gatherPersonsNeedingRollup(recordsToUpdate, Trigger.Old, null, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete);
         }
         if(Trigger.isUndelete) {
            OrderService.gatherPersonsNeedingRollup(recordsToUpdate, Trigger.New, null, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete);
         }

         // process the list

         Utility.logUpdate(Utility.compileUpdates(recordsToUpdate));
    }
}