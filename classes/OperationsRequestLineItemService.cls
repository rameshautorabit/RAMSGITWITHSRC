public with sharing class OperationsRequestLineItemService {
	
	/*
	 *	Service methods for OperationsRequestLineItemTrigger.
	 *
	 */
	
	// "Roll Up" various fields from Operations Request Line Item records to their parent Operations Request record
	// - after insert, after update
	//		- DC_Location__c - "roll up" picklist field to multi-select picklist DC_Location__c
	//		- Ops_Notes__c - if one or more is non blank, set OpsNotesLineItem__c to true
	public static void rollUp(List<Operations_Request_Line_Item__c> newList, Map<Id, Operations_Request_Line_Item__c> oldMap, Boolean isInsert) {
		Set<Id> orIds = new Set<Id>();
		
		for (Operations_Request_Line_Item__c orli :newList) {
			if (isInsert) {
				if (String.isNotBlank(orli.DC_Location__c)) {
					orIds.add(orli.Operations_Request__c);
				}
				if (String.isNotBlank(orli.Ops_Notes__c)) {
					orIds.add(orli.Operations_Request__c);
				}
			}
			
			if (!isInsert) {
				if (orli.DC_Location__c != oldMap.get(orli.Id).DC_Location__c) {
					orIds.add(orli.Operations_Request__c);
				}
				if (orli.Ops_Notes__c != oldMap.get(orli.Id).Ops_Notes__c) {
					orIds.add(orli.Operations_Request__c);
				}
			}
		}
		
		if (!orIds.isEmpty()) {
			Map<Id, Operations_Request__c> orMap = new Map<Id, Operations_Request__c>([select Id, DC_Location__c, OpsNotesLineItem__c from Operations_Request__c where Id in :orIds]);
			for (Operations_Request__c o :orMap.values()) {
				o.DC_Location__c = '';
				o.OpsNotesLineItem__c = false;
			}
			
			List<Operations_Request_Line_Item__c> orliList = new List<Operations_Request_Line_Item__c>();
			orliList = [select Id, DC_Location__c, Operations_Request__c, Ops_Notes__c from Operations_Request_Line_Item__c where Operations_Request__c in :orIds];
			for (Operations_Request_Line_Item__c orli :orliList) {
				
				if (String.isNotBlank(orli.DC_Location__c)) {
					if (orMap.containsKey(orli.Operations_Request__c)) {
						if (!orMap.get(orli.Operations_Request__c).DC_Location__c.contains(orli.DC_Location__c + ';')) {
							orMap.get(orli.Operations_Request__c).DC_Location__c += orli.DC_Location__c + ';';
						}
					}
				}
				
				if (String.isNotBlank(orli.Ops_Notes__c)) {
					if (orMap.containsKey(orli.Operations_Request__c)) {
						orMap.get(orli.Operations_Request__c).OpsNotesLineItem__c = true;
					}
				}
			}
			
			for (Operations_Request__c o :orMap.values()) {
				if (String.isNotBlank(o.DC_Location__c)) {
					o.DC_Location__c = o.DC_Location__c.removeEnd(';');
				}
			}
			
			if (!orMap.isEmpty()) {
				update orMap.values();
			}
		}
	}
}