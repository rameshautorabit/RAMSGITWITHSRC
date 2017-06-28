trigger DateRangeHold on Date_Range_Hold__c (after delete, after insert, after undelete, after update) {
	
	/*
	 *	Based upon the new/changed date range hold records, update the on hold state of
	 *	Delay Notifications cases.
	 *
	 */
	
	List<Date_Range_Hold__c> drhList = new List<Date_Range_Hold__c>();
	if (trigger.isDelete) {
		drhList.addAll(trigger.old);
	} else {
		drhList.addAll(trigger.new);
	}

	Boolean changeHoldState = false;
	for (Date_Range_Hold__c drh :drhList) {
		if (trigger.isInsert || trigger.isUndelete || trigger.isDelete) {
			if (drh.Active__c && drh.Start_Date__c <= system.today() && drh.End_Date__c > system.today()) {
				changeHoldState = true;
			}
		}
		
		if (trigger.isUpdate) {
			if (	(	(drh.Active__c != trigger.oldMap.get(drh.Id).Active__c) || 
						(drh.Start_Date__c != trigger.oldMap.get(drh.Id).Start_Date__c) ||
						(drh.End_Date__c != trigger.oldMap.get(drh.Id).End_Date__c)	) && 
					(	(drh.Start_Date__c <= system.today() && drh.End_Date__c > system.today()) || 
						(trigger.oldMap.get(drh.Id).Start_Date__c <= system.today() && trigger.oldMap.get(drh.Id).End_Date__c > system.today())	)	) {
				changeHoldState = true;
			}
		}
	}
	
	if (changeHoldState) {
		DelayNotificationsHold batch = new DelayNotificationsHold(); 
		Database.executeBatch(batch);
	}
}