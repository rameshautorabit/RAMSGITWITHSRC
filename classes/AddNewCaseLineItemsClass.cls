public without sharing class AddNewCaseLineItemsClass
{
    public String currentSortDir {get; set;}
    public String shiptoNumber {get; Set;}
    public String itemNumber {get; Set;}
    private Set<Id> oliIds;
    private String query = '';
    private String caseId;
    private String orderId;
    private Apexpages.StandardsetController setCon;
    private Set<Id> selectedOrderLineIdList = new Set<Id>();
    private List<SelectOrderLineClass> SelectedOrderLineList;
    private final Integer pageSize = 25;
    private Integer currentPage = 0;
    private Boolean isFilterSearch = false;
    
   
    public AddNewCaseLineItemsClass()
    {
        SelectedOrderLineList = new List<SelectOrderLineClass>();
        oliIds=new Set<Id>();
        
        if(ApexPages.currentPage().getParameters().get('caseId') != null){
            caseId = ApexPages.currentPage().getParameters().get('caseId');
        }
        
        System.debug('Case ID'+ caseId);
        
        if(ApexPages.currentPage().getParameters().get('orderId') != null){
            orderId = ApexPages.currentPage().getParameters().get('orderId');
        }
        
        System.debug('ORDER ID:' + orderId);
        
        //Retrieve Existing Line Items
        List<Case_Line_Items__c> lstOfCL=[SELECT Id, Line_Number__c FROM Case_Line_Items__c WHERE Case_Number__c=:caseId];
        for(Case_Line_Items__c cli: lstOfCL)
        {
            //Set containing existing order line Ids
            oliIds.add(cli.Line_Number__c); 
        }
       
        /*
        query = 'SELECT Id, CW_SKU_ID__c, Collection__c, Return_Quantity__c, Line_Number__c, Item_Description__c, Ship_to_Number__c, Ship_Date__c, Order_Quantity__c, Line_Total__c, Reserve_DC__c  '
                +' FROM Order_Line_Items__c WHERE RH_Order_Number__c =: orderId AND Id NOT IN:oliIds';
        */
        
        query = 'SELECT Id, CW_SKU_ID__c, CW_SKU_ID__r.Name, Collection__c, Return_Quantity__c, Line_Number__c, Item_Description__c, Ship_to_Number__c, Ship_Date__c, Order_Quantity__c, Line_Total__c, Reserve_DC__c, Monogram_able__c, Drop_Ship__c  '
                +' FROM Order_Line_Items__c WHERE RH_Order_Number__c =: orderId AND Id NOT IN:oliIds';
        
        
        searchforOrderLine('');
        
        if (caseId == null || orderId == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This page requires a case Id and an order Id as page parameters.'));
        }
    }
    
     //List of order lines that will be displayed on the VF page
    public List<SelectOrderLineClass> getSelectedOrderLineList()
    {
        if(setCon != null)
        {
            SelectedOrderLineList.clear();
            for(Order_Line_Items__c oli: (List<Order_Line_Items__c>)setCon.getRecords())
            {
                SelectedOrderLineList.add(new SelectOrderLineClass(oli, (selectedOrderLineIdList.contains(oli.Id) || isFilterSearch)));
            }
        }
        return SelectedOrderLineList;
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
    
    /*
    public void sortLineNumber(){
        sortOrderLine('Line_Number__c');
    }
    
    public void sortShiptoNum(){
        sortOrderLine('Ship_to_Number__c');
    }
    
    public void sortLineTotal(){
        sortOrderLine('Line_Total__c');
    }
    
    public void sortShiptoState(){
        //sortOrderLine('Ship_to_State__c');
    }
    */
    
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
    
    public Integer gettotalPages()
    {
        if(Math.mod(setCon.getResultSize(), pageSize) != 0){
            return ((setCon.getResultSize() / pageSize) + 1);
        }else{
            return (setCon.getResultSize() / pageSize);
        }
    }
    
    private void addSelected()
    {
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
    
    public void filter()
    {
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
    
    private void searchforOrderLine(String filterQuery)
    {
        currentSortDir = ' ASC';
        String s = query;
        if(String.isNotBlank(filterQuery))
        {
            s += filterQuery;
        }
        System.debug(s);
        setCon = new Apexpages.StandardsetController(Database.getQueryLocator(s));
        setCon.setPageSize(pageSize);
    }
    
    public void saveandSelectMore()
    {
        addSelected();
        searchforOrderLine('');
        setCon.setPageNumber(currentPage);
        isFilterSearch = false;
    }
    
    public PageReference save()
    {
        addSelected();
        
        // Get the case record type, and the fields of the selected order lines that will be copied to the new case lines
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
            String origOrderLineQuery = orderLineQuery;
            orderLineQuery += ' FROM Order_Line_Items__c WHERE Id IN: selectedOrderLineIdList';
            origOrderLineQuery += ' FROM Order_Line_Items__c WHERE Id IN: oliIds';
            
            // Get the selected Order Line records and the original Order Line records
            List<Order_Line_Items__c> oliList = new List<Order_Line_Items__c>();
            oliList = Database.query(orderLineQuery);
            List<Order_Line_Items__c> oliOrigList = Database.query(origOrderLineQuery);
            
            // If we are dealing with an Order Inquiries case, verify that all Order Lines on the case are with the same DC
            Map<Id, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById();
            if (rtMap.get(ca.RecordTypeId).getName().contains('Order Inquiries')) {
                String dc = '';
                for (Order_Line_Items__c oli :oliOrigList) {
                    if (String.isBlank(dc)) {
                        dc = oli.Reserve_DC__c;
                    }
                }
                
                for (Order_Line_Items__c oli :oliList) {
                    if (String.isBlank(dc)) {
                        dc = oli.Reserve_DC__c;
                    }
                    if (String.isNotBlank(dc) && String.isNotBlank(oli.Reserve_DC__c) && dc != oli.Reserve_DC__c) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You may only add order lines with DC ' + dc + '. If you need to add order lines from another DC, please create another case.'));
                        return null;
                    }
                }
            }
            
            //Selecting case line item record type
            Id selectedLineRecTypeId;
            String selectedLineRecTypeName;
            
            //Retrieve case line record type using case record type from the custom setting
            try {
                CaseToCaseLineRecordTypes__c crt = [SELECT Id, Name, Case_Record_Type__c, CaseLine_Record_Type__c FROM  CaseToCaseLineRecordTypes__c WHERE Case_Record_Type__c = :rtMap.get(ca.RecordTypeId).getName()];
                if (crt != null && crt.CaseLine_Record_Type__c != null) {
                    selectedLineRecTypeName=crt.CaseLine_Record_Type__c;
                }
            } catch(QueryException q) {
                System.debug('*****AddNewCaseLineItemsClass save1 exception' + q.getMessage());
            }
            
            if (selectedLineRecTypeName!=null) {
                try {
                    RecordType clr = [SELECT Id,Name FROM RecordType WHERE SObjectType='Case_Line_Items__c' AND Name=:selectedLineRecTypeName LIMIT 1];
                    selectedLineRecTypeId=clr.Id;
                } catch(QueryException q) {
                    System.debug('*****AddNewCaseLineItemsClass save2 exception' + q.getMessage());
                }
            }
            
            for (Order_Line_Items__c oli: oliList) {
                Case_Line_Items__c cli = new Case_Line_Items__c();
                cli.Case_Number__c = caseId;
                if (selectedLineRecTypeId != null) {
                    cli.RecordTypeId=selectedLineRecTypeId;
                }
                cli.Line_Number__c = oli.Id;
                for (CaseLineToOrderLineMapping__c clo :orderLineMapping) {
                    cli.put(clo.Case_Line_Item_Field__c, oli.get(clo.Order_Line_Item_Field__c));
                }
                cliList.add(cli);
            }
            
            try {
                insert cliList;
            } catch(DmlException de) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, de.getDMLMessage(0)));
                return null;
            }
            
            return new PageReference('/' + caseId);
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Case record, caseId = ' + caseId));
            return null;
        }
    }
    
    public PageReference cancel()
    {
       return new PageReference('/' + caseId);
    }   

}