/*********************************************************/
/*                                                       */
/*  This class is the extension class for the            */
/*  Visualforce for the Opportunity object.              */
/*                                                       */
/*********************************************************/

public with sharing class OpportunityExtension {

    // Error handling
    public String   errorMessage {get; private set;}
    public Boolean  hasErrors {get; private set;}

    // Handle custom exceptions
    public class CustomException extends Exception {}

    // Object & list vars
    public List<PricebookEntry>             availableProducts {get; private set;} // The Product Search Results
    public Boolean                          hasOLIChanged {get; private set;}
    public Boolean                          hasSearchResults {get; private set;}
    public Boolean                          isEditMode {get; private set;}
    public Boolean                          isFullPage {get; private set;}
    public integer                          lineItemCount {get; private set;}
    public String                           lineItemCountDisplay {get; private set;}
    public integer                          lineItemsDisplayed {get; private set;}
    public Boolean                          multipleCurrencies {get; private set;} // Indicates whether the org is using multiple currency
    public List<OpportunityLineItemWrapper> newOpportunityLineItems {get; set;} // The list of new Line Items to be inserted
    public Id                               opportunityId {get; set;} // The Id of the Opportunity
    public List<OpportunityLineItemWrapper> opportunityLineItems {get; set;}
    public Boolean                          overLimit {get; private set;} // Indicates whether or not too many Products have been retrieved in the search
    public Map<Id, PricebookEntry>          pbes {get; private set;} // The Pricebook Entries to be added to the Opportunity
    public Map<Id, Product2>                products {get; private set;} // The Products corresponding to the Pricebook Entries to be added to the Opportunity
    public Boolean                          saveAndAddMore {get; set;} // Indicates whether to stay on the Add Products Page
    public string                           searchString {get; set;} // The search term for new products
    public Boolean                          showAddedProducts {get; set;} // Indicates whether to display the link showing more line items
    public Boolean                          showMoreLink {get; set;} // Indicates whether to display the link showing more line items
    public Opportunity                      theOpportunity {get; private set;}
    public String                           toSelect{get; set;} // Indicates the clicked row in the search results
    public List<OpportunityLineItemWrapper> oliDisplay {get; set;}
    public Integer displaySet {get; set;}
    public Integer pageNumber {get; set;}
    public Integer totalPages {get; set;}
    public Integer rowsToDisplay {get; set;}
    Map<Id, OpportunityLineItem> totalPriceMap;
    Boolean onOLIpage;
    Boolean useSortOrder = null;

    // Instance handle for executing base methods from within wrapper instances
    private OpportunityExtension thisOpportunityExtension;

    // Variable for focus
    public String focusedElementId {get; set;}

    public OpportunityExtension(ApexPages.StandardController sc)
    {
        this.theOpportunity = (Opportunity) sc.getRecord();

        this.thisOpportunityExtension = (OpportunityExtension) this;
        System.debug('Initializing the Opportunity Extension variable: ' + this.thisOpportunityExtension);
        system.debug('*****theOpportunity.Id = ' + this.theOpportunity.Id);

        this.hasOLIChanged = false; // Set to true when list item is added or changes
        
        this.hasSearchResults = false; // Set to true when product search returns records

        // Error handling
        hasErrors = false;
        errorMessage = '';
        
        // Determine if we are on the OpportunityLineItems page
        if (ApexPages.currentPage().getURL().containsIgnoreCase('OPPORTUNITYLINEITEMS')) {
            onOLIpage = true;
        } else {
            onOLIpage = false;
        }

        // Initialize display variables
        isEditMode = false;
        this.saveAndAddMore = false;
        rowsToDisplay = 15;
        displaySet = 0;
        pageNumber = 1;
        totalPages = 1;

        // Load fields that we may need to use later
        this.theOpportunity = [SELECT Amount, CurrencyIsoCode, Id, Name, Pricebook2Id FROM Opportunity WHERE id =:this.theOpportunity.id];
        this.lineItemsDisplayed = 5; // Maximum number of line items to display on the Opportunity Detail Page
        this.multipleCurrencies = UserInfo.isMultiCurrencyOrganization();
        this.showAddedProducts = false;

        // Set the Pricebook if it is null
        if (this.theOpportunity.Pricebook2Id == null)
        {
            this.theOpportunity.Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE Name = 'Standard Price Book'].Id;
        }

        system.debug('this.theOpportunity = '+this.theOpportunity);
        system.debug('Inside the constructor.');
        loadOLIs();

        // Initialize the list of new Line Items to be inserted
        newOpportunityLineItems = new List<OpportunityLineItemWrapper>();
    }

    private void loadOLIs()
    {
        // Default to empty list
        opportunityLineItems = new List<OpportunityLineItemWrapper>();
        oliDisplay = new List<OpportunityLineItemWrapper>();
        oliColumnName = null;

        // Determine how many rows to select
        integer numRows;

        System.debug('Current Page URL: ' + ApexPages.currentPage().getURL());

        if (onOLIpage) {
            numRows = 10000;
        } else {
            numRows = this.lineItemsDisplayed;
        }
        System.debug('NumRows set to ' + numRows);
        System.debug('Selecting Opportunity Line Items for Opportunity ' + theOpportunity.Id);
        
        Id oppId = theOpportunity.Id;
        String oliQueryString = 'SELECT Amount_Discounted__c, Contract_SPO_Amount__c, CreatedById, Name, '
            + 'Actual_Product_Name__c, CreatedDate, CW_Color__c, CW_Item_Description__c, CW_Size__c, Description, '
            + 'Direct_Current_Price__c, Product2Id, Discount, Discount_Percent__c, DMMSSku__c, Drop_Ship_Amount__c, '
            + 'ELC__c, Est_Delivery_Date__c, Expected_Customer_Delivery_Date__c, Delivery_Date__c, Fulfillment_Method__c, '
            + 'Id, IsDeleted, Landed_Cost__c, LastModifiedById, LastModifiedDate, Line_Item_Total_List_Price__c, ListPrice, '
            + 'Manual_Distro_info__c, Margin__c, Notes__c, OpportunityId, Opportunity_Product__c, Percent_Discounted__c, '
            + 'PricebookEntryId, Price_Diff__c, Product_Margin__c, Product_Name__c, Product_Ship_Via__c, Quantity, '
            + 'Quote_Product_Name__c, Active__c, Requires_Handling_Fee__c, ServiceDate, SideMark__c, SKU_del__c, Subtotal, '
            + 'SystemModstamp, Total_ELC__c, TotalPrice, UnitPrice, Unit_Price__c, Update_ELC_total__c, ' 
            + 'PricebookEntry.Product2.Member_Price__c, Sort_Order__c, Customer_Location__c, Customer_Spec__c '
            + 'FROM OpportunityLineItem WHERE OpportunityId = :oppId';
        
        // Determine default sort order to use - if SortOrder is set, use it, otherwise sort by CreatedDate
        if (useSortOrder == null) {
            OpportunityLineItem oliSortCheck = new OpportunityLineItem();
            try {
                oliSortCheck = [select Id, OpportunityId, SortOrder, Sort_Order__c from OpportunityLineItem where OpportunityId = :theOpportunity.Id order by Sort_Order__c asc nulls last limit 1];
            } catch(Exception e) {
                system.debug('*****OpportunityExtension exception while determining sortorder to use = ' + e.getMessage());
            }
            if (oliSortCheck.Sort_Order__c != null) {
                useSortOrder = true;
            } else {
                useSortOrder = false;
            }
        }
        if (useSortOrder) {
            oliQueryString += ' ORDER BY Sort_Order__c ASC NULLS LAST LIMIT :numRows';
        } else {
            oliQueryString += ' ORDER BY CreatedDate ASC LIMIT :numRows';
        }

        // Load related Opportunity Line Items
        List<OpportunityLineItem> tmp = Database.Query(oliQueryString);
        /*
        List<OpportunityLineItem> tmp = [SELECT Amount_Discounted__c, Contract_SPO_Amount__c, CreatedById, Name, Actual_Product_Name__c, 
            CreatedDate, CW_Color__c, CW_Item_Description__c, CW_Size__c, Description, Direct_Current_Price__c, Product2Id, 
            Discount, Discount_Percent__c, DMMSSku__c, Drop_Ship_Amount__c, ELC__c, Est_Delivery_Date__c,
            Expected_Customer_Delivery_Date__c, Delivery_Date__c, Fulfillment_Method__c, Id, IsDeleted, Landed_Cost__c,
            LastModifiedById, LastModifiedDate, Line_Item_Total_List_Price__c, ListPrice, Manual_Distro_info__c,
            Margin__c, Notes__c, OpportunityId, Opportunity_Product__c, Percent_Discounted__c, PricebookEntryId,
            Price_Diff__c, Product_Margin__c, Product_Name__c, Product_Ship_Via__c, Quantity, Quote_Product_Name__c, Active__c,
            Requires_Handling_Fee__c, ServiceDate, SideMark__c, SKU_del__c, Subtotal, SystemModstamp, Total_ELC__c, TotalPrice, UnitPrice, Unit_Price__c, Update_ELC_total__c, SortOrder 
            FROM OpportunityLineItem WHERE OpportunityId = :theOpportunity.Id ORDER BY SortOrder ASC LIMIT :numRows];
            //FROM OpportunityLineItem WHERE OpportunityId = :theOpportunity.Id ORDER BY CreatedDate ASC LIMIT :numRows];
        */

        System.debug('Selected ' + tmp.size() + ' Opportunity Line Items for Opportunity ' + theOpportunity.Id);

        totalPriceMap = new Map<Id, OpportunityLineItem>();
        for (OpportunityLineItem oli : tmp) {
            
            // Save the original TotalPrice field to be reapplied upon save
            totalPriceMap.put(oli.Id, new OpportunityLineItem(TotalPrice = oli.TotalPrice));
            
            opportunityLineItems.add(new OpportunityLineItemWrapper(oli, this.thisOpportunityExtension, oli.Product_Name__c));
        }
        System.Debug('Value of opportunityLineItems' + opportunityLineItems);

        // Populate the additional fields on the Line Item Wrappers
        opportunityLineItems = populateWrappers(opportunityLineItems);
        for (Integer i=displaySet * rowsToDisplay; i<opportunityLineItems.size() && i<((displaySet * rowsToDisplay) + rowsToDisplay); i++) {
            oliDisplay.add(opportunityLineItems[i]);
        }
        pageNumber = displaySet + 1;
        totalPages = opportunityLineItems.size() / rowsToDisplay;
        if (math.mod(opportunityLineItems.size(), rowsToDisplay) > 0) {
            totalPages++;
        }
        
        // Get the total row count
        getLineItemCount();

        // Determine whether the "show more" link should be displayed
        this.showMoreLink = (lineItemCount>lineItemsDisplayed ? true : false);
    }
    
    public PageReference nextSet() {
        if ((displaySet + 1) * rowsToDisplay < opportunityLineItems.size()) {
            oliDisplay = new List<OpportunityLineItemWrapper>();
            displaySet++;
            pageNumber = displaySet + 1;
            for (Integer i=displaySet * rowsToDisplay; i<opportunityLineItems.size() && i<((displaySet * rowsToDisplay) + rowsToDisplay); i++) {
                oliDisplay.add(opportunityLineItems[i]);
            }
        }
        return null;
    }
    
    public PageReference previousSet() {
        if (displaySet - 1 >= 0) {
            oliDisplay = new List<OpportunityLineItemWrapper>();
            displaySet--;
            pageNumber = displaySet + 1;
            for (Integer i=displaySet * rowsToDisplay; i<opportunityLineItems.size() && i<((displaySet * rowsToDisplay) + rowsToDisplay); i++) {
                oliDisplay.add(opportunityLineItems[i]);
            }
        }
        return null;
    }
    
    public Boolean getShowNext() {
        if ((displaySet + 1) * rowsToDisplay < opportunityLineItems.size()) {
            return true;
        } else {
            return false;
        }
    }
    
    public Boolean getShowPrevious() {
        if (displaySet - 1 >= 0) {
            return true;
        } else {
            return false;
        }
    }
    
    public String getRowsPerPage() {
        return String.valueOf(rowsToDisplay);
    }
    
    public void setRowsPerPage(String rpp) {
        rowsToDisplay = Integer.valueOf(rpp);
        if (rowsToDisplay > opportunityLineItems.size()) {
            rowsToDisplay = opportunityLineItems.size();
        }
        if (rowsToDisplay < 5) {
            rowsToDisplay = 5;
        }
        system.debug('***** rowsToDisplay = ' + rowsToDisplay);
    }
    
    public PageReference rowsPerPageChanged() {
        oliDisplay = new List<OpportunityLineItemWrapper>();
        displaySet = 0;
        for (Integer i=displaySet * rowsToDisplay; i<opportunityLineItems.size() && i<((displaySet * rowsToDisplay) + rowsToDisplay); i++) {
            oliDisplay.add(opportunityLineItems[i]);
        }
        pageNumber = displaySet + 1;
        totalPages = opportunityLineItems.size() / rowsToDisplay;
        if (math.mod(opportunityLineItems.size(), rowsToDisplay) > 0) {
            totalPages++;
        }
        return null;
    }
    
    // Methods to support setting a fulfillment method to be applied globally
    public List<SelectOption> getffMethodList() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult dfr = OpportunityLineItem.Fulfillment_Method__c.getDescribe();
        List<Schema.PicklistEntry> pleList = dfr.getPicklistValues();
        
        options.add(new SelectOption('--None--', '--None--'));
        for (Schema.PicklistEntry ple :pleList) {
            options.add(new SelectOption(ple.getLabel(), ple.getLabel()));
        }
        return options;
    }
    
    String ffMethodSelection;
    
    public String getffMethodSelection() {
        return ffMethodSelection;
    }
    
    public void setffMethodSelection(String ffM) {
            this.ffMethodSelection = ffM;
    }
    
    public PageReference applyGlobalFulfillment() {
        
        if (String.isNotBlank(ffMethodSelection) && ffMethodSelection != '--None--') {
            for (OpportunityLineItemWrapper oliw :opportunityLineItems) {
                oliw.oli.Fulfillment_Method__c = ffMethodSelection;
                oliw.oli.Delivery_Date__c = calculateDeliveryDate(ffMethodSelection, oliw.product);
            }
            
            // Call the Made OLI Change method
            this.thisOpportunityExtension.madeOLIChange();
            
        } else {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Please enter a Fulfillment Method to apply to all lines.'));
        }
        return null;
    }
    
    public List<SelectOption> getffMethods() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult dfr = OpportunityLineItem.Fulfillment_Method__c.getDescribe();
        List<Schema.PicklistEntry> pleList = dfr.getPicklistValues();
        
        options.add(new SelectOption('--None--', '--None--'));
        options.add(new SelectOption('All', 'All'));
        for (Schema.PicklistEntry ple :pleList) {
            options.add(new SelectOption(ple.getLabel(), ple.getLabel()));
        }
        return options;
    }
    
    String ffDiscount;
    
    public String getffDiscount() {
        return ffDiscount;
    }
    
    public void setffDiscount(String ffM) {
            this.ffDiscount = ffM;
    }
    
    public Decimal glbDiscount = null;
    
    public String getGlobalDiscount() {
        return String.valueOf(glbDiscount);
    }
    
    public void setGlobalDiscount(String gd) {
        if (String.isNotBlank(gd)) {
            try {
                glbDiscount = Decimal.valueOf(gd);
            } catch(exception e) {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Invalid Global Discount number: ' + gd + '.'));
                glbDiscount = null;
            }
        } else {
            glbDiscount = null;
        }
    }
    
    public PageReference applyGlobalDiscount() {
        
        if (ffDiscount != '--None--' && String.isNotBlank(ffDiscount) && glbDiscount != null && glbDiscount >= 0 && glbDiscount <= 100) {
            for (OpportunityLineItemWrapper oliw :opportunityLineItems) {
                if (ffDiscount == 'All' || ffDiscount == oliw.oli.Fulfillment_Method__c) {
                    oliw.oli.Discount_Percent__c = glbDiscount;
                    
                    oliw.oli.UnitPrice = oliw.oli.ListPrice * (1 - (oliw.oli.Discount_Percent__c/100));
                    
                    if (oliw.oli.ELC__c == null) {
                        system.debug('The Opportunity Extension = ' + this.thisOpportunityExtension);
                        system.debug('This = ' + this);
                        this.thisOpportunityExtension.hasErrors = true;
                        this.thisOpportunityExtension.errorMessage = 'Product Id ' + oliw.oli.Product2Id + ' has a blank ELC. Please give your Salesforce administrator the Product Id:' + oliw.oli.Product2Id;
                        oliw.oli.Margin__c = 0;
                    } else {
                        if (oliw.oli.unitPrice == 0 || oliw.oli.unitPrice == null || oliw.oli.ELC__c == 0) {
                            oliw.oli.Margin__c = 0;
                        } else {
                            System.debug('Margin calculated as ' + (100*(oliw.oli.unitPrice - oliw.oli.ELC__c)/oliw.oli.unitPrice).setScale(2));
                            oliw.oli.Margin__c = (100*(oliw.oli.unitPrice - oliw.oli.ELC__c)/oliw.oli.unitPrice).setScale(2);
                        }
                    }
                    
                    // Set the Total Contract Price if the fields are not null
                    if ((oliw.oli.Quantity != null) && (oliw.oli.UnitPrice != null)) {
                        oliw.totalContractPrice = (oliw.oli.Quantity * oliw.oli.UnitPrice).setScale(2);
                    } else {
                        oliw.totalContractPrice = 0.00;
                        oliw.totalContractPrice.setScale(2);
                    }
                    oliw.oli.TotalPrice = oliw.totalContractPrice;
                    
                    // Call the Made OLI Change method
                    this.thisOpportunityExtension.madeOLIChange();
                }
            }
        } else {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Please enter a Global Discount that is greater than or equal to zero and less than or equal to 100, and select a Fulfillment Method.'));
        }
        return null;
    }
    
    String ffMargin;
    
    public String getffMargin() {
        return ffMargin;
    }
    
    public void setffMargin(String ffM) {
            this.ffMargin = ffM;
        }
    
    public Decimal glbMargin = null;
    
    public String getGlobalMargin() {
        return String.valueOf(glbMargin);
    }
    
    public void setGlobalMargin(String gm) {
        if (String.isNotBlank(gm)) {
            try {
                glbMargin = Decimal.valueOf(gm);
            } catch(exception e) {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Invalid Global Margin number: ' + gm + '.'));
                glbMargin = null;
            }
        } else {
            glbMargin = null;
        }
    }
    
    public PageReference applyGlobalMargin() {
        
        Map<Id, PricebookEntry> pbeMap;
        Map<Id, Product2> pMap;
        List<Id> pbeIds = new List<Id>();
        List<Id> pIds = new List<Id>();
        
        if (ffMargin != '--None--' && String.isNotBlank(ffMargin) && glbMargin != null && glbMargin >= 0 && glbMargin < 100) {
            for (OpportunityLineItemWrapper oliw :opportunityLineItems) {
                if (ffMargin == 'All' || ffMargin == oliw.oli.Fulfillment_Method__c) {
                    pbeIds.add(oliw.oli.PricebookEntryId);
                    pIds.add(oliw.oli.Product2Id);
                }
            }
            
            pbeMap = new Map<Id, PricebookEntry>([select Id, Name, Product2Id, UnitPrice, Product2.Member_Price__c from PricebookEntry where Id in :pbeIds]);
            pMap = new Map<Id, Product2>([select DMMSSku__c, ELC__c, Id from Product2 WHERE Id in :pIds]);
            
            for (OpportunityLineItemWrapper oliw :opportunityLineItems) {
                if (ffMargin == 'All' || ffMargin == oliw.oli.Fulfillment_Method__c) {
                    oliw.oli.Margin__c = glbMargin;
                    
                    // Ensure there is no error leftover from a previous attempt to change the Margin
                    oliw.thisOpportunityExtension.hasErrors = false;
                    oliw.thisOpportunityExtension.errorMessage = '';

                    // Populate Discount Percent, Unit Price and Total Contract Price
                    oliw.oli.UnitPrice = (pMap.get(oliw.oli.Product2Id).ELC__c / ((100 - oliw.oli.Margin__c) / 100)).setScale(2);
                    
                    // If the Unit Price is zero, set the Discount to 0 so that we do not get a "Divide by 0" error
                    if (oliw.oli.UnitPrice == 0) {
                        oliw.oli.Discount_Percent__c = 0;
                    } else {
                        oliw.oli.Discount_Percent__c = 100 - (100 * (oliw.oli.UnitPrice / pbeMap.get(oliw.oli.PricebookEntryId).UnitPrice)).setScale(2);
                    }
                    
                    oliw.totalContractPrice = (oliw.oli.Quantity * oliw.oli.UnitPrice).setScale(2);
                    oliw.oli.TotalPrice = oliw.totalContractPrice;
                    
                    // Call the Made OLI Change method
                    this.thisOpportunityExtension.madeOLIChange();
                }
            }
        } else {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Please enter a Global Margin that is greater than or equal to zero and less than 100, and select a Fulfillment Method.'));
        }
        return null;
    }
    
    public String oliColumnName {get; set;}
    public Boolean sortASC {get; set;}
    
    // Sort the list of opportunitylineitems based upon the column parameter provided
    public pageReference sortOLIcolumn() {
        String colName = null;
        String dataType = null;
        List<OpportunityLineItem> sortedList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        
        colName = ApexPages.currentPage().getParameters().get('columnSort');
        dataType = ApexPages.currentPage().getParameters().get('dataType');
        //system.debug('*****sortOLIcolumn 1 colName = ' + colName + ' oliColumnName = ' + oliColumnName + ' sortASC = ' + sortASC);
        
        for (OpportunityLineItemWrapper oliw :opportunityLineItems) {
            oliList.add(oliw.oli);
        }
        //system.debug('*****sortOLIcolumn oliList.size = ' + oliList.size());
        
        if (oliColumnName == colName) {
            sortASC = !sortASC;
        } else {
            oliColumnName = colName;
            sortASC = true;
        }
        //system.debug('*****sortOLIcolumn 2 colName = ' + colName + ' oliColumnName = ' + oliColumnName + ' sortASC = ' + sortASC);
        
        // First do the basic sort by Name field, then sort based upon the column parameter
        oliList.sort();
        sortedList = Utility.sObjSort(colName, dataType, sortASC, oliList);
        if (sortedList.size() == oliList.size()) {
            opportunityLineItems = new List<OpportunityLineItemWrapper>();
            for(OpportunityLineItem oli :sortedList) {
                opportunityLineItems.add(new OpportunityLineItemWrapper(oli, this.thisOpportunityExtension, oli.Product_Name__c));
            }
            
            // Populate the additional fields on the Line Item Wrappers
            opportunityLineItems = populateWrappers(opportunityLineItems);
            oliDisplay = new List<OpportunityLineItemWrapper>();
            displaySet = 0;
            for (Integer i=displaySet * rowsToDisplay; i<opportunityLineItems.size() && i<((displaySet * rowsToDisplay) + rowsToDisplay); i++) {
                oliDisplay.add(opportunityLineItems[i]);
            }
            pageNumber = displaySet + 1;
            totalPages = opportunityLineItems.size() / rowsToDisplay;
            if (math.mod(opportunityLineItems.size(), rowsToDisplay) > 0) {
                totalPages++;
            }
        }
        return null;
    }
    
    public PageReference madeOLIChange()
    {
        hasOLIChanged = true;
        oliColumnName = null;
        return null;
    }

    public PageReference isFullPage()
    {
        isFullPage = true;
        return null;
    }

    public PageReference isNotFullPage()
    {
        isFullPage = false;
        return null;
    }

	public Boolean getNegativeMargin() {
		Boolean isNegative = false;
		
		for (OpportunityLineItemWrapper oliw : opportunityLineItems) {
			if (oliw.oli.Margin__c < 0) {
				isNegative = true;
				break;
			}
		}
		
		return isNegative;
	}
	
	public Boolean getNewNegativeMargin() {
		Boolean isNegative = false;
		
		for (OpportunityLineItemWrapper oliw : newOpportunityLineItems) {
			if (oliw.oli.Margin__c < 0) {
				isNegative = true;
				break;
			}
		}

		return isNegative;
	}
    
    public PageReference applyOLIChanges()
    {
        List<OpportunityLineItem>   oli = new List<OpportunityLineItem>(); // Bulkify upsert

        try
        {
            for(OpportunityLineItemWrapper oliw : opportunityLineItems)
            {
                if(!oliw.isDeletedOLI)
                {
                    // reapply the original TotalPrice value to avoid an exception
                    oliw.oli.TotalPrice = totalPriceMap.get(oliw.oli.Id).TotalPrice;
                    oli.add(oliw.oli);
                }
            }

            upsert oli;

            loadOLIs();
            hasOLIChanged = false;
            hasErrors = false;
            errorMessage = '';
            isEditMode = false;
        }
        catch(DMLException e)
        {
            hasErrors = true;
            errorMessage = e.getMessage();
        }

        catch(Exception e)
        {
            hasErrors = true;
            errorMessage = e.getMessage();
        }

        return null;
    }

    public PageReference addOLI() {
        
        String retPage;
        
        if (onOLIpage) {
            retPage = 'oli';
        } else {
            retPage = 'opp';
        }
        
        //return the page reference;
        string url = '/p/opp/SelectSearch?addTo=' + theOpportunity.Id + '&retURL=%2F' + theOpportunity.Id + '&retPage=' + retPage;
        System.debug('Returning PageReference ' + url);
        return new PageReference(url);
    }

    public String calculateDeliveryDate(String fulfillmentMethod, Product2 p2) {
        
        String deliveryDate = '';
        Decimal plt = 0;
        Decimal slt = 0;
        Decimal shipVia = 0;
        Decimal early = 0;
        Decimal late = 0;
        Decimal dd = null;
        
        if (String.isNotBlank(fulfillmentMethod) && fulfillmentMethod != 'TBD' && fulfillmentMethod != 'Retail Inventory') {
            
            if (fulfillmentMethod == 'Contract Inventory') {
                if (p2.SKU_Ship_Via__c == '0' || p2.SKU_Ship_Via__c == '1' || p2.SKU_Ship_Via__c == '2' || p2.SKU_Ship_Via__c == '3') {
                    early = 7;
                    late = 10;
                } else {
                    dd = 14;
                }
                
            } else {
					
				plt = p2.Production_Lead_Time__c;
				slt = p2.Shipping_Lead_Time__c;
				if (plt == null) {
					plt = 0;
				}
				if (slt == null) {
					slt = 0;
				}
				if (p2.SKU_Ship_Via__c == '0' || p2.SKU_Ship_Via__c == '1' || p2.SKU_Ship_Via__c == '2' || p2.SKU_Ship_Via__c == '3') {
					shipVia = 7;
				} else {
					shipVia = 14;
				}
				dd = plt + slt + 7 + shipVia;
            }
            
            if (Date.newInstance(2016,11,1) <= system.today() && system.today() < Date.newInstance(2017,1,15)) {
            	if (p2.DropShip__c && (p2.Country_of_Origin__c == 'CHN' || p2.Country_of_Origin__c == 'VNM')) {
            		if (dd == null) {
            			dd = late + 42;
            		} else {
            			dd += 42;
            		}
            	}
            }
            
            if (dd == null) {
            	deliveryDate = String.valueOf(Integer.valueOf(early)) + '-' + String.valueOf(Integer.valueOf(late)) + ' Days';
            } else {
            	deliveryDate = String.valueOf(Integer.valueOf(Math.round(dd / 7))) + ' Weeks';
            }
        }
        return deliveryDate;
    }
    
    public OpportunityLineItemWrapper addNewOLI(PricebookEntry pbe)
    {
        System.debug('Adding new line item for Pricebook Entry: ' + pbe);
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = theOpportunity.Id;
        oli.PricebookEntryId = pbe.Id;
        oli.UnitPrice = pbe.UnitPrice;
        
        // Set default values for Fulfillment Method and Expected Delivery Date
        if (pbe.Product2.Name.endsWith('COM') || pbe.Product2.Name.endsWith('COL')) {
            oli.Fulfillment_Method__c = 'COM/COL';
        } else {
            if (pbe.Product2.Name.endsWith('TR')) {
                oli.Fulfillment_Method__c = 'Contract Inventory';
            } else {
                if (pbe.Product2.Name.startsWith('7')) {
                    oli.Fulfillment_Method__c = 'Custom';
                } else {
                    if (pbe.Product2.Dropship__c) {
                        oli.Fulfillment_Method__c = 'Drop Ship';
                    } else {
                        oli.Fulfillment_Method__c = 'Retail Inventory';
                    }
                }
            }
        }
        
        
        System.debug('The value is : ++++++++' +pbe.Product2);
        
        oli.Delivery_Date__c = calculateDeliveryDate(oli.Fulfillment_Method__c, pbe.Product2);
        
        System.debug('Creating new Opportunity Line Item with Opportunity Extension ' + thisOpportunityExtension);
        
        // Create the new Opportunity Line Item Wrapper and populate it with the OLI
        OpportunityLineItemWrapper oliw = new OpportunityLineItemWrapper(oli, thisOpportunityExtension, pbe.Product2.Name);
        oliw.memberPrice = pbe.Product2.Member_Price__c;
		     
        // Add the new wrapper to the list of new items
        System.debug('Adding Opportunity Line Item Wrapper: ' + oliw);
        this.newOpportunityLineItems.add(oliw);
        System.debug(this.newOpportunityLineItems.size() + ' new Opportunity Line Items now: ' + this.newOpportunityLineItems);
                
        this.madeOLIchange();

        return oliw;
    }

    public PageReference addOneProduct()
    {
        for (PricebookEntry pbe : availableProducts)
        {
            if ((String)pbe.Id==this.toSelect)
            {
                OpportunityLineItemWrapper oliw = addNewOLI(pbe);
                
                // Add the wrapper to a list for processing
                List<OpportunityLineItemWrapper> oliwList = new List<OpportunityLineItemWrapper>{oliw};
                
                // Pass the new wrapper in to populate additional fields
                oliwList = populateWrappers(oliwList);
                
                // Add the new wrapper to the List of new records
//              this.newOpportunityLineItems.add(oliwList[0]);
                 
                break;
            }

            if (this.newOpportunityLineItems.size() > 0)
            {
                this.showAddedProducts = true;
            } else {
                this.showAddedProducts = false;
            }

        system.debug('Show added products: ' + this.showAddedProducts);

        }

        return null;
    }

    public PageReference addAllProducts()
    {
        // Declare local variables
        List<OpportunityLineItemWrapper>    oliwList = new List<OpportunityLineItemWrapper>(); // A List of wrappers to be processed
        Set<Id>                             pbeIds = new Set<Id>(); // The IDs of the Pricebook Entries
        Set<Id>                             productIds = new Set<Id>(); // The IDs of the Products on the Pricebook Entries

        System.debug('Adding ' + availableProducts.size() + ' line items.');
        
        for (PricebookEntry pbe : availableProducts)
        {
            addNewOLI(pbe);
            pbeIds.add(pbe.Id);
            productIds.add(pbe.Product2Id);
        }

        // Populate the read-only variables for the line items
        pbes = new Map<Id, PricebookEntry>([SELECT Id, Product2Id, unitPrice, Product2.Member_Price__c FROM PricebookEntry WHERE Id IN :pbeIds]);
        products = new Map<Id, Product2>([SELECT Id, Direct_Current_Price__c, DMMSSku__c, SKU_Ship_Via__c FROM Product2 WHERE Id IN :productIds]);

        for (Integer i = 0; i < this.newOpportunityLineItems.size(); i++)
        {
            // Check to see if the record is one that was just added
            System.debug('Evaluating Line Item: ' + this.newOpportunityLineItems[i]);
            if (this.newOpportunityLineItems[i].directOriginalPrice == null ||
                this.newOpportunityLineItems[i].directCurrentPrice == null ||
                this.newOpportunityLineItems[i].productShipVia == null)
            {
                /*System.debug('pbes = ' + pbes);
                System.debug('this.newOpportunityLineItems[i].oli.PricebookEntryId = ' + this.newOpportunityLineItems[i].oli.PricebookEntryId);
                System.debug('pbes.get(this.newOpportunityLineItems[i].oli.PricebookEntryId) = ' + pbes.get(this.newOpportunityLineItems[i].oli.PricebookEntryId));
                if (pbes.containsKey(this.newOpportunityLineItems[i].oli.PricebookEntryId))
                {
                    this.newOpportunityLineItems[i].directOriginalPrice = pbes.get(this.newOpportunityLineItems[i].oli.PricebookEntryId).UnitPrice.setScale(2);
                }

                if (products.containsKey(pbes.get(this.newOpportunityLineItems[i].oli.PricebookEntryId).Product2Id))
                {
                    this.newOpportunityLineItems[i].directCurrentPrice = products.get(pbes.get(this.newOpportunityLineItems[i].oli.PricebookEntryId).Product2Id).Direct_Current_Price__c;
                    this.newOpportunityLineItems[i].productShipVia = products.get(pbes.get(this.newOpportunityLineItems[i].oli.PricebookEntryId).Product2Id).SKU_Ship_Via__c;
                }*/
                
                // Add the newly-added record to the list to be processed
                oliwList.add(this.newOpportunityLineItems[i]);
                
                System.debug('Line Item to be added: ' + this.newOpportunityLineItems[i].oli + ' ' + this.newOpportunityLineItems[i].productName);
            }   
        }
        
        // If there are records to pass in for processing then pass them in
        if (oliwList.size() > 0)
        {
            populateWrappers(oliwList);
            
        } // END IF there are records to pass in for processing then pass them in
        
        if (this.newOpportunityLineItems.size() > 0)
        {
            this.showAddedProducts = true;
        } else {
            this.showAddedProducts = false;
        }

        system.debug('Show added products: ' + this.showAddedProducts);
        system.debug('Show added products2: ' + showAddedProducts);

        return null;
    }

    public PageReference editOLI()
    {
        loadOLIs();
        hasOLIChanged = false;
        this.hasErrors = false;
        this.errorMessage = '';
        this.isEditMode = true;

        return null;
    }

    public PageReference getLineItemCount()
    {
        this.lineItemCount = [SELECT COUNT() FROM OpportunityLineItem WHERE OpportunityId = :theOpportunity.Id LIMIT 10000];
        
        // If there are more than 5 records then the display count is "5+" otherwise it is the count
        if (this.lineItemCount > 5)
        {
            this.lineItemCountDisplay = '5+';
        } else {
            this.lineItemCountDisplay = this.lineItemCount.format();
            
        } // END IF there are more than 5 records then the display count is "5+" otherwise it is the count
        
        return null;
    }

    public PageReference insertNewOLI()
    {
        List<OpportunityLineItem>   olis = new List<OpportunityLineItem>(); // Bulkify upsert

        for (OpportunityLineItemWrapper oliw : newOpportunityLineItems)
        {
            oliw.oli.TotalPrice = null;
            olis.add(oliw.oli);
        }

        System.debug('Inserting ' + olis.size() + ' Opportunity Line Items: ' + olis);

        try
        {
            insert olis;
            getLineItemCount();
            hasOLIChanged = false;
            hasErrors = false;
            errorMessage = '';
        }
        catch(DMLException e)
        {
            hasErrors = true;
            errorMessage = e.getMessage();
        }

        catch(Exception e)
        {
            hasErrors = true;
            errorMessage = e.getMessage();
        }

        if (hasErrors)
        {
            return null;
        } else {
            if (this.saveAndAddMore)
            {
                return null;
            } else {
                //return new PageReference('/' + theOpportunity.Id);
                PageReference pr;
                String retPage = ApexPages.currentPage().getParameters().get('retPage');
                if (retPage == 'oli') {
                    pr = new PageReference('/apex/OpportunityLineItems?id=' + theOpportunity.Id);
                } else {
                    pr = new PageReference('/' + theOpportunity.Id);
                }
                pr.setRedirect(true);
                return pr;
            }
        }
    }

    public PageReference saveAndAddMore()
    {
        // Declare local variables
        PageReference pr;
        
        this.saveAndAddMore = true;
        pr = insertNewOLI();
        this.saveAndAddMore = false;
        this.newOpportunityLineItems.clear();
        return pr;
    }
    
    public PageReference oliCancel()
    {
        loadOLIs();
        hasOLIChanged = false;
        this.hasErrors = false;
        this.errorMessage = '';
        this.isEditMode = false;

        return null;
    }

    public PageReference oliCancelAddNew()
    {
        PageReference pr;
        String retPage;
        newOpportunityLineItems.clear();
        hasOLIChanged = false;
        this.hasErrors = false;
        this.errorMessage = '';
        this.isEditMode = false;
        
        retPage = ApexPages.currentPage().getParameters().get('retPage');
        if (retPage == 'oli') {
            pr = new PageReference('/apex/OpportunityLineItems?id=' + theOpportunity.Id);
        } else {
            pr = new PageReference('/' + theOpportunity.Id);
        }
        pr.setRedirect(true);
        return pr;
        
        //return new PageReference('/' + theOpportunity.Id);
    }

    public List<OpportunityLineItemWrapper> populateWrappers (List<OpportunityLineItemWrapper> oliws)
    {
        // Declate local variables
        Set<Id>                 pbeIds = new Set<Id>(); // A Set of Pricebook Entry IDs for the Opportunity Line Items
        Map<Id, PricebookEntry> pbeMap; // A Map of Pricebook Entries for the OLIs
        Set<Id>                 productIds = new Set<Id>(); // A Set of Product IDs for the OLIs' Pricebook Entries
        Map<Id, Product2>       productMap; // A Map of Products for the OLIs' Pricebook Entries
        
        // Loop through the wrappers getting the Pricebook Entries for the OpportunityLineItems
        for (OpportunityLineItemWrapper oliw : oliws)
        {
            pbeIds.add(oliw.oli.PricebookEntryId);
            
        } // END LOOP through the wrappers getting the Pricebook Entries for the OpportunityLineItems
        
        // Get the Map of Pricebook Entries
        pbeMap = new Map<Id, PricebookEntry>([SELECT Id, Product2Id, UnitPrice, Product2.Member_Price__c FROM PricebookEntry WHERE Id IN :pbeIds]);
        
        // Loop through the Pricebook Enries creating a Set of Product2 Ids
        for (PricebookEntry pbe : pbeMap.values())
        {
            productIds.add(pbe.Product2Id);
            
        } // END LOOP through the Pricebook Enries creating a Set of Product2 Ids
        
        // Get the Map of Products
        productMap = new Map <Id, Product2>([SELECT Id, Direct_Current_Price__c, DMMSSku__c, ELC__c, SKU_Ship_Via__c, 
                Production_Lead_Time__c, Shipping_Lead_Time__c, DropShip__c, Country_of_Origin__c, Total_Quantity_On_Hand__c 
                FROM Product2 WHERE Id IN :productIds]);
        
        // Loop through the Wrappers populating field
        for (OpportunityLineItemWrapper oliw : oliws)
        {
            // Populate the PBE
            if (pbeMap.containsKey(oliw.oli.PricebookEntryId))
            {
                oliw.pbe = pbeMap.get(oliw.oli.PricebookEntryId);
                
                // Populate the Product
                if (productMap.containsKey(oliw.pbe.Product2Id))
                {
                    oliw.product = productMap.get(oliw.pbe.Product2Id);
                    System.debug('Setting Direct Current Price to ' + oliw.product.Direct_Current_Price__c);
                    oliw.directCurrentPrice = oliw.product.Direct_Current_Price__c;
                    System.debug('Setting Direct Original Price to ' + oliw.pbe.UnitPrice);
                    oliw.directOriginalPrice = oliw.pbe.UnitPrice;
                    System.debug('Setting Discount based on OLI Unit Price ' + oliw.oli.UnitPrice + ' and PBE Unit Price ' + oliw.pbe.UnitPrice);
                    
                    // If the Unit Price is zero, set the Discount to 0 so that we do not get a "Divide by 0" error
                    if (oliw.pbe.UnitPrice == 0)
                    {
                        oliw.oli.Discount_Percent__c = 0;
                    } else {
                        oliw.oli.Discount_Percent__c = 100 - (100*(oliw.oli.UnitPrice/oliw.pbe.UnitPrice)).setScale(2);
                    } // END IF the Unit Price is zero, set the Discount to 0 so that we do not get a "Divide by 0" error

                    oliw.oli.Margin__c = oliw.calculateMargin(oliw.oli, oliw.product).setScale(2);
                    oliw.productShipVia = oliw.product.SKU_Ship_Via__c;
                } else {
                    UtilityFunctions.sendEmail('Missing Product', 'Product missing for ' + oliw.pbe, new List<String>{'salesforce@restorationhardware.com'});
                }
            } else {
                UtilityFunctions.sendEmail('Missing PricebookEntry', 'PricebookEntry missing for ' + oliw.oli, new List<String>{'salesforce@restorationhardware.com'});
            }
            
        }
        
        return oliws;
    }
    
    public pageReference redirect()
    {
        return new PageReference('/apex/AddProduct?id=' + this.theOpportunity.id);
    }

    public PageReference sortOLI()
    {
        return new PageReference('/oppitm/lineitemsort.jsp?id=' + this.theOpportunity.id + '&retURL=%2F' + this.theOpportunity.id);
    }
    
    public void updateAvailableList() {

        List<String>    searchStrings = new List<String>(); // An array of search terms

        // We dynamically build a query string and exclude items already in the shopping cart
        //String query = 'SELECT Id, Pricebook2Id, IsActive, Product2.Actual_Product_Name__c, Product2.Name, Product2.Family, Product2.IsActive, Product2.Description, UnitPrice FROM PricebookEntry where IsActive=true and Pricebook2Id = \'' + this.theOpportunity.Pricebook2Id + '\'';
        String query = 'SELECT Id, Pricebook2Id, IsActive, Product2.Actual_Product_Name__c, Product2.Name, Product2.Family, Product2.IsActive, Product2.Description, UnitPrice, Product2.Country_of_Origin__c, Product2.Total_Quantity_On_Hand__c, Product2.Dropship__c, Product2.Production_Lead_Time__c, Product2.Shipping_Lead_Time__c, Product2.SKU_Ship_Via__c, Product2.Member_Price__c FROM PricebookEntry where IsActive=true and Pricebook2Id = \'' + this.theOpportunity.Pricebook2Id + '\'';

        if(multipleCurrencies)
            query += ' and CurrencyIsoCode = \'' + this.theOpportunity.get('currencyIsoCode') + '\'';

        // modify this to search other fields if desired
        if(searchString!=null){

            System.debug('The search string is ' + searchString);
            query+= ' and (';

            // Escape single quotes in case any were entered in to the search terms
            searchString = String.escapeSingleQuotes(searchString);
            
            // Split the search terms in case there are comma-separated terms
            searchStrings = searchString.split(',');

            /*
            // Loop through the search terms building the remainder of the query
            for (string s : searchStrings)
            {
                query += 'Product2.Name LIKE \'%' + s + '%\' OR ';
                query += 'Product2.ContractOnlySKU__c LIKE \'%' + s + '%\' OR ';
                query += 'Product2.Core_Cross_Reference_SKU__c LIKE \'%' + s + '%\' OR ';    

            } // END LOOP through the search terms building the remainder of the query
            */
            
            
            // Loop through the search terms building the remainder of the query
            for (string s : searchStrings)
            {
                /*
                query += 'Product2.Name = \'' + s + '\' OR ';
                query += 'Product2.ContractOnlySKU__c = \'' + s + '\' OR ';
                query += 'Product2.Core_Cross_Reference_SKU__c = \'' + s + '\' OR ';
                */
                query += 'Product2.SKU_Search__c LIKE \'%' + s + '%\' OR ';

            } // END LOOP through the search terms building the remainder of the query
            
            

            // Strip out the trailing ' OR '
            query = query.removeEnd(' OR ');

            // Add the terminating parenthesis
            query += ')';
        }

        Set<Id> selectedEntries = new Set<Id>();
        for(OpportunityLineItemWrapper oliw : newOpportunityLineItems){
            selectedEntries.add(oliw.oli.PricebookEntryId);
        }

/* Commented out 8/12/13 to enable users to add same product more than once
        // If there are products already selected then exclude them
        if(selectedEntries.size()>0){
            String tempFilter = ' AND Id NOT IN (';
            for(Id i : selectedEntries){
                tempFilter+= '\'' + (String)i + '\',';
            }
            String extraFilter = tempFilter.substring(0,tempFilter.length()-1);
            extraFilter+= ')';

            query+= extraFilter;

        } // END IF there are products already selected then exclude them
*/
        query+= ' ORDER BY Product2.Name';
        query+= ' LIMIT 101';

        system.debug('The search query is: ' + query);
        availableProducts = database.query(query);

        // We only display up to 100 results... if there are more than we let the user know (see vf page)
        if(availableProducts.size()==101){
            availableProducts.remove(100);
            overLimit = true;
        }
        else{
            overLimit=false;
        }
        
        // Set the boolean to indicate whether the Add All Selected button should be enabled
        if (availableProducts.size() > 0)
        {
            this.hasSearchResults = true;
        } else {
            this.hasSearchResults = false;
        }
    }

    public class OpportunityLineItemWrapper
    {
        public decimal                  directCurrentPrice {get; set;}
        public decimal                  directOriginalPrice {get; set;}
        public boolean                  isDeletedOLI {get; set;}
        public OpportunityLineItem      oli {get; set;}
        public PricebookEntry           pbe {get; set;}
        public Product2                 product {get; set;}
        public string                   productName {get; set;}
        public string                   productShipVia {get; set;}
        private OpportunityExtension    thisOpportunityExtension;
        public decimal                  totalContractPrice {get; set;}
        public decimal                  memberPrice {get; set;}

        public OpportunityLineItemWrapper(OpportunityLineItem c, OpportunityExtension oe, string productName)
        {
            this.thisOpportunityExtension = oe;
//          pbe = ([SELECT Id, Product2Id, UnitPrice FROM PricebookEntry WHERE Id = :c.PricebookEntryId LIMIT 1]);
//          product = ([SELECT Id, Direct_Current_Price__c, DMMSSku__c, ELC__c, SKU_Ship_Via__c FROM Product2 WHERE Id = :pbe.Product2Id LIMIT 1]);
//          System.debug('Setting Direct Current Price to ' + product.Direct_Current_Price__c);
//          this.directCurrentPrice = product.Direct_Current_Price__c;
//          System.debug('Setting Direct Original Price to ' + pbe.UnitPrice);
//          this.directOriginalPrice = pbe.UnitPrice;
            this.oli = c;
//          System.debug('Setting Discount based on OLI Unit Price ' + oli.UnitPrice + ' and PBE Unit Price ' + pbe.UnitPrice);
//          this.oli.Discount_Percent__c = 100 - (100*(oli.UnitPrice/pbe.UnitPrice)).setScale(2);
//          this.oli.Margin__c = this.calculateMargin(oli, product).setScale(2);
            if (this.oli.Quantity == null)
            {
                this.oli.Quantity = 1;
            }
            this.isDeletedOLI = false;
            this.productName = productName;
//          this.productShipVia = product.SKU_Ship_Via__c;

            // Set the Total Contract Price if the fields are not null
            if ((this.oli.Quantity != null) && (this.oli.UnitPrice != null))
            {
                this.totalContractPrice = (this.oli.Quantity * this.oli.UnitPrice).setScale(2);
            } else {
                this.totalContractPrice = 0.00;
                this.totalContractPrice.setScale(2);
            } // END IF - Set the Total Contract Price if the fields are not null
            this.oli.TotalPrice = this.totalContractPrice;
        }

        public decimal calculateMargin(OpportunityLineItem oli, Product2 p)
        {
            if (p.ELC__c == null)
            {
                System.debug('The Opportunity Extension = ' + this.thisOpportunityExtension);
                System.debug('This = ' + this);
                this.thisOpportunityExtension.hasErrors = true;
                this.thisOpportunityExtension.errorMessage = 'Product Id ' + p.Id + ' has a blank ELC. Please give your Salesforce administrator the Product Id:' + p.Id;
                return 0;
            } else {
                if (oli.unitPrice == 0 || oli.unitPrice == null || p.ELC__c ==0)
                {
                    return 0;
                } else {
                    System.debug('Margin calculated as ' + (100*(oli.unitPrice - p.ELC__c)/oli.unitPrice).setScale(2));
                    return (100*(oli.unitPrice - p.ELC__c)/oli.unitPrice).setScale(2);
                }
            }
        }

        public decimal calculateUnitPrice (OpportunityLineItem oli, PricebookEntry pbe)
        {
            return pbe.UnitPrice * (1 - (oli.Discount_Percent__c/100));
        }

        public PageReference deleteOLI()
        {
            try
            {
                delete oli;
                this.thisOpportunityExtension.loadOLIs();
                this.thisOpportunityExtension.hasErrors = false;
                this.thisOpportunityExtension.errorMessage = '';

            }
            catch (Exception e)
            {
                this.thisOpportunityExtension.hasErrors = true;
                this.thisOpportunityExtension.errorMessage = e.getMessage();
            }

            return null;
        }
        
        // Calculate Unit Price and Margin and set the OLI Changed boolean if the Discount Percent has changed
        public PageReference discountPctChanged()
        {

            // Write status to the debug log
            System.debug('Setting Unit Price, Margin and Total Contract Price for ' + oli);
            
            // If the Discount > 100, throw an error otherwise process
            if (this.oli.Discount_Percent__c > 100)
            {
                this.thisOpportunityExtension.hasErrors = true;
                this.thisOpportunityExtension.errorMessage = 'Discount cannot be greater than 100. Please enter a smaller Discount.';

            } else if (this.oli.Discount_Percent__c < 0) {

                this.thisOpportunityExtension.hasErrors = true;
                this.thisOpportunityExtension.errorMessage = 'Discount cannot be less than 0. Please enter a Discount between 0 and 100.';

            } else {
				this.thisOpportunityExtension.hasErrors = false;
				this.thisOpportunityExtension.errorMessage = '';
				
            	// Initialize a Pricebook Entry and a Product variable
            	PricebookEntry pbe = new PricebookEntry();
            	Product2 p = new Product2();
            	
            	// Get the Pricebook Entry and Product
            	pbe = ([SELECT Id, Name, Product2Id, UnitPrice, Product2.Member_Price__c FROM PricebookEntry WHERE Id = :oli.PricebookEntryId]);
            	p = ([SELECT DMMSSku__c, ELC__c, Id FROM Product2 WHERE Id = :pbe.Product2Id LIMIT 1]);
				
            	// Write status to the debug log
            	System.debug('Pricebook Entry search result: ' + pbe);
            	System.debug('Product search result: ' + p);
            	
            	// If the Discount Percent was left blank then set it to 0, so that we don't get a Null Pointer Exception
            	if (this.oli.Discount_Percent__c == null)
            	{
                	this.oli.Discount_Percent__c = 0;
                	
            	} // END IF the Discount Percent was left blank then set it to 0, so that we don't get a Null Pointer Exception
            	
            	// Populate Unit Price, Margin and Total Contract Price
            	this.oli.UnitPrice = this.calculateUnitPrice(oli, pbe);
            	this.oli.Margin__c = this.calculateMargin(oli, p);
            	
            	// Set the Total Contract Price if the fields are not null
            	if ((this.oli.Quantity != null) && (this.oli.UnitPrice != null))
            	{
                	this.totalContractPrice = (this.oli.Quantity * this.oli.UnitPrice).setScale(2);
            	} else {
                	this.totalContractPrice = 0.00;
                	this.totalContractPrice.setScale(2);
            	} // END IF - Set the Total Contract Price if the fields are not null
            	this.oli.TotalPrice = this.totalContractPrice;
				
            	// Call the Made OLI Change method
            	this.thisOpportunityExtension.madeOLIChange();
            }
            
            return null;
        }

        public void unitPriceChanged()
        {
			//Decimal discountPct;
			
            // Write status to the debug log
            System.debug('Setting Discount Percent, Margin and Total Contract Price for ' + oli);

            // Initialize a Pricebook Entry and a Product variable
            PricebookEntry pbe = new PricebookEntry();
            Product2 p = new Product2();

            // Get the Pricebook Entry and Product
            pbe = ([SELECT Id, Name, Product2Id, UnitPrice, Product2.Member_Price__c FROM PricebookEntry WHERE Id = :oli.PricebookEntryId]);
            p = ([SELECT DMMSSku__c, ELC__c, Id FROM Product2 WHERE Id = :pbe.Product2Id LIMIT 1]);

            // Write status to the debug log
            System.debug('Pricebook Entry search result: ' + pbe);
            System.debug('Product search result: ' + p);

            // If the Unit Price was left blank then set it to 0, so that we don't get a Null Pointer Exception
            if (this.oli.UnitPrice == null)
            {
                this.oli.UnitPrice = 0;
                
            } // END IF the Unit Price was left blank then set it to 0, so that we don't get a Null Pointer Exception
            
            // Populate Discount Percent, Margin and Total Contract Price
            
            // If the Unit Price is zero, set the Discount to 0 so that we do not get a "Divide by 0" error
            if (pbe.UnitPrice == 0)
            {
                //discountPct = 0;
                this.oli.Discount_Percent__c = 0;
            } else {
                //discountPct = 100 - (100*(oli.UnitPrice/pbe.UnitPrice)).setScale(2);
                this.oli.Discount_Percent__c = 100 - (100*(oli.UnitPrice/pbe.UnitPrice)).setScale(2);
            } // END IF the Unit Price is zero, set the Discount to 0 so that we do not get a "Divide by 0" error
            
			/*
			// Handle situation where pricebook unitprice is only place holder (usually $1.00)
			if (discountPct <= -1000) {
				discountPct = 0;
			}
			this.oli.Discount_Percent__c = discountPct;
            */
            
            this.oli.Margin__c = this.calculateMargin(oli, p);

            // Set the Total Contract Price if the fields are not null
            if ((this.oli.Quantity != null) && (this.oli.UnitPrice != null))
            {
                this.totalContractPrice = (this.oli.Quantity * this.oli.UnitPrice).setScale(2);
            } else {
                this.totalContractPrice = 0.00;
                this.totalContractPrice.setScale(2);
            } // END IF - Set the Total Contract Price if the fields are not null
            this.oli.TotalPrice = this.totalContractPrice;

            // Call the Made OLI Change method
            this.thisOpportunityExtension.madeOLIChange();
        }

        public PageReference quantityChanged()
        {

            // Write status to the debug log
            System.debug('Setting Total Contract Price for ' + this.oli);

            // Set the Total Contract Price if the fields are not null
            if ((this.oli.Quantity != null) && (this.oli.UnitPrice != null))
            {
                this.totalContractPrice = (this.oli.Quantity * this.oli.UnitPrice).setScale(2);
            } else {
                this.totalContractPrice = 0.00;
                this.totalContractPrice.setScale(2);
            } // END IF - Set the Total Contract Price if the fields are not null
            this.oli.TotalPrice = this.totalContractPrice;

            System.debug('Total Contract Price set to ' + this.totalContractPrice);

            // Call the Made OLI Change method
            this.thisOpportunityExtension.madeOLIChange();

            return null;
        }

        public PageReference marginChanged()
        {

            // If the Margin >= 100, throw an error otherwise process
            if (this.oli.Margin__c >= 100)
            {
                this.thisOpportunityExtension.hasErrors = true;
                this.thisOpportunityExtension.errorMessage = 'Margin cannot be equal to or greater than 100. Please enter a lower Margin.';

            } else if (this.oli.Margin__c < 0) {

                this.thisOpportunityExtension.hasErrors = true;
                this.thisOpportunityExtension.errorMessage = 'Margin cannot be less than 0. Please enter a Margin between 0 and 100.';

            } else {

                // If the Margin was left blank then set it to 0, so that we don't get a Null Pointer Exception
                if (this.oli.Margin__c == null)
                {
                    this.oli.Margin__c = 0;
                    
                } // END IF the Unit Price was left blank then set it to 0, so that we don't get a Null Pointer Exception
                
                // Ensure there is no error leftover from a previous attempt to change the Margin
                this.thisOpportunityExtension.hasErrors = false;
                this.thisOpportunityExtension.errorMessage = '';

                // Write status to the debug log
                System.debug('Setting Discount Percent, Unit Price and Total Contract Price for ' + oli);

                // Initialize a Pricebook Entry and a Product variable
                PricebookEntry pbe = new PricebookEntry();
                Product2 p = new Product2();

                // Get the Pricebook Entry and Product
                pbe = ([SELECT Id, Name, Product2Id, UnitPrice, Product2.Member_Price__c FROM PricebookEntry WHERE Id = :oli.PricebookEntryId]);
                p = ([SELECT DMMSSku__c, ELC__c, Id FROM Product2 WHERE Id = :pbe.Product2Id LIMIT 1]);

                // Write status to the debug log
                System.debug('Pricebook Entry search result: ' + pbe);
                System.debug('Product search result: ' + p);

                // Populate Discount Percent, Unit Price and Total Contract Price
                this.oli.unitPrice = (p.ELC__c / ((100 - this.oli.Margin__c) / 100)).setScale(2);
                
                // If the Unit Price is zero, set the Discount to 0 so that we do not get a "Divide by 0" error
                if (pbe.UnitPrice == 0)
                {
                    this.oli.Discount_Percent__c = 0;
                } else {
                    this.oli.Discount_Percent__c = 100 - (100 * (this.oli.UnitPrice / pbe.UnitPrice)).setScale(2);
                } // END IF the Unit Price is zero, set the Discount to 0 so that we do not get a "Divide by 0" error
            
                this.totalContractPrice = (this.oli.Quantity * this.oli.unitPrice).setScale(2);
                this.oli.TotalPrice = this.totalContractPrice;

                // Call the Made OLI Change method
                this.thisOpportunityExtension.madeOLIChange();

            } // END IF the Margin > 100, throw an error otherwise proceed.

            return null;
        }
        
		public PageReference fulFillmentChanged() {
			
			// Get the Pricebook Entry and Product
			PricebookEntry pbe = new PricebookEntry();
			Product2 p2 = new Product2();
			pbe = [select Id, Name, Product2Id, UnitPrice, Product2.Member_Price__c from PricebookEntry where Id = :this.oli.PricebookEntryId limit 1];
			p2 = [select Id, Name, SKU_Ship_Via__c, Production_Lead_Time__c, Shipping_Lead_Time__c, DropShip__c, Country_of_Origin__c, Total_Quantity_On_Hand__c from Product2 where Id = :pbe.Product2Id limit 1];
			
			// Calculate the expected delivery date
			this.oli.Delivery_Date__c = this.thisOpportunityExtension.calculateDeliveryDate(this.oli.Fulfillment_Method__c, p2);
			
			// Call the Made OLI Change method
			this.thisOpportunityExtension.madeOLIChange();
			
			return null;
		}
    }
}