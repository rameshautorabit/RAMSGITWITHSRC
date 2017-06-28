@isTest
private class testCreditCardDecline {
	
	/*
	 *	Test methods for CreditCardDeclineNotifications.cls and CreditCardDecline.cls
	 *
	 */
	
	// Create Credit Card Decline test data
	@testSetup static void ccdTestData() {
		
		PrepareData.populateCustomSettings();
		
		List<RH_Order__c> orderList = new List<RH_Order__c>();
		orderList.add(new RH_Order__c(
    		Name = 'ccdOrderW',
    		Order_Type_Code__c = 'W',
    		Sold_to_First_Name__c = 'Jerry',
    		Sold_to_Last_Name__c = 'Garcia',
    		Sold_to_Day_Phone__c = '777-123-4567', 
			Sold_to_Address_1__c = '710 Ashbury Street',
			Sold_to_Address_2__c = '',
			Sold_to_City__c = 'San Francisco',
			Sold_to_State__c = 'CA',
			Sold_to_Zip__c = '94117',
			Sold_to_Country__c = 'USA',
			Sold_to_Email__c = 'jerrygarcia@rh.com')
    	);
    	orderList.add(new RH_Order__c(
    		Name = 'ccdOrderE',
    		Order_Type_Code__c = 'W',
    		Sold_to_First_Name__c = 'Jerry',
    		Sold_to_Last_Name__c = 'Garcia',
    		Sold_to_Day_Phone__c = '777-123-4567', 
			Sold_to_Address_1__c = '710 Ashbury Street',
			Sold_to_Address_2__c = '',
			Sold_to_City__c = 'San Francisco',
			Sold_to_State__c = 'CA',
			Sold_to_Zip__c = '94117',
			Sold_to_Country__c = 'USA',
			Sold_to_Email__c = '')
    	);
    	orderList.add(new RH_Order__c(
    		Name = 'ccdOrderZ',
    		Order_Type_Code__c = 'Z',
    		Sold_to_First_Name__c = 'Jerry',
    		Sold_to_Last_Name__c = 'Garcia',
    		Sold_to_Day_Phone__c = '777-123-4567', 
			Sold_to_Address_1__c = '710 Ashbury Street',
			Sold_to_Address_2__c = '',
			Sold_to_City__c = 'San Francisco',
			Sold_to_State__c = 'CA',
			Sold_to_Zip__c = '94117',
			Sold_to_Country__c = 'USA',
			Sold_to_Email__c = 'jerrygarcia@rh.com')
    	);
    	insert orderList;
    	
    	List<Ship_To__c> stList = new List<Ship_To__c>();
    	stList.add(PrepareData.createShipTo(orderList[0].Id, '1'));
    	stList.add(PrepareData.createShipTo(orderList[1].Id, '1'));
    	stList.add(PrepareData.createShipTo(orderList[2].Id, '1'));
    	insert stList;
    	
    	List<PrepareData.productClass> pcList = new List<PrepareData.productClass>();
    	pcList.add(PrepareData.createProduct('91020008RH1Y', 0, '91020008RH1Y', 100));
    	pcList.add(PrepareData.createProduct('68010201DBN', 120.12, '68010201DBN', 379.00));
    	
    	List<Order_Line_Items__c> oliList = new List<Order_Line_Items__c>();
    	oliList.add(PrepareData.createOrderLine(orderList[0].Id, stList[0].Id, '1', pcList[0].p.Id));
    	oliList.add(PrepareData.createOrderLine(orderList[1].Id, stList[1].Id, '1', pcList[1].p.Id));
    	oliList.add(PrepareData.createOrderLine(orderList[2].Id, stList[2].Id, '1', pcList[1].p.Id));
    	insert oliList;
	}
	
	// Credit Card Decline on Contract Order
	static testMethod void ccdTest1() {
		
		RH_Order__c order = [select Id, Name, Order_Type_Code__c from RH_Order__c where Name = 'ccdOrderZ'];
		Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
    	Case ccdCase = new Case(
    		RecordTypeId = rtMap.get('Credit Card Declines').getRecordTypeId(),
    		RH_Order_Number__c = order.Id
    	);
    	
    	Test.startTest();
    	insert ccdCase;
    	Test.stopTest();
    	
    	Group caseQueue = [select Id, Name from Group where Name = 'Contract Case Queue' and Type = 'Queue'];
    	ccdCase = [select Id, OwnerId, RH_Order_Number__c, CCD_Status__c, CCD_Auto_Email_Sent__c, Attempted_Contact__c, Request_Category__c from Case where RH_Order_Number__c = :order.Id limit 1];
    	system.assertEquals('In Progress', ccdCase.CCD_Status__c);
    	system.assertEquals(0, ccdCase.CCD_Auto_Email_Sent__c);
    	system.assertEquals(0, ccdCase.Attempted_Contact__c);
    	system.assertEquals('Callout', ccdCase.Request_Category__c);
    	system.assertEquals(caseQueue.Id, ccdCase.OwnerId);
	}
	
	// Verify that a Credit Card Decline on non-Contract Order with no email is Callout
	static testMethod void ccdTest2() {
		
		RH_Order__c order = [select Id, Name, Order_Type_Code__c from RH_Order__c where Name = 'ccdOrderE'];
		Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
    	Case ccdCase = new Case(
    		RecordTypeId = rtMap.get('Credit Card Declines').getRecordTypeId(),
    		RH_Order_Number__c = order.Id
    	);
    	
    	Test.startTest();
    	insert ccdCase;
    	Test.stopTest();
    	
    	Group caseQueue = [select Id, Name from Group where Name = 'Order Processing Queue' and Type = 'Queue'];
    	ccdCase = [select Id, OwnerId, RH_Order_Number__c, CCD_Status__c, CCD_Auto_Email_Sent__c, Attempted_Contact__c, Request_Category__c from Case where RH_Order_Number__c = :order.Id limit 1];
    	system.assertEquals('In Progress', ccdCase.CCD_Status__c);
    	system.assertEquals(0, ccdCase.CCD_Auto_Email_Sent__c);
    	system.assertEquals(0, ccdCase.Attempted_Contact__c);
    	system.assertEquals('Callout', ccdCase.Request_Category__c);
    	system.assertEquals(caseQueue.Id, ccdCase.OwnerId);
	}
	
	// Verify that a Credit Card Decline on non-Contract Order with email is Automatic Email
	static testMethod void ccdTest3() {
		
		RH_Order__c order = [select Id, Name, Order_Type_Code__c from RH_Order__c where Name = 'ccdOrderW'];
		Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
    	Case ccdCase = new Case(
    		RecordTypeId = rtMap.get('Credit Card Declines').getRecordTypeId(),
    		RH_Order_Number__c = order.Id
    	);
    	
    	Test.startTest();
    	insert ccdCase;
    	Test.stopTest();

    	Group caseQueue = [select Id, Name from Group where Name = 'Order Processing Queue' and Type = 'Queue'];
    	List<Case> ccdCaseList = new List<Case>();
    	ccdCaseList = [select Id, IsClosed, OwnerId, RH_Order_Number__c, CCD_Status__c, CCD_Auto_Email_Sent__c, Attempted_Contact__c, Request_Category__c from Case where RH_Order_Number__c = :order.Id];
    	
    	system.assertEquals(1, ccdCaseList.size());
    	system.assert(!ccdCaseList[0].IsClosed);
    	system.assertEquals(ccdCase.Id, ccdCaseList[0].Id);
    	system.assertEquals('In Progress', ccdCaseList[0].CCD_Status__c);
    	system.assertEquals(1, ccdCaseList[0].CCD_Auto_Email_Sent__c);
    	system.assertEquals(1, ccdCaseList[0].Attempted_Contact__c);
    	system.assertEquals('Automatic Email', ccdCaseList[0].Request_Category__c);
    	system.assertEquals(caseQueue.Id, ccdCaseList[0].OwnerId);
	}
	
	// Verify that multiple open Credit Card Decline cases for a single order are dealt with appropriately
	static testMethod void ccdTest4() {
		
		RH_Order__c order = [select Id, Name, Order_Type_Code__c from RH_Order__c where Name = 'ccdOrderW'];
		Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
    	
    	Case ccdCase = new Case(
    		RecordTypeId = rtMap.get('Standard').getRecordTypeId(),
    		RH_Order_Number__c = order.Id
    	);
    	insert ccdCase;
    	ccdCase.RecordTypeId = rtMap.get('Credit Card Declines').getRecordTypeId();
    	update ccdCase;
    	
    	List<Case> ccdCaseList = new List<Case>();
    	ccdCaseList.add(new Case(
    		RecordTypeId = rtMap.get('Credit Card Declines').getRecordTypeId(),
    		RH_Order_Number__c = order.Id)
    	);
    	ccdCaseList.add(new Case(
    		RecordTypeId = rtMap.get('Credit Card Declines').getRecordTypeId(),
    		RH_Order_Number__c = order.Id)
    	);
    	
    	Test.startTest();
    	insert ccdCaseList;
    	Test.stopTest();

    	ccdCaseList = [select Id, IsClosed, OwnerId, RH_Order_Number__c, CCD_Status__c, CCD_Auto_Email_Sent__c, Attempted_Contact__c, Request_Category__c from Case where RH_Order_Number__c = :order.Id];
    	system.assertEquals(1, ccdCaseList.size());
    	system.assert(!ccdCaseList[0].IsClosed);
	}
}