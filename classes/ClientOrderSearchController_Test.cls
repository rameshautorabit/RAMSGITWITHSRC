@isTest
public with sharing class ClientOrderSearchController_Test{
 
    static testMethod void ClientOrderSearchController_UnitTest() {       
        List<Sales_Attribution__c> saList = new List<Sales_Attribution__c>();

        // Create test Order and insert
        RH_Order__c testOrder = PrepareData.createOrder('741741741');
        insert testOrder;
        
        System.debug('Test Order: ' + testOrder);
      
        // Create custom setting and insert
        insert new Application_Settings__c(Name='CCD System Hold Codes', Value_Text__c='AT,AU,AV,AW,UT,UU,UV,UW');
        
        // Create test Ship To and insert
        Ship_To__c testShipTo = PrepareData.createShipTo(testOrder.Id, '2');
        
        System.debug('Test Ship To: ' + testShipTo);
   
        insert testShipTo;
        
        // Create test Product and insert
        PrepareData.productClass testPC = PrepareData.createProduct('TESTPRODUCT', 100, 'TestProd', 200);
        Product2 testProduct = testPC.p;
        testProduct.Ecommerce_Display_Name__c = 'Nibbler';
        
        // Create test Order Lines and insert
        Order_Line_Items__c testOrderLine = PrepareData.createOrderLine(testOrder.Id, testShipTo.Id, '1', testProduct.Id);
        
        // Create a new instance of standard controller
        Test.StartTest();
        
        PageReference cosPageRef = Page.ClientOrderSearch;
        
        cosPageRef.getParameters().put('fullname',testOrder.Sold_to_Last_Name__c + ', ' + testOrder.Sold_to_First_Name__c);
        cosPageRef.getParameters().put('cwskuid',testProduct.Name);
        cosPageRef.getParameters().put('ecommdisplayname',testProduct.Ecommerce_Display_Name__c);
        
        Test.setCurrentPage(cosPageRef);
      
        ClientOrderSearchController controller = new ClientOrderSearchController();
       
        // Prep SOSL test data
       	Id [] fixedSearchResults= new Id[1];
       	fixedSearchResults[0] = testOrder.Id;
       	Test.setFixedSearchResults(fixedSearchResults);
     
        controller.runSearch();
        
        cosPageRef.getParameters().put('fullname',testOrder.Sold_to_Last_Name__c + ' ' + testOrder.Sold_to_First_Name__c);
        
        controller.runSearch();
        
        cosPageRef.getParameters().put('fullname', 'Nibbles, Nibbler');
        
        controller.runSearch();
       
        Test.StopTest();
    }  
}