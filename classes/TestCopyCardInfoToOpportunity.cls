/**********************************************************/
/*                                                        */
/*  This Class tests the CopyCardInfoToOpportunity        */
/*  Trigger that copies the credit card info from a       */
/*  Quote Clone object to an Opportunity.                 */
/*                                                        */
/**********************************************************/

@isTest
private class TestCopyCardInfoToOpportunity {

    static testMethod void testCopyCardInfoToOpportunity() {
        
        // Populate Custom Settings
        PrepareData.populateCustomSettings();
        
        // Create an Account
        Account a = PrepareData.createAccount();
        insert a;
        
        // Create a Contact
        Contact c = PrepareData.createContact(a.Id);
        insert c;
        
        // Create an Opportunity
        Opportunity o = PrepareData.createOpportunity(a.Id);
        insert o;
        
        // Get a User
        User u = [SELECT Id FROM User WHERE IsActive = true AND UserType = 'Standard' LIMIT 1];
        
        // Create a Quote
        Quote q = PrepareData.createQuote(u.Id, c.Id, o.Id, u.Id, 'Standard');
        insert q;
        
        // Get the Quote Clone Object that was created
        Quote_Clone__c qc = [SELECT Card_Billing_City__c, Card_Billing_Country__c, Card_Billing_Postal_Code__c,
				Card_Billing_State__c, Card_Billing_Street__c, Card_Expiration_Month__c,
				Card_Expiration_Year__c, Card_Holder_Name__c, Card_Number__c FROM Quote_Clone__c WHERE Source_Record__c = :q.Id LIMIT 1];
		
		// Update the Quote Clone Object
		qc.Card_Billing_City__c = 'Denver';
		qc.Card_Billing_Country__c = 'USA';
		qc.Card_Billing_Postal_Code__c = '80237';
		qc.Card_Billing_State__c = 'CO';
		qc.Card_Billing_Street__c = '6565 Main Street';
		qc.Card_Expiration_Month__c = '03';
		qc.Card_Expiration_Year__c = '3014';
		qc.Card_Holder_Name__c = 'Pat Anderson';
		qc.Card_Number__c = '4111111111111111';
		qc.Submitted__c = true;
		update qc;
		
		// Reselect the Opportunity fields
		Opportunity theOpportunity = [SELECT Card_Billing_City__c, Card_Billing_Country__c, 
			Card_Billing_Postal_Code__c, Card_Billing_State__c, Card_Billing_Street__c,
			Card_Expiration_Month__c, Card_Expiration_Year__c, Card_Holder_Name__c,
			Card_Number__c FROM Opportunity WHERE Id = :o.Id LIMIT 1];
		
		// Assert that the Opportunity was updated correctly
		System.assertEquals('Denver', theOpportunity.Card_Billing_City__c);
		System.assertEquals('USA', theOpportunity.Card_Billing_Country__c);
		System.assertEquals('80237', theOpportunity.Card_Billing_Postal_Code__c);
		System.assertEquals('CO', theOpportunity.Card_Billing_State__c);
		System.assertEquals('6565 Main Street', theOpportunity.Card_Billing_Street__c);
		System.assertEquals('03', theOpportunity.Card_Expiration_Month__c);
		System.assertEquals('3014', theOpportunity.Card_Expiration_Year__c);
		System.assertEquals('Pat Anderson', theOpportunity.Card_Holder_Name__c);
		System.assertEquals('4111111111111111', theOpportunity.Card_Number__c);	
    }
}