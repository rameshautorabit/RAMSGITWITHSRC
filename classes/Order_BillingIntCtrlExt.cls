global with sharing class Order_BillingIntCtrlExt{

 ApexPages.StandardController stdController;
 private final RH_Order__c rhOrder;

 public List<RH_Invoice.InvoiceLineWrapper> invItemsWithProdDescSKUTypes {get; set;} 
    
 public Order_BillingIntCtrlExt(ApexPages.StandardController stdController) {
    this.rhOrder = (RH_Order__c)stdController.getRecord();  
 } 
  
 @RemoteAction
 global static List<CWInvoice> getInvoiceData(string OrderNumber){
    List<CWInvoice> cwInv = CWCalloutService.retrieveInvoiceData(OrderNumber);
    System.debug('CW Invoices Size: ' + cwInv.size());
    return cwInv;  
 }   
}