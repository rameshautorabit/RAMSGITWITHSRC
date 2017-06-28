/**
 *   Extends the DataSource.Connection class to enable 
 *   Salesforce to sync the external system’s schema 
 *   and to handle queries and searches of the external data. 
 **/
global class CWDataSourceConnection extends DataSource.Connection {

    /**
     *   Constructors
     **/

    global CWDataSourceConnection(DataSource.ConnectionParams connectionParams) {
    }
    global CWDataSourceConnection() {}
    
    /**
     *   Called when an external object needs to get a list of 
     *   schema from the external data source, for example when 
     *   the administrator clicks “Validate and Sync” in the 
     *   user interface for the external data source.   
     **/
    override global List<DataSource.Table> sync() {
        
        System.debug('*****In sync*****');
        
        List<DataSource.Table> tables = new List<DataSource.Table>();
        /*  
        List<DataSource.Column> invoicePaymentColumns;
        invoicePaymentColumns = new List<DataSource.Column>();
        
        invoicePaymentColumns.add(DataSource.Column.text('ExternalId', 255));
        invoicePaymentColumns.add(DataSource.Column.url('DisplayUrl'));
        invoicePaymentColumns.add(DataSource.Column.number('Company',3,0));
        invoicePaymentColumns.add(DataSource.Column.text('Order Number',8));
        invoicePaymentColumns.add(DataSource.Column.number('Ship To Number (IST)',3,0));
        invoicePaymentColumns.add(DataSource.Column.number('Invoice Order Line Sequence Number',5,0));
        invoicePaymentColumns.add(DataSource.Column.text('Invoice Date',10));
        invoicePaymentColumns.add(DataSource.Column.number('Invoice Number',7,0));
        invoicePaymentColumns.add(DataSource.Column.number('Invoice Line Number',3,0));
        invoicePaymentColumns.add(DataSource.Column.text('Invoice Type',6));
        invoicePaymentColumns.add(DataSource.Column.number('Additional Charge Amount (IST)',7,2));
        invoicePaymentColumns.add(DataSource.Column.number('Additional Freight Amount (IST)',7,2));
        invoicePaymentColumns.add(DataSource.Column.number('Payment Additional Charge Amount',7,2));
        invoicePaymentColumns.add(DataSource.Column.number('Payment Additional Freight Amount',7,2));
        invoicePaymentColumns.add(DataSource.Column.number('Freight Amount (IST)',7,2));
        invoicePaymentColumns.add(DataSource.Column.number('GST Amount (IST)',7,2));
        invoicePaymentColumns.add(DataSource.Column.number('Handling Amount (IST)',7,2));
        invoicePaymentColumns.add(DataSource.Column.number('Merchandise Amount (IST)',9,2));
        invoicePaymentColumns.add(DataSource.Column.number('PST Amount (IST)',7,2));
        invoicePaymentColumns.add(DataSource.Column.number('Tax Amount (IST)',7,2));
        invoicePaymentColumns.add(DataSource.Column.number('Freight Amount (IL)',7,2));
        invoicePaymentColumns.add(DataSource.Column.number('GST Amount (IL)',10,5));
        invoicePaymentColumns.add(DataSource.Column.number('Handling Amount (IL)',7,2));
        invoicePaymentColumns.add(DataSource.Column.number('PST Amount (IL)',10,5));
        invoicePaymentColumns.add(DataSource.Column.number('Tax Amount (IL)',10,5));
        invoicePaymentColumns.add(DataSource.Column.text('Date Shipped',10));
        invoicePaymentColumns.add(DataSource.Column.text('Payment Category',1));
        invoicePaymentColumns.add(DataSource.Column.text('Payment Category Description',20));
        invoicePaymentColumns.add(DataSource.Column.number('Payment Type',2,0));
        invoicePaymentColumns.add(DataSource.Column.text('Payment Type Description',28));
        invoicePaymentColumns.add(DataSource.Column.text('Credit Card Number',20));
        invoicePaymentColumns.add(DataSource.Column.number('Payment Freight Amount',7,2));
        invoicePaymentColumns.add(DataSource.Column.number('Payment GST Amount',10,5));
        invoicePaymentColumns.add(DataSource.Column.number('Payment Handling Amount',7,2));
        invoicePaymentColumns.add(DataSource.Column.number('Merchandise Unit Price (IL)',7,2));
        invoicePaymentColumns.add(DataSource.Column.number('Order Payment Sequence Number',2,0));
        invoicePaymentColumns.add(DataSource.Column.number('Order Level Freight Tax',7,2));
        invoicePaymentColumns.add(DataSource.Column.number('Payment Merchandise Amount',9,2));
        invoicePaymentColumns.add(DataSource.Column.number('Payment PST Amount',10,5));
        invoicePaymentColumns.add(DataSource.Column.number('Payment Tax Amount',7,2));
        invoicePaymentColumns.add(DataSource.Column.number('Quantity Shipped',5,0));
        invoicePaymentColumns.add(DataSource.Column.text('Item Number',12));
        invoicePaymentColumns.add(DataSource.Column.text('Color Code',4));
        invoicePaymentColumns.add(DataSource.Column.text('Size Code',4));
        invoicePaymentColumns.add(DataSource.Column.text('Pre Bill Item Number',12));
        invoicePaymentColumns.add(DataSource.Column.text('Pre Bill Color Code',4));
        invoicePaymentColumns.add(DataSource.Column.text('Pre Bill Size Code',4));
        invoicePaymentColumns.add(DataSource.Column.text('BOM Header Flag',1));
        invoicePaymentColumns.add(DataSource.Column.text('BOM Component Sequence',4));            
               
        
        List<DataSource.Column> shipToColumns;
        shipToColumns = new List<DataSource.Column>();         
        
        shipToColumns.add(DataSource.Column.text('ExternalId', 255));
        shipToColumns.add(DataSource.Column.url('DisplayUrl'));
        shipToColumns.add(DataSource.Column.text('Company', 3));
        shipToColumns.add(DataSource.Column.text('Order Number', 8));
        shipToColumns.add(DataSource.Column.text('Ship To Number', 3));
        shipToColumns.add(DataSource.Column.text('Customer Number', 9));
        shipToColumns.add(DataSource.Column.number('Merchandise Subtotal', 9, 2));
        shipToColumns.add(DataSource.Column.number('Merchandise Balance', 9, 2));
        shipToColumns.add(DataSource.Column.number('Handling', 7, 2));
        shipToColumns.add(DataSource.Column.number('Handling Balance', 7, 2));
        shipToColumns.add(DataSource.Column.number('Freight', 7, 2));
        shipToColumns.add(DataSource.Column.number('Freight Balance', 7, 2));
        shipToColumns.add(DataSource.Column.number('Additional Freight', 7, 2));
        shipToColumns.add(DataSource.Column.number('Additional Freight Balance', 7, 2)); 
        shipToColumns.add(DataSource.Column.number('Tax', 7, 2));
        shipToColumns.add(DataSource.Column.number('Tax Balance', 7, 2));
        shipToColumns.add(DataSource.Column.number('GST', 7, 2));
        shipToColumns.add(DataSource.Column.number('GST Balance', 7, 2));
        shipToColumns.add(DataSource.Column.number('PST', 7, 2));
        shipToColumns.add(DataSource.Column.number('PST Balance', 7, 2));
        shipToColumns.add(DataSource.Column.number('Additional Charge', 7, 2));
        shipToColumns.add(DataSource.Column.number('Additional Charge Balance', 7, 2));
        shipToColumns.add(DataSource.Column.text('Email', 50));
        shipToColumns.add(DataSource.Column.text('Last Name', 25));
        shipToColumns.add(DataSource.Column.text('Middle Initial', 1));
        shipToColumns.add(DataSource.Column.text('First Name', 15));
        shipToColumns.add(DataSource.Column.text('Address1', 32)); //Street?
        shipToColumns.add(DataSource.Column.text('Apartment', 10));
        shipToColumns.add(DataSource.Column.text('Address2', 32)); //Street?
        shipToColumns.add(DataSource.Column.text('City', 25));
        shipToColumns.add(DataSource.Column.text('State', 2));
        shipToColumns.add(DataSource.Column.text('Postal_Code', 10));
        shipToColumns.add(DataSource.Column.text('Day Phone', 14));
        shipToColumns.add(DataSource.Column.text('Evening Phone', 14));
        shipToColumns.add(DataSource.Column.text('Error', 50));
        
 
        List<DataSource.Column> orderLineColumns;
        orderLineColumns = new List<DataSource.Column>();
        
        orderLineColumns.add(DataSource.Column.text('ExternalId', 255));
        orderLineColumns.add(DataSource.Column.url('DisplayUrl'));
        orderLineColumns.add(DataSource.Column.text('Company', 3));
        orderLineColumns.add(DataSource.Column.text('Order Number',8));
        orderLineColumns.add(DataSource.Column.text('Ship To', 3));
        orderLineColumns.add(DataSource.Column.text('Sequence Number', 5));
        orderLineColumns.add(DataSource.Column.number('Line Number', 3, 0));
        orderLineColumns.add(DataSource.Column.text('Drop Ship', 1));
        orderLineColumns.add(DataSource.Column.text('Discount Applied', 8));
        orderLineColumns.add(DataSource.Column.text('Line Status', 1));
        orderLineColumns.add(DataSource.Column.text('No Charge', 1));
        orderLineColumns.add(DataSource.Column.text('Second Choice Status', 1));
        orderLineColumns.add(DataSource.Column.text('Affect Inventory', 1));
        orderLineColumns.add(DataSource.Column.text('Future Ship Date', 10));
        orderLineColumns.add(DataSource.Column.number('BO Level', 2, 0));
        orderLineColumns.add(DataSource.Column.text('Cancel Date', 10));
        orderLineColumns.add(DataSource.Column.number('Coordinate Group', 3, 0));
        orderLineColumns.add(DataSource.Column.text('Pick Print Date', 10));
        orderLineColumns.add(DataSource.Column.text('Order Reserve Date', 10));
        orderLineColumns.add(DataSource.Column.number('Discount', 5, 2));
        orderLineColumns.add(DataSource.Column.text('Expected Ship Date', 10));
        orderLineColumns.add(DataSource.Column.number('Freight Charge', 7, 2));
        orderLineColumns.add(DataSource.Column.text('FUTURE_ORDER', 1));
        orderLineColumns.add(DataSource.Column.text('Next BO Card Date', 10));
        orderLineColumns.add(DataSource.Column.number('Original Price', 7, 2));
        orderLineColumns.add(DataSource.Column.number('Unit Price', 7, 2));
        orderLineColumns.add(DataSource.Column.number('Cancel Quantity', 5, 0));
        orderLineColumns.add(DataSource.Column.number('Order Quantity', 5, 0));
        orderLineColumns.add(DataSource.Column.number('Pick Print Quantity', 5, 0));
        orderLineColumns.add(DataSource.Column.number('Reserved Quantity', 5, 0));        
        orderLineColumns.add(DataSource.Column.number('Shipped Quantity', 5, 0));
        orderLineColumns.add(DataSource.Column.number('Sold Out Quantity', 5, 0));
        orderLineColumns.add(DataSource.Column.number('Return Quantity', 5, 0));
        orderLineColumns.add(DataSource.Column.text('Bypass Reservation', 1));
        orderLineColumns.add(DataSource.Column.number('Special Handling $', 7, 2));
        orderLineColumns.add(DataSource.Column.number('Tax', 10, 5));
        orderLineColumns.add(DataSource.Column.number('GST', 10, 5));
        orderLineColumns.add(DataSource.Column.number('PST', 10, 5));
        orderLineColumns.add(DataSource.Column.number('Time Reserved', 6, 0));
        orderLineColumns.add(DataSource.Column.number('Units Confirmed', 5, 0));
        orderLineColumns.add(DataSource.Column.text('Upsell/Cross-Sell', 1));
        orderLineColumns.add(DataSource.Column.text('Gift Wrap', 1));
        orderLineColumns.add(DataSource.Column.number('Cost Override', 11, 4));
        orderLineColumns.add(DataSource.Column.text('Line Order Date', 10));
        orderLineColumns.add(DataSource.Column.number('Line Order Time', 6, 0));
        orderLineColumns.add(DataSource.Column.number('Priority', 1, 0));
        orderLineColumns.add(DataSource.Column.text('Backorder Reason', 1));
        orderLineColumns.add(DataSource.Column.text('Freight Override', 1));
        orderLineColumns.add(DataSource.Column.number('Additional Freight', 7, 2));
        orderLineColumns.add(DataSource.Column.number('Offer Price', 7, 2));
        orderLineColumns.add(DataSource.Column.text('Price Method', 1));
        orderLineColumns.add(DataSource.Column.text('Allow Repricing', 1));
        orderLineColumns.add(DataSource.Column.text('Promotion Used', 1));
        orderLineColumns.add(DataSource.Column.number('Freight Unit Charge', 7, 2));
        orderLineColumns.add(DataSource.Column.text('BOM Header', 1));
        orderLineColumns.add(DataSource.Column.number('BOM Component Sequence', 6, 0));
        orderLineColumns.add(DataSource.Column.text('Coupon', 1));
        orderLineColumns.add(DataSource.Column.number('Coupon $ Override', 7, 2));
        orderLineColumns.add(DataSource.Column.text('FT Purchase Date', 10));
        orderLineColumns.add(DataSource.Column.number('F/T Serial Number', 9, 0));
        orderLineColumns.add(DataSource.Column.number('Page Number', 5, 0));
        orderLineColumns.add(DataSource.Column.text('Page Letter', 6));
        orderLineColumns.add(DataSource.Column.number('Quantity Credited', 5, 0));
        orderLineColumns.add(DataSource.Column.text('Alias', 12));
        orderLineColumns.add(DataSource.Column.number('Pre-Discount', 7, 2));
        orderLineColumns.add(DataSource.Column.number('Duty', 7, 2));
        orderLineColumns.add(DataSource.Column.text('Sub Set', 1));
        orderLineColumns.add(DataSource.Column.number('Sub Set Sequence', 3, 0));
        orderLineColumns.add(DataSource.Column.text('Upsell Type', 1));
        orderLineColumns.add(DataSource.Column.text('Warranty Item', 1));
        orderLineColumns.add(DataSource.Column.text('Need By Date', 10));
        orderLineColumns.add(DataSource.Column.text('Tax Override', 1));
        orderLineColumns.add(DataSource.Column.number('HDL', 5, 0));
        orderLineColumns.add(DataSource.Column.number('Associated Pre Bill', 5, 0));
        orderLineColumns.add(DataSource.Column.text('Additional Charge Code', 1));
        orderLineColumns.add(DataSource.Column.text('Item Number', 12));
        orderLineColumns.add(DataSource.Column.text('Color', 4));
        orderLineColumns.add(DataSource.Column.text('Size', 4));
        orderLineColumns.add(DataSource.Column.number('Shipped DC', 3, 0));
        orderLineColumns.add(DataSource.Column.number('Cancel Reason Code', 2, 0));
        orderLineColumns.add(DataSource.Column.text('Cancel Reason', 30));
        orderLineColumns.add(DataSource.Column.text('Offer Code', 4));
        orderLineColumns.add(DataSource.Column.number('Ship Via', 2, 0));
        orderLineColumns.add(DataSource.Column.text('Source Code', 9));
        orderLineColumns.add(DataSource.Column.text('Second Choice Item', 12));
        orderLineColumns.add(DataSource.Column.text('Second Choice SKU', 14));
        orderLineColumns.add(DataSource.Column.text('Price Override Code', 1));
        orderLineColumns.add(DataSource.Column.number('Backorder Warehouse', 3, 0));
        orderLineColumns.add(DataSource.Column.text('Add-On Code', 3));
        orderLineColumns.add(DataSource.Column.number('Reserve DC', 3, 0));
        orderLineColumns.add(DataSource.Column.text('Shipped Date', 10));
        orderLineColumns.add(DataSource.Column.text('CW SKU ID', 20));
        */
        
        List<DataSource.Column> orderNoteColumns;
        orderNoteColumns = new List<DataSource.Column>();
                
        orderNoteColumns.add(DataSource.Column.text('ExternalId', 255));
        orderNoteColumns.add(DataSource.Column.url('DisplayUrl'));
        orderNoteColumns.add(DataSource.Column.text('Company', 3));
        orderNoteColumns.add(DataSource.Column.text('Order Number',8));
        orderNoteColumns.add(DataSource.Column.text('Ship To', 3));
        orderNoteColumns.add(DataSource.Column.number('Sequence Number', 4,0)); 
        orderNoteColumns.add(DataSource.Column.text('Message', 60));
        orderNoteColumns.add(DataSource.Column.text('Message Type', 7));
        orderNoteColumns.add(DataSource.Column.text('User', 8));    
        orderNoteColumns.add(DataSource.Column.text('Date', 10)); 
        
         
        //tables.add(DataSource.Table.get('CW Invoice','Invoice Number', invoicePaymentColumns)); 
        //tables.add(DataSource.Table.get('CW Ship To','Ship To', shipToColumns));
        //tables.add(DataSource.Table.get('CW Order Line','Line Number', orderLineColumns)); 
        tables.add(DataSource.Table.get('CW Order Note','Sequence Number', orderNoteColumns));
              
        return tables;
    }
   
      /**
     *   Called to query and get results from the external 
     *   system for SOQL queries, list views, and detail pages 
     *   for an external object that’s associated with the 
     *   external data source.
     *   
     *   The QueryContext argument represents the query to run 
     *   against a table in the external system.
     *   
     *   Returns a list of rows as the query results.
     **/
        override global DataSource.TableResult query(
        DataSource.QueryContext context) {
            
        System.debug('Query Context: ' + context);
        
        List<Map<String, Object>> rows = new List<Map<String, Object>>();
        
        DataSource.Filter filter = context.tableSelection.filter;
        String url;
        String dataSourceType;
        
        System.debug('*****In query*****');
        System.debug('Filter ------> '+ filter); 
        System.debug('ColumnValue: '+ filter.columnValue);
              
        if (filter != null){
            String thisColumnName = filter.columnName;
            String thisColumnValue = String.valueOf(filter.columnValue);
            String thisTableName = filter.tableName;
          /*              
          if (thisColumnName == 'Order Number' && thisTableName.equals('CW Invoice')){ // Pull back Billing data for Order
                    if(Test.isRunningTest()){
                            url = 'https://servicesuat.restorationhardware.com:10000/lightning/billing?OrderNumber=331971';
                        }else{
                            RH_Web_Services__c dataSource = RH_Web_Services__c.getInstance('External Data Source - Billing');   
                            url = dataSource.Service_URL__c + thisColumnValue;
                    }
                    System.debug('Url :' + url);
                    dataSourceType = 'Billing';             
                    
                    rows = getData(url, dataSourceType, null); 
                    }
            else
            */ 
            if (thisColumnName == 'Order Number' && thisTableName.equals('CW Order Note')){ // Pull back Notes data for Order based on Ship To
                    RH_Web_Services__c dataSource = RH_Web_Services__c.getInstance('External Data Source - Order Note');                
                    dataSourceType = 'Order Note';
                    
                    // Build and sort asc list of ship tos
                    List<Ship_To__c> shipToList = new List<Ship_To__c>(); 
                    
                    shipToList = [Select Name from Ship_To__c where RH_Order_Number__c = :thisColumnValue];
                    shipToList.sort();
                    
                    // Step through Ship To list and get notes for each one. Add these to the returned rows.                    
                  
                    if(Test.isRunningTest()){
                            url = 'https://test.restorationhardware.com:10000/orderLines?OrderNumber=331971&shipToNumber=1';
                            rows.addAll(getData(url, dataSourceType, '1'));
                    }else{    	
                    	for(Ship_To__c ST:shipToList){
                            url = dataSource.Service_URL__c + thisColumnValue + '&shipToNumber=' + ST.Name;
                            
                            rows.addAll(getData(url, dataSourceType, ST.Name));
                    	}
                    }            
            }
                    /*
            else if (thisColumnName == 'Order Number' && thisTableName.equals('CW Order Line')){ // Pull back Order Line data for Order
                    RH_Web_Services__c dataSource = RH_Web_Services__c.getInstance('External Data Source - Order Line');                
                    url = dataSource.Service_URL__c + thisColumnValue;
                    //url = 'https://servicesuat.restorationhardware.com:10000/Fail';
                    dataSourceType = 'Order Line';
                    
                    rows = getData(url, dataSourceType, null);      
                    }
            
            else if (thisColumnName == 'Order Number' && thisTableName.equals('CW Ship To')){ // Pull back Ship To data for Order
                    RH_Web_Services__c dataSource = RH_Web_Services__c.getInstance('External Data Source - Ship To');               
                    url = dataSource.Service_URL__c + thisColumnValue;
                    dataSourceType = 'Ship To'; 
                        
                    rows = getData(url, dataSourceType, null); 
                    }
                                   
            else if (thisColumnName == 'ExternalId' && thisTableName.equals('CW Order Line')){ // Pull back Order Line data for selected Order Line
                    String externalId = string.valueOf(filter.columnValue);
                                    
                    String[] externalIdElements = externalId.split('-',0);
                                        
                    RH_Web_Services__c dataSource = RH_Web_Services__c.getInstance('External Data Source - Order Line');            
                    url = dataSource.Service_URL__c + externalIdElements[0]+'&shipToNumber='+externalIdElements[1]+'&orderLineNum='+externalIdElements[2];
                    dataSourceType = 'Order Line'; 
                    
                    rows = getData(url, dataSourceType, null);              
                    }
            
            else if (thisColumnName == 'ExternalId' && thisTableName.equals('CW Ship To')){ // Pull back Ship To data for selected Ship To
                    RH_Web_Services__c dataSource = RH_Web_Services__c.getInstance('External Data Source - Ship To');               
                    //url = dataSource.Service_URL__c + filter.columnValue;
                    dataSourceType = 'Ship To';
                    
                    rows = getData(url, dataSourceType, null);                          
                    }
                    */      
            }
        
        return DataSource.TableResult.get(true, null,context.tableSelection.tableSelected, rows, rows.size());
    }
    
    /**
     *   Called to do a full text search and get results from
     *   the external system for SOSL queries and Salesforce
     *   global searches.
     *   
     *   The SearchContext argument represents the query to run 
     *   against a table in the external system.
     *   
     *   Returns results for each table that the SearchContext 
     *   requested to be searched.
     **/
   
    override global List<DataSource.TableResult> 
        search(DataSource.SearchContext context) {        
        return DataSource.SearchUtils.searchByName(context, this);
    }
    
    
    /**
     *   Helper method to parse the data.
     *   The url argument is the URL of the external system.
     *   Returns a list of rows from the external system.
     **/
    public List<Map<String, Object>> getData(String url, String dataSourceType, String orderNoteShipTo) {
        
        System.debug('*****In getData*****');
        
        HttpResponse response = getResponse(url);

        List<Map<String, Object>> rows = new List<Map<String, Object>>();
        
        List<Object> responseBody = new List<Object>();
        Map<String, Object> responseBodyMap = new Map<String, Object>();
        
        System.debug('Inside getData with url: '+ url+ ' Response object'+response.getBody());  
                
        try{
            if(dataSourceType == 'Order Note') 
            {
                responseBodyMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody()); // For Order Notes will be a Map or a List of Maps
            }
            else{
                responseBody = (List<Object>) JSON.deserializeUntyped(response.getBody()); // For Billing will be List of Objects
            }
            System.debug('Response Body is: '+ responseBody);
            System.debug('Response Body Map is: '+ responseBodyMap);
        }
        catch(System.JSONException e) {
                System.debug('JSON error: '+ e);
            }       

        System.debug('Data Source Requested: ' + dataSourceType);
 		
 		/*
        if (responseBody != null && dataSourceType == 'Billing') { 
            for(Integer i=0;i<responseBody.size();i++){
            Map<String, Object> responseObj = (Map<String, Object>) responseBody.get(i);
            
            Map<String, Object> invoicePaymentItem = new Map<String, Object>();
 
            invoicePaymentItem.put('Company',responseObj.get('COMPANY'));
            invoicePaymentItem.put('CW Order Number',responseObj.get('ORDER_NUMBER'));
            invoicePaymentItem.put('Ship To Number (IST)',responseObj.get('INV_SHIP_TO_NUMBER'));
            invoicePaymentItem.put('Invoice Order Line Sequence Number',responseObj.get('INVOICE_ORDER_LINE_SEQUENCE_NUMBER'));
            invoicePaymentItem.put('Invoice Date',responseObj.get('INVOICE_DATE'));
            invoicePaymentItem.put('Invoice Number',responseObj.get('INVOICE_NUMBER'));
            invoicePaymentItem.put('Invoice Line Number',responseObj.get('INVOICE_LINE_NUMBER')); 
            invoicePaymentItem.put('Invoice Type',responseObj.get('INVOICE_TYPE'));
            invoicePaymentItem.put('Additional Charge Amount (IST)',responseObj.get('INV_SHIP_TO_ADDITIONAL_CHARGE_AMOUNT'));
            invoicePaymentItem.put('Additional Freight Amount (IST)',responseObj.get('INV_SHIP_TO_ADDITIONAL_FREIGHT_AMOUNT'));
            invoicePaymentItem.put('Payment Additional Charge Amount',responseObj.get('PAYMENT_ADDITIONAL_CHARGE'));
            invoicePaymentItem.put('Payment Additional Freight Amount',responseObj.get('PAYMENT_ADDITIONAL_FREIGHT'));
            invoicePaymentItem.put('Freight Amount (IST)',responseObj.get('INV_SHIP_TO_FREIGHT_AMOUNT'));
            invoicePaymentItem.put('GST Amount (IST)',responseObj.get('INV_SHIP_TO_GST_AMOUNT'));
            invoicePaymentItem.put('Handling Amount (IST)',responseObj.get('INV_SHIP_TO_HANDLING_AMOUNT'));
            invoicePaymentItem.put('Merchandise Amount (IST)',responseObj.get('INV_SHIP_TO_MERCHANDISE_AMOUNT'));
            invoicePaymentItem.put('PST Amount (IST)',responseObj.get('INV_SHIP_TO_PST_AMOUNT'));
            invoicePaymentItem.put('Tax Amount (IST)',responseObj.get('INV_SHIP_TO_TAX_AMOUNT'));    
            invoicePaymentItem.put('Freight Amount (IL)',responseObj.get('INVOICE_LINE_FREIGHT_AMOUNT'));       
            invoicePaymentItem.put('GST Amount (IL)',responseObj.get('INVOICE_LINE_GST_AMOUNT'));
            invoicePaymentItem.put('Handling Amount (IL)',responseObj.get('INVOICE_LINE_HANDLING_AMOUNT'));
            invoicePaymentItem.put('PST Amount (IL)',responseObj.get('INVOICE_LINE_PST_AMOUNT'));
            invoicePaymentItem.put('Tax Amount (IL)',responseObj.get('INVOICE_LINE_TAX_AMOUNT'));
            invoicePaymentItem.put('Date Shipped',responseObj.get('DATE_SHIPPED'));
            invoicePaymentItem.put('Payment Category',responseObj.get('PAYMENT_CATEGORY'));
            invoicePaymentItem.put('Payment Category Description',responseObj.get('PAYMENT_CATEGORY_DESCRIPTION'));
            invoicePaymentItem.put('Payment Type',responseObj.get('PAYMENT_TYPE'));
            invoicePaymentItem.put('Payment Type Description',responseObj.get('PAYMENT_TYPE_DESCRIPTION'));
            invoicePaymentItem.put('Credit Card Number',responseObj.get('CREDIT_CARD_NUMBER'));
            invoicePaymentItem.put('Payment Freight Amount',responseObj.get('PAYMENT_FREIGHT_AMOUNT'));
            invoicePaymentItem.put('Payment GST Amount',responseObj.get('PAYMENT_GST_AMOUNT'));
            invoicePaymentItem.put('Payment Handling Amount',responseObj.get('PAYMENT_HANDLING_AMOUNT'));
            invoicePaymentItem.put('Merchandise Unit Price (IL)',responseObj.get('INVOICE_LINE_MERCHANDISE_UNIT_PRICE'));
            invoicePaymentItem.put('Order Payment Sequence Number',responseObj.get('ORDER_PAYMENT_SEQUENCE_NUMBER'));
            invoicePaymentItem.put('Order Level Freight Tax',responseObj.get('ORDER_LEVEL_FREIGHT_TAX'));
            invoicePaymentItem.put('Order Line Description',responseObj.get('ORDER_LINE_DESCRIPTION'));
            invoicePaymentItem.put('Payment Merchandise Amount',responseObj.get('PAYMENT_MERCHANDISE_AMOUNT'));
            invoicePaymentItem.put('Payment PST Amount',responseObj.get('PAYMENT_PST_AMOUNT'));
            invoicePaymentItem.put('Payment Tax Amount',responseObj.get('PAYMENT_TAX_AMOUNT'));
            invoicePaymentItem.put('Quantity Shipped',responseObj.get('QUANTITY_SHIPPED'));
            invoicePaymentItem.put('Item Number',responseObj.get('ITEM_NUMBER'));
            invoicePaymentItem.put('Color Code',responseObj.get('COLOR_CODE'));
            invoicePaymentItem.put('Size Code',responseObj.get('SIZE_CODE'));
            invoicePaymentItem.put('Pre Bill Item Number',responseObj.get('PRE_BILL_ITEM_NUMBER'));
            invoicePaymentItem.put('Pre Bill Color Code',responseObj.get('PRE_BILL_COLOR_CODE'));
            invoicePaymentItem.put('Pre Bill Size Code',responseObj.get('PRE_BILL_SIZE_CODE'));
            invoicePaymentItem.put('BOM Header Flag',responseObj.get('BOM_HEADER_FLAG'));
            invoicePaymentItem.put('BOM Component Sequence',responseObj.get('BOM_COMPONENT_SEQUENCE'));             
            
            //Set the External Ids for Invoice Payment Items: "Order Number"-"Invoice Number"-"Invoice Ship To Number (IST)"-"Invoice Order Line Sequence Number"-"Order Payment Sequence Number"
            String extId = String.valueOf(invoicePaymentItem.get('Order Number')) 
            + '-' + String.valueOf(invoicePaymentItem.get('Invoice Number')) 
            + '-' + String.valueOf(invoicePaymentItem.get('Ship To Number (IST)')) 
            + '-' + String.valueOf(invoicePaymentItem.get('Invoice Order Line Sequence Number'))
            + '-' + String.valueOf(invoicePaymentItem.get('Invoice Line Number')) 
            + '-' + String.valueOf(invoicePaymentItem.get('Order Payment Sequence Number'));
            invoicePaymentItem.put('ExternalId',extId); 
            
            rows.add(invoicePaymentItem);
            } 
        }   
            
      else if (responseBody != null && dataSourceType == 'Order Line') { 
            for(Integer i=0;i<responseBody.size();i++){
            Map<String, Object> responseObj = (Map<String, Object>) responseBody.get(i);
        
            Map<String, Object> orderLineItem = new Map<String, Object>();
        
            orderLineItem.put('Company',responseObj.get('COMPANY'));
            orderLineItem.put('Order Number',responseObj.get('RH_ORDER_NUMBER'));
            orderLineItem.put('Ship To',responseObj.get('SHIP_TO'));
            orderLineItem.put('Sequence Number',responseObj.get('SEQUENCE_NUMBER'));
            orderLineItem.put('Line Number',responseObj.get('LINE_NUMBER'));
            orderLineItem.put('Drop Ship',responseObj.get('DROP_SHIP'));
            orderLineItem.put('Discount Applied',responseObj.get('DISCOUNT_APPLIED'));
            orderLineItem.put('Line Status',responseObj.get('LINE_STATUS'));
            orderLineItem.put('No Charge',responseObj.get('NO_CHARGE'));
            orderLineItem.put('Second Choice Status',responseObj.get('SECOND_CHOICE_STATUS'));
            orderLineItem.put('Affect Inventory',responseObj.get('AFFECT_INVENTORY'));
            orderLineItem.put('Future Ship Date', responseObj.get('FUTURE_SHIP_DATE'));
            orderLineItem.put('BO Level',responseObj.get('BO_LEVEL'));
            orderLineItem.put('Cancel Date',responseObj.get('CANCEL_DATE'));
            orderLineItem.put('Coordinate Group',responseObj.get('COORDINATE_GROUP'));
            orderLineItem.put('Pick Print Date',responseObj.get('PICK_PRINT_DATE'));
            orderLineItem.put('Order Reserve Date',responseObj.get('ORDER_RESERVE_DATE'));
            orderLineItem.put('Discount',responseObj.get('DISCOUNT'));
            orderLineItem.put('Expected Ship Date',responseObj.get('EXPECTED_SHIP_DATE'));
            orderLineItem.put('Freight Charge',responseObj.get('FREIGHT_CHARGE'));
            orderLineItem.put('Future Order',responseObj.get('FUTURE_ORDER'));
            orderLineItem.put('Next BO Card Date',responseObj.get('NEXT_BO_CARD_DATE'));
            orderLineItem.put('Original Price',responseObj.get('ORIGINAL_PRICE'));
            orderLineItem.put('Unit Price',responseObj.get('UNIT_PRICE'));
            orderLineItem.put('Cancel Quantity',responseObj.get('CANCEL_QUANTITY'));
            orderLineItem.put('Order Quantity',responseObj.get('ORDER_QUANTITY'));
            orderLineItem.put('Pick Print Quantity',responseObj.get('PICK_PRINT_QUANTITY'));
            orderLineItem.put('Reserved Quantity',responseObj.get('RESERVED_QUANTITY'));
            orderLineItem.put('Shipped Quantity',responseObj.get('SHIPPED_QUANTITY'));
            orderLineItem.put('Sold Out Quantity',responseObj.get('SOLD_OUT_QUANTITY'));
            orderLineItem.put('Return Quantity',responseObj.get('RETURN_QUANTITY'));
            orderLineItem.put('Bypass Reservation',responseObj.get('BYPASS_RESERVATION'));
            orderLineItem.put('Special Handling',responseObj.get('SPECIAL_HANDLING'));
            orderLineItem.put('Tax',responseObj.get('TAX'));
            orderLineItem.put('GST',responseObj.get('GST'));
            orderLineItem.put('PST',responseObj.get('PST'));
            orderLineItem.put('Time Reserved',responseObj.get('TIME_RESERVED'));
            orderLineItem.put('Units Confirmed',responseObj.get('UNITS_CONFIRMED'));
            orderLineItem.put('Upsell/Cross-Sell',responseObj.get('UPSELL_CROSS_SELL'));
            orderLineItem.put('Gift Wrap',responseObj.get('GIFT_WRAP'));
            orderLineItem.put('Cost Override',responseObj.get('COST_OVERRIDE'));
            orderLineItem.put('Line Order Date',responseObj.get('LINE_ORDER_DATE'));
            orderLineItem.put('Line Order Time',responseObj.get('LINE_ORDER_TIME'));
            orderLineItem.put('Priority',responseObj.get('PRIORITY'));
            orderLineItem.put('Backorder Reason',responseObj.get('BACKORDER_REASON'));
            orderLineItem.put('Freight Override',responseObj.get('FREIGHT_OVERRIDE'));
            orderLineItem.put('Additional Freight',responseObj.get('ADDITIONAL_FREIGHT'));
            orderLineItem.put('Offer Price',responseObj.get('OFFER_PRICE'));
            orderLineItem.put('Price Method',responseObj.get('PRICE_METHOD'));
            orderLineItem.put('Allow Repricing',responseObj.get('ALLOW_REPRICING'));
            orderLineItem.put('Promotion Used',responseObj.get('PROMOTION_USED'));
            orderLineItem.put('Freight Unit Charge',responseObj.get('FREIGHT_UNIT_CHARGE'));
            orderLineItem.put('BOM Header',responseObj.get('BOM_HEADER'));
            orderLineItem.put('BOM Component Sequence',responseObj.get('BOM_COMPONENT_SEQUENCE'));
            orderLineItem.put('Coupon',responseObj.get('COUPON'));
            orderLineItem.put('Coupon $ Override',responseObj.get('COUPON_$_OVERRIDE'));
            orderLineItem.put('FT Purchase Date',responseObj.get('FT_PURCHASE_DATE'));
            orderLineItem.put('F/T Serial Number',responseObj.get('FT_SERIAL'));
            orderLineItem.put('Page',responseObj.get('PAGE'));
            orderLineItem.put('Page Letter',responseObj.get('PAGE_LETTER'));
            orderLineItem.put('Quantity Credited',responseObj.get('QUANTITY_CREDITED'));
            orderLineItem.put('Alias',responseObj.get('ALIAS'));
            orderLineItem.put('Pre-Discount',responseObj.get('PRE_DISCOUNT'));
            orderLineItem.put('Duty',responseObj.get('DUTY'));
            orderLineItem.put('Sub Set',responseObj.get('SUB_SET'));
            orderLineItem.put('Sub Set Sequence',responseObj.get('SUB_SET_SEQUENCE'));
            orderLineItem.put('Upsell Type',responseObj.get('UPSELL_TYPE'));
            orderLineItem.put('Warranty Item',responseObj.get('WARRANTY_ITEM'));
            orderLineItem.put('Need By Date',responseObj.get('NEED_BY_DATE'));
            orderLineItem.put('Tax Override',responseObj.get('TAX_OVERRIDE'));
            orderLineItem.put('HDL',responseObj.get('HDL'));
            orderLineItem.put('Associated Pre Bill',responseObj.get('ASSOCIATED_PRE_BILL'));
            orderLineItem.put('Additional Charge Code',responseObj.get('ADDITIONAL_CHARGE_CODE'));
            orderLineItem.put('Item Number',responseObj.get('ITEM_NUMBER'));
            orderLineItem.put('Color',responseObj.get('COLOR'));
            orderLineItem.put('Size',responseObj.get('SIZE'));
            orderLineItem.put('Shipped DC',responseObj.get('SHIPPED_DC'));
            orderLineItem.put('Cancel Reason Code',responseObj.get('CANCEL_REASON_CODE'));
            orderLineItem.put('Cancel Reason',responseObj.get('CANCEL_REASON'));
            orderLineItem.put('Offer Code',responseObj.get('OFFER_CODE'));
            orderLineItem.put('Ship Via',responseObj.get('SHIP_VIA'));
            orderLineItem.put('Source Code',responseObj.get('SOURCE_CODE'));
            orderLineItem.put('Second Choice Item',responseObj.get('SECOND_CHOICE_ITEM'));
            orderLineItem.put('Second Choice SKU',responseObj.get('SECOND_CHOICE_SKU'));
            orderLineItem.put('Price Override Code',responseObj.get('PRICE_OVERRIDE_CODE'));
            orderLineItem.put('Back Order Warehouse',responseObj.get('BACK_ORDER_WAREHOUSE'));
            orderLineItem.put('Add-On Code',responseObj.get('ADD_ON_CODE'));
            orderLineItem.put('Reserve DC',responseObj.get('RESERVE_DC'));
            orderLineItem.put('Shipped Date',responseObj.get('SHIPPED_DATE'));
            orderLineItem.put('CW SKU ID',responseObj.get('CW_SKU_ID'));
                        
            //Set the External Ids for Order Lines: "Order Number"-"Ship To Number"-"Line Number"
            String extId = String.valueOf(orderLineItem.get('Order Number')) 
            + '-' + String.valueOf(orderLineItem.get('Ship To')) 
            + '-' + String.valueOf(orderLineItem.get('Line Number'));
            orderLineItem.put('ExternalId',extId); 
        
            rows.add(orderLineItem);
            System.debug('Order Line Rows: '+ rows);
            }   
        } 
        
        else if(responseBody != null && dataSourceType == 'Ship To') {
            for(Integer i=0;i<responseBody.size();i++){
            Map<String, Object> responseObj = (Map<String, Object>) responseBody.get(i);
        
            Map<String, Object> shipToItem = new Map<String, Object>();
            
            shipToItem.put('Company',responseObj.get('COMPANY_NUMBER')); 
            shipToItem.put('Order Number',responseObj.get('ORDER_NUMBER'));
            shipToItem.put('Ship To Number',responseObj.get('ORDER_SHIP_TO'));
            shipToItem.put('Customer Number',responseObj.get('CUSTOMER_NUMBER'));
            shipToItem.put('Merchandise Subtotal',responseObj.get('MERCH_SUBTOTAL'));
            shipToItem.put('Merchandise Balance',responseObj.get('MERCH_BALANCE'));
            shipToItem.put('Handling',responseObj.get('HANDLING'));
            shipToItem.put('Handling Balance',responseObj.get('HANDLING_BALANCE'));
            shipToItem.put('Freight',responseObj.get('FREIGHT'));
            shipToItem.put('Freight Balance',responseObj.get('FREIGHT_BALANCE'));
            shipToItem.put('Freight Override',responseObj.get('FREIGHT_OVERRIDE'));
            shipToItem.put('Additional Freight',responseObj.get('ADDITIONAL_FREIGHT'));
            shipToItem.put('Additional Freight Balance',responseObj.get('ADDITIONAL_FREIGHT_BALANCE'));
            shipToItem.put('Tax',responseObj.get('TAX_BALANCE'));
            shipToItem.put('GST',responseObj.get('GST'));
            shipToItem.put('GST Balance',responseObj.get('GST_BALANCE'));
            shipToItem.put('PST',responseObj.get('PST'));
            shipToItem.put('PST Balance',responseObj.get('PST_BALANCE'));
            shipToItem.put('Addtional Charge',responseObj.get('ADDITIONAL_CHARGE'));
            shipToItem.put('Addtional Charge Balance',responseObj.get('ADDITIONAL_CHARGE_BALANCE'));
            shipToItem.put('Email',responseObj.get('EMAIL'));
            shipToItem.put('Last Name',responseObj.get('LAST_NAME'));
            shipToItem.put('Middle Initial',responseObj.get('MIDDLE_INITIAL'));
            shipToItem.put('First Name',responseObj.get('FIRST_NAME'));
            shipToItem.put('Address1',responseObj.get('ADDRESS1'));
            shipToItem.put('Apartment',responseObj.get('APARTMENT'));
            shipToItem.put('Address2',responseObj.get('ADDRESS2'));
            shipToItem.put('City',responseObj.get('CITY'));
            shipToItem.put('State',responseObj.get('STATE'));
            shipToItem.put('Postal Code',responseObj.get('POSTAL_CODE'));
            shipToItem.put('Day Phone',responseObj.get('DAY_PHONE'));
            shipToItem.put('Evening Phone',responseObj.get('EVENING_PHONE'));
            shipToItem.put('Error',responseObj.get('ERROR'));  
            
            // Set the External Ids for Ship Tos: "Order Number (CW)"-"Ship To Number"
            String extId = String.valueOf(shipToItem.get('Order Number')) 
            + '-' + String.valueOf(shipToItem.get('Ship To Number'));
            shipToItem.put('ExternalId',extId);  
            
            rows.add(shipToItem); 
            }    
        }
        */ 
        if(responseBodyMap != null && dataSourceType == 'Order Note') {
            
            // Parse through the Order Notes response body. If the total notes > 1 then this will be a List of Maps. If the total notes == 1 then this will be a Map.  
            
            Map<String, Object> orderNoteItem;
            Map<String, Object> orderNoteJsonObj=(Map<String, Object>)responseBodyMap.get('viewNotesResponse');
                        
            Object orderNumber = orderNoteJsonObj.get('order_nbr');
            Integer totalNotes = Integer.valueOf(((Map<String, Object>)orderNoteJsonObj.get('Notes_list')).get('total_notes'));
 
             if(totalNotes > 1){
                List<Object> notesObj = (List<Object>)((Map<String, Object>)orderNoteJsonObj.get('Notes_list')).get('note');
                for(Object note:notesObj){
                    Map<String, Object> noteMap = (Map<String, Object>) note;
                    Map<String, Object> noteInner = (Map<String, Object>) noteMap.get('detail');
                    orderNoteItem = new Map<String, Object>();
                	if(rows.isEmpty()){
                		orderNoteItem.put('Date',noteInner.get('Date'));
                		if(noteInner.get('Message') != null){
                			orderNoteItem.put('Message', noteInner.get('Message'));
                		}else{
                			orderNoteItem.put('Message', '');
                		}
               			orderNoteItem.put('Ship To', orderNoteShipTo);
                		orderNoteItem.put('User',noteInner.get('User'));
                		orderNoteItem.put('ExternalId', orderNumber + '-' + orderNoteShipTo + '-' + noteMap.get('SequenceNbr'));
                		if(noteInner.get('MsgType')=='H'){
                			orderNoteItem.put('MsgType', 'H');
                        	orderNoteItem.put('Message Type','History');
                    	}else{
                    		orderNoteItem.put('MsgType', 'O');
                        	orderNoteItem.put('Message Type','Note');
                    	}
                    	rows.add(orderNoteItem);
                	}else{
                		Integer i = rows.size();
                		
                		System.debug('DATES: ' + noteInner.get('Date') + ' - ' + rows[i-1].get('Date'));
                		System.debug('MSG TYPES: ' + noteInner.get('MsgType') + ' - ' + rows[i-1].get('MsgType'));
                		System.debug('SHIP TOs: ' + orderNoteShipTo + ' - ' + rows[i-1].get('MsgType'));
                		System.debug('USER: ' + noteInner.get('User') + ' - ' + rows[i-1].get('User'));
                		
                		if ((noteInner.get('Date') == rows[i-1].get('Date')) && (noteInner.get('MsgType') == rows[i-1].get('MsgType')) && (orderNoteShipTo == rows[i-1].get('Ship To')) && (noteInner.get('User') == rows[i-1].get('User'))) {
                			if(noteInner.get('Message') != null){
                				rows[i-1].put('Message', rows[i-1].get('Message') + '</br>' + noteInner.get('Message'));	
                			}else{
                				rows[i-1].put('Message', rows[i-1].get('Message') + '</br>');	
                			}
						}else{
							orderNoteItem.put('Date',noteInner.get('Date'));
                			orderNoteItem.put('Message', noteInner.get('Message'));
                			if(noteInner.get('Message') != null){
                				orderNoteItem.put('Message', noteInner.get('Message'));
                			}else{
                				orderNoteItem.put('Message', '');
                			}
               				orderNoteItem.put('Ship To', orderNoteShipTo);
                			orderNoteItem.put('User',noteInner.get('User'));
                			orderNoteItem.put('ExternalId', orderNumber + '-' + orderNoteShipTo + '-' + noteMap.get('SequenceNbr'));
                			if(noteInner.get('MsgType')=='H'){
                				orderNoteItem.put('MsgType', 'H');
                        		orderNoteItem.put('Message Type','History');
                    		}else{
                    			orderNoteItem.put('MsgType', 'O');
                        		orderNoteItem.put('Message Type','Note');
                    		}
                    		rows.add(orderNoteItem);
						}
                    }
                }
            }else if(totalNotes == 1){  
                Object notesObj = ((Map<String, Object>)orderNoteJsonObj.get('Notes_list')).get('note');
                Map<String, Object> noteMap = (Map<String, Object>) notesObj;
                Map<String, Object> noteInner = (Map<String, Object>) noteMap.get('detail');
                orderNoteItem = new Map<String, Object>();
                
                orderNoteItem.put('Date',noteInner.get('Date'));
                orderNoteItem.put('Message', noteInner.get('Message'));
               	orderNoteItem.put('Ship To', orderNoteShipTo);
                orderNoteItem.put('User',noteInner.get('User'));
                orderNoteItem.put('ExternalId', orderNumber + '-' + orderNoteShipTo + '-' + noteMap.get('SequenceNbr'));
                if(noteInner.get('MsgType')=='H'){
                	orderNoteItem.put('MsgType', 'H');
                    orderNoteItem.put('Message Type','History');
               	}else if(noteInner.get('MsgType')=='O'){
                	orderNoteItem.put('MsgType', 'O');
                	orderNoteItem.put('Message Type','Note');
                }else{
                	orderNoteItem.put('MsgType', 'C');
                	orderNoteItem.put('Message Type','Concierge');
                }
                rows.add(orderNoteItem);
            }           
        }                   
        return rows;
    }
  
     /**
     *   Helper method to make the HTTP GET call.
     *   The url argument is the URL of the external system.
     *   Returns the response from the external system.
     **/
    public HttpResponse getResponse(String url) {
        
        System.debug('*****In getResponse*****');

        HttpResponse response = new HttpResponse();
            
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndPoint(url);
        request.setMethod('GET');
        try{
            response = httpProtocol.send(request);      
        }catch(Exception e){
            System.debug('Callout error: '+ e); 
        } 
      return response;  
    }    
}