@isTest
private class testCase_NotificationsCtlExt {
	
	/*
	 *	Test methods for Case_NotificationsCtlExt.cls
	 *
	 */
	
	static testMethod void caseNotificationsTest1() {
		
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
    	Case ccdCase = new Case(
    		RecordTypeId = rtMap.get('Standard').getRecordTypeId(),
    		RH_Order_Number__c = orderList[0].Id
    	);
    	insert ccdCase;
    	ccdCase.RecordTypeId = rtMap.get('Credit Card Declines').getRecordTypeId();
    	ccdCase.Notification_Type__c = 'Credit Card Declines - 1st Notice';
    	ccdCase.Status = 'In Progress';
    	update ccdCase;
    	
    	// Now test the controller extension
    	ApexPages.StandardController std = new ApexPages.StandardController(ccdCase);
		Case_NotificationsCtlExt ctl = new Case_NotificationsCtlExt(std);
		
		PageReference pr;
		pr = ctl.previewOne();
		system.assertEquals(null, pr);
		
		List<SelectOption> nTypes = ctl.notificationTypes;
		for (SelectOption nt :nTypes) {
			system.assert(nt.getLabel().startsWith('--None--') || nt.getLabel().startsWith('Credit Card Declines'));
			system.assert(nt.getValue().startsWith('--None--') || nt.getValue().startsWith('Credit Card Declines'));
		}
		
		ctl.setnotificationSelected(nTypes[1].getValue());
		String emailType = ctl.getnotificationSelected();
		system.assertEquals(nTypes[1].getValue(), emailType);
		
		pr = ctl.notificationPreview();
		system.assert(String.valueOf(pr).contains('Case_CCDPreview'));
	}
}