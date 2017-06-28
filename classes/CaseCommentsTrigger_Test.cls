/**
	Description: Test Class for the Apex class UpdateCaseFromCaseComments called from the CaseComments_Trigger
	Author: vk@ff on 08/26/2014
**/

@isTest(SeeAlldata=true)
private class CaseCommentsTrigger_Test 
{
	static testMethod void myUnitTest() 
	{
		//Create Case
		Case c=new Case();
		insert c;
		
		//Create Case Comments
		Case_Comments__c cc1=new Case_Comments__c();
		cc1.Case__c=c.Id;
		cc1.Comment__c='Test Comments 1';
		cc1.Action_Required__c=true;
        cc1.Call_Outcome__c='Could Not Reach';
		insert cc1;
		
		Case_Comments__c cc2=new Case_Comments__c();
		cc2.Case__c=c.Id;
		cc2.Comment__c='Test Comments 2';
		cc2.Action_Required__c=false;
		insert cc2;
		
		//Delete case comment to test the count of comments
		delete cc2;
	}
}