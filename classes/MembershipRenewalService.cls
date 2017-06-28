public with sharing class MembershipRenewalService {   
	                           
	public class MembershipRenewalException extends Exception {}
	
	/* 
	 * During  callout we can't start any DML transactions. This means we can't run any insert or update
	 * calls. If errors occur, we need to collect then and defer on the inserts until all call outs have completed
	 */
	
	public class CalloutResponse {
		public List<Membership__c> updatedMemberships = new List<Membership__c>(); 
		public List<Error_Log__c> resultingErrors = new List<Error_Log__c>(); 
	}
		
	/*
	 * Returns details of a membership 
	 * Parameters: A membership ID
	 * Returns: Details about that membership
	 */
	 	
	public static Membership__c getMembershipRecord(ID membershipId) {
		List<Membership__c> memberships = getMembershipRecords(new List<ID>{membershipId});
		return memberships != null && memberships.size() > 0 ? memberships.get(0) : null;
	}
	
	/*
	 * Returns the details for a list of membership records
	 * Parameters: A list of membership Ids
	 * Returns: A list of membership records
	 */
	
    public static List<Membership__c> getMembershipRecords(List<ID> membershipIds) {
    	return [
	       SELECT   Id, Name, Enrollment_Date__c, Expiration_Date__c, Renewal_Reminder_Email_Sent_Date__c, Renewal_Term__c, Renewal_Email_Notification__c
			       ,BC_Renewal_CC_Final_4_Digits__c, BC_Renewal_CC_Expiration_Date__c, RH_Renewal_CC_Final_4_Digits__c, RH_Renewal_CC_Expiration_Date__c, Has_Valid_CC__c
			       ,Special_Enrollee__c, GetsChangedTandCs__c, Latest_CC_Expiration_Date__c, Created_By_Order_Id__c, Created_By_Order_Id__r.Name
			       ,Renewal_Order_Entity_Code__c, RH_Renewal_CC_Entity_Code__c, BC_Renewal_CC_Entity_Code__c, Created_By_Order_Id__r.Division__c
			       ,RH_Renewal_CC_Updated_DateTime__c, BC_Renewal_CC_Updated_DateTime__c, Is_Auto_Renew__c, Renew_Email_Opt_In__c, In_Target_Group__c, RenewalEmailSubjectLine__c
			       ,Phone_Order__c, Member_State__c, Member_Country__c, Contact__c, CreatedDate
			       ,Create_Renewal_Order__c, Contact__r.FirstName, Contact__r.LastName, Member_Email__c
	       FROM 	Membership__c
	       WHERE	ID in :membershipIds    	
    	];    	
    }	
    
    /*
     * Returns a list of up to 5 orders for membership records that were used to purchase that membership
     * Paramters: A list of membership records
     * Returns:  A map of orders keyed with that membership Id.
     */

    
	public static Map<ID, List<RH_Order__c>> getMembershipPurchaseOrders(List<Membership__c> memberships) {
  		Map<Id, List<RH_Order__c>> memberOrders = new Map<Id, List<RH_Order__c>>();
  		
  		// 1. build the map of members to find the orders for
  		
  		for (Membership__c member : memberships) {
  			memberOrders.put(member.Id, new List<RH_Order__c>());
  		} 
  		
  		// 2. find all the orders associated
  		
  		Set<String> orderSkus = MembershipService.skus();
  		List<Rh_Order__c> orders = [
  			SELECT Id, Name, Membership_ID_Lookup__c, 
            		(SELECT Id from Sales_Order_Line_Items__r WHERE CW_SKU_Name__c in :orderSkus) 
			FROM RH_Order__c 
			WHERE Membership_ID_Lookup__c in :memberOrders.keySet()
			Order By CreatedDate Desc
		];
		
		// add just those orders with the SKU
		
		for (RH_Order__c order : orders) {
			if (order.Sales_Order_Line_Items__r.size() > 0) {
				if (memberOrders.get(order.Membership_ID_Lookup__c).size() < 5) {
					memberOrders.get(order.Membership_ID_Lookup__c).add(order);
				}
    		}
 		}		
  		
  		system.debug('MembershipRenewalService -> getMembershipPurchaseOrders -> found -> ' + memberOrders);
  		return memberOrders;
	}
	
	/*
	 * Make a CW Payment request
	 * Parameters: A order number
	 * Returns: A HttpResponse from the get payment request
	 */
	
	public static HttpResponse makePaymentRequest(String xmlString) {
         
	    system.debug('MemberRenewalService -> makePaymentRequest -> '+ xmlString);
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(RH_Web_Services__c.getInstance('getPaymentDetail').Service_URL__c);
        request.setMethod('POST');
        request.setBody(xmlString);
        request.setCompressed(false); 
        request.setHeader('Content-Type', 'application/xml');
        
    	system.debug('MemberRenewalService -> makePaymentRequest -> url ' + request.getEndpoint());
        return Test.isRunningTest() ? new HttpResponse() : new Http().send(request);
	}
	
	/*
	 * Converts the HttpResponse from a Get Payment request and returns a map of values
	 * Parameters: A HttpResponse
	 * Returns: A map of values
	 */
	
	public static Map<String, String> processPaymentResponse(HttpResponse response) {
		
		Map<String, String> responseMap = new Map<String, String>(); 		
		
		if (response == null) {
        	return responseMap;
		}         	

		Dom.Document doc = new Dom.Document();
		doc.load(response.getBody());         
		// System.Debug(LoggingLevel.ERROR, 'XML Response Body ================> '+ response.getBody());
		Dom.XMLNode paymentMethodDetails = doc.getRootElement();       
		
		for (Dom.XMLNode pmHeader : paymentMethodDetails.getChildElements()) {                 
			if (pmHeader.getName() == 'responseType') {
				if (pmHeader.getText() == 'Success') {
					responseMap.put('success', 'true');
				}
			} 
			if (pmHeader.getName() == 'getPaymentMethodResponse') {       
				for (Dom.XMLNode cc : pmHeader.getChildElements() ) {
					responseMap.put(cc.getName(), cc.getText());
				}
			}
		}
			
		System.Debug(LoggingLevel.ERROR, 'MembershipRenewalService -> processPaymentResponse -> '+ responseMap);
		return responseMap;        	 		
	}
	
	/*
	 * Converts a Cw Payment date into a Salesforce Date
	 * Parameters: A Cw payment date
	 * Returns: A Salesforce Date object
	 */
	
	public static Date cwPaymentDateToSalesforcePaymentDate(String cwPaymentDate) {
		system.debug('cwPaymentDateToSalesforcePaymentDate -> ' + cwPaymentDate);
		if (cwPaymentDate.length() == 3) {
			cwPaymentDate = '0' + cwPaymentDate;			
		}
 		Integer yyyy = Integer.valueOf(cwPaymentDate.substring(3,7));
		Integer mm = Integer.valueOf(cwPaymentDate.substring(0,2));
		System.Debug('CC put together ====> ' + mm + '/' + yyyy);
		Date d = Date.newInstance(yyyy, mm, 1);
		Integer numberOfDays = Date.daysInMonth(d.Year(), d.Month());
		return Date.newInstance(yyyy, mm, numberOfDays);		
	}    
	
	/*
	 * Makes a payment request against CW for the credit card details associated with membership records
	 * Parameters: A list of membership records
	 * Returns: A list of membership records that have "improved" credit card details
	 */
	
    public static CalloutResponse callCwForBetterCardDetails(List<Membership__c> memberships) {
    	
    	Map<ID, Membership__c> checkedMemberships = new Map<ID, Membership__c>();
    	Map<ID, Membership__c> updatedMemberships = new Map<ID, Membership__c>();
    	CalloutResponse updateResponse = new CalloutResponse();
    	
    	// 1. Get list of memberships we want to contact CW about
    	
    	for (Membership__c membership : memberships) {
    		if (membership.Latest_CC_Expiration_Date__c == null || membership.Latest_CC_Expiration_Date__c < membership.Expiration_Date__c) {
    			checkedMemberships.put(membership.ID, membership);
    		}
    	}
    	
    	// 2. get the Orders for those membership records
    	
    	Map<ID, List<RH_Order__c>> memberOrders = MembershipRenewalService.getMembershipPurchaseOrders(checkedMemberships.values());
    	
    	// 2. For each member record to check
    	
    	for (ID memberId : memberOrders.keySet()) {
    		
    		// for each member purchase order associated with that member
    		    		
    		for (Rh_Order__c order : memberOrders.get(memberId)) {
    			
    			// only if we've not already updated this membership record
    			
    			if (!updatedMemberships.containsKey(memberId)) {
    			
	    			// 2.5 Make the request
	    			
	    			system.debug('MembershipRenewalService -> callCwForBetterCardDetails -> ' + memberId + ' -> ' + order.Name);
	    			
	    			Map<String, String> paymentResponseMap = null;

					try {	    			
						String xmlString = MembershipService.createGetPaymentRequest(order.Name,'SF','MASK'); 
		    			HttpResponse paymentResponse = MembershipRenewalService.makePaymentRequest(xmlString);
		    			paymentResponseMap = MembershipRenewalService.processPaymentResponse(paymentResponse);
					} catch (Exception ex) {
						updateResponse.resultingErrors.add(new Error_Log__c(
							Type__c = 'APEX RUNTIME ERROR',
							Message__c = ex.getMessage(),
							Process_Summary__c = order.Name,
							Stack_Trace__c = ex.getStackTraceString()
						));		
					}
	    			
	    			// 4. For every response that is successful and has a better expiration date, add to list to return
	    			
	    			if (paymentResponseMap != null && paymentResponseMap.containsKey('success') && paymentResponseMap.containsKey('creditCardExpiration')) {
	    				
	    				Date latestDate = checkedMemberships.get(memberId).Latest_CC_Expiration_Date__c;
	    				Date membershipExpDate = checkedMemberships.get(memberId).Expiration_Date__c;
	    				String cwExpirationString =  paymentResponseMap.get('creditCardExpiration');
	    				Date cwExpDate = MembershipRenewalService.cwPaymentDateToSalesforcePaymentDate(cwExpirationString);
	    				Boolean hasValidCreditCard = (cwExpDate != null && !(cwExpDate < membershipExpDate) );
	    				
	    				if ((latestDate == null && cwExpDate != null) || (cwExpDate != null && cwExpDate > latestDate)) {
	    					
	    					// 5. Create a new record for updating
	    					    					
	    					updatedMemberships.put(memberId, new Membership__c(
	    						ID = memberId,
	    						Latest_CC_Expiration_Date__c = cwExpDate, 
	    						Has_Valid_CC__c = hasValidCreditCard
	    					));
	    				}
	    			}
    			}
    		}
    	}
    	
    	system.debug('MembershipRenewalService -> callCwForBetterCardDetails -> updated -> ' + updatedMemberships.keySet()); 
    	updateResponse.updatedMemberships = updatedMemberships.values();
    	return updateResponse;
    }	
    
    /*
     * Gets the number of days notice required based on the renewal email notification string
     * Parameters: A membership record
     * Returns: The number of days notice required for that member
     */
	   
    public static Integer getDaysNotice(Membership__c membership) {
        if(membership.Renewal_Email_Notification__c == '60-Day Notice'){
           return 60;
        }
        if(membership.Renewal_Email_Notification__c == '30-Day Notice'){
           return 30;
        }
        if(membership.Renewal_Email_Notification__c == '5-Day Notice'){
           return 5;
        }
        if(membership.Renewal_Email_Notification__c == '3-Day Notice'){
           return 3;
        }
        if(membership.Renewal_Email_Notification__c == '1-Day Notice'){
           return 1;
        }
        if(membership.Renewal_Email_Notification__c == '5-Day Post Expiration'){
                   return -5;
        } 
        if(membership.Renewal_Email_Notification__c == '1-Day Post Termination'){
           return -1;
        } 
        system.debug('Renewal_Email_Notification__c not set');
        return null;   	
    }    	
    
    /*
     * For each membership records, instantiates the VisualForce page, and stores the page body as an attachment with member as the parent
     * Parameters: List if membership records
     * Returns: A list of attachments to insert
     */
    
    public static List<Attachment> buildAttachments(List<Membership__c> memberships, String notificationType) {    	
    	List<Attachment> attachments = new List<Attachment>();
    	for (Membership__c membership : memberships) {

            Integer daysNotice = getDaysNotice(membership);    		
	  	    String attName = '(' + String.valueOf(daysNotice) + ' Day Notice) - ' + attName(membership, notificationType);
	  	    
	        Blob pageContent;
	        if (!Test.isRunningTest()) {
				String url = '/apex/RHMembershipRenewalExpCCEmail?Id=' + membership.Id + '&daysOut=' + String.valueOf(daysNotice);
				system.debug('MembershipRenewalService -> buildAttachments -> ' + url);
				pageContent = new PageReference(url).getContent();	           
	        } else {
				pageContent = Blob.valueOf('Test Class');
	        }
	        
	        Attachment attachment = new Attachment();
	        attachment.ParentId = membership.Id;
	        attachment.name = attName + membership.Name + '.html';
	        attachment.body = pageContent; 
	        attachments.add(attachment);
    	}          
        return attachments;    	
    }   
    
    /*
     * Filter the membership records supplied to find those that need renewal emails. Update record with notification schedule and email subject
     * Parameters: list of membership records
     * Returns: Membership records that were updated and require renewal emails
     */
    
	public static List<Membership__c> buildRenewalMembershipRecords(List<Membership__c> memberships, String notificationType) {
       
       Map<String, Boolean> membershipFlagMap = new Map<String, Boolean>(); 
       List<Membership__c> updateMemberships = new List<Membership__c>();
            
       for (Membership__c m : memberships) {      
                             
           Boolean updateMembership = false;
           MembershipRenewalProperties mrp = new MembershipRenewalProperties(m); 
           //block to process renewal notifications and determine which notification to send based on expiration date
           if (notificationType == 'renewal') 
           {
           if (m.Expiration_Date__c == System.Today().AddDays(60) && qualifiesFor60DayEmail(mrp)) {
           	  // 60-Day Notice               
              m.Renewal_Email_Notification__c = '60-Day Notice';
              updateMembership = true;
           } else if (m.Expiration_Date__c == System.Today().AddDays(30) && qualifiesFor30DayEmail(mrp)) {
              // 30-Day Notice              
              System.Debug(LoggingLevel.Error,'SHOULD be sending the 30 day no valid CC email!');    
              m.Renewal_Email_Notification__c = '30-Day Notice';
              updateMembership = true;
           } else if (m.Expiration_Date__c == System.Today().AddDays(5) && qualifiesFor5DayEmail(mrp)) {
              // 5-Day Notice              
              m.Renewal_Email_Notification__c = '5-Day Notice';
              updateMembership = true;
           } else if (m.Expiration_Date__c == System.Today().AddDays(3) && qualifiesFor3DayEmail(mrp)) {
              // 3-Day Notice              
              m.Renewal_Email_Notification__c = '3-Day Notice';
              updateMembership = true;
           } else if (m.Expiration_Date__c == System.Today().AddDays(1) && qualifiesFor1DayEmail(mrp)) {
              // 1-Day Notice               
              m.Renewal_Email_Notification__c = '1-Day Notice';
              updateMembership = true;
           } else if (m.Expiration_Date__c == System.Today().AddDays(-5) && qualifiesForMinus1DayEmail(mrp)) {
              // 1-Day POST EXPIRATION Notice (EXCLUDING QC)              
              m.Renewal_Email_Notification__c = '5-Day Post Expiration';
              m.Is_Auto_Renew__c = false;
              updateMembership = true;
           }
           }
           //need to check if calling methods are processing terminiation notifications this is based on cancellation date
           else if (notificationType == 'terminate')
           {
           	if (m.cancellation_date__c == System.Today().AddDays(-1) && qualifiesForMinus1DayEmail(mrp)) {
              // 1-Day POST Termination Notice             
              m.Renewal_Email_Notification__c = '1-Day Post Termination';
              updateMembership = true;
           	          	
           }
           }
           
          
           if (updateMembership) {
           	
				// initialize template
				MembershipRenewalEmailTemplateController template = new MembershipRenewalEmailTemplateController();
				template.rhMembership = m;
				template.membershipId = m.Id;
				String mainContent = template.getMainParagraph();
				
				if (String.isNotBlank(mainContent)) {
					m.RenewalEmailSubjectLine__c = template.subject;
					m.Renewal_Reminder_Email_Sent_Date__c = System.Now();					
					updateMemberships.add(m);
				} else {
					String message = 'buildRenewalMembershipRecords -> Error Occured. failed to build content for the email. Do not add to list, as blank email would be sent -> ' + m; 
					Utility.logException((Exception)new MembershipRenewalException(message), m.Name);
					system.debug(message);
				}
			} 
       }       
       
       return updateMemberships;       
    }
    
    
    /*
     * Update the latest expiration date and renewal order entity code for a list of membershp records
     * Parameters: list of membership records
     * Returns: membership records that WERE updated
     */    
    
    public static List<Membership__c> assignExpirationDates(List<Membership__c> memberships) {
    	List<Membership__c> updatedMemberships = new List<Membership__c>();
    	for (Membership__c membership : memberships) {
    		Membership__c updatedMembership = assignExpirationDates(membership, false); 
    		
    		// if any changes were made, update existing, and return new membership for update
    		
    		if (updatedMembership.Has_Valid_CC__c != membership.Has_Valid_CC__c ||
    			updatedMembership.Latest_CC_Expiration_Date__c != membership.Latest_CC_Expiration_Date__c ||
    			updatedMembership.Renewal_Order_Entity_Code__c != membership.Renewal_Order_Entity_Code__c ) {
    				
    				// the record changed. add to records to update
    				updatedMemberships.add(updatedMembership);
    				
    				// update the original so exsting membership record can be used by calling method
    				membership.Has_Valid_CC__c = updatedMembership.Has_Valid_CC__c;
    				membership.Latest_CC_Expiration_Date__c = updatedMembership.Latest_CC_Expiration_Date__c;
    				membership.Renewal_Order_Entity_Code__c = updatedMembership.Renewal_Order_Entity_Code__c;
    		}
    	}
    	return updatedMemberships;    	
    }
    
    /*
     * Update the latest expiration date and renewal order entity code for a membershp record
     * Parameters: membership record
     * Returns: membership record that may or may not have been updated
     */
     
    public static Membership__c assignExpirationDates(Membership__c m) {
    	return assignExpirationDates(m, true);
    }        
    
    public static Membership__c assignExpirationDates(Membership__c m, Boolean cwCheck) {
    	
		System.Debug('MembershipRenewalService -> assignExpirationDates -> ' + m.Name );
		
		Membership__c updatedMembership = new Membership__c(
			ID = m.Id,
			Renewal_Order_Entity_Code__c = m.Renewal_Order_Entity_Code__c
		);
              
		//FIRST check if a valid CC exists on the membership.
       
		Date ccExpDate;
		String rhOrBc;
		Date ccExpDateRH = MembershipService.ccExpDate(m.RH_Renewal_CC_Expiration_Date__c);
		Date ccExpDateBC = MembershipService.ccExpDate(m.BC_Renewal_CC_Expiration_Date__c);
       
		if (ccExpDateRH != null && ccExpDateBC != null) {
       	
			if (!(ccExpDateRH < m.Expiration_Date__c) && !(ccExpDateBC < m.Expiration_Date__c) ) {
				if (m.BC_Renewal_CC_Updated_DateTime__c > m.RH_Renewal_CC_Updated_DateTime__c) {
	   	    		ccExpDate = ccExpDateBC;
	   	    		rhOrBC = 'BC';
				} else { 
	   	    		ccExpDate = ccExpDateRH;
	   	    		rhOrBC = 'RH';
	   	    	}
			} else if (!(ccExpDateRH < m.Expiration_Date__c)) {
   	    		ccExpDate = ccExpDateRH;
   	    		rhOrBC = 'RH';				
			} else if (!(ccExpDateBC < m.Expiration_Date__c) ) {
   	    		ccExpDate = ccExpDateBC;
   	    		rhOrBC = 'BC';					
			} else if (ccExpDateRH > ccExpDateBC) {
   	    		ccExpDate = ccExpDateRH;
   	    		rhOrBC = 'RH';								
			} else {
   	    		ccExpDate = ccExpDateBC;
   	    		rhOrBC = 'BC';									
			}

		} else if (ccExpDateBC != null) {
   		 	ccExpDate = ccExpDateBC;
   		 	rhOrBC = 'BC';           		 	
		} else if (ccExpDateRH != null) {
   		 	ccExpDate = ccExpDateRH;
   		 	rhOrBC = 'RH';      		           	
		}     
            
		if (cwCheck) {                                   
			if (ccExpDate == null || ccExpDate < m.Expiration_Date__c) {
	       		system.debug('see if CW has something better');	       		
	            Date cwExpDate = MembershipService.creditCardExpDate(m);   // Call MULE to get CC
	            if (ccExpDate == null && cwExpDate != null) {
	               ccExpDate = cwExpDate;
	            } else if (cwExpDate != null && cwExpDate > m.Expiration_Date__c) {
	               ccExpDate = cwExpDate;
	            }
	   		}
		}
		   		
        updatedMembership.Has_Valid_CC__c = (ccExpDate != null && !(ccExpDate < m.Expiration_Date__c) );
        updatedMembership.Latest_CC_Expiration_Date__c = ccExpDate;
        
        // set entity code based on rh or bc. or created orders division.
        
		if (rhOrBc != null) {
			updatedMembership.Renewal_Order_Entity_Code__c = (rhOrBC == 'RH') ? m.RH_Renewal_CC_Entity_Code__c : m.BC_Renewal_CC_Entity_Code__c;           
		} else {  
			if (m.Created_By_Order_Id__c != null && m.Created_By_Order_Id__r.Division__c != null) {
				updatedMembership.Renewal_Order_Entity_Code__c = m.Created_By_Order_Id__r.Division__c;				
			}
   		}        
   		
   		// catch all
   		
   		if (updatedMembership.Renewal_Order_Entity_Code__c == null) {
   			updatedMembership.Renewal_Order_Entity_Code__c = '10';
   		}
        
        return updatedMembership;    	
    }  


 public static String attName(Membership__c m, String notificationType){
     	 String attNameContext = '';
     	 
     	 if (notificationType == 'renewal')
     	 {
      	 if(!m.Has_Valid_CC__c && m.Latest_CC_Expiration_Date__c == null){
      	 	attNameContext = 'RH Membership No CC Email - Member ';
      	 }
      	 if(m.Has_Valid_CC__c && m.Latest_CC_Expiration_Date__c != null){
      	 	attNameContext = 'RH Membership Valid CC Email - Member ';
      	 }
    	 if(!m.Has_Valid_CC__c && m.Latest_CC_Expiration_Date__c != null){
      	 	attNameContext = 'RH Membership Expiring CC Email - Member ';
      	 }
         if(!m.Is_Auto_Renew__c){
      	 	attNameContext = 'RH Membership No AutoRenew Email - Member ';
      	 }
     	 }
     	 else if (notificationType == 'terminate') 
     	 	attNameContext = 'RH Membership Terminate Email - Member ';
     	 	
   	     return attNameContext;
   }
       
    /*
     * Renewal email Qualification logic
     */
    
	
	public static Boolean qualifiesFor60DayEmail(MembershipRenewalService.MembershipRenewalProperties mrp) {
	    return MembershipService.livesInQuebec(mrp.membership, FALSE);
	}
	
	public static Boolean qualifiesFor30DayEmail(MembershipRenewalService.MembershipRenewalProperties mrp) {
		return !mrp.autoRenew || mrp.expiringCC || mrp.noCC || (
			mrp.autoRenew && mrp.validCC && (
				mrp.isILCTHINC || mrp.isQuebecois || mrp.IsCanadianNonQuebec || mrp.is03122016Thru03162016 || (
					!mrp.isGreaterThan10162016 && mrp.isRenewEmailOptIn
				)
			) 
		);
	}
	
	public static Boolean qualifiesFor5DayEmail(MembershipRenewalService.MembershipRenewalProperties mrp) {
		
	    if (mrp.isILCTHINC && mrp.autoRenew && (mrp.expiringCC || mrp.noCC)){
	    	  return true;
	    }
	    if(mrp.isILCTHINC && !mrp.autoRenew){
	    	  return true;
	    }
	    if(mrp.isCanadianNonQuebec && mrp.autoRenew && (mrp.expiringCC || mrp.noCC)){
	    	  return true;
	    }
	    if(mrp.isCanadianNonQuebec && !mrp.autoRenew){
	    	  return true;
	    }
	    if(!mrp.isILCTHINC && mrp.isNonCanada && mrp.autoRenew && (mrp.expiringCC || mrp.noCC)){
	    	  return true;
	    }
	    if(!mrp.isILCTHINC && mrp.isNonCanada && !mrp.autoRenew){
	    	  return true;
	    }
	    if(mrp.isQuebecois && mrp.autoRenew && (mrp.expiringCC || mrp.noCC)){
	    	  return true;
	    }
	    if(mrp.isQuebecois && !mrp.autoRenew){
	    	  return true;
	    }
	
	    return false;
	}
	
	public static Boolean qualifiesFor3DayEmail(MembershipRenewalService.MembershipRenewalProperties mrp) {
		
	    if (mrp.autoRenew && mrp.isRenewEmailOptIn && mrp.validCC) {
	    	  Boolean sent30Day = membership30DayEmailSent(mrp.membership);
	    	  
	    	  if (mrp.isGreaterThan10162016 && !mrp.isILCTHINC && mrp.isNonCanada) {
	    	  	 return true;
	    	  } 
	      	  if (mrp.isGreaterThan10162016 && !mrp.isNonCanada && !sent30Day) {
	      	  	 return true;
	      	  }       	   
	    }
	
	    return false;
	}
	
	public static Boolean qualifiesFor1DayEmail(MembershipRenewalService.MembershipRenewalProperties mrp) {
		
	    if (mrp.isILCTHINC && mrp.autoRenew && (mrp.expiringCC || mrp.noCC)){
	    	  return true;
	    } 
	    if (mrp.isILCTHINC && !mrp.autoRenew){
	    	  return true;
	    }
	    if (mrp.isCanadianNonQuebec && mrp.autoRenew && (mrp.expiringCC || mrp.noCC)){
	    	  return true;
	    }
	    if (mrp.isCanadianNonQuebec && !mrp.autoRenew){
	    	  return true;
	    }
	    if (!mrp.isILCTHINC && mrp.isNonCanada && mrp.autoRenew && (mrp.expiringCC || mrp.noCC)){
	    	  return true;
	    }
	    if (!mrp.isILCTHINC && mrp.isNonCanada && !mrp.autoRenew){
	    	  return true;
	    }
	    if (mrp.isQuebecois && !mrp.autoRenew){
	    	  return true;
	    }
	
	    return false;
	}
	
	public static Boolean qualifiesFor0DayEmail(MembershipRenewalService.MembershipRenewalProperties mrp) {
	    return false;
	}
	
	public static Boolean qualifiesForMinus1DayEmail(MembershipRenewalService.MembershipRenewalProperties mrp) {
	    return true;
	}
	
	public static Boolean membership30DayEmailSent(Membership__c m) {  	
		for(Membership__History mh:[SELECT Id, Field, NewValue, OldValue, CreatedDate 
		                              FROM Membership__History 
		                             where parentid= :m.Id
		                               and Field = 'Renewal_Email_Notification__c']){  		
	        if(mh.NewValue == '30-Day Notice' && mh.CreatedDate > System.Now().AddDays(-30)){
	        	return true;
	        }
		}
		return false;
	}
	        
    /*
     * Renewal email properties
     */
    
	public class MembershipRenewalProperties {
    	
    	public Membership__c membership {get;set;}
		public Boolean noCC {get;set;}
       	public Boolean expiringCC {get;set;}
       	public Boolean validCC {get;set;}
       	public Boolean anyCC;
       	
       	public Boolean isQuebecois {get;set;}
       	public Boolean isCanadianNonQuebec {get;set;}
       	public Boolean isNonCanada {get;set;}
          
       	public Boolean autoRenew {get;set;}
       	public Boolean enrolledBeforeAugust2016 {get;set;}   
           
       	public Boolean isRenewEmailOptIn {get;set;}
       	public Boolean is03122016Thru03162016 {get;set;}
       	public Boolean isILCTHINC {get;set;}
       	public Boolean isGreaterThan10162016 {get;set;} 
       	
		public Integer daysOut{get;set;}
       
       	public MembershipRenewalProperties(Membership__c m) {
       		
       		Date augustFirst2016 =  Date.newInstance(2016,8,1);
       		
       		this.membership = m;
	       	this.noCC = (!m.Has_Valid_CC__c && m.Latest_CC_Expiration_Date__c == null) ? true : false;
	       	this.expiringCC = (!m.Has_Valid_CC__c && m.Latest_CC_Expiration_Date__c != null) ? true : false;
	       	this.validCC = (m.Has_Valid_CC__c && m.Latest_CC_Expiration_Date__c != null) ? true : false;
	       	this.anyCC = (noCC || expiringCC || validCC) ? true : false;
	       
	       	this.isQuebecois = MembershipService.livesInQuebec(m, FALSE);
	       	this.isCanadianNonQuebec = !isQuebecois && MembershipService.livesInCanada(m) ? true : false;
	       	this.isNonCanada = MembershipService.livesInCanada(m) ? false : true;
	          
	       	this.autoRenew = m.Is_Auto_Renew__c;
	       	this.enrolledBeforeAugust2016 = m.Enrollment_Date__c < augustFirst2016 ? true : false;   
	           
	       	this.isRenewEmailOptIn = m.Renew_Email_Opt_In__c;
	       	this.is03122016Thru03162016 = m.Special_Enrollee__c;
	       	this.isILCTHINC = m.In_Target_Group__c;
	       	this.isGreaterThan10162016 = m.GetsChangedTandCs__c;
	       	
	       	this.daysOut = MembershipRenewalService.getDaysNotice(m);
	       	
	       	system.debug('membership - ' + m.Member_Email__c + ' isIL ' + this.isILCTHINC + ' isnoq ' + this.isCanadianNonQuebec + ' isQuebecois ' + this.isquebecois);

			//system.debug('MembershipRenewalProperties -> ' + this);
       	}   	
	}
}