@isTest
private class testCase_AcceptCases {
	
	/*
	 *	Test methods for Case_AcceptCases.cls
	 *
	 */
	
	// Create test data
	@testSetup static void cacTestData() {
		
		PrepareData.populateCustomSettings();
		
		List<Group> queueList = new List<Group>();
		queueList = [select Id, DeveloperName, Type from Group where Type = 'Queue' and DeveloperName = 'RH_Email_Advocates'];
		
		Map<String, Schema.RecordTypeInfo> rtByNameMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
		List<Case> caseList = new List<Case>();
		caseList.add(new Case(
			Status = 'In Progress',
			Flat_Rate_Accommodation_Amount__c = 100,
			RecordTypeId = rtByNameMap.get('Accommodations - Order Header').getRecordTypeId())
		);
		caseList.add(new Case(
			Status = 'In Progress',
			RecordTypeId = rtByNameMap.get('Email and Web Inquiries').getRecordTypeId(),
			OwnerId = queueList[0].Id)
		);
		insert caseList;
	}
	
	static testMethod void cacTest1() {
		
		List<Case> caseList = [select Id from Case];
		Case_AcceptCases ctl = new Case_AcceptCases(new ApexPages.StandardSetController(caseList));
		
		// Test with no cases selected
		ctl.selectedCases = new List<Case>();
		ctl.acceptCases();
		
		// Test with 2 cases selected, one already owned by a user
		ctl.selectedCases = [select Id, CaseNumber, OwnerId, RecordTypeId from Case];
		system.assertEquals(2, ctl.selectedCases.size());
		ctl.acceptCases();
		
		// Test with 2 cases selected, one with record type Email and Web Inquiries
		Map<Id, Schema.RecordTypeInfo> rtByIdMap = Schema.SObjectType.Case.getRecordTypeInfosById();
		List<Group> queueList = new List<Group>();
		queueList = [select Id, DeveloperName, Type from Group where Type = 'Queue' and DeveloperName = 'Accommodations_Queue'];
		caseList = [select Id, OwnerId, RecordTypeId from Case];
		for (Case c :caseList) {
			if (rtByIdMap.get(c.RecordTypeId).getName() == 'Accommodations - Order Header') {
				c.OwnerId = queueList[0].Id;
			}
		}
		update caseList;
		ctl.selectedCases = [select Id, CaseNumber, OwnerId, RecordTypeId from Case];
		ctl.acceptCases();
		
		// Test with one selected case
		ctl.selectedCases = [select Id, CaseNumber, OwnerId, RecordTypeId from Case limit 1];
		ctl.acceptCases();
		Case acceptedCase = [select Id, OwnerId from Case where Id = :ctl.selectedCases[0].Id];
		system.assertEquals(UserInfo.getUserId(), acceptedCase.OwnerId);
	}
}