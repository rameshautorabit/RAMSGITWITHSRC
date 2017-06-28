/*Test class for controller*/

@isTest
public with sharing class Order_NotesIntCtrlExt_Test {
	
	static testMethod void Order_NotesIntCtrlExt_UnitTest() {
  		
  		PrepareData.populateCustomSettings();
  		
  		//Create a new instance of RH Order
 		RH_Order__c rh=new RH_Order__c();
 		List<CW_Order_Note__x> testOrderNotesList = new List<CW_Order_Note__x>();
		
  		rh.name='test';
		
  		insert rh;
  		
  		//Create a new instance of standard controller
  		test.startTest();
  		ApexPages.StandardController sc = new ApexPages.standardController(rh);
  		Order_NotesIntCtrlExt controller = new Order_NotesIntCtrlExt(sc);
  		testOrderNotesList = controller.getOrderNotesList();
  		test.stopTest();
    }  
}