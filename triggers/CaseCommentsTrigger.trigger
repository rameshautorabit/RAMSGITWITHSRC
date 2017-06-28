trigger CaseCommentsTrigger on Case_Comments__c (after insert, after update, after delete) {
	
	/*
	 *	Update various fields on the Case, Case Line, Order, and Order Line based upon the Case Comment
	 *	record(s) that is being inserted, updated or deleted.
	 *
	 */	 
	
	Boolean updateOrders = false;
	List<Id> cIds = new List<Id>();
	
	Map<String, CallOutcomeToCount__c> callOutComeMap = CallOutcomeToCount__c.getAll();
	
	if (trigger.isDelete) {
		for (Case_Comments__c cc :trigger.old) {
			if (cc.Case__c != null) {
				cIds.add(cc.Case__c);
			}
		}
	} else {
		for (Case_Comments__c cc :trigger.new) {
			if (cc.Case__c != null) {
				cIds.add(cc.Case__c);
				if (cc.Call_Outcome__c == 'Sent Email' || cc.Call_Outcome__c == 'Talked to Client'  || cc.Call_Outcome__c == 'Left Voicemail') {
					updateOrders = true;
				}
			}
		}
	}	
	
	if (!cIds.isEmpty()) {
		Map<Id, RH_Order__c> oUpMap = new Map<Id, RH_Order__c>();
		Map<Id, Order_Line_Items__c> oliMap = new Map<Id, Order_Line_Items__c>();
		List<Case_Line_Items__c> cliUpList = new List<Case_Line_Items__c>();
		Map<Id, Case> cMap = new Map<Id, Case>([select Id, Action_Required__c, Attempted_Contact__c, Call_Outcome__c, no_of_case_comments__c, 
				RecordTypeId, RH_Order_Number__c, System_Hold_Code__c, Request_Category__c, WasReopened__c from Case where Id in :cIds]);
		
		if (trigger.isInsert) {
			
			Map<Id, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById();
			//Id caseDNRecordTypeId = '012500000009tdy';
			List<Id> cDNIds = new List<Id>();
			Map<Id, RH_Order__c> oMap;
			List<Id> oIds = new List<Id>();
			
			if (updateOrders) {
				for (Case c :cMap.values()) {
					oIds.add(c.RH_Order_Number__c);
					if (rtMap.containsKey(c.RecordTypeId) && rtMap.get(c.RecordTypeId).getName() == 'Delay Notifications' && c.WasReopened__c == false) {
						cDNIds.add(c.Id);
					}
				}
				oMap = new Map<Id, RH_Order__c>([select Id, Callout_Contacts__c, Email_Contacts__c from RH_Order__c where Id in :oIds]);
			}
			
			for (Case_Comments__c cc :trigger.new) {
				
				if (cMap.containsKey(cc.Case__c)) {
					
					// update action required
					if (cc.Action_Required__c) {
						cMap.get(cc.Case__c).Action_Required__c = true;
					}
					
					// update the count of the number of case comment records
					if (cMap.get(cc.Case__c).no_of_case_comments__c == null) {
						cMap.get(cc.Case__c).no_of_case_comments__c = 0;
					}
					cMap.get(cc.Case__c).no_of_case_comments__c++;
					
					// update the number of unsuccessful attempted contacts
					if (callOutComeMap.containsKey(cc.Call_Outcome__c)) {
						if (cMap.get(cc.Case__c).Attempted_Contact__c == null) {
							cMap.get(cc.Case__c).Attempted_Contact__c = 0;
						}
						cMap.get(cc.Case__c).Attempted_Contact__c++;
						
						// Prepare to send the CCD final notice email for System Hold Code != AT
						if (rtMap.containsKey(cMap.get(cc.Case__c).RecordTypeId) && rtMap.get(cMap.get(cc.Case__c).RecordTypeId).getName() == 'Credit Card Declines') {
							if (cMap.get(cc.Case__c).Attempted_Contact__c == 3 && cMap.get(cc.Case__c).System_Hold_Code__c != 'AT') {
								cMap.get(cc.Case__c).Request_Category__c = 'Automatic Email';
							}
						}
					}
					
					// update the call outcome and the number of successful customer contacts
					if (cc.Call_Outcome__c != null) {
						cMap.get(cc.Case__c).Call_Outcome__c = cc.Call_Outcome__c;
						
						if (updateOrders && !oMap.isEmpty()) {
							// update the related order customer contact fields
							if (oMap.containsKey(cMap.get(cc.Case__c).RH_Order_Number__c) && rtMap.containsKey(cMap.get(cc.Case__c).RecordTypeId) && rtMap.get(cMap.get(cc.Case__c).RecordTypeId).getName() == 'Delay Notifications') {
								if (cMap.get(cc.Case__c).Call_Outcome__c == 'Talked to Client' || cMap.get(cc.Case__c).Call_Outcome__c == 'Left Voicemail') {
									if (oMap.get(cMap.get(cc.Case__c).RH_Order_Number__c).Callout_Contacts__c == null) {
										oMap.get(cMap.get(cc.Case__c).RH_Order_Number__c).Callout_Contacts__c = 0;
									}
									oMap.get(cMap.get(cc.Case__c).RH_Order_Number__c).Callout_Contacts__c++;
									oUpMap.put(oMap.get(cMap.get(cc.Case__c).RH_Order_Number__c).Id, oMap.get(cMap.get(cc.Case__c).RH_Order_Number__c));
								}
								if (cMap.get(cc.Case__c).Call_Outcome__c == 'Sent Email') {
									if (oMap.get(cMap.get(cc.Case__c).RH_Order_Number__c).Email_Contacts__c == null) {
										oMap.get(cMap.get(cc.Case__c).RH_Order_Number__c).Email_Contacts__c = 0;
									}
									oMap.get(cMap.get(cc.Case__c).RH_Order_Number__c).Email_Contacts__c++;
									oUpMap.put(oMap.get(cMap.get(cc.Case__c).RH_Order_Number__c).Id, oMap.get(cMap.get(cc.Case__c).RH_Order_Number__c));
								}
							}
						}
					}
				}
			}
			
			// Update the order line availability date communicated to customer and the Case Line Interim Update field for all Delay Notifications cases
			if (!oUpMap.isEmpty() && !cDNIds.isEmpty()) {
				List<Case_Line_Items__c> cliList = new List<Case_Line_Items__c>();
				cliList = [select Id, Case_Number__c, Line_Number__c, Order__c, Current_Available_Date__c, Interim_Update__c, IsStaleDate__c 
							from Case_Line_Items__c where Case_Number__c in :cDNIds and Order__c in :oUpMap.keySet() and Delay_Notification_Type__c != 'Invalid'];
				List<Id> oliIds = new List<Id>();
				for (Case_Line_Items__c cli :cliList) {
					oliIds.add(cli.Line_Number__c);
				}
				oliMap = new Map<Id, Order_Line_Items__c>([select Id, Current_Available_Date__c, Current_Delay_Date__c from Order_Line_Items__c where Id in :oliIds]);
				for (Case_Line_Items__c cli :cliList) {
					if (cli.Current_Available_Date__c != null) {
						oliMap.get(cli.Line_Number__c).Current_Available_Date__c = cli.Current_Available_Date__c;
					} else {
						if (oliMap.get(cli.Line_Number__c).Current_Delay_Date__c != null) {
							oliMap.get(cli.Line_Number__c).Current_Available_Date__c = oliMap.get(cli.Line_Number__c).Current_Delay_Date__c;
						}
					}
					
					// Update the Interim Update field on the Case Line
					if (cMap.get(cli.Case_Number__c).Call_Outcome__c == 'Talked to Client' || cMap.get(cli.Case_Number__c).Call_Outcome__c == 'Left Voicemail') {
						if (cli.IsStaleDate__c) {
							if (cli.Interim_Update__c == 'Ready for Callout') {
								cli.Interim_Update__c = 'Contact Date Communicated';
								cliUpList.add(cli);
							}
							if (String.isBlank(cli.Interim_Update__c)) {
								cli.Interim_Update__c = 'Waiting for Planning';
								cliUpList.add(cli);
							}
						}
					}
				}
			}
		}
		
		if (trigger.isUpdate) {
			
			for (Case_Comments__c cc :trigger.new) {
				
				if (cMap.containsKey(cc.Case__c)) {
					
					// update action required
					if (cc.Action_Required__c != trigger.oldMap.get(cc.Id).Action_Required__c && cc.Action_Required__c) {
						cMap.get(cc.Case__c).Action_Required__c = true;
					}
					
					// update the number of unsuccessful attempted contacts
					if (cc.Call_Outcome__c != trigger.oldMap.get(cc.Id).Call_Outcome__c) {
						if (cMap.get(cc.Case__c).Attempted_Contact__c == null) {
							cMap.get(cc.Case__c).Attempted_Contact__c = 0;
						}
						if (callOutComeMap.containsKey(trigger.oldMap.get(cc.Id).Call_Outcome__c)) {
							if (!callOutComeMap.containsKey(cc.Call_Outcome__c)) {
								if (cMap.get(cc.Case__c).Attempted_Contact__c > 0) {
									cMap.get(cc.Case__c).Attempted_Contact__c--;
								}
							}
							
						} else {
							if (callOutComeMap.containsKey(cc.Call_Outcome__c)) {
								cMap.get(cc.Case__c).Attempted_Contact__c++;
							}
						}
					}
				}
			}
		}
		
		if (trigger.isDelete) {
			
			for (Case_Comments__c cc :trigger.old) {
				
				if (cMap.containsKey(cc.Case__c)) {
					
					// update the count of the number of case comment records
					if (cMap.get(cc.Case__c).no_of_case_comments__c == null) {
						cMap.get(cc.Case__c).no_of_case_comments__c = 1;
					}
					cMap.get(cc.Case__c).no_of_case_comments__c--;
				}
			}
		}
		
		try {
			if (!oUpMap.isEmpty()) {
				update oUpMap.values();
			}
			if (!oliMap.isEmpty()) {
				update oliMap.values();
			}
			if (!cMap.isEmpty()) {
				update cMap.values();
			}
			if (!cliUpList.isEmpty()) {
				update cliUpList;
			}
		} catch(DmlException e) {
			System.debug('*****CaseCommentsTrigger exception = ' + e.getMessage());	
		}
	}
}

/*
 *	Original trigger written by ForeFront - works with UpdateCaseFromCaseComments.cls.  Trigger
 *	was rewritten to make it more efficient and reduce the number of queries executed.
 *
 
trigger CaseCommentsTrigger on Case_Comments__c(after insert,after update, after delete) 
{
    List<Id> lstOfCaseIds=new List<Id>();
    Map<Id,Boolean> mOfCids=new Map<Id,Boolean>();
    Set<String> lstOfCallOutcomes=new Set<String>();
    List<Id> lstOfCIds=new List<Id>();
    Map<Id,Id> mapCCToCase=new Map<Id,Id>();
    
    if(trigger.isInsert && trigger.isAfter)
    {
        List<CallOutcomeToCount__c> callOutCome=[SELECT Id, Name FROM CallOutcomeToCount__c];
        for(CallOutcomeToCount__c c: callOutCome)
        {
            lstOfCallOutcomes.add(c.Name);
        }
                
        for(Case_Comments__c c:trigger.new)
        {
            //Check if the Action required field is checked
            if(c.Action_Required__c==true && c.Case__c!=null)
            {
                lstOfCaseIds.add(c.Case__c);
            }
            
            //Check if Case if null; To Increment the number of comments on Case
            if(c.Case__c!=null)
            {
                mOfCids.put(c.Case__c,true);
            }
            
            if(c.Case__c!=null && lstOfCallOutcomes.contains(c.Call_Outcome__c))
            {
                lstOfCIds.add(c.Case__c);
            }
            
            if(c.Case__c!=null)
            {
                mapCCToCase.put(c.Id,c.Case__c);
            }
            
        }
        
    }
    
    if(trigger.isUpdate && trigger.isAfter)
    {
        List<CallOutcomeToCount__c> callOutCome=[SELECT Id, Name FROM CallOutcomeToCount__c];
        for(CallOutcomeToCount__c c: callOutCome)
        {
            lstOfCallOutcomes.add(c.Name);
        }
        
        for(Case_Comments__c c:trigger.new)
        {
            Case_Comments__c cOld=trigger.oldMap.get(c.Id);
            //Check if the Action required field is checked
            if(cold.Action_Required__c!=c.Action_Required__c && c.Action_Required__c==true && c.Case__c!=null)
            {
                lstOfCaseIds.add(c.Case__c);
            }
            
            if(cOld.Call_Outcome__c!=c.Call_Outcome__c && c.Case__c!=null && lstOfCallOutcomes.contains(c.Call_Outcome__c) )
            {
                lstOfCIds.add(c.Case__c);
            }
        }
    }
    
    if(trigger.isDelete && trigger.isAfter)
    {
        for(Case_Comments__c c:trigger.old)
        {
            //Check if Case if null; To Increment the number of comments on Case
            if(c.Case__c!=null)
            {
                mOfCids.put(c.Case__c,false);
            }
        }
    }
    
    if(lstOfCaseIds.size()>0)
    {
        UpdateCaseFromCaseComments.UpdateCase(lstOfCaseIds);
    }
    System.debug(mOfCids);
    if(mOfCids.size()>0)
    {
        UpdateCaseFromCaseComments.UpdateNoOfComments(mOfCids); 
    }
    
    //Calls method to update the Attempted Count field on a Case
    if(lstOfCIds.size()>0)
    {
        UpdateCaseFromCaseComments.UpdateAttemptedCount(lstOfCIds); 
        
    }
    
    if(mapCCToCase.size()>0)
    {
        UpdateCaseFromCaseComments.UpdateCaseCallOutcome(mapCCToCase);  
    }
    
}
*/