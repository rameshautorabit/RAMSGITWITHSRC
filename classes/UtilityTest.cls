@isTest
public with sharing class UtilityTest {
	
	static testMethod void test_stripAccents() {
		
		// GIVEN (null string)
		
		String nullString = null;
		
		// WHEN (strip accents)
		
		String responseFromNull = Utility.stripAccents(nullString);
		
		// THEN (returns null - no exception thrown)
		
		system.assertEquals(null, responseFromNull);
		
		// GIVEN (string with accents)
		
		String stringWithAccents = 'éric';
		
		// WHEN (strip accents)
		
		String responseFromAccents = Utility.stripAccents(stringWithAccents);
		
		// THEN (returns the character without accents)
		
		system.assertEquals('eric', responseFromAccents);		
	}

    static testMethod void test_compileUpdates() {

    	// GIVEN (account created)

    	String testCompanyName = 'test company name';
    	String testTradeId = '123456789123';

    	Account testAccount = new Account(
    		Name = testCompanyName,
    		X12_Digit_Member__c = testTradeId,
    		BillingStreet = '1 Street',
    		ShippingStreet = '1 Avenue'
    	);
    	database.insert(testAccount);

    	// GIVEN - retreve account

    	List<Account> accountList = [ SELECT Name, X12_Digit_Member__c, BillingStreet, ShippingStreet FROM Account];

    	// GIVEN - Change original test Account, add it to account list

    	testAccount.Phone = '1231231234';
    	accountList.add(testAccount);

    	// WHEN - consolidated

    	List<SObject> consolidated = Utility.compileUpdates((List<SObject>)accountList);

    	// THEN - consolidated list should have only 1 record (not two)

    	system.assertEquals(2, accountList.size());
    	system.assertEquals(1, consolidated.size());

    	Account consolidatedAccount = (Account)consolidated.get(0);

    	system.assertEquals('1231231234', consolidatedAccount.Phone);
    	system.assertEquals('1 Street', consolidatedAccount.BillingStreet);
    	system.assertEquals('1 Avenue', consolidatedAccount.ShippingStreet);
    	system.assertEquals(testTradeId, consolidatedAccount.X12_Digit_Member__c);
    	system.assertEquals(testCompanyName, consolidatedAccount.Name);

    }

    public static testMethod void testLog() {

    	// given
    	Account[] testAccounts = new List<Account>();
    	testAccounts.add(new Account());

    	// when
    	Utility.logInsert(testAccounts);

    	// then
    	system.assertEquals(1, [SELECT ID FROM Error_Log__c].size());

    	// given
    	testAccounts[0].Name = 'valid-test-name';

    	// when
    	Utility.logInsert(testAccounts);

    	// then
    	system.assertEquals(1, [SELECT ID FROM Error_Log__c].size());

    	// given
    	testAccounts[0].Name = null; // remove valid name

    	// when
    	Utility.logUpdate(testAccounts);

    	// then
    	Error_Log__c[] logs = [
    		SELECT ID, Type__c, Message__c, Status_Code__c, Affected_Fields__c, Target_Object_Name__c, Target_Object__c
    		FROM Error_Log__c
    		WHERE Target_Object__c = :testAccounts.get(0).Id
    	];
    	system.debug('logs: ' + logs);

    	system.assertEquals(1, logs.size());
    }
}