@isTest
private class CWCallout_Test {

    @isTest
    static void queryCWInvoiceService(){
        // tell the Testing framework to use the mockHttpResponseGenerator 
        // for all Http Callouts in this test  
        Test.setMock(HttpCalloutMock.class, new MockInvoiceHttpResponseGenerator());
        Test.startTest();
        List<CWInvoice> invoices = CWCalloutService.retrieveInvoiceData('331971');
        Test.stopTest();       
   }
   
   @isTest
   static void queryCWOrderLineHistoryService(){
       // tell the Testing framework to use the mockHttpResponseGenerator 
      // for all Http Callouts in this test  
       Test.setMock(HttpCalloutMock.class, new MockOLHHttpResponseGenerator());
      Test.startTest();
      List<CWOrderLineHistory> histories = CWCalloutService.retrieveOrderLineHistoryData('353868', '1', '1');
      Test.stopTest(); 
   }
   
   @isTest
   static void queryOrderRHOMNotesService(){
       // tell the Testing framework to use the mockHttpResponseGenerator 
      // for all Http Callouts in this test  
       Test.setMock(HttpCalloutMock.class, new MockORNHttpResponseGenerator());
      Test.startTest();
      List<OrderRHOMNote> notes = CWCalloutService.retrieveOrderRHOMNoteData('353868');
      Test.stopTest(); 
   }
   
   @isTest
   static void queryCWOrderLinePersonalizationService(){
      // tell the Testing framework to use the mockHttpResponseGenerator 
      // for all Http Callouts in this test  
      Test.setMock(HttpCalloutMock.class, new MockOLPHttpResponseGenerator());
      Test.startTest();
      List<CWOrderLinePersonalization> personalizations = CWCalloutService.retrieveOrderLinePersonalizationData('353868', '1', '1');
      Test.stopTest(); 
   }
   
}