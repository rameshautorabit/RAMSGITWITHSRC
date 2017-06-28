/*
    Class: CaseService
    
    Developer: neeraj@persistent.com on 05/23/2017 -- Made changes for release 17.07-SRS-1960 to fix Case lock/unlock functionality for all closed cases
    
*/
public without sharing class CaseService {
	  
	public static void processEmailWebOrderNumber(List<Case> cases){
        Set<String> orderNumber = new Set<String>();
        for(Case c:cases){
            if(c.RecordTypeId == Utility.getRecordTypeId(Case.sObjectType, 'Email and Web Inquiries')){
                if (c.RH_Order_Number__c == null && String.isNotBlank(c.Order_Number__c)) {
                	if (c.Order_Number__c.isNumeric() && c.Order_Number__c.length() <= 8) {
                		orderNumber.add(c.Order_Number__c);
                	}
                }
            }
        }
        Map<String, RH_Order__c> orderMap = new Map<String, RH_Order__c>();
        if(!orderNumber.isEmpty()){
            for(RH_Order__c o:[SELECT Id, Name from RH_Order__c where Name in :orderNumber]){
               orderMap.put(o.Name, o);
            }           
        }
        for(Case c:cases){
             if(orderMap.ContainsKey(c.Order_Number__c)){
                c.RH_Order_Number__c = orderMap.get(c.Order_Number__c).Id;
             }
        }
	}
		
	public static void updateCaseStatusTransfer(List<Case> cases) {
		String opQId = Groups__c.getInstance('Order Processing Queue').GroupId__c;
		String contractQId = Groups__c.getInstance('Contract Case Queue').GroupId__c;
        Map<Id, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById();
		
		// Set ownership of the Credit Card Declines cases to the appropriate queue upon insert
		for (Case c :cases) {
            if (rtMap.containsKey(c.RecordTypeId) && rtMap.get(c.RecordTypeId).getName() == 'Credit Card Declines') {
               c.OwnerId = opQId;
                if (c.Order_Type_Code__c == 'Z') {
                	c.OwnerId = contractQId;
                }
            }
        } 
    }
    
	public static void processDeclinedCreditCardCases(List<Case> cases){   
        Map<Id, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById();
        Set<Id> caseIdsCCDecline = new Set<Id>();
		
        for (Case c :cases) {
            if(rtMap.containsKey(c.RecordTypeId) && rtMap.get(c.RecordTypeId).getName() == 'Credit Card Declines') {
                caseIdsCCDecline.add(c.Id);             
            }
        }
        // Process any needed Credit Card Decline notifications
        if (!caseIdsCCDecline.isEmpty()) {
           CreditCardDeclineNotifications.ccDeclineNotifications(caseIdsCCDecline);
        }
    }    
    
	public static void populateOrderInformation(List<Case> cases, Map<Id, Case> oldMap, Boolean isInsert){
		List<Case> caseOrderList = new List<Case>();
		List<Case> CaseShipTolist=new List<Case>();
		Set<Id> ShipToOrderIds=new Set<Id>();
		
		// If the Order Number field has changed and is non-null, set to populate Case fields from Order
		for(Case c:cases){
			CaseShipTolist.add(c);
			ShipToOrderIds.add(c.RH_Order_Number__c);
			if ((isInsert && c.RH_Order_Number__c != null)
				|| (!isInsert 
					&& Utility.isChanged(String.valueOf(oldMap.get(c.Id).RH_Order_Number__c), String.valueOf(c.RH_Order_Number__c)) 
					&& c.RH_Order_Number__c != null)) {
				caseOrderList.add(c);
			}
		}
		
		if(!CaseShipTolist.isEmpty()){
			UpdateCase.populateOrderShipToOnCase(CaseShipTolist,ShipToOrderIds);
		}
		
		// Method call to populate Order Information on a Case
		if (!caseOrderList.isEmpty()) {
			UpdateCase.populateOrderInformation(caseOrderList, IsInsert);
		}    
	}
    
    public static void defaultCaseFields(List<Case> cases, Map<Id, Case> oldMap){
        Map<Id, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById();
        
        //Fetch all closed statuses for case object
        set<String> closedStatuses = getCaseClosedStatuses();
                
        for(Case c:cases){
           // Set the Order Type Category for all Delay Notifications cases     
           if (rtMap.containsKey(c.RecordTypeId) 
               && rtMap.get(c.RecordTypeId).getName() == 'Delay Notifications' 
               && c.RH_Order_Number__c != null) {
               
               // Set Order Type Category and Gift Card Status if case is closing, for all Delay Notifications cases
               c.Order_Type_Category__c = DelayedOrderActions.getOrderTypeCategory(c.Order_Type_Code__c);
               if (c.Status == 'Closed - Successful' || c.Status == 'Closed - Unsuccessful' || c.Status == 'Closed - Created in Error' || c.Status == 'Closed - Invalid' || c.Status == 'Closed') {
                  if (c.Gift_Card_Status__c == 'Pending') {
                     c.Gift_Card_Status__c = 'Complete';
                  }
               }
           }
           
           //Set the Action Required field to false if the Case status changes from Re-Open to any other Status
           if(Utility.isChanged(oldMap.get(c.Id).Status, c.Status) 
              && oldMap.get(c.Id).Status == 'Re-Open')
           {
              c.Action_Required__c=false; 
           }
           
           //Release17.07-SRS-1960: Re-open case for all closed statuses
           if(Utility.isChanged(String.valueOf(oldMap.get(c.Id).Action_Required__c), String.valueOf(c.Action_Required__c)) 
              && c.Action_Required__c  
              && closedStatuses.contains(oldMap.get(c.Id).Status) ){
              	c.Status = 'Re-open';
              	c.WasReopened__c = true;
           }
        }   
    }
    
    public static void processCaseLocks(List<Case> cases, Map<Id, Case> oldMap){
    	Map<Id, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById();
    	
        List<Id> casesToLock=new List<Id>();
        
        //Fetch all closed statuses for case object  //
        set<String> closedStatuses = getCaseClosedStatuses();
        
        // Submit Approval process for Locking the Case
        //Release17.07-SRS-1960: Record will be locked for all closed statuses except 'Email and Web Inquiries' case record type
        for(Case c: cases){
            if( rtMap.containsKey(c.RecordTypeId) && !(rtMap.get(c.RecordTypeId).getName() == 'Email and Web Inquiries')
               && Utility.isChanged(oldMap.get(c.Id).Status, c.Status)
               && closedStatuses.contains(c.Status)
               && !c.Submitted_for_Lock__c)
            {
                casesToLock.add(c.Id);
            }
         }
         if(!casesToLock.isEmpty()){
            UpdateCase.lockCaseRecord(casesToLock);
         }      
    }
    
    public static void processCaseUnlocks(List<Case> cases, Map<Id, Case> oldMap){
        List<Id> casesIds = new List<Id>();
        //Reject the approval requests to unlock Cases that are Re-opened
        for(Case c:cases){ 
            if(Utility.isChanged(oldMap.get(c.Id).Status, c.Status)
               && c.Status == 'Re-Open' 
               && c.Submitted_for_Lock__c)
            {
                casesIds.add(c.Id);
            }
        }
        if(!casesIds.isEmpty()){
            UpdateCase.unlockCaseRecord(casesIds);
            UpdateCase.unlockCaseLinesRecord(casesIds);
        }       
    }
    
    // If Credit Card Declines case is not closed, check to see if an email notification needs to be sent.
    // If Credit Card Declines case is closed unsuccessful and it is for an auto membership renewal, update the membership record
    // - after update
    public static void creditCardDecline(Map<Id, Case> newMap, Map<Id, Case> oldMap){
        
        Set<Id> caseIdsCCDecline = new Set<Id>();
        Set<Id> oIds = new Set<Id>();
        Map<Id, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById();
        
        for (Case c :newMap.values()) {
        	if (rtMap.get(c.RecordTypeId).getName() == 'Credit Card Declines') {
        		
        		if (!c.IsClosed) {
        			
        			if (c.CCD_Status__c == 'Pending' && c.Number_of_Order_Lines__c > 0) {
        				caseIdsCCDecline.add(c.Id);
        			}
        			
        			if (c.Attempted_Contact__c != oldMap.get(c.Id).Attempted_Contact__c && c.Attempted_Contact__c == 3) {
						if ( (c.Order_Type_Code__c != 'Z') && (c.System_Hold_Code__c != 'AT') && 
							 (c.Call_Outcome__c == 'Could Not Reach' || c.Call_Outcome__c == 'Left Voicemail' || c.Call_Outcome__c == 'Sent Email') ) {
							caseIdsCCDecline.add(c.Id);
							system.debug('*****CaseTrigger - adding Case Number/Id to CCDecline processing: ' + c.CaseNumber + '/' + c.Id + ' AttemptedContact = ' + c.Attempted_Contact__c);
						}
					}
        		
        		} else {
        			
        			if (c.Status == 'Closed - Unsuccessful' && oldMap.get(c.Id).Status != 'Closed - Unsuccessful') {
        				if (c.Membership_Auto_Renewal_Order__c) {
        					oIds.add(c.RH_Order_Number__c);
        				}
        			}
        			
        		}
        	}
        }
        
        // Send out email notifications
        if (!caseIdsCCDecline.isEmpty()) {
           CreditCardDeclineNotifications.ccDeclineNotifications(caseIdsCCDecline);
        }
        
        // Update membership records
        if (!oIds.isEmpty()) {
        	List<RH_Order__c> orderList = new List<RH_Order__c>();
        	orderList = [select Id, Name, Membership_ID_Lookup__c from RH_Order__c where Id in :oIds];
        	
        	Set<Id> mIds = new Set<Id>();
        	for (RH_Order__c o :orderList) {
        		if (o.Membership_ID_Lookup__c != null) {
        			mIds.add(o.Membership_ID_Lookup__c);
        		}
        	}
        	
        	List<Membership__c> memberList = new List<Membership__c>();
        	memberList = [select Id, Name, AutoRenew_CCD_Order_Number__c, Cancellation_Reason__c, Cancellation_Type__c from Membership__c where Id in :mIds];
        	
        	for (Membership__c m :memberList) {
        		m.Cancellation_Reason__c = 'Credit card decline';
        		m.Cancellation_Type__c = 'RH Terminated';
        		m.AutoRenew_CCD_Order_Number__c = '';
        	}
        	
        	if (!memberList.isEmpty()) {
        		update memberList;
        	}
        }
    }
    
    public static void decrementReorderCount(Map<Id, Case> newMap, Map<Id, Case> oldMap){
        // Decrement the Reorder Count on Order Lines that are associated with Case Line Items 
        // of Reorders Cases that have just been closed (only some close states).
		Set<Id> cIds = new Set<Id>();
		Set<Id> oliIds = new Set<Id>();
		for (Case c :newMap.values()) {
			if (c.Status != oldMap.get(c.Id).Status && 
				(c.Status == 'Closed - Unsuccessful' || c.Status == 'Closed - Created in Error' || c.Status == 'Closed - Invalid')) {
				cIds.add(c.Id);
			}
		}
		
		if (!cIds.isEmpty()) {
			List<Case_Line_Items__c> cliList = new List<Case_Line_Items__c>();
            cliList = [select Id, Line_Number__c from Case_Line_Items__c where Case_Number__c in :cIds];
            for (Case_Line_Items__c cli :cliList) {
                if (cli.Line_Number__c != null) {
                    oliIds.add(cli.Line_Number__c);
                }
            }
            if (!oliIds.isEmpty()) {
                List<Order_Line_Items__c> oliList = new List<Order_Line_Items__c>();
                oliList = [select Id, Reorder_Count__c from Order_Line_Items__c where Id in :oliIds];
                for (Order_Line_Items__c oli :oliList) {
                    if (oli.Reorder_Count__c != null) {
                        oli.Reorder_Count__c = oli.Reorder_Count__c - 1;
                    }
                    if (oli.Reorder_Count__c == null || oli.Reorder_Count__c < 2) {
                        oli.Reorder_Count__c = 0;
                    }
                }
                if (!oliList.isEmpty()) {
                    system.debug('*****CaseTrigger update Reorder Count on ' + oliList.size() + ' order lines');
                    update oliList;
                }
            }
		}
    }
    
	// If case is being transferred, verify that it is ready to be transferred - called from before update trigger
	public static void verifyCaseTransfer(Map<Id, Case> newMap, Map<Id, Case> oldMap) {
		Map<String, CaseToCaseLineRecordTypes__c> crtMap = CaseToCaseLineRecordTypes__c.getAll();
		Map<Id, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById();
		Map<Id, Case> cMap = new Map<Id, Case>();
		
		for (Case c :newMap.values()) {
			if (c.OwnerId != oldMap.get(c.Id).OwnerId) {
				if (rtMap.containsKey(c.RecordTypeId) && crtMap.containsKey(rtMap.get(c.RecordTypeId).getName()) ) {
					cMap.put(c.Id, c);
				}
			}
		}
		
		if (!cMap.isEmpty()) {
			List<Case_Line_Items__c> cliList = new List<Case_Line_Items__c>();
			cliList = [select Id, Case_Number__c, Status__c from Case_Line_Items__c where Case_Number__c in :cMap.keySet()];
			
			Boolean transferError;
			for (Case c :cMap.values()) {
				transferError = false;
				if (c.Status == 'New' && crtMap.get(rtMap.get(c.RecordTypeId).getName()).Case_Required_Fields__c) {
					transferError = true;
				} else {
					if (crtMap.get(rtMap.get(c.RecordTypeId).getName()).Case_Line_Required_Fields__c) {
						for (Case_Line_Items__c cli :cliList) {
							if (cli.Status__c == 'New') {
								transferError = true;
							}
						}
					}
				}
				if (transferError) {
					newMap.get(c.Id).addError('Cannot transfer Case until required fields are completed on the Case and Case Line Item records.');
				}
			}
		}
		
	}
	
	// Set the Opportunity PM field on certain case record types
	public static void populateOpportunityPM(List<Case> cases, Map<Id, Case> oldMap, Boolean isInsert) {
		Set<Id> oppIds = new Set<Id>();
		Map<Id, Schema.RecordTypeInfo> rtByIdMap = Schema.SObjectType.Case.getRecordTypeInfosById();
		
		for (Case c :cases) {
			if ( rtByIdMap.containsKey(c.RecordTypeId) && 
				 (rtByIdMap.get(c.RecordTypeId).getName() == 'Credit Card Declines' || 
				  rtByIdMap.get(c.RecordTypeId).getName() == 'Delay Notifications' ||
				  rtByIdMap.get(c.RecordTypeId).getName() == 'Contract')) {
			
				if (isInsert) {
					if (c.Opportunity_del__c != null) {
						oppIds.add(c.Opportunity_del__c);
					} else {
						c.Opportunity_PM__c = null;
					}
					
				} else {
					
					if (c.Opportunity_del__c != oldMap.get(c.Id).Opportunity_del__c) {
						if (c.Opportunity_del__c != null) {
							oppIds.add(c.Opportunity_del__c);
						} else {
							c.Opportunity_PM__c = null;
						}
					}
				}
			}
		}
		
		if (!oppIds.isEmpty()) {
			Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([select Id, Ops_Contact__c from Opportunity where Id in :oppIds]);
			for (Case c :cases) {
				if (oppMap.containsKey(c.Opportunity_del__c)) {
					c.Opportunity_PM__c = oppMap.get(c.Opportunity_del__c).Ops_Contact__c;
				}
			}
		}
	}
	
	// Verify that a case meets all requirements for being closed.
	// - Contract cases must have at least one Resolution record (Investment__c) associated with it before closing.
	// - If closing a CCD case, set CCD_Status__c to "Complete"
	// - before update
	public static void verifyCaseClose(List<Case> newList, Map<Id, Case> oldMap) {
		Map<Id, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById();
		Set<Id> cIds = new Set<Id>();
		List<Case> ccdCases = new List<Case>();
		
		for (Case c :newList) {
			if (rtMap.containsKey(c.RecordTypeId)) {
				if (rtMap.get(c.RecordTypeId).getName() == 'Contract') {
					if (c.Status == 'Closed - Successful' && c.Status != oldMap.get(c.Id).Status) {
						cIds.add(c.Id);
					}
				}
				if (rtMap.get(c.RecordTypeId).getName() == 'Credit Card Declines') {
					ccdCases.add(c);
				}
			}
		}
		
		if (!cIds.isEmpty()) {
			List<Investment__c> invList = new List<Investment__c>();
			invList = [select Id, Case__c from Investment__c where Case__c in :cIds];
			Map<Id, Investment__c> caseToInvMap = new Map<Id, Investment__c>();
			for (Investment__c inv :invList) {
				caseToInvMap.put(inv.Case__c, inv);
			}
			
			for (Case c :newList) {
				if (cIds.contains(c.Id) && !caseToInvMap.containsKey(c.Id)) {
					c.Status.addError('Contract cases must have at least one Resolution record to be closed.');
				}
			}
		}
		
		if (!ccdCases.isEmpty()) {
			List<CaseStatus> csList = new List<CaseStatus>();
			csList = [select Id, IsClosed, MasterLabel from CaseStatus];
			Map<String, CaseStatus> csMap = new Map<String, CaseStatus>();
			for (CaseStatus cs :csList) {
				csMap.put(cs.MasterLabel, cs);
			}
			
			for (Case c :ccdCases) {
				if (csMap.containsKey(c.Status) && csMap.get(c.Status).IsClosed) {
					c.CCD_Status__c = 'Complete';
				}
			}
		}
	}

	public static set<String> getCaseClosedStatuses(){
		//Fetch all closed statuses for case
        set<String> closedStatuses = new set<String>();
        for(CaseStatus cs: [select Id, IsClosed, MasterLabel from CaseStatus where IsClosed = true]){
        	closedStatuses.add(cs.MasterLabel);
        }
        return closedStatuses;
	}
	/*
	// Do not allow Exchange Approval Rejection if Exchange Approval Rejection Reason is blank
	// - before update
	public static void exchApprovalRejection(List<Case> newList) {
		
		for (Case c :newList) {
			if (c.Exchange_Approval_Status__c == 'Rejected' && String.isBlank(c.Exchange_Approval_Rejection_Reason__c)) {
				c.addError('To reject this approval request, you must first set Exchange Approval Rejection Reason on the case record.');
			}
		}
	}
	*/
}