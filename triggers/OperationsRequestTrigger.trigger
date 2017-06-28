trigger OperationsRequestTrigger on Operations_Request__c (before insert, before update, after update) {
    
    if (trigger.isBefore) {
    	
    	if (trigger.isInsert) {
    		OperationsRequestService.setFields(trigger.new);
    		OperationsRequestService.validationRules(trigger.new, null, trigger.isInsert);
    	}
    	
    	if (trigger.isUpdate) {
    		OperationsRequestService.customerAccepted(trigger.new, trigger.oldMap);
    		OperationsRequestService.validationRules(trigger.new, trigger.oldMap, trigger.isInsert);
    	}
    }
    
    if (trigger.isAfter) {
    	
    	if (trigger.isUpdate) {
    		OperationsRequestService.changeRecordType(trigger.newMap, trigger.oldMap);
    	}
    }
}