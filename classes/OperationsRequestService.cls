public class OperationsRequestService {
	
	/*
	 *	Service methods for OperationsRequestTrigger.trigger.
	 *
	 */
	
	// Automatically sets key fields on insert - fields: Order__c
	// - before insert
	public static void setFields(List<Operations_Request__c> newList) {
		Set<Id> oppIds = new Set<Id>();
		
		for (Operations_Request__c opr :newList) {
			if (opr.Opportunity__c != null && opr.Order__c == null) {
				oppIds.add(opr.Opportunity__c);
			}
		}
		
		if (!oppIds.isEmpty()) {
			
			Map<Id, Id> oppToOrderMap = new Map<Id, Id>();
			List<RH_Order__c> orderList = new List<RH_Order__c>();
			orderList = [select Id, Opportunity__c from RH_Order__c where Opportunity__c in :oppIds];
			
			for (RH_Order__c o :orderList) {
				oppToOrderMap.put(o.Opportunity__c, o.Id);
			}
			
			for (Operations_Request__c opr :newList) {
				if (oppToOrderMap.containsKey(opr.Opportunity__c)) {
					opr.Order__c = oppToOrderMap.get(opr.Opportunity__c);
				}
			}
		}
	}
	
	// Performs various validation rules and throws errors if appropriate
	// - before insert, before update
	public static void validationRules(List<Operations_Request__c> newList, Map<Id, Operations_Request__c> oldMap, Boolean isInsert) {
		
		if (isInsert) {
			
		}
		
		if (!isInsert) {
			for (Operations_Request__c opr :newList) {
				
				// Validate field Customer Decline Reason is not blank if field Approval Status is "Customer Declined"
				if (opr.Approval_Status__c != oldMap.get(opr.Id).Approval_Status__c && opr.Approval_Status__c == 'Customer Declined') {
					if (String.isBlank(opr.Customer_Decline_Reason__c)) {
						opr.Customer_Decline_Reason__c.addError('Customer Decline Reason must not be blank.');
					}
				}
			}
		}
	}
	
	// If Approval Status is "Customer Accepted" notify operations if related Opportunity is in appropriate state
	// - before update
	public static void customerAccepted(List<Operations_Request__c> newList, Map<Id, Operations_Request__c> oldMap) {
		Set<Id> oppIds = new Set<Id>();
		List<Operations_Request__c> oprList = new List<Operations_Request__c>();
		Set<Id> rtIds = new Set<Id>();
		Map<String, Schema.RecordTypeInfo> rtByNameMap = Schema.SObjectType.Operations_Request__c.getRecordTypeInfosByName();
		
		if (rtByNameMap.containsKey('COM/COL')) {
			rtIds.add(rtByNameMap.get('COM/COL').getRecordTypeId());
		}
		if (rtByNameMap.containsKey('Custom Product')) {
			rtIds.add(rtByNameMap.get('Custom Product').getRecordTypeId());
		}
		if (rtByNameMap.containsKey('SPO Quote')) {
			rtIds.add(rtByNameMap.get('SPO Quote').getRecordTypeId());
		}
		
		for (Operations_Request__c opr :newList) {
			if (opr.Opportunity__c != null && rtIds.contains(opr.RecordTypeId)) {
				if (opr.Approval_Status__c == 'Customer Accepted' && oldMap.get(opr.Id).Approval_Status__c != 'Customer Accepted') {
					// Only if we haven't already notified operations
					if (!opr.Notify_Ops__c) {
						oppIds.add(opr.Opportunity__c);
						oprList.add(opr);
					}
				}
			}
		}
		
		if (!oppIds.isempty()) {
			Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([select Id, Name, Amount, Total_Payment_Received__c, Credit_Terms__c 
					from Opportunity where Id in :oppIds]);
			for (Operations_Request__c opr :oprList) {
				if (oppMap.containsKey(opr.Opportunity__c)) {
					if (String.isNotBlank(oppMap.get(opr.Opportunity__c).Credit_Terms__c) && oppMap.get(opr.Opportunity__c).Credit_Terms__c != 'Pre-Pay') {
						opr.Notify_Ops__c = true;	// Notify operations
					}
					
					if (oppMap.get(opr.Opportunity__c).Amount > 0 && oppMap.get(opr.Opportunity__c).Total_Payment_Received__c > 0) {
						if (oppMap.get(opr.Opportunity__c).Total_Payment_Received__c >= oppMap.get(opr.Opportunity__c).Amount / 2) {
							opr.Notify_Ops__c = true;	// Notify operations
						}
					}
				}
			}
		}
	}
	
	// Change the related Operations Request Line Item record types to match the parent Operations Request record type
	// - after update
	public static void changeRecordType(Map<Id, Operations_Request__c> newMap, Map<Id, Operations_Request__c> oldMap) {
		Set<Id> orIds = new Set<Id>();
		
		for (Operations_Request__c opr :newMap.values()) {
			if (opr.RecordTypeId != null && opr.RecordTypeId != oldMap.get(opr.Id).RecordTypeId) {
				orIds.add(opr.Id);
			}
		}
		
		if (!orIds.isEmpty()) {
			List<Operations_Request_Line_Item__c> orliList = new List<Operations_Request_Line_Item__c>();
			orliList = [select Id, RecordTypeId, Operations_Request__c from Operations_Request_Line_Item__c where Operations_Request__c in :orIds];
			
			Map<Id, RecordTypeInfo> rtOpRecByIdMap = Schema.SObjectType.Operations_Request__c.getRecordTypeInfosById();
			Map<String, RecordTypeInfo> rtOpRecLineItemByNameMap = Schema.SObjectType.Operations_Request_Line_Item__c.getRecordTypeInfosByName();
			
			for (Operations_Request_Line_Item__c orli :orliList) {
				orli.RecordTypeId = rtOpRecLineItemByNameMap.get(rtOpRecByIdMap.get(newMap.get(orli.Operations_Request__c).RecordTypeId).getName()).getRecordTypeId();
			}
			
			if (!orliList.isEmpty()) {
				update orliList;
			}
		}
	}
}