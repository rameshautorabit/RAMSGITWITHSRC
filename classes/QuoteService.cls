public with sharing class QuoteService {
	
	/*
	 *	Service methods for QuoteTrigger.
	 *
	 */
	
	// Sync the OpportunityLineItem records with existing QuoteLineItem records
	// - after update
	public static void syncQuoteLineItems(List<Quote> newList, Map<Id, Quote> oldMap) {
		Set<String> qIdSet = new Set<String>();
		
		for (Quote q :newList) {
			if (q.IsSyncing == true && oldMap.get(q.Id).IsSyncing == false) {
				qIdSet.add(q.Id);
			}
		}
		
		if (!qIdSet.isEmpty()) {
			
			// Get all the custom fields to copy from QuoteLineItem to OpportunityLineItem
			Map<String, SyncOliQliCustomFields__c> customFields = SyncOliQliCustomFields__c.getAll();
			String qIds = '(';
			for (String s :qIdSet) {
				qIds += '\'' + s + '\',';
			}
			qIds = qIds.removeEnd(',');
			qIds += ')';
			
			String oliFields = 'Id,';
			String qliFields = 'Id,OpportunityLineItemId__c,';
			for (SyncOliQliCustomFields__c cf :customFields.values()) {
				oliFields += cf.OLI_Field__c + ',';
				qliFields += cf.QLI_Field__c + ',';
			}
			oliFields = oliFields.removeEnd(',');
			qliFields = qliFields.removeEnd(',');
			
			List<QuoteLineItem> qliList = new List<QuoteLineItem>();
			qliList = Database.query('SELECT ' + qliFields + ' FROM QuoteLineItem WHERE QuoteId IN ' + qIds);
			
			String oliIds = '(';
			for (QuoteLineItem qli :qliList) {
				if (String.isNotBlank(qli.OpportunityLineItemId__c)) {
					oliIds += '\'' + qli.OpportunityLineItemId__c + '\',';
				}
			}
			oliIds = oliIds.removeEnd(',');
			oliIds += ')';
			
			if (oliIds != '()') {
				List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
				oliList = Database.query('SELECT ' + oliFields + ' FROM OpportunityLineItem WHERE Id IN ' + oliIds);
				Map<String, OpportunityLineItem> oliMap = new Map<String, OpportunityLineItem>();
				String strId;
				for (OpportunityLineItem oli :oliList) {
					strId = oli.Id;
					oliMap.put(strId.substring(0,15), oli);	// use 15 character Id for map key
				}
				
				// Copy the custom fields of the QuoteLineItem to the OpportunityLineItem
				List<OpportunityLineItem> oliUpList = new List<OpportunityLineItem>();
				for (QuoteLineItem qli :qliList) {
					if (oliMap.containsKey(qli.OpportunityLineItemId__c)) {
						for (SyncOliQliCustomFields__c cf :customFields.values()) {
							oliMap.get(qli.OpportunityLineItemId__c).put(cf.OLI_Field__c, qli.get(cf.QLI_Field__c));
						}
					oliUpList.add(oliMap.get(qli.OpportunityLineItemId__c));
					}
				}
				
				if (!oliUpList.isEmpty()) {
					//QuoteLineItemService.SetQLItoOLIinProcess();	// Prevent recursive triggers
					update oliUpList;
				}
			}
		}
	}
}