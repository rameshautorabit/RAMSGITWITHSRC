/*
    Class: UpdateCase
    Description: This case contains a method to trigger the assignment rules for a case which is not in a New Status
    Developer: vk@ff on 07/21/2014 -- Peter Alexander Mandy 03042016 purged deprecated methods.
    Test Class: CaseTrigger_Test
    Developer:- Raghu Cheruvu on 04/26/2016, added method populateOrderShipToOnCase as part of CSC Refactoring.
*/
    
public without sharing class UpdateCase
{
    //Lock Case and associated Case Line Records
    //Added by vk@ff on 09/24/2014
    public static void lockCaseRecord(List<Id> cToLock) {
    List<Case> lstOfCases=[SELECT Id,Submitted_for_Lock__c FROM Case WHERE Id IN: cToLock and Submitted_for_Lock__c = false];
    
    List<Approval.ProcessSubmitRequest> lstOfAppReqs=new List<Approval.ProcessSubmitRequest>();
    
    if (!lstOfCases.isEmpty()) {
      for (Case c: lstOfCases) {
        // Create an approval request for Case record
        Approval.ProcessSubmitRequest req =new Approval.ProcessSubmitRequest();
        req.setComments('Lock Case Record');
        req.setObjectId(c.Id);
        lstOfAppReqs.add(req);
        c.Submitted_for_Lock__c=true;
      }
      
      try {
        update lstOfCases;  
      } catch(DmlException e) {
        System.debug(e);  
      }
      
      //Submit the approval request
      List<Approval.ProcessResult> lstOfResults=Approval.process(lstOfAppReqs,false);
      
      for (Approval.ProcessResult appvResult: lstOfResults) {
      	//System.assert(appvResult.isSuccess());
        //System.assertEquals('Pending', appvResult.getInstanceStatus(), 'Instance Status'+appvResult.getInstanceStatus());
      	
      }
      
      // Lock the Case Line records
      List<Id> lockedCaseIds = new List<Id>();
      for (Case c :lstOfCases) {
        lockedCaseIds.add(c.Id);
      }
      lockCaseLinesRecord(lockedCaseIds);
    }
  }
  
  //Unlock Case Record
  //Added by vk@ff on 09/24/2014
  
  public static void unlockCaseRecord(List<Id> cToUnlock)
  {
    try
    {
      List<Case> lstCases=[SELECT Id, Submitted_for_Lock__c FROM Case WHERE Id IN: cToUnlock];
      List<Id> lstOfAppReqIds=new List<Id>();
      
          for(Case c: lstCases)
          {
        c.Submitted_for_Lock__c=false;
        lstOfAppReqIds.add(c.Id);
      }
      
      try
      {
        update lstCases;  
      }
      catch(DmlException e)
      {
        System.debug(e.getMessage());  
      }
      
       //Reject Approval Request
      if(lstOfAppReqIds.size()>0)
      {
         Id retVal = null;
       List<Approval.ProcessWorkitemRequest> lstOfAppReq=new List<Approval.ProcessWorkitemRequest>();
        
         List<ProcessInstanceWorkitem> lstWorkItems=[Select Id from ProcessInstanceWorkitem where ProcessInstanceWorkitem.ProcessInstance.TargetObjectId IN: lstOfAppReqIds];
         
        
            for(ProcessInstanceWorkitem workItem:lstWorkItems)
            {
                // Reject the submitted request
                     
                // Instantiate the new ProcessWorkitemRequest object and populate it
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setComments('Rejecting request.');
                req.setAction('Reject');
                                      
                //Specify the item to be worked
                req.setWorkitemId(workItem.Id);
                lstOfAppReq.add(req);            
                
            }
        
        // Submit the request for rejection
            List<Approval.ProcessResult> result2 =  Approval.process(lstOfAppReq, false);
      }
    }
      
    catch(DmlException e)
    {
      System.debug(e.getMessage());  
    }
  }
  
    //Lock Record
    //Added by vk@ff on 09/16/2014
    public static void lockCaseLinesRecord(List<Id> clinesToLock)
    {
        List<Case_Line_Items__c> lstCLItems=[SELECT Id, Case_Number__c FROM Case_Line_Items__c WHERE Case_Number__c IN: clinesToLock];
        List<Approval.ProcessSubmitRequest> lstOfAppReqs=new List<Approval.ProcessSubmitRequest>();
    
        for(Case_Line_Items__c caseLine: lstCLItems)
        {
          // Create an approval request for Case record
          Approval.ProcessSubmitRequest req =new Approval.ProcessSubmitRequest();
          req.setComments('Lock Case Line Record');
          req.setObjectId(caseLine.Id);
          lstOfAppReqs.add(req);
    }
    
    //Submit the approval request
    List<Approval.ProcessResult> lstOfResults=Approval.process(lstOfAppReqs,false);
    
    for(Approval.ProcessResult appvResult: lstOfResults)
    {
      System.assert(appvResult.isSuccess());
            System.assertEquals('Pending', appvResult.getInstanceStatus(), 'Instance Status'+appvResult.getInstanceStatus());
    }
        
    }
  
  //Unlock Case line items
  //Added by vk@ff on 09/16/2014
  
  public static void unlockCaseLinesRecord(List<Id> cLinesToUnlock)
  {
    try
    {
      List<Case_Line_Items__c> lstCLItems=[SELECT Id, Case_Number__c FROM Case_Line_Items__c WHERE Case_Number__c IN: cLinesToUnlock];
      List<Id> lstOfAppReqIds=new List<Id>();
      
          for(Case_Line_Items__c caseLine: lstCLItems)
          {
        lstOfAppReqIds.add(caseLine.Id);
      }
      
       //Reject Approval Request
      if(lstOfAppReqIds.size()>0)
      {
         Id retVal = null;
       List<Approval.ProcessWorkitemRequest> lstOfAppReq=new List<Approval.ProcessWorkitemRequest>();
        
         List<ProcessInstanceWorkitem> lstWorkItems=[Select Id from ProcessInstanceWorkitem where ProcessInstanceWorkitem.ProcessInstance.TargetObjectId IN: lstOfAppReqIds];
         
        
            for(ProcessInstanceWorkitem workItem:lstWorkItems)
            {
                // Reject the submitted request
                     
                // Instantiate the new ProcessWorkitemRequest object and populate it
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setComments('Rejecting request.');
                req.setAction('Reject');
                                      
                //Specify the item to be worked
                req.setWorkitemId(workItem.Id);
                lstOfAppReq.add(req);            
                
            }
        
        // Submit the request for rejection
            List<Approval.ProcessResult> result2 =  Approval.process(lstOfAppReq, false);
      }
    }
      
    catch(DmlException e)
    {
      System.debug(e.getMessage());  
    }
  }  
	
	public static void populateOrderShipToOnCase(List<Case> caseList,Set<Id> CaseOrderIds) {
		
		//Select ShipTos based on order number
		List<Ship_To__c> ShipToList = new List<Ship_To__c>([Select Order__c, Id from Ship_To__c where Order__c in :CaseOrderIds and Name = '1']);
		Map<String,String> OrderShipToMap = new Map<String,String>();
		if (!ShipToList.isEmpty()) {
			for (Ship_To__c s :ShipToList) {
				OrderShipToMap.put(s.Order__c, s.Id);
			}
		}
		
		for (Case c :caseList) {
			if (OrderShipToMap.containsKey(c.RH_Order_Number__c)) {
				c.Ship_To_1__c = OrderShipToMap.get(c.RH_Order_Number__c);
			}
		}
	}
	
    // Populate specific fields on the Cases in the provided list from the Order and update
	// other dependent Case fields. Assumes each Case in caseList has a valid Order Number lookup field
	public static void populateOrderInformation(List<Case> caseList, Boolean isInsert) {
		Set<Id> oIds = new Set<Id>();
		Map<String, CasetoOrderFieldMapping__c> fieldMap = new Map<String, CasetoOrderFieldMapping__c>();
		
		// Create the list of the Ids for the Order records we need
		for (Case c : caseList) {
			oIds.add(c.Rh_Order_Number__c);
		}
		
		// Retrieve the fields to query from the custom setting, build the Order query and get the Order records
		fieldMap = CasetoOrderFieldMapping__c.getAll();
		String orderQuery = 'SELECT Id, ';
		for (CasetoOrderFieldMapping__c cofm :fieldMap.values()) {
			orderQuery += cofm.Order_Field__c + ', ';
		}
		orderQuery = orderQuery.removeEnd(', ');
		orderQuery += ' FROM RH_Order__c WHERE Id IN: oIds';
		Map<Id, RH_Order__c> mapOfOrders = new Map<Id, RH_Order__c>((List<RH_Order__c>)Database.query(orderQuery));
		
		// Determine if we need to set/change the on hold status of Delay Notifications cases
		Map<Id, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById();
		Boolean checkOnHold = false;
		for (Case c :caseList) {
			if (rtMap.containsKey(c.RecordTypeId) && rtMap.get(c.RecordTypeId).getName() == 'Delay Notifications') {
				checkOnHold = true;
			}
		}
		
		// Get the relevant On Hold date ranges if necessary
		Map<String, Boolean> todayHoldsMap;
		if (checkOnHold) {
			todayHoldsMap = DelayedOrderActions.getTodayHolds();
		}
		
		// Populate the Case records with the data from the Order and update dependent Case fields
		for (Case c :caseList) {
			
			for (CasetoOrderFieldMapping__c cofm :fieldMap.values()) {
				
				// For Credit Card Declines cases, only copy System_Hold_Code__c if not insert
				if (cofm.Case_Field__c == 'System_Hold_Code__c' && isInsert) {
					if (rtMap.containsKey(c.RecordTypeId) && rtMap.get(c.RecordTypeId).getName() == 'Credit Card Declines') {
						continue;
					}
				}
				
				// Verify that the user has access to the Opportunity before copying the Opportunity Id
				if (cofm.Case_Field__c == 'Opportunity_del__c') {
					String oppId = (String)(mapOfOrders.get(c.RH_Order_Number__c).get(cofm.Order_Field__c));
					if (String.isNotBlank(oppId)) {
						Boolean hasOppRead = [select RecordId, HasReadAccess from UserRecordAccess where UserId = :UserInfo.getUserId() and RecordId = :oppId].HasReadAccess;
						if (!hasOppRead) {
							c.put(cofm.Case_Field__c, null);
							continue;
						}
					}
				}
				
				c.put(cofm.Case_Field__c, mapOfOrders.get(c.RH_Order_Number__c).get(cofm.Order_Field__c));
			}
			
			// Set the Order Type Category and On Hold state for all Delay Notifications cases
			if (rtMap.get(c.RecordTypeId).getName() == 'Delay Notifications') {
				c.Order_Type_Category__c = DelayedOrderActions.getOrderTypeCategory(c.Order_Type_Code__c);
				if (String.isNotBlank(c.Order_Type_Category__c) && todayHoldsMap.containsKey(c.Order_Type_Category__c)) {
					c.On_Hold__c = todayHoldsMap.get(c.Order_Type_Category__c);
				}
			}
			
			if (String.isNotBlank(c.Sold_to_Address__c)) {
				c.Sold_to_Address__c = c.Sold_to_Address__c.replaceAll('<br>','\n');
			}
		}
	}
	
    //Set the case to Re-Open if Action Required is true and the case was closed previously.
    public static void ReopenCaseOnActionReqd(List<Id> lstOfCases)
    {
        List<Case> lstOfCasesToUpdate=[SELECT Id, Status FROM Case WHERE Id IN: lstOfCases];
        for(Case c: lstOfCasesToUpdate)
        {
            c.Status='Re-open'; 
        }
        try
        {
            update lstOfCasesToUpdate;
        }
        catch(DMLException e)
        {
            System.debug(e.getMessage());
        }
    }
    
    /*
    //Initiate Case Assignment Rules from Code
    public static void UpdateApplyAssignmentRules(List<Id> lstOfCaseIds)
    {
        List<Case> lstOfCasesToUpdate= [SELECT Id,OwnerId,Status,To__c FROM Case WHERE Id IN:lstOfCaseIds];
        
        System.debug('BEFORE' + lstOfCasesToUpdate);
        //Fetching the assignment rules on case
        List<AssignmentRule> AR = new List<AssignmentRule>();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
		System.debug(AR);
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        if(AR.size()>0){
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR[0].id;
        
        dmlOpts.EmailHeader.triggerUserEmail = true;
        }
        
        for(Case c: lstOfCasesToUpdate)
        {
            //Assigning the Assignment rule Id
            c.setOptions(dmlOpts);
        }
                
        try
        {
            update lstOfCasesToUpdate;
			System.debug('AFTER'+lstOfCasesToUpdate);
        }
            
        catch(DmlException e)
        {
            System.debug(e.getMessage());
        }
    }
    */
        
    // Set the SendGrid In Process flag to indicate that a future process has been launched to send
    // an email about the Cases of the Ids provided
    public static void UpdateSendGridInProcess(List<Id> caseIds) {
        
        List<Case> caseList = new List<Case>();
        for (Id cId :caseIds) {
          caseList.add(new Case(
            Id = cId,
            SendGrid_In_Process__c = true)
          );
        }
        
        if (!caseList.isEmpty()) {
      try {
        update caseList;
      } catch(DmlException e) {
        System.debug(e.getMessage());
          }
        }
  }
}