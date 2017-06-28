@isTest
public with sharing class Order_SalesAttributionIntCtrlExt_Test {
 
    static testMethod void Order_SalesAttributionIntCtrlExt_UnitTest() {       
        List<Sales_Attribution__c> saList = new List<Sales_Attribution__c>();

        // Create test Order and insert
        RH_Order__c testOrder = PrepareData.createOrder('741741741');
        insert testOrder;
        
        // Create test Sales Attribution and insert
        List<Sales_Attribution__c> testSAList = new List<Sales_Attribution__c>();
        
        insert new Application_Settings__c(Name='CCD System Hold Codes', Value_Text__c='AT,AU,AV,AW,UT,UU,UV,UW');
        
        Sales_Attribution__c testSA1 = new Sales_Attribution__c(Order__c = testOrder.Id, Attribution_ID__c = 'wsxnji', Associate_Name__c = userInfo.getUserId(), Primary_Associate__c = true, Attribution_Percent__c = 100.00); 
        Sales_Attribution__c testSA2 = new Sales_Attribution__c(Order__c = testOrder.Id, Attribution_ID__c = 'wsxnji', Associate_Name__c = userInfo.getUserId(), Primary_Associate__c = false, Attribution_Percent__c = 10.00);
        Sales_Attribution__c testSA3 = new Sales_Attribution__c(Order__c = testOrder.Id, Attribution_ID__c = 'wsxnji', Primary_Associate__c = false, Attribution_Percent__c = 1);
        Sales_Attribution__c testSA4 = new Sales_Attribution__c(Order__c = testOrder.Id, Attribution_ID__c = 'wsxnji', Associate_Name__c = userInfo.getUserId(), Primary_Associate__c = true, Attribution_Percent__c = 0);
        
        testSAList.add(testSA1);
        testSAList.add(testSA2);
        testSAList.add(testSA3);
        testSAList.add(testSA4);
        
        insert testSAList;
        
        // Create a new instance of standard controller
        Test.StartTest();
        
        PageReference saPageRef = Page.Order_SalesAttribution;
        saPageRef.getParameters().put('id',testOrder.id);
        Test.setCurrentPage(saPageRef);
      
        ApexPages.StandardController sc = new ApexPages.standardController(testOrder);
        Order_SalesAttributionIntCtrlExt controller = new Order_SalesAttributionIntCtrlExt(sc);
        
        saList = controller.getSalesAttributions();
        
        insert new FieldIdLookup__c(Name='Sales Attribution Order Number', FieldId__c='Nibbler');
        
        // Assertions
        System.assertEquals(4,saList.size());
        System.assertEquals(null,controller.edit());
        System.assertEquals(null,controller.Save());
        System.assertEquals(null,controller.edit());
        System.assertEquals(null,controller.Cancel());
        System.assertEquals(null,controller.addRow());
        System.assertEquals(null,controller.deleteRow());
        System.assertEquals('Nibbler', controller.getSalesAttributionOrderNumberFieldId());
        
        Test.StopTest();
    }  
}