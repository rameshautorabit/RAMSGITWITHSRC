global class OrderNotifications {
    
    /*
     *  Methods to send Order related transactional emails - order confirmation, order shipping, order delayed, etc.
     *
     */
    /*
	// Processes the list of Case records that are ready for an order notification email
    // Note - this method makes callouts - the calling method must be an @future method
	public static Map<Id, String> sendOrderNotifications(String notificationType, Set<Id> caseIds) {
        
        Map<Id, String> resultsMap = new Map<Id, String>();
        if (!caseIds.isEmpty()) {
            
            // Read in the Case, Case Line, Order Order Line, and Ship To data we need
            Map<Id, Case> cMap = new Map<Id, Case>([select Id, CaseNumber, Status, Request_Category__c, 
                    Actual_Gift_Card_Amount__c, Gift_Card_Status__c, Gift_Card_Request_Date__c, 
                    SendGrid_Result__c, SendGrid_Request_Date__c, Send_To__c, Send_to_Address_1__c, Send_to_Address_2__c, 
                    Send_to_Company__c, Send_to_City__c, Send_to_Country__c, Send_to_Email__c, Send_to_First_Name__c, 
                    Send_to_Last_Name__c, Send_to_State__c, Send_to_Zip__c, Send_to_Country_Code__c, EXT_Order_Number__c, RH_Order_Number__c, 
                    Acc_First_Name__c, Acc_Last_Name__c, Acc_Company__c, Acc_Address_1__c, Acc_Address_2__c, Acc_City__c, Acc_State__c, 
                    Acc_Postal_Code__c, Acc_Country_Code__c, Acc_Address_Type__c, Acc_Expiration__c, Acc_Requesting_User__c, Acc_Type__c, OwnerId 
                    from Case where Id in :caseIds]);
            
            set<Id> oIds = new Set<Id>();
            for (Case c :cMap.values()) {
                if (c.RH_Order_Number__c != null) {
                    oIds.add(c.RH_Order_Number__c);
                }
            }
            Map<Id, Case_Line_Items__c> cliMap = new Map<Id, Case_Line_Items__c>([select Id, Case_Number__c, Line_Number__c, 
                    Order__c, Delay_Notification_Type__c 
                    from Case_Line_Items__c where Case_Number__c in :caseIds]);
            
            Map<Id, Case_Line_Items__c> oliCliMap = new Map<Id, Case_Line_Items__c>();
            for (Case_Line_Items__c cli :cliMap.values()) {
                if (cli.Line_Number__c != null) {
                    oliCliMap.put(cli.Line_Number__c, cli);
                }
            }
            Map<Id, RH_Order__c> oMap = new Map<Id, RH_Order__c>([select Id, Name, Sold_To_Address_1__c, Sold_to_Address_2__c, 
                    Sold_to_Company__c, Sold_to_City__c, Sold_to_Country__c, Sold_to_Country_Code__c, Sold_to_Email__c, 
                    Sold_to_First_Name__c, Sold_to_Last_Name__c, Sold_to_State__c, Sold_to_Zip__c, Sold_to_Day_Phone__c, 
                    Order_Date__c, Division__c 
                    from RH_Order__c where Id in :oIds]);
            
            Map<Id, Order_Line_Items__c> oliMap = new Map<Id, Order_Line_Items__c>([select Id, Order_Quantity__c, Unit_Price__c, Name, 
                    Current_Available_Date__c, Current_Delay_Date__c, EXT_OrderShipToLine_Number__c, Line_Total__c, Backorder_Quantity__c, 
                    RH_Order_Number__c, RH_Order_Number__r.Name, 
                    CW_SKU_ID__c, CW_SKU_ID__r.Name, CW_SKU_ID__r.Web_Description__c, CW_SKU_ID__r.Product_Image_URL__c, 
                    CW_SKU_ID__r.ECommerce_Display_Name__c, CW_SKU_ID__r.Color__c
                    from Order_Line_Items__c where Id in :oliCliMap.keySet()]);
            
            List<Ship_To__c> shipToList = new List<Ship_To__c>();
            shipToList = [select Id, Name, Order__c, Ship_to_First_Name__c, Ship_to_Last_Name__c, Ship_to_Address_1__c, Ship_to_Address_2__c, 
                    Ship_to_Company__c, Ship_to_City__c, Ship_to_State__c, Ship_to_Zip__c, Ship_to_Country__c, Ship_to_Email__c, Ship_to_Country_Code__c 
                    from Ship_To__c where Order__c in :oMap.keySet() and Name = '1'];
            Map<Id, Ship_To__c> oShipToMap = new Map<Id, Ship_To__c>();
            for (Ship_To__c s :shipToList) {
                oShipToMap.put(s.Order__c, s);
            }
        
            // Prepare to send out the notification emails - one per Case
            SendGrid_RH sgRH = new SendGrid_RH();
            Map<Id, SendGrid_RH.SendGrid_RH_Data> sgrhDataMap = new Map<Id, SendGrid_RH.SendGrid_RH_Data>();
            Map<String, String> subMap;
            List<String> fromList;
            List<String> fromNameList;
            List<String> subjectList;
            List<String> toList;
            List<String> bodyList;
            rhEmail rhe;
            Ship_To__c shipTo;
            Map<Id, rhEmail> rheMap = new Map<Id, rhEmail>();
            for (Case c :cMap.values()) {
                fromList = new List<String>();
                fromNameList = new List<String>();
                subMap = new Map<String, String>();
                subjectList = new List<String>();
                toList = new List<String>();
                bodyList = new List<String>();
                rhe = null;
                shipTo = new Ship_To__c();
                if (oShipToMap.containsKey(c.RH_Order_Number__c)) {
                    shipTo = oShipToMap.get(c.RH_Order_Number__c);
                }
                
                if (notificationType == 'Delay Notification') {
                    rhe = buildDelayNotificationEmail(c, oMap.get(c.RH_Order_Number__c), oliMap, shipTo, oliCliMap);
                }
                
                if (rhe != null) {
                    fromList.add(rhe.fromEmail);
                    fromNameList.add(rhe.fromName);
                    subjectList.add(rhe.subject);
                    toList.addAll(rhe.toEmailList);
                    bodyList.add(rhe.body);
                    rheMap.put(c.Id, rhe);
                    
                    sgrhDataMap.put(c.Id, new SendGrid_RH.SendGrid_RH_Data(true, false, false, true, notificationType, subjectList, fromNameList, fromList, toList, bodyList, subMap, c.Id));
                }
            }
            
            // Send the notification emails
            if (!sgrhDataMap.isEmpty()) {
                Boolean success = sgRH.rhSendEmail(sgrhDataMap.values());
            }
            
            // Record results of sending email: create case comment, create email attachments, create gift card in CW
            List<Case> cList = new List<Case>();
            List<Case_Comments__c> ccList = new List<Case_Comments__c>();
            Case_Comments__c cc;
            String sendType;
            List<Attachment> attList = new List<Attachment>();
            String toEmailAddresses;
            String toString;
            RH_Order__c accOrder;
            Ship_To__c accShipTo;
            
            for (Case c :cMap.values()) {
                c.SendGrid_Request_Date__c = null;
                
                if (sgrhDataMap.containsKey(c.Id)) {
                    resultsMap.put(c.Id, sgrhDataMap.get(c.Id).SendGridResult);
                    c.SendGrid_Result__c = resultsMap.get(c.Id);
                    c.SendGrid_Request_Date__c = system.now();
                } else {
                    c.SendGrid_Result__c = 'MISSING/BAD DATA - EMAIL SEND NOT ATTEMPTED';
                }
                
                // Create attachments of email
                if (rheMap.containsKey(c.Id)) {
                    toEmailAddresses = '';
                    for (String toEmail :rheMap.get(c.Id).toEmailList) {
                        toEmailAddresses += toEmail + ', ';
                    }
                    if (String.isNotBlank(toEmailAddresses)) {
                        toEmailAddresses = toEmailAddresses.removeEnd(', ');
                    }
                    attList.add(new Attachment(
                        ParentId = c.Id,
                        Name = rheMap.get(c.Id).subject + '.html',
                        ContentType = 'text/html',
                        Body = Blob.valueof(rheMap.get(c.Id).body),
                        Description = 'System Generated Attachment'
                            + '\nSendGrid Email - Sent Message' 
                            + '\nFrom Name/Address = ' + rheMap.get(c.Id).fromName + '/' + rheMap.get(c.Id).fromEmail 
                            + '\nToAddress = ' + toEmailAddresses 
                            + '\nCcAddress = ' 
                            + '\nBccAddress = ' 
                            + '\nSendGrid send request result = ' + c.SendGrid_Result__c
                            + '\nSendGrid email send request date/time = ' + ((c.SendGrid_Request_Date__c != null) ? String.valueOf(c.SendGrid_Request_Date__c) : ' ')
                            + '\nHasAttachment = ' + 'false' 
                    ));
                }
                
                // Create case comment
                cc = new Case_Comments__c();
                if (c.Request_Category__c == 'Automatic Email') {
                    sendType = 'automatically';
                } else {
                    sendType = 'manually';
                }
                cc.Case__c = c.Id;
                if (c.SendGrid_Result__c.contains('SUCCESS')) {
                    cc.Call_Outcome__c = 'Sent Email';
                    cc.Comment__c = 'Delay Notification email sent ' + sendType + '.';
                } else {
                    cc.Comment__c = 'Unable to ' + sendType + ' send Delay Notification email. SendGrid send request result = ' + c.SendGrid_Result__c + '.';
                }
                ccList.add(cc);
                
                // Create gift card in CW if appropriate
                c.Gift_Card_Request_Date__c = null;
                c.Gift_Card_Status__c = null;
                if (c.SendGrid_Result__c.contains('SUCCESS')) {
                    
                    if (c.Actual_Gift_Card_Amount__c > 0) {
                        accOrder = null;
                        accShipTo = null;
                        if (oMap.containsKey(c.RH_Order_Number__c)) {
                            accOrder = oMap.get(c.RH_Order_Number__c);
                        }
                        if (oShipToMap.containsKey(c.RH_Order_Number__c)) {
                            accShipTo = oShipToMap.get(c.RH_Order_Number__c);
                        }
                        CW_Accommodation.createCWAccommodation(c, accOrder, accShipTo);
                        c.Gift_Card_Request_Date__c = system.now();
                        c.Gift_Card_Status__c = 'Pending';

                    } else {
                        c.Status = 'Closed - Successful';
                    }
                    
                } else {
                    
                    c.Request_Category__c = 'Callout';
                }
                
                cList.add(c);
            }
            
            // Record results in CW via an Order Line Note
            Map<Id, List<Order_Line_Items__c>> oOliMap = new Map<Id, List<Order_Line_Items__c>>();
            for (Case_Line_Items__c cli :cliMap.values()) {
                if (resultsMap.containsKey(cli.Case_Number__c) && resultsMap.get(cli.Case_Number__c).contains('SUCCESS')) {
                    if (cli.Delay_Notification_Type__c != 'Invalid') {
                        if (!oOliMap.containsKey(cli.Order__c)) {
                            oOliMap.put(cli.Order__c, new List<Order_Line_Items__c>());
                        }
                        oOliMap.get(cli.Order__c).add(oliMap.get(cli.Line_Number__c));
                    }
                }
            }
            
            String xmlString = OrderNoteXML.createOrderNoteXML(oOliMap);
            if (xmlString != null) {
                // send xml message to CW via Mule
                RH_Web_Services__c bon = RH_Web_Services__c.getInstance('Backorder Notes Callout');
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();
                Http http = new Http(); 
                
                req.setEndpoint(bon.Service_URL__c);
                req.setMethod('POST');
                req.setBody(xmlString);
                req.setCompressed(false); 
                req.setHeader('Content-Type', 'application/xml');
                
                system.debug('***** sendOrderNotifications about to post Order Line Notes to mule: ' + xmlString);
                
                try {
                    if (!Test.isRunningTest()) {
                        res = http.send(req);
                    }
                } catch(System.CalloutException e) {
                    system.debug('***** sendOrderNotifications Order Line Notes Callout error: '+ e);
                    system.debug('***** sendOrderNotifications Order Line Notes http response: ' + res.toString());
                }
            }
            
            // Attach each email sent to its related Order
            if (!attList.isEmpty()) {
                insert attList;
            }
            
            // Write out the case comments
            if (!ccList.isEmpty()) {
                insert ccList;
            }
            
            // update the case
            if (!cList.isEmpty()) {
                update cList;
            }
        }
        return resultsMap;
    }
    
    // Send a single Delay Notification email - called from a custom button on the Case detail page
    @future(callout=true)
    webService static void sendSingleDelayNotification(Id caseId) {
        Set<Id> cIds = new Set<Id>();
        cIds.add(caseId);
        Map<Id, String> resultsMap = sendOrderNotifications('Delay Notification', cIds);    
    }
    
    // Gift Card Request data structure
    public class gcRequest {
        public Case gcCase {get; set;}
        public RH_Order__c gcOrder {get; set;}
        public Ship_To__c gcShipTo {get; set;}
        
        public gcRequest() {
            gcCase = new Case();
            gcOrder = new RH_Order__c();
            gcShipTo = new Ship_To__c();
        }
    }
    
    // Email data structure
    public class rhEmail {
        String fromName {get; set;}
        String fromEmail {get; set;}
        List<String> toEmailList {get; set;}
        String subject {get; set;}
        String body {get; set;}
        
        public rhEmail() {
            fromName = '';
            fromEmail = '';
            toEmailList = new List<String>();
            subject = '';
            body = '';
        }
    }
    
    // Construct the Delay Notification Email
    public static rhEmail buildDelayNotificationEmail(Case c, RH_Order__c o, Map<Id, Order_Line_Items__c> oliMap, Ship_To__c shipTo, Map<Id, Case_Line_Items__c> oliCliMap) {
        
        rhEmail rhe = null;
        
        if (String.isNotBlank(o.Sold_to_Email__c)) {
            
            // Get the RH brand data
            String rhBrand = '';
            String rhBrandLogoURL = '';
            String rhBrandHomePageURL = '';
            String rhBrandLogoWidth = '';
            String rhBrandLogoHeight = '';
            String dnEmail = '';
            String dnPhone = '';
            
            RH_Brand__c rhb = null;
            if (String.isNotBlank(o.Division__c)) {
                rhb = RH_Brand__c.getInstance(o.Division__c);
            }
            if (rhb == null) {
                rhb = RH_Brand__c.getInstance('999');
            }
            dnEmail = rhb.Delay_Notification_Email__c;
            dnPhone = rhb.Delay_Notification_Phone__c;
            rhBrand = rhb.Email_Subject_Brand__c;
            rhBrandLogoURL = rhb.Brand_Logo_URL__c;
            rhBrandHomePageURL = rhb.Brand_Home_Page_URL__c;
            rhBrandLogoWidth = rhb.Brand_Logo_Width__c;
            rhBrandLogoHeight = rhb.Brand_Logo_Height__c;
            
            String rhBrandLogo = '<a style="color:#000" href="' + rhBrandHomePageURL + '" target="_blank"><img src="' + rhBrandLogoURL + '" width="' + rhBrandLogoWidth + '" height="'+ rhBrandLogoHeight + '"></a>';
            
            rhe = new rhEmail();
            rhe.fromName = rhBrand;
            rhe.fromEmail = dnEmail;
            rhe.toEmailList.add(o.Sold_to_Email__c);
            rhe.subject = rhBrand + ' Order Update - Order ' + o.Name;
            
            String body = '';
            
            body += '<table style="width: 700px; font-size: 12px; font-family: &#39;minion-pro&#39;, sans-serif; line-height: 18px;" align="center" cellpadding="0" cellspacing="0">';
            body += '<tbody>';
            body += '<tr><td style="text-align:center; padding: 30px 0 10px 0;" colspan="3">' + rhBrandLogo + '</td></tr>';
            
            body += '<tr><td colspan="5" style="padding: 10px 0 10px 0; border-bottom: 1px solid #cccccc;"></td></tr>';
            
            body += '<tr><td colspan="3"><div style="background-color: transparent; color: #5c5c5c; letter-spacing: 1px; font-family: &#39;minion-pro&#39;, Times, &#39;Times New Roman&#39;; padding: 0; margin: 30px 0 30px 0px; font-weight: normal; text-align: center; padding: 0; font-size: 22px; text-transform: uppercase">Order Update</div></td></tr>';
            
            body += '<tr><td style="width: 80px;"></td></tr>';
            
            String soldToName = Utility.toFirstCap(o.Sold_to_First_Name__c, 3);
            if (String.isNotBlank(soldToName)) {
                soldToName += ' ';
            }
            soldToName += Utility.toFirstCap(o.Sold_to_Last_Name__c, 0);
            String shipToName = Utility.toFirstCap(shipTo.Ship_to_First_Name__c, 3);
            if (String.isNotBlank(shipToName)) {
                shipToName += ' ';
            }
            shipToName += Utility.toFirstCap(shipTo.Ship_to_Last_Name__c, 0);
            String salutation = ' ';
            if (String.isNotBlank(shipToName)) {
                salutation = shipToName;
            } else {
                if (String.isNotBlank(soldToName)) {
                    salutation = soldToName;
                }
            }
            
            body += '<tr><td class="module" style="margin:10px 0 10px 0; padding: 0 56px 20px 56px;" colspan="3">';
            body += '<p style="margin: 10px 10px 10px 10px; text-align: left; letter-spacing: 1px; color: #333333;">Dear ' + salutation + ',<br>';
            body += '<br>';
            body += 'Thank you for your recent purchase. We regret to inform you that the item(s) below from your order #' + o.Name + ' has been delayed due to high demand and production delays, and we sincerely apologize for this inconvenience.<br>';
            body += '<br>';
            body += 'We do everything possible to deliver a customer experience that equals the quality of our product, but this time our service didn\'t live up to our high standards. We know that we\'ve let you down and recognize that any delay is unacceptable. We\'ve noted the previous delivery date and the new delivery details below.<br>';
            body += '<br>';
            
            if (c.Actual_Gift_Card_Amount__c > 0) {
                String gcAmount = Utility.htmlDollarAmount(c.Actual_Gift_Card_Amount__c, true);
                //body += 'In appreciation for your continued patience, we\'re offering you a gift card in the amount of ' + gcAmount + '. Your gift card will be mailed separately, and can be applied to a future purchase from any of our brands, including RH, RH Modern, RH TEEN and RH Baby & Child.<br>';
                body += 'In appreciation for your continued patience, we\'re offering you a complimentary credit in the amount of ' + gcAmount + '. This card will be mailed separately, and can be applied to a future purchase from any of our brands, including RH, RH Modern, RH TEEN and RH Baby & Child.<br>';
                body += '<br>';
            }
            body += 'If you have any questions, please do not hesitate to contact us at<br>';
            body += dnPhone + '. Thank you for being a valued customer of RH.</p><br>';
            body += '</td></tr>';
            
            body += '<tr><td colspan="3" style="width: 80px;"></td></tr>';
            
            String soldToAddr1 = Utility.toFirstCap(o.Sold_to_Address_1__c, 0);
            String soldToAddr2 = Utility.toFirstCap(o.Sold_to_Address_2__c, 0);
            String soldToCityStateZip = Utility.toFirstCap(o.Sold_to_City__c, 0) + ', ' + Utility.toFirstCap(o.Sold_to_State__c, 3) + ' ' + o.Sold_to_Zip__c;
            String soldToCountry = Utility.toFirstCap(o.Sold_to_Country__c, 0);
            
            String shipToAddr1 = Utility.toFirstCap(shipTo.Ship_to_Address_1__c, 0);
            String shipToAddr2 = Utility.toFirstCap(shipTo.Ship_to_Address_2__c, 0);
            String shipToCityStateZip = Utility.toFirstCap(shipTo.Ship_to_City__c, 0) + ', ' + Utility.toFirstCap(shipTo.Ship_to_State__c, 3) + ' ' + shipTo.Ship_to_Zip__c;
            String shipToCountry = Utility.toFirstCap(shipTo.Ship_to_Country__c, 0);
            
            body += '<tr>';
            body += '<td valign="top">';
            body += '<h3 style="color: #333333; background-color: transparent; text-indent: 10px; border-top: 0; border-right: 0;  border-bottom: none; border-left: 0; text-align: left; font-weight: normal; margin: 0 0 5px 0; font-family: &#39;minion-pro&#39;, Times, &#39;Times New Roman&#39;; font-size: 14px; text-transform: uppercase; padding: 0; line-height: 30px; height: 30px; width: 310px;">Shipping</h3>';
            body += '<div style="width: 310px; color: #6C6663; text-align: left; margin: 0 0 20px 0; letter-spacing: 1px;">';
            body += '<p style="margin-left: 10px;">' + shipToName + '<br>';
            if (String.isNotBlank(shipToAddr1)) {
                body += shipToAddr1 + '<br>';
            }
            if (String.isNotBlank(shipToAddr2)) {
                body += shipToAddr2 + '<br>';
            }
            if (String.isNotBlank(shipToCityStateZip)) {
                body += shipToCityStateZip + '<br>';
            }
            if (String.isNotBlank(shipToCityStateZip)) {
                body += shipToCountry + '<br>';
            }
            body += '</p>';
            body += '</div>';
            body += '</td>';
            
            body += '<td style="width: 80px;"></td>';
            
            body += '<td class="module" style="margin:10px 0 10px 0">';
            body += '<h3 style="color: #333333; background-color: transparent; text-indent: 10px; border-top: 0; border-right: 0;  border-bottom: none; border-left: 0; text-align: left; font-weight: normal; margin: 0 0 5px 0; font-family: &#39;minion-pro&#39;, Times, &#39;Times New Roman&#39;; font-size: 14px; text-transform: uppercase; padding: 0; line-height: 30px; height: 30px; width: 310px;">Billing</h3>';
            body += '<div style="width: 310px; color: #6C6663; text-align: left; margin: 0 0 20px 0; letter-spacing: 1px;">';
            body += '<p style="margin-left: 10px;">' + soldToName + '<br>';
            if (String.isNotBlank(soldToAddr1)) {
                body += soldToAddr1 + '<br>';
            }
            if (String.isNotBlank(soldToAddr2)) {
                body += soldToAddr2 + '<br>';
            }
            if (String.isNotBlank(soldToCityStateZip)) {
                body += soldToCityStateZip + '<br>';
            }
            if (String.isNotBlank(soldToCityStateZip)) {
                body += soldToCountry + '<br>';
            }
            body += '</p>';
            body += '</div>';
            body += '</td>';
            body += '</tr>';
            
            // Creae the delayed order lines table
            body += '<tr><td colspan="3" style="width: 80px;"></td></tr>';
            
            body += '<tr>';
            body += '<td class="module order-items" style="margin:10px 0 10px 0 " colspan="3">';
            body += '<table style="width: 700px;" align="left" cellspacing="0" cellpadding="10">';
            body += '<thead>';
            body += '<tr width="100%" style="color: #000000; background-color: transparent; text-transform: uppercase; margin: 0; padding: 0px 5px 10px 5px; width: 100%;">';
            body += '<th style="padding: 15px 5px; border-bottom: 1px solid #000000; font-weight: normal;">&nbsp;</th>';
            body += '<th style="padding: 15px 5px; border-bottom: 1px solid #000000; font-weight: normal;">&nbsp;</th>';
            body += '<th style="padding: 15px 5px; border-bottom: 1px solid #000000; font-weight: normal;">Quantity</th>';
            body += '<th style="padding: 15px 5px; border-bottom: 1px solid #000000; font-weight: normal;">Total</th>';
            body += '</tr>';
            body += '</thead>';
            
            body += '<tbody>';
            for (Order_Line_Items__c oli :oliMap.values()) {
                if (oli.RH_Order_Number__c == o.Id && oliCliMap.containsKey(oli.Id) && oliCliMap.get(oli.Id).Delay_Notification_Type__c != 'Invalid') {
                    String delayDate = Utility.usDate(oli.Current_Delay_Date__c, '/');
                    String communicatedDate = Utility.usDate(oli.Current_Available_Date__c, '/');
                    String description = oli.CW_SKU_ID__r.ECommerce_Display_Name__c;
                    if (String.isBlank(description)) {
                        description = oli.CW_SKU_ID__r.Web_Description__c;
                    }
                    
                    String quantity = ' ';
                    String amount = ' ';
                    if (oli.Backorder_Quantity__c != null && oli.Unit_Price__c != null) {
                        quantity = String.valueOf(oli.Backorder_Quantity__c);
                        amount = Utility.htmlDollarAmount(oli.Backorder_Quantity__c * oli.Unit_Price__c, true);
                    }
                    
                    String color = Utility.toFirstCap(oli.CW_SKU_ID__r.Color__c, 0);
                    
                    body += '<tr class="order-item-row">';
                    body += '<td valign="top" style="width:178px; padding: 15px 0 0 10px" class="order-item-image"><img height="164" width="168" src="' + oli.CW_SKU_ID__r.Product_Image_URL__c + '" alt="" title=""></td>';
                    
                    body += '<td style="padding-top: 15px">';
                    body += '<span style="text-transform: uppercase; font-family: &#39;minion-pro&#39;, Times, &#39;Times New Roman&#39;; font-size: 14px;">' + description + '</span><br>';
                    body += '<br>';
                    body += '<div><span style="text-transform: uppercase; color: #6C6663; display: inline-block; min-width: 125px;">Item #</span>' + oli.CW_SKU_ID__r.Name + '</div>';
                    
                    if (String.isNotBlank(color)) {
                        body += '<div class="order-item-attribute"><span style="text-transform: uppercase; color: #6C6663; display: inline-block; min-width: 129px; float: left">Color</span> <span style="display: inline-block; width: 134px">' + color + '</span></div>';
                    }
                    body += '<div style="display:block; float:left;"><br>Our previous contact date for delivery was ' + communicatedDate + '. You will now be contacted on or before ' + delayDate + ' to schedule delivery for this item.<br></div>';
                    body += '</td>';
                    
                    body += '<td valign="top" align="center" style="width:50px; text-align: center; padding-top: 15px">' + quantity + '</td>';
                    
                    body += '<td valign="top" align="center" style="width:50px; text-align: center; padding-top: 15px">' + amount + '</td>';
                    body += '</tr>';
                    
                    body += '<tr>';
                    body += '<td colspan="5"><div style="height:1px; width: 100%; background-color: #ccc; margin: 10px 0 10px 0"></div></td>';
                    body += '</tr>';
                }
            }
            body += '</tbody>';
            body += '</table></td></tr>';
            
            body += '<tr><td colspan="3" style="width: 80px;"></td></tr>';
            
            body += '<tr>';
            body += '<td class="module" style="min-width: 700px; padding-bottom: 20px" colspan="3" width="700">';
            body += '<h3 style="color: #333333; background-color: transparent; text-indent: 10px; border-top: 0; border-right: 0;  border-bottom: none; border-left: 0; text-align: left; font-weight: normal; margin: 0 0 5px 0; font-family: &#39;minion-pro&#39;, Times, &#39;Times New Roman&#39;; font-size: 14px; text-transform: uppercase; padding: 0; line-height: 30px; height: 30px; width: 100%;">Important Information</h3>';
            
            body += '<p style="margin: 0 10px 10px 10px;"><b>Furniture Orders</b><br>';
            body += 'Furniture items are delivered as they become available. The final charges for each shipment will be applied as each shipment releases. Tax and shipping charges are considered estimated and will be recalculated at the time of shipment to ensure they take into account the most current tax information.</p>';
            
            body += '<p style="margin: 0 10px 10px 10px;">Custom orders ship separately. These items begin production immediately upon order and are built to your specifications. Unfortunately, they cannot be cancelled, changed, returned or refunded at any time. A nonrefundable 50% deposit will be taken when the order is placed.</p>';
            body += '</td>';
            body += '</tr>';
            
            body += '<tr><td style="width: 80px;"></td></tr>';
            
            body += '<tr><td colspan="3" style="width: 80px;"></td></tr>';
            
            body += '<tr>';
            body += '<td colspan="3" style="text-align:center; padding-top: 20px;"><img alt="" height="168" src="http://media.restorationhardware.com/is/image/rhis/102413_email_orderConfirm?wid=700&amp;fmt=jpeg&amp;qlt=90,0&amp;op_sharpen=0&amp;resMode=bicub&amp;op_usm=0.0,0.0,0,0&amp;iccEmbed=1" style="width: 700px; height: 168px;" usemap="#138059" width="700" /></span><map name="138059"><area alt="" coords="356,2,699,135" href="http://www.restorationhardware.com/content/page.jsp?id=sourcebookapp&amp;cm_mmc=Transactional+Email-_-Trans+Email-_-SB+App-_-Sourcebookapp" /> <area alt="" coords="1,2,344,135" href="https://www.restorationhardware.com/customer-service/email-signup.jsp?cm_mmc=Transactional+Email-_-Trans+Email-_-Email+SignUp-_-Email+SignUp" /></map></td>';
            body += '</tr>';
            
            body += '<tr><td colspan="3" style="width: 80px;"></td></tr>';
            
            body += '<tr>';
            body += '<td style="background-color: #f1f1f1; color: #000000;text-align: center;font-size: 12px;font-family: &#39;minion-pro&#39;, Times, &#39;Times New Roman&#39;;line-height: 18px;width: 700px;width: 700px;padding: 20px 0 20px 0;letter-spacing: 1px;" colspan="3">';
            body += '<p style="text-transform: none;">For additional order details, please <a href="https://www.restorationhardware.com/my-account/sign-in.jsp" target="_blank" style="color: #000000;">Click Here</a> to go to your account. For Questions<br>';
            body += 'or comments, call us toll-free at ' + dnPhone + ' or email <a href="mailto:' + dnEmail + '" style="color: #000000;">' + dnEmail + '.</a><br>';
            body += '<br>';
            body += 'Want to be in the know? <a href="https://www.restorationhardware.com/customer-service/email-signup.jsp" style="color: #000000;">Join our email list here.</a><br>';
            body += '<br>';
            body += '<a href="https://www.restorationhardware.com/customer-service/privacy-policy.jsp" target="_blank" style="color: #000000; text-decoration: none;text-transform: uppercase;">Privacy Policy</a> | <a href="https://www.restorationhardware.com/customer-service/frequently-asked-questions.jsp" target="_blank" style="color: #000000; text-decoration: none;text-transform: uppercase;">Frequently Asked Questions</a> | <a href="https://www.restorationhardware.com/customer-service/contact-us.jsp" target="_blank" style="color: #000000; text-decoration: none;text-transform: uppercase;">Contact Us</a> | <a href="https://www.restorationhardware.com/customer-service/index.jsp" target="_blank" style="color: #000000; text-decoration: none;text-transform: uppercase;">Customer Service</a></p>';
            
            body += '<p style="text-decoration: none;"><br>';
            body += '2016 RH 15 Koch Road, Corte Madera, CA 94925</p>';
            body += '</td>';
            body += '</tr>';
            
            body += '</tbody>';
            body += '</table>'; 
            
            rhe.body = body;    
        }
        
        return rhe;
    }
    */
}