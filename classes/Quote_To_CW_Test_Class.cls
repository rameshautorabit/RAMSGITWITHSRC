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
private class Quote_To_CW_Test_Class {


static PageReference pref;

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        // create new instance of Quote
        
        // insert account
        
         
        Account acc=new Account(Name='Test Account');
        
        insert acc;
      
         // Insert new opportunity
       
      Opportunity opp=new Opportunity (Name='Quote_To_CW',AccountId=acc.id,StageName='Closed Won',
        Final_Invoice_Amount__c=10000.00,
        Order_Number__c='1234',
        Amount=10000,
        //SyncedQuoteId=qid,
        closedate=System.Today());
        
        insert opp; 
        
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Quote' and Name ='Standard'].Id;
        
        Quote q= new Quote(Name='Test',Conversion_Status__c='Not Yet Sent',Bill_To_Company__c = 'ACME',Bill_To_Last_Name__c = 'Bunny', ShippingName = 'Bunny', BillingName = 'Bunny', opportunityId=opp.id,RecordTypeId=strRecordTypeId);
        
        insert q;
        
        string qid=q.id;
        
        opp.SyncedQuoteId=qid;
        
        update opp;
        
        system.debug('********'+qid);
        
        
        PageReference ref = new PageReference('/apex/Quote_CW_Test');
        
        // pref.getParameters().put('id',qid);
         
         Test.setCurrentPage(ref);
         
         /*Create an instance of controller*/
         

         
        ApexPages.StandardController sc = new ApexPages.standardController(q);
        
        Quote_To_CW_VFExtension QCW=new Quote_To_CW_VFExtension(sc);
        
         ref.getParameters().put('id', String.valueOf(q.Id));
         
         Test.setCurrentPage(ref);
         
         QCW.VFRedirect();
        
        // = new MyController(sc);
        
        PageReference nextpage = new PageReference('/apex/Quote_CW_Redirect');

        //Test.setCurrentPage(nextpage);
        
        System.currentPageReference().getParameters().put('quoteid', q.Id);
        
      //  nextpage.getParameters().put('quoteId', String.valueOf(q.Id));
        
        Quote_To_CW qt=new Quote_To_CW();
        
        qt.cancel();
         
         Test.setCurrentPage(ref);
         
            String testBody;testBody='This is a test';
            
            Test.startTest();
        
        Test.setMock(HTTPCalloutMock.class, new Quote_CW_Test_Hard_Coded_Response(testBody));
        
         
         qt.invokeMule();
         
         
         
         Test.stopTest();
        
        //Quote_To_CW_Test qt=new Quote_To_CW_Test(sc);
        
      //  if (test.isRunningTest()) Test.setMock(HttpCalloutMock.class, mock);
        
    //HttpResponse res = CalloutClass.getInfoFromExternalService(myCase.Id);
         
    }
    
    /*test web service callout */
      
}