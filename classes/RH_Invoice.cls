public with sharing class RH_Invoice {
    
    /*
     *  Methods and wrapper classes for Restoration Hardware invoice data.
     *
     */
    
    // Wrapper class for Billing Summary Invoice Line data
    public class InvoiceLineWrapper {
        
        public Integer invNumber {get; set;}
        public Date invDate {get; set;}
        public Integer invShipTo {get; set;}
        public String skuId {get; set;}
        public Boolean bomSku {get; set;}
        public String skuType {get; set;}
        public String prodDesc {get; set;}
        public Boolean delFee {get; set;}
        public Boolean refund {get; set;}
        public Boolean priceAdj {get; set;}
        public Boolean preBill {get; set;}
        public CWInvoice inv {get; set;}
        public CWInvoice.CWInvoiceLine line {get;set;}
        public Boolean nonMerchRefund {get;set;}
         
        public InvoiceLineWrapper(Integer iNum, Date iDate, Integer iShipTo, String iSkuId, Boolean bSku, String sType, String pDesc, Boolean dFee, Boolean rf, Boolean pa, Boolean pb, CWInvoice iInv, CWInvoice.CWInvoiceLine ln, Boolean nonMerchRef) {
            invNumber = iNum;
            invDate = iDate;
            invShipTo = iShipTo;
            skuId = iSkuId;
            bomSku = bSku;
            skuType = sType;
            prodDesc = pDesc;
            delFee = dfee;
            refund = rf;
            priceAdj = pa;
            preBill = pb;
            inv = iInv;
            line = ln;
            nonMerchRefund = nonMerchRef;
        }
    }
    
    // Class for payment type totals
    public class PaymentTypeTotal {
        public String paymentType {get; set;}
        public String paymentTypeDescription {get; set;}
        public String ccNumber {get; set;}
        public Decimal totalAmount {get; set;}
        public String PaymentKey {get; set;}
        
        public PaymentTypeTotal() {
            paymentType = null;
            paymentTypeDescription = null;
            ccNumber = null;
            totalAmount = null;
            PaymentKey = null;
        }
    }
    
    // Class for Billing Activity totals
    public class BillingActivity {
        public Decimal merchTotal {get; set;}
        public Decimal accomTotal {get; set;}
        public Decimal taxTotal {get; set;}
        public Decimal freightTotal {get; set;}
        public Decimal additionalFreightTotal {get; set;}
        public Decimal handlingTotal {get; set;}
        public Decimal additionalChargeTotal {get; set;}
        public Decimal grandTotal {get; set;}
        
        public BillingActivity() {
            merchTotal = 0.00;
            accomTotal = 0.00;
            taxTotal = 0.00;
            freightTotal = 0.00;
            additionalFreightTotal = 0.00;
            handlingTotal = 0.00;
            additionalChargeTotal = 0.00;
            grandTotal = 0.00;
        }
    }
    
    // Return a sorted InvoiceLineWrapper list from the results of an Invoice query - sort is either by invoice date
    // ascending or by credit card type/invoice date ascending
    public static List<InvoiceLineWrapper> getInvoiceLineWrapper(List<CWInvoice> cwInvoices, String orderNumber, String sortOrder) {
        List<InvoiceLineWrapper> ilwList = new List<InvoiceLineWrapper>();
        Date invDate;
        // Build the InvoiceLineWrapper list
            Integer invNum;
            Integer invShipTo;
            Boolean bomSku;
            String skuType;
            String prodDesc;
            Boolean delFee;
            Boolean refund;
            Boolean priceAdj;
            Boolean preBill;
            String invSkuId;
            Boolean nonMerchRef;
        
        for (CWInvoice inv :cwInvoices) {
            for(CWInvoice.CWInvoiceLine line:inv.invoiceLine){
                // Get the Invoice Line SKU Id
                if (String.isNotBlank(line.PreBillItemNumber)) {
                    preBill = true;
                } else {
                    preBill = false;
                }
                invSkuId = getSkuId(line, preBill);
                
                // Convert the date string (MM/DD/YYYY) to a Date datatype
                invDate = date.parse(inv.InvoiceDate);
                
                // Convert the decimal invoice number and ship to to an integer (works because even though it
                // is a decimal it has no digits to the right of the decimal place)
                invNum = Integer.valueOf(inv.InvoiceNumber);
                invShipTo = Integer.valueOf(inv.ShipToNumberIST);
                
                // SKU Type and Product description
                skuType = '';
                prodDesc = '';
                if (line.skuProduct != null) {
                    skuType = line.skuProduct.SKU_Type__c;
                    prodDesc = line.skuProduct.ECommerce_Display_Name__c;
                    if (String.isBlank(prodDesc) || prodDesc == 'PRODUCT NOT AVAILABLE') {
                        prodDesc = line.skuProduct.CW_Item_Description__c;
                    }
                }
                
                // Determine invoice line type
                bomSku = false;
                if (line.BOMHeaderFlag == 'Y') {
                    bomSku = true;
                }
                delFee = false;                
                if (invSkuId == 'DELIVERYFEE') {
                    delFee = true;
                }
                refund = false;
                if (line.QuantityShipped < 0 && line.MerchandiseUnitPriceIL > 0) {
                    refund = true;
                }
                priceAdj = false;
                if (line.QuantityShipped > 0 && line.MerchandiseUnitPriceIL < 0) {
                    priceAdj = true;
                }
                nonMerchRef = false;
                if(line.PaymentMerchandiseAmount == 0 
                   && (line.PaymentPSTAmount < 0
                       || line.PaymentGSTAmount < 0
                       || line.PaymentTaxAmount < 0
                       || line.PaymentHandlingAmount < 0
                       || line.PaymentFreightAmount < 0)){
                    nonMerchRef = true;
                }
            
                // Add the InvoiceLineWrapper to the list
                //system.debug('ILW invSkuId = ' + invSkuId + ' skuType = ' + skuType);
                ilwList.add(new InvoiceLineWrapper(invNum, invDate, invShipTo, invSkuId, bomSku, skuType, prodDesc, delFee, refund, priceAdj, preBill, inv, line, nonMerchRef));
            }
        }        
        return ilwList;
    }
     
    // Return the SKU Id from the supplied invoice line
    public static String getSkuId(CWInvoice.CWInvoiceLine line, Boolean preBill) {
        String skuId = '';
        
        if (line != null) {
            if (preBill) {
                if (String.isNotBlank(line.PreBillItemNumber)) {
                    skuId += line.PreBillItemNumber;
                }
                if (String.isNotBlank(line.PreBillColorCode)) {
                    skuId += line.PreBillColorCode;
                }
                if (String.isNotBlank(line.PreBillSizeCode)) {
                    skuId += line.PreBillSizeCode;
                }
            } else {
                if (String.isNotBlank(line.ItemNumber)) {
                    skuId += line.ItemNumber;
                }
                if (String.isNotBlank(line.ColorCode)) {
                    skuId += line.ColorCode;
                }
                if (String.isNotBlank(line.SizeCode)) {
                    skuId += line.SizeCode;
                }
            }
        }   
        return skuId;
    }
    
    // Return a map of accommodation gift cards by invoice number from a list of invoice line wrappers
    public static Map<Integer, List<InvoiceLineWrapper>> getGiftCardAccomMap(List<InvoiceLineWrapper> ilwList) {
        Map<Integer, List<InvoiceLineWrapper>> invGiftMap = new Map<Integer, List<InvoiceLineWrapper>>();
        
        for (InvoiceLineWrapper ilw :ilwList) {
            if (ilw.skuType == 'Accommodation Gift Card') {
                if (!invGiftMap.containsKey(ilw.invNumber)) {
                    invGiftMap.put(ilw.invNumber, new List<InvoiceLineWrapper>());
                }
                invGiftMap.get(ilw.invNumber).add(ilw);
            }
        }
        
        return invGiftMap;
    }
    
    // Return a map of invoice line wrappers by invoice number.  The map will be as follows:
    //  - no accommodation gift cards
    //  - no DELIVERYFEE SKUs unless they are the only SKUs for that invoice number
    //  - no BOM SKU headers that have zero value and do not have any BOM components
    //  - only one row per line number (multiple rows per line number indicate the line number was paid for with multiple payment types)
    public static Map<Integer, List<InvoiceLineWrapper>> getInvMap(List<InvoiceLineWrapper> ilwList) {
        Map<Integer, List<InvoiceLineWrapper>> invMap = new Map<Integer, List<InvoiceLineWrapper>>();
        Boolean isInList;
        
        for (InvoiceLineWrapper ilw :ilwList) {
        
            // Do not include Gift Card accommodations
            if (ilw.skuType != 'Accommodation Gift Card') {
                
                // Only include one entry for each invoice number/invoice line number
                if (!invMap.containsKey(ilw.invNumber)) {
                    invMap.put(ilw.invNumber, new List<InvoiceLineWrapper>());
                }
                
                isInList = false;
                if (ilw.delFee) {
                    // Only add DELIVERYFEE SKU if the list of invoice line numbers is empty for this invoice
                    if (!invMap.get(ilw.invNumber).isEmpty()) {
                        isInList = true;
                    }
                } else {
                    // Non-DELIVERYFEE SKU, remove any DELIVERYFEE SKUs already in our list of invoice line numbers
                    for (Integer i=0; i<invMap.get(ilw.invNumber).size(); i++) {
                        if (invMap.get(ilw.invNumber)[i].delFee) {
                            invMap.get(ilw.invNumber).remove(i);
                        }
                    }                    
                    // Non-DELIVERYFEE SKU, add it to our list, if the invoice line number is not already there
                    for (InvoiceLineWrapper inv :invMap.get(ilw.invNumber)) {
                        if (inv.line.InvoiceLineNumber == ilw.line.InvoiceLineNumber) {
                            isInList = true;
                        }
                    }                    
                }
                
                if (!isInList) {
                    invMap.get(ilw.invNumber).add(ilw);
                }
            }
        }
        
        // Make one more pass through our list and toss out BOM SKU headers that are zero value and have no components        
        for (Integer invNum :invMap.keySet()) {
            if (invMap.get(invNum).size() == 1 && invMap.get(invNum)[0].bomSku && invMap.get(invNum)[0].line.MerchandiseUnitPriceIL == 0) {
                invMap.remove(invNum);
            }
        } 
        return invMap;
    }
    
    // Return a map of payment type totals by invoice number
    public static Map<Integer, List<PaymentTypeTotal>> getPaymentTypeTotals(List<InvoiceLineWrapper> ilwList) {
        Map<Integer, List<InvoiceLineWrapper>> delFeeMap = new Map<Integer, List<InvoiceLineWrapper>>();
        Map<Integer, List<PaymentTypeTotal>> ptTotalMap = new Map<Integer, List<PaymentTypeTotal>>();
        PaymentTypeTotal ptTotal;
        Boolean isInList;
        Decimal payTotal;
        Decimal addChargeAmt;
        Decimal addFreightAmt;
        Decimal freightAmt;
        Decimal handlingAmt;
        Decimal merchAmt;
        Decimal taxAmt;
        
        for (InvoiceLineWrapper ilw :ilwList) {
            
            if (ilw.delFee) {
                
                // Separate out the DELIVERYFEE SKUs
                if (!delFeeMap.containsKey(ilw.invNumber)) {
                    delFeeMap.put(ilw.invNumber, new List<InvoiceLineWrapper>());
                }
                delFeeMap.get(ilw.invNumber).add(ilw);
                
            } else {
                
                // Do not include Gift Card accommodations
                if (ilw.skuType != 'Accommodation Gift Card') {
                    
                    // Add to our payment type totals list, calculate total for each invoice payment type
                    addChargeAmt = 0.00;
                    addFreightAmt = 0.00;
                    freightAmt = 0.00;
                    handlingAmt = 0.00;
                    merchAmt = 0.00;
                    taxAmt = 0.00;
                    if (ilw.line.PaymentAdditionalChargeAmount != null) {
                        addChargeAmt = ilw.line.PaymentAdditionalChargeAmount;
                    }
                    if (ilw.line.PaymentAdditionalFreightAmount != null) {
                        addFreightAmt = ilw.line.PaymentAdditionalFreightAmount;
                    }
                    if (ilw.line.PaymentFreightAmount != null) {
                        freightAmt = ilw.line.PaymentFreightAmount;
                    }
                    if (ilw.line.PaymentHandlingAmount != null) {
                        handlingAmt = ilw.line.PaymentHandlingAmount;
                    }
                    if (ilw.line.PaymentMerchandiseAmount != null) {
                        merchAmt = ilw.line.PaymentMerchandiseAmount;
                    }
                    if (ilw.line.PaymentTaxAmount != null) {
                        taxAmt = ilw.line.PaymentTaxAmount;
                    }
                    payTotal = addChargeAmt + addFreightAmt + freightAmt + handlingAmt + merchAmt + taxAmt;
                    if (!ptTotalMap.containsKey(ilw.invNumber)) {
                        ptTotalMap.put(ilw.invNumber, new List<PaymentTypeTotal>());
                    }
                    
                    isInList = false;
                    for (PaymentTypeTotal ptt :ptTotalMap.get(ilw.invNumber)) {
                        if (ilw.line.PaymentCategoryDescription != 'Coupon/Credit' && ptt.paymentType == String.valueOf(ilw.line.PaymentType) && ptt.ccNumber == ilw.line.CreditCardNumber) {
                            isInList = true;
                        }
                        if(ilw.line.PaymentCategoryDescription == 'Coupon/Credit' && ptt.PaymentKey != String.valueOf(ilw.invNumber) + ' - ' + String.valueOf(ilw.line.InvoiceOrderLineSequenceNumber)){
                            isInList = true;                            
                        }
                    }
                    if (!isInList) {
                        ptTotal = new PaymentTypeTotal();
                        ptTotal.paymentType = String.valueOf(ilw.line.PaymentType);
                        ptTotal.paymentTypeDescription = ilw.line.PaymentCategoryDescription;
                        ptTotal.ccNumber = ilw.line.CreditCardNumber;
                        ptTotal.totalAmount = payTotal;
                        ptTotal.PaymentKey = String.valueOf(ilw.invNumber) + ' - ' + String.valueOf(ilw.line.InvoiceOrderLineSequenceNumber);                       
                        ptTotalMap.get(ilw.invNumber).add(ptTotal);                        
                    }
                }
            }
          
        }
        // If DELIVERYFEE SKUs are the only lines for an invoice, add them to our payment type totals
        // Regina wants to suppress this as of 03.29.2016.
        // Stephanie wants this back as of 04.06.2016
        for (Integer invNum :delFeeMap.keySet()) {
            
            if (!ptTotalMap.containsKey(invNum)) {
                for (InvoiceLineWrapper ilw :delFeeMap.get(invNum)) { 
                 
                    addChargeAmt = 0.00;
                    addFreightAmt = 0.00;
                    freightAmt = 0.00;
                    handlingAmt = 0.00;
                    merchAmt = 0.00;
                    taxAmt = 0.00;
                    if (ilw.line.PaymentAdditionalChargeAmount != null) {
                        addChargeAmt = ilw.line.PaymentAdditionalChargeAmount;
                    }
                    if (ilw.line.PaymentAdditionalFreightAmount != null) {
                        addFreightAmt = ilw.line.PaymentAdditionalFreightAmount;
                    }
                    if (ilw.line.PaymentFreightAmount != null) {
                        freightAmt = ilw.line.PaymentFreightAmount;
                    }
                    if (ilw.line.PaymentHandlingAmount != null) {
                        handlingAmt = ilw.line.PaymentHandlingAmount;
                    }
                    if (ilw.line.PaymentMerchandiseAmount != null) {
                        merchAmt = ilw.line.PaymentMerchandiseAmount;
                    }
                    if (ilw.line.PaymentTaxAmount != null) {
                        taxAmt = ilw.line.PaymentTaxAmount;
                    }
                    payTotal = addChargeAmt + addFreightAmt + freightAmt + handlingAmt + merchAmt + taxAmt;
                    if(handlingAmt != 0.0 || payTotal != 0.0){
                       if (!ptTotalMap.containsKey(ilw.invNumber)) {
                          ptTotalMap.put(invNum, new List<PaymentTypeTotal>());
                       }
                    
                       isInList = false;
                       for (PaymentTypeTotal ptt :ptTotalMap.get(invNum)) {
                          if (ptt.paymentType == String.valueOf(ilw.line.PaymentType)) {
                             isInList = true;
                          }
                       }
                       if (!isInList) {
                          ptTotal = new PaymentTypeTotal();
                          ptTotal.paymentType = String.valueOf(ilw.line.PaymentType);
                          ptTotal.paymentTypeDescription = ilw.line.PaymentCategoryDescription;
                          ptTotal.ccNumber = ilw.line.CreditCardNumber;
                          ptTotal.totalAmount = payTotal;
                          ptTotal.PaymentKey = String.valueOf(ilw.invNumber) + ' - ' + String.valueOf(ilw.line.InvoiceOrderLineSequenceNumber);
                          ptTotalMap.get(invNum).add(ptTotal);
                       }
                    }

                }
             }            
        }
        
        return ptTotalMap;
    }
    
    // Calculate the overall Billing Activity totals for the provided InvoiceLineWrapper list
    public static BillingActivity getBillingActivityTotals(List<InvoiceLineWrapper> ilwList) {
        BillingActivity baTotals = new BillingActivity();
        
        // Make a map of the invoice data that will be included in the totals
        Map<Integer, List<InvoiceLineWrapper>> invMap = new Map<Integer, List<InvoiceLineWrapper>>();
        Map<Integer, List<InvoiceLineWrapper>> delFeeMap = new Map<Integer, List<InvoiceLineWrapper>>();
        Boolean isInList;
        for (InvoiceLineWrapper ilw :ilwList) {
            
            if (ilw.delFee) {
                
                // Separate map for DELIVERYFEE SKUs
                if (!delFeeMap.containsKey(ilw.invNumber)) {
                    delFeeMap.put(ilw.invNumber, new List<InvoiceLineWrapper>());
                }
                delFeeMap.get(ilw.invNumber).add(ilw);
                
            } else {
                
                // Do not include Gift Card accommodations
                if (ilw.skuType != 'Accommodation Gift Card' && ilw.skuType != 'Accommodation Gift Card Zero Dollar') {
                    
                    // Only include one entry for each invoice number/invoice line number
                    if (!invMap.containsKey(ilw.invNumber)) {
                        invMap.put(ilw.invNumber, new List<InvoiceLineWrapper>());
                    }
                    
                    isInList = false;
                    if (ilw.delFee) {
                       // Only add DELIVERYFEE SKU if the list of invoice line numbers is empty for this invoice
                       if (!invMap.get(ilw.invNumber).isEmpty()) {
                          isInList = true;
                       }
                    } else {
                       // Non-DELIVERYFEE SKU, remove any DELIVERYFEE SKUs already in our list of invoice line numbers
                       for (Integer i=0; i<invMap.get(ilw.invNumber).size(); i++) {
                           if (invMap.get(ilw.invNumber)[i].delFee) {
                               invMap.get(ilw.invNumber).remove(i);
                           }
                        }                    
                        // Non-DELIVERYFEE SKU, add it to our list, if the invoice line number is not already there
                        for (InvoiceLineWrapper inv :invMap.get(ilw.invNumber)) {
                           if (inv.line.InvoiceLineNumber == ilw.line.InvoiceLineNumber) {
                               isInList = true;
                           }
                        }                    
                    }
                    
                    if (!isInList) {
                        invMap.get(ilw.invNumber).add(ilw);
                    }
                }
            }
        }
        
        // If a DELIVERYFEE SKU is the only line for an invoice, add it to our list
        for (Integer invNum :delFeeMap.keySet()) {
            if (!invMap.containsKey(invNum)) {
                invMap.put(invNum, new List<InvoiceLineWrapper>());
                invMap.get(invNum).add(delFeeMap.get(invNum)[0]);
            }
        }
        
        // Calculate the Billing Activity totals
        CWInvoice inv;
        for (Integer invNum :invMap.keySet()) {
            inv = invMap.get(invNum)[0].inv;
            
            // Calculate totals for all Accommodations/Refunds and regular
            if (invMap.get(invNum)[0].skuType == 'Accommodation' || invMap.get(invNum)[0].skuType == 'Accommodation Zero Dollar' || invMap.get(invNum)[0].refund || invMap.get(invNum)[0].priceAdj) {
                baTotals.accomTotal += inv.MerchandiseAmountIST;
            } else {
                baTotals.merchTotal += inv.MerchandiseAmountIST;
            }
            baTotals.taxTotal += inv.TaxAmountIST;
            baTotals.freightTotal += inv.FreightAmountIST;
            baTotals.additionalFreightTotal += inv.AdditionalFreightAmountIST;
            baTotals.handlingTotal += inv.HandlingAmountIST;
            baTotals.additionalChargeTotal += inv.AdditionalChargeAmountIST;
        }
        baTotals.taxTotal = baTotals.taxTotal.setScale(2, System.RoundingMode.HALF_UP);
        baTotals.grandTotal = baTotals.merchTotal + baTotals.accomTotal + baTotals.taxTotal + baTotals.freightTotal + baTotals.additionalFreightTotal + baTotals.handlingTotal + baTotals.additionalChargeTotal;
        
        return baTotals;
    }
}