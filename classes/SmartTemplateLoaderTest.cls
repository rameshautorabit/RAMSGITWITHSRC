@isTest (SeeAllData=true)

private class SmartTemplateLoaderTest {

	static testMethod void testChooseTemplate() {
		
		SmartTemplateLoader ST = new SmartTemplateLoader();
		List<Case> cList=new List<Case>();
		Map<String, RecordTypeInfo> rtByNameMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
		
		// Create a simulated case to test with
		Case c = new Case();
		c.Subject = 'I\'m having trouble with my Laptop';
        c.Status='In Progress';
        c.RecordTypeId = rtByNameMap.get('Email and Web Inquiries').getRecordTypeId();
       	cList.add(c);
       	Case c1=new Case();
        c1.Subject='This is test case';
        c1.Status='';
        c1.RecordTypeId = rtByNameMap.get('Standard').getRecordTypeId();
		cList.add(c1);
        Database.insert(cList);
        
        // ensure the proper template is chosen for this subject
        Id actualTemplateId = ST.getDefaultEmailTemplateId(c.Id);
        EmailTemplate expectedTemplate = [SELECT id FROM EmailTemplate WHERE DeveloperName = 'Email_and_Web_Reply_Inquiries'];
        Id expectedTemplateId = expectedTemplate.Id;
        System.assertEquals(actualTemplateId, expectedTemplateId);
        
        actualTemplateId = ST.getDefaultEmailTemplateId(c1.Id);
        System.assertEquals(actualTemplateId, null);
	}
}