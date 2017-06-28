@isTest
public with sharing class SalesAttributionServiceTest {
    
	static testMethod void createSalesAttribution() {	
	    
	    // Create and insert test Account 
	    Account testAccount = PrepareData.createAccount();
		insert testAccount;
		
		// Create test Contact and insert
		User testUser = TestDataFactory.createUser();
		testUser.Username = 'wsxnji@wsxnji.com';
		
		insert testUser;
		
		// Create test Order and insert
		RH_Order__c testOrder = PrepareData.createOrder('741741741');
		insert testOrder;
		
		// Populate custom setting
		
		insert new Application_Settings__c(Name='CCD System Hold Codes', Value_Text__c='AT,AU,AV,AW,UT,UU,UV,UW');
		
		// Create Sales Attribution and insert
		Sales_Attribution__c testSalesAttribution = new Sales_Attribution__c(Order__c = testOrder.Id, Attribution_ID__c = 'wsxnji', Primary_Associate__c = true, Attribution_Percent__c = 100.00); 
		insert testSalesAttribution;
		
		// Validate
		testSalesAttribution = [Select Id, Associate_Name__c from Sales_Attribution__c where Id = : testSalesAttribution.Id];
		System.assertEquals(testSalesAttribution.Associate_Name__c, testUser.Id);
    }    
}