trigger ContactTrigger on Contact (
        before insert,
        before update,
        before delete,
        after insert,
        after update,
        after delete,
        after undelete) {
        	
    SObjectDomain.domainTriggerHandler(new Contacts());
    
    if(trigger.isAfter) {
    	if (trigger.isInsert || trigger.isUpdate) {
    		ContactService.handleInsertedUpdatedContact(trigger.new, trigger.oldMap);
    	} else if (trigger.isDelete) {
    		ContactService.handleAfterDeleteContact(trigger.old);
    	}
    }
    
}