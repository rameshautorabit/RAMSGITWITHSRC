@isTest
public with sharing class ShipToServiceTest {

	public static testMethod void testHandleShipToUpdateChanges() {
		
		PrepareData.populateCustomSettings();
		
		// given a contact
		
		List<Contact> testContacts = new List<Contact>();
		testContacts.add(new Contact(
			FirstName = 'paul', 
			LastName = 'hemmings')
		);
		database.insert(testContacts);
				
		// given an order (pointing to contact)
		
		List<Rh_Order__c> testOrders = new List<Rh_Order__c>();
		testOrders.add(new Rh_Order__c(
			Name='test order', 
			Contact_Sold_To__c = [SELECT ID FROM CONTACT].Id)
		);
		database.insert(testOrders);
		
		// given a ship to

		List<Ship_To__c> testShipTos = new List<Ship_To__c>();
		testShipTos.add(new Ship_To__c(
			Name='test ship-to', 
			Order__c = [SELECT ID FROM RH_ORDER__C].Id, 
			Contact_Ship_To__c = [SELECT ID FROM CONTACT].Id,
	        ship_to_first_name__c = 'paul',
	        ship_to_last_name__c = 'hemmings',
	        Ship_to_Company__c = 'test-company',
	        Ship_to_Address_1__c = '112 somerset dr',
	        Ship_to_City__c  = 'novato',
	        Ship_to_State__c = 'ca',
	        Ship_to_Zip__c = '94949',
	        Ship_to_Country__c = 'US'		
		));
		database.insert(testShipTos);
		
		// when (ship-to processed)
		
		Ship_to__c[] insertedShipTos = database.query(ContactAddressBatch.buildShipToQuery(false, null));
		database.update(ContactAddressService.buildAddressForShipTos(insertedShipTos));
		
		// when (ship-to with associations retrieved)
		
		List<Ship_To__c> processedShipTos = [
			SELECT ID, Contact_Ship_To__c, Address_Ship_To__c FROM Ship_To__c
		];
		
		// then ship-to is linked to a contact-address
		
		for (Ship_To__c shipTo : processedShipTos) {
			system.assertNotEquals(null, shipTo.Address_Ship_To__c);
		}
		
		// when (the contact is changed for that order)
		
		for (Ship_To__c shipTo : processedShipTos) {
			shipTo.Contact_Ship_To__c = null;
		}
		database.update(processedShipTos);
		
		// then (the order should have no link to the contact-address) 
		
        for (Ship_To__c shipTo : [SELECT ID, Contact_Ship_To__c, Address_Ship_To__c, Ship_To_Contact_Address__c FROM Ship_To__c]) {
            system.assertEquals(null, shipTo.Address_Ship_To__c);
        }  	
        
        // when (the ship to address is changed)
        
		testShipTos.get(0).Ship_to_Country__c = 'UK';
		database.update(testShipTos);      	
		
		// then historical address updated
		
        for (Ship_To__c shipTo : [SELECT ID, Contact_Ship_To__c, Address_Ship_To__c, Ship_To_Contact_Address__c FROM Ship_To__c]) {
            system.assertNotEquals(null, shipTo.Ship_To_Contact_Address__c);
        }		
	}
		
}