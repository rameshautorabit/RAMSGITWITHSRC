trigger QuoteLineItemTrigger on QuoteLineItem (before insert, after update) {
	
	if (trigger.isBefore) {
		
		if (trigger.isInsert) {
			//system.debug('QUOTESYNC QuoteLineItemTrigger BI trigger.new = ' + trigger.new);
			
			QuoteLineItemService.syncQuoteLine(trigger.new, null, trigger.isInsert);
		}
	}
	
	if (trigger.isAfter) {
		
		if (trigger.isUpdate) {
			//system.debug('QUOTESYNC QuoteLineItemTrigger AU trigger.new = ' + trigger.new);
			//system.debug('QUOTESYNC QuoteLineItemTrigger AU trigger.old = ' + trigger.old);
			
			QuoteLineItemService.syncQuoteLine(trigger.new, trigger.oldMap, trigger.isInsert);
		}
	}
}