public with sharing class CWConnection {
    
    /*
     *  Methods to work with the CWConnection external data source.
     *
     */
    
    // Return a List of all Invoices for a given Order Number.  
    // Each Invoice row will contain all fields of the external object.
    public static List<CW_Invoice__x> getCWInvoiceAllFields(String orderNumber) {
        // Get all the object field names and build the query
        String query = 'SELECT';
        Map<String,Schema.SObjectField> FieldMap = Schema.SObjectType.CW_Invoice__x.fields.getMap();
        
        //system.debug('***** number of fields = ' + FieldMap.size());
        
        for (Schema.SObjectField f : FieldMap.values()) {
            //Schema.DescribeFieldResult DescField = f.getDescribe();
            //system.debug('Name: ' +  DescField.getName());
            //system.debug('Type: ' +  DescField.getType());
            query += ' ' + f.getDescribe().getName() + ',';
        }
        query = query.removeEnd(',');
        query += ' FROM CW_Invoice__x WHERE Order_Number__c = \'' + orderNumber + '\'';
        
        //system.debug('***** query string = ' + query); 
        
        List<CW_Invoice__x> cwInvoices = new List<CW_Invoice__x>();
        
        if (Test.isRunningTest()) {
            cwInvoices = getInvoiceTestData(orderNumber);
        } else {
            cwInvoices = Database.query(query);
        }
        
        return cwInvoices;
    }
    
    // Return dummy test data for the Order number provided
    public static List<CW_Invoice__x> getInvoiceTestData(String orderNumber) {
        List<CW_Invoice__x> cwInvoices = new List<CW_Invoice__x>();
        
        if (orderNumber == '298356' || orderNumber != '298356') {
            cwInvoices.add(new CW_Invoice__x(
                Id = 'x004B0000008OOrQAM',
                ExternalId = 'IP-0-61377-2-1-1-1',
                DisplayUrl = null,
                Additional_Charge_Amount_IST__c = 0.00,
                Additional_Freight_Amount_IST__c = 0.00,
                BOM_Component_Sequence__c = '0',
                BOM_Header_Flag__c = 'N',
                Color_Code__c = 'G1',
                Company__c = null,
                Credit_Card_Number__c = '************4113',
                Date_Shipped__c = '11/13/2015',
                Freight_Amount_IL__c = 0.00,
                Freight_Amount_IST__c = 0.00,
                GST_Amount_IL__c = 0.00000,
                GST_Amount_IST__c = 0.00,
                Handling_Amount_IL__c = 0.00,
                Handling_Amount_IST__c = 0.00,
                Invoice_Date__c = '11/13/2015',
                Invoice_Line_Number__c = 1,
                Invoice_Number__c = 61377,
                Invoice_Order_Line_Sequence_Number__c = 1,
                Invoice_Type__c = 'Credit',
                Item_Number__c = 'CASHACGW',
                Merchandise_Amount_IST__c = -5.95,
                Merchandise_Unit_Price_IL__c = 5.95,
                Order_Level_Freight_Tax__c = null,
                Order_Number__c = '0',
                Order_Payment_Sequence_Number__c = 1,
                PST_Amount_IL__c = 0.00000,
                PST_Amount_IST__c = 0.00,
                Payment_Additional_Charge_Amount__c = 0.00,
                Payment_Additional_Freight_Amount__c = 0.00,
                Payment_Category_Description__c = 'Credit Card',
                Payment_Category__c = '2',
                Payment_Freight_Amount__c = 0.00,
                Payment_GST_Amount__c = 0.00000,
                Payment_Handling_Amount__c = 0.00,
                Payment_Merchandise_Amount__c = -5.95,
                Payment_PST_Amount__c = 0.00000,
                Payment_Tax_Amount__c = -0.54,
                Payment_Type_Description__c = 'VISA',
                Payment_Type__c = 4,
                Pre_Bill_Color_Code__c = null,
                Pre_Bill_Item_Number__c = null,
                Pre_Bill_Size_Code__c = null,
                Quantity_Shipped__c = -1,
                Ship_To_Number_IST__c = 2,
                Size_Code__c = '10',
                Tax_Amount_IL__c = -0.54000,
                Tax_Amount_IST__c = -0.54
            ));
            cwInvoices.add(new CW_Invoice__x(
                Id = 'x004B0000008OOsQAM',
                ExternalId = 'IP-0-61384-1-1-1-1',
                DisplayUrl = null,
                Additional_Charge_Amount_IST__c = 5.95,
                Additional_Freight_Amount_IST__c = 0.00,
                BOM_Component_Sequence__c = '0',
                BOM_Header_Flag__c = 'N',
                Color_Code__c = 'AZUR',
                Company__c = null,
                Credit_Card_Number__c = '************4113',
                Date_Shipped__c = '11/13/2015',
                Freight_Amount_IL__c = 0.00,
                Freight_Amount_IST__c = 7.00,
                GST_Amount_IL__c = 0.00000,
                GST_Amount_IST__c = 0.00,
                Handling_Amount_IL__c = 0.00,
                Handling_Amount_IST__c = 0.00,
                Invoice_Date__c = '11/13/2015',
                Invoice_Line_Number__c = 1,
                Invoice_Number__c = 61384,
                Invoice_Order_Line_Sequence_Number__c = 1,
                Invoice_Type__c = 'Sale',
                Item_Number__c = '17050043',
                Merchandise_Amount_IST__c = 19.00,
                Merchandise_Unit_Price_IL__c = 19.00,
                Order_Level_Freight_Tax__c = null,
                Order_Number__c = '0',
                Order_Payment_Sequence_Number__c = 1,
                PST_Amount_IL__c = 0.00000,
                PST_Amount_IST__c = 0.00,
                Payment_Additional_Charge_Amount__c = 5.95,
                Payment_Additional_Freight_Amount__c = 0.00,
                Payment_Category_Description__c = 'Credit Card',
                Payment_Category__c = '2',
                Payment_Freight_Amount__c = 7.00,
                Payment_GST_Amount__c = 0.00000,
                Payment_Handling_Amount__c = 0.00,
                Payment_Merchandise_Amount__c = 19.00,
                Payment_PST_Amount__c = 0.00000,
                Payment_Tax_Amount__c = 1.71,
                Payment_Type_Description__c = 'VISA',
                Payment_Type__c = 4,
                Pre_Bill_Color_Code__c = null,
                Pre_Bill_Item_Number__c = null,
                Pre_Bill_Size_Code__c = null,
                Quantity_Shipped__c = 1,
                Ship_To_Number_IST__c = 1,
                Size_Code__c = null,
                Tax_Amount_IL__c = 1.71000,
                Tax_Amount_IST__c = 1.71
            ));
            cwInvoices.add(new CW_Invoice__x(
                Id = 'x004B0000008OOtQAM',
                ExternalId = 'IP-0-61385-1-0-0-1',
                DisplayUrl = null,
                Additional_Charge_Amount_IST__c = -5.95,
                Additional_Freight_Amount_IST__c = 0.00,
                BOM_Component_Sequence__c = '0',
                BOM_Header_Flag__c = null,
                Color_Code__c = null,
                Company__c = null,
                Credit_Card_Number__c = '************4113',
                Date_Shipped__c = null,
                Freight_Amount_IL__c = 0.00,
                Freight_Amount_IST__c = 0.00,
                GST_Amount_IL__c = 0.00000,
                GST_Amount_IST__c = 0.00,
                Handling_Amount_IL__c = 0.00,
                Handling_Amount_IST__c = 0.00,
                Invoice_Date__c = '11/13/2015',
                Invoice_Line_Number__c = 0,
                Invoice_Number__c = 61385,
                Invoice_Order_Line_Sequence_Number__c = 0,
                Invoice_Type__c = 'Credit',
                Item_Number__c = null,
                Merchandise_Amount_IST__c = 0.00,
                Merchandise_Unit_Price_IL__c = 0.00,
                Order_Level_Freight_Tax__c = null,
                Order_Number__c = '0',
                Order_Payment_Sequence_Number__c = 1,
                PST_Amount_IL__c = 0.00000,
                PST_Amount_IST__c = 0.00,
                Payment_Additional_Charge_Amount__c = -5.95,
                Payment_Additional_Freight_Amount__c = 0.00,
                Payment_Category_Description__c = 'Credit Card',
                Payment_Category__c = '2',
                Payment_Freight_Amount__c = 0.00,
                Payment_GST_Amount__c = 0.00000,
                Payment_Handling_Amount__c = 0.00,
                Payment_Merchandise_Amount__c = 0.00,
                Payment_PST_Amount__c = 0.00000,
                Payment_Tax_Amount__c = 0.00,
                Payment_Type_Description__c = 'VISA',
                Payment_Type__c = 4,
                Pre_Bill_Color_Code__c = null,
                Pre_Bill_Item_Number__c = null,
                Pre_Bill_Size_Code__c = null,
                Quantity_Shipped__c = 0,
                Ship_To_Number_IST__c = 1,
                Size_Code__c = null,
                Tax_Amount_IL__c = 0.00000,
                Tax_Amount_IST__c = 0.00
            ));
        }
        
        return cwInvoices;
    }
    
    public static List<CW_Order_Note__x> getCWOrderNotesAllFields(String orderNumber) {
        // Get all the object field names and build the query
        String query = 'SELECT';
        Map<String,Schema.SObjectField> FieldMap = Schema.SObjectType.CW_Order_Note__x.fields.getMap();
        
        //system.debug('***** number of fields = ' + FieldMap.size());
        
        for (Schema.SObjectField f : FieldMap.values()) {
            //Schema.DescribeFieldResult DescField = f.getDescribe();
            //system.debug('Name: ' +  DescField.getName());
            //system.debug('Type: ' +  DescField.getType());
            query += ' ' + f.getDescribe().getName() + ',';
        }
        query = query.removeEnd(',');
        query += ' FROM CW_Order_Note__x WHERE Order_Number__c = \'' + orderNumber + '\'';
        
        //system.debug('***** query string = ' + query); 
        
        List<CW_Order_Note__x> cwOrderNotes = new List<CW_Order_Note__x>();
        
        if (Test.isRunningTest()) {
            cwOrderNotes = getOrderNoteTestData(orderNumber);
        } else {
        
            for(CW_Order_Note__x cwon : Database.query(query))
            cwOrderNotes.add(cwon);
            
        }
    
        return cwOrderNotes;
    }
    
    // Return Order Note dummy test data for the Order number provided
    public static List<CW_Order_Note__x> getOrderNoteTestData(String orderNumber) {
        List<CW_Order_Note__x> cwOrderNotes = new List<CW_Order_Note__x>();
        
        if (orderNumber == '331971' || orderNumber != '331971') {
            
            cwOrderNotes.add(new CW_Order_Note__x(
                Id = 'x004B0000008OOrQAM',
                ExternalId = '331971-1-1',
                DisplayUrl = null,
                Ship_To__c = '1',
                Sequence_Number__c = 001,
                Message__c = ' ',
                Message_Type__c = 'N',
                User__c = 'SCANNY',    
                Date__c = '03/16/1971'      
            ));
        }
        return cwOrderNotes;
    }
}