@isTest
private class AddressesTest {
	
    static String STREET = 'test street';
    static String CITY = 'Vancouver';
    static String COUNTRY_CODE = 'CA';
    static String STATE = 'BC';
    static String POSTAL_CODE = 'test zip';

    static String STREET_2 = 'test street2';
    static String CITY_2 = 'Vancouver2';
    static String COUNTRY_CODE_2 = 'US';
    static String STATE_2 = 'DC';
    static String POSTAL_CODE_2 = 'test zip2';

    @testSetup
    static void setup() {
    	TestDataFactory.turnMdmFeatureFlagsOn();
        TestDataFactoryHelper.COUNTER = -10;
        User u = TestDataFactory.createUser();
        u.Single_View_of_Customer_Process_User__c = false;
        System.runAs(u) {
            Contact c = TestDataFactory.createContact(true);
            Address__c a = TestDataFactory.createAddress(false);
            a.Address_1__c = STREET;
            a.City__c = CITY;
            a.Country_Code__c = COUNTRY_CODE;
            a.State__c = STATE;
            a.Zip__c = POSTAL_CODE;
            insert a;

            // Relate contact to address
            Customer_Address__c ca = TestDataFactory.createCustomerAddress(false, false);
            ca.Is_Principal_Address__c = true;
            ca.Address__c = a.Id;
            ca.Contact__c = c.Id;
            insert ca;
        }
    }
    
    @isTest
    public static void testAmericanZipFormattingInMatchKey() {
    	
    	List<Address__c> addresses = new List<Address__c>(); 
    	addresses.add(new Address__c(
    		Zip__c = '123456789',
    		Country_Code__c = 'MEX'
    	));
    	addresses.add(new Address__c(
    		Zip__c = '123456789',
    		Country_Code__c = 'USA'
    	));    	
    	addresses.add(new Address__c(
    		Zip__c = '123456789'
    	));  
    	    	
    	addresses[0].Address_Match_Key__c = SSVCleaner.buildAddressMatchKey(addresses[0]);
    	addresses[1].Address_Match_Key__c = SSVCleaner.buildAddressMatchKey(addresses[1]);
    	addresses[2].Address_Match_Key__c = SSVCleaner.buildAddressMatchKey(addresses[2]);
    	
    	System.assertEquals('123456789', addresses[0].Address_Match_Key__c);
    	System.assertEquals('12345', addresses[1].Address_Match_Key__c);
    	System.assertEquals('123456789', addresses[2].Address_Match_Key__c);
    }
    
    // Test updating related contacts on update of an address
    @isTest
    static void test_updateContacts() {
        Contact c = [SELECT Id FROM Contact];
        Address__c a = [SELECT Id FROM Address__c];
        update_2(a);
        assertUpdated(c);
    }

    // Test setting the match key and hash on insert of an address
    @isTest
    static void test_setMatchKey_insert() {
        Address__c a = [SELECT Address_Match_Key__c, Address_Match_Key_Hash__c FROM Address__c];
        System.assertNotEquals(null, a.Address_Match_Key__c);
        System.assertNotEquals(null, a.Address_Match_Key_Hash__c);
    }

    // Test setting the match key and hash on update of an address
    @isTest
    static void test_setMatchKey_update() {
        Address__c a = [SELECT Address_Match_Key__c, Address_Match_Key_Hash__c FROM Address__c];
        System.assertNotEquals(null, a.Address_Match_Key__c);
        System.assertNotEquals(null, a.Address_Match_Key_Hash__c);
        update_2(a);
        Address__c a2 = [SELECT Address_Match_Key__c, Address_Match_Key_Hash__c FROM Address__c];
        System.assertNotEquals(a2.Address_Match_Key__c, a.Address_Match_Key__c);
        System.assertNotEquals(a2.Address_Match_Key_Hash__c, a.Address_Match_Key_Hash__c);
    }

    static void update_2(Address__c a) {
        a.Address_1__c = STREET_2;
        a.City__c = CITY_2;
        a.Country_Code__c = COUNTRY_CODE_2;
        a.State__c = STATE_2;
        a.Zip__c = POSTAL_CODE_2;
        update a;
    }

    static void assertUpdated(Contact c) {
        c = [SELECT MailingStreet,
                MailingCity,
                MailingCountry,
                MailingState,
                MailingPostalCode
            FROM Contact
            WHERE Id = :c.Id
        ];
        System.assertEquals(STREET_2, c.MailingStreet);
        System.assertEquals(CITY_2, c.MailingCity);
        System.assertEquals(COUNTRY_CODE_2, c.MailingCountry);
        System.assertEquals(STATE_2, c.MailingState);
        System.assertEquals(POSTAL_CODE_2, c.MailingPostalCode);
    }

    static void assertNotUpdated(Contact c) {
        c = [SELECT MailingStreet,
                MailingCity,
                MailingCountry,
                MailingState,
                MailingPostalCode
            FROM Contact
            WHERE Id = :c.Id
        ];
        System.assertNotEquals(STREET_2, c.MailingStreet);
        System.assertNotEquals(CITY_2, c.MailingCity);
        System.assertNotEquals(COUNTRY_CODE_2, c.MailingCountry);
        System.assertNotEquals(STATE_2, c.MailingState);
        System.assertNotEquals(POSTAL_CODE_2, c.MailingPostalCode);
    }
}