global class DelayNotificationsHold implements Database.Batchable<sObject> {
	
	/*
	 *	Batch job to update the On Hold state of all appropriate Delay Notifications cases
	 */
	
	global final String Query;
	global DelayNotificationsHold() {
		Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
		if (!Test.isRunningTest()) {
			Query = 'SELECT Id, On_Hold__c, Order_Type_Category__c FROM Case WHERE RecordTypeId = \'' + rtMap.get('Delay Notifications').getRecordTypeId() + '\' AND IsClosed = false AND WasReopened__c = false';
		} else {
			Query = 'SELECT Id, On_Hold__c, Order_Type_Category__c FROM Case WHERE RecordTypeId = \'' + rtMap.get('Delay Notifications').getRecordTypeId() + '\' AND IsClosed = false AND WasReopened__c = false AND RH_Order_Number__r.Name like \'dnhT%\'';
		}
	}
	
	global DelayNotificationsHold(String q) {
		Query = q;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		Database.QueryLocator ql = Database.getQueryLocator(Query);
		system.debug('*****DelayNotificationsHold Query locator: ' + ql);
		return ql;
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		
		List<Case> cases = new List<Case>();
		Map<String, Boolean> todayHoldsMap;
		
		// Process each case - set them to on hold or take them off of on hold
		todayHoldsMap = DelayedOrderActions.getTodayHolds();
		if (!todayHoldsMap.isEmpty()) {
			
			for (sObject s :scope) {
				Case c = (Case)s;
				if (String.isNotBlank(c.Order_Type_Category__c)) {
					if (todayHoldsMap.containsKey(c.Order_Type_Category__c)) {
						if (c.On_Hold__c != todayHoldsMap.get(c.Order_Type_Category__c)) {
							c.On_Hold__c = todayHoldsMap.get(c.Order_Type_Category__c);
							cases.add(c);
						}
					}
				}
			}
			
			if (!cases.isEmpty()) {
				List<Database.SaveResult> srList = new List<Database.SaveResult>();
				try {
					srList = Database.update(cases, false);
				} catch(exception e) {
					system.debug('*****DelayNotificationsHold: exception while updating cases: ' + e.getMessage());
				}
				
				// Iterate through each returned result
				for (Database.SaveResult sr : srList) {
					if (!sr.isSuccess()) {
						// Operation failed, so get all errors 
						system.debug('*****DelayNotificationsHold error on Case Id:' + sr.getId());               
						for (Database.Error err :sr.getErrors()) {
							system.debug('*****DelayNotificationsHold The following error has occurred: ' + err.getStatusCode() + ': ' + err.getMessage());                    
							system.debug('*****DelayNotificationsHold Case fields that affected this error: ' + err.getFields());
						}
					}
				}
			}
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
		// Get the status of the batch job just completed
		AsyncApexJob a = [select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =: BC.getJobId()];
		
		// Send an email to notify of job completion. 
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		List<String> toAddresses = new List<String>();
		toAddresses.add('salesforce@restorationhardware.com');
		//toAddresses.add('sthompto@restorationhardware.com');
		mail.setToAddresses(toAddresses);
		mail.setSubject('DelayNotificationsHold Status: ' + a.Status);
		mail.setPlainTextBody('The batch Apex job DelayNotificationsHold processed ' + a.TotalJobItems + ' batches with ' + a.NumberOfErrors + ' failures.');
		if (!Test.isRunningTest()) {
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}
}