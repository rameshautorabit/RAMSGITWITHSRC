global class BatchExpireMemberships implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
   
    private Integer membershipCount = 0; 
    private Integer membershipsExpired = 0;
    private Integer membershipsOnGracePeriod = 0;           
    
    private Integer jobNumber = 0;
    
    private MembershipExpiration__c expirationParams;
    private Integer expireOn = null;
    private Integer grace = null;
    
    /*
     * Initialize
     * if you only want to run the expiration process, and ignore the logic to set the CC dates and entity codes, set this to 2.
     */
    
	global BatchExpireMemberships() {
		this.initialize();
		this.jobNumber = this.isGracePeriodEnabled() ? 0 : 2; 
	}

	global BatchExpireMemberships(Integer job) {
		this.initialize();
		this.jobNumber = job;
	}
	
	private void initialize() {
		Map<String, MembershipExpiration__c> graceMap = MembershipExpiration__c.getAll();
		this.expirationParams = graceMap.get('Default');
		this.expireOn = Integer.ValueOf(expirationParams.ExpireAfterDays__c); 
		this.grace = Integer.ValueOf(expirationParams.NumberOfDaysGrace__c);		
	}
	
	private Boolean isGracePeriodEnabled() {
		if (this.grace == null) {
			this.initialize();
		}
		return this.grace > this.expireOn;
	}
		
    /*
     * Build the query
     */
    
    global String buildQuery() {
       String nonGraceExpire = String.valueOf(System.Today().addDays(-1*this.expireOn)).substring(0,10);  	       
       return 'SELECT Id, Name, Enrollment_Date__c, Expiration_Date__c, Renewal_Reminder_Email_Sent_Date__c, Renewal_Term__c, Renewal_Email_Notification__c'
       		+ ', BC_Renewal_CC_Final_4_Digits__c, BC_Renewal_CC_Expiration_Date__c, RH_Renewal_CC_Final_4_Digits__c, RH_Renewal_CC_Expiration_Date__c, Has_Valid_CC__c'
       		+ ', Special_Enrollee__c, GetsChangedTandCs__c, Latest_CC_Expiration_Date__c, Created_By_Order_Id__c, Created_By_Order_Id__r.Name'
       		+ ', Renewal_Order_Entity_Code__c, RH_Renewal_CC_Entity_Code__c, BC_Renewal_CC_Entity_Code__c, Created_By_Order_Id__r.Division__c, Cancellation_Type__c, Cancellation_Reason__c, Cancellation_Date__c'
       		+ ', RH_Renewal_CC_Updated_DateTime__c, BC_Renewal_CC_Updated_DateTime__c, Is_Auto_Renew__c, Renew_Email_Opt_In__c, Auto_Renew_Order_Failed_Date_Time__c, Auto_Renew_Order_Failed__c'
       		+ '  FROM Membership__c'
       		+ ' WHERE Expiration_Date__c <= ' + nonGraceExpire 
       		+ ' AND Cancellation_Reason__c != \'' + this.expirationParams.Cancellation_Reason__c + '\'';
    }  
    
    /*
     * Expire membership records
     */
    
	global List<Membership__c> processRecords(List<Membership__c> memberships, Map<String, Boolean> mapEligibility) {    
		
		system.debug('BatchExpireMemberships -> processRecords');	
		       
		List<Membership__c> updateMemberships = new List<Membership__c>();            
		for (Membership__c m : memberships) {
			
			system.debug('BatchExpireMemberships -> processRecords -> ' + m);
			
			Date ExpirationDate;            
   			Boolean getsGrace = false;
   			Boolean shouldExpire = true;
   			if (!m.Auto_Renew_Order_Failed__c && m.Is_Auto_Renew__c && m.Has_Valid_CC__c) {
    			getsGrace = true; 
    			membershipsOnGracePeriod++;           	
   			}
           
           	system.Debug('BatchExpireMemberships -> processRecords -> Should expr on? ' + System.Today().addDays(-1 * this.expireOn));
           	system.Debug('BatchExpireMemberships -> processRecords -> If grace then exp on? ' + System.Today().addDays(-1 * this.grace));
           	system.debug('BatchExpireMemberships -> processRecords -> But actually expired on: '+m.Expiration_Date__c);
           	
           	if ((!getsGrace && m.Expiration_Date__c == System.Today().addDays(-1 * this.expireOn)) || (getsGrace && m.Expiration_Date__c < System.Today().addDays(-1 * this.grace))) {
           		
           		system.debug('BatchExpireMemberships -> processRecords -> Expiring -> ' + m);
           		
   				if (m.Cancellation_Type__c == null) {
   					system.debug('setting Cancellation_Type__c to today');
         			m.Cancellation_Type__c = this.expirationParams.Cancellation_Type__c;
	   			}
	   			if (m.Cancellation_Reason__c == null) {
	   				system.debug('setting Cancellation_Reason__c to today');
					m.Cancellation_Reason__c = this.expirationParams.Cancellation_Reason__c;
	   			}
	   			if (m.Cancellation_Date__c == null) {
	   				system.debug('setting Cancellation_Date__c to today');
					m.Cancellation_Date__c = System.Today();
	   			}
	   			
	            m.Is_Auto_Renew__c = FALSE;
	            m.Auto_Renew_Order_Failed_Date_Time__c = null;
	            m.Auto_Renew_Order_Failed__c = FALSE;	             
	            updateMemberships.add(m);
	            mapEligibility.put(m.Name, false);	             
	            
           	}           
       	} 
       	return updateMemberships;   	
    }
    
    /*
     * Run the batch
     */
    
    global database.queryLocator start(Database.BatchableContext BC) {
    	String query = buildQuery();    	
    	system.debug('BatchExpireMemberships -> start -> ' + query);
    	return database.getQueryLocator(query);
    }
    
	/*
	 * Execute the batch - split into 3 batches to ensure we don't blow any SOQL limits
	 * Job ONE : Assigns new expiration dates to the membership record
	 * Job TWO : Assigns better expiration dates from CW if necessary
	 * JOB THREE : Finds the membership records that expiration
	 */    
    
	global void execute(Database.BatchableContext BC, List<Membership__c> memberships) {
		
		system.debug('BatchExpireMemberships -> execute -> ' + this.jobNumber + ' -> ' + memberships.size());
    	
    	if (this.jobNumber == 0) {

	    	system.debug('Bulk update expiration dates for membership records in batch');
	    	List<Membership__c> assignedMemberships = MembershipRenewalService.assignExpirationDates(memberships);
	    	if (!assignedMemberships.isEmpty()) {
	    		Utility.logUpdate(assignedMemberships);
	    	}
    		
    	} else if (this.jobNumber == 1) {
    		
	    	system.debug('Bulk update membership records with better CW expiration dates if any available');
	    	MembershipRenewalService.CalloutResponse response = MembershipRenewalService.callCwForBetterCardDetails(memberships);
	    	Utility.logUpdate(response.updatedMemberships);
	    	Utility.logInsert(response.resultingErrors);
	    	
    	} else if (this.jobNumber == 2) {		
    		
			membershipCount += memberships.size();
			Map<String, Boolean> mapEligibility = new Map<String, Boolean>(); 
	       	List<Membership__c> updateMemberships = this.processRecords(memberships, mapEligibility);
	       	if (!updateMemberships.isEmpty()) {     
	       		membershipsExpired += updateMemberships.size();    
	          	MembershipService.updateEligibleForMemberBenefitsSynchronous(mapEligibility);
	          	Utility.logUpdate(updateMemberships);
	       	}        
    	}
    	
    } 
    
    /*
     * Finish batch:
     * Either move onto the next batch or finish and send email
     * Job ONE has to be run with a smaller batch size as this potentially makes call outs to CW for every membership record 
     */    
     
	global void finish(Database.BatchableContext BC) {     

    	system.debug('BatchMonitorMembershipRenewalEmails -> finish -> ' + this.jobNumber); 	
    	
    	if (this.jobNumber ==  0) {    		
    		Database.executeBatch(new BatchExpireMemberships(1), 1);
    	} else if (this.jobNumber == 1) {
    		Database.executeBatch(new BatchExpireMemberships(2), 50);
    	} else {    	     

			AsyncApexJob aaj = [
		      	SELECT Id, Status, NumberOfErrors, JobItemsProcessed, MethodName, TotalJobItems, CreatedBy.Email, CreatedDate
				FROM AsyncApexJob 
				WHERE Id = :BC.getJobId()
			];                                                     
		                        
			String[] addresses = new String[] {aaj.CreatedBy.Email};
			String subject = 'Membership Expiration Batch Job ' + aaj.Status;
			String bodyText = 	'Number of batches processed ' + aaj.TotalJobItems + ' with '+ aaj.NumberOfErrors + ' failures.\n' +                                 
		      					'Expired ' + membershipsExpired + ' Memberships out of ' + membershipCount + ' queried.\n' +
		      					membershipsOnGracePeriod + ' Memberships are still on Grace Period.\n';
		      					
			Utility.sendEmail(addresses, bodyText, subject);
    	}
    	
    }
       
}