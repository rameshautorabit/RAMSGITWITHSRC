/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=true)
private class TestSetQuoteStatusFromOpportunity {

    static testMethod void testSetQuoteStatusFromOpportunity() {
        
        // Declare Local Variables
        List<Opportunity>	opportunities = new List<Opportunity>(); // A List of Opportunities to be updated
        Set<Id>				quoteIds = new Set<Id>(); // A Set of the Quote Ids
        Map<Id, Quote>		quoteMap; // A Map of Quotes to be evaluated after processing
        String				status; // The status to set the Quotes
		
		// Get the Quote status from the Custom Setting
		status = Application_Settings__c.getInstance('QuoteCloneStatusToCreatePortalUser').Value_Text__c;
		
		// Create an Account
		Account a = PrepareData.createAccount();
		insert a;
		
		// Create a Contact
		Contact c = PrepareData.createContact(a.Id);
		insert c;
		
		// Create an Opportunity for a Synced Quote an another with no synced quotes
		Opportunity o1 = PrepareData.createOpportunity(a.Id);
		insert o1;
		Opportunity o2 = PrepareData.createOpportunity(a.Id);
		insert o2;
		
		// Create two Quotes for the first Opportunity and one for the second
		Quote q1 = PrepareData.createQuote(UserInfo.getUserId(), c.Id, o1.Id, UserInfo.getUserId(), 'Standard');
		q1.Status = 'Not Presented';
		insert q1;
		Quote q2 = PrepareData.createQuote(UserInfo.getUserId(), c.Id, o1.Id, UserInfo.getUserId(), 'Standard');
		q2.Status = 'Not Presented';
		insert q2;
		Quote q3 = PrepareData.createQuote(UserInfo.getUserId(), c.Id, o2.Id, UserInfo.getUserId(), 'Standard');
		q3.Status = 'Not Presented';
		insert q3;
		
		// Add the Quote IDs to the array
		quoteIds.add(q1.Id);
		quoteIds.add(q2.Id);
		quoteIds.add(q3.Id);
		
		// Start Syncing the Quote
		o1.SyncedQuoteId = q1.Id;
		update o1;
		
		// Change the Status on the Opportunities
		o1.StageName = status;
		o2.StageName = status;
		opportunities.add(o1);
		opportunities.add(o2);
		update opportunities;
		
		// Assert that the Quote Statuses were accurately changed
		quoteMap = new Map<Id, Quote>([SELECT Id, Status FROM Quote WHERE Id IN :quoteIds]);
		System.assertEquals(status, quoteMap.get(q1.Id).Status);
		System.assertEquals('Not Presented', quoteMap.get(q2.Id).Status);
		System.assertEquals('Not Presented', quoteMap.get(q3.Id).Status);
    }
}