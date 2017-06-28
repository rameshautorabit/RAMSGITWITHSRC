/*Test class for controller*/

@isTest(SeeAllData=true)

public with sharing class OrderLine_HistoryIntCtrlExt_Test {
	
	static testMethod void OrderLine_HistoryIntCtrlExt_UnitTest() {
  	//Create a new instance of RH Order
 	RH_Order__c rho = PrepareData.createOrder('olhT01');
 	insert rho;
 	Ship_To__c st = PrepareData.createShipTo(rho.id, '1');
 	insert st;
 	
 	List<Product2> prod = new List<Product2>();
 	prod.add([Select Id, Name from Product2 where Name like '%SAND' limit 1]);
 	
 	System.debug('Product Id: ' + prod);
 	
 	Order_Line_Items__c olh = PrepareData.createOrderLine(rho.Id, st.Id, '1', prod[0].Id);
 	insert olh;	
 	
 	List<CWOrderLineHistory> testOrderLineHistoryList = new List<CWOrderLineHistory>();
  	
  	//Create a new instance of standard controller
  	test.startTest();
  	ApexPages.StandardController sc = new ApexPages.standardController(olh);
  	OrderLine_HistoryIntCtrlExt controller = new OrderLine_HistoryIntCtrlExt(sc);
  	testOrderLineHistoryList = controller.getOrderLineHistoryList();
  	test.stopTest();
    }  
}