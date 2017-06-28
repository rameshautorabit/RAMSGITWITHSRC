/*Test class for controller*/

@isTest (seeAllData=true)
public with sharing class Issue_InventoryCtrlExt_Test {

	static testMethod void Issue_InventoryCtrlExt_UnitTest() {
  	
  	//Create a test Product with Inventory
 	Product2 testProduct = new Product2();
 	
 	prepareData.productClass testProductClass = prepareData.createProduct('1234NICESOFA', 333.33,'NICE SOFA', 777.77);
 	
 	testProduct = testProductClass.p;
 	testProduct.Inventory__c = '[{"skuNxtOrderDate":"2016-03-06","backOrderQty":"N/A","nextExpectedDate":"N/A","entity":"20","locationId":"89","date":"2016-03-06","skuQty":"0","availableQty":"N/A","nextExpectedQty":"N/A","reserveQty":"N/A","source":"CWDirect","allowWebOrders":"N","onHandQty":"N/A","onOrderQty":"N/A","fullSkuId":"100008ESPFULL","skuQtyOnOrder":"0"},{"skuNxtOrderDate":"2016-03-06","backOrderQty":"N/A","nextExpectedDate":"N/A","entity":"20","locationId":"95","date":"2016-03-06","skuQty":"0","availableQty":"N/A","nextExpectedQty":"N/A","reserveQty":"N/A","source":"CWDirect","allowWebOrders":"N","onHandQty":"N/A","onOrderQty":"N/A","fullSkuId":"100008ESPFULL","skuQtyOnOrder":"0"},{"skuNxtOrderDate":"2016-03-06","backOrderQty":"N/A","nextExpectedDate":"N/A","entity":"20","locationId":"96","date":"2016-03-06","skuQty":"0","availableQty":"N/A","nextExpectedQty":"N/A","reserveQty":"N/A","source":"CWDirect","allowWebOrders":"N","onHandQty":"N/A","onOrderQty":"N/A","fullSkuId":"100008ESPFULL","skuQtyOnOrder":"0"},{"skuNxtOrderDate":"2016-03-06","backOrderQty":"N/A","nextExpectedDate":"N/A","entity":"20","locationId":"97","date":"2016-03-06","skuQty":"0","availableQty":"N/A","nextExpectedQty":"N/A","reserveQty":"N/A","source":"CWDirect","allowWebOrders":"N","onHandQty":"N/A","onOrderQty":"N/A","fullSkuId":"100008ESPFULL","skuQtyOnOrder":"0"},{"skuNxtOrderDate":"2016-03-06","backOrderQty":"N/A","nextExpectedDate":"N/A","entity":"20","locationId":"98","date":"2016-03-06","skuQty":"0","availableQty":"N/A","nextExpectedQty":"N/A","reserveQty":"N/A","source":"CWDirect","allowWebOrders":"N","onHandQty":"N/A","onOrderQty":"N/A","fullSkuId":"100008ESPFULL","skuQtyOnOrder":"0"}]';
 	
 	update testProduct;
 	
 	//Create a test Issue associated with the test Product	
 	Issue__c i = new Issue__c();
 	i.CW_SKU_ID__c = testProduct.Id;	
 	
  	insert i;

  	List<InventoryInfo> testInventoryIssueList = new List<InventoryInfo>();
  	
  	//Create a new instance of standard controller
  	test.startTest();
  	ApexPages.StandardController sc = new ApexPages.standardController(i);
  	Issue_InventoryCtrlExt controller = new Issue_InventoryCtrlExt(sc);
  	testInventoryIssueList = controller.inventoryInfoList;
  	test.stopTest();
    }  
}