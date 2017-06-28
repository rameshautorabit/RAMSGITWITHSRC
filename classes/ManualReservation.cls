public class ManualReservation {
	
	private Manual_Reservation__c rhMR;
	private Map<String, String> subMap;
	private Map<String, String> footerMap;
	
	public class mirvOLI {
		public String description {get; set;}
		public String quantity {get; set;}
		public String image {get; set;}
		public String item {get; set;}
		public String color {get; set;}
		
		public mirvOLI(String des, String qty, String img, String itm, String clr) {
			description = des;
			quantity = qty;
			image = img;
			item = itm;
			color = clr;
		}
	}
	
	public List<mirvOLI> mirvItems {get; set;}
	
	public Id mrId {get; set;}
	
	public ManualReservation() {
		
		// The Manual Reservation record Id is either passed in as a page parameter or it comes to the page via
		// the visualforce email template (ManualReservation)
		Id mrIdParameter = ApexPages.currentPage().getParameters().get('mrId');
		if (String.isNotBlank(mrIdParameter)) {
			mrId = mrIdParameter;
		}
		
		system.debug('*****ManualReservation constructor mrId = ' + mrId + ' mrIdParameter = ' + mrIdParameter);
		
		rhMR = null;
	}
	
	// Get the data for the email template
	public Map<String, String> getsubMap() {
		
		if (rhMR == null) {
			
			system.debug('*****ManualReservation getsubMap mrId = ' + mrId);
			
			rhMR = new Manual_Reservation__c();
			rhMR = [select Id, Order_Number__c, Ship_To__c, Early_Delivery_Date__c, Late_Delivery_Date__c,  
					Email_Subject_Brand__c, Email_To_Address__c, Order_Lines__c 
					from Manual_Reservation__c where Id = :mrId];
			
			List<String> lineExtIds = new List<String>();
			lineExtIds = (List<String>)JSON.deserialize(rhMR.Order_Lines__c, List<String>.class);
			
			RH_Order__c rhOrder = new RH_Order__c();
            rhOrder = [select Id, Name, Division__c, Order_Type_Code__c, Opportunity__c, Opportunity__r.Ops_Contact__c 
                    from RH_Order__c where Id = :rhMR.Order_Number__c];
			
			List<Order_Line_Items__c> oliList = new List<Order_Line_Items__c>();
            oliList = [select Id, Name, Order_Quantity__c, EXT_OrderShipToLine_Number__c, 
                    CW_SKU_ID__c, CW_SKU_ID__r.Name, CW_SKU_ID__r.Web_Description__c, CW_SKU_ID__r.Product_Image_URL__c, 
                    CW_SKU_ID__r.ECommerce_Display_Name__c, CW_SKU_ID__r.Color__c
                    from Order_Line_Items__c where EXT_OrderShipToLine_Number__c in :lineExtIds];
            
            Ship_To__c rhShipTo = new Ship_To__c();
            rhShipTo = [select Id, Name, Order__c, Ship_to_First_Name__c, Ship_to_Last_Name__c, Ship_to_Address_1__c, 
            		Ship_to_Address_2__c, Ship_to_Company__c, Ship_to_City__c, Ship_to_State__c, Ship_to_Zip__c, 
            		Ship_to_Country__c, Ship_to_Email__c, Ship_to_Country_Code__c, Order_Description__c 
                    from Ship_To__c where Id = :rhMR.Ship_To__c];
		
			// Get the RH brand data
            String dnEmail = '';
            String dnPhone = '';
            String pmName = ' ';
            RH_Brand__c rhb = null;
            if (rhOrder.Order_Type_Code__c == 'Z') {
            	rhb = RH_Brand__c.getInstance('RH Contract');
            	if (rhOrder.Opportunity__r.Ops_Contact__c != null) {
            		User pmUser = [select Id, Name, Email, Phone from User where Id = :rhOrder.Opportunity__r.Ops_Contact__c];
            		pmName = pmUser.Name;
            		if (String.isNotBlank(pmUser.Phone)) {
            			dnPhone = Utility.formatPhone10(pmUser.Phone);
            		}
            		dnEmail = pmUser.Email;
            	}
            } else {
            	if (String.isNotBlank(rhOrder.Division__c)) {
                	rhb = RH_Brand__c.getInstance(rhOrder.Division__c);
            	} else {
            		rhb = RH_Brand__c.getInstance('999');
            	}
            }
            
            dnEmail = (String.isNotBlank(dnEmail)) ? dnEmail : rhb.Delay_Notification_Email__c;
            dnPhone = (String.isNotBlank(dnPhone)) ? dnPhone : Utility.formatPhone10(rhb.Delay_Notification_Phone__c);
            
            subMap = new Map<String, String>();
            subMap.put('%pmName%', pmName);
            subMap.put('%dnEmail%', dnEmail);
            subMap.put('%dnPhone%', dnPhone);
            subMap.put('%logoLink%', rhb.Brand_Home_Page_URL__c);
            subMap.put('%logoURL%', rhb.Brand_Logo_URL__c);
            subMap.put('%logoWidth%', rhb.Brand_Logo_Width__c);
            subMap.put('%logoHeight%', rhb.Brand_Logo_Height__c);
            
            // Customer name and addresses, order number and type code
            String shipToName = Utility.toFirstCap(rhShipTo.Ship_to_First_Name__c, 3);
            if (String.isNotBlank(shipToName)) {
                shipToName += ' ';
            }
            shipToName += Utility.toFirstCap(rhShipTo.Ship_to_Last_Name__c, 0);
            if (String.isBlank(shipToName)) {
            	shipToName = ' ';
            }
			
			subMap.put('%shipToName%', shipToName);
			
			String addr = (String.isNotBlank(rhShipTo.Ship_To_Company__c)) ? Utility.toFirstCap(rhShipTo.Ship_To_Company__c, 2) : ' ';
			subMap.put('%shipToCompany%', addr);
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
            
            // Delivery dates and order description
            String subStr = Utility.usDate(rhMR.Early_Delivery_Date__c, '/');
            subStr = (String.isBlank(subStr)) ? ' ' : subStr;
            subMap.put('%earlyDeliveryDate%', subStr);
            subStr = Utility.usDate(rhMR.Late_Delivery_Date__c, '/');
            subStr = (String.isBlank(subStr)) ? ' ' : subStr;
            subMap.put('%lateDeliveryDate%', subStr);
            
            if (String.isBlank(rhShipTo.Order_Description__c)) {
            	subMap.put('%orderDescriptionHeader%', ' ');
            	subMap.put('%orderDescription%', ' ');
            } else {
            	subMap.put('%orderDescriptionHeader%', 'ORDER DESCRIPTION');
            	subMap.put('%orderDescription%', rhShipTo.Order_Description__c);
            }
            
            // Get the data for the MIRV order lines table
            mirvItems = new List<mirvOLI>();
            String description;
            String quantity;
            String color;
            String imageURL;
            Application_Settings__c noImgURL = Application_Settings__c.getInstance('ProductImageNotAvailableURL');
            for (Order_Line_Items__c oli :oliList) {
				
				description = ' ';
				if (String.isNotBlank(oli.CW_SKU_ID__r.ECommerce_Display_Name__c)) {
					description = oli.CW_SKU_ID__r.ECommerce_Display_Name__c;
				} else {
					if (String.isNotBlank(oli.CW_SKU_ID__r.Web_Description__c)) {
						description = oli.CW_SKU_ID__r.Web_Description__c;
					}
				}
				
				quantity = (oli.Order_Quantity__c != null) ? String.valueOf(oli.Order_Quantity__c) : ' ';
				color = (String.isNotBlank(oli.CW_SKU_ID__r.Color__c)) ? Utility.toFirstCap(oli.CW_SKU_ID__r.Color__c, 0) : ' ';
				imageURL = (String.isNotBlank(oli.CW_SKU_ID__r.Product_Image_URL__c)) ? oli.CW_SKU_ID__r.Product_Image_URL__c : noImgURL.Value_Text__c;
				
				mirvItems.add(new mirvOLI(description, quantity, imageURL, oli.CW_SKU_ID__r.Name, color));
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
		
		system.debug('*****ManualReservation footerMap = ' + footerMap);
		
		return footerMap;
	}
}