trigger OperationsRequestLineItemTrigger on Operations_Request_Line_Item__c (after insert, after update) {
	
	if (trigger.isAfter) {
		
		if (trigger.isInsert) {
			OperationsRequestLineItemService.rollUp(trigger.new, null, trigger.isInsert);
		}
		
		if (trigger.isUpdate) {
			OperationsRequestLineItemService.rollUp(trigger.new, trigger.oldMap, trigger.isInsert);
		}
	}
}