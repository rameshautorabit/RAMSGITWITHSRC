public with sharing class OpportunityService {

    /*
     *  Service methods for OpportunityTrigger.trigger.
     *
     */

    // Set field Opportunity Creator Gallery (if not already set) to the gallery account refereneced in
    // the CreatedById user record for all Opportunity records with Design Atelier record type.
    // - before insert

    public static void creatorGallery(List<Opportunity> newList) {
        Map<Id, Schema.RecordTypeInfo> rtMapById = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
        Set<Id> userIds = new Set<Id>();

        for (Opportunity o :newList) {
            if (o.Opportunity_Creator_Gallery__c == null) {
                if (rtMapById.containsKey(o.RecordTypeId) && rtMapById.get(o.RecordTypeId).getName() == 'Design Atelier') {
                    userIds.add(UserInfo.getUserId());
                }
            }
        }

        if (!userIds.isEmpty()) {
            Map<Id, User> userMap = new Map<Id, User>([select Id, Gallery__c from User where Id in :userIds]);
            Set<String> galleryNames = new Set<String>();
            for (User u :userMap.values()) {
                if (String.isNotBlank(u.Gallery__c)) {
                    galleryNames.add(u.Gallery__c);
                }
            }

            if (!galleryNames.isEmpty()) {
                List<Account> accountList = new List<Account>();
                accountList = [select Id, Name from Account where Name in :galleryNames];
                Map<String, Account> accountMap = new Map<String, Account>();
                for (Account a :accountList) {
                    accountMap.put(a.Name, a);
                }

                if (!accountMap.isEmpty()) {
                    for (Opportunity o :newList) {
                        if (userMap.containsKey(UserInfo.getUserId())) {
                            if (accountMap.containsKey(userMap.get(UserInfo.getUserId()).Gallery__c)) {
                                o.Opportunity_Creator_Gallery__c = accountMap.get(userMap.get(UserInfo.getUserId()).Gallery__c).Id;
                            }
                        }
                    }
                }
            }
        }
    }

    // Update the Opportunity PM field on related Cases if the PM field on the Opportunity has changed
    // - after update
    public static void opportunityPM(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {
        Set<Id> oppIds = new Set<Id>();

        for (Opportunity o :newMap.values()) {
            if (o.Ops_Contact__c != oldMap.get(o.Id).Ops_Contact__c) {
                oppIds.add(o.Id);
            }
        }

        if (!oppIds.isEmpty()) {
            List<Case> caseList = new List<Case>();
            List<Case> caseUpList = new List<Case>();
            caseList = [select Id, Opportunity_PM__c, Opportunity_del__c from Case where Opportunity_del__c in :oppIds and IsClosed = false];
            for (Case c :caseList) {
                if (newMap.containsKey(c.Opportunity_del__c)) {
                    c.Opportunity_PM__c = newMap.get(c.Opportunity_del__c).Ops_Contact__c;
                    caseUpList.add(c);
                }
            }

            if (!caseUpList.isEmpty()) {
                update caseUpList;
            }
        }
    }

    // Clear credit card information on the Opportunity and related Quote Clone when Order Number is changed
    // - before update, after update
    public static void clearCardInfo(List<Opportunity> newList, Map<Id, Opportunity> oldMap, Boolean isBefore) {

        if (isBefore) {
            for (Opportunity opp :newList) {
                if (opp.Order_Number__c != null && opp.Order_Number__c != oldMap.get(opp.Id).Order_Number__c) {

                    // Clear the Opportunity card number field
                    opp.Card_Expiration_Month__c = null;
                    opp.Card_Expiration_Year__c = null;
                    opp.Card_Number__c = null;
                    opp.Second_Card_Expiration_Month__c = null;
                    opp.Second_Card_Expiration_Year__c = null;
                    opp.Second_Card_Number__c = null;

                    // Set the Card Info Cleared fields
                    opp.Card_Info_Cleared_Date_Time__c = System.now();
                    opp.Card_Info_Cleared_By__c = UserInfo.getUserId();
                }
            }
        }

        if (!isBefore) {
            Set<Id> oppIds = new Set<Id>();
            for (Opportunity opp :newList) {
                if (opp.Order_Number__c != null && opp.Order_Number__c != oldMap.get(opp.Id).Order_Number__c) {
                    oppIds.add(opp.Id);
                }
            }

            if (!oppIds.isEmpty()) {
                List<Quote_Clone__c> qcList = new List<Quote_Clone__c>();
                qcList = [select Id, Card_Expiration_Month__c, Card_Expiration_Year__c, Card_Number__c,
                        Second_Card_Expiration_Month__c, Second_Card_Expiration_Year__c, Second_Card_Number__c,
                        Card_Info_Cleared_Date_Time__c, Card_Info_Cleared_By__c
                        from Quote_Clone__c where Opportunity__c in :oppIds];

                for (Quote_Clone__c qc :qcList) {
                    qc.Card_Expiration_Month__c = null;
                    qc.Card_Expiration_Year__c = null;
                    qc.Card_Number__c = null;
                    qc.Second_Card_Expiration_Month__c = null;
                    qc.Second_Card_Expiration_Year__c = null;
                    qc.Second_Card_Number__c = null;
                    qc.Card_Info_Cleared_Date_Time__c = System.now();
                    qc.Card_Info_Cleared_By__c = UserInfo.getUserId();
                }

                if (!qcList.isEmpty()) {
                    update qcList;
                }
            }
        }
    }

    // Sets the Status on the syncing Quote if the Opportunity reaches a given Stage
    // - after update
    public static void setSyncingQuoteStatus(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Set<Id> opportunityIds = new Set<Id>();
        String stage;
        
        System.debug('New Map: ' + newList + ' Old Map: ' + oldMap);

        // Get the given Stage
        stage = Application_Settings__c.getInstance('QuoteCloneStatusToCreatePortalUser').Value_Text__c;

        // Create list of Opportunity Ids with the given Stage
        for (Opportunity o :newList) {
            if (o.StageName == stage && oldMap.get(o.Id).StageName != stage) {
                opportunityIds.add(o.Id);
            }
        }

        // Set the Status on the syncing Quote
        if (opportunityIds.size() > 0) {
            List<Quote> quotes = new List<Quote>();
            String status;

            // Get the Quote status from the Custom Setting and the Quote records
            status = Application_Settings__c.getInstance('QuoteCloneStatusToCreatePortalUser').Value_Text__c;
            quotes = [select Id, Status from Quote where IsSyncing = true and OpportunityId in :opportunityIds];

            // Set Status on the syncing Quotes
            for (Quote q :quotes) {
                q.Status = status;
            }

            // Update the Quotes
            UtilityFunctions.databaseUpdate(quotes, false, 'SetQuoteStatusFromOpportunity');
        }
    }

    /*
    // When payment received is >= 50% of Amount on an Opportunity or if Credit Terms is not Pre-Pay, set related Operations Request records to notify Ops
    // - after update
    public static void notifyOps(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Set<Id> oppIds = new Set<Id>();

        for (Opportunity o :newList) {
            if (o.Total_Payment_Received__c != oldMap.get(o.Id).Total_Payment_Received__c || o.Amount != oldMap.get(o.Id).Amount) {
                if (o.Total_Payment_Received__c > 0 && o.Amount > 0) {
                    if (o.Total_Payment_Received__c >= o.Amount / 2) {
                        oppIds.add(o.Id);
                    }
                }
            }
            if (String.isNotBlank(o.Credit_Terms__c) && o.Credit_Terms__c != 'Pre-Pay') {
                if (String.isBlank(oldMap.get(o.Id).Credit_Terms__c) || oldMap.get(o.Id).Credit_Terms__c == 'Pre-Pay') {
                    oppIds.add(o.Id);
                }
            }
        }

        if (!oppIds.isEmpty()) {
            Map<String, Schema.RecordTypeInfo> rtByNameMap = Schema.SObjectType.Operations_Request__c.getRecordTypeInfosByName();
            Set<Id> rtIds = new Set<Id>();
            if (rtByNameMap.containsKey('COM/COL')) {
                rtIds.add(rtByNameMap.get('COM/COL').getRecordTypeId());
            }
            if (rtByNameMap.containsKey('Custom Product')) {
                rtIds.add(rtByNameMap.get('Custom Product').getRecordTypeId());
            }
            if (rtByNameMap.containsKey('SPO Quote')) {
                rtIds.add(rtByNameMap.get('SPO Quote').getRecordTypeId());
            }

            List<Operations_Request__c> opRequestList = new List<Operations_Request__c>();
            opRequestList = [select Id, Notify_Ops__c from Operations_Request__c where Opportunity__c in :oppIds and
                    RecordTypeId in :rtIds and Approval_Status__c = 'Customer Accepted' and Notify_Ops__c = false];

            for (Operations_Request__c opr :opRequestList) {
                opr.Notify_Ops__c = true;
            }

            if (!opRequestList.isEmpty()) {
                update opRequestList;
            }
        }
    }
    */
    // The Clone w/Attachment button (currently only on Design Atelier opportunities) creates a clone of the given opportunity
    // and stores the id of the cloned opportunity in the Cloned_Parent_Id__c field on the clone.
    // Once the clone is inserted the Opportunity after insert trigger fires and calls this method which clones the attachments
    // and notes associated with the cloned parent and associates with the clone.
    public static void processOpportunityAttachments(List<Opportunity> newList) {
		
		Set<Opportunity> opportunityCloneAttachmentList = new Set<Opportunity>();
		List<Opportunity> opportunityAttachmentProcessList = new List<Opportunity>();
		List<Id> clonedOpportunityIdList = new List<Id>();
		List<Opportunity> clonedOpportunityResetList = new List<Opportunity>();

		for (Opportunity o: newList){
				if (!String.isBlank(o.Cloned_Parent_id__c)){
					opportunityCloneAttachmentList.add(o);
				}
		}
		
		if(!opportunityCloneAttachmentList.isEmpty()){
				
				List<Attachment> ListAttachUpdate= new List<Attachment>();
				List<Note> ListNoteUpdate= new List<Note>();
				
				for(Opportunity opp: opportunityCloneAttachmentList){	
					
            		List<Attachment> ListAttach =[SELECT name,body FROM Attachment WHERE ParentID =: opp.Cloned_Parent_Id__c];
            		for(Attachment att: ListAttach){
            			Attachment newAttach = att.Clone(false,true);
            			newAttach.parentId = opp.id;
            			ListAttachUpdate.add(newAttach);
            		}
            		
            		List<Note> ListNote =[SELECT Title,body FROM Note WHERE ParentID =: opp.Cloned_Parent_Id__c];
            		for(Note att: ListNote){
            			Note newNote = att.Clone(false,true);
            			newNote.parentId = opp.id;
            			ListNoteUpdate.add(newNote);
            		}	
            		clonedOpportunityIdList.add(opp.Id);	
				}
				
				clonedOpportunityResetList = [Select Id, Cloned_Parent_Id__c from Opportunity where Id in: clonedOpportunityIdList];
				
				for (Opportunity o: clonedOpportunityResetList){
					o.Cloned_Parent_Id__c = null;
				}
				
			Utility.loginsert(ListAttachUpdate);
			Utility.loginsert(ListNoteUpdate);
			Utility.logupdate(clonedOpportunityResetList);		
		}	
	}

    
    //  Update summary fields on a project when an Opportunity is associated to it
    public static void updateProjectFields(List<Opportunity> newList, Map<Id, Opportunity> oldMap){

        Set<Id> opptyIds = new Set<Id>();
        Set<Id> projIds = new Set<Id>();

        List<Opportunity> opptyList = new List<Opportunity>();
        List<Project__c> projList = new List<Project__c>();
        List<Project__c> projUpdateList = new List<Project__c>();

        for(Opportunity o: newList){
            opptyIds.add(o.Id);
            if(!String.isBlank(o.Parent_Project__c)){
                projIds.add(o.Parent_Project__c);
            }

            if(oldMap != null){
            	if(!String.isBlank(oldMap.get(o.Id).Parent_Project__c) && (oldMap.get(o.Id).Parent_Project__c != o.Parent_Project__c)){
                	projIds.add(oldMap.get(o.Id).Parent_Project__c);
            	}
            }

            System.debug('OpptyIds : ' + opptyIds);
            System.debug('ProjIds :' + projIds);
        }

        if(!projIds.isEmpty()){
            projList = [Select Id, Total_Project_Amount__c, Total_Project_Budget__c, Probability__c, MMU__c, Discount__c from Project__c where Id in :projIds];
            if(!opptyIds.isEmpty()){
                opptyList= [select Id, Amount, Project_Budget__c, Probability, Blended_MMU__c, Total_Discount_Percent__c, Discount_Percentage__c, Parent_Project__c, Initial_Inquiry_Date__c, CloseDate from Opportunity where Parent_Project__c in :projIds];
            }
        }

        System.debug('ProjList: ' + projList);
        System.debug('OpptyList: ' + opptyList);

        if(!projList.isEmpty()){
            for(Project__c p: projList){

                integer n = 0;

                Decimal totPA = 0;
                Decimal totPB = 0;
                Decimal totPP = 0;
                Decimal totBMMU = 0;
                Decimal totDP = 0;
                List<Date> initInqDateList = new List<Date>();
                List<Date> closeDateList = new List<Date>();
                // List<Date> startDateList = new List<Date>();
                // List<Date> endDateList = new List<Date>();

                if(!opptyList.isEmpty()){
                	for(Opportunity o: opptyList){
                    	if(o.Parent_Project__c  == p.Id){
                        	n++;
                        	if(o.Amount == null){
                           		totPA += 0;
                        	}else{
                            	totPA += o.Amount;
                        	}
                        	if(o.Project_Budget__c == null){
                            	totPB += 0;
                        	}else{
                            	totPB += o.Project_Budget__c;
                        	}
                        	if(o.Probability == null){
                            	totPP += 0;
                        	}else{
                            	totPP += o.Probability;
                        	}
                        	if (o.Blended_MMU__c == null){
                            	totBMMU += 0;
                        	}else{
                            	totBMMU += o.Blended_MMU__c;
                        	}
                        	if (o.Total_Discount_Percent__c == null){
                            	totDP += 0;
                        	}else{
                            	totDP += o.Total_Discount_Percent__c;
                        	}
                        	
	                        initInqDateList.add(o.Initial_Inquiry_Date__c);
	                        initInqDateList.sort();
	                        closeDateList.add(o.CloseDate);
	                        closeDateList.sort();
	                        //startDateList.add(o.startDate);
	                        //startDateList.sort();
	                        //endDateList.add(o.startDate);
	                        //endDateList.sort();

	                        System.debug('Close Date List: ' + closeDateList);
	                        System.debug('Init Inq Date List: ' + initInqDateList);
                    	}
                	}

                	If(n != 0){
		               	p.Total_Project_Amount__c = totPA;
		              	p.Total_Project_Budget__c = totPB;
		               	p.Probability__c = totPP/n;
		              	p.MMU__c = totBMMU/n;
		               	p.Discount__c = totDP/n;
  	             		p.Initial_Inquiry_Date__c = initInqDateList[0];
                		p.Close_Date__c = closeDateList[closeDateList.size()-1];
                		//p.Start_Date__c = startDateList[0];
                		//p.End_Date__c = endDateList[endDateList.length-1];

	                	System.debug('Proj Init Inq Date: ' + p.Initial_Inquiry_Date__c);
	                	System.debug('Proj Close Date: ' + p.Close_Date__c);

	                	projUpdateList.add(p);
                	}
                }
            }
        }
        System.debug('ProjUpdateList: ' + projUpdateList);

        Utility.logupdate(projUpdateList);
    }
    
    /*
		* Description: Method to update Purchasing owner and Design Owner info on Opportunity. JIRA SRS-1884
	    * Author: Eashan Parlewar
	    * Created Date : 25-04-2017
	*/
	public static void Purchasing_DesignOwnerPopulate(List<Opportunity> newList) 
	{
		     set<string> PurchasingAgentSet=new set<string>();
		     set<string> DesignFirmSet=new set<string>();
		     map<string,string> PusrchasingAccMap=new map<string,string>();
		     map<string,string> DesignFirmAccMap=new map<string,string>();
		     
		     for(Opportunity Opp:newList)
		     {
			        // IF 'Purchasing Agent Involved?' is Yes then 'Purchasing Agent' lookup will populate. 
			        // And we need the ownerid of 'Purchasing Agent'.
			        if(Opp.Purchasing_Agent_Involved__c=='Yes' 
			           && Opp.Purchasing_Agent__c!=null 
			           && Opp.TL_Owner_Purchasing__c==null)
			        {
			        	PurchasingAgentSet.add(Opp.Purchasing_Agent__c);
			        }
		            
		            // IF 'Design Firm' is populated then we need the ownerid of 'Design Firm'. 
		            if(Opp.Design_Firm__c!=null 
		               && Opp.TL_Owner_Design__c==null)
		            {
		            	DesignFirmSet.add(Opp.Design_Firm__c);
		            }
		     }
		     
		     if(PurchasingAgentSet.size()>0 || DesignFirmSet.size()>0)
		     {
				     // Query on Account to get the OwnerId of the Purchasing agent or Design Firm records.
				     for(Account Acc:[select id,OwnerId from Account where id in:PurchasingAgentSet or id in:DesignFirmSet])
				     {
					     	if(PurchasingAgentSet.contains(Acc.id))
					     	{
					     		PusrchasingAccMap.put(Acc.id,Acc.OwnerId);
					     	}
					     	
					     	if(DesignFirmSet.contains(Acc.id))
					     	{
					     		DesignFirmAccMap.put(Acc.id,Acc.OwnerId);
					     	}
				     }
				     
				     // Loop to populate TL Owner Purchasing/TL Owner Design.
				     for(Opportunity Opp:newList)
				     {
				            if(Opp.Purchasing_Agent_Involved__c=='Yes' 
				               && Opp.Purchasing_Agent__c!=null 
				               && PusrchasingAccMap.containsKey(Opp.Purchasing_Agent__c))
					        {
					        	Opp.TL_Owner_Purchasing__c=PusrchasingAccMap.get(Opp.Purchasing_Agent__c);
					        }
				            
				            if(Opp.Design_Firm__c!=null 
				               && DesignFirmAccMap.containsKey(Opp.Design_Firm__c))
				            {
				            	Opp.TL_Owner_Design__c=DesignFirmAccMap.get(Opp.Design_Firm__c);
				            }
				     }
		     }
	}
	
	/*	Description	:	Method will calculate rollup summary of Opportunity Won/Lost/Open Amount on its associated Project	JIRA-2082
     *	Author		:	Surbhi Dubey
     *	Created Date	:	24-05-2017
    */
    public static void updateProjectAmount(List<Opportunity> newOppty,map <Id,Opportunity> oldMap,Boolean isInsert,Boolean isDelete)	{
    	Set<Id> projectIds=new Set<Id>();
       	for(Opportunity oppty:newOppty)	
       	{ 
       		if(isInsert || isDelete )	
       		{
       			if(oppty.Parent_Project__c!=null){
					projectIds.add(oppty.Parent_Project__c);
    			}
       		}
       		else if(oldMap!=null 
       			&& ((oppty.Parent_Project__c!=null && (oldMap.get(oppty.Id).Parent_Project__c != oppty.Parent_Project__c)) 
       				|| (oppty.Amount!=null && (oldMap.get(oppty.Id).Amount != oppty.Amount)) 
       				|| (oldMap.get(oppty.Id).Exclude_from_Project_roll_ups__c != oppty.Exclude_from_Project_roll_ups__c) 
       				|| (oldMap.get(oppty.Id).StageName != oppty.StageName))){
       			if(oppty.Parent_Project__c != null){
       				projectIds.add(oppty.Parent_Project__c);	
       			}
				if(oldMap.get(oppty.Id).Parent_Project__c != null && (oldMap.get(oppty.Id).Parent_Project__c != oppty.Parent_Project__c)){
					projectIds.add(oldMap.get(oppty.Id).Parent_Project__c);	
				}
    		}
    		else if(oldMap.get(oppty.Id).Parent_Project__c!=null && (oldMap.get(oppty.Id).Parent_Project__c != oppty.Parent_Project__c)){
       		   	projectIds.add(oldMap.get(oppty.Id).Parent_Project__c);	
    		}
       }
    	
        List<Opportunity> listOppty1=new List<Opportunity>();
		map<Id,List<Opportunity>> mapProjectNListOppty=new map<Id,List<Opportunity>>();
		if(projectIds.size()>0)	
		{
			List<Opportunity> listOppty=[Select Id,Parent_Project__c,StageName,Amount,Exclude_from_Project_roll_ups__c from Opportunity
			 							where Parent_Project__c IN: projectIds AND Exclude_from_Project_roll_ups__c=false AND Parent_Project__c != NULL];
			for(Opportunity opp:listOppty)	
			{
				if(mapProjectNListOppty.containsKey(opp.Parent_Project__c))	
				{
		    		mapProjectNListOppty.get(opp.Parent_Project__c).add(opp);
		    	}
		    	else	
		    	{
		         mapProjectNListOppty.put(opp.Parent_Project__c,new List <Opportunity> { opp });
		    	}
			}
		}
		
		if(mapProjectNListOppty.size()>0)	
		{
			List<OpportunityStage> opportunityStages=[SELECT Id, MasterLabel, ApiName, IsClosed, IsWon FROM OpportunityStage];
			Set<String> closedWon=new Set<String>();
			Set<String> closedLost=new Set<String>();
			for(OpportunityStage oppStage:opportunityStages)	
			{
	    		if(oppStage.isClosed==true && oppStage.isWon==true)	
	    		{
	        		closedWon.add(oppStage.ApiName);
	   			}
	    		else if(oppStage.isClosed==true && oppStage.isWon==false)	
	    		{
	        		closedLost.add(oppStage.ApiName);
	    		}
			}
		   
			List<Project__c> projectList=[select Id from Project__c where Id IN:mapProjectNListOppty.keySet()];    
			List<Project__c> listToUpdate=new List<Project__c>();
			if(projectList.size()>0)	
			{
				for(Project__c projectObj:projectList)	
				{
					Decimal totalWonAmount=0.0; 
					Decimal totalLostAmount=0.0;
					Decimal totalOpenAmount=0.0;
		    		List<Opportunity> opportunityList= mapProjectNListOppty.get(projectObj.Id);
		    		for(Opportunity oppObj:opportunityList)	
		    		{
		        		if(closedWon.contains(oppObj.StageName) && oppObj.Amount!=null )	
		        		{
		        			totalWonAmount=totalWonAmount+oppObj.Amount;
		        		}
		       			else if(closedLost.contains(oppObj.StageName) && oppObj.Amount!=null)	
		       			{
		            			totalLostAmount=totalLostAmount+oppObj.Amount;
		        		}
		        		else if(oppObj.Amount!=null)	
		        		{
		           			 	totalOpenAmount=totalOpenAmount+oppObj.Amount;
		       			}
		    		}
					projectObj.Total_Project_Won_Amount__c=totalWonAmount;
					projectObj.Total_Project_Lost_Amount__c=totalLostAmount;
					projectObj.Total_Project_Open_Amount__c=totalOpenAmount;
					listToUpdate.add(projectObj);
				}
				if(listToUpdate.size()>0)	{
					update listToUpdate;
				}
				
			}
			   
		}
	 }
}