public with sharing class OperationsRequestLineItem_EditAllCtlExt {
	
	/*
     *  Operations Request Line Item controller extension - methods to support editing key fields of all 
     *	operations request line item records related to a single operations request record on a single page.
     *
     */
    
	ApexPages.StandardController stdController;
	
	private String orId;
	private String retURL;
	private List<Operations_Request_Line_Item__c> opReqLineList;
	private List<Operations_Request_Line_Item__c> displayOpReqLineList;
	private Integer minDisplayRows = 2;
	private Integer defaultDisplayRows = 10;
	
	public Operations_Request__c opReq {get; set;}
	public Boolean fatalError {get; set;}
	public Boolean noLines {get; set;}
	public Integer displaySet {get; set;}
    public Integer pageNumber {get; set;}
    public Integer totalPages {get; set;}
    public Integer rowsToDisplay {get; set;}
    public String recordTypeName {get; set;}
	
	// Constructor
	public OperationsRequestLineItem_EditAllCtlExt(ApexPages.StandardController stdController) {
		
		fatalError = false;
		noLines = false;
		opReq = new Operations_Request__c();
		opReqLineList = new List<Operations_Request_Line_Item__c>();
		displayOpReqLineList = new List<Operations_Request_Line_Item__c>();
		orId = ApexPages.currentPage().getParameters().get('orId');
		retURL = ApexPages.currentPage().getParameters().get('retURL');
		
		// Initialize display variables
		rowsToDisplay = defaultDisplayRows;
		displaySet = 0;
		pageNumber = 1;
		totalPages = 1;
		
		if (String.isNotBlank(orId) && String.isNotBlank(retURL)) {
			try {
				opReq = [select Id, Name, RecordTypeId, Opportunity__c from Operations_Request__c where Id = :orId];
				Map<Id, RecordTypeInfo> rtByIdMap = Schema.SObjectType.Operations_Request__c.getRecordTypeInfosById();
				recordTypeName = rtByIdMap.containsKey(opReq.RecordTypeId) ? rtByIdMap.get(opReq.RecordTypeId).getName() : '';
				initOpReqLines();
			} catch(Exception e) {
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Fatal exception: ' + e.getMessage()));
				fatalError = true;
			}
		} else {
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Invalid page parameters.'));
			fatalError = true;
		}
	}
	
	// Read in the entire list of Operations Request Line Items - all fields
	private void initOpReqLines() {
		String selects;
		Map<String, Schema.SObjectField> fMap;
		List<String> selectFields;
		
		opReqLineList.clear();
		
		fMap = Schema.getGlobalDescribe().get('Operations_Request_Line_Item__c').getDescribe().Fields.getMap();
		selectFields = new List<String>();
		if (fMap != null) {
			for (Schema.SObjectField ft : fMap.values()) {
				Schema.DescribeFieldResult fd = ft.getDescribe();
				selectFields.add(fd.getName());
			}
		}
		
		selects = '';
		for (String s:selectFields) {
			selects += s + ',';
		}
		if (selects.endsWith(',')) {
			selects += 'Product__r.Name,';
			selects = selects.substring(0,selects.lastIndexOf(','));
			
			system.debug('*****initOpReqLines field list = ' + selects);
			
			opReqLineList = (List<Operations_Request_Line_Item__c>)Database.query('SELECT ' + selects + ' FROM Operations_Request_Line_Item__c WHERE Operations_Request__c = \'' + opReq.Id + '\' ORDER BY Name ASC');
		}
		
		/*
		opReqLineList = [select Id, Name, Operations_Request__c, Customer_Location__c, Customer_Spec__c, 
				DC_Location__c, Notes__c, Opportunity_Product_Id__c, Quantity__c, Actual_Product_Name__c, 
				New_SKU__c, Ready_To_Place_Dropship__c, Product__c, Product__r.Name, Indoor_Outdoor__c, 
				Attribute_Color_Finish__c, ELC__c, Approved_Pricing__c, Customer_Tracking__c, PO__c, 
				PO_In_DC_Date__c, Confirmed_Lead_Time__c, Yardage__c, Square_Feet__c, Fulfillment_Type__c,
				Dom_Int__c, Additional_Information__c, MOQ__c, Ops_Notes__c, Freight_Cost_Per_Unit__c, 
				Discount__c, MMU_Approved__c, Question__c, Product_Information__c, Foam_Fill__c,
				Vendor_Request_Date__c, Is_this_a_Custom_Item__c, Custom_Specification_Info__c, 
				Do_you_need_a_CAD__c, Vendor_Tracking__c, Arrival_Date__c, Type__c 
				from Operations_Request_Line_Item__c where Operations_Request__c = :opReq.Id order by Name asc];
		*/
		
		noLines = opReqLineList.isEmpty() ? true : false;
		
		// Initialize the first set of operations request lines to display
		PageReference pr = rowsPerPageChanged();
	}
	
	// The list of Operations Request Line Items displayed
	public List<Operations_Request_Line_Item__c> getOpReqLines() {
		return displayOpReqLineList;
	}
	
	// Operations Request Line Items pagination methods
	public PageReference firstSet() {
		displayOpReqLineList.clear();
		displaySet = 0;
		pageNumber = displaySet + 1;
		for (Integer i=displaySet * rowsToDisplay; i<opReqLineList.size() && i<((displaySet * rowsToDisplay) + rowsToDisplay); i++) {
			displayOpReqLineList.add(opReqLineList[i]);
		}
        return null;
    }
	
	public PageReference nextSet() {
        if ((displaySet + 1) * rowsToDisplay < opReqLineList.size()) {
            displayOpReqLineList.clear();
            displaySet++;
            pageNumber = displaySet + 1;
            for (Integer i=displaySet * rowsToDisplay; i<opReqLineList.size() && i<((displaySet * rowsToDisplay) + rowsToDisplay); i++) {
                displayOpReqLineList.add(opReqLineList[i]);
            }
        }
        return null;
    }
    
    public PageReference previousSet() {
        if (displaySet - 1 >= 0) {
            displayOpReqLineList.clear();
            displaySet--;
            pageNumber = displaySet + 1;
            for (Integer i=displaySet * rowsToDisplay; i<opReqLineList.size() && i<((displaySet * rowsToDisplay) + rowsToDisplay); i++) {
                displayOpReqLineList.add(opReqLineList[i]);
            }
        }
        return null;
    }
	
	public PageReference lastSet() {
		displayOpReqLineList.clear();
		displaySet = totalPages > 1 ? totalPages - 1 : 0;
		pageNumber = displaySet + 1;
		for (Integer i=displaySet * rowsToDisplay; i<opReqLineList.size() && i<((displaySet * rowsToDisplay) + rowsToDisplay); i++) {
			displayOpReqLineList.add(opReqLineList[i]);
        }
        return null;
    }
    
    public String getRowsPerPage() {
        return String.valueOf(rowsToDisplay);
    }
    
    public void setRowsPerPage(String rpp) {
        rowsToDisplay = Integer.valueOf(rpp);
        if (rowsToDisplay > opReqLineList.size()) {
            rowsToDisplay = opReqLineList.size();
        }
        if (rowsToDisplay < minDisplayRows) {
            rowsToDisplay = minDisplayRows;
        }
    }
    
    public PageReference rowsPerPageChanged() {
        displayOpReqLineList.clear();
        displaySet = 0;
        for (Integer i=displaySet * rowsToDisplay; i<opReqLineList.size() && i<((displaySet * rowsToDisplay) + rowsToDisplay); i++) {
            displayOpReqLineList.add(opReqLineList[i]);
        }
        pageNumber = displaySet + 1;
        totalPages = opReqLineList.size() / rowsToDisplay;
        if (math.mod(opReqLineList.size(), rowsToDisplay) > 0) {
            totalPages++;
        }
        return null;
    }
	
	// Save whatever changes have been made and return the user to the operations request detail page
	public PageReference save() {
		PageReference pr = null;
		
		try {
			update opReqLineList;
			pr = new PageReference('/' + opReq.Id);
			pr.setRedirect(true);
		} catch(Exception e) {
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Exception saving Operations Request Line Items: ' + e.getMessage()));
		}
		
		return pr;
	}
	
	// Save whatever changes have been made and allow the user to continue editing
	public PageReference saveAndMore() {
		PageReference pr = null;
		
		try {
			update opReqLineList;
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, 'Save success.'));
		} catch(Exception e) {
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Exception saving Operations Request Line Items: ' + e.getMessage()));
		}
		
		return pr;
	}
}