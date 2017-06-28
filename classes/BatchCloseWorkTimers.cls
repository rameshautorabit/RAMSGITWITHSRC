Global class BatchCloseWorkTimers implements Database.Batchable<sObject> {
	
	/*
	 *	Batch job designed to run once every 24 hours around midnight Pacific Time.
	 *	Purpose is to shut down any Work Timers that were left running by mistake.
	 *
	 */
	
	public String wtQueryString = 'SELECT Id, EndTime__c, Memo__c FROM Timer_Entry__c WHERE EndTime__c = null';
	
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(wtQueryString);
	}
	
	global void execute(Database.BatchableContext BC, List<Timer_Entry__c> records) {
		
		system.debug('*****BatchCloseWorkTimers:  query string = ' + wtQueryString);
		system.debug('*****BatchCloseWorkTimers:  total number of Timer_Entry__c records to process = ' + records.size());
		
		DateTime nowTime = system.now();
		for (Timer_Entry__c te :records) {
			te.EndTime__c = nowTime;
			te.Memo__c = 'Timer automatically closed by System - nightly batch.';
		}
		
		if (!records.isEmpty()) {
			update records;
		}
	}
	
    global void finish(Database.BatchableContext BC) {
    	
		Id rhProductionOrgId = '00D500000007MjVEAU';
		
		// Get the status of the batch job just completed
		AsyncApexJob a = [select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =: BC.getJobId()];
		
		// Send an email to the RH SFDC email alias notifying of job completion, but only if running in production.
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		List<String> toAddresses = new List<String>();
		toAddresses.add('salesforce@restorationhardware.com');
		mail.setToAddresses(toAddresses);
		mail.setSubject('BatchEmailToAttachment Status: ' + a.Status);
		mail.setPlainTextBody('The batch Apex job BatchCloseWorkTimers processed ' + a.TotalJobItems + ' batches with ' + a.NumberOfErrors + ' failures.');
		if (UserInfo.getOrganizationId() == rhProductionOrgId) {
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
    }
}