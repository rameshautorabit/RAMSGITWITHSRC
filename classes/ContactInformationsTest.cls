@isTest
private class ContactInformationsTest {

	static {
		TestDataFactory.turnMdmFeatureFlagsOn();
	}

    // Values test contact is created with
    static String PHONE_1 = '456';
    static Double PHONE_EXT_1 = 789;
    static String PHONE_EXT_1_STR {
        get { return String.valueOf(PHONE_EXT_1); }
    }
    static String EMAIL_1 = 'test@test.com';
    static String ALTERNATE_EMAIL_1 = 'test2@test.com';
    static String MOBILE_1 = '101112';
    static String FAX_1 = '123';

    // Values the test contact is updated to
    static String PHONE_2 = '456-2';
    static Double PHONE_EXT_2 = 789789;
    static String PHONE_EXT_2_STR {
        get { return String.valueOf(PHONE_EXT_2); }
    }
    static String EMAIL_2 = 'test2@test.com';
    static String FAX_2 = '123123';

    @testSetup
    static void setup() {
        User u = TestDataFactory.createUser();
        u.Single_View_of_Customer_Process_User__c = false;
        System.runAs(u) {
            Contact c = TestDataFactory.createContact(false);
            c.Email = EMAIL_1;
            c.Alternate_Email__c = ALTERNATE_EMAIL_1;
            c.Phone = PHONE_1;
            c.Phone_Extension__c = PHONE_EXT_1;
            c.MobilePhone = MOBILE_1;
            c.Fax = FAX_1;
            insert c;
        }
    }

    // Test updating a contact by updating the contact's CI records
    @isTest
    static void test_updateContacts_update() {
        updateContacts_update();
        assertUpdated();
    }

    // Test updating contacts by creating new contact informations
    @isTest
    static void test_updateContacts_insert() {
        updateContacts_insert();
        assertUpdated();
    }

    // Test setting the match key
   /* @isTest
    static void test_setMatchKey_insert() {
        // Get the CI record created on contact insert
        Contact_Information__c ci = [
            SELECT Contact_Information_Match_Key__c, Contact_Information_Match_Key_Hash__c
            FROM Contact_Information__c
            LIMIT 1
        ];

        System.assertNotEquals(null, ci.Contact_Information_Match_Key__c);
        System.assertNotEquals(null, ci.Contact_Information_Match_Key_Hash__c);
    }*/

    // Test setting the match key
   /* @isTest
    static void test_setMatchKey_update() {
        // Get the CI record created on contact insert
        Contact_Information__c ci = [
            SELECT Contact_Information_Match_Key__c, Contact_Information_Match_Key_Hash__c
            FROM Contact_Information__c
            LIMIT 1
        ];

        ci.Email__c = EMAIL_2;
        update ci;

        Contact_Information__c ci2 = [
            SELECT Contact_Information_Match_Key__c, Contact_Information_Match_Key_Hash__c
            FROM Contact_Information__c
            WHERE Id = :ci.Id
        ];

    //    System.assertNotEquals(ci2.Contact_Information_Match_Key__c, ci.Contact_Information_Match_Key__c);
    //    System.assertNotEquals(ci2.Contact_Information_Match_Key_Hash__c, ci.Contact_Information_Match_Key_Hash__c);
    }*/

    static void updateContacts_insert() {
        // Get the CI records created on contact insert
        List<Contact_Information__c> cis = [
            SELECT RecordTypeId, Contact__c, Contact_Information_Type__c, Is_Primary__c
            FROM Contact_Information__c
        ];

        for (Contact_Information__c ci : cis) {
            if (ci.Is_Primary__c) {
                if (ci.RecordTypeId == ContactInformations.EMAIL_RECORD_TYPE_ID) {
                    ci.Email__c = EMAIL_2;
                } else if (ci.RecordTypeId == ContactInformations.PHONE_RECORD_TYPE_ID) {
                    ci.Phone__c = PHONE_2;
                    ci.Phone_Extension__c = PHONE_EXT_2_STR;
                } else if (ci.RecordTypeId == ContactInformations.FAX_RECORD_TYPE_ID) {
                    ci.Phone__c = FAX_2;
                }
            }
        }

        update cis;
    }

    static void updateContacts_update() {
        Contact c = [SELECT Id FROM Contact];

        List<Contact_Information__c> cis = TestDataFactory.createContactInformations(3, false);
        for (Contact_Information__c ci : cis) {
            ci.Is_Primary__c = true;
            ci.Contact__c = c.Id;
        }

        cis[0].RecordTypeId = ContactInformations.EMAIL_RECORD_TYPE_ID; 
        cis[0].Email__c = EMAIL_2;

        cis[1].RecordTypeId = ContactInformations.PHONE_RECORD_TYPE_ID;
        cis[1].Phone__c = PHONE_2;
        cis[1].Phone_Extension__c = PHONE_EXT_2_STR;

        cis[2].RecordTypeId = ContactInformations.FAX_RECORD_TYPE_ID;
        cis[2].Phone__c = FAX_2;
        cis[2].Contact_Information_Type__c = 'Fax';

        insert cis;
    }

    static void assertUpdated() {
        Contact c = [SELECT Phone, Phone_Extension__c, Email, Fax
            FROM Contact
        ];
        //System.assertEquals(PHONE_2, c.Phone);
        //System.assertEquals(PHONE_EXT_2, c.Phone_Extension__c);
        //System.assertEquals(EMAIL_2, c.Email);
        //System.assertEquals(FAX_2, c.Fax);
    }

    static void assertNotUpdated() {
        Contact c = [SELECT Phone, Phone_Extension__c, Email, Fax
            FROM Contact
        ];
        //System.assertEquals(PHONE_1, c.Phone);
        //System.assertEquals(PHONE_EXT_1, c.Phone_Extension__c);
        //System.assertEquals(EMAIL_1, c.Email);
        //System.assertEquals(FAX_1, c.Fax);
    }
}