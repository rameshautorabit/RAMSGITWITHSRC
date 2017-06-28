@isTest
private class RH_OrdersTest {
	
    static String SSV_ID = '1234567';

    @testSetup
    static void setup() {
    	
    	PrepareData.populateCustomSettings();
    	
    	TestDataFactory.turnMdmFeatureFlagsOn();
        Account a = TestDataFactory.createAccount(true);
        Contact c = TestDataFactory.createContact(true);
        Customer_Address__c ca = TestDataFactory.createCustomerAddress(true);
        Source_System_View__c ssv = TestDataFactory.createSSV(false);
        ssv.EXT_Source_System_Customer_ID__c = SSV_ID;
        ssv.Account__c = a.Id;
        ssv.Contact__c = c.Id;
        ssv.Customer_Address__c = ca.Id;
        insert ssv;
    }  

    @isTest
    static void testSsvCreatingFromOrder() {

		// GIVEN (test User)    	
		
		User u = TestDataFactory.createUser();
        
		TriggerManager__c triggerManager = new TriggerManager__c(SetupOwnerId = u.Id, runTriggers__c=true, runMDMTriggers__c=true);
		insert triggerManager;
		
		// GIVEN (test trade account)
		
		List<Account> testAccounts = new List<Account>();
		testAccounts.add(new Account (
			NAME = 'test-account'
		));
		u.Single_View_of_Customer_Process_User__c = true;
		System.runAs(u) {
			database.insert(testAccounts);
		}
		
		// GIVEN (trade id from new account)
		
		String tradeId = [SELECT X12_Digit_Member__c FROM Account WHERE ID = :testAccounts.get(0).Id].X12_Digit_Member__c;
		system.assertNotEquals(NULL, tradeId);
		
    	// GIVEN (test order)
    	
    	List<SObject> testOrders = new List<SObject>();
    	testOrders.add(new RH_Order__c(
    		Sold_to_Customer_Number__c = 'this-is-a-test-record',
    		Sold_to_Country_Code__c = 'USA',
    		Trade_ID__c = tradeId
    	));
    	
    	// GIVEN (domain handler)
    	
    	RH_Orders domainOrders = new RH_Orders();
    	domainOrders.records.addAll(testOrders);
    	
    	// WHEN (call link to existing contact)
    	
    	domainOrders.linkToExistingContact((List<Rh_Order__c>)testOrders);
 
	    	
    	// THEN (account associated with order)
    	
    	System.assertNotEquals(null, testAccounts.get(0).Id);
    	System.assertEquals(testAccounts.get(0).Id, ((RH_Order__c)testOrders.get(0)).Account_Sold_To__c, 'order account not set');
    	
    	// WHEN (after insert trigger run)
    	
		domainOrders.handleSSVCreation(null);
        
        // THEN ssv generated
    	
    	System.assertEquals(1, domainOrders.recordsToInsert.size());
    	System.assertEquals('this-is-a-test-record', ((Source_System_View__c)domainOrders.recordsToInsert[0]).Name);    	
    	System.assertEquals(testAccounts.get(0).Id, ((Source_System_View__c)domainOrders.recordsToInsert[0]).Account__c);
    	System.assertEquals('US', ((Source_System_View__c)domainOrders.recordsToInsert[0]).Country_Code__c);
    }
	
    // Test setting Source_System_View_Sold_To__c by Sold_To_Customer_Number__c
    @isTest
    static void test_setSsvLookup_custNum_insert() {
    	
		User u = TestDataFactory.createUser();
        u.Single_View_of_Customer_Process_User__c = false;

		TriggerManager__c triggerManager = new TriggerManager__c(SetupOwnerId = u.Id, runTriggers__c=true, runMDMTriggers__c=true);
		insert triggerManager;
		
        System.runAs(u) {    
	        Source_System_View__c ssv = [
	            SELECT Account__c,
	                Contact__c,
	                Customer_Address__c
	            FROM Source_System_View__c
	            WHERE EXT_Source_System_Customer_ID__c = :SSV_ID
	        ];
	
	        RH_Order__c order = TestDataFactory.createRhOrder(false);
	        order.Sold_To_Customer_Number__c = SSV_ID;
	        insert order;
	
	        order = [
	            SELECT Source_System_View_Sold_To__c,
	                Account_Sold_To__c,
	                Contact_Sold_To__c,
	                Customer_Address_Sold_To__c
	            FROM RH_Order__c
	            WHERE Id = :order.Id
	        ];
	        System.assertEquals(ssv.Id, order.Source_System_View_Sold_To__c);
	        System.assertEquals(ssv.Account__c, order.Account_Sold_To__c);
	        System.assertEquals(ssv.Contact__c, order.Contact_Sold_To__c);
	        System.assertEquals(ssv.Customer_Address__C, order.Customer_Address_Sold_To__c);
        }
    }

    // Test setting Source_System_View_Sold_To__c by Sold_To_Customer_Number__c
    @isTest
    static void test_setSsvLookup_custNum_update() {
    	
		User u = TestDataFactory.createUser();
        u.Single_View_of_Customer_Process_User__c = false;

		TriggerManager__c triggerManager = new TriggerManager__c(SetupOwnerId = u.Id, runTriggers__c=true, runMDMTriggers__c=true);
		insert triggerManager;
		
        System.runAs(u) {     	
	        Source_System_View__c ssv = [
	            SELECT Account__c,
	                Contact__c,
	                Customer_Address__c
	            FROM Source_System_View__c
	            WHERE EXT_Source_System_Customer_ID__c = :SSV_ID
	        ];
	
	        RH_Order__c order = TestDataFactory.createRhOrder(false);
	        insert order;
	
	        order = [
	            SELECT Source_System_View_Sold_To__c,
	                Account_Sold_To__c,
	                Contact_Sold_To__c,
	                Customer_Address_Sold_To__c
	            FROM RH_Order__c
	            WHERE Id = :order.Id
	        ];
	        System.assertNotEquals(ssv.Id, order.Source_System_View_Sold_To__c);
	        System.assertNotEquals(ssv.Account__c, order.Account_Sold_To__c);
	        System.assertNotEquals(ssv.Contact__c, order.Contact_Sold_To__c);
	        System.assertNotEquals(ssv.Customer_Address__C, order.Customer_Address_Sold_To__c);
	
	        order.Sold_To_Customer_Number__c = SSV_ID;
	        update order;
	
	        order = [
	            SELECT Source_System_View_Sold_To__c,
	                Account_Sold_To__c,
	                Contact_Sold_To__c,
	                Customer_Address_Sold_To__c
	            FROM RH_Order__c
	            WHERE Id = :order.Id
	        ];
	        System.assertEquals(ssv.Id, order.Source_System_View_Sold_To__c);
	        System.assertEquals(ssv.Account__c, order.Account_Sold_To__c);
	        System.assertEquals(ssv.Contact__c, order.Contact_Sold_To__c);
	        System.assertEquals(ssv.Customer_Address__C, order.Customer_Address_Sold_To__c);
        }
    }

    // Test mirroring of lookup fields on children
    @isTest
    static void test_mirror_lookups_children() {
    	
    	User u = TestDataFactory.createUser();
		u.Single_View_of_Customer_Process_User__c = false;

        System.runAs(u) {    	   	
	        // Update lookup on order
	        Source_System_View__c ssv = [
	            SELECT Account__c,
	                Contact__c,
	                Customer_Address__c
	            FROM Source_System_View__c
	            WHERE EXT_Source_System_Customer_ID__c = :SSV_ID
	        ];
	        RH_Order__c order = TestDataFactory.createRhOrder(false);
	        order.Sold_To_Customer_Number__c = SSV_ID;
	        insert order;
	
	        Ship_To__c child = TestDataFactory.createShipTo(false);
	        child.Order__c = order.Id;
	        child.Ship_To_Customer_Number__c = '0';
	        insert child;
	
	        // Assert lookups are mirrored
	        child = [
	            SELECT CW_Customer_Ship_To__c, 
	                Account_Ship_To__c, 
	                Contact_Ship_To__c, 
	                Customer_Address_Ship_To__c
	            FROM Ship_To__c
	            WHERE Id = :child.Id
	        ];
	        System.assertEquals(ssv.Id, child.CW_Customer_Ship_To__c);
	        System.assertEquals(ssv.Account__c, child.Account_Ship_To__c);
	        System.assertEquals(ssv.Contact__c, child.Contact_Ship_To__c);
	        System.assertEquals(ssv.Customer_Address__c, child.Customer_Address_Ship_To__c);
	
	        order.Source_System_View_Sold_To__c = null;
	        order.Account_Sold_To__c = null;
	        order.Contact_Sold_To__c = null;
	        order.Customer_Address_Sold_To__c = null;
	        update order;
	        child = [
	            SELECT CW_Customer_Ship_To__c, 
	                Account_Ship_To__c, 
	                Contact_Ship_To__c, 
	                Customer_Address_Ship_To__c
	            FROM Ship_To__c
	            WHERE Id = :child.Id
	        ];
	        System.assertEquals(null, child.CW_Customer_Ship_To__c);
	        System.assertEquals(null, child.Account_Ship_To__c);
	        System.assertEquals(null, child.Contact_Ship_To__c);
	        System.assertEquals(null, child.Customer_Address_Ship_To__c);
        }
    }

    // Test non-mirroring of lookup fields on children because Ship_To_Customer_Number__c != 0
    @isTest
    static void test_not_mirror_lookups_children() {
    	
		User u = TestDataFactory.createUser();
		u.Single_View_of_Customer_Process_User__c = true;

        System.runAs(u) {    	
	        // Update lookup on order
	        Source_System_View__c ssv = [
	            SELECT Account__c,
	                Contact__c,
	                Customer_Address__c
	            FROM Source_System_View__c
	            WHERE EXT_Source_System_Customer_ID__c = :SSV_ID
	        ];
	        RH_Order__c order = TestDataFactory.createRhOrder(false);
	        order.Sold_To_Customer_Number__c = SSV_ID;
	        insert order;
	
	        Ship_To__c child = TestDataFactory.createShipTo(false);
	        child.Order__c = order.Id;
	        child.Ship_To_Customer_Number__c = '1';
	        insert child;
	
	        // Assert lookups are not mirrored
	        child = [
	            SELECT CW_Customer_Ship_To__c, 
	                Account_Ship_To__c, 
	                Contact_Ship_To__c, 
	                Customer_Address_Ship_To__c
	            FROM Ship_To__c
	            WHERE Id = :child.Id
	        ];
	        System.assertNotEquals(ssv.Id, child.CW_Customer_Ship_To__c);
	        System.assertNotEquals(ssv.Account__c, child.Account_Ship_To__c);
	        System.assertNotEquals(ssv.Contact__c, child.Contact_Ship_To__c);
	        System.assertNotEquals(ssv.Customer_Address__c, child.Customer_Address_Ship_To__c);
        }
    }

    // Test bulk updates
    @isTest
    static void test_mirror_ssv_lookup_children_bulk() {
        Integer numOrders = 40;
        Integer numChildrenEach = 5;

        System.debug('creating orders');
        List<RH_Order__c> orders = TestDataFactory.createRhOrders(numOrders, false);
        insert orders;
        System.debug('created orders');

        Source_System_View__c ssv = [
            SELECT Account__c,
                Contact__c,
                Customer_Address__c
            FROM Source_System_View__c
            WHERE EXT_Source_System_Customer_ID__c = :SSV_ID
        ];

        // Create children
        System.debug('creating shipTos');
        List<Ship_To__c> shipTos = TestDataFactory.createShipTos(numOrders * numChildrenEach, false);
        Integer count = 0;
        for (RH_Order__c order : orders) {
            for (Integer i = 0; i < numChildrenEach; i++) {
                shipTos[count].Order__c = order.Id;
                shipTos[count].Ship_To_Customer_Number__c = '0';
                count++;
            }
            order.Sold_To_Customer_Number__c = SSV_ID;
        }

        User u = TestDataFactory.createUser();
        u.Single_View_of_Customer_Process_User__c = false;

        System.runAs(u) {
            Reporter.startLogging();
            Reporter.log('Queries Before:' + Limits.getQueries());
            insert shipTos;
            Reporter.log('Queries After:' + Limits.getQueries());
            Reporter.stopLogging();
        }
        System.debug('created shipTos');

        // Update lookup on orders
        Test.startTest();
            System.debug('updating orders');
            update orders;
            System.debug('updated orders');
        Test.stopTest();

        // Assert update is mirrored
        List<Ship_To__c> children = [
            SELECT CW_Customer_Ship_To__c, Account_Ship_To__c, Contact_Ship_To__c, Customer_Address_Ship_To__c
            FROM Ship_To__c
            WHERE Id IN :shipTos
        ];
        for (Ship_To__c child : children) {
            // System.assertEquals(ssv.Id, child.CW_Customer_Ship_To__c);
            // System.assertEquals(ssv.Account__c, child.Account_Ship_To__c);
            // System.assertEquals(ssv.Contact__c, child.Contact_Ship_To__c);
            // System.assertEquals(ssv.Customer_Address__C, child.Customer_Address_Ship_To__c);
        }
    }
}