global class BatchOrderTableScan implements Database.Batchable<sObject> {
	
	/*
	 *	Batch job to find all Orders that are not order shells that do not have any Order Lines.
	 *
	 */
	
	global final String Query;
	global BatchOrderTableScan() {
		String orderNonShellRTID = '012500000009tf4';
		Query = 'SELECT Id, Name FROM RH_Order__c WHERE RecordTypeId = \'' + orderNonShellRTID + '\'';
	}
	
	global BatchOrderTableScan(String q) {
		Query = q;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		Database.QueryLocator ql = Database.getQueryLocator(Query);
		system.debug('*****BatchOrderTableScan Query locator: ' + ql);
		return ql;
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		
		system.debug('*****BatchOrderTableScan scope = ' + scope);
		
		Map<Id, String> orderNumberMap = new Map<Id, String>();
		for (sObject s :scope) {
			RH_Order__c o = (RH_Order__c)s;
			orderNumberMap.put(o.Id, o.Name);
		}
		
		system.debug('*****BatchOrderTableScan orderNumberMap = ' + orderNumberMap);
		
		List<Order_Line_Items__c> oliList = new List<Order_Line_Items__c>();
		oliList = [select Id, Name, RH_Order_Number__c from Order_Line_Items__c where RH_Order_Number__c in :orderNumberMap.keySet()];
		
		system.debug('*****BatchOrderTableScan oliList = ' + oliList);
		
		for (Order_Line_Items__c oli :oliList) {
			if (orderNumberMap.containsKey(oli.RH_Order_Number__c)) {
				orderNumberMap.remove(oli.RH_Order_Number__c);
			}
		}
		
		system.debug('*****BatchOrderTableScan orderNumberMap after = ' + orderNumberMap);
		
		if (!orderNumberMap.isEmpty()) {
			Map<String, Application_Settings__c> appSettings = Application_Settings__c.getAll();
			if (appSettings.containsKey('EnableCustomLogging') && appSettings.get('EnableCustomLogging').Value_Text__c == 'True') {
				Log__c log = new Log__c();
				log.Script_Event__c = 'BatchOrderTableScan: found ' + orderNumberMap.size() + ' non-shell orders without order lines.';
				log.Log_Message__c = 'Non-shell orders without order lines:';
				for (Id key :orderNumberMap.keySet()) {
					log.Log_Message__c += '\nId = ' + key + ' Order Number = ' + orderNumberMap.get(key);
				}
				insert log;
			}
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
		// Get the status of the batch job just completed
		AsyncApexJob a = [select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =: BC.getJobId()];
		
		// Send an email to notify of job completion. 
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		List<String> toAddresses = new List<String>();
		//toAddresses.add('salesforce@restorationhardware.com');
		toAddresses.add('sthompto@restorationhardware.com');
		mail.setToAddresses(toAddresses);
		mail.setSubject('BatchOrderTableScan Status: ' + a.Status);
		
		String textBody = 'The batch Apex job BatchOrderTableScan processed ' + a.TotalJobItems + ' batches with ' + a.NumberOfErrors + ' failures.';
		
		mail.setPlainTextBody(textBody);
		if (!Test.isRunningTest()) {
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}
}