/*
    Class: UpdateCaseFromCaseComments
    Description: This case contains a method to update the Case field "Action Required" and also number of case comments related to a Case
    Developer: vk@ff on 08/26/2014
    Test Class: CaseCommentsTrigger_Test
*/

public without sharing class UpdateCaseFromCaseComments
{
	/*
	 *	Entire class file is commented out because the CaseCommentsTrigger has been rewritten to no longer use this class file.
	 *	This class file should probably be deleted at some point in the future when we are sure we will not want to go back to it.
	 *
	
	//Method sets the Action Required field on a Case
	public static void UpdateCase(List<Id> lstOfCIds)
	{
		List<Case> lstOfCases=new List<Case>();
		lstOfCases=[SELECT Id, Action_Required__c FROM Case WHERE Id IN: lstOfCIds];
		if(!lstOfCases.isEmpty())
		{
			for(Case c: lstOfCases)
			{
				c.Action_Required__c=true;
			}
		}
		
		try
		{
			update lstOfCases;	
		}
		catch(DmlException e)
		{
			System.debug(e.getMessage());	
		}
	}
	
	//Updates the number of Case Comments on a Case
	public static void UpdateNoOfComments(Map<Id,Boolean> mOfCids)
	{
		List<Case> lstOfCases=new List<Case>();
		System.debug('CASE IDS'+ mOfCids.keySet());
		List<Id> lstOfCids=new List<Id>();
		lstOfCids.addAll(mOfCids.keySet());
		
		lstOfCases=[SELECT Id, no_of_case_comments__c FROM Case WHERE Id IN:mOfCids.keySet()];
		System.debug('IN CLASS' + lstOfCases);
		if(!lstOfCases.isEmpty())
		{
			for(Case c: lstOfCases)
			{
				if(mOfCids.containsKey(c.Id))
				{
					if(mOfCids.get(c.Id)==true && c.no_of_case_comments__c!=null)
					{
						c.no_of_case_comments__c=c.no_of_case_comments__c+1;
						System.debug('INCREMENTING' + c.no_of_case_comments__c);
					}
					else
					{
						if(c.no_of_case_comments__c!=null)
						{
							c.no_of_case_comments__c=c.no_of_case_comments__c-1;
							System.debug('DECREMENTING' + c.no_of_case_comments__c);
						}
					}	
				}	
			}	
		}
		
		try
		{
			update lstOfCases;
		}
		catch(DmlException e)
		{
			System.debug(e.getMessage());	
		}
	}
	
	//Updates the accepted count field on Case
	public static void UpdateAttemptedCount(List<Id> lstOfCIds)
	{
		List<Case> lstOfCases=[SELECT Id,Attempted_Contact__c FROM Case WHERE Id IN: lstOfCIds];
		
		for(Case c: lstOfCases)
		{
			if(c.Attempted_Contact__c!=null)
			{
				c.Attempted_Contact__c++;
			}
			else
			{
				c.Attempted_Contact__c=1;
			}
		}
		
		try
		{
			update lstOfCases;
		}
		catch(DmlException e)
		{
			System.debug(e.getMessage());	
		}
		
	}
	
	// Update the case field Call Outcome from the case comment.  Also update the related order and order line information as appropriate
	public static void UpdateCaseCallOutcome(Map<Id,Id> mapCCToCase)
	{
		List<Id> oIds = new List<Id>();
		List<Id> cDNIds = new List<Id>();
		Map<Id, RH_Order__c> oMap;
		Boolean upOrder;
		List<RH_Order__c> oUpList = new List<RH_Order__c>();
		Id caseDNRecordTypeId = '012500000009tdy';
		
		List<Case> lstOfCases = [SELECT Id, Call_Outcome__c, RecordTypeId, RH_Order_Number__c FROM Case WHERE Id IN: mapCCToCase.values()];
		for (Case c :lstOfCases) {
			oIds.add(c.RH_Order_Number__c);
			if (c.RecordTypeId == caseDNRecordTypeId) {
				cDNIds.add(c.Id);
			}
		}
		
		oMap = new Map<Id, RH_Order__c>([select Id, Callout_Contacts__c, Email_Contacts__c from RH_Order__c where Id in :oIds]);
		
		//Retrieve all the call outcomes from Case Comments
		Map<Id,Case_Comments__c> mapOfcc = new Map<Id,Case_Comments__c>([SELECT Id, Call_Outcome__c FROM Case_Comments__c WHERE Id IN: mapCCToCase.keySet()]);
		
		for (Case c :lstOfCases) {
			for (Id ccId :mapCCToCase.keySet()) {
				if (mapCCToCase.get(ccId) == c.Id && mapOfcc.get(ccId) != null && mapOfcc.get(ccId).Call_Outcome__c != null) {
					c.Call_Outcome__c=mapOfcc.get(ccId).Call_Outcome__c;
					
					// update the related order customer contact fields
					if (oMap.containsKey(c.RH_Order_Number__c)) {
						upOrder = false;
						if (c.Call_Outcome__c == 'Talked to Customer') {
							if (oMap.get(c.RH_Order_Number__c).Callout_Contacts__c == null) {
								oMap.get(c.RH_Order_Number__c).Callout_Contacts__c = 0;
							}
							oMap.get(c.RH_Order_Number__c).Callout_Contacts__c++;
							upOrder = true;
						}
						if (c.Call_Outcome__c == 'Sent Email') {
							if (oMap.get(c.RH_Order_Number__c).Email_Contacts__c == null) {
								oMap.get(c.RH_Order_Number__c).Email_Contacts__c = 0;
							}
							oMap.get(c.RH_Order_Number__c).Email_Contacts__c++;
							upOrder = true;
						}
						if (upOrder) {
							oUpList.add(oMap.get(c.RH_Order_Number__c));
						}
					}
				}
			}
		}
		
		// Update the order line availability date communicated to customer for all Delay Notifications cases
		Map<Id, Order_Line_Items__c> oliMap = new Map<Id, Order_Line_Items__c>();
		if (!oUpList.isEmpty() && !cDNIds.isEmpty()) {
			List<Case_Line_Items__c> cliList = new List<Case_Line_Items__c>();
			cliList = [select Id, Case_Number__c, Line_Number__c, Current_Available_Date__c from Case_Line_Items__c where Case_Number__c in :cDNIds];
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
			}
		}
		
		try {
			if (!oUpList.isEmpty()) {
				update oUpList;
			}
			if (!oliMap.isEmpty()) {
				update oliMap.values();
			}
			if (!lstOfCases.isEmpty()) {
				update lstOfCases;
			}
		} catch(DmlException e) {
			System.debug('*****UpdateCaseCallOutcome exception = ' + e.getMessage());	
		}
	}
	*/
}