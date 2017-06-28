@isTest
private class CloneCaseWithCaseLinesController_Test 
{
	static testMethod void myUnitTest() 
	{	PrepareData.populateCustomSettings();
		
		//Create Case
		Case c=new Case();
		//c.Queue_Type__c='Accommodations';
		c.Request_Category__c='Gift Card';
		c.Client_Type__c='Customer';
		c.Send_to_First_Name__c = 'Bob';
		c.Send_to_Last_Name__c = 'Jones';
		c.Send_to_City__c = 'Santa Cruz';
		c.Send_to_State__c = 'CA';
		c.Send_to_Zip__c = '94500';
		c.Send_to_Country__c = 'USA';
		c.Send_to_Day_Phone__c = '555-555-5555';
		c.Original_Requested_Percentage__c=.95;
		insert c;
		
		//Create Case Lines
		Case_Line_Items__c cl1=new Case_Line_Items__c();
		cl1.Item_Number__c='1213';
		cl1.Color__c='Green';
		cl1.Line_Total__c=100.00;
		cl1.Case_Number__c=c.Id;
		insert cl1;
		
		Case_Line_Items__c cl2=new Case_Line_Items__c();
		cl2.Item_Number__c='3232';
		cl2.Color__c='Yellow';
		cl2.Line_Total__c=200.00;
		cl2.Case_Number__c=c.Id;
		insert cl2;
		
		PageReference pageRef = new PageReference('apex/CloneCaseWithCaseLines' + 'id=' + c.Id);
        
        //Set the current test page to the Clone with related list visualforce page
        Test.setCurrentPage(pageRef);       
        
        //Instantiate the Controllers
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        CloneCaseWithCaseLineController cClone = new CloneCaseWithCaseLineController(sc);
        
        Test.startTest();
        cClone.cloneRecord();
        Test.stopTest();

	}
}