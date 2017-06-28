global class CWInvoice implements Comparable{
    
public Integer OrderNumber {get;set;}
public Integer InvoiceNumber {get;set;}
public String InvoiceDate {get;set;}
public String InvoiceType {get;set;}
public decimal ShipToNumberIST {get;set;}
public decimal AdditionalChargeAmountIST {get;set;}
public decimal AdditionalFreightAmountIST {get;set;}
public decimal InvShiptoDiscountAmount {get;set;}
public decimal FreightAmountIST {get;set;} 
public decimal GSTAmountIST {get;set;}
public decimal HandlingAmountIST {get;set;}
public decimal MerchandiseAmountIST {get;set;}
public decimal PSTAmountIST {get;set;}
public decimal TaxAmountIST {get;set;}
public List<CWInvoiceLine> invoiceLine {get;set;}
public List<CWInvoiceAdditionalCharge> additionalCharge {get;set;}
public Set<String> setSKUs {get;set;}
//public decimal Company {get;set;} 
//public decimal OrderLevelFreightTax {get;set;}
 
    // Return the SKU Id from the supplied invoice line
    public static String getSkuId(CWInvoiceLine inv, Boolean preBill) {
        String skuId = '';      
        if (inv != null) {
            if (preBill) {
                if (String.isNotBlank(inv.PreBillItemNumber)) {
                    skuId += inv.PreBillItemNumber;
                }
                if (String.isNotBlank(inv.PreBillColorCode)) {
                    skuId += inv.PreBillColorCode;
                }
                if (String.isNotBlank(inv.PreBillSizeCode)) {
                    skuId += inv.PreBillSizeCode;
                }
            } else {
                if (String.isNotBlank(inv.ItemNumber)) {
                    skuId += inv.ItemNumber;
                }
                if (String.isNotBlank(inv.ColorCode)) {
                    skuId += inv.ColorCode;
                }
                if (String.isNotBlank(inv.SizeCode)) {
                    skuId += inv.SizeCode;
                }
            }
        }   
        return skuId;
    }
        
global CWInvoice(List<Dom.XMLNode> InvoiceHeader){
   this.invoiceLine = new List<CWInvoiceLine>();
   this.additionalCharge = new List<CWInvoiceAdditionalCharge>();
   this.setSKUs = new Set<String>();
   for(Dom.XMLNode InvoiceHeaderFields : InvoiceHeader){
      if(InvoiceHeaderFields.getName() == 'Order_Number'){this.OrderNumber = Integer.valueOf(InvoiceHeaderFields.getText());}
      if(InvoiceHeaderFields.getName() == 'Invoice_Number'){this.InvoiceNumber = Integer.valueOf(InvoiceHeaderFields.getText());}
      if(InvoiceHeaderFields.getName() == 'Invoice_Date'){this.InvoiceDate = InvoiceHeaderFields.getText();}
      if(InvoiceHeaderFields.getName() == 'Invoice_Type'){this.InvoiceType = InvoiceHeaderFields.getText();}
      if(InvoiceHeaderFields.getName() == 'Invoice_Shipto_Number'){this.ShipToNumberIST = Decimal.valueOf(InvoiceHeaderFields.getText());}
      if(InvoiceHeaderFields.getName() == 'Inv_Shipto_Additional_Charge_Amount'){this.AdditionalChargeAmountIST = Decimal.valueOf(InvoiceHeaderFields.getText());}
      if(InvoiceHeaderFields.getName() == 'Inv_Shipto_Additional_Freight_Amount'){this.AdditionalFreightAmountIST = Decimal.valueOf(InvoiceHeaderFields.getText());}
      if(InvoiceHeaderFields.getName() == 'Inv_Shipto_Discount_Amount'){this.InvShiptoDiscountAmount = Decimal.valueOf(InvoiceHeaderFields.getText());}
      if(InvoiceHeaderFields.getName() == 'Inv_Shipto_Freight_Amount'){this.FreightAmountIST = Decimal.valueOf(InvoiceHeaderFields.getText());}
      if(InvoiceHeaderFields.getName() == 'Inv_Shipto_GST_Amount'){this.GSTAmountIST = Decimal.valueOf(InvoiceHeaderFields.getText());}
      if(InvoiceHeaderFields.getName() == 'Inv_Shipto_Handling_Amount'){this.HandlingAmountIST = Decimal.valueOf(InvoiceHeaderFields.getText());}
      if(InvoiceHeaderFields.getName() == 'Inv_Shipto_Merchandise_Amount'){this.MerchandiseAmountIST = Decimal.valueOf(InvoiceHeaderFields.getText());}
      if(InvoiceHeaderFields.getName() == 'Inv_Shipto_PST_Amount'){this.PSTAmountIST = Decimal.valueOf(InvoiceHeaderFields.getText());}
      if(InvoiceHeaderFields.getName() == 'Inv_Shipto_Tax_Amount'){this.TaxAmountIST = Decimal.valueOf(InvoiceHeaderFields.getText());}
      if(InvoiceHeaderFields.getName() == 'InvoiceLines'){ 
         for(Dom.XMLNode il : InvoiceHeaderFields.getChildElements() ){    
            CWInvoiceLine invLine = new CWInvoiceLine(il.getChildElements());
            Boolean bPreBill = (String.isNotBlank(invLine.PreBillItemNumber)) ? true: false;
            invLine.skuId = getSkuId(invLine, bPreBill);
            setSKUs.add(invLine.skuId);
            this.invoiceLine.add(invLine);
         }
      }   
      if(InvoiceHeaderFields.getName() == 'Inv_Shipto_Additional_Charge_Codes'){ 
         for(Dom.XMLNode ac : InvoiceHeaderFields.getChildElements() ){    
            this.additionalCharge.add(new CWInvoiceAdditionalCharge(ac.getChildElements()));
         }
      }      
   }
}    

public class CWInvoiceLine implements Comparable{
   public Integer InvoiceLineNumber {get;set;}
   public Integer InvoiceOrderLineSequenceNumber {get;set;}
   public decimal FreightAmountIL {get;set;}
   public decimal GSTAmountIL {get;set;}
   public decimal HandlingAmountIL {get;set;}
   public decimal PSTAmountIL {get;set;}
   public decimal TaxAmountIL {get;set;}
   public decimal QuantityShipped {get;set;}
   public String DateShipped {get;set;}
   public String ItemNumber {get;set;}
   public String ColorCode {get;set;}
   public String SizeCode {get;set;}
   public decimal PaymentMerchandiseAmount {get;set;}
   public decimal PaymentPSTAmount {get;set;}
   public decimal PaymentGSTAmount {get;set;}
   public decimal PaymentTaxAmount {get;set;}
   public decimal PaymentHandlingAmount {get;set;}
   public decimal PaymentFreightAmount {get;set;}
   public String PaymentCategory {get;set;}
   public String PaymentCategoryDescription {get;set;}   
   public String PaymentTypeDescription {get;set;}
   public Integer PaymentType {get;set;}
   public String PaymentMethod {get;set;}
   public String CreditCardNumber {get;set;}
   public Integer OrderPaymentSequenceNumber {get;set;}
   public decimal PaymentMerchandiseUnitPrice {get;set;}
   public decimal MerchandiseUnitPriceIL {get;set;}
   public decimal PaymentAdditionalChargeAmount {get;set;}
   public decimal PaymentAdditionalFreightAmount {get;set;}      
   public String PreBillItemNumber {get;set;}
   public String PreBillColorCode {get;set;}
   public String PreBillSizeCode {get;set;}
   public String BOMHeaderFlag {get;set;}   
   public String BOMComponentSequence {get;set;}
   public String NoChargeReplacementIndicator {get;set;}
   public String skuId {get;set;}
   public Product2 skuProduct {get;set;}
   // Implement the compareTo() method
   public Integer compareTo(Object compareTo) {
        CWInvoiceLine compareToInvoiceLine = (CWInvoiceLine)compareTo;
        if (BOMComponentSequence == compareToInvoiceLine.BOMComponentSequence) return 0;
        if (BOMComponentSequence > compareToInvoiceLine.BOMComponentSequence) return 1;
        return -1;        
   }
   public CWInvoiceLine(List<Dom.XMLNode> invoiceLine){
      for(Dom.XMLNode invoiceLineFields : invoiceLine){
         if(invoiceLineFields.getName() == 'Invoice_Line_Number'){this.InvoiceLineNumber = Integer.valueOf(invoiceLineFields.getText());}
         if(invoiceLineFields.getName() == 'Invoice_Order_Line_Sequence_Number'){this.InvoiceOrderLineSequenceNumber = Integer.valueOf(invoiceLineFields.getText());}
         if(invoiceLineFields.getName() == 'Invoice_Line_Freight_Amount'){this.FreightAmountIL = Decimal.valueOf(invoiceLineFields.getText());}
         if(invoiceLineFields.getName() == 'Invoice_Line_GST_Amount'){this.GSTAmountIL = Decimal.valueOf(invoiceLineFields.getText());}
         if(invoiceLineFields.getName() == 'Invoice_Line_Handling_Amount'){this.HandlingAmountIL = Decimal.valueOf(invoiceLineFields.getText());}
         if(invoiceLineFields.getName() == 'Invoice_Line_PST_Amount'){this.PSTAmountIL = Decimal.valueOf(invoiceLineFields.getText());}
         if(invoiceLineFields.getName() == 'Invoice_Line_TAX_Amount'){this.TaxAmountIL = Decimal.valueOf(invoiceLineFields.getText());}
         if(invoiceLineFields.getName() == 'Quantity_Shipped'){this.QuantityShipped = Integer.valueOf(invoiceLineFields.getText());}
         if(invoiceLineFields.getName() == 'Date_Shipped'){this.DateShipped = invoiceLineFields.getText();}
         if(invoiceLineFields.getName() == 'Item_Number'){this.ItemNumber = invoiceLineFields.getText();}
         if(invoiceLineFields.getName() == 'Color_Code'){this.ColorCode = invoiceLineFields.getText();}
         if(invoiceLineFields.getName() == 'Size_Code'){this.SizeCode = invoiceLineFields.getText();}
         if(invoiceLineFields.getName() == 'Payment_Merchandise_Amount'){this.PaymentMerchandiseAmount = Decimal.valueOf(invoiceLineFields.getText());}
         if(invoiceLineFields.getName() == 'Payment_PST_Amount'){this.PaymentPSTAmount = Decimal.valueOf(invoiceLineFields.getText());}
         if(invoiceLineFields.getName() == 'Payment_GST_Amount'){this.PaymentGSTAmount = Decimal.valueOf(invoiceLineFields.getText());}
         if(invoiceLineFields.getName() == 'Payment_Tax_Amount'){this.PaymentTaxAmount = Decimal.valueOf(invoiceLineFields.getText());}
         if(invoiceLineFields.getName() == 'Payment_Handling_Amount'){this.PaymentHandlingAmount = Decimal.valueOf(invoiceLineFields.getText());}
         if(invoiceLineFields.getName() == 'Payment_Freight_Amount'){this.PaymentFreightAmount = Decimal.valueOf(invoiceLineFields.getText());}
         if(invoiceLineFields.getName() == 'Payment_Category'){this.PaymentCategory = invoiceLineFields.getText();}
         if(invoiceLineFields.getName() == 'Payment_Category_Description'){this.PaymentCategoryDescription = invoiceLineFields.getText();}
         if(invoiceLineFields.getName() == 'Payment_Type_Description'){this.PaymentTypeDescription = invoiceLineFields.getText();}
         if(invoiceLineFields.getName() == 'Payment_Type'){this.PaymentType = Integer.valueOf(invoiceLineFields.getText());}
         if(invoiceLineFields.getName() == 'Payment_Method'){this.PaymentMethod = invoiceLineFields.getText();}
         if(invoiceLineFields.getName() == 'Credit_Card_Number'){this.CreditCardNumber = invoiceLineFields.getText();}
         if(invoiceLineFields.getName() == 'Order_Payment_Sequence_Number'){this.OrderPaymentSequenceNumber = Integer.valueOf(invoiceLineFields.getText());}
         if(invoiceLineFields.getName() == 'Payment_Merchandise_Unit_Price'){this.PaymentMerchandiseUnitPrice = Decimal.valueOf(invoiceLineFields.getText());}
         if(invoiceLineFields.getName() == 'Invoice_Line_Merchandise_Unit_Price'){this.MerchandiseUnitPriceIL = Decimal.valueOf(invoiceLineFields.getText());}
         if(invoiceLineFields.getName() == 'Payment_Additional_Charge'){this.PaymentAdditionalChargeAmount = Decimal.valueOf(invoiceLineFields.getText());}
         if(invoiceLineFields.getName() == 'Payment_Additional_Freight'){this.PaymentAdditionalFreightAmount = Decimal.valueOf(invoiceLineFields.getText());}
         if(invoiceLineFields.getName() == 'Pre_Bill_Item_Number'){this.PreBillItemNumber = invoiceLineFields.getText();}
         if(invoiceLineFields.getName() == 'Pre_Bill_Color_Code'){this.PreBillColorCode = invoiceLineFields.getText();}
         if(invoiceLineFields.getName() == 'Pre_Bill_Size_Code'){this.PreBillSizeCode = invoiceLineFields.getText();}
         if(invoiceLineFields.getName() == 'BOM_Header_Flag'){this.BOMHeaderFlag = invoiceLineFields.getText();}
         if(invoiceLineFields.getName() == 'BOM_Component_Sequence'){this.BOMComponentSequence = invoiceLineFields.getText();}
         if(invoiceLineFields.getName() == 'Invoice_Line_No_Charge_Replacement_Indicator'){this.NoChargeReplacementIndicator = invoiceLineFields.getText();}
      }     
   }
}   

public class CWInvoiceAdditionalCharge{
   public String ChargeCode {get;set;}
   public String ChargeDescription {get;set;}
   public decimal ChargeAmount {get;set;}
   public CWInvoiceAdditionalCharge(List<Dom.XMLNode> additionalCharge){
      for(Dom.XMLNode additionalChargeFields : additionalCharge){
         if(additionalChargeFields.getName() == 'Additional_Charge_Code'){this.ChargeCode = additionalChargeFields.getText();}
         if(additionalChargeFields.getName() == 'Additional_Charge_Description'){this.ChargeDescription = additionalChargeFields.getText();}
         if(additionalChargeFields.getName() == 'Additional_Charge_Amount'){this.ChargeAmount = Decimal.valueOf(additionalChargeFields.getText());}
      }
   }
} 

    /*
    // Implement the compareTo() method
    public Integer compareTo(Object compareTo) {
        CWInvoice compareToInvoice = (CWInvoice)compareTo;
        if (date.parse(InvoiceDate) == date.parse(compareToInvoice.InvoiceDate)) return 0;
        if (date.parse(InvoiceDate) >  date.parse(compareToInvoice.InvoiceDate)) return 1;
        return -1;        
    }
    */
    
    // Implement the compareTo() method
    public Integer compareTo(Object compareTo) {
        CWInvoice compareToInvoice = (CWInvoice)compareTo;
        if (InvoiceNumber == compareToInvoice.InvoiceNumber) return 0;
        if (InvoiceNumber > compareToInvoice.InvoiceNumber) return 1;
        return -1;        
    }
 
}