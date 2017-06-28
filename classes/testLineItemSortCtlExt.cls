@isTest

/*
 *	Methods to test LineItemSortCtlExt.cls
 *
 */
 
private class testLineItemSortCtlExt {
	
	// Create test data
	@testSetup static void lisTestData() {
		
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
	
	static testMethod void lisTest1() {
		
		Opportunity opp = [select Id from Opportunity];
		
		// Instantiate the controller extension and start testing
		ApexPages.StandardController std = new ApexPages.StandardController(opp);
		ApexPages.currentPage().getParameters().put('id', opp.Id);
		ApexPages.currentPage().getParameters().put('retURL', '/' + opp.Id);
		LineItemSortCtlExt ctl = new LineItemSortCtlExt(std);
		
		// Select a line item
		List<LineItemSortCtlExt.LineItemWrapper> availLineItems = ctl.getLineItems();
		system.assertEquals(3, availLineItems.size());
		
		availLineItems[0].selected = true;
		ctl.getSelected();
		List<LineItemSortCtlExt.LineItemWrapper> selLineItems = ctl.getselectedLineItems();
		system.assertEquals(1, selLineItems.size());
		
		// Move the line item about
		system.assertEquals(1, selLineItems[0].oli.Sort_Order__c);
		ctl.bottom();
		selLineItems = ctl.getselectedLineItems();
		system.assertEquals(3, selLineItems[0].oli.Sort_Order__c);
		ctl.up();
		selLineItems = ctl.getselectedLineItems();
		system.assertEquals(2, selLineItems[0].oli.Sort_Order__c);
		ctl.down();
		selLineItems = ctl.getselectedLineItems();
		system.assertEquals(3, selLineItems[0].oli.Sort_Order__c);
		ctl.top();
		selLineItems = ctl.getselectedLineItems();
		system.assertEquals(1, selLineItems[0].oli.Sort_Order__c);
		
		// Save the sorted line items
		ctl.saveSortedLines();
	}
	
	static testMethod void lisTest2() {
		
		Quote qt = [select Id from Quote];
		
		// Instantiate the controller extension and start testing
		ApexPages.StandardController std = new ApexPages.StandardController(qt);
		ApexPages.currentPage().getParameters().put('id', qt.Id);
		ApexPages.currentPage().getParameters().put('retURL', '/' + qt.Id);
		LineItemSortCtlExt ctl = new LineItemSortCtlExt(std);
		
		// Select a line item
		List<LineItemSortCtlExt.LineItemWrapper> availLineItems = ctl.getLineItems();
		system.assertEquals(3, availLineItems.size());
		
		availLineItems[0].selected = true;
		ctl.getSelected();
		List<LineItemSortCtlExt.LineItemWrapper> selLineItems = ctl.getselectedLineItems();
		system.assertEquals(1, selLineItems.size());
		
		// Move the line item about
		system.assertEquals(1, selLineItems[0].qli.Sort_Order__c);
		ctl.bottom();
		selLineItems = ctl.getselectedLineItems();
		system.assertEquals(3, selLineItems[0].qli.Sort_Order__c);
		ctl.up();
		selLineItems = ctl.getselectedLineItems();
		system.assertEquals(2, selLineItems[0].qli.Sort_Order__c);
		ctl.down();
		selLineItems = ctl.getselectedLineItems();
		system.assertEquals(3, selLineItems[0].qli.Sort_Order__c);
		ctl.top();
		selLineItems = ctl.getselectedLineItems();
		system.assertEquals(1, selLineItems[0].qli.Sort_Order__c);
		
		// Save the sorted line items
		ctl.saveSortedLines();
	}
}