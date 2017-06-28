public class DelayNotification {
	
	/*
	 *	Controller for the Delay Notification visualforce email template and components.
	 *
	 */
	
	private Case rhCase;
	private Map<String, String> subMap;
	private Map<String, String> footerMap;
	private String notificationType;
	private RH_Brand__c rhb;
	
	public class DelayedOLI {
		public String description {get; set;}
		public String quantity {get; set;}
		public String price {get; set;}
		public String image {get; set;}
		public String item {get; set;}
		public String color {get; set;}
		public String oldDate {get; set;}
		public String newDate {get; set;}
		
		public DelayedOLI(String des, String qty, String prc, String img, String itm, String clr, String odt, String ndt) {
			description = des;
			quantity = qty;
			price = prc;
			image = img;
			item = itm;
			color = clr;
			oldDate = odt;
			newDate = ndt;
		}
	}
	
	public List<DelayedOLI> delayedItems {get; set;}
	public Id caseId {get; set;}
	
	public DelayNotification() {
		
		// The case Id is either passed in as a page parameter or it comes to the page via
		// the visualforce email template (DelayNotification)
		Id cIdParameter = ApexPages.currentPage().getParameters().get('caseId');
		if (String.isNotBlank(cIdParameter)) {
			caseId = cIdParameter;
		}
		
		notificationType = ApexPages.currentPage().getParameters().get('notificationType');
		
		rhCase = null;
	}
	
	// Get the data for the email template
	public Map<String, String> getsubMap() {
		
		if (rhCase == null) {
			rhCase = new Case();
			rhCase = [select Id, CaseNumber, Description, Notification_Type__c, Actual_Gift_Card_Amount__c, Opportunity_PM__c, 
					Email_Subject_Brand__c, Email_Thread_Id__c, Membership_Auto_Renewal_Order__c, 
					RH_Order_Number__c, RH_Order_Number__r.Name, RH_Order_Number__r.Order_Type_Code__c 
					from Case where Id = :caseId];
			
			List<Case_Line_Items__c> cliList = new List<Case_Line_Items__c>();
			cliList = [select Id, Case_Number__c, Line_Number__c, Order__c, Delay_Notification_Type__c 
                    from Case_Line_Items__c where Case_Number__c = :rhCase.Id];
            
            Map<Id, Case_Line_Items__c> oliCliMap = new Map<Id, Case_Line_Items__c>();
            for (Case_Line_Items__c cli :cliList) {
                if (cli.Line_Number__c != null && cli.Delay_Notification_Type__c != 'Invalid') {
                    oliCliMap.put(cli.Line_Number__c, cli);
                }
            }
            
            RH_Order__c rhOrder = new RH_Order__c();
            rhOrder = [select Id, Name, Sold_To_Address_1__c, Sold_to_Address_2__c, Sold_to_Company__c, Sold_to_City__c, 
					Sold_to_Country__c, Sold_to_Country_Code__c, Sold_to_Email__c, Sold_to_First_Name__c, Sold_to_Last_Name__c, 
					Sold_to_State__c, Sold_to_Zip__c, Sold_to_Day_Phone__c, Order_Date__c, Division__c, Order_Type_Code__c 
                    from RH_Order__c where Id = :rhCase.RH_Order_Number__c];
            
            List<Order_Line_Items__c> oliList = new List<Order_Line_Items__c>();
            oliList = [select Id, Order_Quantity__c, Unit_Price__c, Name, Current_Available_Date__c, Current_Delay_Date__c, 
            		EXT_OrderShipToLine_Number__c, Line_Total__c, Backorder_Quantity__c, 
                    RH_Order_Number__c, RH_Order_Number__r.Name, 
                    CW_SKU_ID__c, CW_SKU_ID__r.Name, CW_SKU_ID__r.Web_Description__c, CW_SKU_ID__r.Product_Image_URL__c, 
                    CW_SKU_ID__r.ECommerce_Display_Name__c, CW_SKU_ID__r.Color__c
                    from Order_Line_Items__c where Id in :oliCliMap.keySet()];
            
            Ship_To__c rhShipTo = new Ship_To__c();
            rhShipTo = [select Id, Name, Order__c, Ship_to_First_Name__c, Ship_to_Last_Name__c, Ship_to_Address_1__c, Ship_to_Address_2__c, 
                    Ship_to_Company__c, Ship_to_City__c, Ship_to_State__c, Ship_to_Zip__c, Ship_to_Country__c, Ship_to_Email__c, Ship_to_Country_Code__c 
                    from Ship_To__c where Order__c = :rhCase.RH_Order_Number__c and Name = '1'];
            
            // Populate our substitution map with data
            subMap = new Map<String, String>();
            
            // Get the RH brand data
            String dnEmail = '';
            String dnPhone = '';
            String pmName = ' ';
            String personalNote = 'No Note';
            rhb = null;
            if (rhOrder.Order_Type_Code__c == 'Z') {
            	rhb = RH_Brand__c.getInstance('RH Contract');
            	User pmUser = [select Id, Name, Email, Phone from User where Id = :rhCase.Opportunity_PM__c];
            	pmName = pmUser.Name;
            	if (String.isNotBlank(pmUser.Phone)) {
            		dnPhone = Utility.formatPhone10(pmUser.Phone);
            	} else {
            		dnPhone = '555.555.5555';
            	}
            	dnEmail = pmUser.Email;
            	if (String.isNotBlank(rhCase.Description)) {
            		personalNote = rhCase.Description;
            	}
            } else {
            	if (String.isNotBlank(rhOrder.Division__c)) {
                	rhb = RH_Brand__c.getInstance(rhOrder.Division__c);
            	} else {
            		rhb = RH_Brand__c.getInstance('999');
            	}
            	dnPhone = Utility.formatPhone10(rhb.Delay_Notification_Phone__c);
            	dnEmail = rhb.Delay_Notification_Email__c;
            }
            
            subMap.put('%personalNote%', personalNote);
            subMap.put('%pmName%', pmName);
            subMap.put('%dnEmail%', dnEmail);
            subMap.put('%dnPhone%', dnPhone);
            subMap.put('%logoLink%', rhb.Brand_Home_Page_URL__c);
            subMap.put('%logoURL%', rhb.Brand_Logo_URL__c);
            subMap.put('%logoWidth%', rhb.Brand_Logo_Width__c);
            subMap.put('%logoHeight%', rhb.Brand_Logo_Height__c);
            
            // Customer name and addresses, order number and type code
            String soldToName = Utility.toFirstCap(rhOrder.Sold_to_First_Name__c, 3);
            if (String.isNotBlank(soldToName)) {
                soldToName += ' ';
            }
            soldToName += Utility.toFirstCap(rhOrder.Sold_to_Last_Name__c, 0);
            
            String shipToName = Utility.toFirstCap(rhShipTo.Ship_to_First_Name__c, 3);
            if (String.isNotBlank(shipToName)) {
                shipToName += ' ';
            }
            shipToName += Utility.toFirstCap(rhShipTo.Ship_to_Last_Name__c, 0);
            String customerName = ' ';
            if (String.isNotBlank(shipToName)) {
                customerName = shipToName;
            } else {
            	shipToName = ' ';
                if (String.isNotBlank(soldToName)) {
                    customerName = soldToName;
                } else {
                	soldToName = ' ';
                }
            }
            
            subMap.put('%soldToName%', soldToName);
            String addr = (String.isNotBlank(rhOrder.Sold_To_Address_1__c)) ? Utility.toFirstCap(rhOrder.Sold_To_Address_1__c, 2) : ' ';
			subMap.put('%soldToAddr1%', addr);
			addr = (String.isNotBlank(rhOrder.Sold_To_Address_2__c)) ? Utility.toFirstCap(rhOrder.Sold_To_Address_2__c, 2) : ' ';
			subMap.put('%soldToAddr2%', addr);
			addr = (String.isNotBlank(rhOrder.Sold_To_City__c)) ? Utility.toFirstCap(rhOrder.Sold_To_City__c, 2) : '';
			if (String.isNotBlank(addr)) {
				addr += (String.isNotBlank(rhOrder.Sold_To_State__c)) ? ', ' + Utility.toFirstCap(rhOrder.Sold_To_State__c, 3) : '';
			} else {
				addr += (String.isNotBlank(rhOrder.Sold_To_State__c)) ? Utility.toFirstCap(rhOrder.Sold_To_State__c, 3) : '';
			}
			if (String.isNotBlank(addr)) {
				addr += (String.isNotBlank(rhOrder.Sold_To_Zip__c)) ? ' ' + rhOrder.Sold_To_Zip__c : '';
			} else {
				addr += (String.isNotBlank(rhOrder.Sold_To_Zip__c)) ? rhOrder.Sold_To_Zip__c : '';
			}
			addr = (String.isNotBlank(addr)) ? addr : ' ';
			subMap.put('%soldToCityStatePostalCode%', addr);
			addr = (String.isNotBlank(rhOrder.Sold_to_Country_Code__c)) ? rhOrder.Sold_to_Country_Code__c : ' ';
			subMap.put('%soldToCountryCode%', addr);
			
			subMap.put('%shipToName%', shipToName);
            addr = (String.isNotBlank(rhShipTo.Ship_To_Address_1__c)) ? Utility.toFirstCap(rhShipTo.Ship_To_Address_1__c, 2) : ' ';
			subMap.put('%shipToAddr1%', addr);
			addr = (String.isNotBlank(rhShipTo.Ship_To_Address_2__c)) ? Utility.toFirstCap(rhShipTo.Ship_To_Address_2__c, 2) : ' ';
			subMap.put('%shipToAddr2%', addr);
			addr = (String.isNotBlank(rhShipTo.Ship_To_City__c)) ? Utility.toFirstCap(rhShipTo.Ship_To_City__c, 2) : '';
			if (String.isNotBlank(addr)) {
				addr += (String.isNotBlank(rhShipTo.Ship_To_State__c)) ? ', ' + Utility.toFirstCap(rhShipTo.Ship_To_State__c, 3) : '';
			} else {
				addr += (String.isNotBlank(rhShipTo.Ship_To_State__c)) ? Utility.toFirstCap(rhShipTo.Ship_To_State__c, 3) : '';
			}
			if (String.isNotBlank(addr)) {
				addr += (String.isNotBlank(rhShipTo.Ship_To_Zip__c)) ? ' ' + rhShipTo.Ship_To_Zip__c : '';
			} else {
				addr += (String.isNotBlank(rhShipTo.Ship_To_Zip__c)) ? rhShipTo.Ship_To_Zip__c : '';
			}
			addr = (String.isNotBlank(addr)) ? addr : ' ';
			subMap.put('%shipToCityStatePostalCode%', addr);
			addr = (String.isNotBlank(rhShipTo.Ship_To_Country_Code__c)) ? rhShipTo.Ship_To_Country_Code__c : ' ';
			subMap.put('%shipToCountryCode%', addr);
            
            subMap.put('%orderNumber%', rhOrder.Name);
            subMap.put('%orderTypeCode%', rhOrder.Order_Type_Code__c);
            subMap.put('%customerName%', customerName);
            subMap.put('%emailThreadId%', rhCase.Email_Thread_Id__c);
            
            // Gift card amount
            String gcAmount = '0';
            if (rhCase.Actual_Gift_Card_Amount__c > 0) {
            	gcAmount = Utility.htmlDollarAmount(rhCase.Actual_Gift_Card_Amount__c, true);
            }
            subMap.put('%giftCardAmount%', gcAmount);
            
            // Get the data for the delayed order lines table
            delayedItems = new List<DelayedOLI>();
            String delayDate;
            String communicatedDate;
            String description;
            String quantity;
            String amount;
            String color;
            String imageURL;
            Application_Settings__c noImgURL = Application_Settings__c.getInstance('ProductImageNotAvailableURL');
            for (Order_Line_Items__c oli :oliList) {
				
				delayDate = Utility.usDate(oli.Current_Delay_Date__c, '/');
				if (String.isBlank(delayDate)) {
					delayDate = ' ';
				}
				
				communicatedDate = Utility.usDate(oli.Current_Available_Date__c, '/');
				if (String.isBlank(communicatedDate)) {
					communicatedDate = ' ';
				}
				
				description = ' ';
				if (String.isNotBlank(oli.CW_SKU_ID__r.ECommerce_Display_Name__c)) {
					description = oli.CW_SKU_ID__r.ECommerce_Display_Name__c;
				} else {
					if (String.isNotBlank(oli.CW_SKU_ID__r.Web_Description__c)) {
						description = oli.CW_SKU_ID__r.Web_Description__c;
					}
				}
				
				quantity = ' ';
				amount = ' ';
				if (oli.Backorder_Quantity__c != null) {
					quantity = String.valueOf(oli.Backorder_Quantity__c);
					if (oli.Unit_Price__c != null) {
						amount = Utility.htmlDollarAmount(oli.Backorder_Quantity__c * oli.Unit_Price__c, true);
					}
				}
				
				color = ' ';
				if (String.isNotBlank(oli.CW_SKU_ID__r.Color__c)) {
					color = Utility.toFirstCap(oli.CW_SKU_ID__r.Color__c, 0);
				}
				
				imageURL = ' ';
				if (String.isNotBlank(oli.CW_SKU_ID__r.Product_Image_URL__c)) {
					imageURL = oli.CW_SKU_ID__r.Product_Image_URL__c;
				} else {
					imageURL = noImgURL.Value_Text__c;
				}
				
				delayedItems.add(new DelayedOLI(description, quantity, amount, imageURL, oli.CW_SKU_ID__r.Name, color, communicatedDate, delayDate));
            }
		}
		
		return subMap;
	}
	
	public Map<String, String> getfooterMap() {
		
		String phone1 = subMap.get('%dnPhone%');
		String phone2 = '1' + phone1.replaceAll('\\D',''); // strip out all non-digits
		
		footerMap = new Map<String, String>();
		footerMap.put('%phoneContact1%', phone1);
		footerMap.put('%phoneContact2%', phone2);
		footerMap.put('%emailContact%', subMap.get('%dnEmail%'));
		footerMap.put('%contactUsURL%', rhb.ContactUsURL__c);
		footerMap.put('%customerServiceURL%', rhb.CustomerServiceURL__c);
		footerMap.put('%faqURL%', rhb.FrequentlyAskedQuestionsURL__c);
		footerMap.put('%privacyPolicyURL%', rhb.PrivacyPolicyURL__c);
		footerMap.put('%galleryNearestYouURL%', rhb.GalleryNearestYouURL__c);
		
		if (String.isNotBlank(notificationType)) {
			footerMap.put('%notificationType%', notificationType);
		} else {
			footerMap.put('%notificationType%', rhCase.Notification_Type__c);
		}
		footerMap.put('%orderTypeCode%', rhCase.RH_Order_Number__r.Order_Type_Code__c);
		footerMap.put('%membershipAutoRenewal%', (rhCase.Membership_Auto_Renewal_Order__c) ? 'TRUE' : 'FALSE');
		
		return footerMap;
	}
}