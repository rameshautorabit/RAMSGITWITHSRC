@isTest
private class testOpportunityCloneCtlExt {
	
	/*
	 *	Test methods for OpportunityCloneCtlExt and OpportunityCloneProductCtlExt.
	 */
	
	// Create test data
	@testSetup static void cacTestData() {
		
		PrepareData.populateCustomSettings();
		
		Account acc = PrepareData.createAccount();
		insert acc;
		
		Contact cn = PrepareData.createContact(acc.Id);
		insert cn;
		
		Opportunity opp = PrepareData.createOpportunity(acc.Id);
		insert opp;
		
		List<PrepareData.productClass> pcList = new List<PrepareData.productClass>();
		pcList.add(PrepareData.createProduct('testProduct1', 90, 'testProduct1', 100));
		pcList.add(PrepareData.createProduct('testProduct2', 95, 'testProduct2', 105));
		
		List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
		oliList.add(PrepareData.createOLI(0, opp.Id, pcList[0].p.Direct_Current_Price__c, pcList[0].pbe.Id, 1));
		oliList.add(PrepareData.createOLI(0, opp.Id, pcList[1].p.Direct_Current_Price__c, pcList[1].pbe.Id, 1));
		insert oliList;
	}
	
	static testMethod void oppCloneTest1() {
		
		// Test OpportunityCloneCtlExt
		Opportunity oppToClone = [select Id, Name, AccountId, CloseDate, StageName from Opportunity limit 1];
		List<OpportunityLineItem> oliToCloneList = new List<OpportunityLineItem>();
		oliToCloneList = [select Id from OpportunityLineItem where OpportunityId = :oppToClone.Id];
		
		PageReference pr = Page.OpportunityClone;
		Test.setCurrentPage(pr);
		ApexPages.currentPage().getParameters().put('oppId', oppToClone.Id);
		ApexPages.currentPage().getParameters().put('retURL', '/' + oppToClone.Id);
		
		ApexPages.StandardController std = new ApexPages.StandardController(oppToClone);
		OpportunityCloneCtlExt ctl = new OpportunityCloneCtlExt(std);
		
		ctl.executeClone();
		
		// Test OpportunityCloneProductCtlExt
		Opportunity clonedOpp = oppToClone.clone(false, true, false, false);
		clonedOpp.Cloned_From__c = oppToClone.Id;
		insert clonedOpp;
		
		pr = Page.OpportunityCloneProduct;
		Test.setCurrentPage(pr);
		ApexPages.currentPage().getParameters().put('oppId', clonedOpp.Id);
		ApexPages.currentPage().getParameters().put('retURL', '/' + clonedOpp.Id);
		
		ApexPages.StandardController std1 = new ApexPages.StandardController(clonedOpp);
		OpportunityCloneProductCtlExt ctl1 = new OpportunityCloneProductCtlExt(std1);
		
		ctl1.executeClone();
		
		List<OpportunityLineItem> clonedOliList = new List<OpportunityLineItem>();
		clonedOliList = [select Id from OpportunityLineItem where OpportunityId = :clonedOpp.Id];
		system.assertEquals(oliToCloneList.size(), clonedOliList.size());
	}
}