global class BatchDelayNotificationCases implements Database.Batchable<sObject> {
	
	/*
	 *	Batch job to process all open Delay Notification cases. Determine if the case should
	 *	be updated in some way based upon updated information in the related case lines/order lines.
	 *
	 */
	
	global final String Query;
	global BatchDelayNotificationCases() {
		Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
		String dnRecordTypeId = rtMap.get('Delay Notifications').getRecordTypeId();
		Query = 'SELECT Id, RH_Order_Number__c '
			+ 'FROM Case '
			+ 'WHERE RecordTypeId = \'' + dnRecordTypeId + '\' AND IsClosed = false AND Gift_Card_Status__c != \'Pending\'';
	}
	
	global BatchDelayNotificationCases(String q) {
		Query = q;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		Database.QueryLocator ql = Database.getQueryLocator(Query);
		system.debug('*****BatchDelayNotificationCases Query locator: ' + ql);
		return ql;
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		/*
		Set<Id> oIds = new Set<Id>();
		for (sObject s :scope) {
			Case c = (Case)s;
			if (c.RH_Order_Number__c != null) {
				oIds.add(c.RH_Order_Number__c);
			}
		}
		
		DelayedOrderActions.updateDelayNotificationCases(oIds);
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
		mail.setSubject('BatchDelayNotificationCases Status: ' + a.Status);
		mail.setPlainTextBody('The batch Apex job BatchDelayNotificationCases processed ' + a.TotalJobItems + ' batches with ' + a.NumberOfErrors + ' failures.');
		if (!Test.isRunningTest()) {
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
		*/
	}
}