@isTest
private class CustomerAddressesTest {
	
	static {
		TestDataFactory.turnMdmFeatureFlagsOn();
	}	

    static String STREET = 'test street';
    static String CITY = 'Vancouver';
    static String COUNTRY_CODE = 'CA';
    static String STATE = 'BC';
    static String POSTAL_CODE = '1234567';
    
    static User nonIntegrationUser {
	    get {
	            if (nonIntegrationUser == null) {
	                nonIntegrationUser = TestDataFactory.createUser();
	                nonIntegrationUser.Single_View_of_Customer_Process_User__c = false;
	                
					TriggerManager__c triggerManager = new TriggerManager__c(SetupOwnerId = nonIntegrationUser.Id, runTriggers__c=true, runMDMTriggers__c=true);
					insert triggerManager;                
	            }
	            return nonIntegrationUser;
	    } set; 
	}

    @testSetup
    static void setup() {
        Contact c = TestDataFactory.createContact(true);
        Address__c a = TestDataFactory.createAddress(false);
        a.Address_1__c = STREET;
        a.City__c = CITY;
        a.Country_Code__c = COUNTRY_CODE;
        a.State__c = STATE;
        a.Zip__c = POSTAL_CODE;
        
        System.runAs(nonIntegrationUser) {  
        	insert a;
        }
    }

    // Test updating related contacts on insert of a principle address
    @isTest
    static void test_updateContacts_insert() {
        Address__c a = [SELECT Id FROM Address__c];
        Contact c = [SELECT Id FROM Contact];
        Customer_Address__c ca = TestDataFactory.createCustomerAddress(false, false);
        ca.Is_Principal_Address__c = true;
        ca.Address__c = a.Id;
        ca.Contact__c = c.Id;

		System.runAs(nonIntegrationUser) {  
        	insert ca;
		}
		
        assertUpdated(c);
	}

    // Test updating related contacts on update of a customer address to a principle address
    @isTest
    static void test_updateContacts_update() {
        Address__c a = [SELECT Id FROM Address__c];
        Contact c = [SELECT Id FROM Contact];
        Customer_Address__c ca = TestDataFactory.createCustomerAddress(false, false);
        ca.Is_Principal_Address__c = false;
        ca.Address__c = a.Id;
        ca.Contact__c = c.Id;
        insert ca;
        assertNotUpdated(c);

        ca.Is_Principal_Address__c = true;
        System.runAs(nonIntegrationUser) {  
        	update ca;
        }
        assertUpdated(c);
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
        System.assertEquals(STREET, c.MailingStreet);
        System.assertEquals(CITY, c.MailingCity);
        System.assertEquals(COUNTRY_CODE, c.MailingCountry);
        System.assertEquals(STATE, c.MailingState);
        System.assertEquals(POSTAL_CODE, c.MailingPostalCode);
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
        System.assertNotEquals(STREET, c.MailingStreet);
        System.assertNotEquals(CITY, c.MailingCity);
        System.assertNotEquals(COUNTRY_CODE, c.MailingCountry);
        System.assertNotEquals(STATE, c.MailingState);
        System.assertNotEquals(POSTAL_CODE, c.MailingPostalCode);
    }
}