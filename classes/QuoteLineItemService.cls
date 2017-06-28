public without sharing class QuoteLineItemService {
	
	/*
	 *	Service methods for QuoteLineItemTrigger.
	 *
	 */
	
	// Trigger QLI to OLI in process variable and methods
	private static Boolean QLItoOLIinProcess = false;
	
	public static boolean isQLItoOLIinProcess() {
		return QLItoOLIinProcess;
    }
    
	public static void setQLItoOLIinProcess() {
		QLItoOLIinProcess = true;
	}
	
	public static void resetQLItoOLIinProcess() {
		QLItoOLIinProcess = false;
	}
	
	// One or more QuoteLineItem records have just been inserted or updated, synchronize the
	// custom fields with the counterpart OpportunityLineItem records
	// - before insert, after update
	public static void syncQuoteLine(List<QuoteLineItem> newList, Map<Id, QuoteLineItem> oldMap, Boolean isInsert) {
		
		if (isInsert || !OpportunityLineItemService.isOLItoQLIinProcess()) {
			
			Set<String> oliIdSet = new Set<String>();
			List<QuoteLineItem> qliList = new List<QuoteLineItem>();
			Map<String, SyncOliQliCustomFields__c> customFields = SyncOliQliCustomFields__c.getAll();
			for (QuoteLineItem qli :newList) {
				if (String.isNotBlank(qli.OpportunityLineItemId__c)) {
					
					if (isInsert) {
						oliIdSet.add(qli.OpportunityLineItemId__c);
						qliList.add(qli);
					}
					
					if (!isInsert) {
						if (qli.IsQuoteSynced__c) {
							for (SyncOliQliCustomFields__c cf :customFields.values()) {
								if (qli.get(cf.QLI_Field__c) != oldMap.get(qli.Id).get(cf.QLI_Field__c)) {
									oliIdSet.add(qli.OpportunityLineItemId__c);
									qliList.add(qli);
									break;
								}
							}
						}
					}
				}
			}
			
			if (!oliIdSet.isEmpty()) {
				
				// Get the OpportunityLineItem records
				String oliIds = '(';
				for (String s :oliIdSet) {
					oliIds += '\'' + s + '\',';
				}
				oliIds = oliIds.removeEnd(',');
				oliIds += ')';
				
				String oliFields = 'Id,SyncedQuoteId__c,';
				for (SyncOliQliCustomFields__c cf :customFields.values()) {
					oliFields += cf.OLI_Field__c + ',';
				}
				oliFields = oliFields.removeEnd(',');
				
				List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
				oliList = Database.query('SELECT ' + oliFields + ' FROM OpportunityLineItem WHERE Id IN ' + oliIds);
				Map<String, OpportunityLineItem> oliMap = new Map<String, OpportunityLineItem>();
				String strKey;
				for (OpportunityLineItem oli :oliList) {
					strKey = oli.Id;
					strKey = strKey.substring(0,15);
					oliMap.put(strKey, oli);
				}
				
				// Copy the custom fields between the QuoteLineItem and OpportunityLineItem records - direction depends on trigger state
				for (QuoteLineItem qli :qliList) {
					strKey = qli.OpportunityLineItemId__c;
					if (oliMap.containsKey(strKey)) {
						if (isInsert) {
							for (SyncOliQliCustomFields__c cf :customFields.values()) {
								qli.put(cf.QLI_Field__c, oliMap.get(strKey).get(cf.OLI_Field__c));
							}
						} else {
							for (SyncOliQliCustomFields__c cf :customFields.values()) {
								oliMap.get(strKey).put(cf.OLI_Field__c, qli.get(cf.QLI_Field__c));
							}
						}
					}
				}
				
				if (isInsert) {
					OpportunityLineItemService.setOLItoQLIinProcess();		// prevent recursive triggers
				} else {
					if (!oliMap.isEmpty()) {
						setQLItoOLIinProcess();								// prevent recursive triggers
						update oliMap.values();
					}
				}
			}
		}
	}
}