@isTest
private class testAttachment_System {
	
	/*
	 *	Methods to test Attachment_System.trigger
	 *
	 */
	
    // Set up data for the test
	@testSetup static void testData() {
		
        PrepareData.populateCustomSettings();
        
        RH_Order__c order = new RH_Order__c(Name = 'OATT123');
        insert order;
	}
    
    static testMethod void attSysTest1() {
		
		RH_Order__c order = new RH_Order__c();
		order = [select Id from RH_Order__c where Name = 'OATT123'];
		
		Attachment att = new Attachment(
			Name = 'Test Attachment',
			Description = 'Test Description',
			ContentType = 'Text',
			Body = Blob.valueof('This is the body of the attachment'),
			ParentId = order.Id
		);
		insert att;
		
		att.Description = 'System Generated Attachment and other stuff';
		update att;
		att.Name = 'Test2 Attachment';
		update att;
		delete att;
    }
}