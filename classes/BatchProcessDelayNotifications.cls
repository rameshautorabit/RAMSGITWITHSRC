Global class BatchProcessDelayNotifications implements Database.Batchable<sObject>, Database.AllowsCallouts {
	
	/*
	 *	Process each Delay Notifications Case that is ready to send a notification to the customer
	 *
	 */
	
	public String bpdnQueryString;
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(bpdnQueryString);
	}
	
	global void execute(Database.BatchableContext BC, List<Case> records) {
		
		system.debug('*****BatchProcessDelayNotifications number of records to process = ' + records.size());
		
		List<Id> cIds = new List<Id>();
		for (Case c :records) {
			cIds.add(c.Id);
		}
		
		if (!cIds.isEmpty()) {
			DelayedOrderNotification.sendOrderNotifications(cIds, false);
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
		mail.setSubject('BatchProcessDelayNotifications Status: ' + a.Status);
		mail.setPlainTextBody('The batch Apex job BatchProcessDelayNotifications processed ' + a.TotalJobItems + ' batches with ' + a.NumberOfErrors + ' failures.');
		if (!Test.isRunningTest()) {
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
		
		// Re-schedule ourself to run again in "intervalMinutes" time
        List<Delay_Notifications_Schedule__c> dnsList = new List<Delay_Notifications_Schedule__c>();
        if (!Test.isRunningTest()) {
        	dnsList = [select Id, Name, Start_Time__c, End_Time__c, Interval_Minutes__c, Max_Cases__c, Catch_Up_Run_Time__c, 
        			Sunday__c, Monday__c, Tuesday__c, Wednesday__c, Thursday__c, Friday__c, Saturday__c 
        			from Delay_Notifications_Schedule__c where Active__c = true limit 1];
        } else {
        	dnsList = [select Id, Name, Start_Time__c, End_Time__c, Interval_Minutes__c, Max_Cases__c, Catch_Up_Run_Time__c, 
        			Sunday__c, Monday__c, Tuesday__c, Wednesday__c, Thursday__c, Friday__c, Saturday__c 
        			from Delay_Notifications_Schedule__c where Name = 'bpdnTest1 Schedule' limit 1];
        }
		
        if (!dnsList.isEmpty()) {
        	
        	// Determine if we should schedule ourselves for another run
        	Delay_Notifications_Schedule__c dns = dnsList[0];
        	Integer startHour = Integer.valueOf(dns.Start_Time__c.length() == 8 ? dns.Start_Time__c.substring(0,2) : dns.Start_Time__c.substring(0,1));
        	if (dns.Start_Time__c.contains('AM')) {
        		if (startHour == 12) {
        			startHour = 0;
        		}
        	} else {
        		if (startHour != 12) {
        			startHour += 12;
        		}
        	}
        	Integer endHour = Integer.valueOf(dns.End_Time__c.length() == 8 ? dns.End_Time__c.substring(0,2) : dns.End_Time__c.substring(0,1));
        	if (dns.End_Time__c.contains('AM')) {
        		if (endHour == 12) {
        			endHour = 0;
        		}
        	} else {
        		if (endHour != 12) {
        			endHour += 12;
        		}
        	}
        	Integer catchUpHour = Integer.valueOf(dns.Catch_Up_Run_Time__c.length() == 8 ? dns.Catch_Up_Run_Time__c.substring(0,2) : dns.Catch_Up_Run_Time__c.substring(0,1));
        	if (dns.Catch_Up_Run_Time__c.contains('AM')) {
        		if (catchUpHour == 12) {
        			catchUpHour = 0;
        		}
        	} else {
        		if (catchUpHour != 12) {
        			catchUpHour += 12;
        		}
        	}
			DateTime now = DateTime.now();
			if (Test.isRunningTest()) {
				now = DateTime.newInstance(now.year(), now.month(), now.day(), 10, 0, 0);
			}
			DateTime nextRunTime = now.addMinutes(Integer.valueOf(dns.Interval_Minutes__c));
			Decimal nextRun = Decimal.valueOf(nextRunTime.hour()) + (Decimal.valueOf(nextRunTime.minute()) / 60);
			
			system.debug('*****BatchProcessDelayNotifications nextRun = ' + nextRun + ' hourD = ' + Decimal.valueOf(nextRunTime.hour()) + ' minD = ' + Decimal.valueOf(nextRunTime.minute()) / 60);
			
			system.debug('*****BatchProcessDelayNotifications startHour = ' + startHour + ' endHour = ' + endHour + ' catchUpHour = ' + catchUpHour + ' nextRun = ' + nextRun);
			
			if (nextRun >= startHour && nextRun <= endHour) {
				Integer maxCases = Integer.valueOf(dns.Max_Cases__c);
				Decimal intervalHours = dns.Interval_Minutes__c / 60;
				
				// If last run of the day, set maxCases to process all remaining cases
				if (nextRun + intervalHours > endHour) {
					maxCases = 0;
				} else {
					// If catchup run, set maxCases to process those cases that won't be covered by the other runs for the day
					if (nextRun == catchUpHour || (nextRun > catchUpHour && nextRun - intervalHours < catchUpHour)) {
						Integer caseCount;
						try {
							caseCount = [select count() from Case where RecordTypeId = '012500000009tdy' and Request_Category__c = 'Automatic Email' and On_Hold__c = false and IsClosed = false];
							maxCases = caseCount - Integer.valueOf((((endHour - startHour) / intervalHours) - 1) * dns.Max_Cases__c);
							if (maxCases <= 0) {
								maxCases = Integer.valueOf(dns.Max_Cases__c);
							}
						} catch(Exception e) {
							system.debug('*****BatchProcessDelayNotifications exception while getting case count: ' + e.getMessage());
							maxCases = Integer.valueOf(dns.Max_Cases__c);
						}
						system.debug('*****BatchProcessDelayNotifications caseCount = ' + caseCount + ' maxCases = ' + maxCases);
					}
				}
				
				system.debug('*****BatchProcessDelayNotifications maxCases = ' + maxCases + ' intervalHours = ' + intervalHours);
				
				String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
							nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
							nextRunTime.month() + ' ? ' + nextRunTime.year(); 
				
				if (!Test.isRunningTest()) {
					System.schedule(ScheduleBatchProcessDelayNotifications.class.getName() + '-' + nextRunTime.format(), cronString, new ScheduleBatchProcessDelayNotifications(maxCases));
				}
			}
		}
    }
}