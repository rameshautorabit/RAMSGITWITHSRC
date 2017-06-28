/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=true)
private class TestOpportunityExtension {

    static testMethod void testOpportunityExtension() {
        
        // Declare local variables
        List<SObject>	objects = new List<Sobject>(); // An array of SObjects for mass processing
        Pricebook2		pb; // An active Pricebook
        
		// Create an Account
        Account a = PrepareData.createAccount();
        insert a;
        
        // Create a Contact
        Contact c = PrepareData.createContact(a.Id);
        insert c;
        
        // Create an Opportunity
        Opportunity o = PrepareData.createOpportunity(a.Id);
        insert o;
        
        // Get an active Pricebook
        pb = [SELECT Id FROM Pricebook2 WHERE IsActive = True LIMIT 1];
        
        // Create three Products
        PrepareData.productClass pc1 = PrepareData.createProduct('Widget1', 100, 'Widget1', 150);
        PrepareData.productClass pc2 = PrepareData.createProduct('Widget2', 100, 'Widget2', 150);
        PrepareData.productClass pc3 = PrepareData.createProduct('Widget3', 100, 'Widget3', 150);
        
        // Create an Opportunity Line Item for the Opportunity
        OpportunityLineItem oli1 = PrepareData.createOLI(10, o.Id, 135, pc1.pbe.Id, 2);
		oli1.SKU_del__c = 'abcdefg'; // This is to ensure we bypass a validation rule that is irrelevant in this case
        insert oli1;
        
        // Set Test page context to the Opportunity Detail Page
		Test.setCurrentPage(Page.OpportunityLineItems);
		
		// Start the test
		Test.startTest();
		        
        // Instantiate the Controller
        OpportunityExtension oe1 = new OpportunityExtension(new ApexPages.StandardController(o));
        
        // Assert the Controller was instantiated correctly
        System.assertEquals(1, oe1.lineItemCount);
        System.assert(!oe1.showMoreLink);
        
        // Assert the OpportunityLineItemWrapper was instantiated correctly
        System.assertEquals(150, oe1.opportunityLineItems[0].directCurrentPrice);
        System.assertEquals(150, oe1.opportunityLineItems[0].directOriginalPrice);
        System.assertEquals(10, oe1.opportunityLineItems[0].oli.Discount_Percent__c);
        System.assertEquals(25.93, oe1.opportunityLineItems[0].oli.Margin__c);
        System.assert(oe1.opportunityLineItems[0].productName.contains('Widget1'));
        System.assertEquals('Ship', oe1.opportunityLineItems[0].productShipVia);
        System.assertEquals(270, oe1.opportunityLineItems[0].totalContractPrice);
        
        // Add three more Opportunity Line Items
        OpportunityLineItem oli2 = PrepareData.createOLI(10, o.Id, 135, pc2.pbe.Id, 1);
        oli2.SKU_del__c = 'abcdefg'; // This is to ensure we bypass a validation rule that is irrelevant in this case
        objects.add(oli2);
        OpportunityLineItem oli3 = PrepareData.createOLI(10, o.Id, 135, pc2.pbe.Id, 1);
        oli3.SKU_del__c = 'abcdefg'; // This is to ensure we bypass a validation rule that is irrelevant in this case
        objects.add(oli3);
        OpportunityLineItem oli4 = PrepareData.createOLI(10, o.Id, 135, pc2.pbe.Id, 1);
        oli4.SKU_del__c = 'abcdefg'; // This is to ensure we bypass a validation rule that is irrelevant in this case
        objects.add(oli4);
        insert objects;
        
        // Instantiate the Controller
        OpportunityExtension oe2 = new OpportunityExtension(new ApexPages.StandardController(o));
        
        // Search for the 5th Product
        oe2.searchString = 'Widget1';
        oe2.updateAvailableList();
        
        // Loop through the search results asserting that the first Product is the search results
        for (PricebookEntry pbe : oe2.availableProducts)
        {
        	System.assertEquals('Widget1', pbe.Product2.Actual_Product_Name__c);
        	
        } // END LOOP through the search results asserting that none of the results are the first Product
        
        // Add the 5th Product to the Opportunity
        oe2.toSelect = pc1.pbe.Id;
        System.debug('Adding ' + pc1.pbe + ' to the ' + oe2.newOpportunityLineItems.size() + ' line items.');
        oe2.addOneProduct();
		System.debug('There are now ' + oe2.newOpportunityLineItems.size() + ' line items.');
        oe2.newOpportunityLineItems[0].oli.Quantity = 1;
        System.assertEquals(pc1.pbe.Id, oe2.newOpportunityLineItems[0].oli.PricebookEntryId);
                
        // Search for the 6th Product, testing a search where we also search for a Product already added to the Opportunity.
        oe2.searchString = 'Widget1,Widget3';
        oe2.updateAvailableList();
        
        /* MDF 8/21/13 Commented out since we now allow products to be reselected
        // Assert that the first Product is not returned in the search but the second is
        boolean	containsSecondProduct = false;
        
        // Loop through the search results asserting that none of the results are the first Product
        System.debug('The ' + oe2.availableProducts.size() + ' available Products are ' + oe2.availableProducts);
        for (PricebookEntry pbe : oe2.availableProducts)
        {
        	System.assertNotEquals('Widget1', pbe.Product2.Actual_Product_Name__c);
        	if (pbe.Product2.Actual_Product_Name__c == 'Widget3')
        	{
        		// If the second Product is returned then update the flag
        		containsSecondProduct = true;
        	}
        	
        } // END LOOP through the search results asserting that none of the results are the first Product
        
        // Assert that the second Product was returned
        System.assert(containsSecondProduct);
        */
        
        // Add the sixth line item, testing the addNewOLI functionality
//        oe2.toSelect = pc3.pbe.Id;
//        oe2.addOneProduct();
		System.debug('Adding sixth line');
		System.debug(oe2.newOpportunityLineItems.size() + ' new Opportunity Line Items: ' + oe2.newOpportunityLineItems);
		oe2.addAllProducts();
        oe2.newOpportunityLineItems[1].oli.Quantity = 1;
        
        // Save the two new records
        oe2.insertNewOLI();
        
        // Assert the Controller was instantiated correctly
        System.assertEquals(7, oe2.lineItemCount);
        
        // Reinstantiate the controller to test the limit on rows displayed on the detail page as well as the "show more" link
        OpportunityExtension oe3 = new OpportunityExtension(new ApexPages.StandardController(o));
        //System.assertEquals(5, oe3.opportunityLineItems.size()); // There should be no more than 5 of the total selected
        //System.assert(oe3.showMoreLink);
        
        // Set Test page context to the full-length Opportunity Line Items Page
		Test.setCurrentPage(Page.OpportunityLineItems);
		        
        // Instantiate the Controller
        System.debug('Instantiating Controller #4.');
        OpportunityExtension oe4 = new OpportunityExtension(new ApexPages.StandardController(o));
        
        // Assert that all records are being displayed as opposed to just 5
        System.assertEquals(7, oe4.opportunityLineItems.size());
        
        // Delete two of the line items
        oe3.opportunityLineItems[0].deleteOLI();
        oe3.opportunityLineItems[0].deleteOLI();
        
        // Assert that the delete was processed correctly
        System.assertEquals(5, oe3.lineItemCount);
        //System.assert(!oe3.showMoreLink);
        
        // Clear the objects variable
        objects.clear();
        
        // Add 96 more Line Items to being the total to 101 and test governor limits on large orders
        for (integer i = 0; i < 96; i++)
        {
        	OpportunityLineItem newOLI = PrepareData.createOLI(10, o.Id, 135, pc2.pbe.Id, 1);
        	newOLI.SKU_del__c = 'abcdefg';
        	objects.add(newOLI.clone(true, true));
        }
        
        insert objects;
        
        // Instantiate the Controller
        System.debug('Instantiating Controller #6.');
        OpportunityExtension oe6 = new OpportunityExtension(new ApexPages.StandardController(o));
        
        // Assert that all records are being displayed as opposed to just 5
        System.assertEquals(101, oe6.opportunityLineItems.size());
        
        // Create a new Opporunity
        Opportunity o2 = PrepareData.createOpportunity(a.Id);
        insert o2;
        
        // Create a line item for the Opoportunity
        OpportunityLineItem oli6 = PrepareData.createOLI(30, o2.Id, 135, pc1.pbe.Id, 2);
        insert oli6;
        
        // Instantiate the Controller
        OpportunityExtension oe5 = new OpportunityExtension(new ApexPages.StandardController(o2));
        
        // Update the discount on line item with Product 1
        oe5.opportunityLineItems[0].oli.Discount_Percent__c = 20;
        oe5.opportunityLineItems[0].discountPctChanged();
        
        // Assert that the Unit Price, Margin and Total Contract Price were calculated correctly
        System.assertEquals(120, oe5.opportunityLineItems[0].oli.UnitPrice);
        System.assertEquals(16.67, oe5.opportunityLineItems[0].oli.Margin__c);
        System.assertEquals(240, oe5.opportunityLineItems[0].totalContractPrice);
        
        // Update the Unit Price
        oe5.opportunityLineItems[0].oli.UnitPrice = 105;
        oe5.opportunityLineItems[0].unitPriceChanged();
        
        // Assert that the Discount Percent, Margin and Total Contract Price were calculated correctly
        System.assertEquals(30, oe5.opportunityLineItems[0].oli.Discount_Percent__c);
        System.assertEquals(4.76, oe5.opportunityLineItems[0].oli.Margin__c);
        System.assertEquals(210, oe5.opportunityLineItems[0].totalContractPrice);
        
        // Update the Margin
        oe5.opportunityLineItems[0].oli.Margin__c = 25.9259259259259;
        oe5.opportunityLineItems[0].marginChanged();
        
        // Assert that the Discount Percent, Unit Price and Total Contract Price were calculated correctly
        System.assertEquals(10, oe5.opportunityLineItems[0].oli.Discount_Percent__c);
        System.assertEquals(135, oe5.opportunityLineItems[0].oli.UnitPrice);
        System.assertEquals(270, oe5.opportunityLineItems[0].totalContractPrice);
        
        // Update the Quantity
        oe5.opportunityLineItems[0].oli.Quantity = 4;
        oe5.opportunityLineItems[0].quantityChanged();
        
        // Assert that the Discount Percent, Unit Price and Total Contract Price were calculated correctly
        System.assertEquals(540, oe5.opportunityLineItems[0].totalContractPrice);
        
        // Save the changes to the database
        oe5.applyOLIChanges();
        
        // Test the Edit OLI Functionality
        oe5.editOLI();
        System.assert(oe5.isEditMode);
        
        // Update the discount again on line item with Product 1
        for (OpportunityExtension.OpportunityLineItemWrapper oliw : oe5.opportunityLineItems)
        {
        	if(oliw.oli.PricebookEntryId == pc1.pbe.Id)
        	{
        		oliw.oli.Discount_Percent__c = 90;
        	}
        }

        // Test Canceling changes
        oe5.oliCancel();
        
        // Assert that the changes were made and not made accordingly
        System.assertEquals(10, [SELECT Discount_Percent__c FROM OpportunityLineItem WHERE OpportunityId = :o2.Id AND PricebookEntryId = :pc1.pbe.Id LIMIT 1].Discount_Percent__c);

        // Assert that the Add Product is redirecting correctly
        PageReference pg = oe5.addOli();
        System.assert(pg.getURL().contains('/p/opp/SelectSearch?addTo='));
        /*
        // Create a new Opportunity
        Opportunity o3 = PrepareData.createOpportunity(a.Id);
        insert o3;
        
        // Instantiate the Controller
        OpportunityExtension oe7 = new OpportunityExtension(new ApexPages.StandardController(o3));
        
        // Select multiple records and add them to the selected Products
        oe7.searchString = 'Widget1,Widget3';
        oe7.updateAvailableList();
        oe7.addAllProducts();
        
        // Assert that the products were added and the Controller variables changed appropriately
        System.assertEquals(2, oe7.newOpportunityLineItems.size());
        System.assert(oe7.hasOLIChanged);
        
        // Test setting the margin too high
        oe7.newOpportunityLineItems[0].oli.Margin__c = 101;
        oe7.newOpportunityLineItems[0].marginChanged();
        
        // Assert that the expected error was generated
        System.assertEquals('Margin cannot be equal to or greater than 100. Please enter a lower Margin.', oe7.errorMessage);
        
        // Test setting the margin too low
        oe7.newOpportunityLineItems[0].oli.Margin__c = -1;
        oe7.newOpportunityLineItems[0].marginChanged();
        
        // Assert that the expected error was generated
        System.assertEquals('Margin cannot be less than 0. Please enter a Margin between 0 and 100.', oe7.errorMessage);
        
        // Cancel the add new
        oe7.oliCancelAddNew();
        
        // Assert that the line items were cleared and the variables reset
        System.assertEquals(0, oe7.newOpportunityLineItems.size());
        System.assertEquals(0, [SELECT COUNT() FROM OpportunityLineItem WHERE OpportunityId = :o3.Id]);
        System.assert(!oe7.hasOLIChanged);
        */
        
        // Stop the test
        Test.stopTest();
    }
    
    static testMethod void testOpportunityExtension2() {
    	
    	// Declare local variables
        List<SObject>	objects = new List<Sobject>(); // An array of SObjects for mass processing
        Pricebook2		pb; // An active Pricebook
        
		// Create an Account
        Account a = PrepareData.createAccount();
        insert a;
        
        // Create a Contact
        Contact c = PrepareData.createContact(a.Id);
        insert c;
        
        // Create an Opportunity
        Opportunity o = PrepareData.createOpportunity(a.Id);
        insert o;
        
        // Get an active Pricebook
        pb = [SELECT Id FROM Pricebook2 WHERE IsActive = True LIMIT 1];
        
        // Create three Products
        PrepareData.productClass pc1 = PrepareData.createProduct('Widget1', 100, 'Widget1', 150);
        PrepareData.productClass pc2 = PrepareData.createProduct('Widget2', 100, 'Widget2', 150);
        PrepareData.productClass pc3 = PrepareData.createProduct('Widget3', 100, 'Widget3', 150);
        
        // Create an Opportunity Line Item for the Opportunity
        OpportunityLineItem oli1 = PrepareData.createOLI(10, o.Id, 135, pc1.pbe.Id, 2);
		oli1.SKU_del__c = 'abcdefg'; // This is to ensure we bypass a validation rule that is irrelevant in this case
        insert oli1;
        
        // Add a bunch of Opportunity Line Items
        
        // Add 96 more Line Items to being the total to 101 and test governor limits on large orders
        for (integer i = 0; i < 50; i++)
        {
        	OpportunityLineItem newOLI = PrepareData.createOLI(10, o.Id, 135, pc2.pbe.Id, 1);
        	newOLI.SKU_del__c = 'abcdefg';
        	objects.add(newOLI.clone(true, true));
        }
        
        insert objects;
        
        // Set Test page context to the Opportunity Detail Page
		Test.setCurrentPage(Page.OpportunityLineItems);
		        
        // Instantiate the Controller
        OpportunityExtension oe6 = new OpportunityExtension(new ApexPages.StandardController(o));
        
        // Exercise some of the other methods in the controller
        oe6.nextSet();
        oe6.previousSet();
        oe6.getShowNext();
        oe6.getShowPrevious();
        oe6.getRowsPerPage();
        oe6.setRowsPerPage('20');
        oe6.rowsPerPageChanged();
        
        oe6.getffMethodList();
        oe6.setffMethodSelection('Drop Ship');
        oe6.getffMethodSelection();
        oe6.applyGlobalFulfillment();
        
        oe6.getffMethods();
        oe6.setffDiscount('All');
        oe6.getffDiscount();
        oe6.setGlobalDiscount('15');
        oe6.getGlobalDiscount();
        oe6.applyGlobalDiscount();
        
        oe6.setffMargin('All');
        oe6.getffMargin();
        oe6.setGlobalMargin('10');
        oe6.getGlobalMargin();
        oe6.applyGlobalMargin();
        
        ApexPages.currentPage().getParameters().put('columnSort', 'ListPrice');
		ApexPages.currentPage().getParameters().put('dataType', 'Number');
		oe6.sortOLIcolumn();
    }
    
    static testMethod void testOpportunityExtension3() {
        
        // Declare local variables
        List<SObject>	objects = new List<Sobject>(); // An array of SObjects for mass processing
        Pricebook2		pb; // An active Pricebook
        
		// Create an Account
        Account a = PrepareData.createAccount();
        insert a;
        
        // Create a Contact
        Contact c = PrepareData.createContact(a.Id);
        insert c;
        
        // Create an Opportunity
        Opportunity o = PrepareData.createOpportunity(a.Id);
        insert o;
        
        // Get an active Pricebook
        pb = [SELECT Id FROM Pricebook2 WHERE IsActive = True LIMIT 1];
        
        // Create three Products
        PrepareData.productClass pc1 = PrepareData.createProduct('Widget1', 100, 'Widget1', 150);
        PrepareData.productClass pc2 = PrepareData.createProduct('Widget2', 100, 'Widget2', 150);
        PrepareData.productClass pc3 = PrepareData.createProduct('Widget3', 100, 'Widget3', 150);
        
        // Create an Opportunity Line Item for the Opportunity
        OpportunityLineItem oli1 = PrepareData.createOLI(10, o.Id, 135, pc1.pbe.Id, 2);
		oli1.SKU_del__c = 'abcdefg'; // This is to ensure we bypass a validation rule that is irrelevant in this case
        insert oli1;
        
        // Set Test page context to the Opportunity Detail Page
		Test.setCurrentPage(Page.OpportunityLineItems);
		
		// Create a new Opportunity
        Opportunity o3 = PrepareData.createOpportunity(a.Id);
        insert o3;
		
		// Instantiate the Controller
        OpportunityExtension oe7 = new OpportunityExtension(new ApexPages.StandardController(o3));
        
        // Select multiple records and add them to the selected Products
        oe7.searchString = 'Widget1,Widget3';
        oe7.updateAvailableList();
        oe7.addAllProducts();
        
        // Assert that the products were added and the Controller variables changed appropriately
        System.assertEquals(2, oe7.newOpportunityLineItems.size());
        System.assert(oe7.hasOLIChanged);
        
        // Test setting the margin too high
        oe7.newOpportunityLineItems[0].oli.Margin__c = 101;
        oe7.newOpportunityLineItems[0].marginChanged();
        
        // Assert that the expected error was generated
        System.assertEquals('Margin cannot be equal to or greater than 100. Please enter a lower Margin.', oe7.errorMessage);
        
        // Test setting the margin too low
        oe7.newOpportunityLineItems[0].oli.Margin__c = -1;
        oe7.newOpportunityLineItems[0].marginChanged();
        
        // Assert that the expected error was generated
        System.assertEquals('Margin cannot be less than 0. Please enter a Margin between 0 and 100.', oe7.errorMessage);
        
        // Cancel the add new
        oe7.oliCancelAddNew();
        
        // Assert that the line items were cleared and the variables reset
        System.assertEquals(0, oe7.newOpportunityLineItems.size());
        System.assertEquals(0, [SELECT COUNT() FROM OpportunityLineItem WHERE OpportunityId = :o3.Id]);
        System.assert(!oe7.hasOLIChanged);
    }
		
}