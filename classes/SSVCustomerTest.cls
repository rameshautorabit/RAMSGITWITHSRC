@isTest
public with sharing class SSVCustomerTest {
    
    public static testMethod void testCreateAccountContact() {
    	
		RecordType tradeAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Trade' and SObjectType = 'Account'];
		RecordType contractAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Contract' and SObjectType = 'Account'];
		RecordType unclassifiedAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Unclassified Business Account' and SObjectType = 'Account'];
		
		Source_System_View__c ssv = new Source_System_View__c(
			First_Name__c = 'paul',
			Last_Name__c = 'hemmings',
			Address_1__c = null,
			City__c = '',
			State__c = '',
			Zip__c = '',
			Country__c = '',
			Email__c = '',
			Duplicate_Set_ID__c = ''	
		); 
		
		Account account = new Account(
			Name = 'test Account'
		);
		
		database.insert(ssv);
		database.insert(account);
		
		Map<String, Contact> testContacts = new Map<String, Contact>();
		testContacts.put('Trade', SSVCustomer.createContactAtAccount(ssv, account.Id, tradeAccountRecordType.Id));
		testContacts.put('Contract', SSVCustomer.createContactAtAccount(ssv, account.Id, contractAccountRecordType.Id));
		testContacts.put('Unclassified Business Account', SSVCustomer.createContactAtAccount(ssv, account.Id, unclassifiedAccountRecordType.Id));
		
		
		System.assertEquals(true, testContacts.get('Trade').Unauthorized_Contact_Checkbox__c);
		System.assertEquals(true, testContacts.get('Contract').Unauthorized_Contact_Checkbox__c);	
		System.assertEquals(false, testContacts.get('Unclassified Business Account').Unauthorized_Contact_Checkbox__c);							
	}
	
}