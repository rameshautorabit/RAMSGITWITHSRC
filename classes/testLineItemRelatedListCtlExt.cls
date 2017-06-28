@isTest

/*
 *	Methods to test LineItemRelatedListCtlExt.cls
 *
 */
 
private class testLineItemRelatedListCtlExt {
	
	// Create test data
	@testSetup static void lirlTestData() {
		
		PrepareData.populateCustomSettings();
		
		Account acc = PrepareData.createAccount();
		insert acc;
		
		Contact con = PrepareData.createContact(acc.Id);
		insert con;
		
		PrepareData.productClass p0 = PrepareData.createProduct('57360001BLPM', 1743.50, '57360001BLPM', 6395.00);
		PrepareData.productClass p1 = PrepareData.createProduct('23750121PN', 211.58, '23750121PN', 625.00);
		PrepareData.productClass p2 = PrepareData.createProduct('17050043EUCY', 4.26, '17050043EUCY', 20);
		
		Opportunity opp = PrepareData.createOpportunity(acc.Id);
		insert opp;
		
		List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
		oliList.add(PrepareData.createOLI(10, opp.Id, p0.p.Direct_Current_Price__c, p0.pbe.Id, 1));
		oliList.add(PrepareData.createOLI(10, opp.Id, p1.p.Direct_Current_Price__c, p1.pbe.Id, 1));
		oliList.add(PrepareData.createOLI(10, opp.Id, p2.p.Direct_Current_Price__c, p2.pbe.Id, 1));
		insert oliList;
		
		Quote qt = PrepareData.createQuote(UserInfo.getUserId(), con.Id, opp.Id, UserInfo.getUserId(), 'Standard');
		qt.Pricebook2Id = Test.getStandardPricebookId();
		insert qt;
		
		List<QuoteLineItem> qliList = new List<QuoteLineItem>();
		qliList.add(PrepareData.createQLI(qt.Id, p0.p.Direct_Current_Price__c, p0.pbe.Id, 1));
		qliList.add(PrepareData.createQLI(qt.Id, p1.p.Direct_Current_Price__c, p1.pbe.Id, 1));
		qliList.add(PrepareData.createQLI(qt.Id, p2.p.Direct_Current_Price__c, p2.pbe.Id, 1));
		insert qliList;
	}
	
	static testMethod void lirlTest1() {
		
		Opportunity opp = [select Id from Opportunity];
		
		// Instantiate the controller extension and start testing
		ApexPages.StandardController std = new ApexPages.StandardController(opp);
		LineItemRelatedListCtlExt ctl = new LineItemRelatedListCtlExt(std);
		
		// Get the line items
		List<LineItemRelatedListCtlExt.LineItemWrapper> lineItems = ctl.getLineItems();
		system.assertEquals(3, lineItems.size());
		
		ctl.deleteId = lineItems[0].oli.Id;
		ctl.deleteLine();
		lineItems = ctl.getLineItems();
		system.assertEquals(2, lineItems.size());
		for (LineItemRelatedListCtlExt.LineItemWrapper liw :lineItems) {
			system.assertNotEquals(ctl.deleteId, liw.oli.Id);
		}
	}
	
	static testMethod void lirlTest2() {
		
		Quote qt = [select Id from Quote];
		
		// Instantiate the controller extension and start testing
		ApexPages.StandardController std = new ApexPages.StandardController(qt);
		LineItemRelatedListCtlExt ctl = new LineItemRelatedListCtlExt(std);
		
		// Get the line items
		List<LineItemRelatedListCtlExt.LineItemWrapper> lineItems = ctl.getLineItems();
		system.assertEquals(3, lineItems.size());
		
		ctl.deleteId = lineItems[0].qli.Id;
		ctl.deleteLine();
		lineItems = ctl.getLineItems();
		system.assertEquals(2, lineItems.size());
		for (LineItemRelatedListCtlExt.LineItemWrapper liw :lineItems) {
			system.assertNotEquals(ctl.deleteId, liw.qli.Id);
		}
	}
}