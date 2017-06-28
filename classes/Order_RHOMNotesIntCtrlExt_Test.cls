/*Test class for controller*/

@isTest
public with sharing class Order_RHOMNotesIntCtrlExt_Test {
	
	static testMethod void Order_RHOMNotesIntCtrlExt_UnitTest() {
  		
  		PrepareData.populateCustomSettings();
  		
  		//Create a new instance of RH Order
 		RH_Order__c rh=new RH_Order__c();
 		List<OrderRHOMNote> testOrderRHOMNotesList = new List<OrderRHOMNote>();
		
  		rh.name='test';
		
  		insert rh;
  		
  		//Create a new instance of standard controller
  		test.startTest();
  		ApexPages.StandardController sc = new ApexPages.standardController(rh);
  		Order_RHOMNotesIntCtrlExt controller = new Order_RHOMNotesIntCtrlExt(sc);
  		testOrderRHOMNotesList = controller.getOrderRHOMNoteList();
  		test.stopTest();
    }  
}