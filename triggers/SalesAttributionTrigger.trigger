trigger SalesAttributionTrigger on Sales_Attribution__c (before insert) {
			
	if (trigger.isBefore) {
		if (trigger.isInsert) {
			SalesAttributionService.populateAttributionName(trigger.new);
		}
	}
}