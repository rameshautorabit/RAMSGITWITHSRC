/**
	Test Class: CreateCaseClass_Test for CreateCaseClass
**/

@isTest
private class CreateCaseClass_Test 
{
	public static testMethod void testCreateCaseClass() 
	{
		
		PrepareData.populateCustomSettings();
		
        // given
        Account testAccount = new Account(
            Name = 'test account'
        );
        database.insert(testAccount);
        
        // given
        Contact testContact = new Contact(
            AccountId = testAccount.Id,
            firstName = 'paul',
            lastname = 'hemmings'
        );
        database.insert(testContact);
        
        //given
		RH_Order__c rhOrder = new RH_Order__c(
            Account_sold_to__c = testAccount.id,
            Contact_sold_to__c = testContact.id,
            Name ='ORDER 123'
        );
		database.insert(rhOrder);
		
		ApexPages.currentPage().getParameters().put('orderId', rhOrder.Id);
		ApexPages.StandardController controller=new ApexPages.StandardController(rhOrder);
		CreateCaseClass c = new CreateCaseClass(controller);
		
		c.initRecordTypes();
		c.CreateCase();
		c.cancelCreateCase();  
	}
}