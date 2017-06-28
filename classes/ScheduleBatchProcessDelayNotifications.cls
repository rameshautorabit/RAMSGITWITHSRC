global class ScheduleBatchProcessDelayNotifications implements Schedulable {
	
	Integer maxCases;
    public ScheduleBatchProcessDelayNotifications() {
        this.maxCases = null;
        List<Delay_Notifications_Schedule__c> dnsList = new List<Delay_Notifications_Schedule__c>();
        if (!Test.isRunningTest()) {
        	dnsList = [select Id, Max_Cases__c from Delay_Notifications_Schedule__c where Active__c = true limit 1];
        } else {
        	dnsList = [select Id, Max_Cases__c from Delay_Notifications_Schedule__c where Name = 'bpdnTest1 Schedule' limit 1];
        }
        if (!dnsList.isEmpty()) {
        	this.maxCases = Integer.valueOf(dnsList[0].Max_Cases__c);
        }
    }
    
    public ScheduleBatchProcessDelayNotifications(Integer caseLimit) {
        this.maxCases = caseLimit;
    }
	
	// Schedule Class for batch job BatchBackordersActions
	global void execute(SchedulableContext SC) {
		BatchProcessDelayNotifications BA =  new BatchProcessDelayNotifications();
		Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
		Id dnRecordTypeId = rtMap.get('Delay Notifications').getRecordTypeId();
		String queryFields = 'Id';
		String whereClause = 'RecordTypeId = \'' + dnRecordTypeId + '\' AND Request_Category__c = \'Automatic Email\' AND IsClosed = false AND On_Hold__c = false AND Gift_Card_Status__c = null AND WasReopened__c = false';
		if (Test.isRunningTest()) {
			whereClause += ' AND RH_Order_Number__r.Name LIKE \'bpdnT1%\'';
		}
		whereClause += ' ORDER BY CreatedDate';
		if (maxCases != null && maxCases != 0) {
			whereClause += ' LIMIT ' + maxCases;
		}
		BA.bpdnQueryString = 'SELECT ' + queryFields + ' FROM Case WHERE ' + whereClause;
		system.debug('*****ScheduleBatchProcessDelayNotifications querystring = ' + BA.bpdnQueryString);
		Database.executeBatch(BA, 5); 
	}
}