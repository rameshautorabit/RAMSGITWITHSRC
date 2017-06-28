/************************************************/
/*                                              */
/*  This test class is designed to provide      */
/*  coverage to the PrepareData class in        */
/*  order to enable smooth migration.           */
/*                                              */
/************************************************/

@isTest(SeeAllData=true)
private class TestPrepareData {

    static testMethod void testPrepareData() {
        
		// Test custom setting data creation in memory
		List<Application_Settings__c> appSettings = PrepareData.createApplicationSettings(); 
        List<Groups__c> grpSettings = PrepareData.createGroups();
        List<RH_Brand__c> rhbList = PrepareData.createRHBrand();
		List<CasetoOrderFieldMapping__c> ctoList = PrepareData.createCaseToOrderMappingList();
		List<CaseLineToOrderLineMapping__c> cliTOoliList = PrepareData.createCaseLineToOrderLineMappingList();
		
		// Test the getPortalProfile method
		PrepareData.getPortalProfile();
		
		// Create an Account
		Account a = PrepareData.createAccount();
		insert a;
		
		// Create a Contact
		Contact c = PrepareData.createContact(a.Id);
		insert c;
		
		// Get the Standard Pricebook
		Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE Name = 'Standard Price Book' LIMIT 1];
		
		// Create an Opportunity
		Opportunity o = PrepareData.createOpportunity(a.Id);
		o.Pricebook2Id = pb.Id;
		insert o;
		OpportunityContactRole ocr = PrepareData.createContactRole(c.Id, o.Id, 'Other');
		
		// Get a BDL User
		User bDLUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
		OpportunityTeamMember otm = PrepareData.createOpportunityTeamMember(o.Id, bDLUser.Id);
		
		// Get a Prepared By User
		User preparedByUser = [SELECT Id FROM User WHERE IsActive = true AND Id != :bDLUser.Id LIMIT 1];
		
		// Create a Quote
		Quote quote = PrepareData.createQuote(bDLUser.Id, c.Id, o.Id, preparedByUser.Id, 'Admin');
		
		// Get two Pricebook Entry Records
		List<PricebookEntry> pBEList = new List<PricebookEntry>([SELECT Id FROM PricebookEntry WHERE Pricebook2Id = :pb.Id LIMIT 2]);
		OpportunityLineItem oli = PrepareData.createOLI(10, o.Id, 1000, pBEList[0].Id, 2);
		
		// Create two Quote Line Items
		QuoteLineItem qli1 = PrepareData.createQLI(quote.Id, 1000, pBEList[0].Id, 1);
		
		// Execute the other methods of PrepareData
		PrepareData.createGenericRHData();
		Case rhCase = PrepareData.createCase('Standard');
		insert rhCase;
		Case_Line_Items__c rhCLI = PrepareData.createCaseLineItem(rhCase);
		Attachment att = PrepareData.createAttachment(rhCase.Id);
		PrepareData.productClass pc = PrepareData.createProduct('DDDD', 10, 'DDDD', 10);
		Task tsk = PrepareData.createTask(system.today(), 'Open', 'Subject', c.Id, c.Id);
		Delayed_Order_Rule__c dor = PrepareData.rcDelayedOrderRule('Standard');
		RH_Order__c rhOrder = PrepareData.createOrder('WWW');
		insert rhOrder;
		Ship_To__c rhShipTo = PrepareData.createShipTo(rhOrder.Id, '1');
		insert rhShipTo;
		Order_Line_Items__c rhOrderLine = PrepareData.createOrderLine(rhOrder.Id, rhShipTo.Id, '1', pc.p.Id);
    }
}