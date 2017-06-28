@isTest
public with sharing class AddressExtensionTest {
    
    @testSetup
    static void setup() {
    	TestDataFactory.turnMdmFeatureFlagsOn(); 
    }
        
    public static testMethod void testInitializeExtension() {
    	
    	// GIVEN - an ssv user
    	
		User su = TestDataFactory.createUser();
        su.Single_View_of_Customer_Process_User__c = true;     	

		RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'RH End Customer' and SObjectType = 'Account'];
		     	
    	// given (test person account)
    	
    	Account testAccount = new Account(
    		RecordTypeId = personAccountRecordType.Id,
    		Type = 'Consumer',
    		FirstName = 'paul',
    		LastName = 'hemmings',
            PersonMailingStreet= '4 test',
            PersonMailingCity = 'Novato',
            PersonMailingCountry = 'US',
            PersonMailingState = 'CA',
            PersonMailingPostalCode= '94949'   		
    	);
    	
    	// when (account inserted using SSV)
    	
    	System.runAs(su) {
    		database.insert(testAccount);
    	}
    	
    	// then contact created
    	
    	system.assertEquals(1, [SELECT ID FROM Contact WHERE AccountID = :testAccount.Id].size());
    		
    	// when (get matching contact)
    	
    	Contact testContact = [
    		SELECT 	FirstName, 
    				LastName,
    		        MailingStreet,
	                MailingCity,
	                MailingCountry,
	                MailingState,
	                MailingPostalCode,   
	                AccountId,
	                Account.IsPersonAccount
			FROM 	Contact
			WHERE	AccountId = :testAccount.Id	           
    	];   
    	
    	// then check no address yet created
    	
    	system.assertEquals(0, [SELECT ID FROM Customer_Address__c WHERE Contact__c = :testContact.Id].size()); 
        system.assertEquals(true, [SELECT Account.IsPersonAccount FROM Contact WHERE ID = :testContact.Id].Account.IsPersonAccount);

		// given (new address)
		    	    	 	    	
    	Address__c testAddress = new Address__c(
	        Address_1__c = '5 new test',
	        City__c = 'Novato',
	        Country_Code__c = 'US',
	        State__c = 'CA',
	        Zip__c = '94949'    		
    	);
    	
    	// given (partial new customer address)
    	
    	Customer_Address__c testCustAddr = new Customer_Address__c(
    		Is_Inactive__c = false, 
		    Is_Principal_Address__c = true
    	);
    	
    	// when (insert new address)
    	
    	AddressExtension extension = new AddressExtension(testContact);
    	extension.initializeExtension(testContact);
    	extension.insertNewAddress(false, testAddress, testCustAddr, testContact.Id);
    	    	
    	// then (associates new address with that contact)   
    	
    	List<Customer_Address__c> contactAddresses = extension.getContactAddressRecords(testContact.Id); 	    	
    	system.assertEquals(1, contactAddresses.size());
    	system.assertNotEquals(null, contactAddresses.get(0).Address__c);

		// then (mailing address and billing address updated on contact) 
    	
        system.assertEquals(1, [SELECT ID FROM Customer_Address__c WHERE Contact__c = :testContact.Id].size());
    	system.assertEquals('5 new test', [SELECT MailingStreet FROM Contact WHERE Id = :testContact.Id].MailingStreet);
    	system.assertEquals('5 new test', [SELECT BillingStreet FROM Account WHERE Id = :testAccount.Id].BillingStreet);
        
    	// when (update that address)
    	
    	extension.initializeExtension(new Address__c( Id = contactAddresses.get(0).Address__c ));
    	List<Customer_Address__c> addressRecords = extension.getAddressContactRecords(contactAddresses.get(0).Address__c);
        testAddress.Address_1__c = '6 cielo lane';
        
        System.runAs(su) {
    		extension.updateExistingAddress(true, testAddress, addressRecords);
        }
        
		// then (mailing address and billing address updated on contact) 
    	
    	system.assertEquals('6 cielo lane', [SELECT MailingStreet FROM Contact WHERE Id = :testContact.Id].MailingStreet);
    	system.assertEquals('6 cielo lane', [SELECT BillingStreet FROM Account WHERE Id = :testAccount.Id].BillingStreet);

    }
    
    
}