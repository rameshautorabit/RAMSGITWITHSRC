trigger OpportunityLineItemTrigger on OpportunityLineItem (after insert, after update) {
	
	if (trigger.isAfter) {
		
		if (trigger.isInsert) {
			/*
			system.debug('QUOTESYNC OpportunityLineItemTrigger AI trigger.new = ' + trigger.new);
			
			Set<Id> oIds = new Set<Id>();
			for (OpportunityLineItem oli :trigger.new) {
				oIds.add(oli.OpportunityId);
			}
			
			if (!oIds.isEmpty()) {
				List<QuoteLineItem> qliList = new List<QuoteLineItem>();
				qliList = [select Id, OpportunityLineItemId__c from QuoteLineItem where Quote.OpportunityId in :oIds and Quote.IsSyncing = true];
				system.debug('QUOTESYNC OpportunityLineItemTrigger AI qliList = ' + qliList);
			}
			*/
			
			OpportunityLineItemService.syncOpportunityLine(trigger.new, null, trigger.isInsert);
		}
		
		if (trigger.isUpdate) {
			/*
			system.debug('QUOTESYNC OpportunityLineItemTrigger AU trigger.new = ' + trigger.new);
			
			Set<Id> oIds = new Set<Id>();
			for (OpportunityLineItem oli :trigger.new) {
				oIds.add(oli.OpportunityId);
			}
			
			if (!oIds.isEmpty()) {
				List<QuoteLineItem> qliList = new List<QuoteLineItem>();
				qliList = [select Id, OpportunityLineItemId__c from QuoteLineItem where Quote.OpportunityId in :oIds and Quote.IsSyncing = true];
				system.debug('QUOTESYNC OpportunityLineItemTrigger AU qliList = ' + qliList);
			}
			*/
			
			// QUOTESYNC debug code - start
			OpportunityLineItem offendingOLI = null;
			Integer debugLevel = 0;
			Map<String, Application_Settings__c> appSettingsMap = Application_Settings__c.getAll();
			if (appSettingsMap.containsKey('QUOTESYNC') && appSettingsMap.get('QUOTESYNC').Value_Numeric__c > 0) {
				debugLevel = Integer.valueOf(appSettingsMap.get('QUOTESYNC').Value_Numeric__c);
				
				if (debugLevel == 1) {
					for (OpportunityLineItem oli :trigger.new) {
						if (oli.Id == appSettingsMap.get('QUOTESYNC').Value_Text__c) {
							offendingOLI = oli;
							break;
						}
					}
					
					if (offendingOLI != null) {
						system.debug('QUOTESYNC OpportunityLineItemTrigger AU before OLI sync, offendingOLI NEW = ' + offendingOLI);
						system.debug('QUOTESYNC OpportunityLineItemTrigger AU before OLI sync, offendingOLI OLD = ' + trigger.oldMap.get(offendingOLI.Id));
					}
				} else {
					system.debug('QUOTESYNC OpportunityLineItemTrigger AU before OLI sync, trigger.new = ' + trigger.new);
					system.debug('QUOTESYNC OpportunityLineItemTrigger AU before OLI sync, trigger.old = ' + trigger.old);
				}
			}
			// QUOTESYNC debug code - end
			
			OpportunityLineItemService.syncOpportunityLine(trigger.new, trigger.oldMap, trigger.isInsert);
			
			// QUOTESYNC debug code - start
			if (debugLevel > 0) {
				if (debugLevel == 1) {
					if (offendingOLI != null) {
						system.debug('QUOTESYNC OpportunityLineItemTrigger AU after OLI sync, offendingOLI NEW = ' + offendingOLI);
					}
				} else {
					system.debug('QUOTESYNC OpportunityLineItemTrigger AU after OLI sync, trigger.new = ' + trigger.new);
				}
			}
			// QUOTESYNC debug code - end
		}
	}
}