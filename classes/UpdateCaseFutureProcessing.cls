/* Author SP@ForeFront
 * Purpose A batch job to set cases whose future processing dates are today or earlier not to future processing
 * Last Modified 8/19/2014
 */
 global class UpdateCaseFutureProcessing implements Database.Batchable<sObject> {
	global final String Query;
	global UpdateCaseFutureProcessing() {
		Query = 'SELECT Id, Future_Processing__c, IsClosed, RecordTypeId FROM Case WHERE ( Future_Processing__c = NULL OR Future_Processing_Date__c <= '+ ((Datetime)Date.today()).formatGMT('yyyy-MM-dd') +') AND Future_Processing__c = true';
	}
	
	global UpdateCaseFutureProcessing(String q) {
		Query = q;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		Database.QueryLocator ql = Database.getQueryLocator(Query);
		System.debug('Query locator: ' + ql);
		return ql;
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		Map<Id, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById();
		Set<Id> ccdIds = new Set<Id>();
		List<Case> cases = new List<Case>();
		
		for (sObject s : scope) {
			Case c = (Case)s;
			c.Future_Processing__c = false;
			cases.add(c);
			
			if (c.IsClosed == false && rtMap.containsKey(c.RecordTypeId) && rtMap.get(c.RecordTypeId).getName() == 'Credit Card Declines') {
				ccdIds.add(c.Id);
			}
		}
		
		Database.SaveResult[] srList;
		try {
			srList = Database.update(cases, false);
		} catch (exception e) {
			System.debug(e.getMessage());
		}
		
		// Iterate through each returned result
		for (Database.SaveResult sr : srList) {
			
			if (!sr.isSuccess()) {
				// Operation failed, so get all errors 
				System.debug('Case Id:' + sr.getId());               
				for (Database.Error err : sr.getErrors()) {
					System.debug('The following error has occurred.');                    
					System.debug(err.getStatusCode() + ': ' + err.getMessage());
					System.debug('Case fields that affected this error: ' + err.getFields());
				}
			}
		}
		
		// Process all Credit Card Decline cases coming off future processing
		if (!ccdIds.isEmpty()) {
			CreditCardDeclineNotifications.sendCCDNotifications(ccdIds);
		}
	}
	
	global void finish(Database.BatchableContext BC) {
	}
}