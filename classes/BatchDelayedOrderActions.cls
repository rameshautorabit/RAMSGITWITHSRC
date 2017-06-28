global class BatchDelayedOrderActions implements Database.Batchable<sObject> {
	
	/*
	 *	Batch job to process all order lines that have a pending delay feed (new delayed order
	 *	date) or stale date (In Warehouse Date has been set to a date in the past).
	 *	For each order line meeting the criteria, a case/case line will be created or updated.
	 *
	 */
	
	global final String Query;
	global BatchDelayedOrderActions() {
		
		Query = 'SELECT Id, DelayFeed__c, StaleDate__c, Delay_Feed_History__c, Backorder_Quantity__c, Coordinate_Group__c, '
				+ 'Current_Available_Date__c, Current_Delay_Date__c, Available_Date__c, Original_Available_Date__c, '
				+ 'In_Warehouse_Date__c, Days_Since_Original_Available_Date__c, CW_SKU_ID__c, Line_Status_Description__c, Line_Total__c, '
				+ 'RH_Order_Number__c, RH_Order_Number__r.Order_Type_Code__c '
				+ 'FROM Order_Line_Items__c WHERE DelayFeed__c = true';
	}
	
	global BatchDelayedOrderActions(String q) {
		Query = q;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		Database.QueryLocator ql = Database.getQueryLocator(Query);
		system.debug('*****BatchDelayedOrderActions Query locator: ' + ql);
		return ql;
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		
		List<Order_Line_Items__c> oliList = new List<Order_Line_Items__c>();
		List<Order_Line_Items__c> doOliList = new List<Order_Line_Items__c>();
		for (sObject s :scope) {
			Order_Line_Items__c oli = (Order_Line_Items__c)s;
			if (oli.Backorder_Quantity__c > 0 && (oli.Line_Status_Description__c == 'Open' || oli.Line_Status_Description__c == 'Held')) {
				if (oli.In_Warehouse_Date__c < system.today()) {
					oli.StaleDate__c = true;
				}
				doOliList.add(oli);
			}
			oliList.add(oli);
		}
		
		if (!doOliList.isEmpty()) {
			DelayedOrderActions.takeAction(doOliList);
		}
		
		for (Order_Line_Items__c oli :oliList) {
			oli.DelayFeed__c = false;
			oli.StaleDate__c = false;
		}
		
		if (!oliList.isEmpty()) {
			update oliList;
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
		mail.setSubject('BatchDelayedOrderActions Status: ' + a.Status);
		mail.setPlainTextBody('The batch Apex job BatchDelayedOrderActions processed ' + a.TotalJobItems + ' batches with ' + a.NumberOfErrors + ' failures.');
		if (!Test.isRunningTest()) {
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}
}