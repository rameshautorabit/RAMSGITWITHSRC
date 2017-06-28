@isTest
private class TestEmailMessage_After {
	
	/*
	 *	Test trigger EmailMessage_After.trigger.
	 *
	 */
	/*
    static testMethod void emInsertTest() {
    	
    	PrepareData.populateCustomSettings();
    	//Create a case with Record type
        RecordType rtype=[SELECT Id, Name FROM RecordType WHERE SObjectType='Case' AND Name= 'Accommodations - Order Header' LIMIT 1];
        
        //Get Case Record type
        List<Case> caseList = new List<Case>();
        caseList.add(new Case(
        	Send_to_First_Name__c = 'Bob',
			Send_to_Last_Name__c = 'Jones',
			Send_to_City__c = 'Santa Cruz',
			Send_to_State__c = 'CA',
			Send_to_Zip__c = '94500',
			Send_to_Country__c = 'USA',
			Send_to_Day_Phone__c = '555-555-5555',
            RecordTypeId = rtype.Id)
		);
        insert caseList;
        
        test.startTest();
        
        List<EmailMessage> emList = new List<EmailMessage>();
        emList.add(new EmailMessage(
        	FromAddress = 'webcs@restorationhardware.com',
        	ToAddress = 'cscmetrics@rh.com',
        	ParentId = caseList[0].Id,
        	Subject = 'TEST TEST TEST',
        	HtmlBody = 'body',
        	TextBody = 'body')
        );
        insert emList;
        
        test.stopTest();
    }
    */
}