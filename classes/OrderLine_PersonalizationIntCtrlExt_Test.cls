/*Test class for controller*/

@isTest(SeeAllData=true)

public with sharing class OrderLine_PersonalizationIntCtrlExt_Test {
	
	static testMethod void OrderLine_PersonalizationIntCtrlExt_Test() {
  	// Create a new instance of RH Order
 	RH_Order__c rho = PrepareData.createOrder('olpT01');
 	insert rho;
 	Ship_To__c st = PrepareData.createShipTo(rho.id, '1');
 	insert st;
 	
 	List<Product2> prod = new List<Product2>();
 	prod.add([Select Id, Name from Product2 where Name like '%SAND' limit 1]);
 	
 	System.debug('Product Id: ' + prod);
 	
 	Order_Line_Items__c olp = PrepareData.createOrderLine(rho.Id, st.Id, '1', prod[0].Id);
 	insert olp;	
 	
 	List<CWOrderLinePersonalization> testOrderLinePersonalizationList = new List<CWOrderLinePersonalization>();
  	
  	// Test.setMock(HttpCalloutMock.class, new MockOLPHttpResponseGenerator());
  	
  	// Create a new instance of standard controller
  	test.startTest();
  	ApexPages.StandardController sc = new ApexPages.standardController(olp);
  	OrderLine_PersonalizationIntCtrlExt controller = new OrderLine_PersonalizationIntCtrlExt(sc);
  	testOrderLinePersonalizationList = controller.getOrderLinePersonalizationList();
  	test.stopTest();
    }  
}