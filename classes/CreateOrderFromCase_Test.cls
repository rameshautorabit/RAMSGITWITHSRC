@isTest
private class CreateOrderFromCase_Test 
{
	static testMethod void createOrderFromCase() 
	{
		PrepareData.populateCustomSettings();
		Case c=new Case();
		//c.New_Address__c = 'TestAddress';
		insert c;
		
		ApexPages.StandardController controller=new ApexPages.StandardController(c);
		createOrderFromCase co=new createOrderFromCase(controller);
		
		Test.startTest();
		co.createOrder();
		co.cancel();
		Test.stopTest();
		
	}
}