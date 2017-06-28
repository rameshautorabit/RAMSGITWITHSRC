public with sharing class OperationsRequestLineItemCtlExt {
	
	/*
     *  Operations Request Line Item controller extension - methods to support selection of multiple 
     *	OpportunityLineItem or Product2 records for creation of new Operations Request Line Item records.
     *
     */
    
	ApexPages.StandardController stdController;
	
	private String orId;
	private String retURL;
	private List<Operations_Request_Line_Item__c> opReqLineItemList;
	private List<OpportunityLineItem> oppLineItemList;
	private Integer minDisplayRows = 2;
	private Integer defaultDisplayRows = 10;
	private String sortDir;
	
	public Operations_Request__c opReq {get; set;}
	public String productSearchString {get; set;}
	public Boolean fatalError {get; set;}
	public Boolean noMore {get; set;}
	public Boolean isOpportunity {get; set;}
	public Boolean productView {get; set;}
	public Boolean disableToggle {get; set;}
	public Map<Id, Product2> productMap {get; set;}
	public Map<Id, Product2> newProductMap {get; set;}
	public Boolean overLimit {get; set;}
	public Boolean hasSearchResults {get; set;}
	public Boolean hasSelectedResults {get; set;}
	public String toSelect {get; set;}
	public Integer displaySet {get; set;}
    public Integer pageNumber {get; set;}
    public Integer totalPages {get; set;}
    public Integer rowsToDisplay {get; set;}
    public String oliColumnName {get; set;}
    public Boolean sortASC {get; set;}
	
	// Constructor
	public OperationsRequestLineItemCtlExt(ApexPages.StandardController stdController) {
		
		fatalError = false;
		noMore = false;
		disableToggle = false;
		isOpportunity = true;
		productView = false;
		overLimit = false;
		hasSearchResults = false;
		hasSelectedResults = false;
		productMap = new Map<Id, Product2>();
		newProductMap = new Map<Id, Product2>();
		opReq = new Operations_Request__c();
		opReqLineItemList = new List<Operations_Request_Line_Item__c>();
		oppLineItemList = new List<OpportunityLineItem>();
		
		// Initialize display variables
		rowsToDisplay = defaultDisplayRows;
		displaySet = 0;
		pageNumber = 1;
		totalPages = 1;
		oliColumnName = 'Product2.Name';
		sortASC = true;
		sortDir = 'ASC';
		
		orId = ApexPages.currentPage().getParameters().get('orId');
		retURL = ApexPages.currentPage().getParameters().get('retURL');
		
		if (String.isNotBlank(orId) && String.isNotBlank(retURL)) {
			try {
				opReq = [select Id, Name, RecordTypeId, Opportunity__c from Operations_Request__c where Id = :orId];
				Map<Id, RecordTypeInfo> rtOpRecByIdMap = Schema.SObjectType.Operations_Request__c.getRecordTypeInfosById();
				if (!rtOpRecByIdMap.containsKey(opReq.RecordTypeId)) {
					ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Operations Request has illegal record type.'));
					fatalError = true;
				} else {
					initAvailableList(true);
					if (noMore) {
						ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Cannot add operations request line items. Product Information operations requests cannot have more than one operations request line item.'));
						fatalError = true;
					}
				}
			} catch(Exception e) {
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Fatal exception: ' + e.getMessage()));
				fatalError = true;
			}
		} else {
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Invalid page parameters.'));
			fatalError = true;
		}
	}
	
	// Inner class for OpportunityLineItem selection
	public class SelectOpportunityLineItemClass {
		public Boolean selected {get; set;}
		public OpportunityLineItem oppLineItem {get; set;}
		public SelectOpportunityLineItemClass(Boolean selected, OpportunityLineItem oppLineItem) {
			this.selected = selected;
			this.oppLineItem = oppLineItem;
		}
	}
	
	List<SelectOpportunityLineItemClass> availableOppLineItems = new List<SelectOpportunityLineItemClass>();
	List<SelectOpportunityLineItemClass> displayOppLineItems = new List<SelectOpportunityLineItemClass>();
	List<SelectOpportunityLineItemClass> selectedOppLineItems = new List<SelectOpportunityLineItemClass>();
	
	// Initialize the list of opportunity line items that can be selected and products that have been selected
	private void initAvailableList(Boolean clearSelected) {
		String queryString;
		String oliIds;
		
		availableOppLineItems.clear();
		
		Map<Id, Schema.RecordTypeInfo> rtByIdMap = Schema.SObjectType.Operations_Request__c.getRecordTypeInfosById();
		opReqLineItemList = [select Id, Name, Operations_Request__c, Opportunity_Product__c, Opportunity_Product_Id__c, Product__c 
				from Operations_Request_Line_Item__c where Operations_Request__c = :opReq.Id];
		
		if (rtByIdMap.containsKey(opReq.RecordTypeId) && rtByIdMap.get(opReq.RecordTypeId).getName() == 'Product Information') {
			if (opReqLineItemList.size() >= 1) {
				noMore = true;
			}
		}
		
		if (opReq.Opportunity__c != null) {
			
			// build the query string for reading the opportunity products that are available to be added as operations request line items
			opReqLineItemList = [select Id, Name, Operations_Request__c, Opportunity_Product__c, Opportunity_Product_Id__c, Product__c 
					from Operations_Request_Line_Item__c where Operations_Request__c = :opReq.Id];
			
			oliIds = '(';
			if (!opReqLineItemList.isEmpty()) {
				for (Operations_Request_Line_Item__c orli :opReqLineItemList) {
					if (String.isNotBlank(orli.Opportunity_Product_Id__c)) {
						oliIds += '\'' + orli.Opportunity_Product_Id__c + '\',';
					}
				}
			}
			oliIds = oliIds.removeEnd(',');
			oliIds += ')';
			
			queryString = 'select Id, OpportunityId, Quantity, Fulfillment_Method__c, Notes__c, Customer_Location__c, Customer_Spec__c, Product_Ship_Via__c, Product2Id, Product2.Name, Product2.Actual_Product_Name__c from OpportunityLineItem where OpportunityId = \'' + opReq.Opportunity__c + '\'';
			if (oliIds != '()') {
				queryString += ' and (not Id in ' + oliIds + ')';
			}
			queryString += ' order by ' + oliColumnName + ' ' + sortDir + ' nulls last';
			
			oppLineItemList = Database.query(queryString);
			
			for (OpportunityLineItem oli :oppLineItemList) {
				availableOppLineItems.add(new SelectOpportunityLineItemClass(false, oli));
			}
			
			// Set display variables and list of selected items
			setRowsPerPage(String.valueOf(rowsToDisplay));
			PageReference pr = rowsPerPageChanged();
			if (availableOppLineItems.isEmpty()) {
				selectedOppLineItems.clear();
				isOpportunity = false;
				productView = true;
				disableToggle = true;
				hasSelectedResults = false;
			} else {
				if (clearSelected) {
					selectedOppLineItems.clear();
				} else {
					for (SelectOpportunityLineItemClass soli :selectedOppLineItems) {
						for (SelectOpportunityLineItemClass aoli :availableOppLineItems) {
							if (aoli.oppLineItem.Id == soli.oppLineItem.Id) {
								aoli.selected = true;
							}
						}
					}
				}
				
				isOpportunity = true;
				disableToggle = !selectedOppLineItems.isEmpty();
				hasSelectedResults = disableToggle;
			}
			
		} else {
			
			selectedOppLineItems.clear();
			isOpportunity = false;
			productView = true;
			disableToggle = true;
			hasSelectedResults = false;
		}
	}
	
	// Sort the list of opportunitylineitems based upon the column parameter provided
	public pageReference sortOLIcolumn() {
        String colName = null;
		
		colName = ApexPages.currentPage().getParameters().get('columnSort');
		if (colName == oliColumnName) {
			sortASC = !sortASC;
		} else {
			sortASC = true;
			oliColumnName = colName;
		}
		sortDir = sortASC ? 'ASC' : 'DESC';
		
		initAvailableList(false);
		
		return null;
	}
	
	// Return the list of available and selected opportunity line items
	public List<SelectOpportunityLineItemClass> getOppLineItems() {
		return displayOppLineItems;
	}
	
	public List<SelectOpportunityLineItemClass> getselectedOppLineItems() {
        List<SelectOpportunityLineItemClass> selectedList = null;
        if (selectedOppLineItems.size() > 0) {
            selectedList = selectedOppLineItems;
        }
        return selectedList;
    }
	
	// Record the selected opportunity line items
	public PageReference getSelected() {
		selectedOppLineItems.clear();
		for (SelectOpportunityLineItemClass soli :availableOppLineItems) {
			if (soli.selected) {
				selectedOppLineItems.add(soli);
			}
		}
		
		disableToggle = selectedOppLineItems.isEmpty() ? false : true;
		hasSelectedResults = disableToggle;
		return null;
	}
	
	// Opportunity Line Items pagination methods
	public PageReference firstSet() {
		displayOppLineItems.clear();
		displaySet = 0;
		pageNumber = displaySet + 1;
		for (Integer i=displaySet * rowsToDisplay; i<availableOppLineItems.size() && i<((displaySet * rowsToDisplay) + rowsToDisplay); i++) {
			displayOppLineItems.add(availableOppLineItems[i]);
		}
        return null;
    }
	
	public PageReference nextSet() {
        if ((displaySet + 1) * rowsToDisplay < availableOppLineItems.size()) {
            displayOppLineItems.clear();
            displaySet++;
            pageNumber = displaySet + 1;
            for (Integer i=displaySet * rowsToDisplay; i<availableOppLineItems.size() && i<((displaySet * rowsToDisplay) + rowsToDisplay); i++) {
                displayOppLineItems.add(availableOppLineItems[i]);
            }
        }
        return null;
    }
    
    public PageReference previousSet() {
        if (displaySet - 1 >= 0) {
            displayOppLineItems.clear();
            displaySet--;
            pageNumber = displaySet + 1;
            for (Integer i=displaySet * rowsToDisplay; i<availableOppLineItems.size() && i<((displaySet * rowsToDisplay) + rowsToDisplay); i++) {
                displayOppLineItems.add(availableOppLineItems[i]);
            }
        }
        return null;
    }
	
	public PageReference lastSet() {
		displayOppLineItems.clear();
		displaySet = totalPages > 1 ? totalPages - 1 : 0;
		pageNumber = displaySet + 1;
		for (Integer i=displaySet * rowsToDisplay; i<availableOppLineItems.size() && i<((displaySet * rowsToDisplay) + rowsToDisplay); i++) {
			displayOppLineItems.add(availableOppLineItems[i]);
        }
        return null;
    }
    
    public String getRowsPerPage() {
        return String.valueOf(rowsToDisplay);
    }
    
    public void setRowsPerPage(String rpp) {
        rowsToDisplay = Integer.valueOf(rpp);
        if (rowsToDisplay > availableOppLineItems.size()) {
            rowsToDisplay = availableOppLineItems.size();
        }
        if (rowsToDisplay < minDisplayRows) {
            rowsToDisplay = minDisplayRows;
        }
    }
    
    public PageReference rowsPerPageChanged() {
        displayOppLineItems.clear();
        displaySet = 0;
        for (Integer i=displaySet * rowsToDisplay; i<availableOppLineItems.size() && i<((displaySet * rowsToDisplay) + rowsToDisplay); i++) {
            displayOppLineItems.add(availableOppLineItems[i]);
        }
        pageNumber = displaySet + 1;
        totalPages = availableOppLineItems.size() / rowsToDisplay;
        if (math.mod(availableOppLineItems.size(), rowsToDisplay) > 0) {
            totalPages++;
        }
        return null;
    }
	
	// Toggle page view between Opportunity Product and Product selection
	public PageReference toggleView() {
		if (isOpportunity) {
			productView = !productView;
			if (!productView) {
				initAvailableList(true);
			}
		}
		return null;
	}
	
	public PageReference cancel() {
		PageReference pr;
		if (String.isBlank(retURL)) {
			pr = new PageReference('/');
		} else {
			pr = new PageReference(retURL);
		}
		pr.setRedirect(true);
		return pr;
	}
	
	private List<Operations_Request_Line_Item__c> createOperationsRequestLineItems(List<SelectOpportunityLineItemClass> selectedOppList, List<Product2> productList) {
		List<Operations_Request_Line_Item__c> orliList = new List<Operations_Request_Line_Item__c>();
		Map<Id, RecordTypeInfo> rtOpRecByIdMap = Schema.SObjectType.Operations_Request__c.getRecordTypeInfosById();
		Map<String, RecordTypeInfo> rtOpRecLineItemByNameMap = Schema.SObjectType.Operations_Request_Line_Item__c.getRecordTypeInfosByName();
		Id OpRecLineRT = rtOpRecLineItemByNameMap.get(rtOpRecByIdMap.get(opReq.RecordTypeId).getName()).getRecordTypeId();
		
		if (selectedOppList != null) {
			Boolean limitQty = false;
			Decimal qty;
			if (rtOpRecByIdMap.get(opReq.RecordTypeId).getName() == 'Swatches, Fabrics & Finishes') {
				limitQty = true;
			}
			
			for (SelectOpportunityLineItemClass s :selectedOppList) {
				qty = s.oppLineItem.Quantity;
				if (limitQty && qty > 4) {
					qty = 4;
				}
				orliList.add(new Operations_Request_Line_Item__c(
					RecordTypeId = OpRecLineRT,
					Operations_Request__c = opReq.Id,
					Opportunity_Product_Id__c = s.oppLineItem.Id,
					Quantity__c = qty,
					Notes__c = s.oppLineItem.Notes__c,
					Customer_Location__c = s.oppLineItem.Customer_Location__c,
					Customer_Spec__c = s.oppLineItem.Customer_Spec__c,
					Product__c = s.oppLineItem.Product2Id)
				);
			}
		}
		
		if (productList != null) {
			for (Product2 p :productList) {
				orliList.add(new Operations_Request_Line_Item__c(
					RecordTypeId = OpRecLineRT,
					Operations_Request__c = opReq.Id,
					Product__c = p.Id)
				);
			}
		}
		
		return orliList;
	}
	
	private Boolean saveOpReqLines(List<SelectOpportunityLineItemClass> selectedOppLineList, List<Product2> productList) {
		Boolean success = false;
		
		List<Operations_Request_Line_Item__c> orliList = createOperationsRequestLineItems(selectedOppLineList, productList);
		
		if (orliList.isEmpty()) {
			
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'You must select at least one.'));
			
		} else {
			
			Map<Id, Schema.RecordTypeInfo> rtByIdMap = Schema.SObjectType.Operations_Request__c.getRecordTypeInfosById();
			if (rtByIdMap.containsKey(opReq.RecordTypeId) && rtByIdMap.get(opReq.RecordTypeId).getName() == 'Product Information' && opReqLineItemList.size() + orliList.size() > 1) {
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Too many operations request line items. Product Information operations requests can not have more than one operations request line item.'));
				
			} else {
				
				try {
					insert orliList;
					initAvailableList(true);
					newProductMap.clear();
					success = true;
				} catch(Exception e) {
					ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Exception while adding Operations Request Line Item records: ' + e.getMessage()));
				}
			}
		}
		
		return success;
	}
	
	public PageReference saveOppLineItems() {
		PageReference pr = null;
		
		if (saveOpReqLines(selectedOppLineItems, null)) {
			pr = new PageReference(retURL);
		}
		
		return pr;
	}
	
	public PageReference saveAndMoreOppLineItems() {
		PageReference pr = null;
		
		Boolean success = saveOpReqLines(selectedOppLineItems, null);
		return pr;
	}
	
	public PageReference saveProducts() {
		PageReference pr = null;
		
		if (saveOpReqLines(null, newProductMap.values())) {
			pr = new PageReference(retURL);
		}
		
		return pr;
	}
	
	public PageReference saveAndMoreProducts() {
		PageReference pr = null;
		
		Boolean success = saveOpReqLines(null, newProductMap.values());
		return pr;
	}
	
	// Search for products
	public PageReference searchProducts() {
		List<Product2> productList = new List<Product2>();
		List<String> searchStrings = new List<String>();
		String query = 'SELECT Id, IsActive, Name, Actual_Product_Name__c, ECommerce_Display_Name__c, Total_Quantity_On_Hand__c FROM Product2 WHERE';
		
		productMap.clear();
		overLimit = false;
		hasSearchResults = false;

		// Create the query WHERE clause based upon search strings entered
		if (String.isNotBlank(productSearchString)) {
			
			system.debug('The search string is ' + productSearchString);
			query+= ' (';
			
			// Escape single quotes in case any were entered in to the search terms
			productSearchString = String.escapeSingleQuotes(productSearchString);
			
			// Split the search terms in case there are comma-separated terms
			searchStrings = productSearchString.split(',');
			
			// Loop through the search terms building the remainder of the query
			for (String s :searchStrings) {
				query += 'SKU_Search__c LIKE \'%' + s + '%\' OR ';
            }
			
			// Strip out the trailing ' OR '
			query = query.removeEnd(' OR ');
			
			// Add the terminating parenthesis
			query += ')';
			
			query+= ' ORDER BY Name';
			query+= ' LIMIT 101';
			
			system.debug('The search query is: ' + query);
			productList = database.query(query);
			
			// We only display up to 100 results... if there are more, let the user know
			if (productList.size() == 101) {
				productList.remove(100);
				overLimit = true;
			}
			
			for (Product2 p :productList) {
				productMap.put(p.Id, p);
			}
			
			// Set the boolean to indicate whether the Add All Selected button should be enabled
			if (!productMap.isEmpty()) {
				hasSearchResults = true;
			}
		}
		
		return null;
	}
	
	// Add one product to the selected list
	public PageReference addOneProduct() {
		
		for (Product2 p :productMap.values()) {
			if ((String)p.Id == this.toSelect) {
				newProductMap.put(p.Id, p);
				productMap.remove(p.Id);
				hasSelectedResults = true;
				disableToggle = true;
				break;
			}
		}
		
		if (productMap.isEmpty()) {
			hasSearchResults = false;
		}
		
		return null;
	}
	
	// Remove one product from the selected list
	public PageReference removeOneProduct() {
		
		for (Product2 p :newProductMap.values()) {
			if ((String)p.Id == this.toSelect) {
				newProductMap.remove(p.Id);
				productMap.put(p.Id, p);
				hasSearchResults = true;
				break;
			}
		}
		
		if (newProductMap.isEmpty()) {
			hasSelectedResults = false;
			disableToggle = false;
		}
		
		return null;
	}
	
	// Add all products from the search results to the selected list
	public PageReference addAllProducts() {
		
		for (Product2 p :productMap.values()) {
			newProductMap.put(p.Id, p);
		}
		
		if (!newProductMap.isEmpty()) {
			hasSelectedResults = true;
			disableToggle = true;
		}
		productMap.clear();
		hasSearchResults = false;
		
		return null;
	}
	
	// Remove all products from the selected list
	public PageReference removeAllProducts() {
		
		for (Product2 p :newProductMap.values()) {
			productMap.put(p.Id, p);
		}
		
		if (!productMap.isEmpty()) {
			hasSearchResults = true;
		}
		newProductMap.clear();
		hasSelectedResults = false;
		disableToggle = false;
		
		return null;
	}
}