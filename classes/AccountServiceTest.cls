@isTest
private class AccountServiceTest {
	
    static testMethod void createVendorPublicGroup() {	
	    
	    // Create vendors public group
	    Group vendorGroup = new Group(Name = 'Vendor Partner Users');
	    insert vendorGroup;
	    
	    // Create test Account and insert
	    Account testAccount = new Account(Name='Partner Account');
		testAccount.Vendor_Number__c = '1234';
		insert testAccount;
		
		testAccount.isPartner = true;
		update testAccount;
		
		testAccount = [Select Id, Name, PublicGroupId__c, isPartner from Account where Id= :testAccount.Id];
		Group testGroup = [Select Name from Group where Id = :testAccount.PublicGroupId__c];
		
		System.assertEquals('VEND-' + testAccount.Name + '-' + testAccount.Id, testGroup.name);
		System.assertEquals(testAccount.isPartner, true);
    }    
    
    public static testMethod void test_handleInsertedUpdatedAccount() {
    	
		// given a feature flag turned on
		
		Feature_Flags__c customSetting = new Feature_Flags__c(
			Single_Pane_Address_Feature__c = true
		);
		insert customSetting;	    	
    	
    	// GIVEN - a person account record type
    	
    	Id personAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('RH End Customer').getRecordTypeId();
    	
		// GIVEN - a new person account
		
		Account testAccount = new Account(RecordTypeId = personAccountRecTypeId,
								  FirstName='paul',
								  LastName='hemmings',
								  PersonMailingStreet='4 Cielo Lane.',
								  PersonMailingPostalCode='94949',
								  PersonMailingCity='Novato',
								  PersonEmail='paul@paul.com');
								  
		// WHEN - person account inserted
										  
		database.insert(testAccount);
		
		// THEN - contact address account created
		
		system.assertEquals(1, [SELECT ID FROM Contact WHERE AccountID = :testAccount.Id].size());
		system.assertEquals(1, [SELECT ID FROM Contact_Address__c].size());
		system.assertEquals(null, [SELECT COMPANY_NAME__C FROM Contact_Address__c].COMPANY_NAME__C);        	 
    }
}