@isTest
private class testOperationsRequest {
	
	/*
	 *	Test methods for Operations Request functionality. Classes and triggers tested:
	 *		- OperationsRequestLineItemCtlExt.cls
	 *		- OperationsRequestLineItem_EditAllCtlExt.cls
	 */
	
	// Create Operations Request test data
	@testSetup static void oprTestData() {
		
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
	
	// Test OpportunityLineItem selection methods
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
		ctl.cancel();
		
		// Test controller with good page parameters
		std = new ApexPages.StandardController(oprList[0]);
		ApexPages.currentPage().getParameters().put('orId', oprList[0].Id);
		ApexPages.currentPage().getParameters().put('retURL', '/' + oprList[0].Id);
		ctl = new OperationsRequestLineItemCtlExt(std);
		PageReference pr;
		
		String sortCol = ctl.oliColumnName;
		ApexPages.currentPage().getParameters().put('columnSort', sortCol);
		pr = ctl.sortOLIcolumn();
		
		String rows = ctl.getRowsPerPage();
		ctl.setRowsPerPage('1');
		pr = ctl.rowsPerPageChanged();
		pr = ctl.nextSet();
		pr = ctl.previousSet();
		pr = ctl.lastSet();
		pr = ctl.firstSet();
		ctl.setRowsPerPage('10');
		pr = ctl.rowsPerPageChanged();
		rows = ctl.getRowsPerPage();
		system.assertEquals('4', rows);
		
		pr = ctl.toggleView();
		system.assert(ctl.productView);
		pr = ctl.toggleView();
		system.assert(!ctl.productView);
		
		List<OperationsRequestLineItemCtlExt.SelectOpportunityLineItemClass> oppLineItems = ctl.getOppLineItems();
		system.assertEquals(4, oppLineItems.size());
		oppLineItems[0].selected = true;
		pr = ctl.getSelected();
		List<OperationsRequestLineItemCtlExt.SelectOpportunityLineItemClass> selectedLineItems = ctl.getselectedOppLineItems();
		system.assertEquals(1, selectedLineItems.size());
		
		pr = ctl.saveAndMoreOppLineItems();
		oppLineItems = ctl.getOppLineItems();
		system.assertEquals(3, oppLineItems.size());
		oppLineItems[0].selected = true;
		oppLineItems[1].selected = true;
		pr = ctl.getSelected();
		selectedLineItems = ctl.getselectedOppLineItems();
		system.assertEquals(2, selectedLineItems.size());
		pr = ctl.saveOppLineItems();
		
		ctl.cancel();
	}
	
	// Test Product selection methods
	static testMethod void oprTest2() {
		
		List<Operations_Request__c> oprList = new List<Operations_Request__c>();
		oprList.add(new Operations_Request__c());
		insert oprList;
		
		// Test controller
		ApexPages.StandardController std = new ApexPages.StandardController(oprList[0]);
		ApexPages.currentPage().getParameters().put('orId', oprList[0].Id);
		ApexPages.currentPage().getParameters().put('retURL', '/' + oprList[0].Id);
		OperationsRequestLineItemCtlExt ctl = new OperationsRequestLineItemCtlExt(std);
		PageReference pr;
		
		ctl.productSearchString = '63420784BRN,17050042WHT';
		pr = ctl.searchProducts();
		Integer productsFound = ctl.productMap.size();
		system.assert(productsFound > 1);
		for (Id pId :ctl.productMap.keySet()) {
			ctl.toSelect = pId;
		}
		pr = ctl.addOneProduct();
		system.assertEquals(1, ctl.newProductMap.size());
		pr = ctl.removeOneProduct();
		system.assertEquals(0, ctl.newProductMap.size());
		pr = ctl.addAllProducts();
		system.assertEquals(productsFound, ctl.newProductMap.size());
		pr = ctl.removeAllProducts();
		system.assertEquals(0, ctl.newProductMap.size());
		
		pr = ctl.addOneProduct();
		system.assertEquals(1, ctl.newProductMap.size());
		pr = ctl.saveAndMoreProducts();
		pr = ctl.addAllProducts();
		system.assertEquals(productsFound - 1, ctl.newProductMap.size());
		pr = ctl.saveProducts();
	}
	
	// Test edit all functionality
	static testMethod void oprTest3() {
		
		Opportunity opp = [select Id from Opportunity limit 1];
		List<OpportunityLineItem> oliList = [select Id, OpportunityId from OpportunityLineItem where OpportunityId = :opp.Id];
		
		List<Operations_Request__c> oprList = new List<Operations_Request__c>();
		oprList.add(new Operations_Request__c(
			Opportunity__c = opp.Id)
		);
		insert oprList;
		
		// Now test the controller extension - test bad page parameters
    	ApexPages.StandardController std = new ApexPages.StandardController(oprList[0]);
		OperationsRequestLineItem_EditAllCtlExt ctl = new OperationsRequestLineItem_EditAllCtlExt(std);
		
		// Test controller with good page parameters but no operations request line items
		std = new ApexPages.StandardController(oprList[0]);
		ApexPages.currentPage().getParameters().put('orId', oprList[0].Id);
		ApexPages.currentPage().getParameters().put('retURL', '/' + oprList[0].Id);
		ctl = new OperationsRequestLineItem_EditAllCtlExt(std);
		system.assert(ctl.noLines);
		
		// Test controller with operations request line items
		List<Operations_Request_Line_Item__c> oprLineList = new List<Operations_Request_Line_Item__c>();
		for (OpportunityLineItem oli :oliList) {
			oprLineList.add(new Operations_Request_Line_Item__c(
				Operations_Request__c = oprList[0].Id,
				Opportunity_Product_Id__c = oli.Id)
			);
		}
		insert oprLineList;
		
		std = new ApexPages.StandardController(oprList[0]);
		ApexPages.currentPage().getParameters().put('orId', oprList[0].Id);
		ApexPages.currentPage().getParameters().put('retURL', '/' + oprList[0].Id);
		ctl = new OperationsRequestLineItem_EditAllCtlExt(std);
		system.assert(!ctl.noLines);
		
		List<Operations_Request_Line_Item__c> ctlOprLineList = ctl.getOpReqLines();
		system.assertEquals(ctlOprLineList.size(), oprLineList.size());
		
		String rows = ctl.getRowsPerPage();
		ctl.setRowsPerPage('1');
		PageReference pr;
		pr = ctl.rowsPerPageChanged();
		pr = ctl.nextSet();
		pr = ctl.previousSet();
		pr = ctl.lastSet();
		pr = ctl.firstSet();
		ctl.setRowsPerPage('10');
		
		pr = ctl.saveAndMore();
		pr = ctl.save();
	}
}