public class DelayedOrderNotification {
	
	/*
	 *	Methods to support sending delayed order notifications - both automatically and on-demand.
	 *
	 */
	
	// Send delayed order notification for one case/order on-demand
	@future (callout=true)
	public static void sendSingleDelayNotification(Id caseId) {
		List<Id> cIds = new List<Id>();
		if (caseId != null) {
			cIds.add(caseId);
			sendOrderNotifications(cIds, true);
		}
	}
	
	// Processes the list of Case records that need a delayed order notification to be sent
	public static void sendOrderNotifications(List<Id> caseIds, Boolean onDemand) {
		
		if (!caseIds.isEmpty()) {
			
			// Get the case, case line, order and order line data needed
			Map<Id, Case> cMap = new Map<Id, Case>([select Id, CaseNumber, Status, Request_Category__c, Notification_Type__c, 
                    Actual_Gift_Card_Amount__c, Gift_Card_Status__c, Gift_Card_Request_Date__c, Email_Subject_Brand__c, 
                    Send_To__c, Send_to_Address_1__c, Send_to_Address_2__c, To_Email_Address__c, 
                    Send_to_Company__c, Send_to_City__c, Send_to_Country__c, Send_to_Email__c, Send_to_First_Name__c, 
                    Send_to_Last_Name__c, Send_to_State__c, Send_to_Zip__c, Send_to_Country_Code__c, EXT_Order_Number__c, RH_Order_Number__c, 
                    Acc_First_Name__c, Acc_Last_Name__c, Acc_Company__c, Acc_Address_1__c, Acc_Address_2__c, Acc_City__c, Acc_State__c, 
                    Acc_Postal_Code__c, Acc_Country_Code__c, Acc_Address_Type__c, Acc_Expiration__c, Acc_Requesting_User__c, Acc_Type__c, OwnerId 
					from Case where Id in :caseIds and IsClosed = false]);
			
			List<Case_Line_Items__c> cliList = new List<Case_Line_Items__c>();
			cliList = [select Id, Case_Number__c, Line_Number__c, Order__c, Delay_Notification_Type__c 
                    from Case_Line_Items__c where Case_Number__c in :caseIds and Delay_Notification_Type__c != 'Invalid'];
			
			Set<Id> oIds = new Set<Id>();
			Map<Id, Case_Line_Items__c> oliCliMap = new Map<Id, Case_Line_Items__c>();
            for (Case_Line_Items__c cli :cliList) {
                if (cli.Line_Number__c != null) {
                    oliCliMap.put(cli.Line_Number__c, cli);
                }
                if (cli.Order__c != null) {
                	oIds.add(cli.Order__c);
                }
            }
            
            Map<Id, RH_Order__c> oMap = new Map<Id, RH_Order__c>([select Id, Name, Sold_To_Address_1__c, Sold_to_Address_2__c, 
                    Sold_to_Company__c, Sold_to_City__c, Sold_to_Country__c, Sold_to_Country_Code__c, Sold_to_Email__c, 
                    Sold_to_First_Name__c, Sold_to_Last_Name__c, Sold_to_State__c, Sold_to_Zip__c, Sold_to_Day_Phone__c, 
                    Order_Date__c, Division__c, Order_Type_Code__c 
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
			
			// Prepare to send Delay Notification emails
			Set<Id> attemptIds = new Set<Id>();
			List<Case> attemptCaseList = new List<Case>();
            for (Case c :cMap.values()) {
				
				if (oMap.containsKey(c.RH_Order_Number__c)) {
					if (!onDemand) {
						c.To_Email_Address__c = oMap.get(c.RH_Order_Number__c).Sold_to_Email__c;
					}
					
					RH_Brand__c rhb = null;
					if (oMap.get(c.RH_Order_Number__c).Order_Type_Code__c == 'Z') {
						rhb = RH_Brand__c.getInstance('RH Contract');
					} else {
						if (String.isNotBlank(oMap.get(c.RH_Order_Number__c).Division__c)) {
							rhb = RH_Brand__c.getInstance(oMap.get(c.RH_Order_Number__c).Division__c);
						} else {
							rhb = RH_Brand__c.getInstance('999');
						}
					}
					c.Email_Subject_Brand__c = rhb.Email_Subject_Brand__c;
				}
				
				if (Utility.isValidDomain(c.To_Email_Address__c)) {
					c.Email_Alert_Trigger__c = true;
					attemptIds.add(c.Id);
					attemptCaseList.add(c);
				}
            }
            
			// Create order line notes in CW for each order line on a delay notification email
			Map<Id, List<Order_Line_Items__c>> oOliMap = new Map<Id, List<Order_Line_Items__c>>();
            for (Case_Line_Items__c cli :cliList) {
                if (attemptIds.contains(cli.Case_Number__c)) {
            		if (!oOliMap.containsKey(cli.Order__c)) {
						oOliMap.put(cli.Order__c, new List<Order_Line_Items__c>());
					}
					oOliMap.get(cli.Order__c).add(oliMap.get(cli.Line_Number__c));
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
            
            // Send the Delay Notification emails
            if (!attemptCaseList.isEmpty()) {
            	update attemptCaseList;
            }
			
			// Record the results of sending the Delay Notification emails
			List<Case_Comments__c> ccList = new List<Case_Comments__c>();
            List<Attachment> attList = new List<Attachment>();
            String sendType;
            Blob pageContent;
            Map<Id, Case> attemptMap = new Map<Id, Case>([select Id, Email_Alert_Trigger__c from Case where Id in :attemptIds]);
			for (Case c :cMap.values()) {
				c.Email_Alert_Trigger__c = false;
				
				if (attemptMap.containsKey(c.Id) && attemptMap.get(c.Id).Email_Alert_Trigger__c == false) {
					
					// Create gift card in CW if indicated
					c.Gift_Card_Request_Date__c = null;
					c.Gift_Card_Status__c = null;
                    if (c.Order_Type_Code__c != 'Z' && c.Actual_Gift_Card_Amount__c > 0 && oMap.containsKey(c.RH_Order_Number__c) && oShipToMap.containsKey(c.RH_Order_Number__c)) {
                        CW_Accommodation.createCWAccommodation(c, oMap.get(c.RH_Order_Number__c), oShipToMap.get(c.RH_Order_Number__c));
                        c.Gift_Card_Request_Date__c = system.now();
                        c.Gift_Card_Status__c = 'Pending';

                    } else {
                        c.Status = 'Closed - Successful';
                    }
					
					// Create new case comment
					sendType = (onDemand) ? 'on-demand' : 'automatically';
					ccList.add(new Case_Comments__c(
						Case__c = c.Id,
						Call_Outcome__c = 'Sent Email',
						Comment__c = 'Delay Notification email sent ' + sendType + '.')
					);
					
					// Create new attachment of email to be sent
					if (!Test.isRunningTest()) {
						pageContent = new PageReference('/apex/DelayNotificationHTML?caseId=' + c.Id).getContent();
					} else {
						pageContent = Blob.valueOf('Test Class');
					}
					attList.add(new Attachment(
						ParentId = c.Id,
						Name = c.Notification_Type__c + ': ' + sendType + '.html',
						ContentType = 'html',
						Body = pageContent,
						Description = 'System Generated Attachment'
							+ '\nNotification sent ' + sendType + ': ' + c.Notification_Type__c 
							+ '\nToAddress = ' + c.To_Email_Address__c
							+ '\nSend Date/Time = ' + String.valueOf(system.now()))
					);
					
				} else {
					
					// Couldn't send Delay Notification email, set case for manual processing
					c.Request_Category__c = 'Callout';
				}
			}
            
            // Attach copies of the sent emails
            if (!attList.isEmpty()) {
            	insert attList;
            }
            
            // Write out the new case comments
            if (!ccList.isEmpty()) {
            	insert ccList;
            }
            
            // Update the cases with the results of sending the emails
            if (!cMap.isEmpty()) {
            	TriggerStopper.stopCase = false;	// Make sure second case update is processed
            	update cMap.values();
            }
		}
	}
}