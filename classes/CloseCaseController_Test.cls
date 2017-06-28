@isTest(SeeAllData=true)
private class CloseCaseController_Test 
{
	static testMethod void myUnitTest() 
	{
		
		//Create Case
		Case c=new Case();
		c.New_Address__c='Test Address';
		insert c;
		
		//Create Case Comments
		Case_Comments__c cc1=new Case_Comments__c();
		cc1.Case__c=c.Id;
		cc1.Comment__c='Test Comments 1';
		cc1.Action_Required__c=true;
		insert cc1;
		
		ApexPages.currentPage().getParameters().put('caseId',c.Id);
		ApexPages.currentPage().getParameters().put('id',cc1.Id);
		ApexPages.StandardController con=new ApexPages.StandardController(c);
        CloseCaseController ccon=new CloseCaseController(con);
        CloseCaseController.getStatusValues();
        ccon.closeCase();
		
		//Create Case: Case for DML Error: Catch Block
		Case c2=new Case();
		insert c2;
		
		//Create Case Comments
		Case_Comments__c cc2=new Case_Comments__c();
		//cc2.Case__c=c.Id;
		cc2.Comment__c='Test Comments 1';
		cc2.Action_Required__c=true;
		insert cc2;
		
		ApexPages.currentPage().getParameters().put('caseId',c2.Id);
		ApexPages.currentPage().getParameters().put('id',cc2.Id);
		ApexPages.StandardController con2=new ApexPages.StandardController(c2);
        CloseCaseController ccon2=new CloseCaseController(con2);
        CloseCaseController.getStatusValues();
        ccon2.closeCase();
        ccon2.cancelClose();
		
	}
}