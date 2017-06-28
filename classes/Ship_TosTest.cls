@isTest
private class Ship_TosTest {

    static String CUST_ID = '123456789';
    static Integer NUM_SHIP_TOS = 10;

    static User nonIntegrationUser {
        get {
            if (nonIntegrationUser == null) {
                nonIntegrationUser = TestDataFactory.createUser();
                nonIntegrationUser.Single_View_of_Customer_Process_User__c = false;
            }
            return nonIntegrationUser;
        } set;
    }

    @testSetup
    static void setup() {
    	
    	PrepareData.populateCustomSettings();
    	
    	TestDataFactory.turnMdmFeatureFlagsOn();    	    	
        Account a = TestDataFactory.createAccount(true);
        Contact c = TestDataFactory.createContact(true);
        Customer_Address__c ca = TestDataFactory.createCustomerAddress(true);
        Source_System_View__c ssv = TestDataFactory.createSSV(false);
        ssv.EXT_Source_System_Customer_ID__c = CUST_ID;
        ssv.Account__c = a.Id;
        ssv.Contact__c = c.Id;
        ssv.Customer_Address__c = ca.Id;
        insert ssv;

        a = TestDataFactory.createAccount(true);
        c = TestDataFactory.createContact(true);
        ca = TestDataFactory.createCustomerAddress(true);
        RH_Order__c order = TestDataFactory.createRhOrder(false);
        order.Account_Sold_To__c = a.Id;
        order.Contact_Sold_To__c = c.Id;
        order.Customer_Address_Sold_To__c = ca.Id;
        insert order;
    }
    
    // Test setting CW_Customer_Ship_To__c & other lookups by non-zero Ship_To_Customer_Number__c on insert
    @isTest
    static void test_setSsvLookup_insert_non_zero() {
        RH_Order__c order = [
            SELECT Account_Sold_To__c,
                Contact_Sold_To__c,
                Customer_Address_Sold_To__c
            FROM RH_Order__c
        ];

        Source_System_View__c ssv = [
            SELECT Account__c,
                Contact__c,
                Customer_Address__c
            FROM Source_System_View__c
            WHERE EXT_Source_System_Customer_ID__c = :CUST_ID
        ];

        // Create children
        System.debug('creating shipTos');
        List<Ship_To__c> shipTos = TestDataFactory.createShipTos(NUM_SHIP_TOS, false);
        for (Ship_To__c shipTo : shipTos) {
            shipTo.Order__c = order.Id;
            shipTo.Ship_To_Customer_Number__c = CUST_ID;
        }

        System.runAs(nonIntegrationUser) { 
            insert shipTos;
        }
        System.debug('created shipTos');

        // Assert insert is mirrored to SSV
        List<Ship_To__c> children = [
            SELECT CW_Customer_Ship_To__c,
                Account_Ship_To__c, 
                Contact_Ship_To__c, 
                Customer_Address_Ship_To__c
            FROM Ship_To__c
            WHERE Id IN :shipTos
        ];
        for (Ship_To__c child : children) {
            System.assertEquals(ssv.Id, child.CW_Customer_Ship_To__c);
            System.assertEquals(ssv.Account__c, child.Account_Ship_To__c);
            System.assertEquals(ssv.Contact__c, child.Contact_Ship_To__c);
            System.assertEquals(ssv.Customer_Address__c, child.Customer_Address_Ship_To__c);
        }
    }

    // Test setting CW_Customer_Ship_To__c & other lookups by non-zero Ship_To_Customer_Number__c on update
    @isTest
    static void test_setSsvLookup_update_non_zero() {
        RH_Order__c order = [
            SELECT Account_Sold_To__c,
                Contact_Sold_To__c,
                Customer_Address_Sold_To__c
            FROM RH_Order__c
        ];

        Source_System_View__c ssv = [
            SELECT Account__c,
                Contact__c,
                Customer_Address__c
            FROM Source_System_View__c
            WHERE EXT_Source_System_Customer_ID__c = :CUST_ID
        ];

        // Create children
        System.debug('creating shipTos');
        List<Ship_To__c> shipTos = TestDataFactory.createShipTos(NUM_SHIP_TOS, false);
        for (Ship_To__c shipTo : shipTos) {
            shipTo.Order__c = order.Id;
        }

        System.runAs(nonIntegrationUser) { 
            insert shipTos;
        }
        System.debug('created shipTos');

        // Assert update is not mirrored to SSV
        List<Ship_To__c> children = [
            SELECT CW_Customer_Ship_To__c,
                Account_Ship_To__c, 
                Contact_Ship_To__c, 
                Customer_Address_Ship_To__c
            FROM Ship_To__c
            WHERE Id IN :shipTos
        ];
        for (Ship_To__c child : children) {
            System.assertNotEquals(ssv.Id, child.CW_Customer_Ship_To__c);
            System.assertNotEquals(ssv.Account__c, child.Account_Ship_To__c);
            System.assertNotEquals(ssv.Contact__c, child.Contact_Ship_To__c);
            System.assertNotEquals(ssv.Customer_Address__c, child.Customer_Address_Ship_To__c);
        }

        for (Ship_To__c shipTo : shipTos) {
            shipTo.Ship_To_Customer_Number__c = CUST_ID;
        }

        System.runAs(nonIntegrationUser) { 
            update shipTos;
        }

        // Assert update is mirrored to SSV
        children = [
            SELECT CW_Customer_Ship_To__c,
                Account_Ship_To__c, 
                Contact_Ship_To__c, 
                Customer_Address_Ship_To__c
            FROM Ship_To__c
            WHERE Id IN :shipTos
        ];
        for (Ship_To__c child : children) {
            System.assertEquals(ssv.Id, child.CW_Customer_Ship_To__c);
            System.assertEquals(ssv.Account__c, child.Account_Ship_To__c);
            System.assertEquals(ssv.Contact__c, child.Contact_Ship_To__c);
            System.assertEquals(ssv.Customer_Address__c, child.Customer_Address_Ship_To__c);
        }
    }

    // Test setting CW_Customer_Ship_To__c & other lookups by zero Ship_To_Customer_Number__c on insert
    @isTest
    static void test_setSsvLookup_insert_zero() {
        RH_Order__c order = [
            SELECT Source_System_View_Sold_To__c, 
                Account_Sold_To__c,
                Contact_Sold_To__c,
                Customer_Address_Sold_To__c
            FROM RH_Order__c
        ];

        Source_System_View__c ssv = [
            SELECT Account__c,
                Contact__c,
                Customer_Address__c
            FROM Source_System_View__c
            WHERE EXT_Source_System_Customer_ID__c = :CUST_ID
        ];

        // Create children
        System.debug('creating shipTos');
        List<Ship_To__c> shipTos = TestDataFactory.createShipTos(NUM_SHIP_TOS, false);
        for (Ship_To__c shipTo : shipTos) {
            shipTo.Order__c = order.Id;
            shipTo.Ship_To_Customer_Number__c = '0';
        }

        System.runAs(nonIntegrationUser) { 
            insert shipTos;
        }
        System.debug('created shipTos');

        // Assert update is mirrored to order
        List<Ship_To__c> children = [
            SELECT CW_Customer_Ship_To__c,
                Account_Ship_To__c, 
                Contact_Ship_To__c, 
                Customer_Address_Ship_To__c
            FROM Ship_To__c
            WHERE Id IN :shipTos
        ];
        for (Ship_To__c child : children) {
            System.assertEquals(order.Source_System_View_Sold_To__c, child.CW_Customer_Ship_To__c);
            System.assertEquals(order.Account_Sold_To__c, child.Account_Ship_To__c);
            System.assertEquals(order.Contact_Sold_To__c, child.Contact_Ship_To__c);
            System.assertEquals(order.Customer_Address_Sold_To__c, child.Customer_Address_Ship_To__c);
        }
    }

    // Test setting CW_Customer_Ship_To__c & other lookups by zero Ship_To_Customer_Number__c on update
    @isTest
    static void test_setSsvLookup_update_zero() {
        RH_Order__c order = [
            SELECT Source_System_View_Sold_To__c,
                Account_Sold_To__c,
                Contact_Sold_To__c,
                Customer_Address_Sold_To__c
            FROM RH_Order__c
        ];

        Source_System_View__c ssv = [
            SELECT Account__c,
                Contact__c,
                Customer_Address__c
            FROM Source_System_View__c
            WHERE EXT_Source_System_Customer_ID__c = :CUST_ID
        ];

        // Create children
        System.debug('creating shipTos');
        List<Ship_To__c> shipTos = TestDataFactory.createShipTos(NUM_SHIP_TOS, false);
        for (Ship_To__c shipTo : shipTos) {
            shipTo.Order__c = order.Id;
        }

        System.runAs(nonIntegrationUser) { 
            insert shipTos;
        }
        System.debug('created shipTos');

        // Assert update is not mirrored to order
        List<Ship_To__c> children = [
            SELECT CW_Customer_Ship_To__c,
                Account_Ship_To__c, 
                Contact_Ship_To__c, 
                Customer_Address_Ship_To__c
            FROM Ship_To__c
            WHERE Id IN :shipTos
        ];
        for (Ship_To__c child : children) {
            System.assertNotEquals(order.Account_Sold_To__c, child.Account_Ship_To__c);
            System.assertNotEquals(order.Contact_Sold_To__c, child.Contact_Ship_To__c);
            System.assertNotEquals(order.Customer_Address_Sold_To__c, child.Customer_Address_Ship_To__c);
        }

        for (Ship_To__c shipTo : shipTos) {
            shipTo.Ship_To_Customer_Number__c = '0';
        }

        System.runAs(nonIntegrationUser) { 
            update shipTos;
        }

        // Assert update is mirrored to order
        children = [
            SELECT CW_Customer_Ship_To__c,
                Account_Ship_To__c, 
                Contact_Ship_To__c, 
                Customer_Address_Ship_To__c
            FROM Ship_To__c
            WHERE Id IN :shipTos
        ];
        for (Ship_To__c child : children) {
            System.assertEquals(order.Source_System_View_Sold_To__c, child.CW_Customer_Ship_To__c);
            System.assertEquals(order.Account_Sold_To__c, child.Account_Ship_To__c);
            System.assertEquals(order.Contact_Sold_To__c, child.Contact_Ship_To__c);
            System.assertEquals(order.Customer_Address_Sold_To__c, child.Customer_Address_Ship_To__c);
        }
    }
}