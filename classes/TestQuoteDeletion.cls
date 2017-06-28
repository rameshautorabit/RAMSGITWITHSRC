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
public class TestQuoteDeletion {
  
	public static testMethod void testDeleteQuote()
	{
        // Declare Local Variables       
        Set<Id>        quoteIds = new Set<Id>(); // A Set of the Quote Ids
        List<Opportunity>  opportunities = new List<Opportunity>(); // A List of Opportunities to be updated
        
        // Create an Account
        Account a = PrepareData.createAccount();
        insert a;
        
        // Create a Contact
        Contact c = PrepareData.createContact(a.Id);
        insert c;
        
        // Create an Opportunity for a Synced Quote an another with no synced quotes
        Opportunity o1 = PrepareData.createOpportunity(a.Id);
        insert o1;
       
        // Create two Quotes for the first Opportunity and one for the second
        Quote q1 = PrepareData.createQuote(UserInfo.getUserId(), c.Id, o1.Id, UserInfo.getUserId(), 'Standard');
        q1.Status = 'Not Presented';
        insert q1;
        Quote q2 = PrepareData.createQuote(UserInfo.getUserId(), c.Id, o1.Id, UserInfo.getUserId(), 'Standard');
        q2.Status = 'Not Presented';
        insert q2;
       
        // Add the Quote IDs to the array
        quoteIds.add(q1.Id);
        quoteIds.add(q2.Id);
       
        // Start Syncing the Quote
        o1.SyncedQuoteId = q1.Id;
        update o1;
        
        // Change the Status on the Opportunities
        o1.StageName = 'Closed Won'; 
        o1.Final_Invoice_Amount__c = 1000;
        o1.Order_Number__c = '123456';
        o1.Amount = 100;
        opportunities.add(o1);        
        update opportunities;
                       
        //try delete quote
        Test.startTest();  // Start Executing the test
        
        try{            
        	delete q1;            
        }
        catch(Exception e)
        {     
            system.debug('should not delete id='+ q1.id);
            quote[] q1Results = [SELECT id from quote where id = :q1.id];
            System.assertNotEquals(0, q1Results.size());

            Boolean expectedExceptionThrown =  e.getMessage().contains('Quotes for which payment has been made cannot be deleted.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);            
        }
        
        
        // Change the Status on the Opportunities
        o1.StageName = 'Project Inquiry';             
        update opportunities;
        
        //try delete quote        
        try{
        	delete q1;
        }
        catch(Exception e)
        {
             system.debug('e.getmessage='+ e.getMessage());
        }
              
        quote[] q1Results = [SELECT id from quote where id = :q1.id];
        quote_clone__c[] qcResults = [SELECT id from quote_clone__c where Source_Record_ID__c = :q1.id];
        
        System.assertEquals(0, q1Results.size());
        System.assertEquals(0, qcResults.size());
        
        Test.stopTest();  // Stops the test execution 
    }
    
    public static testMethod void testDeleteQuoteClone()
	{
          // Declare Local Variables       
        Set<Id>        quoteIds = new Set<Id>(); // A Set of the Quote Ids
        Set<Id>        quoteCloneIds = new Set<Id>(); // A Set of the Quote Clone Ids
        List<Opportunity>  opportunities = new List<Opportunity>(); // A List of Opportunities to be updated
        
        // Create an Account
        Account a = PrepareData.createAccount();
        insert a;
        
        // Create a Contact
        Contact c = PrepareData.createContact(a.Id);
        insert c;
        
        // Create an Opportunity for a Synced Quote an another with no synced quotes
        Opportunity o1 = PrepareData.createOpportunity(a.Id);
        insert o1;
       
        // Create two Quotes for the first Opportunity and one for the second
        Quote q1 = PrepareData.createQuote(UserInfo.getUserId(), c.Id, o1.Id, UserInfo.getUserId(), 'Standard');
        q1.Status = 'Not Presented';
        insert q1;
       
        // Add the Quote IDs to the array
        quoteIds.add(q1.Id);
       
        // Start Syncing the Quote
        o1.SyncedQuoteId = q1.Id;
        update o1;
        
        quote_clone__c qc1 = [SELECT id from quote_clone__c where Source_Record_ID__c = :q1.Id ];
        quoteCloneIds.add(qc1.Id);
        
        // Change the Status on the Opportunities
        o1.StageName = 'Closed Won'; 
        o1.Amount = 100;       
        update opportunities;
                       
        //try delete quote
        Test.startTest();  // Start Executing the test
        
        try{            
        	delete qc1;            
        }
        catch(Exception e)
        {     
            system.debug('should not delete id='+ qc1.id);
            quote[] q1Results = [SELECT id from quote where id = :qc1.id];
            System.assertNotEquals(0, q1Results.size());

            Boolean expectedExceptionThrown =  e.getMessage().contains('Quotes for which payment has been made cannot be deleted.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);            
        }
        
         // Change the Status on the Opportunities
        o1.StageName = 'Project Inquiry';                       
        update opportunities;
        
        //try delete quote 
         try{
        	delete q1;
        }
        catch(Exception e)
        {
             system.debug('e.getmessage='+ e.getMessage());
        }
              
        quote[] q1Results = [SELECT id from quote where id = :q1.id];
        quote_clone__c[] qcResults = [SELECT id from quote_clone__c where id = :qc1.id];
        
        System.assertEquals(0, q1Results.size());
        System.assertEquals(0, qcResults.size());
                           
        Test.stopTest();  // Stops the test execution 
        
    } 
}