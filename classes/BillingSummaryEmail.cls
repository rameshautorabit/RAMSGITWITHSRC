global with sharing class BillingSummaryEmail {

public class CPUTimeoutException extends Exception {}

public static Map<String, String> headerFooterContent(Id orderId, String clientType) {

        Map<String, String> subMap = new Map<String, String>();
        
        Id rhProductionOrgId = '00D500000007MjVEAU';
        Map<Id, String> resultsMap = new Map<Id, String>();
        
        // Read in the Order, Template and Brand related data we need to populate the email template
        RH_Order__c bsOrder = new RH_Order__c();
       
       System.Debug('About to query order# ' + orderId);
       
       bsOrder = [select Id, Name, Opportunity__c, Opportunity__r.Ops_Contact__c,  Sold_to_Address_1__c, Sold_to_Address_2__c, 
                Sold_to_City__c, Sold_to_State__c, Sold_to_Zip__c, Sold_to_First_Name__c, Sold_to_Last_Name__c, Sold_to_Email__c, 
                Sold_to_Day_Phone__c, Order_Date__c, Division__c, Client_Type__c, 
                To_Email_Address__c, Additional_To_Email_Addresses__c, Ship_To_1_Order_Description__c 
                from RH_Order__c where Id = :orderId];
                
        if(clientType != null){
           bsOrder.Client_Type__c = clientType;
        }
        
        BillingSummaryTemplate__c bst = BillingSummaryTemplate__c.getInstance(bsOrder.Client_Type__c);
        String rhBrand = '';
        String rhBrandLogoURL = '';
        String rhBrandHomePageURL = '';
        String rhBrandLogoWidth = '';
        String rhBrandLogoHeight = '';
        
        RH_Brand__c rhb = null;
        if (String.isNotBlank(bsOrder.Division__c)) {
            rhb = RH_Brand__c.getInstance(bsOrder.Division__c);
        }
        if (rhb == null) {
            rhb = RH_Brand__c.getInstance('999');
        }
        rhBrand = rhb.Email_Subject_Brand__c;
        rhBrandLogoURL = rhb.Brand_Logo_URL__c;
        rhBrandHomePageURL = rhb.Brand_Home_Page_URL__c;
        rhBrandLogoWidth = rhb.Brand_Logo_Width__c;
        rhBrandLogoHeight = rhb.Brand_Logo_Height__c;
        
        String rhBrandLogo = '<a style="color:#000" href="' + rhBrandHomePageURL + '" target="_blank"><img src="' + rhBrandLogoURL + '" width="' + rhBrandLogoWidth + '" height="'+ rhBrandLogoHeight + '"></a>';
        
        // Get the from email address, from name, and phone if Client Type is Contract
        List<String> fromList = new List<String>();
        List<String> fromNameList = new List<String>();
        User contractPM = new User();
        String cnName = bst.FromName__c;
        String cnEmail = bst.Email1__c;
        String cnRHEmail = bst.Email2__c;
        String cnDashPhone = bst.Phone1__c;
        String cnPhone = bst.Phone2__c;
        if (bsOrder.Client_Type__c == 'Contract') {
            if (bsOrder.Opportunity__c != null && bsOrder.Opportunity__r.Ops_Contact__c != null) {
                contractPM = [select Id, Name, Email, Phone from User where Id = :bsOrder.Opportunity__r.Ops_Contact__c];
                cnName = contractPM.Name;
                cnEmail = contractPM.Email;
                cnRHEmail = cnEmail.replaceFirst('@rh', '@RH');
                if (String.isNotBlank(contractPM.Phone)) {
                    cnDashPhone = contractPM.Phone;
                    if (cnDashPhone.startsWith('(')) {
                        cnDashPhone = cnDashPhone.remove(' ');
                        cnDashPhone = cnDashPhone.substring(1);
                        cnDashPhone = cnDashPhone.replaceFirst('[)]', '-');
                    }
                    cnPhone = cnDashPhone.remove('-');
                }
            }
            fromList.add(cnEmail);
            fromNameList.add(cnName);
            
        } else {
            
            fromList.add(bst.Email1__c);
            fromNameList.add(bst.FromName__c);
        }
        
        List<String> subjectList = new List<String>();
        subjectList.add(rhBrand + ' Billing Summary - Order ' + bsOrder.Name);
        
        List<String> toList = new List<String>();
        toList.add(bsOrder.To_Email_Address__c);
        if (String.isNotBlank(bsOrder.Additional_To_Email_Addresses__c)) {
            toList.addAll(bsOrder.Additional_To_Email_Addresses__c.split(',', 0));
        }
        
        List<String> bodyList = new List<String>();
        bodyList.add(bsOrder.Name);
        
        // Populate the email header with data
        subMap.put('%rhBrandLogo%', rhBrandLogo);
        subMap.put('%orderDesc%', bsOrder.Ship_To_1_Order_Description__c); //bsOrder.Name);
        subMap.put('%orderNumber%', bsOrder.Name);
        String soldToName = Utility.toFirstCap(bsOrder.Sold_to_First_Name__c, 3);
        if (String.isNotBlank(soldToName)) {
            soldToName += ' ';
        }
        soldToName += Utility.toFirstCap(bsOrder.Sold_to_Last_Name__c, 0);
        subMap.put('%oSoldToName%', (String.isBlank(soldToName) ? ' ' : soldToName));
        subMap.put('%oSoldToAddr1%', Utility.toFirstCap(bsOrder.Sold_to_Address_1__c, 0));
        subMap.put('%oSoldToAddr2%', Utility.toFirstCap(bsOrder.Sold_to_Address_2__c, 0));
        subMap.put('%oSoldToCity%', Utility.toFirstCap(bsOrder.Sold_to_City__c, 0));
        subMap.put('%oSoldToState%', Utility.toFirstCap(bsOrder.Sold_to_State__c, 3));
        subMap.put('%oSoldToZip%', bsOrder.Sold_to_Zip__c);
        subMap.put('%oSoldToPhone%', Utility.formatPhone10(bsOrder.Sold_to_Day_Phone__c));
        subMap.put('%oSoldToEmail%', bsOrder.Sold_to_Email__c);
        subMap.put('%orderDate%', Utility.usDate(bsOrder.Order_Date__c, '/'));
        
        // Utility.usWrittenDate(bsOrder.Order_Date__c, true));
        

        
        // Populate the email footer with data
        if (bsOrder.Client_Type__c == 'Contract') {
            subMap.put('%email1%', cnEmail);
            subMap.put('%email2%', cnRHEmail);
            subMap.put('%phone1%', Utility.formatPhone10(cnDashPhone));
            subMap.put('%phone2%', Utility.formatPhone10(cnPhone));
            subMap.put('%phone3%', Utility.formatPhone10(cnDashPhone));
        } else {
            subMap.put('%email1%', bst.Email1__c);
            subMap.put('%email2%', bst.Email2__c);
            subMap.put('%phone1%', Utility.formatPhone10(bst.Phone1__c));
            subMap.put('%phone2%', Utility.formatPhone10(bst.Phone2__c));
            subMap.put('%phone3%', Utility.formatPhone10(bst.Phone3__c));
        }
  
        return subMap;
}

public static List<RH_Invoice.InvoiceLineWrapper> bsInvoiceLineWrapper(Id orderId, String clientType){
        // Read in the Order, Template and Brand related data we need to populate the email template
        RH_Order__c bsOrder = new RH_Order__c();
        bsOrder = [select Id, Name, Opportunity__c, Opportunity__r.Ops_Contact__c,  Sold_to_Address_1__c, Sold_to_Address_2__c, 
                Sold_to_City__c, Sold_to_State__c, Sold_to_Zip__c, Sold_to_First_Name__c, Sold_to_Last_Name__c, Sold_to_Email__c, 
                Sold_to_Day_Phone__c, Order_Date__c, Division__c, Client_Type__c, 
                To_Email_Address__c, Additional_To_Email_Addresses__c 
                from RH_Order__c where Id = :orderId];
        
        // Get Invoice data
        List<CWInvoice> invoiceData = CWCalloutService.retrieveInvoiceData(bsOrder.Name); //getInvoiceData(); // gets the invoice data and details.
        List<RH_Invoice.InvoiceLineWrapper> invoiceList = new List<RH_Invoice.InvoiceLineWrapper>();
        return RH_Invoice.getInvoiceLineWrapper(invoiceData, bsOrder.Name, 'Invoice Date');     
}

public static void saveContent(Map<String, String> subMap, Id orderId){
    String emailContent = JSON.serialize(subMap);
    Decimal emailContentLength = emailContent.length();
    Decimal parts = emailContentLength / 131072;
    Integer interations = Integer.valueOf(parts.round(System.RoundingMode.CEILING));
    List<OrderEmailContent__c> contentList = new List<OrderEmailContent__c>();
    
    for(Integer contentChunk=0;contentChunk < interations; contentChunk++){
       OrderEmailContent__c oec = new OrderEmailContent__c();
       oec.RH_Order__c = orderId;
       oec.Sequence__c = Decimal.ValueOf(contentChunk+1);
       if(contentChunk == interations-1){
          oec.EmailContent__c = emailContent.substring(contentChunk * 131072);
       }else{
          oec.EmailContent__c = emailContent.substring(contentChunk * 131072, (contentChunk * 131072) + 131072);
       }
       contentList.add(oec);
    } 
    insert contentList;
}

public static void deleteContent(Id orderId){
    List<OrderEmailContent__c> deleteOrderEmailContent = new List<OrderEmailContent__c>();
    for(OrderEmailContent__c oec:[select id 
                                    from OrderEmailContent__c 
                                   where RH_Order__c = :orderId]){
        deleteOrderEmailContent.add(oec);
    }
    if(!deleteOrderEmailContent.isEmpty()){
        delete deleteOrderEmailContent;
    }
}
 
@future(callout=true)
public static void processEmailService(Id orderId, String clientType){  
        List<RH_Invoice.InvoiceLineWrapper> invoiceList = BillingSummaryEmail.bsInvoiceLineWrapper(orderId, clientType);
        Map<String, String> subMap = BillingSummaryEmail.getEmailContent(orderId, clientType, invoiceList, CPULimitThreshold__c.getInstance('Asynchronous').Milliseconds__c - 1000);
        BillingSummaryEmail.useEmailService(orderId, subMap);
}

@future(callout=true)
public static void writeEmailContent(Id orderId, String clientType){    
        List<RH_Invoice.InvoiceLineWrapper> invoiceList = BillingSummaryEmail.bsInvoiceLineWrapper(orderId, clientType);
        Map<String, String> subMap = BillingSummaryEmail.getEmailContent(orderId, clientType, invoiceList, CPULimitThreshold__c.getInstance('Asynchronous').Milliseconds__c - 1000);
        BillingSummaryEmail.saveContent(subMap, orderId);
}
   
public static Map<String, String> getEmailContent(Id orderId, String clientType, List<RH_Invoice.InvoiceLineWrapper> invoiceList, Decimal threshold) {
        Decimal CPUTime = System.Now().getTime();
        Id rhProductionOrgId = '00D500000007MjVEAU';
        Map<Id, String> resultsMap = new Map<Id, String>();
        Map<String, String> subMap = new Map<String, String>();
        subMap = headerFooterContent(orderId, clientType);
        
        // Read in the Order, Template and Brand related data we need to populate the email template
        RH_Order__c bsOrder = new RH_Order__c();
        bsOrder = [select Id, Name, Opportunity__c, Opportunity__r.Ops_Contact__c,  Sold_to_Address_1__c, Sold_to_Address_2__c, 
                Sold_to_City__c, Sold_to_State__c, Sold_to_Zip__c, Sold_to_First_Name__c, Sold_to_Last_Name__c, Sold_to_Email__c, 
                Sold_to_Day_Phone__c, Order_Date__c, Division__c, Client_Type__c, 
                To_Email_Address__c, Additional_To_Email_Addresses__c 
                from RH_Order__c where Id = :orderId];
        
        // Get Gift Card, non-Gift Card, DELIVERYFEE, and Payment type invoice maps with the invoice number as the key
        Map<Integer, List<RH_Invoice.InvoiceLineWrapper>> invGiftMap = new Map<Integer, List<RH_Invoice.InvoiceLineWrapper>>();
        invGiftMap = RH_Invoice.getGiftCardAccomMap(invoiceList);
        
        Map<Integer, List<RH_Invoice.InvoiceLineWrapper>> invMap = new Map<Integer, List<RH_Invoice.InvoiceLineWrapper>>();
        invMap = RH_Invoice.getInvMap(invoiceList);
        
        Map<Integer, List<RH_Invoice.PaymentTypeTotal>> ptTotalMap = new Map<Integer, List<RH_Invoice.PaymentTypeTotal>>();
        ptTotalMap = RH_Invoice.getPaymentTypeTotals(invoiceList);
        
        // Get the Billing Activity totals
        RH_Invoice.BillingActivity baTotals = new RH_Invoice.BillingActivity();
        baTotals = RH_Invoice.getBillingActivityTotals(invoiceList);
         
        SendGrid_RH sgRH = new SendGrid_RH();
        Map<Id, SendGrid_RH.SendGrid_RH_Data> sgrhDataMap = new Map<Id, SendGrid_RH.SendGrid_RH_Data>();
          
        // Populate the email with the Billing Activity information
        String baMerch = bsDollarAmount(baTotals.merchTotal, false);
        String baRefAccom = bsDollarAmount(baTotals.accomTotal, false);
        String baTax = bsDollarAmount(baTotals.taxTotal, false);
        String baStdShip = bsDollarAmount(baTotals.freightTotal, false);
        String baExpShip = bsDollarAmount(baTotals.additionalFreightTotal, false);
        String baUnlFurn = bsDollarAmount(baTotals.handlingTotal, false);
        String baGiftBox = bsDollarAmount(baTotals.additionalChargeTotal, false);
        String baTotal = bsDollarAmount(baTotals.grandTotal, true);
        
        String billingActivity = '<td style="width:570px;vertical-align:top;padding:0 0 10px 0">';
        billingActivity += '<table style="color:#000;line-height:17px;font-family:&#39;minion-pro&#39;,sans-serif;font-size:12px;text-transform:uppercase" cellpadding="0" cellspacing="0">';
        billingActivity += '<tbody>';
         
        billingActivity += '<tr><td height="25" style="color:000;font-weight:bold;text-transform:uppercase">Total Billed To Date</td></tr>';

        billingActivity += '</tbody></table></td>';
        
        billingActivity += '<td style="width:80px;vertical-align:top;padding:0 0 10px 10px">';
        billingActivity += '<table style="float:right;color:#000;line-height:17px;font-family:&#39;minion-pro&#39;,sans-serif;font-size:12px" cellpadding="0" cellspacing="0">';
        billingActivity += '<tbody>';
        
        billingActivity += '<tr><td height="25" style="padding-right:10px;text-align:right;color:#000;font-weight:bold">' + baTotal + '</td></tr>';
        
        billingActivity += '</tbody></table></td>';
        
        subMap.put('%billingActivity%', billingActivity);
        
        // Populate the email with the invoice detail information
        String noLogo = PaymentType__c.getInstance('1').Logo_URL__c;
        PaymentType__c payType;
        String ccLogo;
        Decimal invTotalNum;
        String invTotal;
        String invDetail = '';
        
        if (!invMap.isEmpty()) {
            invDetail = '<tr>';
            invDetail += '<td style="vertical-align:top;border-top:1px solid #333;height:auto">';
            
            invDetail += '<table cellpadding="0" cellspacing="0" style="border-bottom:1px solid #ccc;color:#333;font-family:\'minion-pro\',sans-serif;font-size:12px;vertical-align:top;margin:20px auto 10px auto;width:650px;height:auto;line-height:31px;text-transform:uppercase">';
            invDetail += '<thead style="text-align:left">';
            invDetail += '<tr style="text-align:left">';
            invDetail += '<th style="width:80px">Date</th>';
            invDetail += '<th style="width:360px">Item</th>';
            invDetail += '<th style="text-align:center;width:40px">Qty</th>';
            invDetail += '<th style="text-align:center;width:90px">Price</th>';
            invDetail += '<th style="text-align:center;width:80px">Amt. Billed</th>';
            invDetail += '</tr></thead></table>';
            
            Boolean firstRow;
            Boolean bomComponent;
            Boolean allZeroSKUs;
            Boolean allGiftCardZeroSKUs;
            Boolean allBlankSKUs;
            Decimal unitPrice;
            Decimal totalPrice;
            String invDate;
            String chargeDesc;
            String prodDesc;
            String qtyShipped;
            String merchUnitPrice;
            String merchTotalPrice;
            String payDescription;
            String invAddChg;
            String invStdShip;
            String invExpShip;
            String invUnlFurn;
            String invTax;
            
            // Loop through each Invoice
            for (Integer invNum :invMap.keySet()) {
            	
                invTotalNum = 0.00;
                firstRow = true;
                allZeroSKUs = false;
                allGiftCardZeroSKUs = false;
                allBlankSKUs = false;
                
                // Loop through each Invoice Line except DELIVERYFEE Sku
                // Per Stephanie Zevely on August 12, 2016 at 3:42 PM: 
                // all freight, additional freight, and handling should show even if there is no sku.
                if (!invMap.get(invNum)[0].delFee) {
                    allZeroSKUs = true;
                    allGiftCardZeroSKUs = true;
                    allBlankSKUs = true;
                    
                    for (RH_Invoice.InvoiceLineWrapper ilw :invMap.get(invNum)) {
                       
                       Decimal diff = System.Now().getTime() - CPUTime;
                
                       if(System.Now().getTime() - CPUTime > threshold){
                          throw new CPUTimeoutException('Your order contains many invoies and will take a while to generate.'); 
                       }  
                    
                        unitPrice = ilw.line.MerchandiseUnitPriceIL;
                        totalPrice = ilw.line.QuantityShipped * ilw.line.MerchandiseUnitPriceIL;
                        
                        // If there is not SKU Id, skip it
                        if (String.isBlank(ilw.skuId)) {
                            //continue;
                        }
                        allBlankSKUs = false;
                        
                        // If special accommodation zero dollar SKU and totalPrice is zero, skip it
                        if (ilw.skuType == 'Accommodation Zero Dollar' && totalPrice == 0) {
                            continue;
                        }
                        allZeroSKUs = false;
                        
                        // If special accommodation gift card zero dollar sku, skip it
                        if (ilw.skuType == 'Accommodation Gift Card Zero Dollar') {
                        	continue;
                        }
                        allGiftCardZeroSKUs = false;
                        
                        if (firstRow) {
//                            invDate = Utility.usWrittenDate(ilw.invDate, false);
                            invDate = Utility.usDate(ilw.invDate, '/');
                        } else {
                            invDate = ' ';
                        }
                        firstRow = false;
                    
                        chargeDesc = '';
                        if (ilw.refund) {
                            chargeDesc = '<span style="font-weight:bold;">Refund - ';
                        }
                        if (ilw.priceAdj) {
                            chargeDesc = '<span style="font-weight:bold;">Price Adjustment - ';
                        }
                        if (ilw.preBill) {
                            if (String.isBlank(chargeDesc)) {
                                chargeDesc = '<span style="font-weight:bold;">';
                            }
                            chargeDesc += 'Custom Order Deposit - ';
                        }
                        if (String.isNotBlank(chargeDesc)) {
                            chargeDesc += '</span>';
                        }
                        
                        prodDesc = ilw.prodDesc;
                        
                        // Determine how to display BOM header and component
                        bomComponent = false;
                        
                        if (ilw.line.BOMComponentSequence != '0') {                            
                            // If BOM header, add to product description and calculate unit price and total price from BOM components
                            if (ilw.bomSku) {
                                prodDesc += '<br/><span style="font-style:italic;font-size:9px;">This item is made up of individual components listed below:</span>';
                                unitPrice = 0;
                                totalPrice = 0;
                                for (RH_Invoice.InvoiceLineWrapper bom :invMap.get(invNum)) {
                                   if (ilw.line.BOMComponentSequence == bom.line.BOMComponentSequence && !bom.bomSku) {
                                        //unitPrice += bom.inv.Merchandise_Unit_Price_IL__c;
                                        totalPrice += (bom.line.QuantityShipped * bom.line.MerchandiseUnitPriceIL);
                                    }
                                }
                            } else {
                                
                                // If BOM component, set bomComponent flag to true (for display purposes), only if the BOM header exists in this invoice
                                for (RH_Invoice.InvoiceLineWrapper bom :invMap.get(invNum)) {
                                    if (bom.line.BOMComponentSequence == bom.line.BOMComponentSequence && bom.bomSku) {
                                        bomComponent = true;
                                    }                                  
                                }
                            }
                        }
                        
                        qtyShipped = String.valueOf(ilw.line.QuantityShipped);
                        if (ilw.bomSku && unitPrice == 0) {
                            merchUnitPrice = '&nbsp;';
                        } else {
                            merchUnitPrice = bsDollarAmount(unitPrice, true);
                        }
                        merchTotalPrice = bsDollarAmount(totalPrice, true);
                        
                        if(!String.isBlank(ilw.skuId)){
                        	
                            invDetail += '<table cellpadding="0" cellspacing="0" style="text-align:left;font-size:12px;vertical-align:top;margin:0 auto;width:650px;height:auto">';
                            invDetail += '<tbody><tr>';
                        
                            invDetail += '<td style="width:80px;vertical-align:top">';
                            invDetail += '<table cellpadding="0" cellspacing="0" style="color:#000;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:12px;text-transform:uppercase">';
                            invDetail += '<tbody><tr><td height="25" style="vertical-align:top">' + invDate + '</td></tr></tbody>';
                            invDetail += '</table></td>';
                        
                            invDetail += '<td style="width:360px;vertical-align:top">';
                            invDetail += '<table cellpadding="0" cellspacing="0" style="color:#666;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:12px;text-transform:uppercase">';
                            if (bomComponent) {
                                invDetail += '<tbody><tr><td height="10" style="text-indent:15px;font-size:10px;vertical-align:top;padding-bottom:5px">' + chargeDesc + prodDesc + '</td></tr></tbody>';
                            } else {
                                //invDetail += '<tbody><tr><td height="25" style="vertical-align:top;padding-bottom:5px">' + chargeDesc + prodDesc + '</td></tr></tbody>';
                                
                                if (ilw.line.NoChargeReplacementIndicator == 'Y' || ilw.skuId == 'GCNCRRTN10' || ilw.skuId == 'CSHNCRTN10') {
                                	invDetail += '<tbody><tr><td height="15" style="vertical-align:top;padding-bottom:0px">';
                                } else {
                                	invDetail += '<tbody><tr><td height="25" style="vertical-align:top;padding-bottom:5px">';
                                }
                                invDetail += chargeDesc + prodDesc + '</td></tr></tbody>';
                            }
                            
                            if(ilw.line.NoChargeReplacementIndicator == 'Y'){                               
                               if(ilw.line.QuantityShipped < 0){
                                  invDetail += '<tbody><tr><td height="25" style="text-indent:15px;vertical-align:top;padding-bottom:5px"><span style="font-weight:bold;">- NO COST REPLACEMENT RETURN​</span></td></tr></tbody>';
                               }                            
                               if(ilw.line.QuantityShipped > 0){
                                  invDetail += '<tbody><tr><td height="25" style="text-indent:15px;vertical-align:top;padding-bottom:5px"><span style="font-weight:bold;">- NO COST REPLACEMENT ITEM​ SHIPPED</span></td></tr></tbody>';                                                            
                               }
                            }     
                            
                            //"​​- NO COST REPLACEMENT REFUND​" is the accommodation skus below:
                            system.debug('SKU=============> ' + ilw.skuId);
                            //GCNCRRTN10 or CSHNCRTN10 
                            if(ilw.skuId == 'GCNCRRTN10' || ilw.skuId == 'CSHNCRTN10'){ 
                               invDetail += '<tbody><tr><td height="25" style="text-indent:15px;vertical-align:top;padding-bottom:5px"><span style="font-weight:bold;">- NO COST REPLACEMENT REFUND​</span></td></tr></tbody>';                                                                                        
                            }
                            
                            invDetail += '</table></td>';
                        
                            invDetail += '<td style="width:40px;vertical-align:top">';
                            invDetail += '<table cellpadding="0" cellspacing="0" style="float:right;color:#666;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:12px;text-transform:uppercase">';
                            if (bomComponent) {
                                invDetail += '<tbody><tr><td height="10" style="font-size:10px;padding-right:10px;text-align:right;vertical-align:top">' + qtyShipped + '</td></tr></tbody>';
                            } else {
                                invDetail += '<tbody><tr><td height="25" style="padding-right:10px;text-align:right;vertical-align:top">' + qtyShipped + '</td></tr></tbody>';
                            }
                            invDetail += '</table></td>';
                        
                            invDetail += '<td style="width:90px;vertical-align:top">';
                            invDetail += '<table cellpadding="0" cellspacing="0" style="float:right;color:#666;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:12px;text-transform:uppercase">';
                            if (bomComponent) {
                                invDetail += '<tbody><tr><td height="10" style="font-size:10px;padding-right:20px;text-align:right;vertical-align:top">' + merchUnitPrice + '</td></tr></tbody>';
                            } else {
                                invDetail += '<tbody><tr><td height="25" style="padding-right:20px;text-align:right;vertical-align:top">' + merchUnitPrice + '</td></tr></tbody>';
                            }
                            invDetail += '</table></td>';
                        
                            invDetail += '<td style="width:80px;vertical-align:top">';
                            invDetail += '<table cellpadding="0" cellspacing="0" style="float:right;color:#666;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:12px;text-transform:uppercase">';
                            if (bomComponent) {
                                invDetail += '<tbody><tr><td height="10" style="font-size:10px;padding-right:10px;text-align:right;vertical-align:top">' + merchTotalPrice + '</td></tr></tbody>';
                            } else {
                                invDetail += '<tbody><tr><td height="25" style="padding-right:10px;text-align:right;vertical-align:top">' + merchTotalPrice + '</td></tr></tbody>';
                            }
                            invDetail += '</table></td>';
                        
                            invDetail += '</tr></tbody></table>';
                            
                        }
                                             
                    }
                }
            
                // Finish off the invoice Line portion
                invDetail += '</td>';
                invDetail += '</tr>';
                
                // If all SKU Ids for this Invoice are are zero or blank, skip the totals section
                if (allGiftCardZeroSKUs || (allBlankSKUs && invMap.get(invNum)[0].inv.additionalCharge.size() == 0)) {
                    continue;
                }
                
                // Prepare the totals for the invoice
                invAddChg = bsDollarAmount(invMap.get(invNum)[0].inv.AdditionalChargeAmountIST, false);
                invStdShip = bsDollarAmount(invMap.get(invNum)[0].inv.FreightAmountIST, false);
                invExpShip = bsDollarAmount(invMap.get(invNum)[0].inv.AdditionalFreightAmountIST, false);
                invUnlFurn = bsDollarAmount(invMap.get(invNum)[0].inv.HandlingAmountIST, false);
                invTax = bsDollarAmount(invMap.get(invNum)[0].inv.TaxAmountIST, false);
                invTotalNum = invMap.get(invNum)[0].inv.MerchandiseAmountIST + invMap.get(invNum)[0].inv.AdditionalChargeAmountIST + invMap.get(invNum)[0].inv.FreightAmountIST + invMap.get(invNum)[0].inv.AdditionalFreightAmountIST + invMap.get(invNum)[0].inv.HandlingAmountIST + invMap.get(invNum)[0].inv.TaxAmountIST;
                invTotal = bsDollarAmount(invTotalNum, true);
                
                // If DELIVERYFEE SKU or all SKUs are either special zero dollar SKUs or are missing, show date on first row of the invoice totals section
                if (invMap.get(invNum)[0].delFee || allZeroSKUs || invMap.get(invNum)[0].nonMerchRefund || (String.isNotBlank(invAddChg) && String.isBlank(invMap.get(invNum)[0].skuId))) {
//                    invDate = Utility.usWrittenDate(invMap.get(invNum)[0].invDate, false);
                    invDate = Utility.usDate(invMap.get(invNum)[0].invDate, '/');
                } else {
                    invDate = '&nbsp;';
                }
                
                // Populate the email with the invoice totals
                invDetail += '<tr><td>';
                invDetail += '<table cellpadding="0" cellspacing="0" style="text-align:left;font-size:12px;vertical-align:top;margin:0 auto;width:650px;height:auto">';
                invDetail += '<tbody><tr>';
                
                invDetail += '<td style="width:80px;vertical-align:top">';
                invDetail += '<table cellpadding="0" cellspacing="0" style="color:#000;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:12px;text-transform:uppercase">';
                invDetail += '<tbody>';
                if (String.isNotBlank(invAddChg)) {
                    invDetail += '<tr><td height="60" style="vertical-align:top">' + invDate + '</td></tr>';
                    invDate = '&nbsp;';
                }
                if (String.isNotBlank(invStdShip)) {
                    invDetail += '<tr><td height="25" style="vertical-align:top">' + invDate + '</td></tr>';
                    invDate = '&nbsp;';
                }
                if (String.isNotBlank(invExpShip)) {
                    invDetail += '<tr><td height="25" style="vertical-align:top">' + invDate + '</td></tr>';
                    invDate = '&nbsp;';
                }
                if (String.isNotBlank(invUnlFurn)) {
                    invDetail += '<tr><td height="25" style="vertical-align:top">' + invDate + '</td></tr>';
                    invDate = '&nbsp;';
                }
                if (String.isNotBlank(invTax)) {
                    invDetail += '<tr><td height="25" style="vertical-align:top">' + invDate + '</td></tr>';
                    invDate = '&nbsp;';
                }
                invDetail += '<tr><td height="25" style="vertical-align:top">&nbsp;</td></tr>';
                invDetail += '</tbody></table></td>';
                
                invDetail += '<td style="width:360px;vertical-align:top">';
                invDetail += '<table cellpadding="0" cellspacing="0" style="color:#000;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:12px;text-transform:uppercase">';
                invDetail += '<tbody>';
                
                if (String.isNotBlank(invAddChg)) {
                    //invDetail += '<tr><td height="25" style="vertical-align:top">Gift Box</td></tr>';
                    //invDetail += '<tr><td height="60" style="vertical-align:top">Additional Charges<br/><span style="font-style:italic;font-size:9px;">* May include Gift Boxing, Additional Freight, Monogramming, or other Misc. Charges.</span></td></tr>';
                    invDetail += '<tr><td height="25" style="vertical-align:top">Additional Charges<span style="font-style:italic;font-size:9px;"></span></td></tr>';
                    
                    //ADDITIONAL CHARGE INFO
                    if(invMap.get(invNum)[0].inv.additionalCharge.size() > 0){
                       for(CWInvoice.CWInvoiceAdditionalCharge ac: invMap.get(invNum)[0].inv.additionalCharge){ 
                          invDetail += '<tr><td style="width:360px;vertical-align:top">';
                          invDetail += '<table cellpadding="0" cellspacing="0" style="color:#666;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:12px;text-transform:uppercase">';
                          invDetail += '<tbody><tr><td height="25" style="vertical-align:top;padding-bottom:5px;padding-left:15px;">' + ac.chargeCode + ' - ' + ac.chargeDescription + '($' + ac.chargeAmount + ')' + '</td></tr></tbody>';
                          invDetail += '</table></td></tr>';                                                     
                       }
                    }
                    
                    
                }              
                if (String.isNotBlank(invStdShip)) {
                    invDetail += '<tr><td height="25" style="vertical-align:top">Standard/Parcel Shipping</td></tr>';
                }
                if (String.isNotBlank(invExpShip)) {
                    invDetail += '<tr><td height="25" style="vertical-align:top">Expedited Shipping &amp; Delivery Surcharges</td></tr>';
                }
                if (String.isNotBlank(invUnlFurn)) {
                    invDetail += '<tr><td height="25" style="vertical-align:top">Unlimited Furniture Delivery, Personalization, &amp; Mattress Recycling Fee</td></tr>';
                }
                if (String.isNotBlank(invTax)) {
                    invDetail += '<tr><td height="25" style="vertical-align:top">Tax</td></tr>';
                }
                if(ptTotalMap.ContainsKey(invNum)){
                   invDetail += '<tr><td height="25" style="vertical-align:top;color:000;font-weight:bold">Total</td></tr>';
                }
                invDetail += '</tbody></table></td>';
                
                invDetail += '<td style="width:40px;vertical-align:top">';
                invDetail += '<table cellpadding="0" cellspacing="0" style="color:#000;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:12px;text-transform:uppercase">';
                invDetail += '<tbody>';
                if (String.isNotBlank(invAddChg)) {
                    invDetail += '<tr><td height="60" style="vertical-align:top">&nbsp;</td></tr>';
                }
                if (String.isNotBlank(invStdShip)) {
                    invDetail += '<tr><td height="25" style="vertical-align:top">&nbsp;</td></tr>';
                }
                if (String.isNotBlank(invExpShip)) {
                    invDetail += '<tr><td height="25" style="vertical-align:top">&nbsp;</td></tr>';
                }
                if (String.isNotBlank(invUnlFurn)) {
                    invDetail += '<tr><td height="25" style="vertical-align:top">&nbsp;</td></tr>';
                }
                if (String.isNotBlank(invTax)) {
                    invDetail += '<tr><td height="25" style="vertical-align:top">&nbsp;</td></tr>';
                }
                invDetail += '<tr><td height="25" style="vertical-align:top;color:000;font-weight:bold">&nbsp;</td></tr>';
                invDetail += '</tbody></table></td>';
                
                invDetail += '<td style="width:90px;vertical-align:top">';
                invDetail += '<table cellpadding="0" cellspacing="0" style="color:#000;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:12px;text-transform:uppercase">';
                invDetail += '<tbody>';
                if (String.isNotBlank(invAddChg)) {
                    invDetail += '<tr><td height="60" style="vertical-align:top">&nbsp;</td></tr>';
                }
                if (String.isNotBlank(invStdShip)) {
                    invDetail += '<tr><td height="25" style="vertical-align:top">&nbsp;</td></tr>';
                }
                if (String.isNotBlank(invExpShip)) {
                    invDetail += '<tr><td height="25" style="vertical-align:top">&nbsp;</td></tr>';
                }
                if (String.isNotBlank(invUnlFurn)) {
                    invDetail += '<tr><td height="25" style="vertical-align:top">&nbsp;</td></tr>';
                }
                if (String.isNotBlank(invTax)) {
                    invDetail += '<tr><td height="25" style="vertical-align:top">&nbsp;</td></tr>';
                }
                invDetail += '<tr><td height="25" style="vertical-align:top;color:000;font-weight:bold">&nbsp;</td></tr>';
                invDetail += '</tbody></table></td>';
                
                invDetail += '<td style="width:80px;vertical-align:top">';
                invDetail += '<table cellpadding="0" cellspacing="0" style="float:right;color:#000;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:12px;text-transform:uppercase">';
                invDetail += '<tbody>';
                if (String.isNotBlank(invAddChg)) {
                    invDetail += '<tr><td height="60" style="padding-right:10px;text-align:right;vertical-align:top">' + invAddChg + '</td></tr>';                     
                }
                if (String.isNotBlank(invStdShip)) {
                    invDetail += '<tr><td height="25" style="padding-right:10px;text-align:right;vertical-align:top">' + invStdShip + '</td></tr>';
                }
                if (String.isNotBlank(invExpShip)) {
                    invDetail += '<tr><td height="25" style="padding-right:10px;text-align:right;vertical-align:top">' + invExpShip + '</td></tr>';
                }
                if (String.isNotBlank(invUnlFurn)) {
                    invDetail += '<tr><td height="25" style="padding-right:10px;text-align:right;vertical-align:top">' + invUnlFurn + '</td></tr>';
                }
                if (String.isNotBlank(invTax)) {
                    invDetail += '<tr><td height="25" style="padding-right:10px;text-align:right;vertical-align:top">' + invTax + '</td></tr>';
                }
                if(ptTotalMap.ContainsKey(invNum)){
                   invDetail += '<tr><td height="25" style="padding-right:10px;text-align:right;vertical-align:top;color:000;font-weight:bold">' + invTotal + '</td></tr>';
                }
                invDetail += '</tbody></table></td>';
                
                // Finish off the Invoice Totals portion
                invDetail += '</tr></tbody></table>';
                invDetail += '</td></tr>';
                
                // Add the payment type totals information
                invDetail += '<tr><td>';
                invDetail += '<table cellpadding="0" cellspacing="0" style="text-align:left;font-size:12px;vertical-align:top;margin:0 auto;width:650px;height:auto">';
                invDetail += '<tbody>';
                
                if(ptTotalMap.ContainsKey(invNum)){
                  for (RH_Invoice.PaymentTypeTotal ptt :ptTotalMap.get(invNum)) {
                    ccLogo = noLogo;
                    if (String.isNotBlank(ptt.paymentType)) {
                        payType = PaymentType__c.getInstance(ptt.paymentType);
                        if (payType != null) {
                            ccLogo = payType.Logo_URL__c;
                        }
                    }
                    if (String.isBlank(ptt.ccNumber)) {
                        payDescription = ptt.paymentTypeDescription;
                    } else {
                        payDescription = '<img src="' + ccLogo + '">&nbsp;' + ptt.ccNumber;
                    }
                    
                    invDetail += '<tr>';
                    
                    invDetail += '<td style="width:80px;vertical-align:top;padding:10px 0 10px 0">';
                    invDetail += '<table cellpadding="0" cellspacing="0" style="color:#000;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:12px;text-transform:uppercase">';
                    invDetail += '<tbody><tr><td height="25" style="text-align:right;vertical-align:top">&nbsp;</td</tr></tbody>';
                    invDetail += '</table></td>';
                    
                    invDetail += '<td style="width:360px;vertical-align:top;padding:0 0 10px 0">';
                    invDetail += '<table cellpadding="0" cellspacing="0" style="color:#000;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:12px;text-transform:uppercase">';
                    invDetail += '<tbody>';
                    invDetail += '<tr><td height="25" style="text-align:left;text-transform:none">' + payDescription + '</td></tr>';
                    if(payType != null && payType.PLCC__c){
                       invDetail += '<tr><td height="25" style="text-align:left;text-transform:none">' + payType.Description__c + '</td></tr>';
                    }
                    invDetail += '</tbody>';
                    invDetail += '</table></td>';
                    
                    invDetail += '<td style="width:40px;vertical-align:top;padding:0 0 10px 0">';
                    invDetail += '<table cellpadding="0" cellspacing="0" style="color:#000;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:12px;text-transform:uppercase">';
                    invDetail += '<tbody><tr><td height="25" style="text-align:right;vertical-align:top;color:000;font-weight:bold">&nbsp;</td></tr></tbody>';
                    invDetail += '</table></td>';
                    
                    invDetail += '<td style="width:90px;vertical-align:top;padding:0 0 10px 0">';
                    invDetail += '<table cellpadding="0" cellspacing="0" style="color:#000;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:12px;text-transform:uppercase">';
                    invDetail += '<tbody><tr><td height="25" style="text-align:right;vertical-align:top;color:000;font-weight:bold">&nbsp;</td></tr></tbody>';
                    invDetail += '</table></td>';
                    
                    invDetail += '<td style="width:80px;vertical-align:top;padding:0 0 10px 0">';
                    invDetail += '<table cellpadding="0" cellspacing="0" style="float:right;color:#000;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:12px;text-transform:uppercase">';
                    invDetail += '<tbody><tr><td height="25" style="padding-right:10px;text-align:right;vertical-align:top;color:000">' + bsDollarAmount(ptt.totalAmount, true) + '</td></tr></tbody>';
                    invDetail += '</table></td>';
                    
                    invDetail += '</tr>';
                  }
                }
                
                // Finish off the payment type totals information
                invDetail += '</tbody></table>';
                invDetail += '</td></tr>';
            }
        }
        
        subMap.put('%invoiceDetail%', invDetail);
        
        // Populate the email with the Gift Card detail information
        String invGift = '';
        if (!invGiftMap.isEmpty()) {
            Decimal giftTotal = 0.00;
            
            invGift = '<tr>';
            invGift += '<table cellpadding="0" cellspacing="0" style="text-align:left;color:#333;font-family:\'minion-pro\',sans-serif;font-size:12px;vertical-align:top;margin:0 auto;width:700px;height:auto;line-height:31px;">';
            invGift += '<tr><td style="border-bottom:1px solid #333;font-family:\'minion-pro\',\'Times New Roman\',Times,serif;line-height:31px;text-indent:25px;margin-left:340px;font-weight:normal;font-size:14px;color:#000;letter-spacing:1px;text-transform:uppercase">Complimentary Credits</td></tr>';
            invGift += '</table>';
            invGift += '<tr>';
            invGift += '<td style="font-size:12px;vertical-align:top;background-color:#fff;height:auto">';
            
            invGift += '<br/><table cellpadding="0" cellspacing="0" style="border-bottom:1px solid #ccc;color:#333;font-family:\'minion-pro\',sans-serif;font-size:12px;vertical-align:top;margin:0 auto;width:650px;height:auto;line-height:31px;text-transform:uppercase">';
            invGift += '<thead style="tex qt-align:left">';
            invGift += '<tr style="text-align:left">';
            invGift += '<th style="width:80px">Date</th>';
            invGift += '<th style="width:490px">Item</th>';
            invGift += '<th style="text-align:center;width:80px">Amount</th>';
            invGift += '</tr></thead></table><br/>';
            
            Boolean firstRow;
            String invDate;
            
            // Loop through each Invoice
            for (Integer invNum :invGiftMap.keySet()) {
            
            invGift += '<table cellpadding="0" cellspacing="0" style="text-align:left;font-size:12px;vertical-align:top;margin:0 auto;width:650px;height:auto">';
            invGift += '<tbody>';
            
                firstRow = true;
                
                // Loop through each Invoice Line
                for (RH_Invoice.InvoiceLineWrapper ilw :invGiftMap.get(invNum)) {
                    
                    giftTotal += (ilw.line.QuantityShipped * ilw.line.MerchandiseUnitPriceIL);
                    
                    if (firstRow) {
                        //invDate = Utility.usWrittenDate(ilw.invDate, false);
                        invDate = Utility.usDate(ilw.invDate, '/');
                    } else {
                        invDate = '&nbsp;';
                    }
                    firstRow = false;
                    
                    invGift += '<tr>';
                    
                    invGift += '<td style="width:80px;vertical-align:top">';
                    invGift += '<table cellpadding="0" cellspacing="0" style="color:#000;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:12px;text-transform:uppercase">';
                    invGift += '<tbody><tr><td height="25" style="vertical-align:top">' + invDate + '</td></tr></tbody>';
                    invGift += '</table></td>';
                    
                    invGift += '<td style="width:490px;vertical-align:top">';
                    invGift += '<table cellpadding="0" cellspacing="0" style="color:#666;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:12px;text-transform:uppercase">';
                    invGift += '<tbody><tr><td height="25" style="vertical-align:top;padding-bottom:5px">' + ilw.prodDesc + '</td></tr></tbody>';
                    invGift += '</table></td>';
                    
                    invGift += '<td style="width:80px;vertical-align:top">';
                    invGift += '<table cellpadding="0" cellspacing="0" style="float:right;color:#000;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:12px;text-transform:uppercase">';
                    invGift += '<tbody><tr><td height="25" style="padding-right:10px;text-align:right;vertical-align:top">' + bsDollarAmount((ilw.line.QuantityShipped * ilw.line.MerchandiseUnitPriceIL), true) + '</td></tr></tbody>';
                    invGift += '</table></td>';
                    
                    invGift += '</tr>'; 
                }
                
                // Finish off the Gift Card line section
                invGift += '</tbody></table>';                
            }
            
            // Totals for the Gift Cards
            invGift += '<table cellpadding="0" cellspacing="0" style="text-align:left;font-size:12px;vertical-align:top;margin:0 auto;width:650px;height:auto">';
            invGift += '<tbody><tr>';
            
            invGift += '<td style="width:80px;vertical-align:top;padding:10px 0 10px 0">';
            invGift += '<table cellpadding="0" cellspacing="0" style="color:#000;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:12px;text-transform:uppercase">';
            invGift += '<tbody><tr><td height="25" style="vertical-align:top">&nbsp;</td></tr></tbody>';
            invGift += '</table></td>';
            
            invGift += '<td style="width:490px;vertical-align:top;padding:0 0 10px 0">';
            invGift += '<table cellpadding="0" cellspacing="0" style="color:#000;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:12px;text-transform:uppercase">';
            invGift += '<tbody><tr><td height="25" style="vertical-align:top;color:000;font-weight:bold">Total</td></tr></tbody>';
            invGift += '</table></td>';
            
            invGift += '<td style="width:80px;vertical-align:top;padding:0 0 10px 0">';
            invGift += '<table cellpadding="0" cellspacing="0" style="float:right;color:#000;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:12px;text-transform:uppercase">';
            invGift += '<tbody><tr><td height="25" style="padding-right:10px;text-align:right;vertical-align:top;color:000;font-weight:bold">' + bsDollarAmount(giftTotal, true) + '</td></tr></tbody>';
            invGift += '</table></td>';
            
            invGift += '</tr></tbody></table>';
            
        }
        invGift += '</td></tr>';
        
        subMap.put('%invoiceGift%', invGift);
        
        String emailParentId = 'ref:' + bsOrder.Id + ':ref';
        
        subMap.put('%emailThreadId%', emailParentId);
        
        return subMap;
    } 
    
     // Convert the decimal dollar amount to an html string dollar amount 
    public static String bsDollarAmount(Decimal dAmt, Boolean zeroOk) {
        Decimal absAmt;
        String sAmt = '';
        String zeroZero = '';
        
        if (dAmt != null) {
            if (dAmt == 0) {
                if (zeroOk) {
                    sAmt = '$' + String.valueOf(dAmt);
                }
            } else {
                absAmt = math.abs(dAmt);
                if ((absAmt * 10) - Decimal.valueOf((absAmt * 10).intValue()) == 0) {
                    zeroZero = '0';
                }
                if (absAmt - Decimal.valueOf(absAmt.intValue()) == 0) {
                    zeroZero = '.00';
                }
                
                if (dAmt < 0) {
                    sAmt = '<span style="color:#ff0000">($' + String.valueOf(absAmt.format()) + zeroZero + ')</span>';
                } else {
                    sAmt = '$' + String.valueOf(absAmt.format()) + zeroZero;
                }
            }
        }
        return sAmt;
    }
    
    public static void useEmailService(Id OrderId, Map<String, String> subMap){     
        // Email Services allow a larger (36MB Heap Size)                   
        Messaging.reserveSingleEmailCapacity(2);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {BillingSummaryEmailService__c.getInstance('SendBillingSummaryEmail').EmailServiceEmailAddress__c};        
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('webcs@rh.com');
        mail.setSenderDisplayName('RH Support');
        mail.setSubject(OrderId);
        mail.setPlainTextBody(JSON.serialize(subMap));
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });       
    }
    
    @future(callout=true)
    public static void sendEmail(Id orderId, Map<String, String> stringMap, Boolean isAutomated) {
        Map<String, String> subMap = stringMap;
        // Read in the Order, Template and Brand related data we need to populate the email template
        RH_Order__c bsOrder = new RH_Order__c();
        bsOrder = [select Id, Name, Opportunity__c, Opportunity__r.Ops_Contact__c,  Sold_to_Address_1__c, Sold_to_Address_2__c, 
                Sold_to_City__c, Sold_to_State__c, Sold_to_Zip__c, Sold_to_First_Name__c, Sold_to_Last_Name__c, Sold_to_Email__c, 
                Sold_to_Day_Phone__c, Order_Date__c, Division__c, Client_Type__c, 
                To_Email_Address__c, Additional_To_Email_Addresses__c 
                from RH_Order__c where Id = :orderId];
        Boolean isLarge = false;                
        if(isAutomated){            
            try{
               List<RH_Invoice.InvoiceLineWrapper> ILWrapper = BillingSummaryEmail.bsInvoiceLineWrapper(bsOrder.Id, bsOrder.Client_Type__c);
               subMap = BillingSummaryEmail.getEmailContent(bsOrder.Id, 'Standard', ILWrapper, CPULimitThreshold__c.getInstance('Asynchronous').Milliseconds__c - 1000);
            }catch(BillingSummaryEmail.CPUTimeoutException ex){
               isLarge = true;
            }
            System.Debug('is large??????? ' + isLarge);
            if(isLarge && !Test.isRunningTest()){                   
               BillingSummaryEmail.processEmailService(orderId, bsOrder.Client_Type__c);
            }             
        }
        if(!isLarge){        
        Id rhProductionOrgId = '00D500000007MjVEAU';
        Map<Id, String> resultsMap = new Map<Id, String>();
        
        if(isAutomated){
            // Set the default To email address
            bsOrder.To_Email_Address__c = bsOrder.Sold_to_Email__c;
            bsOrder.Additional_To_Email_Addresses__c = '';
            bsOrder.Client_Type__c = 'Standard';
        }
        
        BillingSummaryTemplate__c bst = BillingSummaryTemplate__c.getInstance(bsOrder.Client_Type__c);
        String rhBrand = '';
        
        RH_Brand__c rhb = null;
        if (String.isNotBlank(bsOrder.Division__c)) {
            rhb = RH_Brand__c.getInstance(bsOrder.Division__c);
        }
        if (rhb == null) {
            rhb = RH_Brand__c.getInstance('999');
        }
        rhBrand = rhb.Email_Subject_Brand__c;        
          
        // Get the from email address, from name, and phone if Client Type is Contract
        List<String> fromList = new List<String>();
        List<String> fromNameList = new List<String>();
        User contractPM = new User();
        String cnName = bst.FromName__c;
        String cnEmail = bst.Email1__c;
        String cnRHEmail = bst.Email2__c;
        String cnDashPhone = bst.Phone1__c;
        String cnPhone = bst.Phone2__c;
        if (bsOrder.Client_Type__c == 'Contract') {
            if (bsOrder.Opportunity__c != null && bsOrder.Opportunity__r.Ops_Contact__c != null) {
                contractPM = [select Id, Name, Email, Phone from User where Id = :bsOrder.Opportunity__r.Ops_Contact__c];
                cnName = contractPM.Name;
                cnEmail = contractPM.Email;
                cnRHEmail = cnEmail.replaceFirst('@rh', '@RH');
                if (String.isNotBlank(contractPM.Phone)) {
                    cnDashPhone = contractPM.Phone;
                    if (cnDashPhone.startsWith('(')) {
                        cnDashPhone = cnDashPhone.remove(' ');
                        cnDashPhone = cnDashPhone.substring(1);
                        cnDashPhone = cnDashPhone.replaceFirst('[)]', '-');
                    }
                    cnPhone = cnDashPhone.remove('-');
                }
            }
            fromList.add(cnEmail);
            fromNameList.add(cnName);
            
        } else {
            
            fromList.add(bst.Email1__c);
            fromNameList.add(bst.FromName__c);
        }
        
        List<String> subjectList = new List<String>();
        subjectList.add(rhBrand + ' Billing Summary - Order ' + bsOrder.Name);
        
        List<String> toList = new List<String>();
        toList.add(bsOrder.To_Email_Address__c);
        if (String.isNotBlank(bsOrder.Additional_To_Email_Addresses__c)) {
            toList.addAll(bsOrder.Additional_To_Email_Addresses__c.split(',', 0));
        }
        
        List<String> bodyList = new List<String>();
        //bodyList.add(bsOrder.Name);
        
        SendGrid_RH sgRH = new SendGrid_RH();
        Map<Id, SendGrid_RH.SendGrid_RH_Data> sgrhDataMap = new Map<Id, SendGrid_RH.SendGrid_RH_Data>();
         
        //MODS for new template (generic)
        Blob pageContent;
        if (!Test.isRunningTest()) {
            pageContent = new PageReference('/apex/BillingSummaryEmailSolo?Id=' + orderId).getContent();
        } else {
            pageContent = Blob.valueOf('Test Class');
        }
        bodyList.add(pageContent.toString());
        subMap = new Map<String, String>();
         
        sgrhDataMap.put(bsOrder.Id, new SendGrid_RH.SendGrid_RH_Data(true, false, false, true, 'Billing Summary', subjectList, fromNameList, fromList, toList, bodyList, subMap, bsOrder.Id));
        subMap = null;
        // Send the email
        Boolean success = sgRH.rhSendEmail(sgrhDataMap.values());
         
        if(success){
            // Attach Email, update Billing_Request_Flag__c to 'S' (If automated, i.e. CustomerRequestedBillingSummaryEmail)
            Attachment attach = new Attachment();
            attach.ParentId = bsOrder.Id;
            attach.name = 'RH Billing Summary - Order ' + bsOrder.Name + '.html';
            attach.body = pageContent;
            insert attach;
            
            if(isAutomated){
               bsOrder.Billing_Request_Flag__c = 'S';
            }           
        }   
            
        // Record the success of sending the email
        bsOrder.SendGrid_Result__c = sgrhDataMap.get(bsOrder.Id).SendGridResult;
        bsOrder.SendGrid_Request_Date__c = system.now();
        update bsOrder;
  }
}  

    public static void sendEmailForEmailService(Id orderId, Map<String, String> stringMap, Boolean isAutomated) {
        Map<String, String> subMap = stringMap;
        // Read in the Order, Template and Brand related data we need to populate the email template
        RH_Order__c bsOrder = new RH_Order__c();
        bsOrder = [select Id, Name, Opportunity__c, Opportunity__r.Ops_Contact__c,  Sold_to_Address_1__c, Sold_to_Address_2__c, 
                Sold_to_City__c, Sold_to_State__c, Sold_to_Zip__c, Sold_to_First_Name__c, Sold_to_Last_Name__c, Sold_to_Email__c, 
                Sold_to_Day_Phone__c, Order_Date__c, Division__c, Client_Type__c, 
                To_Email_Address__c, Additional_To_Email_Addresses__c 
                from RH_Order__c where Id = :orderId];
        if(isAutomated){
            List<RH_Invoice.InvoiceLineWrapper> ILWrapper = BillingSummaryEmail.bsInvoiceLineWrapper(bsOrder.Id, bsOrder.Client_Type__c);
            subMap = BillingSummaryEmail.getEmailContent(bsOrder.Id, 'Standard', ILWrapper, CPULimitThreshold__c.getInstance('Asynchronous').Milliseconds__c - 1000);
        }
        
        Id rhProductionOrgId = '00D500000007MjVEAU';
        Map<Id, String> resultsMap = new Map<Id, String>();
        
        
        if(isAutomated){
            // Set the default To email address
            bsOrder.To_Email_Address__c = bsOrder.Sold_to_Email__c;
            bsOrder.Additional_To_Email_Addresses__c = '';
            bsOrder.Client_Type__c = 'Standard';
        }
        
        BillingSummaryTemplate__c bst = BillingSummaryTemplate__c.getInstance(bsOrder.Client_Type__c);
        String rhBrand = '';
        
        RH_Brand__c rhb = null;
        if (String.isNotBlank(bsOrder.Division__c)) {
            rhb = RH_Brand__c.getInstance(bsOrder.Division__c);
        }
        if (rhb == null) {
            rhb = RH_Brand__c.getInstance('999');
        }
        rhBrand = rhb.Email_Subject_Brand__c;        
          
        // Get the from email address, from name, and phone if Client Type is Contract
        List<String> fromList = new List<String>();
        List<String> fromNameList = new List<String>();
        User contractPM = new User();
        String cnName = bst.FromName__c;
        String cnEmail = bst.Email1__c;
        String cnRHEmail = bst.Email2__c;
        String cnDashPhone = bst.Phone1__c;
        String cnPhone = bst.Phone2__c;
        if (bsOrder.Client_Type__c == 'Contract') {
            if (bsOrder.Opportunity__c != null && bsOrder.Opportunity__r.Ops_Contact__c != null) {
                contractPM = [select Id, Name, Email, Phone from User where Id = :bsOrder.Opportunity__r.Ops_Contact__c];
                cnName = contractPM.Name;
                cnEmail = contractPM.Email;
                cnRHEmail = cnEmail.replaceFirst('@rh', '@RH');
                if (String.isNotBlank(contractPM.Phone)) {
                    cnDashPhone = contractPM.Phone;
                    if (cnDashPhone.startsWith('(')) {
                        cnDashPhone = cnDashPhone.remove(' ');
                        cnDashPhone = cnDashPhone.substring(1);
                        cnDashPhone = cnDashPhone.replaceFirst('[)]', '-');
                    }
                    cnPhone = cnDashPhone.remove('-');
                }
            }
            fromList.add(cnEmail);
            fromNameList.add(cnName);
            
        } else {
            
            fromList.add(bst.Email1__c);
            fromNameList.add(bst.FromName__c);
        }
        
        List<String> subjectList = new List<String>();
        subjectList.add(rhBrand + ' Billing Summary - Order ' + bsOrder.Name);
        
        List<String> toList = new List<String>();
        toList.add(bsOrder.To_Email_Address__c);
        if (String.isNotBlank(bsOrder.Additional_To_Email_Addresses__c)) {
            toList.addAll(bsOrder.Additional_To_Email_Addresses__c.split(',', 0));
        }
        
        List<String> bodyList = new List<String>();
        //bodyList.add(bsOrder.Name);
        
        SendGrid_RH sgRH = new SendGrid_RH();
        Map<Id, SendGrid_RH.SendGrid_RH_Data> sgrhDataMap = new Map<Id, SendGrid_RH.SendGrid_RH_Data>();
         
        //MODS for new template (generic)
        Blob pageContent;
        if (!Test.isRunningTest()) {
            pageContent = new PageReference('/apex/BillingSummaryEmailSolo?Id=' + orderId).getContent();
        } else {
            pageContent = Blob.valueOf('Test Class');
        }
        bodyList.add(pageContent.toString());
        subMap = new Map<String, String>(); 
         
        sgrhDataMap.put(bsOrder.Id, new SendGrid_RH.SendGrid_RH_Data(true, false, false, true, 'Billing Summary', subjectList, fromNameList, fromList, toList, bodyList, subMap, bsOrder.Id));
        subMap = null;
        // Send the email
        Boolean success = sgRH.rhSendEmail(sgrhDataMap.values());
         
        if(success){
            // Attach Email, update Billing_Request_Flag__c to 'S' (If automated, i.e. CustomerRequestedBillingSummaryEmail)
            Attachment attach = new Attachment();
            attach.ParentId = bsOrder.Id;
            attach.name = 'RH Billing Summary - Order ' + bsOrder.Name + '.html';
            attach.body = pageContent;           
            insert attach;

            if(isAutomated){
               bsOrder.Billing_Request_Flag__c = 'S';
            }           
        }       
            
        // Record the success of sending the email
        bsOrder.SendGrid_Result__c = sgrhDataMap.get(bsOrder.Id).SendGridResult;
        bsOrder.SendGrid_Request_Date__c = system.now();
        update bsOrder;
    }
  
}