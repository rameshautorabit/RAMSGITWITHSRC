/*
 *	Methods to test Order_RHMembershipCtlExt.cls
 *
 */

@isTest(SeeAllData=true)
private class testOrder_RHMembershipCtlExt {
	
	static testMethod void membershipTest1() {
		
		String orderNumber = 'mtest01';
		RH_Order__c order = PrepareData.createOrder(orderNumber);
		insert order;
		
		// Test the Order Line Delay Order Feed controller
		ApexPages.StandardController std = new ApexPages.StandardController(order);
		Order_RHMembershipCtlExt ctl = new Order_RHMembershipCtlExt(std);
		
		ctl.requestNewMembershipCard();
		system.assertEquals(false, ctl.newCardRequested);
		
		order.Membership_ID__c = 'RH-123456';
		order.Grey_Card_Opt_in__c = true;
		order.Membership_Expiration_Date__c = system.today();
		order.Membership_Expiration_Date__c = system.today().addDays(30);
		update order;
		
		ApexPages.StandardController std1 = new ApexPages.StandardController(order);
		Order_RHMembershipCtlExt ctl1 = new Order_RHMembershipCtlExt(std1);
		
		ctl1.requestNewMembershipCard();
		system.assertEquals(true, ctl1.newCardRequested);
		
		ctl1.sendMembershipWelcomeEmail();
	}
	
	static testMethod void membershipTest2() {
		String welcomeEmailOrderNumber = 'weoT1O1';
		String rhMembershipSKU = '91020001RH';
		
		RH_Order__c weOrder = PrepareData.createOrder(welcomeEmailOrderNumber);
		insert weOrder;
		
		Ship_To__c shipTo = PrepareData.createShipTo(weOrder.Id, '1');
		insert shipTo;
		
		weOrder = [select Id, Name, Membership_ID__c, Membership_Enrollment_Date__c, Membership_Expiration_Date__c, Membership_Welcome_Email_Sent__c from RH_Order__c where Id = :weOrder.Id];
		weOrder.Membership_ID__c = 'RH-1234';
		weOrder.Membership_Enrollment_Date__c = system.today();
		update weOrder;
		
		weOrder = [select Id, Name, Membership_ID__c, Membership_Enrollment_Date__c, Membership_Expiration_Date__c, Membership_Welcome_Email_Sent__c from RH_Order__c where Id = :weOrder.Id];
		system.assertEquals(system.today().addYears(1), weOrder.Membership_Expiration_Date__c);
		system.assertEquals(false, weOrder.Membership_Welcome_Email_Sent__c);
		
		// Create Membship SKU Order Line and verify membership email was created and sent (simulated)
		Id rhMembershipSKUId = [select Id, Name from Product2 where Name = :rhMembershipSKU].Id;
		shipTo = [select Id, Name, Order__c from Ship_To__c where Order__c = :weOrder.Id];
		Order_Line_Items__c oliMembership = PrepareData.createOrderLine(weOrder.Id, shipTo.Id, '001', rhMembershipSKUId);
		
		Test.startTest();
		insert oliMembership;
		Test.stopTest();
		
		weOrder = [select Id, Name, Membership_ID__c, Membership_Enrollment_Date__c, Membership_Expiration_Date__c, Membership_Welcome_Email_Sent__c from RH_Order__c where Name = :welcomeEmailOrderNumber];
		system.assertEquals(true, weOrder.Membership_Welcome_Email_Sent__c);
		
		// Now test manual send of email
		ApexPages.StandardController std = new ApexPages.StandardController(weOrder);
		Order_RHMembershipCtlExt ctl = new Order_RHMembershipCtlExt(std);
		ctl.sendMembershipWelcomeEmail();
		system.assertEquals(false, ctl.orderDataError);
		
		weOrder.Membership_ID__c = '';
		update weOrder;
		ApexPages.StandardController std1 = new ApexPages.StandardController(weOrder);
		Order_RHMembershipCtlExt ctl1 = new Order_RHMembershipCtlExt(std1);
		ctl1.sendMembershipWelcomeEmail();
		system.assertEquals(true, ctl1.orderDataError);
	}
}