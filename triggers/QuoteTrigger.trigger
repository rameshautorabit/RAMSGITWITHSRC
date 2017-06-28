trigger QuoteTrigger on Quote (after update) {
	
	if (trigger.isAfter) {
		
		if (trigger.isUpdate) {
			/*
			for (Quote q :trigger.new) {
				system.debug('QUOTESYNC QuoteTrigger AU QId = ' + q.Id + ' Old IsSyncing = ' + trigger.oldMap.get(q.Id).IsSyncing  + ' IsSyncing = ' + q.IsSyncing);
			}
			*/
			
			QuoteService.syncQuoteLineItems(trigger.new, trigger.oldMap);
		}
	}
}