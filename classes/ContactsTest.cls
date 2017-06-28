/**
 * Test class for contact triggers
 * @author Zi Zhang + John Rogers, Traction on Demand
 * @date   2016-02-27
 */
@isTest
public class ContactsTest {

	static {
		TestDataFactory.turnMdmFeatureFlagsOn();
	}
		
    private static Id companyAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Contract').getRecordTypeId();
    static Account testAccount;
    static Contact masterContact, mergeContact, testContact;
    static RH_Order__c testOrder;
    static Order_Role__c testOrderRole;

    // Test creation of no CI records due to integration user running
    static testMethod void test_createContactInformationRecords_integration() {
        User u = TestDataFactory.createUser();
        u.Single_View_of_Customer_Process_User__c = true;
        System.runAs(u) {
            Contact c = TestDataFactory.createContact(false);
            c.Email = 'test@test.com';
            c.Alternate_Email__c = 'test2@test.com';
            c.Phone = '456';
            c.Phone_Extension__c = 789;
            c.MobilePhone = '101112';
            c.Fax = '123';
            insert c;

            List<Contact_Information__c> cis = [
                SELECT Is_Primary__c,
                    Contact_Information_Medium__c, 
                    Email__c,
                    RecordTypeId
                FROM Contact_Information__c 
                WHERE Contact__c = :c.Id
            ];

            System.assertEquals(0, cis.size());
        }
    }

    // Test creation of related CI records on insert
    static testMethod void test_createContactInformationRecords_all() {
        User u = TestDataFactory.createUser();
        u.Single_View_of_Customer_Process_User__c = false;
        System.runAs(u) {
            Contact c = TestDataFactory.createContact(false);
            c.Email = 'test@test.com';
            c.Alternate_Email__c = 'test2@test.com';
            c.Phone = '456';
            c.Phone_Extension__c = 789;
            c.MobilePhone = '101112';
            c.Fax = '123';
            insert c;

            List<Contact_Information__c> cis = [
                SELECT Is_Primary__c,
                    Contact_Information_Medium__c, 
                    Email__c,
                    RecordTypeId
                FROM Contact_Information__c 
                WHERE Contact__c = :c.Id
            ];

            System.assertEquals(0, cis.size());
        }
    }

    // Test creation of no CI records on insert
    static testMethod void test_createContactInformationRecords_none() {
        User u = TestDataFactory.createUser();
        u.Single_View_of_Customer_Process_User__c = false;
        System.runAs(u) {
            Contact c = TestDataFactory.createContact(false);
            c.Email = null;
            c.Alternate_Email__c = null;
            c.Phone = null;
            c.Phone_Extension__c = null;
            c.MobilePhone = null;
            c.Fax = null;
            insert c;

            List<Contact_Information__c> cis = [
                SELECT Is_Primary__c,
                    Contact_Information_Medium__c, 
                    Email__c,
                    RecordTypeId
                FROM Contact_Information__c 
                WHERE Contact__c = :c.Id
            ];

            System.assertEquals(0, cis.size());
        }
    }

    /**
     * Test Business Contact triggers - upsert ssv records
     * @author Zi Zhang, Traction on Demand
     * @date   2016-03-09
     */
    public static testMethod void testBusinessContactTrigger() {
        User u = TestDataFactory.createUser();
        u.Single_View_of_Customer_Process_User__c = false;
        
        System.runAs(u) {
            System.assertEquals(true, String.isNotEmpty(companyAccountRecTypeId), 'Company Account Record Type not found.');
            createCompanyAccountFieldMappingSettings();
            createBusinessContactFieldMappingSettings();

            // Insert new company account
            testAccount = new Account(Name = 'Test Company Account', RecordTypeId = companyAccountRecTypeId);
            insert testAccount;

            System.assertNotEquals(null, testAccount.Id, 'Error inserting account.');

            List<Source_System_View__c> resultCompanySSVs = [SELECT Id, Name, Account__c, Company_Name__c, Contact__c, First_Name__c, Last_Name__c 
                                                        FROM Source_System_View__c 
                                                        WHERE Account__c = :testAccount.Id];

            System.assertEquals(1, resultCompanySSVs.size(), 'Related Account SSV record does not exist.');

            testContact = new Contact(FirstName = 'Test Contact FName', LastName = 'Test Contact LName', AccountId = testAccount.Id, MailingStreet='123 Fake St.');
            insert testContact;

            List<Source_System_View__c> resultSSVs = [SELECT Id, Name, Account__c, Company_Name__c, Contact__c, First_Name__c, Last_Name__c, Source_System_View_CW_Company__c 
                                                        FROM Source_System_View__c 
                                                        WHERE Contact__c = :testContact.Id];
            System.assertEquals(1, resultSSVs.size(), 'SSV record does not exist.');
            System.assertEquals('SFDC-' + testContact.Id, resultSSVs[0].Name, 'Name field not mapped.');
            System.assertEquals(testContact.Id, resultSSVs[0].Contact__c, 'Contact__c field not mapped.');
            System.assertEquals(testAccount.Name, resultSSVs[0].Company_Name__c, 'Company_Name__c field not mapped.');
            System.assertEquals(testContact.FirstName, resultSSVs[0].First_Name__c, 'First_Name__c field not mapped.');
            System.assertEquals(testContact.LastName, resultSSVs[0].Last_Name__c, 'Last_Name__c field not mapped.');
            System.assertEquals(testAccount.Id, resultSSVs[0].Account__c, 'Account__c field not mapped.');
            System.assertEquals(resultCompanySSVs[0].Id, resultSSVs[0].Source_System_View_CW_Company__c, 'SSV record not linked to Company SSV record.');

            // Update key fields on company account
            testContact.FirstName = 'Test FName modified';
            update testContact;

            resultSSVs = [SELECT Id, Name, Account__c, Company_Name__c, Contact__c, First_Name__c, Last_Name__c FROM Source_System_View__c WHERE Contact__c = :testContact.Id];

            System.assertEquals(1, resultSSVs.size(), 'SSV record does not exist.');
            System.assertEquals(testContact.FirstName, resultSSVs[0].First_Name__c, 'First_Name__c field not mapped.');

            delete testContact;

            resultSSVs = [SELECT Id FROM Source_System_View__c WHERE Contact__c = :testContact.Id];

            System.assertEquals(0, resultSSVs.size(), 'SSV record was not deleted.');
        }
    }

    /**
     * Test Business Contact triggers and Account triggers on lead convert
     * @author Zi Zhang, Traction on Demand
     * @date   2016-03-09
     */
    public static testMethod void testBusinessContactTriggerOnLeadConvert() {
        User u = TestDataFactory.createUser();
        u.Single_View_of_Customer_Process_User__c = false;

        System.runAs(u) {
            createCompanyAccountFieldMappingSettings();
            createBusinessContactFieldMappingSettings();
			createApplicationSettings();			

            // Create test lead to convert
            Lead testLead = new Lead();
            testLead.FirstName = 'Test First';
            testLead.LastName = 'Test Last';
            testLead.Company = 'Test Co';
            insert testLead;

            Test.StartTest();
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(testLead.id);

            LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);

            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());

            Test.StopTest();

            List<Contact> contactResult = [Select Id, FirstName, LastName, AccountId, Account.IsPersonAccount FROM Contact];
            List<Account> accountResult = [Select Id, Name, X12_Digit_Member__c FROM Account];

            System.assertEquals(1, accountResult.size(), 'Lead Convert did not create an Account');
            System.assertNotEquals(NULL, accountResult[0].X12_Digit_Member__c, 'Lead Convert did not create a trade-id for the account');
            System.assertEquals(1, contactResult.size(), 'Lead Convert did not create a Contact');
            System.assertEquals(accountResult[0].Id, contactResult[0].AccountId, 'Lead Convert did not link Contact and Account');

            List<Source_System_View__c> resultCompanySSVs = [SELECT Id, Name, Account__c, Company_Name__c, Contact__c, First_Name__c, Last_Name__c 
                                                        FROM Source_System_View__c 
                                                        WHERE Source_Table__c = 'Salesforce Account'];

            System.assertEquals(1, resultCompanySSVs.size(), 'Account SSV record does not exist.');

            List<Source_System_View__c> resultSSVs = [SELECT Id, Name, Account__c, Company_Name__c, Contact__c, First_Name__c, Last_Name__c, Source_System_View_CW_Company__c 
                                                        FROM Source_System_View__c 
                                                        WHERE Contact__c = :contactResult[0].Id];
            System.assertEquals(1, resultSSVs.size(), 'SSV record does not exist.');
            System.assertEquals('SFDC-' + contactResult[0].Id, resultSSVs[0].Name, 'Name field not mapped.');
            System.assertEquals(contactResult[0].Id, resultSSVs[0].Contact__c, 'Contact__c field not mapped.');
            System.assertEquals(accountResult[0].Name, resultSSVs[0].Company_Name__c, 'Company_Name__c field not mapped.');
            System.assertEquals(contactResult[0].FirstName, resultSSVs[0].First_Name__c, 'First_Name__c field not mapped.');
            System.assertEquals(contactResult[0].LastName, resultSSVs[0].Last_Name__c, 'Last_Name__c field not mapped.');
            System.assertEquals(accountResult[0].Id, resultSSVs[0].Account__c, 'Account__c field not mapped.');
            System.assertEquals(resultCompanySSVs[0].Id, resultSSVs[0].Source_System_View_CW_Company__c, 'SSV record not linked to Company SSV record.');
        }
    }

    /*********************** Test data custom settings field mapping ****************************/
    private static void createBusinessContactFieldMappingSettings() {
        List<Contact_SSV_Field_Mapping__c> settings = new List<Contact_SSV_Field_Mapping__c>();
        settings.add(new Contact_SSV_Field_Mapping__c(Name = 'FM1', Source_Field__c = 'ID', Target_Field__c = 'Name'));
        settings.add(new Contact_SSV_Field_Mapping__c(Name = 'FM3', Source_Field__c = 'ID', Target_Field__c = 'Contact__c'));
        settings.add(new Contact_SSV_Field_Mapping__c(Name = 'FM4', Source_Field__c = 'FirstName', Target_Field__c = 'First_Name__c'));
        settings.add(new Contact_SSV_Field_Mapping__c(Name = 'FM5', Source_Field__c = 'LastName', Target_Field__c = 'Last_Name__c'));
        settings.add(new Contact_SSV_Field_Mapping__c(Name = 'FM6', Source_Field__c = 'ID', Target_Field__c = 'EXT_Source_System_Customer_ID__c'));
        settings.add(new Contact_SSV_Field_Mapping__c(Name = 'FM7', Source_Field__c = 'AccountId', Target_Field__c = 'Account__c'));

        insert settings;
    } 

    private static void createCompanyAccountFieldMappingSettings() {
        List<Company_Account_SSV_Field_Mapping__c> settings = new List<Company_Account_SSV_Field_Mapping__c>();
        settings.add(new Company_Account_SSV_Field_Mapping__c(Name = 'FM1', Source_Field__c = 'ID', Target_Field__c = 'Name'));
        settings.add(new Company_Account_SSV_Field_Mapping__c(Name = 'FM2', Source_Field__c = 'ID', Target_Field__c = 'Account__c'));
        settings.add(new Company_Account_SSV_Field_Mapping__c(Name = 'FM3', Source_Field__c = 'Name', Target_Field__c = 'Company_Name__c'));

        insert settings;
    } 
    
    private static void createApplicationSettings() {
    	List<Application_Settings__c> settings = new LIst<Application_Settings__c>();
    	settings.add(new Application_Settings__c(Name = 'QuoteCloneStatusToCreatePortalUser', Value_Text__c = 'Quote finalized - Payment Link Sent'));
    	insert settings;
    }
}