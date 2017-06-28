@isTest
private class TestSyncOLI_QLI {
/*
    static testMethod void SyncOLIQLI() {
        List<QuoteLineItem> 		lstQLI = new List<QuoteLineItem>();
        List<OpportunityLineItem> 	lstOLI = new List<OpportunityLineItem>();
        List<Quote> 				lstQ = new List<Quote>();
        List<Opportunity> 			lstO = new List<Opportunity>();
        Date						todays = Date.today();
        
        // Account
        Account a = new Account();
        a.Name = 'Test Acc';
        a.Industry = 'Commercial';
        a.Segment__c = 'Architect';
        a.Member_Since__c = (Date.today()).addMonths(-4);
        insert a;
        
        // Contact
        
        Contact c = new Contact();
        c.Email = 'none@none.tcom';
        c.LastName = 'Test Contact';
        c.AccountId = a.id;
        insert c;
        
        // Opportunity
        
        Opportunity o = new Opportunity();
        o.Name = 'Opp Name';
        o.CurrencyIsoCode = 'USD';
        o.CloseDate = Date.today();
        o.AccountId = a.id;
        o.StageName = 'Project Inquiry';
        o.LeadSource = 'Web';
        //o.Ops_Contact__c = UserInfo.getUserId();
        o.PO__c = '222';
        o.Project__c = 'Test Proj';
        o.Price_Bid_Contact__c = c.Id;
       	insert o;
       	
       	Pricebook2 pb = [select Id from Pricebook2 where IsStandard = true];
       	PricebookEntry PBE=[select id,product2Id,Pricebook2Id from PricebookEntry WHERE isActive = true AND CurrencyIsoCode = 'USD' and Pricebook2Id = :pb.Id limit 1 ];
       	//PricebookEntry PBE=[select id,product2Id,Pricebook2Id from PricebookEntry WHERE isActive = true AND CurrencyIsoCode = 'USD' limit 1 ];
       	
       	system.debug('*****TestSyncOLI_QLI SyncOLIQLI PBE.Id = ' + PBE.Id + ' PBE.Product2Id = ' + PBE.Product2Id + ' PBE.Pricebook2Id = ' + PBE.Pricebook2Id);
       	 
       	OpportunityLineItem oli = new OpportunityLineItem();
       	oli.PricebookEntryId = PBE.id;
       	oli.Quantity = 100;
       	oli.Fulfillment_Method__c = 'Core Inventory - AC';
       	oli.Expected_Customer_Delivery_Date__c = '3-7 days';
       	oli.Est_Delivery_Date__c = todays;
       	oli.Notes__c = 'This is a fantastic product.';
       	oli.OpportunityId = o.id;
       	oli.UnitPrice = 11;
       	oli.SKU_del__c = PBE.Product2Id;
       	insert oli;
       	
       	lstOLI = [SELECT Fulfillment_Method__c, Est_Delivery_Date__c,  Expected_Customer_Delivery_Date__c, Notes__c FROM OpportunityLineItem WHERE Id = : oli.Id];
       	system.debug('lstOLI -  '+lstOLI);
       	
       	Quote q = new Quote();
       	q.name = 'TestQ';
       	q.Quoted_On__c = Date.today();
       	q.ExpirationDate = (Date.today()).addMonths(1);
       	q.Country__c = 'US';
       	q.Range_for_Handling_Fees__c = 'Yes';
       	q.Tax_Rate__c = 11;
       	q.Handling_Fees_Y_N__c = 'Yes';
       	q.ContactId = c.id;
       	q.Bill_To_Last_Name__c = 'Bunny';
       	q.BillingName = 'Test Contact';
       	q.ShippingName = 'Test Acc';
       	q.BDL_Name__c = UserInfo.getUserId();
       	q.OpportunityId = o.Id;
       	q.Pricebook2Id = oli.PricebookEntry.Pricebook2Id;
       	q.Tax_Code__c = 'T - Standard Tax';
       	q.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
       	
       	insert q;
       	
       	QuoteLineItem q1 = new QuoteLineItem();
       	q1.QuoteId = q.Id;
       	q1.PricebookEntryId = oli.PricebookEntryId;
       
       	q1.UnitPrice = oli.UnitPrice;
       	q1.Quantity = oli.Quantity;
       	q1.Fulfillment_Method__c = oli.Fulfillment_Method__c;
		q1.Delivery_Date__c = oli.Delivery_Date__c;
		q1.Notes__c = oli.Notes__c;
		q1.Quantity = oli.Quantity;
		q1.UnitPrice = oli.UnitPrice;
       	
       	insert q1;
		
       	List<QuoteLineItem> qliList = new List<QuoteLineItem>();
       	qliList = [select Id, Quantity, UnitPrice, OpportunityLineItemId__c, Fulfillment_Method__c, Delivery_Date__c, Expected_Customer_Delivery_Date__c, Est_Delivery_Date__c, Notes__c from QuoteLineItem where Id = : q1.Id];
       	
       	system.debug('*****TestSyncOLI_QLI qliList 1 = ' + qliList);
       	
       	System.assertEquals(oli.Fulfillment_Method__c, qliList[0].Fulfillment_Method__c);
		System.assertEquals(oli.Delivery_Date__c, qliList[0].Delivery_Date__c);
		System.assertEquals(oli.Notes__c, qliList[0].Notes__c);
       	
		oli.Fulfillment_Method__c = 'Contract Inventory';
		oli.Delivery_Date__c = '2 weeks';
		oli.Notes__c = 'Different notes';
		oli.Quantity = oli.Quantity + 1;
		oli.UnitPrice = oli.UnitPrice + 1;
		update oli;
		
		qliList = [select Id, Quantity, UnitPrice, OpportunityLineItemId__c, Fulfillment_Method__c, Delivery_Date__c, Expected_Customer_Delivery_Date__c, Est_Delivery_Date__c, Notes__c from QuoteLineItem where Id = : q1.Id];
		
		system.debug('*****TestSyncOLI_QLI qliList 2 = ' + qliList);
		
       	System.assertNotEquals(oli.Fulfillment_Method__c, qliList[0].Fulfillment_Method__c);
       	System.assertNotEquals(oli.Delivery_Date__c, qliList[0].Delivery_Date__c);
		System.assertNotEquals(oli.Notes__c, qliList[0].Notes__c);
		System.assertNotEquals(oli.Quantity, qliList[0].Quantity);
		System.assertNotEquals(oli.UnitPrice, qliList[0].UnitPrice);
       	
       	// Now synchronize the quote with the opportunity and verify that custom fields in the line items are synchronized
       	OpportunityLineItemService.resetOLItoQLIinProcess();
       	QuoteLineItemService.resetQLItoOLIinProcess();
       	o.SyncedQuoteId = q.Id;
       	update o;
       	
       	qliList = [select Id, Quantity, UnitPrice, OpportunityLineItemId__c, Fulfillment_Method__c, Delivery_Date__c, Expected_Customer_Delivery_Date__c, Est_Delivery_Date__c, Notes__c from QuoteLineItem where Id = : q1.Id];
		system.debug('*****TestSyncOLI_QLI qliList 3 = ' + qliList);
       	
       	List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
       	oliList = [select PricebookEntryId, PricebookEntry.Pricebook2Id, Quantity, UnitPrice, Fulfillment_Method__c, Delivery_Date__c, Est_Delivery_Date__c,  Expected_Customer_Delivery_Date__c, Notes__c, SyncedQuoteId__c from OpportunityLineItem where OpportunityId = :o.Id limit 1];
       	
       	system.debug('*****TestSyncOLI_QLI oliList 4 = ' + oliList);
       	
       	System.assertEquals(oliList[0].Fulfillment_Method__c, qliList[0].Fulfillment_Method__c);
       	System.assertEquals(oliList[0].Delivery_Date__c, qliList[0].Delivery_Date__c);
		System.assertEquals(oliList[0].Notes__c, qliList[0].Notes__c);
		System.assertEquals(oliList[0].Quantity, qliList[0].Quantity);
		System.assertEquals(oliList[0].UnitPrice, qliList[0].UnitPrice);
		
		qliList[0].Fulfillment_Method__c = 'Custom';
		qliList[0].Delivery_Date__c = '3 weeks';
		qliList[0].Notes__c = 'Blah blah';
		qliList[0].Quantity = qliList[0].Quantity + 1;
		qliList[0].UnitPrice = qliList[0].UnitPrice + 1;
		
		OpportunityLineItemService.resetOLItoQLIinProcess();
       	QuoteLineItemService.resetQLItoOLIinProcess();
		update qliList[0];
		
		oliList = [select PricebookEntryId, PricebookEntry.Pricebook2Id, Quantity, UnitPrice, Fulfillment_Method__c, Delivery_Date__c, Est_Delivery_Date__c,  Expected_Customer_Delivery_Date__c, Notes__c, SyncedQuoteId__c from OpportunityLineItem where OpportunityId = :o.Id limit 1];
		
		system.debug('*****TestSyncOLI_QLI oliList 5 = ' + oliList);
		
		System.assertEquals(oliList[0].Fulfillment_Method__c, qliList[0].Fulfillment_Method__c);
       	System.assertEquals(oliList[0].Delivery_Date__c, qliList[0].Delivery_Date__c);
		System.assertEquals(oliList[0].Notes__c, qliList[0].Notes__c);
		System.assertEquals(oliList[0].Quantity, qliList[0].Quantity);
		System.assertEquals(oliList[0].UnitPrice, qliList[0].UnitPrice);
		
		oliList[0].Fulfillment_Method__c = 'COM/COL';
		oliList[0].Delivery_Date__c = '4 weeks';
		oliList[0].Notes__c = 'JJJJJJ';
		oliList[0].Quantity = oliList[0].Quantity + 1;
		oliList[0].UnitPrice = oliList[0].UnitPrice + 1;
		
		OpportunityLineItemService.resetOLItoQLIinProcess();
       	QuoteLineItemService.resetQLItoOLIinProcess();
		update oliList[0];
		
		qliList = [select Id, Quantity, UnitPrice, OpportunityLineItemId__c, Fulfillment_Method__c, Delivery_Date__c, Expected_Customer_Delivery_Date__c, Est_Delivery_Date__c, Notes__c from QuoteLineItem where Id = : q1.Id];
		
		system.debug('*****TestSyncOLI_QLI qliList 6 = ' + qliList);
		
		System.assertEquals(oliList[0].Fulfillment_Method__c, qliList[0].Fulfillment_Method__c);
       	System.assertEquals(oliList[0].Delivery_Date__c, qliList[0].Delivery_Date__c);
		System.assertEquals(oliList[0].Notes__c, qliList[0].Notes__c);
		System.assertEquals(oliList[0].Quantity, qliList[0].Quantity);
		System.assertEquals(oliList[0].UnitPrice, qliList[0].UnitPrice);
    }
*/
}