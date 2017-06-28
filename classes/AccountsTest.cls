/**
 * Test class for account triggers (Upsert SSV records)
 * @author Zi Zhang, Traction on Demand
 * @date   2016-03-08
 */
@isTest
public class AccountsTest {
	
	private static Account testAccount;
	// If record type names change, modify the names below
	private static Id companyAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Contract').getRecordTypeId();
	private static Id personAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('RH End Customer').getRecordTypeId();
	private static final Id UNCLASSIFIED_RECORD_TYPE_ID = Accounts.ACCOUNT_RECORD_TYPES.get('Unclassified Business Account').getRecordTypeId();

    @testSetup
    static void setup() {
    	TestDataFactory.turnMdmFeatureFlagsOn(); 
    }
    
	public static testMethod void testCompanyAccountTrigger() {
		User u = TestDataFactory.createUser();
        u.Single_View_of_Customer_Process_User__c = false;

        System.runAs(u) {
			System.assertEquals(true, String.isNotEmpty(companyAccountRecTypeId), 'Company Account Record Type not found.');
			createCompanyAccountFieldMappingSettings();

			// Insert new company account
			testAccount = new Account(Name = 'Test Company Account', RecordTypeId = companyAccountRecTypeId);
			insert testAccount;

			System.assertNotEquals(null, testAccount.Id, 'Error inserting account.');

			List<Source_System_View__c> resultSSVs = [SELECT Id, Name, Account__c, Company_Name__c FROM Source_System_View__c];

			System.assertEquals(1, resultSSVs.size(), 'SSV record does not exist.');
			System.assertEquals('SFDC-' + testAccount.Id, resultSSVs[0].Name, 'Name field not mapped.');
			System.assertEquals(testAccount.Id, resultSSVs[0].Account__c, 'Account__c field not mapped.');
			System.assertEquals(testAccount.Name, resultSSVs[0].Company_Name__c, 'Company_Name__c field not mapped.');

			// Update key fields on company account
			testAccount.Name = 'Test Company Account modified';
			update testAccount;

			resultSSVs = [SELECT Id, Name, Account__c, Company_Name__c FROM Source_System_View__c];

			System.assertEquals(1, resultSSVs.size(), 'SSV record does not exist.');
			System.assertEquals(testAccount.Name, resultSSVs[0].Company_Name__c, 'Company_Name__c field not mapped.');

			delete testAccount;

			resultSSVs = [SELECT Id, Name, Account__c, Company_Name__c FROM Source_System_View__c];

			System.assertEquals(0, resultSSVs.size(), 'SSV record was not deleted.');
		}
	}

	public static testMethod void testPersonAccountTrigger() {
		User u = TestDataFactory.createUser();
        u.Single_View_of_Customer_Process_User__c = false;

        System.runAs(u) {
			System.assertEquals(true, String.isNotEmpty(personAccountRecTypeId), 'Person Account Record Type not found.');
			createPersonAccountFieldMappingSettings();

			// Insert new company account
			testAccount = new Account(RecordTypeId = personAccountRecTypeId,
									  FirstName='Test FName',
									  LastName='Test LName',
									  PersonMailingStreet='123 Fake St.',
									  PersonMailingPostalCode='12345',
									  PersonMailingCity='Burnaby',
									  PersonEmail='test@tractionondemand.com');
			insert testAccount;

			List<Account> personAccount = [SELECT Id, PersonContactId FROM Account WHERE Id = :testAccount.Id];
			System.assertEquals(1, personAccount.size(), 'Person Account was not created.');
			System.assertNotEquals(null, testAccount.Id, 'Error inserting account.');

			List<Source_System_View__c> resultSSVs = [
				SELECT 
					Id,
					Name,
					Duplicate_Set_ID__c,
					Is_Ready_For_Duplicate_Check__c,
					Processing_Status__c,
					Processing_Ready_Time__c,
					EXT_Source_System_Customer_ID__c,
					Source_System_View_CW_Company__c,
					Account__c,
					Contact__c,
					Customer_Address__c,
					Company_Name__c,
					First_Name__c,
					Last_Name__c,
					Email__c,
					Day_Phone__c,
					Alternative_Phone__c,
					Address_1__c,
					Address_2__c,
					City__c,
					State__c,
					Zip__c,
					Country__c,
					Country_Code__c,
					Cleansed_First_Name__c,
					Cleansed_Last_Name__c,
					Cleansed_Company_Name__c,
					Email_Match_Key__c,
					Day_Phone_Match_Key__c,
					Address_Match_Key__c,
					Address_Match_Key_Hash__c,
					Match_Type__c,
					Master_Record_Score__c,
					Trade_ID__c,
					Membership_Number__c,
					Source_System_View_CW_Company__r.Duplicate_Set_ID__c,
					Source_System_View_CW_Company__r.Account__c
				FROM Source_System_View__c
			];														
			List<Contact> resultContacts = [SELECT Id, FirstName, LastName FROM Contact];

			System.assertEquals(1, resultSSVs.size(), 'SSV record does not exist.');
			System.assertNotEquals(null, resultSSVs[0].Account__c, 'Spawned SSV is not linked to the source account.');
			System.assertNotEquals(null, resultSSVs[0].Contact__c, 'Spawned SSV is not linked to the source contact.');
			
			System.assertEquals(1, resultContacts.size(), 'Contact record does not exist.');
			
			System.assertEquals('SFDC PA-' + testAccount.Id, resultSSVs[0].Name, 'Name field not mapped.');
			System.assertEquals(testAccount.Id, resultSSVs[0].Account__c, 'Account__c field not mapped.');
			System.assertEquals(personAccount[0].PersonContactId, resultContacts[0].Id, 'Contact__c field not mapped.');
			System.assertEquals(testAccount.Name, resultSSVs[0].Company_Name__c, 'Company_Name__c field not mapped.');
			System.assertEquals(resultContacts[0].FirstName, resultSSVs[0].First_Name__c, 'First_Name__c field not mapped.');
			System.assertEquals(resultContacts[0].LastName, resultSSVs[0].Last_Name__c, 'Last_Name__c field not mapped.');
			
			
			
			
			
			// run the consolidate / spawnx
			new SSVCreator(resultSSVs).syncToCustomers().spawnData();
			
			// ensure no duplicate account or contact is created
			List<Contact> newContactList = [SELECT Id, FirstName, LastName FROM Contact];
			// System.assertEquals(1, newContactList.size(), 'Additional Contact record created.');
			
			// ensure the customer address related to existing contact was created
			List<Customer_Address__c> newCustomerAddressList = [SELECT Id, Address__c, Contact__c FROM Customer_Address__c WHERE Contact__c IN :resultContacts];
						
			System.assertEquals(1, newCustomerAddressList.size(), 'Customer Address not created.');
			System.assertNotEquals(null, newCustomerAddressList[0].Address__c, 'Address was not created for contact.');
			
			
			
			

			// Update key fields on company account
			testAccount.FirstName = 'Test FName updated';
			update testAccount;

			resultSSVs = [SELECT Id, Name, Account__c, Company_Name__c, Contact__c, First_Name__c, Last_Name__c 
														FROM Source_System_View__c];

			System.assertEquals(1, resultSSVs.size(), 'SSV record does not exist.');
			System.assertEquals(testAccount.FirstName, resultSSVs[0].First_Name__c, 'Company_Name__c field not mapped.');

			delete testAccount;

			resultSSVs = [SELECT Id, Name, Account__c, Company_Name__c, Contact__c, First_Name__c, Last_Name__c 
														FROM Source_System_View__c];

			System.assertEquals(0, resultSSVs.size(), 'SSV record was not deleted.');
		}
	}

	// Test setting membership numbers on insert
	private static testmethod void test_setMembership_insert() {
		Account a = TestDataFactory.createAccount(false);
		a.RecordTypeId = Accounts.CONTRACT_RECORD_TYPE_ID;
		insert a;

		Account a2 = TestDataFactory.createAccount(false);
		a2.RecordTypeId = Accounts.CONTRACT_RECORD_TYPE_ID;
		insert a2;

		Map<Id, Account> accs = new Map<Id, Account> ([SELECT X12_Digit_Member__c FROM Account WHERE Id = :a.Id OR Id = :a2.Id]);
		a = accs.get(a.Id);
		a2 = accs.get(a2.Id);

		System.assertNotEquals(null, a.X12_Digit_Member__c);
		System.assertNotEquals(null, a2.X12_Digit_Member__c);
		System.assert(a2.X12_Digit_Member__c > a.X12_Digit_Member__c);
	}

	// Test setting membership numbers on update
	private static testmethod void test_setMembership_update() {
		Account a = TestDataFactory.createAccount(false);
		a.RecordTypeId = UNCLASSIFIED_RECORD_TYPE_ID;
		insert a;
		a.RecordTypeId = Accounts.CONTRACT_RECORD_TYPE_ID;
		update a;

		Account a2 = TestDataFactory.createAccount(false);
		a2.RecordTypeId = UNCLASSIFIED_RECORD_TYPE_ID;
		insert a2;
		a2.RecordTypeId = Accounts.CONTRACT_RECORD_TYPE_ID;
		update a2;

		Map<Id, Account> accs = new Map<Id, Account> ([SELECT X12_Digit_Member__c FROM Account WHERE Id = :a.Id OR Id = :a2.Id]);
		a = accs.get(a.Id);
		a2 = accs.get(a2.Id);

		System.assertNotEquals(null, a.X12_Digit_Member__c);
		System.assertNotEquals(null, a2.X12_Digit_Member__c);
		System.assert(a2.X12_Digit_Member__c > a.X12_Digit_Member__c);
	}

	/*********************** Test data custom settings field mapping ****************************/
	private static void createCompanyAccountFieldMappingSettings() {
		List<Company_Account_SSV_Field_Mapping__c> settings = new List<Company_Account_SSV_Field_Mapping__c>();
		settings.add(new Company_Account_SSV_Field_Mapping__c(Name = 'FM1', Source_Field__c = 'ID', Target_Field__c = 'Name'));
		settings.add(new Company_Account_SSV_Field_Mapping__c(Name = 'FM2', Source_Field__c = 'ID', Target_Field__c = 'Account__c'));
		settings.add(new Company_Account_SSV_Field_Mapping__c(Name = 'FM3', Source_Field__c = 'Name', Target_Field__c = 'Company_Name__c'));

		insert settings;
	} 

	private static void createPersonAccountFieldMappingSettings() {
		List<Person_Account_SSV_Field_Mapping__c> settings = new List<Person_Account_SSV_Field_Mapping__c>();
		settings.add(new Person_Account_SSV_Field_Mapping__c(Name = 'FM1', Source_Field__c = 'ID', Target_Field__c = 'Name'));
		settings.add(new Person_Account_SSV_Field_Mapping__c(Name = 'FM2', Source_Field__c = 'ID', Target_Field__c = 'Account__c'));
		settings.add(new Person_Account_SSV_Field_Mapping__c(Name = 'FM3', Source_Field__c = 'PersonContactID', Target_Field__c = 'Contact__c'));
		settings.add(new Person_Account_SSV_Field_Mapping__c(Name = 'FM4', Source_Field__c = 'FirstName', Target_Field__c = 'First_Name__c'));
		settings.add(new Person_Account_SSV_Field_Mapping__c(Name = 'FM5', Source_Field__c = 'LastName', Target_Field__c = 'Last_Name__c'));
		
		settings.add(new Person_Account_SSV_Field_Mapping__c(Name = 'FM6', Source_Field__c = 'PersonMailingCountry', Target_Field__c = 'Country__c'));
		settings.add(new Person_Account_SSV_Field_Mapping__c(Name = 'FM7', Source_Field__c = 'PersonMailingState', Target_Field__c = 'State__c'));
		settings.add(new Person_Account_SSV_Field_Mapping__c(Name = 'FM8', Source_Field__c = 'Phone', Target_Field__c = 'Day_Phone__c'));
		settings.add(new Person_Account_SSV_Field_Mapping__c(Name = 'FM9', Source_Field__c = 'PersonMailingCity', Target_Field__c = 'City__c'));
		settings.add(new Person_Account_SSV_Field_Mapping__c(Name = 'FM10', Source_Field__c = 'PersonEmail', Target_Field__c = 'Email__c'));
		settings.add(new Person_Account_SSV_Field_Mapping__c(Name = 'FM11', Source_Field__c = 'PersonMailingPostalCode', Target_Field__c = 'Zip__c'));
		settings.add(new Person_Account_SSV_Field_Mapping__c(Name = 'FM12', Source_Field__c = 'Mailing_Country_Code__pc', Target_Field__c = 'Country_Code__c'));
		settings.add(new Person_Account_SSV_Field_Mapping__c(Name = 'FM13', Source_Field__c = 'ID', Target_Field__c = 'EXT_Source_System_Customer_ID__c'));
		

		insert settings;
	} 
}