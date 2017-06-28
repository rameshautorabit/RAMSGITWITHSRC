public class CreditCardDecline {
	
	/*
	 *	Controller for the Credit Card Decline visualforce email template and components
	 *
	 */
	
	private Case rhCase;
	private Map<String, String> subMap;
	private Map<String, String> footerMap;
	private String notificationType;
	private RH_Brand__c rhbrand;
	
	public Id caseId {get; set;}
	
	public CreditCardDecline() {
		
		// The case Id is either passed in as a page parameter or it comes to the page via
		// the visualforce email template (CreditCardDecline)
		Id cIdParameter = ApexPages.currentPage().getParameters().get('caseId');
		if (String.isNotBlank(cIdParameter)) {
			caseId = cIdParameter;
		}
		
		notificationType = ApexPages.currentPage().getParameters().get('notificationType');
		
		rhCase = null;
	}
	
	public Map<String, String> getsubMap() {
		String customerName;
		
		// Get all the data needed for the email if necessary
		if (rhCase == null) {
			rhCase = new Case();
			rhCase = [select Id, CaseNumber, Notification_Type__c, RH_Order_Number__c, Email_Thread_Id__c, Membership_Auto_Renewal_Order__c, 
					RH_Order_Number__r.Name, RH_Order_Number__r.Sold_to_First_Name__c, RH_Order_Number__r.Sold_to_Last_Name__c, 
					RH_Order_Number__r.Order_Type_Code__c, RH_Order_Number__r.Division__c, RH_Order_Number__r.Membership_ID_Lookup__r.Member_Email__c 
					/*
					RH_Order_Number__r.Sold_To_Address_1__c, RH_Order_Number__r.Sold_to_Address_2__c, 
					RH_Order_Number__r.Sold_To_Address_3__c, RH_Order_Number__r.Sold_to_City__c, 
					RH_Order_Number__r.Sold_to_State__c, RH_Order_Number__r.Sold_to_Zip__c,
					RH_Order_Number__r.Sold_to_Country_Code__c
					*/
					from Case where Id = :caseId];
			
			subMap = new Map<String, String>();
			
			customerName = Utility.toFirstCap(rhCase.RH_Order_Number__r.Sold_to_First_Name__c, 3);
			if (String.isNotBlank(customerName)) {
				customerName += ' ';
			}
			customerName += Utility.toFirstCap(rhCase.RH_Order_Number__r.Sold_to_Last_Name__c, 0);
			
			if (String.isNotBlank(notificationType)) {
				subMap.put('%notificationType%', notificationType);
			} else {
				subMap.put('%notificationType%', rhCase.Notification_Type__c);
			}
			
			if (rhCase.RH_Order_Number__r.Order_Type_Code__c == 'Z') {
				rhBrand = RH_Brand__c.getInstance('RH Contract');
			} else {
				if (String.isNotBlank(rhCase.RH_Order_Number__r.Division__c) && rhCase.Membership_Auto_Renewal_Order__c) {
                	rhBrand = RH_Brand__c.getInstance(rhCase.RH_Order_Number__r.Division__c);
            	} else {
            		rhBrand = RH_Brand__c.getInstance('999');
            	}
			}
			
			submap.put('%logoLink%', rhBrand.Brand_Home_Page_URL__c);
			subMap.put('%logoURL%', rhBrand.Brand_Logo_URL__c);
			subMap.put('%logoWidth%', rhBrand.Brand_Logo_Width__c);
			subMap.put('%logoHeight%', rhBrand.Brand_Logo_Height__c);
			subMap.put('%customerName%', customerName);
			subMap.put('%orderNumber%', rhCase.RH_Order_Number__r.Name);
			subMap.put('%orderTypeCode%', rhCase.RH_Order_Number__r.Order_Type_Code__c);
			subMap.put('%emailThreadId%', rhCase.Email_Thread_Id__c);
			subMap.put('%membershipAutoRenewal%', (rhCase.Membership_Auto_Renewal_Order__c) ? 'TRUE' : 'FALSE');
			
			// Set the preview text
			Map<String, CreditCardDeclineEmail__c> ccdEmailMap = CreditCardDeclineEmail__c.getAll();
			String noticeType = rhCase.Notification_Type__c.substringAfter('Credit Card Declines - ');
			if (rhCase.RH_Order_Number__r.Order_Type_Code__c == 'Z') {
				noticeType += ' - Contract';
			} else {
				if (rhCase.Membership_Auto_Renewal_Order__c) {
					noticeType += ' - Membership';
				} else {
					noticeType += ' - Regular';
				}
			}
			subMap.put('%previewText%', ccdEmailMap.get(noticeType).Preview_Text__c);
			
			// Set the membership renewal URL
			/*
			Blob key = Blob.valueOf(Application_Settings__c.getInstance('MembershipRenewalLoginKey').Value_Text__c);
			String loginName = rhCase.RH_Order_Number__r.Membership_ID_Lookup__r.Member_Email__c;
			String encryptedLoginName = '';
			if (String.isNotBlank(loginName)) {
				Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(loginName));
				String encodedCipherText = EncodingUtil.base64Encode(cipherText);
				encryptedLoginName = encodingUtil.URLEncode(encodedCipherText,'UTF-8');
			}
			subMap.put('%membershipRenewalURL%', rhBrand.MembershipRenewalURL__c + encryptedLoginName);
			*/
			String loginName = rhCase.RH_Order_Number__r.Membership_ID_Lookup__r.Member_Email__c;
			if (String.isBlank(loginName)) {
				loginName = '';
			}
			subMap.put('%membershipRenewalURL%', rhBrand.MembershipRenewalURL__c + encodingUtil.URLEncode(loginName,'UTF-8'));
			
			/*
			String addr = (String.isNotBlank(rhCase.RH_Order_Number__r.Sold_To_Address_1__c)) ? Utility.toFirstCap(rhCase.RH_Order_Number__r.Sold_To_Address_1__c, 2) : ' ';
			subMap.put('%addr1%', addr);
			addr = (String.isNotBlank(rhCase.RH_Order_Number__r.Sold_To_Address_2__c)) ? Utility.toFirstCap(rhCase.RH_Order_Number__r.Sold_To_Address_2__c, 2) : ' ';
			subMap.put('%addr2%', addr);
			addr = (String.isNotBlank(rhCase.RH_Order_Number__r.Sold_To_Address_3__c)) ? Utility.toFirstCap(rhCase.RH_Order_Number__r.Sold_To_Address_3__c, 2) : ' ';
			subMap.put('%addr3%', addr);
			addr = (String.isNotBlank(rhCase.RH_Order_Number__r.Sold_To_City__c)) ? Utility.toFirstCap(rhCase.RH_Order_Number__r.Sold_To_City__c, 2) : '';
			if (String.isNotBlank(addr)) {
				addr += (String.isNotBlank(rhCase.RH_Order_Number__r.Sold_To_State__c)) ? ', ' + Utility.toFirstCap(rhCase.RH_Order_Number__r.Sold_To_State__c, 3) : '';
			} else {
				addr += (String.isNotBlank(rhCase.RH_Order_Number__r.Sold_To_State__c)) ? Utility.toFirstCap(rhCase.RH_Order_Number__r.Sold_To_State__c, 3) : '';
			}
			if (String.isNotBlank(addr)) {
				addr += (String.isNotBlank(rhCase.RH_Order_Number__r.Sold_To_Zip__c)) ? ' ' + rhCase.RH_Order_Number__r.Sold_To_Zip__c : '';
			} else {
				addr += (String.isNotBlank(rhCase.RH_Order_Number__r.Sold_To_Zip__c)) ? rhCase.RH_Order_Number__r.Sold_To_Zip__c : '';
			}
			addr = (String.isNotBlank(addr)) ? addr : ' ';
			subMap.put('%cityStatePostalCode%', addr);
			addr = (String.isNotBlank(rhCase.RH_Order_Number__r.Sold_to_Country_Code__c)) ? rhCase.RH_Order_Number__r.Sold_to_Country_Code__c : ' ';
			subMap.put('%countryCode%', addr);
			*/
		}
		
		return subMap;
	}
	
	public Map<String, String> getfooterMap() {
		
		footerMap = new Map<String, String>();
		footerMap.put('%phoneContact1%', '800.910.9836');
		footerMap.put('%phoneContact2%', '18009109836');
		footerMap.put('%emailContact%', 'webcs@rh.com');
		footerMap.put('%contactUsURL%', rhBrand.ContactUsURL__c);
		footerMap.put('%customerServiceURL%', rhBrand.CustomerServiceURL__c);
		footerMap.put('%faqURL%', rhBrand.FrequentlyAskedQuestionsURL__c);
		footerMap.put('%privacyPolicyURL%', rhBrand.PrivacyPolicyURL__c);
		footerMap.put('%galleryNearestYouURL%', rhBrand.GalleryNearestYouURL__c);
		
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