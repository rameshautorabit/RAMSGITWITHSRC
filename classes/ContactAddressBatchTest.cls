@isTest
public with sharing class ContactAddressBatchTest {

	public static testMethod void ensureBothBatchesRun() {
		
    	PrepareData.populateCustomSettings();
    	
    	// GIVEN - an ssv user
    	
		User su = TestDataFactory.createUser();
        su.Single_View_of_Customer_Process_User__c = true;   		
		
		// GIVEN a contact
		/*
		Contact testContact = new Contact(
			FIRSTNAME = 'paul',
			LASTNAME = 'hemmings'
		);
		System.runAs(su) {
			database.insert(testContact);
		}
		*/
		
		// GIVEN an order with that contact
		
		List<Rh_Order__c> testOrders = new List<Rh_Order__c>(); 
		testOrders.add(new Rh_Order__c(
			CONTACT_SOLD_TO__C = null, // testContact.Id,
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
		
		// GIVEN a test ship-to (shipment)
		
		List<Ship_To__c> testShipments = new List<Ship_To__c>();
		testShipments.add(new Ship_To__c(
			Order__c = testOrders.get(0).Id,
			CONTACT_SHIP_TO__c = null, // testContact.Id,    
			NAME  = '',
			Ship_to_FIRST_NAME__C = 'paul',  
			Ship_to_LAST_NAME__C  = 'hemmings',
			Ship_to_ADDRESS_1__C = '4 cielo lane',
			Ship_to_ADDRESS_2__C = '',			
			Ship_to_CITY__C = 'novato',
			Ship_to_COUNTRY__C = 'US',
			Ship_to_STATE__C = 'CA',
			Ship_to_ZIP__C = '94949',
			Ship_to_DAY_PHONE__C = '1231231234',
			Ship_to_NIGHT_PHONE__C = '1231231234',
			Ship_to_EMAIL__C = 'paul@paul.com'			
		));
		System.runAs(su) {
			database.insert(testShipments);
		}					
		
		// when		
		Test.startTest();
		ContactAddressBatch.executeFullBatch(false, 200);
		Test.stopTest();
		
		// then
		system.assertNotEquals(null, [SELECT Account_Sold_To__c FROM Rh_Order__c WHERE ID = :testOrders.get(0).Id].Account_Sold_To__c);
		system.assertNotEquals(null, [SELECT Contact_Sold_To__c FROM Rh_Order__c WHERE ID = :testOrders.get(0).Id].Contact_Sold_To__c);
		system.assertNotEquals(null, [SELECT Address_Sold_To__c FROM Rh_Order__c WHERE ID = :testOrders.get(0).Id].Address_Sold_To__c);
		system.assertNotEquals(null, [SELECT Address_Ship_To__c FROM Ship_To__c WHERE ID = :testShipments.get(0).Id].Address_Ship_To__c);
			
	}    
}