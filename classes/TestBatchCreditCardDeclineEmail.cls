@isTest(SeeAllData=true)
public with sharing class TestBatchCreditCardDeclineEmail {

    /*
    static Case initCCDecline() {
		 	
    	// Create the test data - Order, Ship To, and Case
    	List<RecordType> rtList = new List<RecordType>();
    	Id caseRtId = [select Id, SobjectType from RecordType where Name = 'Credit Card Declines' and SobjectType = 'Case' limit 1].Id;
    	
    	RH_Order__c order = new RH_Order__c(
    		Name = 'TestOrder1',
    		Sold_to_First_Name__c = 'Jerry',
    		Sold_to_Last_Name__c = 'Garcia',
    		Sold_to_Day_Phone__c = '777-123-4567', 
			Sold_to_Address_1__c = '710 Ashbury Street',
			Sold_to_Address_2__c = '',
			Sold_to_City__c = 'San Francisco',
			Sold_to_State__c = 'CA',
			Sold_to_Zip__c = '94117',
			Sold_to_Country__c = 'USA',
			Sold_to_Email__c = 'jerrygarcia@gmail.com'
    	);
    	insert order;
    	
    	Ship_To__c shipTo = new Ship_To__c(
    		Name = '1',
    		Order__c = order.Id,
    		Ship_to_First_Name__c = 'Jerry',
    		Ship_to_Last_Name__c = 'Garcia',
    		Ship_to_Day_Phone__c = '777-123-4567', 
			Ship_to_Address_1__c = '710 Ashbury Street',
			Ship_to_Address_2__c = '',
			Ship_to_City__c = 'San Francisco',
			Ship_to_State__c = 'CA',
			Ship_to_Zip__c = '94117',
			Ship_to_Country__c = 'USA',
			Ship_to_Email__c = 'jerrygarcia@rh.com'
    	);
    	insert shipTo;
    	
    	Order_Line_Items__c orderLine = new Order_Line_Items__c(
    		Name = '1',
    		RH_Order_Number__c = order.Id,
    		Ship_To__c = shipTo.Id
    	);
    	insert orderLine;
    	
    	// Create a Case
    	List<Case> ccCase = new List<Case>();
    	ccCase.add(new Case(
    		RecordTypeId = caseRtId,
    		RH_Order_Number__c = order.Id
    		)
    	);
    	//insert ccCase;
    	
    	return ccCase[0];
    }
    
    static testmethod void testBatchNotification() {
		
        Case ccdCase = new Case();
		
		ccdCase = initCCDecline();
		
		Test.StartTest();
		insert ccdCase;
		//BatchCreditCardDeclineEmail sync = new BatchCreditCardDeclineEmail();
		//ID batchprocessid = Database.executeBatch(sync, 100);
		Test.StopTest();
		
		// Verify results
		ccdCase = [select Id, SendGrid_Result__c, Call_Outcome__c, Attempted_Contact__c from Case where Id = :ccdCase.Id];
		system.assertEquals(true, ccdCase.SendGrid_Result__c.contains('SUCCESS'));
		system.assertEquals('Sent Email', ccdCase.Call_Outcome__c);
		system.assertEquals(1, ccdCase.Attempted_Contact__c);
    }
    
    static testmethod void testFinalNotification() {
		
		Case ccdCase = new Case();
		
		ccdCase = initCCDecline();
		
		Test.StartTest();
		insert ccdCase;
		ccdCase.Attempted_Contact__c = 3;
		ccdCase.Call_Outcome__c = 'Could Not Reach';
		update ccdCase;
		Test.StopTest();
		
		// Verify results
		ccdCase = [select Id, SendGrid_Result__c, Call_Outcome__c, Attempted_Contact__c from Case where Id = :ccdCase.Id];
		system.assertEquals(true, ccdCase.SendGrid_Result__c.contains('SUCCESS'));
		system.assertEquals('Sent Email', ccdCase.Call_Outcome__c);
		system.assertEquals(4, ccdCase.Attempted_Contact__c);
	}
	*/
}