public class CreditCardDeclineNotifications {
    
    /*
     *  Methods for automatic Credit Card Decline email notifications.
     *
     */
	
	// Return the auto-processing state
	public static Boolean isCCDAutoProcess(Case c) {
		Boolean autoProcess;
		
		if ( c.RH_Order_Number__c == null || 
			 c.CCD_Final_Notice_Sent__c || 
			 c.WasReopened__c || 
			 c.RH_Order_Number__r.Order_Type_Code__c == 'Z' || 
			 String.isBlank(c.RH_Order_Number__r.Sold_to_Email__c) || 
			 c.Request_Category__c == 'Callout' ||
			 c.RH_Order_Number__r.Number_of_Order_Lines__c == 0  ) {
			autoProcess = false;
		} else {
			if (c.CCD_Auto_Email_Sent__c > 0) {
				autoProcess = false;
				if (c.System_Hold_Code__c != 'AT' && c.Attempted_Contact__c == 3) {
					autoProcess = true;
				}
				if (c.System_Hold_Code__c == 'AT' && String.isNotBlank(c.Call_Outcome__c) && c.Call_Outcome__c == 'Sent Email') {
					autoProcess = true;
				}
			} else {
				autoProcess = true;
			}
		}
		
		return autoProcess;
	}
	
	// Returns the updated membership record based on case CCD_Status__c.
	public static Membership__c ccdMembership(Case c, String ccdStatus, Map<Id, Membership__c> mMap) {
		Membership__c mem = null;
		
		if ((String.isBlank(c.CCD_Status__c) || c.CCD_Status__c == 'Pending') && ccdStatus == 'In Progress') {
			if (c.Membership_Auto_Renewal_Order__c && mMap.containsKey(c.RH_Order_Number__r.Membership_ID_Lookup__c)) {
				mem = mMap.get(c.RH_Order_Number__r.Membership_ID_Lookup__c);
				mem.AutoRenew_CCD_Order_Number__c = c.RH_Order_Number__r.Alternate_Order_Number__c;
				mem.Cancellation_Reason__c = 'Credit card decline';
				mem.Cancellation_Type__c = 'Pending';
			}
		}
		
		return mem;
	}
	
	// Processes the list of CCD notifications - @future because of trigger and getContent
    @future (callout=true)
    public static void ccDeclineNotifications(Set<Id> caseIds) {
    	sendCCDNotifications(caseIds);
    }
	
	// Send the CCD notification emails
    public static void sendCCDNotifications(Set<Id> caseIds) {
        
        if (!caseIds.isEmpty()) {
            
           // Get the case data for the supplied case Ids - all must be open cases
            List<Case> caselist = new List<Case>();
			caseList = [select Id, CaseNumber, Status, Email_Alert_Trigger__c, CCD_Auto_Email_Sent__c, 
					Notification_Type__c, Future_Processing_Date__c, To_Email_Address__c, Call_Outcome__c, 
					Attempted_Contact__c, Request_Category__c, WasReopened__c, CCD_Status__c, CreatedDate, 
					CCD_Final_Notice_Sent__c, System_Hold_Code__c, Membership_Auto_Renewal_Order__c, 
					RH_Order_Number__c, RH_Order_Number__r.Name, RH_Order_Number__r.Order_Type_Code__c, 
					RH_Order_Number__r.Sold_to_Email__c, RH_Order_Number__r.Sold_to_First_Name__c, 
					RH_Order_Number__r.Sold_to_Last_Name__c, RH_Order_Number__r.Number_of_Order_Lines__c, 
					RH_Order_Number__r.Membership_ID_Lookup__c, RH_Order_Number__r.Alternate_Order_Number__c 
					from Case where Id in :caseIds and IsClosed = false and WasReopened__c = false];
			
            // Guard against the possiblity of duplicate Credit Card Declines cases
            Set<Id> oIds = new Set<Id>();
            for (Case c :caseList) {
                oIds.add(c.RH_Order_Number__c);
            }
            
            Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
            List<Case> existingCases = new List<Case>();
            existingCases = [select Id, CaseNumber, Status, Email_Alert_Trigger__c, CCD_Auto_Email_Sent__c, 
					Notification_Type__c, Future_Processing_Date__c, To_Email_Address__c, Call_Outcome__c, 
					Attempted_Contact__c, Request_Category__c, WasReopened__c, CCD_Status__c, CreatedDate, 
					CCD_Final_Notice_Sent__c, System_Hold_Code__c, Membership_Auto_Renewal_Order__c, 
					RH_Order_Number__c, RH_Order_Number__r.Name, RH_Order_Number__r.Order_Type_Code__c, 
					RH_Order_Number__r.Sold_to_Email__c, RH_Order_Number__r.Sold_to_First_Name__c, 
					RH_Order_Number__r.Sold_to_Last_Name__c, RH_Order_Number__r.Number_of_Order_Lines__c, 
					RH_Order_Number__r.Membership_ID_Lookup__c, RH_Order_Number__r.Alternate_Order_Number__c 
					from Case where RH_Order_Number__c in :oIds and Id not in :caseIds 
					and RecordTypeId = :rtMap.get('Credit Card Declines').getRecordTypeId() and IsClosed = false and WasReOpened__c = false];
            
            List<Case> deleteCases = new List<Case>();
            Map<Id, Case> oCaseMap = new Map<Id, Case>();
            for (Case c :caseList) {
                if (!oCaseMap.containsKey(c.RH_Order_Number__c)) {
                    oCaseMap.put(c.RH_Order_Number__c, c);
                } else {
                    if (c.CreatedDate < oCaseMap.get(c.RH_Order_Number__c).CreatedDate) {
                        deleteCases.add(oCaseMap.get(c.RH_Order_Number__c));
                        oCaseMap.put(c.RH_Order_Number__c, c);
                    } else {
                        deleteCases.add(c);
                    }
                }
            }
            
            for (Case c :existingCases) {
                if (oCaseMap.containsKey(c.RH_Order_Number__c)) {
                    if (c.CreatedDate <= oCaseMap.get(c.RH_Order_Number__c).CreatedDate) {
                        deleteCases.add(oCaseMap.get(c.RH_Order_Number__c));
                        oCaseMap.remove(c.RH_Order_Number__c);
                    }
                }
            }
            
            // Build map of membership records
            Set<Id> mIds = new Set<Id>();
            for (Case c :oCaseMap.values()) {
            	if (c.RH_Order_Number__r.Membership_ID_Lookup__c != null) {
            		mIds.add(c.RH_Order_Number__r.Membership_ID_Lookup__c);
            	}
            }
            Map<Id, Membership__c> membershipMap = new Map<Id, Membership__c>([select Id, Name, AutoRenew_CCD_Order_Number__c, Cancellation_Reason__c, Cancellation_Type__c from Membership__c where Id in :mIds]);
            
        
            // Send out credit card decline notification for each case that meets the automatic email criteria
			Set<Id> ccdAutoIds = new Set<Id>();
			List<Membership__c> membershipUpList = new List<Membership__c>();
			String ccdStatus;
			Membership__c mem;
            for (Case c :oCaseMap.values()) {
				
				if (c.Attempted_Contact__c == null) {
					c.Attempted_Contact__c = 0;
				}
				
                if (c.CCD_Auto_Email_Sent__c == null) {
                	c.CCD_Auto_Email_Sent__c = 0;
                }
				
				if (isCCDAutoProcess(c) && Utility.isValidDomain(c.RH_Order_Number__r.Sold_to_Email__c)) {
					
					// Notify customer via automatic email
					ccdStatus = 'In Progress';
					mem = ccdMembership(c, ccdStatus, membershipMap);
					if (mem != null) {
						membershipUpList.add(mem);
					}
					c.CCD_Status__c = ccdStatus;
					c.Request_Category__c = 'Automatic Email';
					c.To_Email_Address__c = c.RH_Order_Number__r.Sold_to_Email__c;
					c.Attempted_Contact__c++;
					c.Call_Outcome__c = 'Sent Email';
					c.CCD_Auto_Email_Sent__c++;
					c.Email_Alert_Trigger__c = true;
					
					// Determine which notification to send
					c.Notification_Type__c = 'Credit Card Declines - 1st Notice';
					if (c.CCD_Auto_Email_Sent__c == 2) {
						if (c.System_Hold_Code__c != 'AT') {
							c.Notification_Type__c = 'Credit Card Declines - Final Notice';
						} else {
							c.Notification_Type__c = 'Credit Card Declines - 2nd Notice';
						}
					} else {
						if (c.CCD_Auto_Email_Sent__c > 2) {
							c.Notification_Type__c = 'Credit Card Declines - Final Notice';
						}
					}
					
					if (c.Notification_Type__c == 'Credit Card Declines - Final Notice') {
						c.CCD_Final_Notice_Sent__c = true;
					}
					
					// Set subject line of CCD email
					Map<String, CreditCardDeclineEmail__c> ccdEmailMap = CreditCardDeclineEmail__c.getAll();
					String noticeType = c.Notification_Type__c.substringAfter('Credit Card Declines - ');
					if (c.RH_Order_Number__r.Order_Type_Code__c == 'Z') {
						noticeType += ' - Contract';
					} else {
						if (c.Membership_Auto_Renewal_Order__c) {
							noticeType += ' - Membership';
						} else {
							noticeType += ' - Regular';
						}
					}
					c.CCD_Email_Subject__c = ccdEmailMap.get(noticeType).Subject__c;
					if (ccdEmailMap.get(noticeType).Include_Order_Number__c) {
						c.CCD_Email_Subject__c += c.RH_Order_Number__r.Name;
					}
					
					ccdAutoIds.add(c.Id);
					
				} else {
					
					// We are not ready to process CCD case automatically, determine next steps
					if (c.RH_Order_Number__r.Number_of_Order_Lines__c == 0 && String.isBlank(c.CCD_Status__c)) {
						ccdStatus = 'Pending';
						mem = ccdMembership(c, ccdStatus, membershipMap);
						if (mem != null) {
							membershipUpList.add(mem);
						}
						c.CCD_Status__c = ccdStatus;
						c.Request_Category__c = 'Automatic Email';
						c.Future_Processing_Date__c = system.today().addDays(2);
					} else {
						if (c.RH_Order_Number__r.Number_of_Order_Lines__c > 0) {
							ccdStatus = 'In Progress';
							mem = ccdMembership(c, ccdStatus, membershipMap);
							if (mem != null) {
								membershipUpList.add(mem);
							}
							c.CCD_Status__c = ccdStatus;
						}
						
						// Customer must be contacted by phone
						c.Request_Category__c = 'Callout';
					}
					
					c.Email_Alert_Trigger__c = false;
				}
			}
			
			// Cause all automatic notifications to be sent (via workflow/email alert)
			update oCaseMap.values();
            
            // Verify that automatic notifications were successfully sent and attach copy of email to case
            if (!ccdAutoIds.isEmpty()) {
				Blob pageContent;
				List<Attachment> attList = new List<Attachment>();
				List<Case> ccdFailList = new List<Case>();
				List<Case> ccdAutoList = new List<Case>();
				ccdAutoList = [select Id, CaseNumber, Email_Alert_Trigger__c, Request_Category__c, Call_Outcome__c, Notification_Type__c, To_Email_Address__c from Case where Id in :ccdAutoIds];
				
				for (Case c :ccdAutoList) {
					
					if (c.Email_Alert_Trigger__c) {
						
						// Email failed to send
						c.Email_Alert_Trigger__c = false;
						c.Call_Outcome__c = 'Failed To Send Email';
						c.Request_Category__c = 'Callout';
						ccdFailList.add(c);
						
					} else {
						
						system.debug('*****CreditCardDeclineNotifications notificationType = ' + c.Notification_Type__c);
						
						// Email sent, prepare copy as an attachment
						if (!Test.isRunningTest()) {
							pageContent = new PageReference('/apex/CreditCardDeclineHTML?caseId=' + c.Id + '&notificationType=' + c.Notification_Type__c).getContent();
						} else {
							pageContent = Blob.valueOf('Test Class');
						}
						
						attList.add(new Attachment(
							ParentId = c.Id,
							Name = c.Notification_Type__c + ': automatic.html',
							ContentType = 'html',
							Body = pageContent,
							Description = 'System Generated Attachment'
								+ '\nNotification sent automatically: ' + c.Notification_Type__c 
								+ '\nToAddress = ' + c.To_Email_Address__c
								+ '\nSend Date/Time = ' + String.valueOf(system.now()))
						);
					}
				}
				
				if (!attList.isEmpty()) {
					insert attList;
				}
				
				if (!ccdFailList.isEmpty()) {
					update ccdFailList;
				}
            }
            
            // Update membership records to reflect CCD state
            if (!membershipUpList.isEmpty()) {
            	update membershipUpList;
            }
            
			// Delete any duplicate CCD cases
			if (!deleteCases.isEmpty()) {
				delete deleteCases;
			}
		}
	}
}