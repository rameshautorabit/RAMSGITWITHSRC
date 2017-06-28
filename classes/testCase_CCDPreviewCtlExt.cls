@isTest
private class testCase_CCDPreviewCtlExt {
	
	/*
	 *	Test methods for Case_CCDPreviewCtlExt.cls
	 *
	 */
	 
	static testMethod void ccdPreviewTest1() {
		
		// create our test data
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
    	insert orderList;
    	
    	// Create case for our test - first insert case as record type Standard and then change 
    	// change it to record type Credit Card Declines - avoids sending email automatically upon 
    	// insert via @future job.
    	Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
    	Case ccdCase = new Case(RecordTypeId = rtMap.get('Standard').getRecordTypeId());
    	insert ccdCase;
    	ccdCase.RecordTypeId = rtMap.get('Credit Card Declines').getRecordTypeId();
    	ccdCase.Notification_Type__c = '';
    	ccdCase.Status = 'In Progress';
    	update ccdCase;
    	
    	// Now test the controller extension - test bad page parameters
    	ApexPages.StandardController std = new ApexPages.StandardController(ccdCase);
		Case_CCDPreviewCtlExt ctl = new Case_CCDPreviewCtlExt(std);
		
		// Test controller with good page parameters but bad notification type
		std = new ApexPages.StandardController(ccdCase);
		ApexPages.currentPage().getParameters().put('caseId', ccdCase.Id);
		ApexPages.currentPage().getParameters().put('retURL', '/' + ccdCase.Id);
		ctl = new Case_CCDPreviewCtlExt(std);
		
		// Test controller with good page parameters, good notification type, but no order
		ccdCase.Notification_Type__c = 'Credit Card Declines - 1st Notice';
		update ccdCase;
		std = new ApexPages.StandardController(ccdCase);
		ApexPages.currentPage().getParameters().put('caseId', ccdCase.Id);
		ApexPages.currentPage().getParameters().put('retURL', '/' + ccdCase.Id);
		ctl = new Case_CCDPreviewCtlExt(std);
		
		// Test controller with valid data
		ccdCase.RH_Order_Number__c = orderList[0].Id;
		update ccdCase;
		std = new ApexPages.StandardController(ccdCase);
		ApexPages.currentPage().getParameters().put('caseId', ccdCase.Id);
		ApexPages.currentPage().getParameters().put('retURL', '/' + ccdCase.Id);
		ctl = new Case_CCDPreviewCtlExt(std);
		
		ctl.sendNotification();
		ctl.cancelCCDPreview();
		
	}
}