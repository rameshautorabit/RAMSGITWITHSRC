@isTest
public with sharing class ContactAddressServiceTest {
	
	public static testMethod void testFixSoldToEmailIssue() {

    	PrepareData.populateCustomSettings();
    	
    	// GIVEN - an ssv user
    	
		User su = TestDataFactory.createUser();
        su.Single_View_of_Customer_Process_User__c = true;   		
		
		// GIVEN a contact
		
		Contact[] testContacts = new List<Contact> {
			new Contact(
				FIRSTNAME = 'paul',
				LASTNAME = 'hemmings',
				EMAIL = 'paul@paul.com'
			)
		};
		System.runAs(su) {
			database.insert(testContacts);
		}
		
		// given - a contact address
		
		Contact_Address__c soldToAddress = new Contact_Address__c(
			Contact__c = testContacts.get(0).Id,
			First_Name__c = 'paul',
			Last_Name__c = 'hemmings',
			Email__c = null
		);
		database.insert(soldToAddress);
		
		// given - an order pointing to that address
		
		Rh_Order__c[] testOrders = new List<Rh_Order__c>{
			new Rh_Order__c(
				Name = 'testOrder',
				Contact_Sold_To__c = testContacts.get(0).Id,
				Address_Sold_To__c = soldToAddress.Id,
				Sold_To_Email__c = 'paul@paul.com'
			)
		};
		System.runAs(su) {
			database.insert(testOrders);
		}		
		
		// when - fix run
		
		Utility.logUpdate(ContactAddressService.fixSoldToEmailIssue(testOrders));
		
		// then - contact address now has an email address
		
		system.assertEquals(1, [SELECT ID FROM Contact_Address__c].size());
		system.assertEquals('paul@paul.com', [SELECT Email__c FROM Contact_Address__c WHERE ID = :soldToAddress.Id].Email__c);
	}
	
    public static testMethod void testbuildSoldToAddress() {
    	
    	// given
    	String matchKey = 'test-match-key';
    	
    	// given 
    	RH_Order__c testOrder = new Rh_Order__c(
    		SOLD_TO_DAY_PHONE__c = '(123) 123-1234'
    	);
    	
    	// when
    	Contact_Address__c testAddress = ContactAddressService.generateSoldToContactAddress(testOrder);
    	
    	// then
    	system.assertEquals('1231231234', testAddress.day_phone__c);
    	
    }
    
    public static testMethod void testBuildingAddressFromContact() {
    	
    	// GIVEN - an ssv user
    	
		User su = TestDataFactory.createUser();
        su.Single_View_of_Customer_Process_User__c = true;   		
		
		// GIVEN a contact
		
		Contact[] testContacts = new List<Contact> {
			new Contact(
				FIRSTNAME = 'paul',
				LASTNAME = 'hemmings',
				EMAIL = 'paul@paul.com'
			)
		};
		System.runAs(su) {
			database.insert(testContacts);
		}
		
		Map<ID, Contact> testContactMap = new Map<ID, Contact>(testContacts);
    	
    	// WHEN - process contact
    	
    	Utility.logInsert(ContactAddressService.buildAddressForContacts(testContactMap));
    	
    	// THEN - one address record generated
    	
		system.assertEquals(1, [SELECT ID FROM Contact_Address__c].size());
		system.assertEquals(testContacts.get(0).Id, [SELECT Contact__c FROM Contact_Address__c].Contact__c);
		system.assertEquals('paul', [SELECT First_Name__c FROM Contact_Address__c].First_Name__c);
		system.assertEquals('paul@paul.com', [SELECT Email__c FROM Contact_Address__c].Email__c);    	
		
		// GIVEN - the contact email changes
		
		testContactMap.values().get(0).EMAIL = 'test@test.com';
		database.update(testContactMap.values());
		
		// WHEN - process contact again
		
		Utility.logInsert(ContactAddressService.buildAddressForContacts(testContactMap));
		
		// THEN - new contact address created (even though match key would be the same)
		
		system.assertEquals(2, [SELECT ID FROM Contact_Address__c].size());
		
		// GIVEN - unrelated field change
		
		testContactMap.values().get(0).MobilePhone = '123-123-1234';
		database.update(testContactMap.values());
		
		// WHEN - process contact again
		
		Utility.logInsert(ContactAddressService.buildAddressForContacts(testContactMap));
		
		// THEN - no new contact address created
		
		system.assertEquals(2, [SELECT ID FROM Contact_Address__c].size());
    }
    

	public static testMethod void testBuildingAddressFromOrder() {
		
    	PrepareData.populateCustomSettings();
    	
    	// GIVEN - an ssv user
    	
		User su = TestDataFactory.createUser();
        su.Single_View_of_Customer_Process_User__c = true;   		
		
		// GIVEN a contact
		
		Contact testContact = new Contact(
			FIRSTNAME = 'paul',
			LASTNAME = 'hemmings'
		);
		System.runAs(su) {
			database.insert(testContact);
		}
		
		// GIVEN an order with that contact
		
		List<Rh_Order__c> testOrders = new List<Rh_Order__c>(); 
		testOrders.add(new Rh_Order__c(
			CONTACT_SOLD_TO__C = testContact.Id,
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
			SOLD_TO_LAST_NAME__C = 'hemmings',
			BILL_TO_ADDRESS_1__C = 'bill to address 1'
		));
		System.runAs(su) {
			database.insert(testOrders);
		}
		
		// WHEN - order processed
				
		database.update(ContactAddressService.buildAddressForOrders(testOrders, ContactAddressService.ORDER_ADDRESS_TYPE.SOLD_TO));
		database.update(ContactAddressService.buildAddressForOrders(testOrders, ContactAddressService.ORDER_ADDRESS_TYPE.BILL_TO));
		
		// THEN - two address records created (sold-to, bill-to) and the order associated with those records
				
		system.assertEquals(2, [SELECT ID FROM Contact_Address__c].size());		
		system.assertNotEquals(null, [SELECT Address_Sold_To__c FROM Rh_Order__c WHERE Id = :testOrders.get(0).Id ].Address_Sold_To__c);
		system.assertNotEquals(null, [SELECT Address_Bill_To__c FROM Rh_Order__c WHERE Id = :testOrders.get(0).Id ].Address_Bill_To__c);
		
		// GIVEN (a new order that has the same sold to address and contact)
		
		Rh_Order__c anotherOrder = new Rh_Order__c(
			CONTACT_SOLD_TO__C = testContact.Id,
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
			SOLD_TO_LAST_NAME__C = 'hemmings',
			BILL_TO_ADDRESS_1__C = 'bill to address 1'		
		);
		System.runAs(su) {
			database.insert(anotherOrder);
		}
		testOrders.add(anotherOrder);		
			
		// WHEN (process both orders)
		
		database.update(ContactAddressService.buildAddressForOrders(testOrders, ContactAddressService.ORDER_ADDRESS_TYPE.SOLD_TO));
		database.update(ContactAddressService.buildAddressForOrders(testOrders, ContactAddressService.ORDER_ADDRESS_TYPE.BILL_TO));
		
		// THEN (no new address records generated. new order linked to existing address)		
		
		List<Rh_Order__c> updatedOrders = [
			SELECT Address_Sold_To__c, Address_Bill_To__c // , Sold_to_Address_Match_Key__c, Bill_To_Address_Match_Key__c
			FROM Rh_Order__c
		]; 
		
		system.assertEquals(2, updatedOrders.size());
		system.assertEquals(2, [SELECT ID FROM Contact_Address__c].size());
		system.assertEquals(updatedOrders.get(0).Address_Sold_To__c, updatedOrders.get(1).Address_Sold_To__c);
		system.assertEquals(updatedOrders.get(0).Address_Bill_To__c, updatedOrders.get(1).Address_Bill_To__c);
	}
        
    
	
	public static testMethod void testBuildingAddressFromShipTo() {
		
    	PrepareData.populateCustomSettings();
    	
    	// GIVEN - an ssv user
    	
		User su = TestDataFactory.createUser();
        su.Single_View_of_Customer_Process_User__c = true;   		
		
		// GIVEN a contact
		
		Contact testContact = new Contact(
			FIRSTNAME = 'paul',
			LASTNAME = 'hemmings'
		);
		System.runAs(su) {
			database.insert(testContact);
		}
		
		
		// GIVEN an order with that contact
		
		List<Rh_Order__c> testOrders = new List<Rh_Order__c>(); 
		testOrders.add(new Rh_Order__c(
			CONTACT_SOLD_TO__C = testContact.Id,
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
			CONTACT_SHIP_TO__c = testContact.Id,    
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

		// WHEN - the shipments inserted are retrieved (otherwise the Order__r.Contact_Sold_To__c is NULL)
		
		List<Ship_To__c> shipmentsToProcess = database.query(ContactAddressBatch.buildShipToQuery(true, null));
		system.assertEquals(1, shipmentsToProcess.size());
		
		// WHEN - shipment processed

		database.update(ContactAddressService.buildAddressForShipTos(shipmentsToProcess));
				
		// THEN - two address records created (sold-to, bill-to, ship-to) and the order associated with those records
		
		system.assertNotEquals(null, testContact.Id);
		system.assertEquals(testContact.Id, [SELECT CONTACT_SHIP_TO__c FROM Ship_To__c].CONTACT_SHIP_TO__c);
		system.assertEquals(testContact.Id, [SELECT Order__r.CONTACT_SOLD_TO__C FROM Ship_To__c].Order__r.CONTACT_SOLD_TO__C);
								
		system.assertEquals(1, [SELECT ID FROM Contact_Address__c].size());		
		system.assertNotEquals(null, [SELECT Address_Ship_To__c FROM Ship_To__c WHERE Id = :testShipments.get(0).Id ].Address_Ship_To__c);	
	}
		    
}