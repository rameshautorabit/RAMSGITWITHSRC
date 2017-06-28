/* Test class for CWDataSourceConnection */

@isTest
private class CWDataSourceConnection_Test {
    
    @isTest
    static void syncUnitTest() {
        
        //Retrieve results of CWDataSourceConnection.sync()
        List<DataSource.Table> tables = new List<DataSource.Table>();
        
        CWDataSourceConnection testConnection = new CWDataSourceConnection();
        tables = testConnection.sync();
        
        //Build test data
        List<DataSource.Table> testTables = new List<DataSource.Table>();
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
                            
        //testTables.add(DataSource.Table.get('CW Invoice','Invoice Number', invoicePaymentColumns)); 
        testTables.add(DataSource.Table.get('CW Order Note','Sequence Number', orderNoteColumns)); 
        
        //Compare retrieved data against test data    
        System.assertEquals(tables, testTables);
    }
    
    /*
    @isTest
    static void queryInvoiceUnitTest() {     
      // create the QueryContext class
      DataSource.QueryContext context = new DataSource.QueryContext();
      // create the filter class and set the ColumnName
      DataSource.Filter filter = new DataSource.Filter();
      filter.columnName = 'Order Number';
      filter.tableName = 'CW Invoice';
      filter.columnValue='331971';
 
      //create the TableSelection class, set the filter and add it to the QueryContext
      DataSource.TableSelection tableSelection = new DataSource.TableSelection();
      tableSelection.tableSelected = 'CW Invoice';
      tableSelection.filter = filter;
      context.TableSelection = tableSelection;
      
      System.debug('Invoice Query context : ' + context);
       
      // tell the Testing framework to use the mockHttpResponseGenerator for all Http Callouts in this test  
      Test.setMock(HttpCalloutMock.class, new MockInvoiceHttpResponseGenerator());
      Test.startTest();
      CWDataSourceConnection connection = new CWDataSourceConnection();
      DataSource.TableResult result = connection.query(context);
      Test.stopTest();
      system.assertEquals(result.tableName, 'CW Invoice'); 
   }
   */
   
   @isTest
    static void querySingleOrderNoteUnitTest() {   
      // create the QueryContext class
      DataSource.QueryContext context = new DataSource.QueryContext();
      // create the filter class and set the ColumnName
      DataSource.Filter filter = new DataSource.Filter();
      filter.columnName = 'Order Number';
      filter.tableName = 'CW Order Note';
      filter.columnValue='331971';
 
      // create the TableSelection class, set the filter and add it to the QueryContext
      DataSource.TableSelection tableSelection = new DataSource.TableSelection();
      tableSelection.tableSelected = 'CW Order Note'; 
      tableSelection.filter = filter;
      context.TableSelection = tableSelection;
       
      // tell the Testing framework to use the mockHttpResponseGenerator for all Http Callouts in this test  
      
      Test.setMock(HttpCalloutMock.class, new MockOrderNoteHttpResponseGenerator());
      Test.startTest();
      CWDataSourceConnection connection = new CWDataSourceConnection();
      DataSource.TableResult result = connection.query(context);
      System.debug('Query result: ' + result);
      Test.stopTest();
      system.assertEquals(result.tableName, 'CW Order Note');
   }
   
   @isTest
    static void queryMultipleOrderNoteUnitTest() {   
      // create the QueryContext class
      DataSource.QueryContext context = new DataSource.QueryContext();
      // create the filter class and set the ColumnName
      DataSource.Filter filter = new DataSource.Filter();
      filter.columnName = 'Order Number';
      filter.tableName = 'CW Order Note';
      filter.columnValue='331971';
 
      // create the TableSelection class, set the filter and add it to the QueryContext
      DataSource.TableSelection tableSelection = new DataSource.TableSelection();
      tableSelection.tableSelected = 'CW Order Note'; 
      tableSelection.filter = filter;
      context.TableSelection = tableSelection;
       
      // tell the Testing framework to use the mockHttpResponseGenerator for all Http Callouts in this test  
      
      Test.setMock(HttpCalloutMock.class, new MockOrderNotesHttpResponseGenerator());
      Test.startTest();
      CWDataSourceConnection connection = new CWDataSourceConnection();
      DataSource.TableResult result = connection.query(context);
      System.debug('Query result: ' + result);
      Test.stopTest();
      system.assertEquals(result.tableName, 'CW Order Note');
   }
   
   
}