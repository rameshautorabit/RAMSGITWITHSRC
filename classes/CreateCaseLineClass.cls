/**
    Test Class: CreateCaseLineClass
**/

public with sharing class CreateCaseLineClass
{

    public String currentSortDir {get; set;}
    public String shiptoNumber {get; Set;}
    public String itemNumber {get; Set;}
    public Boolean fatalError {get; set;}
    public Boolean maximumLines {get; set;}
    
    private String query = '';
    private String caseId;
    private String orderId;
    private String newCaseLineItem;
    private String retURL;
    private Case caseRec;
    private Apexpages.StandardsetController setCon;
    private Set<Id> selectedOrderLineIdList = new Set<Id>();
    private List<SelectOrderLineClass> SelectedOrderLineList;
    private final Integer pageSize = 25;
    private Integer currentPage = 0;
    private Boolean isFilterSearch = false;
    private Set<Id> oliIds;
    private List<Case_Line_Items__c> lstOfCL;
    private String caseRecordType;
    
    
    //List of order lines that will be displayed on the VF page
    public List<SelectOrderLineClass> getSelectedOrderLineList(){
        if(setCon != null){
            SelectedOrderLineList.clear();
            for(Order_Line_Items__c oli: (List<Order_Line_Items__c>)setCon.getRecords()){
                SelectedOrderLineList.add(new SelectOrderLineClass(oli, (selectedOrderLineIdList.contains(oli.Id) || isFilterSearch)));
                System.debug(selectedOrderLineIdList.contains(oli.Id));
            }
        }
        System.debug(SelectedOrderLineList);
        return SelectedOrderLineList;
    }
    
    //Constructor
    public CreateCaseLineClass() {
        
        SelectedOrderLineList = new List<SelectOrderLineClass>();
        oliIds = new Set<Id>();
        fatalError = false;
        maximumLines = false;
        
        caseId = ApexPages.currentPage().getParameters().get('caseId');
        //orderId = ApexPages.currentPage().getParameters().get('orderId');
        newCaseLineItem = ApexPages.currentPage().getParameters().get('newCaseLineItem');
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        
		Map<String, CaseToCaseLineRecordTypes__c> cToclMap = CaseToCaseLineRecordTypes__c.getAll();
		
		if (String.isBlank(caseId)) {
			fatalError = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This page requires the case Id as the page parameter.'));
			
		} else {
			
			// Get existing Case Line records to make sure we don't already have too many
			caseRecordType = null;
            caseRec = [select Id, CaseNumber, RecordTypeId, RH_Order_Number__c, RH_Order_Number__r.Name from Case where Id = :caseId];
            orderId = caseRec.RH_Order_Number__c;
            Map<Id, Schema.RecordTypeInfo> rtCaseByIdMap = Schema.SObjectType.Case.getRecordTypeInfosById();
            if (rtCaseByIdMap.containsKey(caseRec.RecordTypeId)) {
                caseRecordType = rtCaseByIdMap.get(caseRec.RecordTypeId).getName();
            }
            
			lstOfCL = new List<Case_Line_Items__c>();
			lstOfCL = [SELECT Id, Line_Number__c, RecordTypeId FROM Case_Line_Items__c WHERE Case_Number__c = :caseId];
			for (Case_Line_Items__c cli :lstOfCL) {
				oliIds.add(cli.Line_Number__c);		// Set containing existing order lines on the case
			}
            
            if (!lstOfCL.isEmpty()) {
                if (cToclMap.containsKey(caseRecordType) && String.isNotBlank(cToclMap.get(caseRecordType).CaseLine_Record_Type__c)) {
                    if (lstOfCL.size() >= 1) {
                        maximumLines = cToclMap.get(caseRecordType).Limit_To_1__c;
                    }
                }
            }
            
            if (maximumLines) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This case already has the maximum number of case lines allowed - cannot add any more case lines.'));
                
            } else {
				
				// Initialize our Order Lines
				query = 'SELECT Id, CW_SKU_ID__c, CW_SKU_ID__r.Name, Collection__c, Return_Quantity__c, Backorder_Quantity__c, Line_Number__c, Item_Description__c, Ship_to_Number__c, Ship_Date__c, Order_Quantity__c, Line_Total__c, Reserve_DC__c, Monogram_able__c, Drop_Ship__c  '
						+' FROM Order_Line_Items__c WHERE RH_Order_Number__c=: orderId AND Id NOT IN:oliIds';
				searchforOrderLine('');
            }
		}
    }
	
	public PageReference checkOrderLines() {
		PageReference pr = null;
		Map<String, CaseToCaseLineRecordTypes__c> cToclMap = CaseToCaseLineRecordTypes__c.getAll();
		
		if (!fatalError && !maximumLines) {
			
			if (String.isBlank(orderId) || setCon.getResultSize() == 0) {
				
				if (oliIds.isEmpty()) {
					// No provided Order Id or no Order Lines, take user to standard new Case Line page
					Schema.DescribeSObjectResult r = Case_line_Items__c.sObjectType.getDescribe();
					String keyPrefix = r.getKeyPrefix();
					
					Map<String, FieldIdLookup__c> fieldIdMap = FieldIdLookup__c.getAll();
					String caseParam = '';
					if (fieldIdMap.containsKey('Case Line Item - Case')) {
						caseParam = '&CF' + fieldIdMap.get('Case Line Item - Case').FieldId__c + '=' + caseRec.CaseNumber + '&CF' + fieldIdMap.get('Case Line Item - Case').FieldId__c + '_lkid=' + caseRec.Id;
					}
					
					String orderParam = '';
					if (fieldIdMap.containsKey('Case Line Item - Order') && String.isNotBlank(orderId)) {
						orderParam = '&CF' + fieldIdMap.get('Case Line Item - Order').FieldId__c + '=' + caseRec.RH_Order_Number__r.Name + '&CF' + fieldIdMap.get('Case Line Item - Order').FieldId__c + '_lkid=' + caseRec.RH_Order_Number__c;
					}
					
					String rtParam = '';
					Map<String, Schema.RecordTypeInfo> rtCLIByNameMap = Schema.SObjectType.Case_Line_Items__c.getRecordTypeInfosByName();
					if (cToclMap.containsKey(caseRecordType) && String.isNotBlank(cToclMap.get(caseRecordType).CaseLine_Record_Type__c)) {
						if (rtCLIByNameMap.containsKey(cToclMap.get(caseRecordType).CaseLine_Record_Type__c)) {
							rtParam = '&RecordType=' + rtCLIByNameMap.get(cToclMap.get(caseRecordType).CaseLine_Record_Type__c).getRecordTypeId();
						}
					}
					
					pr = new PageReference('/'+ keyPrefix+'/e?retURL=' + retURL + caseParam + orderParam + rtParam);
					pr.setRedirect(true);
					
				} else {
					
					maximumLines = true;
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No available Order Lines for selection.'));
				}
			
			} else {
				
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Select one or more Order Lines to associate with new Case Lines and click Save or just click Save to continue.'));
				
			}
		}
		
		return pr;
	}
    
    //Inner class for selected Case Lines
    private class SelectOrderLineClass{
        public Boolean selected {get; set;}
        public Order_Line_Items__c orderLine {get; set;}
        public SelectOrderLineClass(Order_Line_Items__c orderLine, Boolean selected){
            this.selected = selected;
            this.orderLine = orderLine;
        }
    }
    
    private String sortColumn = '';
    
    public String getsortColumn() {
        return sortColumn;
    }
    
    public void sortLineNumber() {
        sortColumn = 'LineNumber';
        sortOrderLine('Line_Number__c');
    }
    
    public void sortItemNumber() {
        sortColumn = 'ItemNumber';
        sortOrderLine('CW_SKU_ID__r.Name');
    }
    
    public void sortItemDescription() {
        sortColumn = 'ItemDescription';
        sortOrderLine('Item_Description__c');
    }
    
    public void sortDC() {
        sortColumn = 'DC';
        sortOrderLine('Reserve_DC__c');
    }
    
    public void sortBackorderQuantity() {
        sortColumn = 'BackorderQuantity';
        sortOrderLine('Backorder_Quantity');
    }
    
    public void sortOrderQuantity() {
        sortColumn = 'OrderQuantity';
        sortOrderLine('Order_Quantity__c');
    }
    
    public void sortReturnQuantity() {
        sortColumn = 'ReturnQuantity';
        sortOrderLine('Return_Quantity__c');
    }
    
    public void sortShipDate() {
        sortColumn = 'ShipDate';
        sortOrderLine('Ship_Date__c');
    }
    
    public void sortLineTotal() {
        sortColumn = 'LineTotal';
        sortOrderLine('Line_Total__c');
    }
    
    public void sortShiptoNum() {
        sortColumn = 'ShiptoNum';
        sortOrderLine('Ship_to_Number__c');
    }
    
    public void sortCollection() {
        sortColumn = 'Collection';
        sortOrderLine('Collection__c');
    }
    
    public void sortMonogram_able() {
        sortColumn = 'Monogram_able';
        sortOrderLine('Monogram_able__c');
    }
    
    public void sortSPO() {
        sortColumn = 'SPO';
        sortOrderLine('Drop_Ship__c');
    }
    
    private void sortOrderLine(String fieldName){
        if(currentSortDir.equals('ASC')){
            currentSortDir = 'DESC';
        }else{
            currentSortDir = 'ASC';
        }
    
       setCon = new Apexpages.StandardsetController(Database.getQueryLocator(query + ' Order By ' + fieldName + ' ' + currentSortDir));
       setCon.setPageSize(pageSize);
    }
    
    public void next(){
        addSelected();
        setCon.next();
    }
    
    public Boolean gethasNext(){
        return setCon.gethasNext();
    }
    
    public void previous(){
        addSelected();
        setCon.previous();
    }
    
    public Boolean gethasPrevious(){
        return setCon.gethasPrevious();
    }
    
    public void last(){
        addSelected();
        setCon.last();
    }
    
    public Boolean gethasLast(){
        return (setCon.getResultSize() > pageSize && getCurrentPage() != gettotalPages());
    }
    
    public void first(){
        addSelected();
        setCon.first();
    }
    
    public Boolean gethasFirst(){
        return (setCon.getResultSize() > pageSize && setCon.getPageNumber() != 1);
    }
    
    public Integer getCurrentPage(){
        return setCon.getPageNumber();
    }
    
    public Integer gettotalPages(){
        if(Math.mod(setCon.getResultSize(), pageSize) != 0){
            return ((setCon.getResultSize() / pageSize) + 1);
        }else{
            return (setCon.getResultSize() / pageSize);
        }
    }
    
    private void addSelected(){
        
        //system.debug('*****addSelected before SelectedOrderLineList.size = ' + SelectedOrderLineList.size() + ' selectedOrderLineIdList.size = ' + selectedOrderLineIdList.size());
        
        for (SelectOrderLineClass sol :SelectedOrderLineList) {
            if (sol.Selected) {
                selectedOrderLineIdList.add(sol.orderLine.Id);
            } else {
                selectedOrderLineIdList.remove(sol.orderLine.Id);
            }
        }
        
        //system.debug('*****addSelected before SelectedOrderLineList.size = ' + SelectedOrderLineList.size() + ' selectedOrderLineIdList.size = ' + selectedOrderLineIdList.size());
    }
    
    public void filter(){
        String s = ''; 
        
        if(String.isNotBlank(itemNumber)){
            isFilterSearch = true;
            s = ' AND Ship_to_Number__c =: itemNumber'; 
        }
        
        if(String.isNotBlank(shiptoNumber)){
            isFilterSearch = true;
            s = ' AND Ship_to_Number__c =: shiptoNumber'; 
        }
        
        if(String.isBlank(s)){
            isFilterSearch = false;
        }
        
        addSelected();
        currentPage = getCurrentPage();
        searchforOrderLine(s);
    }
    
    private void searchforOrderLine(String filterQuery){
        currentSortDir = ' ASC';
        String s = query;
        if(String.isNotBlank(filterQuery)){
            s += filterQuery;
        }
        //Commented on 07/30 as the Ship to address doesn't exist on order lines
        //setCon = new Apexpages.StandardsetController(Database.getQueryLocator(s + ' ORDER BY Ship_to_Address_1__c ' + currentSortDir));
        System.debug(s);
        setCon = new Apexpages.StandardsetController(Database.getQueryLocator(s));
        setCon.setPageSize(pageSize);
        //query = 'SELECT Id, Line_Number__c, Ship_to_Number__c, Ship_to_City__c, Ship_to_State__c, Order_Quantity__c, Item_Description__c, Line_Total__c, Color__c, Size__c, Item_Number__c '
            //     +  ' FROM Order_Line_Items__c WHERE RH_Order_Number__c=: orderId';
    }
    
    public void saveandSelectMore(){
        addSelected();
        searchforOrderLine('');
        setCon.setPageNumber(currentPage);
        isFilterSearch = false;
    }
    
    public PageReference save() {
        PageReference pr = null;
        String cliStatus = 'New';
        
        addSelected();
        
        // Get the case record type, and the fields of the selected order lines that will be copied to the case lines
        List<Case> cList = new List<Case>();
        cList = [select Id, RecordTypeId from Case where Id = :caseId limit 1];
        if (!cList.isEmpty()) {
            Case ca = cList[0];
            List<Case_Line_Items__c> cliList = new List<Case_Line_Items__c>();
            
            String orderLineQuery = 'SELECT Reserve_DC__c, ';
            List<CaseLineToOrderLineMapping__c> orderLineMapping = [SELECT Order_Line_Item_Field__c, Case_Line_Item_Field__c FROM CaseLineToOrderLineMapping__c];
            
            for (CaseLineToOrderLineMapping__c clo: orderLineMapping) {
                orderLineQuery += clo.Order_Line_Item_Field__c + ', ';
            }
            
            orderLineQuery = orderLineQuery.removeEnd(', ');
            orderLineQuery += ' FROM Order_Line_Items__c WHERE Id IN: selectedOrderLineIdList';
            List<Order_Line_Items__c> oliList = new List<Order_Line_Items__c>();
            oliList = Database.query(orderLineQuery);
            
            // Verify that all selected Order Lines are associated with the same DC if we are dealing with an Order Inquiries case
            Map<Id, Schema.RecordTypeInfo> rtCaseMap = Schema.SObjectType.Case.getRecordTypeInfosById();
            if (rtCaseMap.containsKey(ca.RecordTypeId) && rtCaseMap.get(ca.RecordTypeId).getName().contains('Order Inquiries')) {
                String dc = '';
                for (Order_Line_Items__c oli :oliList) {
                    if (String.isBlank(dc)) {
                        dc = oli.Reserve_DC__c;
                    }
                    if (String.isNotBlank(dc) && String.isNotBlank(oli.Reserve_DC__c) && dc != oli.Reserve_DC__c) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You may only create a case with multiple lines that are going to the same DC. If you have items that are at different DCs, please create a case for each DC.'));
                        return null;
                    }
                }
            }
            
            // Determine the Case Line Item record type Id
            Id selectedLineRecTypeId = null;
            CaseToCaseLineRecordTypes__c crt = null;
            Map<String, CaseToCaseLineRecordTypes__c> crtMap = CaseToCaseLineRecordTypes__c.getAll();
            Map<String, Schema.RecordTypeInfo> rtCaseLineMap = Schema.SObjectType.Case_Line_Items__c.getRecordTypeInfosByName();
            if (crtMap.containsKey(caseRecordType)) {
                crt = CaseToCaseLineRecordTypes__c.getInstance(caseRecordType);
                if (rtCaseLineMap.containsKey(crt.CaseLine_Record_Type__c)) {
                    selectedLineRecTypeId = rtCaseLineMap.get(crt.CaseLine_Record_Type__c).getRecordTypeId();
                }
                if (!crt.Case_Line_Required_Fields__c) {
                    cliStatus = 'In Progress';
                }
            }
            
            for (Order_Line_Items__c oli: oliList) {
                Case_Line_Items__c cli = new Case_Line_Items__c();
                cli.Case_Number__c = caseId;
                if (selectedLineRecTypeId != null) {
                    cli.RecordTypeId = selectedLineRecTypeId;
                }
                cli.Line_Number__c = oli.Id;
                for (CaseLineToOrderLineMapping__c clo :orderLineMapping) {
                    cli.put(clo.Case_Line_Item_Field__c, oli.get(clo.Order_Line_Item_Field__c));
                }
                cli.Status__c = cliStatus;
                cliList.add(cli);
            }
            
            // Make sure the user hasn't selected too many order lines
            Boolean tooManyLines = true;
            if (!cliList.isEmpty()) {
                if (crt != null) {
                    tooManyLines = crt.Limit_to_1__c;
                    if (!tooManyLines || cliList.size() == 1) {
                        tooManyLines = false;
                    }
                } else {
                    tooManyLines = false;
                }
                
                if (!tooManyLines) {
                    try {
                        insert cliList;
                       /* if (oliList.size()==0 && orderId=='') {

                       pr= new PageReference('/' + cliList[0].Id+ '/e?retURL=' + caseId); 
                       
                    }*/
                        pr = new PageReference('/' + caseId);
                    } catch(DmlException de) {
                        System.debug(de.getDMLMessage(0));
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, de.getDMLMessage(0)));
                    }
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Too many Order Lines selected. Please select only one Order Line.'));
                }
            } else {
                pr = new PageReference('/' + caseId);
                if (crt != null) {
                 if (crt.Case_Line_Required__c && lstOfCL.size() < 1) {
                    //if (oliList.size()==0 && orderId!='') {

                       // pr= new PageReference('/' + cliList[0].Id+ '/e?retURL=' + caseId); 

                     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select at least one Order Line.'));
                     pr = null;
                    }
                }
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Case record, caseId = ' + caseId));
        }
        
        return pr;
    }
    
    public PageReference cancel(){
        PageReference pr;
        
        pr = new PageReference(retURL);
        if (newCaseLineItem != 'true') {
            Case c = new Case(Id = caseId);
            delete c;
        }
        return pr;
    }
}