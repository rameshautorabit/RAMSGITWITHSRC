trigger AccountTrigger on Account (
        before insert,
        before update,
        before delete,
        after insert,
        after update,
        after delete,
        after undelete) {
    SObjectDomain.domainTriggerHandler(new Accounts());

	if (trigger.isBefore) {
		if (trigger.isInsert) {
			AccountService.vendorNumberUnique(trigger.new, null, trigger.isInsert);
		}

		if (trigger.isUpdate) {
			AccountService.vendorNumberUnique(trigger.new, trigger.oldMap, trigger.isInsert);
		}
	}

	if (trigger.isAfter) {
		if (trigger.isUpdate || trigger.isInsert) {
			if (trigger.isUpdate) {		
				AccountService.createVendorPublicGroup(trigger.new);				
			}			
			AccountService.handleInsertedUpdatedAccount(trigger.new, trigger.oldMap);
		}
	

	 	else if (trigger.isDelete) {
			AccountService.handleAfterDeleteAccount(trigger.old);
 	}
 }
}