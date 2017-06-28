@isTest(seeAllData=true)
private class ClearCardInfoTest {

	static testMethod void myUnitTest() {
		
		// Create an Account
        Account a = PrepareData.createAccount();
        insert a;
        
        // Create a Contact
        Contact c = PrepareData.createContact(a.Id);
        insert c;
        
        // Create an Opportunity
        Opportunity o = PrepareData.createOpportunity(a.Id);
        o.Amount = 1000000;
        insert o;
        
        // Get a User
        User u = [SELECT Id FROM User WHERE UserType = 'Standard' LIMIT 1];
        
        // Create a Quote
        Quote q = PrepareData.createQuote(u.Id, c.Id, o.Id, u.Id, 'Standard');
        q.Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
        insert q;
        
        // Create a line item for the Quote
        PrepareData.productClass pc = PrepareData.createProduct('GAUAASAIOOC', 100000, 'Art Devo Table', 100000);
        QuoteLineItem qli = PrepareData.createQLI(q.Id, 100000, pc.pbe.Id, 1);
        insert qli;
        
        // Get the Quote Clone Object that was created
        Quote_Clone__c qc = [SELECT Amount_To_Be_Applied__c, Card_Billing_City__c, Card_Billing_Country__c,
        	Card_Billing_Postal_Code__c, Card_Billing_State__c, Card_Billing_Street__c, Card_Expiration_Month__c,
			Card_Expiration_Year__c, Card_Holder_Name__c, Card_Number__c, Second_Amount_To_Be_Applied__c,
			Second_Bill_To_City__c, Second_Bill_To_Country__c, Second_Bill_To_Postal_Code__c, Second_Bill_To_State__c,
			Second_Bill_To_Street__c, Second_Card_Expiration_Month__c, Second_Card_Expiration_Year__c,
			Second_Card_Holder_Name__c, Second_Card_Number__c FROM Quote_Clone__c WHERE Source_Record__c = :q.Id LIMIT 1];
        
        // Update the Quote Clone with Card Info
        qc.Amount_To_Be_Applied__c = 75000;
        qc.Card_Billing_City__c = 'Denver';
		qc.Card_Billing_Country__c = 'USA';
		qc.Card_Billing_Postal_Code__c = '80237';
		qc.Card_Billing_State__c = 'CO';
		qc.Card_Billing_Street__c = '6565 Main Street';
		qc.Card_Expiration_Month__c = '03';
		qc.Card_Expiration_Year__c = '3014';
		qc.Card_Holder_Name__c = 'Pat Anderson';
		qc.Card_Number__c = '4111111111111111';
		qc.Second_Amount_To_Be_Applied__c = 25000;
        qc.Second_Bill_To_City__c = 'San Francisco';
		qc.Second_Bill_To_Country__c = 'USA';
		qc.Second_Bill_To_Postal_Code__c = '94105';
		qc.Second_Bill_To_State__c = 'CA';
		qc.Second_Bill_To_Street__c = '339 Villa de los Lobos';
		qc.Second_Card_Expiration_Month__c = '03';
		qc.Second_Card_Expiration_Year__c = '3014';
		qc.Second_Card_Holder_Name__c = 'Valeria Sa';
		qc.Second_Card_Number__c = '378282246310005';
		qc.Submitted__c = true;
		update qc;
		
		// Reselect the Opportunity to assert that it contains the card info
		Opportunity theOpportunity = [SELECT Order_Number__c, Amount_To_Be_Applied__c, Card_Billing_City__c,
			Card_Billing_Country__c, Card_Billing_Postal_Code__c, Card_Billing_State__c,
			Card_Billing_Street__c,	Card_Expiration_Month__c, Card_Expiration_Year__c, 
			Card_Holder_Name__c, Card_Number__c, Second_Amount_To_Be_Applied__c, Second_Bill_To_City__c,
			Second_Bill_To_Country__c, Second_Bill_To_Postal_Code__c, Second_Bill_To_State__c,
			Second_Bill_To_Street__c, Second_Card_Expiration_Month__c, Second_Card_Expiration_Year__c,
			Second_Card_Holder_Name__c, Second_Card_Number__c FROM Opportunity WHERE Id = :o.Id LIMIT 1];
		
		// Assert that the Opportunity was updated correctly
		System.assertEquals(75000, theOpportunity.Amount_To_Be_Applied__c);
		System.assertEquals('Denver', theOpportunity.Card_Billing_City__c);
		System.assertEquals('USA', theOpportunity.Card_Billing_Country__c);
		System.assertEquals('80237', theOpportunity.Card_Billing_Postal_Code__c);
		System.assertEquals('CO', theOpportunity.Card_Billing_State__c);
		System.assertEquals('6565 Main Street', theOpportunity.Card_Billing_Street__c);
		System.assertEquals('03', theOpportunity.Card_Expiration_Month__c);
		System.assertEquals('3014', theOpportunity.Card_Expiration_Year__c);
		System.assertEquals('Pat Anderson', theOpportunity.Card_Holder_Name__c);
		System.assertEquals('4111111111111111', theOpportunity.Card_Number__c);	
		System.assertEquals(25000, theOpportunity.Second_Amount_To_Be_Applied__c);
		System.assertEquals('San Francisco', theOpportunity.Second_Bill_To_City__c);
		System.assertEquals('USA', theOpportunity.Second_Bill_To_Country__c);
		System.assertEquals('94105', theOpportunity.Second_Bill_To_Postal_Code__c);
		System.assertEquals('CA', theOpportunity.Second_Bill_To_State__c);
		System.assertEquals('339 Villa de los Lobos', theOpportunity.Second_Bill_To_Street__c);
		System.assertEquals('03', theOpportunity.Second_Card_Expiration_Month__c);
		System.assertEquals('3014', theOpportunity.Second_Card_Expiration_Year__c);
		System.assertEquals('Valeria Sa', theOpportunity.Second_Card_Holder_Name__c);
		System.assertEquals('378282246310005', theOpportunity.Second_Card_Number__c);	
		
		theOpportunity.Order_Number__c = '1';
		update theOpportunity;
        
        // Reselect the Opportunity to assert that the fields have been updated
        Opportunity theUpdatedOpportunity = [SELECT Order_Number__c, Card_Expiration_Month__c, Card_Expiration_Year__c, 
			Card_Info_Cleared_By__c, Card_Info_Cleared_Date_Time__c, Card_Number__c, Second_Card_Expiration_Month__c,
			Second_Card_Expiration_Year__c, Second_Card_Number__c FROM Opportunity WHERE Id = :o.Id LIMIT 1];
		
		// Assert that the Opportunity was cleared correctly
		System.assertEquals(null, theUpdatedOpportunity.Card_Expiration_Month__c);
		System.assertEquals(null, theUpdatedOpportunity.Card_Expiration_Year__c);
		System.assertEquals(null, theUpdatedOpportunity.Card_Number__c);	
		System.assertEquals(null, theUpdatedOpportunity.Second_Card_Expiration_Month__c);
		System.assertEquals(null, theUpdatedOpportunity.Second_Card_Expiration_Year__c);
		System.assertEquals(null, theUpdatedOpportunity.Second_Card_Number__c);	
		System.assertEquals(UserInfo.getUserId(), theUpdatedOpportunity.Card_Info_Cleared_By__c);
		System.assertNotEquals(null, theUpdatedOpportunity.Card_Info_Cleared_Date_Time__c);
		
        // Reselect the Quote Clone object(s)
        List<Quote_Clone__c> lqc = [SELECT Card_Expiration_Month__c, Card_Expiration_Year__c, 
        	Card_Info_Cleared_By__c, Card_Info_Cleared_Date_Time__c, Card_Number__c,
        	Second_Card_Expiration_Month__c, Second_Card_Expiration_Year__c, Second_Card_Number__c FROM Quote_Clone__c WHERE Opportunity__c = :o.Id];
		
		// Loop through the Quote Clone Objects asserting that the fields were updated
		for (Quote_Clone__c quoteClone : lqc)
		{
			System.assertEquals(null, quoteClone.Card_Expiration_Month__c);
			System.assertEquals(null, quoteClone.Card_Expiration_Year__c);
			System.assertEquals(null, quoteClone.Card_Number__c);
			System.assertEquals(null, quoteClone.Second_Card_Expiration_Month__c);
			System.assertEquals(null, quoteClone.Second_Card_Expiration_Year__c);
			System.assertEquals(null, quoteClone.Second_Card_Number__c);
			System.assertEquals(UserInfo.getUserId(), quoteClone.Card_Info_Cleared_By__c);
			System.assertNotEquals(null, quoteClone.Card_Info_Cleared_Date_Time__c);
		}
	}
}