@isTest
private class testCaseComment_NewCtlExt {
	
	/*
	 *	Test methods for CaseComment_NewCtlExt.cls
	 *
	 */
	
	// Create test data
	@testSetup static void ccnTestData() {
		
		PrepareData.populateCustomSettings();
		
		Map<String, Schema.RecordTypeInfo> rtByNameMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
		List<Case> caseList = new List<Case>();
		caseList.add(new Case(
			Status = 'In Progress',
			RecordTypeId = rtByNameMap.get('Delivery & Return Support').getRecordTypeId())
		);
		caseList.add(new Case(
			Status = 'In Progress',
			RecordTypeId = rtByNameMap.get('Email and Web Inquiries').getRecordTypeId())
		);
		insert caseList;
		
		RH_Order__c order = PrepareData.createOrder('ccnTest');
		insert order;
	}
	
    static testMethod void ccnTest1() {
		
		List<Case> caseList = [select Id, CaseNumber, RecordTypeId from Case];
		List<RH_Order__c> orderList = [select Id, Name, RecordTypeId from RH_Order__c];
		List<Case_Comments__c> ccList = new List<Case_Comments__c>();
		
		// Test controller with no page parameters
		CaseComment_NewCtlExt ctl = new CaseComment_NewCtlExt(new ApexPages.StandardSetController(ccList));
		ctl.newCaseComment();
		
		// Test controller with a Case Id
		ApexPages.currentPage().getParameters().put('id', caseList[0].Id);
		ctl = new CaseComment_NewCtlExt(new ApexPages.StandardSetController(ccList));
		ctl.newCaseComment();
		
		// Test controller with an Order Id
		ApexPages.currentPage().getParameters().put('id', orderList[0].Id);
		ctl = new CaseComment_NewCtlExt(new ApexPages.StandardSetController(ccList));
		ctl.newCaseComment();
    }
}