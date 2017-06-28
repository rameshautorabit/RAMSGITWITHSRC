global class BatchDNCaseExecuteRules implements Database.Batchable<sObject> {
	
	/*
	 *	Batch job to process all open Delay Notification cases. Purpose is to populate
	 *	the new field "Delay Notification Type" on all of the related Case Line records
	 *
	 */
	
	global final String Query;
	global BatchDNCaseExecuteRules() {
		
		Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
		String dnRecordTypeId = rtMap.get('Delay Notifications').getRecordTypeId();
		Query = 'SELECT Id, CaseNumber, Status, Request_Category__c, Delay_Notification_Reason__c '
			+ 'FROM Case '
			+ 'WHERE RecordTypeId = \'' + dnRecordTypeId + '\' AND IsClosed = false AND Gift_Card_Status__c != \'Pending\'';
	}
	
	global BatchDNCaseExecuteRules(String q) {
		Query = q;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		Database.QueryLocator ql = Database.getQueryLocator(Query);
		system.debug('*****BatchDNCaseExecuteRules Query locator: ' + ql);
		return ql;
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		/*
		Map<Id, Case> cMap = new Map<Id, Case>();
		for (sObject s :scope) {
			Case c = (Case)s;
			c.Request_Category__c = '';
			c.Delay_Notification_Reason__c = '';
			cMap.put(c.Id, c);
		}
		update cMap.values();
		
		// Get all of the related Case Line Items
		Map<Id, Case_Line_Items__c> cliMap = new Map<Id, Case_Line_Items__c>([select Id, Name, Case_Number__c, IsStaleDate__c, 
				Delay_Notification_Type__c, In_Warehouse_Date__c, Line_Status_Description__c, Backorder_Quantity__c, Line_Number__c 
				from Case_Line_Items__c where Case_Number__c in :cMap.keySet()]);
		
		// Create a list of Order Lines to put back through the delayed order rules
		Map<Id, Case_Line_Items__c> oliCliMap = new Map<Id, Case_Line_Items__c>();
		for (Case_Line_Items__c cli :cliMap.values()) {
			if (cli.Line_Number__c != null) {
				oliCliMap.put(cli.Line_Number__c, cli);
			}
		}
		List<Order_Line_Items__c> oliList = new List<Order_Line_Items__c>();
		oliList = [select Id, DelayFeed__c, StaleDate__c, Delay_Feed_History__c, Backorder_Quantity__c, Coordinate_Group__c, 
				Current_Available_Date__c, Current_Delay_Date__c, RH_Order_Number__c, Available_Date__c, Original_Available_Date__c, 
				In_Warehouse_Date__c, Days_Since_Original_Available_Date__c, CW_SKU_ID__c, Line_Status_Description__c, Line_Total__c 
				from Order_Line_Items__c where Id in :oliCliMap.keySet()];
		
		// Manipulate the Order Lines to simulate new backorder date or stale date
		for (Order_Line_Items__c oli : oliList) {
			oli.DelayFeed__c = true;
			if (oliCliMap.get(oli.Id).IsStaleDate__c) {
				oli.StaleDate__c = true;
			}
		}
		update oliList;
		
		DelayedOrderActions.takeAction(oliList);
		
		// Clear out the Order Line flags we set earlier
		for (Order_Line_Items__c oli :oliList) {
			oli.DelayFeed__c = false;
			oli.StaleDate__c = false;
		}
		update oliList;
		*/
	}
	
	global void finish(Database.BatchableContext BC) {
		/*
		// Get the status of the batch job just completed
		AsyncApexJob a = [select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =: BC.getJobId()];
		
		// Send an email to notify of job completion. 
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		List<String> toAddresses = new List<String>();
		toAddresses.add('salesforce@restorationhardware.com');
		mail.setToAddresses(toAddresses);
		mail.setSubject('BatchDNCaseExecuteRules Status: ' + a.Status);
		mail.setPlainTextBody('The batch Apex job BatchDNCaseExecuteRules processed ' + a.TotalJobItems + ' batches with ' + a.NumberOfErrors + ' failures.');
		if (!Test.isRunningTest()) {
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
		*/
	}
}