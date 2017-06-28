/*
 *	Methods to test Case_ReturnReceiptCtlExt.cls, ReturnReceipt.cls, Case_Accept.cls and related classes/methods
 *
 */

@isTest
private class testCase_ReturnReceiptCtlExt {
	
	// Create Return Receipt test data
	@testSetup static void rrTestData() {
		
		PrepareData.populateCustomSettings();
		
		Map<String, Schema.RecordTypeInfo> rtAccMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
		List<Account> accList = new List<Account>();
		accList.add(new Account(Name = 'RH DC 97 (SoCal)', RecordTypeId = rtAccMap.get('Internal').getRecordTypeId(), HDL_Code__c = '97'));
		accList.add(new Account(Name = 'RH DC 89 (OH)', RecordTypeId = rtAccMap.get('Internal').getRecordTypeId(), HDL_Code__c = '89'));
		insert accList;
		
		Account galleryAcc = new Account(Name = 'Gallery 006 - Corte Madera', RecordTypeId = rtAccMap.get('Internal').getRecordTypeId(), Email__c = 'cortemadera@rh.com', Furniture_Return_DC__c = accList[0].Id, Shelf_Stock_Return_DC__c = accList[1].Id);
		insert galleryAcc;
		
		User u = [select Id, Gallery__c from User where Id = :UserInfo.getUserId()];
		u.Gallery__c = 'Gallery 006 - Corte Madera';
		update u;
		
		RH_Order__c order = PrepareData.createOrder('rroT1');
		insert order;
		
		Ship_To__c shipTo = PrepareData.createShipTo(order.Id, '1');
		insert shipTo;
		
		PrepareData.productClass p0 = PrepareData.createProduct('57360001BLPM', 1743.50, '57360001BLPM', 6395.00);
		PrepareData.productClass p1 = PrepareData.createProduct('23750121PN', 211.58, '23750121PN', 625.00);
		PrepareData.productClass p2 = PrepareData.createProduct('17050043EUCY', 4.26, '17050043EUCY', 20);
		List<Product2> pList = new List<Product2>();
		p0.p.SKU_Ship_Via__c = '5';
		pList.add(p0.p);
		p1.p.Fulfilling_Warehouse__c = 'F';
		pList.add(p1.p);
		p2.p.Fulfilling_Warehouse__c = 'S';
		pList.add(p2.p);
		update pList;
		
		List<Order_Line_Items__c> oliList = new List<Order_Line_Items__c>();
		oliList.add(PrepareData.createOrderLine(order.Id, shipTo.Id, '1', p0.p.Id));
		oliList.add(PrepareData.createOrderLine(order.Id, shipTo.Id, '2', p1.p.Id));
		oliList.add(PrepareData.createOrderLine(order.Id, shipTo.Id, '3', p2.p.Id));
		for (Order_Line_Items__c oli :oliList) {
			oli.Shipped_Quantity__c = 2;
		}
		insert oliList;
		
		Map<String, Schema.RecordTypeInfo> rtCaseMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
		Case returnCase = new Case(
			RecordTypeId = rtCaseMap.get('Returns').getRecordTypeId(),
			RH_Order_Number__c = order.Id,
			Status = 'New'
		);
		insert returnCase;
		
		
	}
	
	static testMethod void rrTest1() {
		
		Map<String, Schema.RecordTypeInfo> rtCaseMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
		Case returnCase = [select Id from Case where RecordTypeId = :rtCaseMap.get('Returns').getRecordTypeId()];
		
		Test.startTest();
		
		// Instantiate the controller extension and start testing
		ApexPages.StandardController std = new ApexPages.StandardController(returnCase);
		ApexPages.currentPage().getParameters().put('caseId', returnCase.Id);
		Case_ReturnReceiptCtlExt ctl = new Case_ReturnReceiptCtlExt(std);
		
		ctl.rhCase.Send_To__c = 'Sold To';
		ctl.saveCaseandCaseLine();
		
		returnCase = [select Id, Return_Location__c, Send_To__c, RH_Order_Number__r.Sold_to_Email__c, To_Email_Address__c from Case where Id = :returnCase.Id];
		system.assertEquals('Gallery 006 - Corte Madera', returnCase.Return_Location__c);
		system.assertEquals('Sold To', returnCase.Send_To__c);
		system.assertEquals(returnCase.RH_Order_Number__r.Sold_to_Email__c, ctl.rhCase.To_Email_Address__c);
		
		// Select a few order lines and verify that they are added as case lines
		ctl.selectOrderLines();
		List<Case_ReturnReceiptCtlExt.SelectOrderLineClass> availableOrderLines = ctl.getOrderLines();
		for (Case_ReturnReceiptCtlExt.SelectOrderLineClass oli :availableOrderLines) {
			oli.selected = true;
		}
		ctl.getSelected();
		List<Case_ReturnReceiptCtlExt.SelectOrderLineClass> selectedOrderLines = ctl.getselectedOrderLines();
		system.assertEquals(3, selectedOrderLines.size());
		for (Case_ReturnReceiptCtlExt.SelectOrderLineClass oli :selectedOrderLines) {
			oli.returnItem.rtnItem.Quantity_Returned__c = 1;
			oli.returnItem.rtnItem.Return_Reason__c = 'Arrived Too Late';
		}
		system.assertEquals(0, ctl.rhCaseLineList.size());
		selectedOrderLines[0].solcQuantityChanged();
		selectedOrderLines[0].returnItem.rtnItem.Exchange__c = true;
		selectedOrderLines[0].returnItem.toggleExchange();
		
		Product2 psearch = [select Id, Name from Product2 where Name = '57360001BLPM'];
		List<Id> pIds = new List<Id>();
		pIds.add(psearch.Id);
		Test.setFixedSearchResults(pIds);
		
		selectedOrderLines[0].returnItem.exchList[0].productSearchString = '57360001BLPM';
		selectedOrderLines[0].returnItem.exchList[0].executeProductSearch();
		system.assertEquals(1, selectedOrderLines[0].returnItem.exchList[0].searchResults.size());
		selectedOrderLines[0].returnItem.exchList[0].searchResults[0].selectedProduct();
		
		ctl.createCaseLines();
		system.assertEquals(3, ctl.rhCaseLineList.size());
		
		// Edit the Return Items and do a price override
		ctl.editReturnItems();
		ctl.rwList[0].rtns[0].rtnItem.Exchange__c = false;
		ctl.rwList[0].rtns[0].toggleExchange();
		ctl.rwList[0].rtns[0].exchList[0].clearExchItem(ctl.rwList[0].rtns[0].exchList[0]);
		ctl.rwList[0].rtns[0].quantityChanged();
		ctl.cancelEdit();
		ctl.rwList[0].rtns[0].exchList[0].displayProductSearch();
		ctl.rwList[0].rtns[0].exchList[0].cancelProductSearch();
		
		ctl.saveCaseandCaseLine();
		ctl.rwList[2].rtns[0].deleteReturnItem();
		system.assert(!ctl.approvalRequired);
		system.assertEquals(2, ctl.rwList.size());
		
		Account cmAccount = new Account();
		cmAccount = [select Id, Name, Furniture_Return_DC__c, Furniture_Return_DC__r.HDL_Code__c, Shelf_Stock_Return_DC__c, Shelf_Stock_Return_DC__r.HDL_Code__c from Account where Name = 'Gallery 006 - Corte Madera'];
		for (Case_Line_Items__c cli :ctl.rhCaseLineList) {
			system.assertEquals(true, String.isNotBlank(cli.Return_DC__c));
			if (cli.CW_SKU_ID__r.SKU_Ship_Via__c == '5' || cli.CW_SKU_ID__r.SKU_Ship_Via__c == '6') {
				system.assertEquals('HDL', cli.Return_DC__c);
			} else {
				if (cli.CW_SKU_ID__r.Fulfilling_Warehouse__c == 'F') {
					system.assertEquals(cmAccount.Furniture_Return_DC__r.HDL_Code__c, cli.Return_DC__c);
				}
				if (cli.CW_SKU_ID__r.Fulfilling_Warehouse__c == 'S') {
					system.assertEquals(cmAccount.Shelf_Stock_Return_DC__r.HDL_Code__c, cli.Return_DC__c);
				}
			}
		}
		
		// Edit and Cancel
		ctl.editReturn();
		ctl.cancelEdit();
		
		
		// Send the Return Receipt and attach as PDF
		ctl.sendReturnReceipt();
		ctl.attachPdf();
		
		// Transfer case to the gallery queue
		ctl.transferGallery();
		List<Id> caseIds = new List<Id>();
		caseIds.add(returnCase.Id);
		Case_Accept.acceptCases(caseIds);
		
		// Test the packing slip functionality
		ctl.getpackingSlipDCList();
		ctl.setselectedPackingSlipDC('HDL');
		ctl.psSelect();
		String DC = ctl.getselectedPackingSlipDC();
		
		// Run through the left over code
		ctl.misShip();
		ctl.cancelReturnReceipt();
		ctl.transferCSC();
		
		Test.stopTest();
	}
	
	// Test the Approval Process related methods
	static testMethod void rrTest2() {
		
		Map<String, Schema.RecordTypeInfo> rtCaseMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
		Case returnCase = [select Id from Case where RecordTypeId = :rtCaseMap.get('Returns').getRecordTypeId()];
		
		Test.startTest();
		
		// Instantiate the controller extension and start testing
		ApexPages.StandardController std = new ApexPages.StandardController(returnCase);
		ApexPages.currentPage().getParameters().put('caseId', returnCase.Id);
		Case_ReturnReceiptCtlExt ctl = new Case_ReturnReceiptCtlExt(std);
		
		ctl.rhCase.Send_To__c = 'Sold To';
		ctl.saveCaseandCaseLine();
		
		returnCase = [select Id, Return_Location__c, Send_To__c, RH_Order_Number__r.Sold_to_Email__c, To_Email_Address__c from Case where Id = :returnCase.Id];
		system.assertEquals('Gallery 006 - Corte Madera', returnCase.Return_Location__c);
		system.assertEquals('Sold To', returnCase.Send_To__c);
		system.assertEquals(returnCase.RH_Order_Number__r.Sold_to_Email__c, ctl.rhCase.To_Email_Address__c);
		
		// Select a few order lines and verify that they are added as case lines
		ctl.selectOrderLines();
		List<Case_ReturnReceiptCtlExt.SelectOrderLineClass> availableOrderLines = ctl.getOrderLines();
		for (Case_ReturnReceiptCtlExt.SelectOrderLineClass oli :availableOrderLines) {
			oli.selected = true;
		}
		ctl.getSelected();
		List<Case_ReturnReceiptCtlExt.SelectOrderLineClass> selectedOrderLines = ctl.getselectedOrderLines();
		system.assertEquals(3, selectedOrderLines.size());
		for (Case_ReturnReceiptCtlExt.SelectOrderLineClass oli :selectedOrderLines) {
			oli.returnItem.rtnItem.Quantity_Returned__c = 1;
			oli.returnItem.rtnItem.Return_Reason__c = 'Arrived Too Late';
		}
		system.assertEquals(0, ctl.rhCaseLineList.size());
		selectedOrderLines[0].solcQuantityChanged();
		selectedOrderLines[0].returnItem.rtnItem.Exchange__c = true;
		selectedOrderLines[0].returnItem.toggleExchange();
		
		Product2 psearch = [select Id, Name from Product2 where Name = '23750121PN'];
		List<Id> pIds = new List<Id>();
		pIds.add(psearch.Id);
		Test.setFixedSearchResults(pIds);
		
		selectedOrderLines[0].returnItem.exchList[0].productSearchString = '23750121PN';
		selectedOrderLines[0].returnItem.exchList[0].executeProductSearch();
		system.assertEquals(1, selectedOrderLines[0].returnItem.exchList[0].searchResults.size());
		selectedOrderLines[0].returnItem.exchList[0].searchResults[0].selectedProduct();
		
		ctl.createCaseLines();
		system.assertEquals(3, ctl.rhCaseLineList.size());
		
		// Edit the Return Items and do a price override
		ctl.editReturnItems();
		
		ctl.rwList[0].rtns[0].rtnItem.Price_Override_Type__c = 'New Price';
		ctl.rwList[0].rtns[0].rtnItem.Price_Override_Amount__c = 10;
		ctl.rwList[0].rtns[0].exchList[0].exchQuantityChanged();
		ctl.rwList[0].rtns[0].rtnItem.Price_Override_Type__c = 'Amt off';
		ctl.rwList[0].rtns[0].exchList[0].exchQuantityChanged();
		ctl.rwList[0].rtns[0].rtnItem.Price_Override_Type__c = '';
		ctl.rwList[0].rtns[0].exchList[0].exchQuantityChanged();
		ctl.rwList[0].rtns[0].rtnItem.Price_Override_Type__c = '% off';
		ctl.rwList[0].rtns[0].rtnItem.Price_Override_Amount__c = 10;
		ctl.rwList[0].rtns[0].rtnItem.Price_Override_Reason__c = 'G - Price Adjustment';
		
		ctl.saveCaseandCaseLine();
		system.assert(ctl.approvalRequired);
		
		// Submit for approval
		ctl.submitApproval();
		returnCase = [select Id, Exchange_Approval_Status__c, Exchange_Approval_Rejection_Reason__c from Case where Id = :returnCase.Id];
		system.assertEquals('Pending', returnCase.Exchange_Approval_Status__c);
		
		ApexPages.StandardController std1 = new ApexPages.StandardController(returnCase);
		ApexPages.currentPage().getParameters().put('caseId', returnCase.Id);
		Case_ReturnReceiptCtlExt ctl1 = new Case_ReturnReceiptCtlExt(std1);
		
		ctl1.approveReject();
		ctl1.rhCase.Exchange_Approval_Rejection_Reason__c = 'Discount Not Approved';
		ctl1.rejectExch();
		
		returnCase = [select Id, Exchange_Approval_Status__c, Exchange_Approval_Rejection_Reason__c from Case where Id = :returnCase.Id];
		system.assertEquals('Rejected', returnCase.Exchange_Approval_Status__c);
		
		Test.stopTest();
	}
}