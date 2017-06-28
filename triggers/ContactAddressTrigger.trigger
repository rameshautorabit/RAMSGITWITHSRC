trigger ContactAddressTrigger on Contact_Address__c (
        before insert,
        before update,
        before delete,
        after insert,
        after update,
        after delete,
        after undelete) {
    
    if (trigger.isBefore) {
    	if (trigger.isInsert || trigger.isUpdate) {
    		ContactAddressService.handleInsertOrUpdateContactAddress(trigger.new, trigger.oldMap);
    	}
    } else if (trigger.isAfter) {
    	if (trigger.isInsert || trigger.isUpdate) {
	    	List<SObject> recordsToUpdate = new List<SObject>();
	    	ContactAddressService.handleInsertedOrUpdatedContactAddress(recordsToUpdate, trigger.new, trigger.oldMap);
	    	Utility.logUpdate(Utility.compileUpdates(recordsToUpdate));
    	}
    }
}