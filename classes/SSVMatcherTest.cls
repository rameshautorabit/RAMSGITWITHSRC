@isTest
public with sharing class SSVMatcherTest {
    
    
	@isTest static void testMatchingCompanyRecords() {
		
		Source_System_View__c companyToMatch = new Source_System_View__c(
			Match_Type__c = 'Company',
			Duplicate_Set_ID__c = '123',
			Trade_ID__c = '123456'
		);
		
		Source_System_View__c companyMatchTrade = new Source_System_View__c(
			Match_Type__c = 'Company',
			Duplicate_Set_ID__c = '456',
			Trade_ID__c = '123456'
		);

		Source_System_View__c companyMatchDuplicateSetWrongTradeID = new Source_System_View__c(
			Match_Type__c = 'Company',
			Duplicate_Set_ID__c = '123',
			Trade_ID__c = '456789'
		);		

		Source_System_View__c companyMatchDuplicateSetRightTradeID = new Source_System_View__c(
			Match_Type__c = 'Company',
			Duplicate_Set_ID__c = '123',
			Trade_ID__c = '123456'
		);	
		
		Source_System_View__c companyNoTradeToMatch = new Source_System_View__c(
			Match_Type__c = 'Company',
			Duplicate_Set_ID__c = '123',
			Trade_ID__c = ''
		);	

		Source_System_View__c companyMatchWrongDuplicateSet = new Source_System_View__c(
			Match_Type__c = 'Company',
			Duplicate_Set_ID__c = '456',
			Trade_ID__c = ''
		);		
			
		SSVMatcher.CompanyMatcher matcher = new SSVMatcher.CompanyMatcher();
		// match on trade
		system.assertEquals(true, matcher.matches(new SSVCleansed(companyToMatch), new SSVCleansed(companyMatchTrade)));
		// do not match on trade
		system.assertEquals(false, matcher.matches(new SSVCleansed(companyToMatch), new SSVCleansed(companyMatchDuplicateSetWrongTradeID)));		
		// match as has no trade
		system.assertEquals(true, matcher.matches(new SSVCleansed(companyToMatch), new SSVCleansed(companyNoTradeToMatch)));
		// no match as neither has trade and wrong duplicates set
		system.assertEquals(false, matcher.matches(new SSVCleansed(companyNoTradeToMatch), new SSVCleansed(companyMatchWrongDuplicateSet)));
	}
	
	
}