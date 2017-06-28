@isTest
private class testOperationsRequestLineItemCtlExt {
	
	/*
	 *	Test methods for OperationsRequestLineItemCtlExt.cls and OperationsRequestLineItem_EditAllCtlExt.cls
	 */
	
	// Create Delay Notification test data
	@testSetup static void dnTestData() {
		
		PrepareData.populateCustomSettings();
		
		Account acc = PrepareData.createAccount();
		insert acc;
		
		Contact con = PrepareData.createContact(acc.Id);
		insert con;
		
		PrepareData.productClass p1 = PrepareData.createProduct('63420784BRN', 100, '63420784BRN', 100);
		PrepareData.productClass p2 = PrepareData.createProduct('17050042WHT', 100, '17050042WHT', 100);
		PrepareData.productClass p3 = PrepareData.createProduct('63190021WHT', 100, '63190021WHT', 100);
		PrepareData.productClass p4 = PrepareData.createProduct('62210002NATL', 100, '62210002NATL', 100);
		
		Opportunity opp = PrepareData.createOpportunity(acc.Id);
		opp.Ops_Contact__c = UserInfo.getUserId();
		insert opp;
		
		List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
		oliList.add(PrepareData.createOLI(10, opp.Id, 100, p1.pbe.Id, 2));
		oliList.add(PrepareData.createOLI(10, opp.Id, 100, p2.pbe.Id, 2));
		oliList.add(PrepareData.createOLI(10, opp.Id, 100, p3.pbe.Id, 2));
		oliList.add(PrepareData.createOLI(10, opp.Id, 100, p4.pbe.Id, 2));
		insert oliList;
	}
	
	static testMethod void oprTest1() {
		
		Opportunity opp = [select Id from Opportunity limit 1];
		
		List<Operations_Request__c> oprList = new List<Operations_Request__c>();
		oprList.add(new Operations_Request__c(
			Opportunity__c = opp.Id)
		);
		insert oprList;
		
		// Now test the controller extension - test bad page parameters
    	ApexPages.StandardController std = new ApexPages.StandardController(oprList[0]);
		OperationsRequestLineItemCtlExt ctl = new OperationsRequestLineItemCtlExt(std);
		
		// Test controller with good page parameters but bad notification type
		std = new ApexPages.StandardController(oprList[0]);
		ApexPages.currentPage().getParameters().put('orId', oprList[0].Id);
		ApexPages.currentPage().getParameters().put('retURL', '/' + oprList[0].Id);
		ctl = new OperationsRequestLineItemCtlExt(std);
	}
}