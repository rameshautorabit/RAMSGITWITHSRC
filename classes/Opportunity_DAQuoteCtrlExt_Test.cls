/*Test class for controller*/

@isTest(SeeAllData = true)
	
public with sharing class Opportunity_DAQuoteCtrlExt_Test  {

	static testMethod void Opportunity_DAQuoteCtrlExt_UnitTest() {
  		
  		Account testDAAccount = new Account();
	 	Contact testDAContact = new Contact();
	 	Opportunity testDAOppty = new Opportunity();
	 	Opportunity testDAOppty2 = new Opportunity();
  		
  		testDAAccount = PrepareData.createAccount();
	 	insert testDAAccount;
	 	testDAContact = PrepareData.createContact(testDAAccount.Id);
	 	insert testDAContact;
	 	testDAOppty = PrepareData.createOpportunity(testDAAccount.Id);
	 	insert testDAOppty;
	 	testDAOppty2 = PrepareData.createOpportunity(testDAAccount.Id);
	 	insert testDAOppty2;
  		
  		//Create a new instance of standard controller
 		ApexPages.StandardController sc = new ApexPages.standardController(testDAOppty);
 		Opportunity_DAQuoteCtrlExt controller = new Opportunity_DAQuoteCtrlExt(sc);
 		
 		Design_Atelier_Quote__c daq = new Design_Atelier_Quote__c();
 		Design_Atelier_Quote__c daq2 = new Design_Atelier_Quote__c();
 		
 		List<Opportunity_DAQuoteCtrlExt.DesignAtelierQuoteWrapper> testdaQuoteWrapperList = new List<Opportunity_DAQuoteCtrlExt.DesignAtelierQuoteWrapper>();
	  	
	  	daq.name='DATestQuoteName';
	  	daq.Quote_Id__c = 'DATestQuoteId';
	  	daq.Forecast__c = TRUE;
	  	daq.Order_Subtotal__c = 123.00;
	  	daq.EXT_Oppty_Quote_Number__c = 'DATestEXTOpptyQuoteNumber';
	  	daq.DA_Opportunity__c = testDAOppty.Id;
	  	daq.DA_Opportunity_Number__c = 'DATestOpptyNumber';
	  	
	  	insert daq;
	  	
	  	daq2.name='DATestQuoteName';
	  	daq2.Quote_Id__c = 'DATestQuoteId';
	  	daq2.Forecast__c = TRUE;
	  	daq2.Order_Subtotal__c = 123.00;
	  	daq2.EXT_Oppty_Quote_Number__c = 'DATestEXTOpptyQuoteNumber';
	  	daq2.DA_Opportunity__c = testDAOppty2.Id;
	  	daq2.DA_Opportunity_Number__c = 'DATestOpptyNumber';
	
		insert daq2;
		
	  	test.startTest();
	  	testdaQuoteWrapperList = controller.daQuoteWrapperList;
	  	test.stopTest();	
    } 
}