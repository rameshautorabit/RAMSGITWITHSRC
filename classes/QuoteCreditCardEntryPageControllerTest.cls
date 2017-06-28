@IsTest
private class QuoteCreditCardEntryPageControllerTest {
    private static testmethod void testRVAccountToSFAccount(){
        
        Opportunity o = new Opportunity (
            Name = 'oppNameTest',
            StageName = 'stageNameTest',
            CloseDate = date.parse('12/27/2098')
        );
        insert o;
        
        Contact c = new Contact (
            LastName = 'contTest'
        );
        insert c;
        
        Quote_Clone__c qcc = new Quote_Clone__c (
            Contract_Total__c = 100000,
            Expiration_Date__c = date.parse('12/27/2099'),
            Opportunity__c = o.Id,
            Contact__c = c.Id,
            Opportunity_Name__c = 'name1',
            Invoice__c = '10'
        );
        insert qcc;
        
        ApexPages.StandardController controller = new ApexPages.StandardController(qcc);
        QuoteCreditCardEntryPageController qccepc = new QuoteCreditCardEntryPageController(controller);
        Test.StartTest();
        qccepc.cancel();
        
        qccepc.ok();
        System.assertEquals(qcc.Card_Holder_Name__c, NULL);
        qccepc.save();
        System.assertEquals(qcc.Card_Holder_Name__c, NULL);
        System.assert(qccepc.errorMessage.contains('Card holder name is required.'));
        qcc.Card_Holder_Name__c = 'cardHolderTest';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('Card billing street is required.'));
        qcc.Card_Billing_Street__c = 'billStreetTest';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('Card billing city is required.'));
        qcc.Card_Billing_City__c = 'billCityTest';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('Card billing state is required.'));
        qcc.Card_Billing_State__c = 'billStateTest';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('Card billing zip/postal code is required.'));
        qcc.Card_Billing_Postal_Code__c = 'billPostCodeTest';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('Card billing country is required.'));
        qcc.Card_Billing_Country__c = 'billCountryTest';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('M/C, Visa, AMEX # is required.'));
        qcc.Card_Number__c = 'cardNumTest';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('Expiration month is required.'));
        qcc.Card_Expiration_Month__c = 'aa';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('Expiration month must be numeric.'));
        qcc.Card_Expiration_Month__c = '10';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('Expiration year is required.'));
        qcc.Card_Expiration_Year__c = 'aaaa';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('Expiration year must be numeric.'));
        qcc.Card_Expiration_Year__c = '111';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('The Expiration Year must be in YYYY format. Please enter a valid Expiration Year.'));
        qcc.Card_Expiration_Year__c = '1111';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('The Expiration Date must be in the future. Please enter a valid Expiration Date.'));
        qcc.Card_Expiration_Year__c = '4444';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('The credit card number is invalid.'));
        qcc.Card_Number__c = '4111111111111111';
        qccepc.firstAmountToBeApplied = '-750000';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('Amount to be applied must be a number greater than zero.'));
        qccepc.firstAmountToBeApplied = 'xx';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('Amount to be applied must be a number greater than zero.'));
        qccepc.firstAmountToBeApplied = null;
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('Please enter an amount to be applied for the first card.'));
        qccepc.firstAmountToBeApplied = '75000';
        qccepc.secondAmountToBeApplied = '50000';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('Card holder name is required if entering a second credit card.'));
        qcc.Second_Card_Holder_Name__c = 'Valeria Sa';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('Card billing street is required if entering a second credit card.'));
        qcc.Second_Bill_To_Street__c = '293 Hampden Avenue';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('Card billing city is required if entering a second credit card.'));
        qcc.Second_Bill_To_City__c = 'Denver';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('Card billing state is required if entering a second credit card.'));
        qcc.Second_Bill_To_State__c = 'CO';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('Card billing zip/postal code is required if entering a second credit card.'));
        qcc.Second_Bill_To_Postal_Code__c = '80220';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('Card billing country is required if entering a second credit card.'));
        qcc.Second_Bill_To_Country__c = 'USA';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('M/C, Visa, AMEX # is required if entering a second credit card.'));
        qcc.Second_Card_Number__c = '4115';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('The second credit card number is invalid.'));
        qcc.Second_Card_Number__c = '4111111111111111';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('Expiration month is required if entering a second credit card.'));
        qcc.Second_Card_Expiration_Month__c = 'xx';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('Expiration month must be numeric.'));
        qcc.Second_Card_Expiration_Month__c = '06';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('Expiration year is required if entering a second credit card.'));
        qcc.Second_Card_Expiration_Year__c = 'xx';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('Expiration year must be numeric.'));
        qcc.Second_Card_Expiration_Year__c = '123';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('The Expiration Year must be in YYYY format. Please enter a valid Expiration Year.'));
        qcc.Second_Card_Expiration_Year__c = '2012';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('The Expiration Date must be in the future. Please enter a valid Expiration Date.'));
		qcc.Second_Card_Expiration_Year__c = String.valueOf(System.today().year()+1);
		qcc.Second_Card_Expiration_Month__c = '13';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('The Expiration Month must be between 1 and 12. Please enter a valid Expiration Month.'));
        qcc.Second_Card_Expiration_Month__c = '06';
        qccepc.secondAmountToBeApplied = null;
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('Amount to be applied is required if entering a second credit card.'));
        qccepc.secondAmountToBeApplied = 'xx';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('Amount to be applied must be a number greater than zero.'));
        qccepc.secondAmountToBeApplied = '-100';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('Amount to be applied must be a number greater than zero.'));
        qccepc.secondAmountToBeApplied = '75000';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('The amounts to be applied cannot be greater than the Contract Total.'));
        qccepc.secondAmountToBeApplied = '25000';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('The two credit card numbers cannot be identical.'));
        qcc.Second_Card_Number__c = '378282246310005';
        qcc.Card_Expiration_Year__c = String.valueof(Date.today().year());
        qcc.Card_Expiration_Month__c = '0';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('The Expiration Date must be in the future. Please enter a valid Expiration Date.'));
        qcc.Card_Expiration_Month__c = '14';
        qccepc.save();
        System.assert(qccepc.errorMessage.contains('The Expiration Month must be between 1 and 12. Please enter a valid Expiration Month.'));
        qcc.Card_Expiration_Month__c = '06';
        qcc.Card_Expiration_Year__c = String.valueof(Date.today().year()+1);
        qccepc.save();
        System.assertEquals('', qccepc.errorMessage);
        Test.StopTest();
    }
}