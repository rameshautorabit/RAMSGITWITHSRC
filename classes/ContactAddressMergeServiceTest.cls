@isTest
public with sharing class ContactAddressMergeServiceTest {
    
	public static testMethod void testGettingPersonAccountAndContactRecordTypes() {
		
		system.assertNotEquals(null, ContactAddressMergeService.getRecordTypeByName(ContactAddressMergeService.ACCOUNTS_RECORD_TYPE_NAMES, 'RH End Customer'));
		
		
	}
	
	public static testMethod void testCreatingOrderPersonAccount() {
				
    	PrepareData.populateCustomSettings();
    	
    	// GIVEN - an ssv user
    	
		User su = TestDataFactory.createUser();
        su.Single_View_of_Customer_Process_User__c = true;   
        		
		// given (a test order)
		
		List<Rh_Order__c> testOrders = new List<Rh_Order__c>();
		testOrders.add(new Rh_Order__c(
			CONTACT_SOLD_TO__C = null,
			SOLD_TO_ADDRESS_1__C = 'address 1',
			SOLD_TO_ADDRESS_2__C = 'address 2',
			SOLD_TO_CITY__C = 'city',
			SOLD_TO_STATE__C = 'CA',
			SOLD_TO_ZIP__C = '94949',	
			SOLD_TO_COUNTRY__C = 'US',	
			SOLD_TO_CUSTOMER_NUMBER__C = '1111111',
			SOLD_TO_DAY_PHONE__C = '9191231234',
			SOLD_TO_EMAIL__C = 'paul@paul.com',
			SOLD_TO_FIRST_NAME__C = 'paul',
			SOLD_TO_LAST_NAME__C = 'hemmings'		
		));
		testOrders.add(new Rh_Order__c(
			CONTACT_SOLD_TO__C = null,
			Sold_to_Company__c = 'pauls test company',			
			SOLD_TO_ADDRESS_1__C = 'address 1',
			SOLD_TO_ADDRESS_2__C = 'address 2',
			SOLD_TO_CITY__C = 'city',
			SOLD_TO_STATE__C = 'CA',
			SOLD_TO_ZIP__C = '94949',	
			SOLD_TO_COUNTRY__C = 'US',	
			SOLD_TO_CUSTOMER_NUMBER__C = '1111111',
			SOLD_TO_DAY_PHONE__C = '9191231234',
			SOLD_TO_EMAIL__C = 'paul@paul.com',
			SOLD_TO_FIRST_NAME__C = 'paul',
			SOLD_TO_LAST_NAME__C = 'hemmings'		
		));		
		System.runAs(su) {
			database.insert(testOrders);
		}
						
		// when (create customer for order)
		
		database.update(ContactAddressMergeService.buildCustomerForOrders(testOrders));
		
		// then (get the processed orders)
		
		List<Rh_Order__c> processedOrders = [SELECT ID, CONTACT_SOLD_TO__C, ACCOUNT_SOLD_TO__C FROM Rh_Order__c];	
		List<Account> spawnedAccounts = [SELECT ID FROM Account];
		List<Contact> spawnedContacts = [SELECT ID FROM Contact];
		List<Contact_Address__c> spawnedContactAddresses = [SELECT ID FROM Contact_Address__c];
			
		// then (test order now has link to account and contact)

		system.assertNotEquals(null, spawnedAccounts);
		system.assertNotEquals(null, spawnedContacts);
		// system.assertNotEquals(null, spawnedContactAddresses);
		
		system.assertEquals(2, spawnedAccounts.size());
		system.assertEquals(2, spawnedContacts.size());
		// system.assertEquals(2, spawnedContactAddresses.size());
		
		for (Rh_Order__c processedOrder : processedOrders) {
			system.assertNotEquals(null, processedOrder.ACCOUNT_SOLD_TO__C);
			system.assertNotEquals(null, processedOrder.CONTACT_SOLD_TO__C);
			// system.assertNotEquals(null, processedOrder.ADDRESS_SOLD_TO__C);
		}		
	}
    
}