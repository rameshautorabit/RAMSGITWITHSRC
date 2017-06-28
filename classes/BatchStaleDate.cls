global class BatchStaleDate implements Database.Batchable<sObject> {
	
	/*
	 *	Batch job to process all order lines that have a stale date equal to yesterday (In Warehouse Date is has not
	 *	been updated and is now in the past). For each order line meeting the criteria, a case/case line will be 
	 *	created or updated.
	 *
	 *	Note - this does not catch stale dates that set to a date beyond yesterday in the past.
	 *
	 */
	
	global final String Query;
	global BatchStaleDate() {
		
		Query = 'SELECT Id, DelayFeed__c, StaleDate__c, Delay_Feed_History__c, Backorder_Quantity__c, Coordinate_Group__c, '
				+ 'Current_Available_Date__c, Current_Delay_Date__c, RH_Order_Number__c, Available_Date__c, Original_Available_Date__c, '
				+ 'In_Warehouse_Date__c, Days_Since_Original_Available_Date__c, CW_SKU_ID__c, Line_Status_Description__c, Line_Total__c '
				+ 'FROM Order_Line_Items__c '
				+ 'WHERE In_Warehouse_Date__c = YESTERDAY AND Backorder_Quantity__c > 0';
	}
	
	global BatchStaleDate(String q) {
		Query = q;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		Database.QueryLocator ql = Database.getQueryLocator(Query);
		system.debug('*****BatchStaleDate Query locator: ' + ql);
		return ql;
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		
		List<Order_Line_Items__c> staleList = new List<Order_Line_Items__c>();
		for (sObject s :scope) {
			Order_Line_Items__c oli = (Order_Line_Items__c)s;
			if (oli.Line_Status_Description__c == 'Open' || oli.Line_Status_Description__c == 'Held') {
				oli.StaleDate__c = true;
				staleList.add(oli);
			}
		}
		
		if (!staleList.isEmpty()) {
			DelayedOrderActions.takeAction(staleList);
		}
		
		for (Order_Line_Items__c oli :staleList) {
			oli.StaleDate__c = false;
		}
		
		if (!staleList.isEmpty()) {
			update staleList;
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
		// Get the status of the batch job just completed
		AsyncApexJob a = [select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =: BC.getJobId()];
		
		// Send an email to notify of job completion. 
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		List<String> toAddresses = new List<String>();
		toAddresses.add('salesforce@restorationhardware.com');
		mail.setToAddresses(toAddresses);
		mail.setSubject('BatchStaleDate Status: ' + a.Status);
		mail.setPlainTextBody('The batch Apex job BatchStaleDate processed ' + a.TotalJobItems + ' batches with ' + a.NumberOfErrors + ' failures.');
		if (!Test.isRunningTest()) {
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}
}