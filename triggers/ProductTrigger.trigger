trigger ProductTrigger on Product2 (after insert, after update, before insert, before update) {
	
	if (trigger.isBefore) {
		
		if (trigger.isInsert) {
			ProductService.totalQuantityOnHand(trigger.new, null, trigger.isInsert);
			ProductService.contractOnlySKU(trigger.new, null, trigger.isBefore, trigger.isInsert);
		}
		
		if (trigger.isUpdate) {
			ProductService.totalQuantityOnHand(trigger.new, trigger.oldMap, trigger.isInsert);
		}
	}
	
	if (trigger.isAfter) {
		
		if (trigger.isInsert) {
			ProductService.contractOnlySKU(trigger.new, null, trigger.isBefore, trigger.isInsert);
		}
		
		if (trigger.isUpdate) {
			ProductService.contractOnlySKU(trigger.new, trigger.oldMap, trigger.isBefore, trigger.isInsert);
		}
	}
}