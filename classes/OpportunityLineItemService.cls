public with sharing class OpportunityLineItemService {
	
	/*
	 *	Service methods for OpportunityLineItemTrigger.
	 *
	 */
	
	// Trigger OLI to QLI in process variable and methods
	private static Boolean OLItoQLIinProcess = false;
	
	public static boolean isOLItoQLIinProcess() {
		return OLItoQLIinProcess;
    }
    
	public static void setOLItoQLIinProcess() {
		OLItoQLIinProcess = true;
	}
	
	public static void resetOLItoQLIinProcess() {
		OLItoQLIinProcess = false;
	}
	
	// One or more OpportunityLineItem records have just been inserted or updated, synchronize the
	// custom fields with the counterpart QuoteLineItem records
	// - after insert, after update
	public static void syncOpportunityLine(List<OpportunityLineItem> newList, Map<Id, OpportunityLineItem> oldMap, Boolean isInsert) {
		String strOliId;
		String strQId;
		String strKey;
		
		if (isInsert || !QuoteLineItemService.isQLItoOLIinProcess()) {
			
			Map<String, SyncOliQliCustomFields__c> customFields = SyncOliQliCustomFields__c.getAll();
			Map<String, OpportunityLineItem> oliMap = new Map<String, OpportunityLineItem>();
			for (OpportunityLineItem oli :newList) {
				if (String.isNotBlank(oli.SyncedQuoteId__c)) {
					if (isInsert) {
						strOliId = oli.Id;
						strQId = oli.SyncedQuoteId__c;
						strKey = strOliId.substring(0,15) + '-' + strQId.subString(0,15);
						oliMap.put(strKey, oli);
					}
					
					if (!isInsert) {
						for (SyncOliQliCustomFields__c cf :customFields.values()) {
							if (oli.get(cf.OLI_Field__c) != oldMap.get(oli.Id).get(cf.OLI_Field__c)) {
								strOliId = oli.Id;
								strQId = oli.SyncedQuoteId__c;
								strKey = strOliId.substring(0,15) + '-' + strQId.subString(0,15);
								oliMap.put(strKey, oli);
								break;
							}
						}
					}
				}
			}
			
			if (!oliMap.isEmpty()) {
				
				// Get the QuoteLineItem records
				Set<String> qIdSet = new Set<String>();
				String oliIds = '(';
				String qIds = '(';
				for (OpportunityLineItem oli :oliMap.values()) {
					strKey = oli.Id;
					oliIds += '\'' + strKey.substring(0,15) + '\',';
					if (!qIdSet.contains(oli.SyncedQuoteId__c)) {
						qIds += '\'' + oli.SyncedQuoteId__c + '\',';
						qIdSet.add(oli.SyncedQuoteId__c);
					}
				}
				oliIds = oliIds.removeEnd(',');
				oliIds += ')';
				qIds = qIds.removeEnd(',');
				qIds += ')';
				
				String qliFields = 'Id,QuoteId,OpportunityLineItemId__c,';
				for (SyncOliQliCustomFields__c cf :customFields.values()) {
					qliFields += cf.QLI_Field__c + ',';
				}
				qliFields = qliFields.removeEnd(',');
				
				List<QuoteLineItem> qliList = new List<QuoteLineItem>();
				qliList = Database.query('SELECT ' + qliFields + ' FROM QuoteLineItem WHERE OpportunityLineItemId__c IN ' + oliIds + ' AND QuoteId IN ' + qIds);
				
				// Copy the custom fields between the OpportunityLineItem and QuoteLineItem records - direction depends on trigger state
				OpportunityLineItem oliTmp;
				List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
				for (QuoteLineItem qli :qliList) {
					strQId = qli.QuoteId;
					strKey = qli.OpportunityLineItemId__c + '-' + strQId.substring(0,15);
					if (oliMap.containsKey(strKey)) {
						if (isInsert) {
							oliTmp = new OpportunityLineItem();
							oliTmp.Id = oliMap.get(strKey).Id;
							for (SyncOliQliCustomFields__c cf :customFields.values()) {
								oliTmp.put(cf.OLI_Field__c, qli.get(cf.QLI_Field__c));
							}
							oliList.add(oliTmp);
						} else {
							for (SyncOliQliCustomFields__c cf :customFields.values()) {
								qli.put(cf.QLI_Field__c, oliMap.get(strKey).get(cf.OLI_Field__c));
							}
						}
					}
				}
				
				if (isInsert) {
					if (!oliList.isEmpty()) {
						QuoteLineItemService.setQLItoOLIinProcess();	// prevent recursive triggers
						update oliList;
					}
				} else {
					if (!qliList.isEmpty()) {
						setOLItoQLIinProcess();							// prevent recursive triggers
						update qliList;
					}
				}
			}
		}
	}
}