public class MembershipService{
	
	public static Set<String> NA_COUNTRIES = new Set<String>{'US', 'CA'};	
	
   public static void SetDefaultsDeprecated(List<Membership__c> memberships, Map<Id, Membership__c> oldMap) {
	   /*
	   h4. Eligible for Member Benefits (Eligible_for_Member_Benefits__c)
	
	   Will be default TRUE upon Member Creation unless Enrollment Date > Today
	
	   h5. Automatically set to FALSE when any values change such that:
	
	   * Expiration Date < Today
	   * OR Enrollment Date > Today
	   * OR Cancelled Status = "RH Terminated"
	
	   h5. Automatically set to TRUE when any values change such that:
	
	   * Cancelled Status != "RH Terminated"
	   * Enrollment Date >= Today
	   * Expiration Date <= Today
	
	   h4. Is Auto Renew
	
	   * For Comp Memberships, Default value is FALSE at Member Creation
	   * For Paid Memberships, Value is whatever is input via API
	
	   h5. Automatically set to FALSE when any values change such that:
	
	   * Cancelled Status = Member Cancelled
	
	   h5. Automatically set to TRUE when any values change such that:
	
	   * Cancelled Status is Updated from Member Cancelled to Not Cancelled
	
	   Note: Not updating the AutoRenew flag for RH Cancelled reasons, so as to preserve customer's original AutoRenew selection if a Salesforce user cancels membership , realizes this was an error, and then un-cancels. At time of renewal, we won't renew any RH Cancelled memberships.
	   
	   ************************************************************************
	   At Creation - Enrollment Date
	
	   Part 1 - Standard Membership
	     If created by MULE_User_ID (Mule API User) then:
	     Set Enrollment date to today's date if NULL - else keep what MULE sent. (MULE will NOT pass NULL for Paid Memberships as per design)
	     Use logic as described to set the Exp Date (i.e. enrollment date with year + 1, same MM/DD)
	   Part 2 - COMP Membership
	     If is Comp, Set Enrollment date to today�s date
	     Use logic as described to set the Exp Date (i.e. enrollment date with year + 1, same MM/DD)
	   Part 3 - Green Screen (CW) Purchase
	     if Membership_Type__c = 'Paid' and NOT created by Mule API User - Do NOTHING upon creation.
	   ************************************************************************
	   */
	   
	   for(Membership__c m:memberships){
	      Membership__c oldRecord;
	      if(oldMap != null){
	         oldRecord = oldMap.get(m.Id);
	      }
	      
	      // Set Dates in certain circumstances
	      if(oldRecord == null){      
	         if(UserInfo.getUserId().Contains('00550000003kjUn')){ // MULE API USER
	            if(m.Enrollment_Date_Time__c == null){
	               m.Enrollment_Date_Time__c = System.Now();
	            }
	            m.Expiration_Date_Time__c = expDate(m.Enrollment_Date_Time__c);
	            m.Welcome_Email_Requested_Datetime__c = System.Now(); // Auto email ONLY for MULE created memberships
	            m.Send_To_Email__c = m.Member_Email__c;   
	         }else{
	            m.Created_by_Application__c = 'Salesforce.com';
	         }
	         if(m.Membership_Type__c != null && m.Membership_Type__c.Contains('Complimentary')){
	            m.Enrollment_Date_Time__c = System.Now();
	            m.Expiration_Date_Time__c = expDate(m.Enrollment_Date_Time__c);   
	            // MSFDC-403
	            // Is Auto Renew should be unchecked when creating new comp membership         
	            m.Is_Auto_Renew__c = false; 
	         }
	         //Member_Card_Scheduled_Request_Date__c
	         if(m.Membership_Card_Opt_in__c == true){
	            m.Member_Card_Scheduled_Request_Date__c = System.Today().addDays(5);
	            m.Member_Card_Status__c = 'Scheduled';
	            m.Member_Card_Street_1__c = m.Member_Street_1__c;
	            m.Member_Card_Street_2__c = m.Member_Street_2__c;
	            m.Member_Card_City__c = m.Member_City__c;
	            m.Member_Card_State__c = m.Member_State__c;
	            m.Member_Card_Postal_Code__c = m.Member_Postal_Code__c;
	            m.Member_Card_Country__c = m.Member_Country__c;            
	         }         
	      } 
	      // Restore Date Logic MSFDC-363
	      if(oldRecord != null 
	         && m.Cancellation_Type__c == 'Member Cancelled'
	         && Utility.isChanged(String.valueOf(oldRecord.Membership_Restore_Date__c), String.valueOf(m.Membership_Restore_Date__c))
	         && oldRecord.Membership_Restore_Date__c == null
	         && m.Membership_Restore_Date__c != null){
	                m.Cancellation_Type__c = null;
	                m.Cancellation_Date__c = null;
	                m.Cancellation_Reason__c = null;
	                m.Is_Auto_Renew__c = true;  
	         } 
	        
	      //Set Address Field for Audit         
	      m.Member_Address__c = addressFormat(m, 'Member'); 
	      m.Member_Card_Address__c = addressFormat(m, 'Member Card'); 
	      
	      // MSFDC-364
	      //  When a Membership is updated such that Membership_c/Cancellation_Type_c 
	      //  is updated to NOT NULL, then:
	      //    the Membership_c/Membership_Restore_Date_c field should be updated to NULL
	      //    the Membership_c/Cancellation_Date_c field should be updated to TODAY
	      //
	      // MSFDC-490
	      //  membership restore date should populate when user uncancel a membership from SFDC UI 
	      //  and when Membership__c/Cancellation_Type__c is updated to NOT NULL, membership restore date  should be null
	      //
	      if((oldRecord == null && m.Cancellation_Type__c != null) || 
	         (oldRecord != null 
	          && Utility.isChanged(oldRecord.Cancellation_Type__c, m.Cancellation_Type__c)
	          && oldRecord.Cancellation_Type__c == null
	          && m.Cancellation_Type__c != null)
	         ){
	         m.Cancellation_Date__c = System.Today();
	         m.Is_Auto_Renew__c = false;
	         m.Membership_Restore_Date__c = null;
	      }
	      
	      if((oldRecord == null && m.Cancellation_Type__c == null) || 
	         (oldRecord != null 
	          && Utility.isChanged(oldRecord.Cancellation_Type__c, m.Cancellation_Type__c)
	          && oldRecord.Cancellation_Type__c != null
	          && m.Cancellation_Type__c == null)
	         ){
	         m.Cancellation_Date__c = null;
	         if(m.Membership_Type__c == null || !m.Membership_Type__c.Contains('Complimentary')){
	            m.Is_Auto_Renew__c = true;   
	         }
	         if(oldRecord != null){
	         	if(m.Membership_Restore_Date__c == null){
	               m.Membership_Restore_Date__c = System.Now();
	         	}            
	         }
	      }
	      
	      //New requirement
	      if(oldRecord != null 
	       && (m.Cancellation_Type__c == 'RH Terminated' || m.Cancellation_Type__c == 'Member Terminated')
	         && m.Membership_Card_Opt_in__c == TRUE
	         && m.Member_Card_Address__c != null
	         && m.Member_Card_Status__c == 'Scheduled'
	         && (m.RRD_Membership_Status__c == Null || m.RRD_Membership_Status__c == 'MC')
	         && m.Member_Card_Scheduled_Request_Date__c >= System.TODAY()
	        ){
	            m.Member_Card_Status__c = null;
	            m.RRD_Membership_Status__c = null;
	            m.Member_Card_Scheduled_Request_Date__c = null;       
	      }   
	       
	      /* Note: Not updating the AutoRenew flag for RH Cancelled reasons,
	         so as to preserve customer's original AutoRenew selection if a Salesforce user cancels membership , 
	         realizes this was an error, and then un-cancels.
	         At time of renewal, we won't renew any RH Cancelled memberships. */     
   		}
   
   }	

   public static void setMemberNumber(List<Membership__c> memberships){
      MembershipNumber__c madj = MembershipNumber__c.getOrgDefaults();
      List<Membership__c> updateMemberships = new List<Membership__c>();
      Set<Id> membershipIds = (new Map<Id,SObject>(memberships)).keySet();      
      for(Membership__c m:[SELECT Id, Name, Member_ID__c from Membership__c where Id in :membershipIds]){
          String membershipName = String.valueOf(Integer.valueOf(m.Member_ID__c) + Integer.ValueOf(madj.Adjustor__c));
          m.Name = membershipName;
          m.MembershipExternalID__c = membershipName; // For Himanshu, who did not want to use Name
          updateMemberships.add(m);
      }
      if(!updateMemberships.isEmpty()){
         update updateMemberships;
      }
   }

   public static void attachEmail(List<Membership__c> memberships, Map<Id, Membership__c> oldMap){
      Map<String, AdminUser__c> adminUser = AdminUser__c.getAll();
      Map<String, AdminUser__c> integrationUser = new Map<String, AdminUser__c>();
      for(AdminUser__c au:adminUser.values()){
          if(au.IntegrationUser__c){
            integrationUser.put(au.Name, au);
          }
      }
      Map<Id, String> mapMembership = new Map<Id, String>();
      for(Membership__c m:memberships){
         Membership__c oldMembership;
         if(oldMap != null){
            oldMembership = oldMap.get(m.Id);
         }
         if((oldMembership == null && m.Welcome_Email_Requested_Datetime__c != null)
           || (oldMembership == null && integrationUser.ContainsKey(m.LastModifiedById)) // ContainsKey(UserInfo.getUserId())) in PMembershi
           || (oldMembership != null && Utility.isChanged(String.valueOf(oldMembership.Welcome_Email_Requested_Datetime__c), String.valueOf(m.Welcome_Email_Requested_Datetime__c)))){
            mapMembership.put(m.Id, m.Name);
         }
      }
      if(!mapMembership.isEmpty()){
         processAttachment(mapMembership, 'RHMembershipWelcomeEmail', 'RH Membership Welcome Email - Member ', null);
      }
   }
                     
   public static void attachEmailExpCC(List<Membership__c> memberships, Map<Id, Membership__c> oldMap){
      Map<Id, String> mapMembership = new Map<Id, String>();
      Map<Id, Integer> mapMembershipDaysNotice = new Map<Id, Integer>();
       
      for(Membership__c m:memberships){
         Membership__c oldMembership;
         if(oldMap != null){
            oldMembership = oldMap.get(m.Id);
         }
         if((oldMembership == null && m.Renewal_Reminder_Email_Sent_Date__c!= null)
           || (oldMembership != null && Utility.isChanged(String.valueOf(oldMembership.Renewal_Reminder_Email_Sent_Date__c), String.valueOf(m.Renewal_Reminder_Email_Sent_Date__c)))){
            mapMembership.put(m.Id, m.Name);
            
            if(m.Renewal_Email_Notification__c == '60-Day Notice'){
               mapMembershipDaysNotice.put(m.Id, 60);
            }
            if(m.Renewal_Email_Notification__c == '30-Day Notice'){
               mapMembershipDaysNotice.put(m.Id, 30);
            }
            if(m.Renewal_Email_Notification__c == '5-Day Notice'){
               mapMembershipDaysNotice.put(m.Id, 5);
            }
            if(m.Renewal_Email_Notification__c == '3-Day Notice'){
               mapMembershipDaysNotice.put(m.Id, 3);
            }
            if(m.Renewal_Email_Notification__c == '1-Day Notice'){
               mapMembershipDaysNotice.put(m.Id, 1);
            }
            if(m.Renewal_Email_Notification__c == '1-Day Post Expiration'){
               mapMembershipDaysNotice.put(m.Id, -1);
            }
            
         }
      }
      if(!mapMembership.isEmpty()){
      	 processAttachmentSynchronous(mapMembership, 'RHMembershipRenewalExpCCEmail', '', mapMembershipDaysNotice);
      }
   }
   
   public static String attName(Membership__c m){
     	 String attNameContext = '';
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
   	     return attNameContext;
   }
   
   public static void processAttachmentSynchronous(Map<Id, String> membershipIdMap, String vfPage, String attName, Map<Id, Integer> mapMembershipDaysNotice){
      Map<Id, Membership__c> mapMembership = new Map<Id, Membership__c>();
      for(Membership__c m:[SELECT Id, Name, Has_Valid_CC__c, Latest_CC_Expiration_Date__c, Is_Auto_Renew__c FROM Membership__c where Id in :membershipIdMap.keySet()]){
      	 mapMembership.put(m.Id, m);
      }      
      for(Id mId:membershipIdMap.keySet()){
      	    attName = '';
      	    if(mapMembership.ContainsKey(mId)){
      	    	attName = MembershipService.attName(mapMembership.get(mId));
      	    }
            Blob pageContent;
            if (!Test.isRunningTest()) {
               pageContent = new PageReference('/apex/' + vfPage + '?Id=' + mId).getContent();
            } else {
               pageContent = Blob.valueOf('Test Class');
            }
            Attachment attach = new Attachment();
            attach.ParentId = mId;
            if(mapMembershipDaysNotice != null && mapMembershipDaysNotice.containsKey(mId)){
               attName = '(' + String.valueOf(mapMembershipDaysNotice.get(mId)) + ' Day Notice) - ' + attName;
            }
            attach.name = attName + membershipIdMap.get(mID) + '.html';
            attach.body = pageContent;           
            insert attach;
       }
   }
   
   @future(callout=true)
   public static void processAttachment(Map<Id, String> membershipIdMap, String vfPage, String attName, Map<Id, Integer> mapMembershipDaysNotice){
	      Map<Id, Membership__c> mapMembership = new Map<Id, Membership__c>();
	      for(Membership__c m:[SELECT Id, Name, Has_Valid_CC__c, Latest_CC_Expiration_Date__c, Is_Auto_Renew__c FROM Membership__c where Id in :membershipIdMap.keySet()]){
	      	 mapMembership.put(m.Id, m);
	      }
	      for(Id mId:membershipIdMap.keySet()){
		      	attName = '';
	      	    if(mapMembership.ContainsKey(mId)){
	      	    	attName = MembershipService.attName(mapMembership.get(mId));
	      	    }
	            Blob pageContent;
	            if (!Test.isRunningTest()) {
	               pageContent = new PageReference('/apex/' + vfPage + '?Id=' + mId).getContent();
	            } else {
	               pageContent = Blob.valueOf('Test Class');
	            }
	            Attachment attach = new Attachment();
	            attach.ParentId = mId;
	            if(mapMembershipDaysNotice != null && mapMembershipDaysNotice.containsKey(mId)){
	               attName = '(' + String.valueOf(mapMembershipDaysNotice.get(mId)) + ' Day Notice) - ' + attName;
	            }
	            attach.name = attName + membershipIdMap.get(mID) + '.html';
	            attach.body = pageContent;           
	            insert attach;
	       }
   }
   
   public static Boolean isValid(Membership__c m){
      if(((m.Expiration_Date_Time__c != null 
          && m.Expiration_Date_Time__c >= System.Now()) || m.Expiration_Date_Time__c == null)
         && m.Enrollment_Date_Time__c != null 
         && m.Enrollment_Date_Time__c <= System.Now()){
          return true;
      }
      return false;
   }
   
   public static void monitorEligibleForMemberBenefits(List<Membership__c> memberships, Map<Id, Membership__c> oldMap){
   	  Map<String, MembershipExpiration__c> graceMap = MembershipExpiration__c.getAll();
      MembershipExpiration__c expirationParams = graceMap.get('Default');
      Map<String, Boolean> mapMembership = new Map<String, Boolean>();
      for(Membership__c m:memberships){
         Membership__c oldMembership = oldMap.get(m.Id);
         if(Utility.isChanged(String.valueOf(oldMembership.Enrollment_Date_Time__c), String.valueOf(m.Enrollment_Date_Time__c))){
            if(m.Enrollment_Date_Time__c == null || m.Enrollment_Date_Time__c > System.Now()){
               mapMembership.put(m.Name, false);
            }
            if(isValid(m)){
               mapMembership.put(m.Name, true);
            }
         }
         if(Utility.isChanged(String.valueOf(oldMembership.Expiration_Date_Time__c), String.valueOf(m.Expiration_Date_Time__c))){
            if(m.Expiration_Date_Time__c != null && m.Expiration_Date_Time__c < System.Now()){
               mapMembership.put(m.Name, false);
            }
            if(isValid(m)){
               if(!mapMembership.ContainsKey(m.Name)){
                  mapMembership.put(m.Name, true);
               }
            }
         }
            
         if(Utility.isChanged(String.valueOf(oldMembership.Cancellation_Reason__c), String.valueOf(m.Cancellation_Reason__c)) || (m.Eligible_for_Member_Benefits__c != oldMembership.Eligible_for_Member_Benefits__c)){        
            if(m.Cancellation_Type__c != expirationParams.Cancellation_Type__c && m.Cancellation_Type__c != 'Pending'){ // To avoid asynchronous call from expiration batch job or from asynchronous CCD processing.
	            if(m.Cancellation_Type__c == 'RH Terminated' 
	               || m.Cancellation_Type__c == 'Member Terminated'
	               || !isValid(m)){
	               mapMembership.put(m.Name, false);
	            }
	            if(m.Cancellation_Type__c != 'RH Terminated' 
	               && m.Cancellation_Type__c != 'Member Terminated'
	               && isValid(m)){
	               if(!mapMembership.ContainsKey(m.Name)){
	                  mapMembership.put(m.Name, true);
	               }
	            }
            }
         }            
      }
      if(!mapMembership.isEmpty()){
         updateEligibleForMemberBenefits(mapMembership);
         updateMembershipContactEligibility(mapMembership);
      }                 
   }
   
   public static void updateMembershipContactEligibility(Map<String, Boolean> mapMembersFlag) {
    
        // 1. Get the list of members that we are setting to be illegible
        List<String> illegibleMembers = new List<String>();
        for (String memberName : mapMembersFlag.keySet()) {
            if (!mapMembersFlag.get(memberName)) {
                system.debug('add member as illegible: ' + memberName);
                illegibleMembers.add(memberName);               
            }
        }   
        
        // 2. Get the list of Contacts that are related to that list of members
        List<Membership__c> illegibleMemberContacts = [SELECT Contact__c FROM Membership__c WHERE Name IN :illegibleMembers];
        system.debug('got list of illegible member contacts: ' + illegibleMemberContacts);
        
        // 3. Set those contacts to be illegible
        Map<ID, Contact> illegibleContacts = new Map<ID, Contact>();
        for (Membership__c memberContact : illegibleMemberContacts) {
            if (memberContact.Contact__c != NULL) {
                if (!illegibleContacts.containsKey(memberContact.Contact__c)) {
                    system.debug('add contact as illegible: ' + memberContact.Contact__c);          
                    illegibleContacts.put(memberContact.Contact__c, new Contact(
                        ID = memberContact.Contact__c,
                        Has_Membership__c = false
                    ));
                }
            }
        }
        
        // 4. Update those contacts
        system.debug('update contacts: ' + illegibleContacts.values());
        if (illegibleContacts.values().size() > 0) {
            database.update(illegibleContacts.values());
        }
    }   
	
	public static void handleMembershipContactChange(List<Membership__c> records, Map<ID, Membership__c> oldMap) {
		
		// 1. only care about updates
		if (oldMap == null) {
			return;
		}
		
		// 2. create updated contact records for the contacts related to the change
		
		Map<ID, Contact> contactsChanged = new Map<ID, Contact>();
		for (Membership__c membership : records) {			
			ID oldContactId = oldMap.get(membership.Id).Contact__c;
			if (oldContactId != membership.Contact__c) {
				// set the new contact to have membership
				contactsChanged.put(membership.Contact__c, new Contact(
					ID = membership.Contact__c,
					Has_Membership__c = true
				));
				if (oldContactId != null) {						
					// set the old contact to not have membership
					contactsChanged.put(oldContactId, new Contact(
						ID = oldContactId,
						Has_Membership__c = false
					));		
				}
			}			
		}
		
		// 3. update the contacts related to the changed membership
		
		Utility.logUpdate(contactsChanged.values()); 
	}     
   
   public static void updateEligibleForMemberBenefitsSynchronous(Map<String, Boolean> mapMembersFlag){
      // https://servicesuat.restorationhardware.com:10000/EligibleForMemberBenefits?memberId=<>&flag=true/false
      Set<String> failures = new Set<String>();
      Set<String> successes = new Set<String>();
      for(String membershipNumber: mapMembersFlag.keySet()){      
         String url = '';
         if(Test.isRunningTest()){
            url = 'https://servicesuat.restorationhardware.com:10000//EligibleForMemberBenefits?memberId=123&flag=true';
         }else{
            RH_Web_Services__c dataSource = RH_Web_Services__c.getInstance('EligibleForMemberBenefits');   
            url = dataSource.Service_URL__c + membershipNumber + '&flag=' + mapMembersFlag.get(membershipNumber);
         }
         try{
            HttpResponse response = CWCalloutService.doCallout(url);
            System.Debug(LoggingLevel.Error, 'RESPONSE =====> ' + response);
            if(response.getStatusCode() != 200){
               failures.add(membershipNumber);
            }else{
               successes.add(membershipNumber);
            }            
         }catch(Exception ex){
            failures.add(membershipNumber);
         }
      } 
      if(!failures.isEmpty()){
         List<Membership__c> reprocess = new List<Membership__c>();
         for(Membership__c m:[SELECT Id, Name, ReprocessBatch__c from Membership__c where Name in :failures]){
             m.ReprocessBatch__c = true;
             reprocess.add(m);
         }
         if(!reprocess.isEmpty()){
            update reprocess;
         }
      }       
      if(!successes.isEmpty()){
         List<Membership__c> reprocessed = new List<Membership__c>();
         for(Membership__c m:[SELECT Id, Name, ReprocessBatch__c from Membership__c where Name in :successes]){
             if(m.ReprocessBatch__c){
                m.ReprocessBatch__c = false;
                reprocessed.add(m);
             }
         }
         if(!reprocessed.isEmpty()){
            update reprocessed;
         }
      }
   }
   
   @Future(callout=true)
   public static void updateEligibleForMemberBenefits(Map<String, Boolean> mapMembersFlag){
      // https://servicesuat.restorationhardware.com:10000/EligibleForMemberBenefits?memberId=<>&flag=true/false
      Set<String> failures = new Set<String>();
      Set<String> successes = new Set<String>();
      for(String membershipNumber: mapMembersFlag.keySet()){      
         String url = '';
         if(Test.isRunningTest()){
            url = 'https://servicesuat.restorationhardware.com:10000//EligibleForMemberBenefits?memberId=123&flag=true';
         }else{
            RH_Web_Services__c dataSource = RH_Web_Services__c.getInstance('EligibleForMemberBenefits');   
            url = dataSource.Service_URL__c + membershipNumber + '&flag=' + mapMembersFlag.get(membershipNumber);
         }
         try{
            HttpResponse response = CWCalloutService.doCallout(url);
            if(response.getStatusCode() != 200){
               failures.add(membershipNumber);
            }else{
               successes.add(membershipNumber);
            }            
         }catch(Exception ex){
            failures.add(membershipNumber);
         }
      } 
      if(!failures.isEmpty()){
         List<Membership__c> reprocess = new List<Membership__c>();
         for(Membership__c m:[SELECT Id, Name, ReprocessBatch__c from Membership__c where Name in :failures]){
             m.ReprocessBatch__c = true;
             reprocess.add(m);
         }
         if(!reprocess.isEmpty()){
            update reprocess;
         }
      }       
      if(!successes.isEmpty() || Test.isRunningTest()){
         List<Membership__c> reprocessed = new List<Membership__c>();
         for(Membership__c m:[SELECT Id, Name, ReprocessBatch__c from Membership__c where Name in :successes]){
             if(m.ReprocessBatch__c){
                m.ReprocessBatch__c = false;
                reprocessed.add(m);
             }
         }
         if(!reprocessed.isEmpty()){
            update reprocessed;
         }
      }
   }
   
   public static Datetime expDate(Datetime enroll){
      if(enroll.Month() == 2 && enroll.Day() == 29){ // LeapYearMath
         return Datetime.newInstance(enroll.Year() + 1, 3, 1);
      }else{
         return Datetime.newInstance(enroll.Year() + 1, enroll.Month(), enroll.Day(), enroll.Hour(), enroll.Minute(), enroll.Second());
      }
   }
   
   public static Datetime expDateMonthly(Datetime enroll){
      if(enroll.Month() == 2 && enroll.Day() == 29){ // LeapYearMath
         return Datetime.newInstance(enroll.Year() + 1, 3, 31);
      }else{
         Integer yr;
         Integer mo;
         if(enroll.Month() == 12){
            yr = enroll.Year() + 1;
            mo = 1;
         }else{
            yr = enroll.Year();
            mo = enroll.Month() + 1;
         }
         return Datetime.newInstance(yr, mo, enroll.Day(), enroll.Hour(), enroll.Minute(), enroll.Second());
      }
   }
   
   public static String addressFormat(Membership__c m, String addrType){
      String addr = '';
      if(addrType == 'Member'){ 
         String addr2 = (m.Member_Street_2__c == null)?'':m.Member_Street_2__c;
         if(m.Member_Street_1__c == '' || m.Member_Street_1__c == null || m.Member_Street_1__c == '-'){
            addr = null;
         }else{
         	addr = m.Member_Street_1__c + ' ' + addr2 + ' ' + m.Member_City__c + ', ' + m.Member_State__c + ' ' + m.Member_Postal_Code__c + ' ' + m.Member_Country__c;
         } 
      }
      if(addrType == 'Member Card'){
         String addr2 = (m.Member_Card_Street_2__c== null)?'':m.Member_Card_Street_2__c;
         if(m.Member_Card_Street_1__c == '' || m.Member_Card_Street_1__c == null || m.Member_Card_Street_1__c == '-'){
            addr = null;
         }else{
         	addr = m.Member_Card_Street_1__c + ' ' + addr2 + ' ' + m.Member_Card_City__c + ', ' + m.Member_Card_State__c + ' ' + m.Member_Card_Postal_Code__c + ' ' + m.Member_Card_Country__c;
         }
      }
      return addr;
   }
   
   public static Boolean addressChanged(Membership__c oldVal, Membership__c newVal, String addrType){
     if(oldVal == null){
       return true;
     }      
     if(addrType == 'Member'){ 
         if(Utility.isChanged(oldVal.Member_Street_1__c, newVal.Member_Street_1__c)
            || Utility.isChanged(oldVal.Member_Street_2__c, newVal.Member_Street_2__c)
            || Utility.isChanged(oldVal.Member_City__c, newVal.Member_City__c)
            || Utility.isChanged(oldVal.Member_State__c, newVal.Member_State__c)
            || Utility.isChanged(oldVal.Member_Postal_Code__c, newVal.Member_Postal_Code__c)
            || Utility.isChanged(oldVal.Member_Country__c, newVal.Member_Country__c)){
            return true;
         }         
      }
      if(addrType == 'Member Card'){
         if(Utility.isChanged(oldVal.Member_Card_Street_1__c, newVal.Member_Card_Street_1__c)
            || Utility.isChanged(oldVal.Member_Card_Street_2__c, newVal.Member_Card_Street_2__c)
            || Utility.isChanged(oldVal.Member_Card_City__c, newVal.Member_Card_City__c)
            || Utility.isChanged(oldVal.Member_Card_State__c, newVal.Member_Card_State__c)
            || Utility.isChanged(oldVal.Member_Card_Postal_Code__c, newVal.Member_Card_Postal_Code__c)
            || Utility.isChanged(oldVal.Member_Card_Country__c, newVal.Member_Card_Country__c)){
            return true;
         }
      }
      return false;
   }
   
   public static void quebecoisCheck(List<Membership__c> memberships){
      for(Membership__c m:memberships){
         if(!m.Once_was_Quebecois__c){
            m.Once_was_Quebecois__c = MembershipService.livesInQuebec(m, false);
         }
      }
      
   }
   
   @future(callout=true)
   public static void setWelcomeEmailRequestDatetimeAsynchronously(Map<String, Datetime> membershipEmailDateMap){
      list<Membership__c> updateMemberships = new list<Membership__c>();
      for(Membership__c m:[SELECT Id, Name, Member_Email__c, Send_To_Email__c, Welcome_Email_Requested_Datetime__c from Membership__c where Member_Email__c in :membershipEmailDateMap.KeySet()]){
         m.Welcome_Email_Requested_Datetime__c = membershipEmailDateMap.get(m.Member_Email__c);
         m.Send_To_Email__c = m.Member_Email__c;  
         updateMemberships.add(m);
      }
      if(!updateMemberships.isEmpty()){
         TriggerStopper.stopMembership = true;
         update updateMemberships;
      } 
   }
   
   public static Map<Id, String> validationRules(List<Membership__c> memberships, Map<Id, Membership__c> oldMap){
      //
      // VRs moved to a trigger, per MSFDC-582
      //
      //
      // Logic specific to Admin/API Only Profiled Users
      //
      Map<String, AdminOrAPIOnlyProfile__c> adminAndApiOnlyProfiles = AdminOrAPIOnlyProfile__c.getAll();
      Map<String, MembershipValidation__c> membershipValidation = MembershipValidation__c.getAll();
      Map<String, AdminUser__c> adminUser = AdminUser__c.getAll();
      Map<String, AdminUser__c> integrationUser = new Map<String, AdminUser__c>();
      for(AdminUser__c au:adminUser.values()){
          if(au.IntegrationUser__c){
            integrationUser.put(au.Name, au);
          }
      }
      MembershipVRExcludedUser__c VRExclusions = MembershipVRExcludedUser__c.getOrgDefaults();
      Map<Id, String> errorMessagesVR = new Map<Id, String>();
      list<Membership__c> membershipTouchedByNONAdminNONApiOnly = new list<Membership__c>();
      Map<String, Datetime> membershipEmailDateMap = new Map<String, Datetime>();
      
      for(Membership__c m:memberships){
         if(!adminAndApiOnlyProfiles.ContainsKey(Userinfo.getProfileId()) && !adminUser.ContainsKey(UserInfo.getUserId())){
            membershipTouchedByNONAdminNONApiOnly.add(m);         
         }      
         if(oldMap == null && integrationUser.ContainsKey(UserInfo.getUserId())){
            membershipEmailDateMap.put(m.Member_Email__c, (m.Welcome_Email_Requested_Datetime__c == null) ? System.Now() : m.Welcome_Email_Requested_Datetime__c);
            m.Welcome_Email_Requested_Datetime__c = null; // DO NOT TRIGGER EMAIL ON INSERT SYNCHRONOUSLY.  INSTEAD collect values and CALL ASYNCHRONOUS METHOD TO HANDLE IT (MSFDC-584)
         }
      }
      System.Debug(LoggingLevel.Error, 'membershipEmailDateMap===== '+membershipEmailDateMap);
      if(!membershipEmailDateMap.isEmpty()){
        MembershipService.setWelcomeEmailRequestDatetimeAsynchronously(membershipEmailDateMap);
      }
         
      if(!membershipTouchedByNONAdminNONApiOnly.isEmpty()){
         for(Membership__c m:membershipTouchedByNONAdminNONApiOnly ){
            Membership__c oldMembership;
            if(oldMap != null){
               oldMembership = oldMap.get(m.Id);
            }
            // CancelReasonReqdwithCancelType
            if(!String.isBlank(m.Cancellation_Type__c) && String.isBlank(m.Cancellation_Reason__c)){
               if(membershipValidation.ContainsKey('CancelReasonReqdwithCancelType') && membershipValidation.get('CancelReasonReqdwithCancelType').Active__c){
                  errorMessagesVR.put(m.Id, membershipValidation.get('CancelReasonReqdwithCancelType').Message__c);
               }               
            }
            // CannotCreateCompMemberships
            if((VRExclusions.UserId__c == null || !VRExclusions.UserId__c.Contains(UserInfo.getUserName()))
               && ((oldMembership == null || Utility.isChanged(oldMembership.Membership_Type__c, m.Membership_Type__c))
               && (m.Membership_Type__c == 'Complimentary - PR' || m.Membership_Type__c == 'Complimentary - VIP'))){
               if(membershipValidation.ContainsKey('CannotCreateCompMemberships') && membershipValidation.get('CannotCreateCompMemberships').Active__c){
                  errorMessagesVR.put(m.Id, membershipValidation.get('CannotCreateCompMemberships').Message__c);
               }             
            }
            // CannotEditMuleUserCreatedMemberships 
            if(oldMembership != null
               && integrationUser.ContainsKey(m.CreatedById)
               && (Utility.isChanged(oldMembership.Membership_Type__c, m.Membership_Type__c) || Utility.isChanged(String.valueOf(oldMembership.Agreed_T_C__c), String.valueOf(m.Agreed_T_C__c)))){
               if(membershipValidation.ContainsKey('CannotEditMuleUserCreatedMemberships') && membershipValidation.get('CannotEditMuleUserCreatedMemberships').Active__c){
                  errorMessagesVR.put(m.Id, membershipValidation.get('CannotEditMuleUserCreatedMemberships').Message__c);
               }             
            } 
            // CannotSaveWOAgreedTC
            if(oldMembership == null
               && m.Membership_Type__c == 'Paid'
               && !m.Agreed_T_C__c){
               if(membershipValidation.ContainsKey('CannotSaveWOAgreedTC') && membershipValidation.get('CannotSaveWOAgreedTC').Active__c){
                  errorMessagesVR.put(m.Id, membershipValidation.get('CannotSaveWOAgreedTC').Message__c);
               }             
            } 
            
            // CantEditMemberID
            if(oldMembership != null
               && Utility.isChanged(oldMembership.Name, m.Name)
               && oldMembership.Name != 'Automated'){
               if(membershipValidation.ContainsKey('CantEditMemberID') && membershipValidation.get('CantEditMemberID').Active__c){
                  errorMessagesVR.put(m.Id, membershipValidation.get('CantEditMemberID').Message__c);
               }             
            } 
            // ContactNotBlankforCompMemberships
             if((m.Membership_Type__c == 'Complimentary - PR' || m.Membership_Type__c == 'Complimentary - VIP')
                && m.Contact__c == null){
               if(membershipValidation.ContainsKey('ContactNotBlankforCompMemberships') && membershipValidation.get('ContactNotBlankforCompMemberships').Active__c){
                  errorMessagesVR.put(m.Id, membershipValidation.get('ContactNotBlankforCompMemberships').Message__c);
               }             
            }  
            // MemberAddressFieldsCannotbeBlank
            if(m.Membership_Type__c == 'Paid'
                && (String.isBlank(m.Member_Street_1__c)
                    || String.isBlank(m.Member_City__c)
                    || (String.isBlank(m.Member_State__c) && NA_COUNTRIES.contains(m.Member_Country__c))
                    || String.isBlank(m.Member_Postal_Code__c)
                    || String.isBlank(m.Member_Country__c))){
               if(membershipValidation.ContainsKey('MemberAddressFieldsCannotbeBlank') && membershipValidation.get('MemberAddressFieldsCannotbeBlank').Active__c){
                  errorMessagesVR.put(m.Id, membershipValidation.get('MemberAddressFieldsCannotbeBlank').Message__c);
               }             
            }  
            // MemberCardCountry2Chars
            if(m.Member_Card_Country__c != null && m.Member_Card_Country__c.length() > 2){
               if(membershipValidation.ContainsKey('MemberCardCountry2Chars') && membershipValidation.get('MemberCardCountry2Chars').Active__c){
                  errorMessagesVR.put(m.Id, membershipValidation.get('MemberCardCountry2Chars').Message__c);
               }             
            }  
            // PhoneOrderCheckedforSomeApplications
            if(m.Phone_Order__c
               && (m.Created_by_Application__c == 'RH - Web'
                   || m.Created_by_Application__c == 'RHBC - Web'
                   || m.Created_by_Application__c == 'RHTN - Web'
                   || m.Created_by_Application__c == 'RHMO - Web'
                   || m.Created_by_Application__c == 'MAUI')){
               if(membershipValidation.ContainsKey('PhoneOrderCheckedforSomeApplications') && membershipValidation.get('PhoneOrderCheckedforSomeApplications').Active__c){
                  errorMessagesVR.put(m.Id, membershipValidation.get('PhoneOrderCheckedforSomeApplications').Message__c);
               }             
            }  
            // ScheduledDateCannotbeTodayorPast
            if(oldMembership != null
               && Utility.isChanged(String.valueOf(oldMembership.Member_Card_Scheduled_Request_Date__c), String.valueOf(m.Member_Card_Scheduled_Request_Date__c))
               && m.Member_Card_Scheduled_Request_Date__c <= System.Today()){
               if(membershipValidation.ContainsKey('ScheduledDateCannotbeTodayorPast') && membershipValidation.get('ScheduledDateCannotbeTodayorPast').Active__c){
                  errorMessagesVR.put(m.Id, membershipValidation.get('ScheduledDateCannotbeTodayorPast').Message__c);
               }             
            }  
            // ScheduledDateNotBlankforInFlightCards
            if(m.Member_Card_Scheduled_Request_Date__c == null
               && (m.Member_Card_Status__c == 'Request Sent' || m.Member_Card_Status__c == 'Card Sent')){
               if(membershipValidation.ContainsKey('ScheduledDateNotBlankforInFlightCards') && membershipValidation.get('ScheduledDateNotBlankforInFlightCards').Active__c){
                  errorMessagesVR.put(m.Id, membershipValidation.get('ScheduledDateNotBlankforInFlightCards').Message__c);
               }             
            } 
            // UpdateScheduledDateforAddressChanges
            if((m.Member_Card_Scheduled_Request_Date__c < m.Membership_Card_Ship_Date__c
               || m.Member_Card_Scheduled_Request_Date__c <= System.Today())
               && (Utility.isChanged(oldMembership.Member_Card_Street_1__c, m.Member_Card_Street_1__c)
                   || Utility.isChanged(oldMembership.Member_Card_Street_2__c, m.Member_Card_Street_2__c)
                   || Utility.isChanged(oldMembership.Member_Card_City__c, m.Member_Card_City__c)
                   || Utility.isChanged(oldMembership.Member_Card_State__c, m.Member_Card_State__c)                         
                   || Utility.isChanged(oldMembership.Member_Card_Postal_Code__c, m.Member_Card_Postal_Code__c)
                   || Utility.isChanged(oldMembership.Member_Card_Country__c, m.Member_Card_Country__c))){
               if(membershipValidation.ContainsKey('UpdateScheduledDateforAddressChanges') && membershipValidation.get('UpdateScheduledDateforAddressChanges').Active__c){
                  errorMessagesVR.put(m.Id, membershipValidation.get('UpdateScheduledDateforAddressChanges').Message__c);
               }             
            }               
         }      
      }
      for(Membership__c m:memberships){
         if(errorMessagesVR.ContainsKey(m.Id)){
            m.addError(errorMessagesVR.get(m.Id));
         }      
      } 
      
      return errorMessagesVR;  
   } 
   
   public static void UpdateOrderLineLevelInfo(Map<String, Order_Line_Items__c> orderLineMap){
      Map<String, Order_Line_Items__c> OLineMap = new Map<String, Order_Line_Items__c>();
      List<Membership__c> membershipsToUpdate = new List<Membership__c>();
      for(Order_Line_Items__c ol:[SELECT Id, Name, RH_Order_Number__c, Ship_to_Number__c, Line_Number__c // Requery since ship to is related field
                                    from Order_Line_Items__c 
                                   WHERE RH_Order_Number__c in :orderLineMap.keySet()]){
         OLineMap.put(ol.RH_Order_Number__c, ol);
      }
      if(!OLineMap.isEmpty()){
         for(Membership__c m:[SELECT Id, Created_by_Ship_To_Number__c, Created_by_Order_Line_Number__c, Created_by_Order_ID__c
                                FROM Membership__c
                               WHERE Created_by_Order_ID__c in :OLineMap.KeySet()]){
            m.Created_by_Ship_To_Number__c = OLineMap.get(m.Created_by_Order_ID__c).Ship_to_Number__c;
            m.Created_by_Order_Line_Number__c = OLineMap.get(m.Created_by_Order_ID__c).Name;
            membershipsToUpdate.add(m);         
         }
         if(!membershipsToUpdate.isEmpty()){
            update membershipsToUpdate;
         }
      }     
   
   }
   
   public static void UpdateDates(Set<Id> orderIds){
      /*
      At Order Line Insertion
       Trigger on Order Line when SKU is (read values from custom setting) a specific value
       AND line is created/updated to set that sku value
      THEN
        Part 4 - Green Screen (CW) Purchase
          AND if Enrollment Date = NULL
            Set Enrollment Date and Expiration Date per rules
      Part 5 - Un-Termination
        IF Cancellation_Type != NULL, then:
          Update Cancellation_Type  to NULL
          Cancellation_Reason  to NULL
          Cancellation_Date to NULL
          Set Enrollment Date and Expiration Date per rules (Note: Enrollment Date is ALREADY populated from the first enrollment)
      */
      Map<Id, RH_Order__c> orderMap = new Map<Id, RH_Order__c>();
      for(RH_Order__c o:[SELECT Id, Name, Membership_ID_Lookup__c 
                           from RH_Order__c 
                          where Id in :orderIds 
                            and Membership_ID_Lookup__c != null]){
         orderMap.put(o.Membership_ID_Lookup__c, o);
      }
      if(!orderMap.isEmpty()){
         List<Membership__c> membershipsToUpdate = new List<Membership__c>();
         for(Membership__c m:[select Id, Name, Enrollment_Date_Time__c, Expiration_Date_Time__c, 
                                     Cancellation_Type__c, Cancellation_Date__c, Cancellation_Reason__c,
                                     Created_By_Order_ID__c
                                from Membership__c
                               where Id in :orderMap.KeySet()]){
             //
             // This step supports the CW new purchase scenario described in MSFDC-163                  
             //
             Boolean isUpdated = false;
             if(m.Enrollment_Date_Time__c == null){
                m.Enrollment_Date_Time__c = System.Now();
                m.Expiration_Date_Time__c = expDate(m.Enrollment_Date_Time__c);
                isUpdated = true;
             }                 
             //
             // This step supports the CW re-instatement scenario described in MSFDC-355   
             //                                          
             if(m.Cancellation_Type__c != null
                && m.Created_By_Order_ID__c != null
                && orderMap.get(m.Id).Id != m.Created_By_Order_ID__c
             ){
                m.Cancellation_Type__c = null;
                m.Cancellation_Date__c = null;
                m.Cancellation_Reason__c = null;
                m.Expiration_Date_Time__c = expDate(System.Now()); 
                isUpdated = true;
             }             
             if(isUpdated){
                membershipsToUpdate.add(m);
             }
         }
         if(!membershipsToUpdate.isEmpty()){
             update membershipsToUpdate;
         }
      }
   
   }
    
   public static void SetDefaults(List<Membership__c> memberships, Map<Id, Membership__c> oldMap){
       //
       Map<String, AdminOrAPIOnlyProfile__c> adminAndApiOnlyProfiles = AdminOrAPIOnlyProfile__c.getAll();
       Map<String, MembershipValidation__c> membershipValidation = MembershipValidation__c.getAll();
       Map<String, AdminUser__c> adminUser = AdminUser__c.getAll();
       Map<String, AdminUser__c> integrationUser = new Map<String, AdminUser__c>();
       for(AdminUser__c au:adminUser.values()){
          if(au.IntegrationUser__c){
            integrationUser.put(au.Name, au);
          }
       }
       //
       for(Membership__c m:memberships){
        
        Membership__c oldRecord;
        if(oldMap != null){
           oldRecord = oldMap.get(m.Id);
        }
     
          if((oldRecord == null && !integrationUser.ContainsKey(UserInfo.getUserId()))
              || (oldRecord != null)){       // && !integrationUser.ContainsKey(UserInfo.getUserId()))){
          // Keep logic for manually entered memberships
          if(oldRecord == null){               
                if(m.Membership_Type__c != null && m.Membership_Type__c.Contains('Complimentary')){                    
                   m.Enrollment_Date_Time__c = System.Now();
                   m.Expiration_Date_Time__c = expDate(m.Enrollment_Date_Time__c); 
                   // MSFDC-403
                   // Is Auto Renew should be unchecked when creating new comp membership         
                   m.Is_Auto_Renew__c = false; 
                }
                //Member_Card_Scheduled_Request_Date__c
                if(m.Membership_Card_Opt_in__c == true){
                  m.Member_Card_Scheduled_Request_Date__c = System.Today().addDays(5);
                  m.Member_Card_Status__c = 'Scheduled';
                  m.Member_Card_Street_1__c = m.Member_Street_1__c;
                  m.Member_Card_Street_2__c = m.Member_Street_2__c;
                  m.Member_Card_City__c = m.Member_City__c;
                  m.Member_Card_State__c = m.Member_State__c;
                  m.Member_Card_Postal_Code__c = m.Member_Postal_Code__c;
                  m.Member_Card_Country__c = m.Member_Country__c;            
                }          
            }     
            
            //Set Address Field for Audit
            if(MembershipService.addressChanged(oldRecord, m, 'Member')){
                m.Member_Address__c = addressFormat(m, 'Member');   
            }         
            if(MembershipService.addressChanged(oldRecord, m, 'Member Card')){
                m.Member_Card_Address__c = addressFormat(m, 'Member Card'); 
            }
            
            // Restore Date Logic MSFDC-363
            Boolean alreadyChangedCancellationType = false;
            if(oldRecord != null 
               && m.Cancellation_Type__c == 'Member Cancelled'
               && Utility.isChanged(String.valueOf(oldRecord.Membership_Restore_Date__c), String.valueOf(m.Membership_Restore_Date__c))
               && oldRecord.Membership_Restore_Date__c == null
               && m.Membership_Restore_Date__c != null){
                    m.Cancellation_Type__c = null;
                    alreadyChangedCancellationType = true;
                    m.Cancellation_Date__c = null;
                    m.Cancellation_Reason__c = null;
                    m.Is_Auto_Renew__c = true;  
             }
             // MSFDC-364
             // MSFDC-490
             
             if((oldRecord == null && m.Cancellation_Type__c != null) || 
                (oldRecord != null 
                 && Utility.isChanged(oldRecord.Cancellation_Type__c, m.Cancellation_Type__c)
                 && oldRecord.Cancellation_Type__c == null
                 && m.Cancellation_Type__c != null
                 && !alreadyChangedCancellationType)){
                m.Cancellation_Date__c = System.Today();
                m.Is_Auto_Renew__c = false;
                m.Membership_Restore_Date__c = null;
            }
            if((oldRecord == null && m.Cancellation_Type__c == null) || 
               (oldRecord != null 
                && Utility.isChanged(oldRecord.Cancellation_Type__c, m.Cancellation_Type__c)
                && oldRecord.Cancellation_Type__c != null
                && m.Cancellation_Type__c == null
                && !alreadyChangedCancellationType)
               ){
               m.Cancellation_Date__c = null;
               if(m.Membership_Type__c == null || !m.Membership_Type__c.Contains('Complimentary')){
                  m.Is_Auto_Renew__c = true;   
               }
               if(oldRecord != null){
                 if(m.Membership_Restore_Date__c == null){
                     m.Membership_Restore_Date__c = System.Now();
                      
                 }            
               }
            }
            if(oldRecord != null 
             && (m.Cancellation_Type__c == 'RH Terminated' || m.Cancellation_Type__c == 'Member Terminated')
               && m.Membership_Card_Opt_in__c == TRUE
               && m.Member_Card_Address__c != null
               && m.Member_Card_Status__c == 'Scheduled'
               && (m.RRD_Membership_Status__c == Null || m.RRD_Membership_Status__c == 'MC')
               && m.Member_Card_Scheduled_Request_Date__c >= System.TODAY()
               && !alreadyChangedCancellationType
              ){
                  m.Member_Card_Status__c = null;
                  m.RRD_Membership_Status__c = null;
                  m.Member_Card_Scheduled_Request_Date__c = null;       
            }
            }
         }     
   }
   
   public static void ManageRenewal(Set<Id> ordersToCheck){
      
      /*
      SMR-85 -- When an Expired Member Purchases a Renewal SKU, this Reinstates the Membership (i.e. Sets AutoRenew to TRUE) 
      Updates AutoRenew to TRUE
      Updates the Expiration Date according to the rules for renewal expiration dates (See "When an Expired Member Successfully Renews, the Expiration Date is Updated to Renewal Date + Renewal Term" story)
      Updates Cancellation Type to EMPTY (if there was previously a Cancellation Type)
      Updates Cancellation Reason to EMPTY (if there was previously a Cancellation Reason)
      Updates Cancellation Date to EMPTY (if there was previously a Cancellation Date)
      Updates Reinstatement Date
      */
      
      Member_Renewal_SKU__c renewalSKUs = Member_Renewal_SKU__c.getOrgDefaults();
      Set<String> skus = MembershipService.skus(); 
      Map<String, RH_Order__c> mapMemberIdToOrder = new Map<String, RH_Order__c>();
      for(RH_Order__c o:[SELECT Id, Membership_ID__c, Membership_Renewal_Term__c,
                               (SELECT Id from Sales_Order_Line_Items__r WHERE CW_SKU_Name__c in :skus) 
                           from RH_Order__c 
                          WHERE Id in :ordersToCheck]){
         if((o.Membership_Renewal_Term__c != null && o.Sales_Order_Line_Items__r.size() == 0)
             || (o.Membership_Renewal_Term__c == null && o.Sales_Order_Line_Items__r.size() > 0)){
            mapMemberIdToOrder.put(o.Membership_ID__c, o);
         }
      }      
      
      list<Membership__c> memberships = new list<Membership__c>();
      for(Membership__c m:[select Id, Name, Enrollment_Date__c, Expiration_Date__c, Expiration_Date_Time__c, Once_was_Quebecois__c,
                                     Cancellation_Type__c, Cancellation_Date__c, Cancellation_Reason__c,
                                     Created_By_Order_ID__c, Member_State__c, Member_Country__c, Phone_Order__c, Renewal_Term__c
                                from Membership__c
                               where Name in :mapMemberIdToOrder.keySet()]){
                               
             Datetime newExpDateBasis;
             if (m.Cancellation_Reason__c == 'Member Cancelled' && m.Expiration_Date__c != null && m.Expiration_Date__c >= System.Today()){
                newExpDateBasis = m.Expiration_Date_Time__c;
             } else {
                newExpDateBasis = System.Now();
             }

             m.Is_Auto_Renew__c = true;             
             m.Expiration_Date_Time__c = expDate(newExpDateBasis);
             m.Cancellation_Type__c = null;
             m.Cancellation_Reason__c = null;
             m.Cancellation_Date__c = null;
             m.Membership_Restore_Date__c = System.Now();
             memberships.add(m);

      }
      if (!memberships.isEmpty()) {
         update memberships;
      }

   }
   
   public static void logiqueDesQuebecois(list<Membership__c> memberships, Map<Id, Membership__c> oldMap){
      for(Membership__c m:memberships){
         Membership__c oldMembership;
         if(oldMap != null){
            oldMembership = oldMap.get(m.Id);
         }
         if(oldMembership == null){
            if(MembershipService.livesInQuebec(m, false)){
               m.Renewal_Term__c = 'Annual'; //'Monthly'; not doing for now, until late 2017
            }else{
               m.Renewal_Term__c = 'Annual';
            }
         }
         //If address is updated to Quebec, update Renewal_Term__c to "Monthly" (if it is not already "Monthly")
         if(oldMembership != null
            && m.Renewal_Term__c != 'Monthly'
            && MembershipService.livesInQuebec(m, false)
            && !MembershipService.livesInQuebec(oldMembership, false)){
            m.Renewal_Term__c = 'Annual'; //'Monthly'; not doing for now, until late 2017
         }
         // If address is updated from Quebec to non-Quebec, update Renewal_Term_c to "Annual"
         // ONLY IF (Advised_of_monthly_renewalc = FALSE AND Converted_to_monthly_c = FALSE)
         if(oldMembership != null //not gonna fire for now, until late 2017 cause MONTHLY gone!!!!!
            && m.Renewal_Term__c == 'Monthly'
            && m.Renewal_Reminder_Email_Sent_Date__c == null
            && !MembershipService.livesInQuebec(m, false)
            && MembershipService.livesInQuebec(oldMembership, false)){
            m.Renewal_Term__c = 'Annual';
         }         
      } 
   }
   
   public static Boolean isQuebecois(Id membershipid, Boolean checkPhoneOrder){ 
     Boolean isQuebecois;
     Membership__c membership = [SELECT Id, Name, Phone_Order__c, Member_State__c, Member_Country__c
                                   from Membership__c
                                  where Id = :membershipid];
                        
     return MembershipService.livesInQuebec(membership, checkPhoneOrder);   
   }

   public static Boolean livesInQuebec(Membership__c membership, Boolean checkPhoneOrder){   
     // 'QC','QC.','Q.C.','QUE.','QUEBEC','QU�BEC'                    
     // 'CA','C.A.','CAN','C.A.N.','CANADA' 
     
     
     
     Quebecois__c q = Quebecois__c.getOrgDefaults();
     Set<String> provinceStrings = new Set<String>();
     Set<String> countryStrings = new Set<String>();
     
     for(String s:q.CountryValue__c.split(':')){
        countryStrings.add(s);
     }
     for(String s:q.ProvinceValue__c.split(':')){
        provinceStrings.add(s);
     }
          
     Boolean isQuebecois = false;
     if(((membership.Phone_Order__c && checkPhoneOrder) || !checkPhoneOrder) 
        && membership.Member_State__c != null
        && membership.Member_Country__c != null
        && provinceStrings.contains(membership.Member_State__c.toUpperCase()) 
        && countryStrings.contains(membership.Member_Country__c.toUpperCase())){        	
       isQuebecois = true;
     } 
     return isQuebecois;     
   }
   
   public static Boolean livesInCanada(Id membershipid){   
     Membership__c membership = [SELECT Id, Name, Phone_Order__c, Member_State__c, Member_Country__c
                                   from Membership__c
                                  where Id = :membershipid];
                          
	 return MembershipService.livesInCanada(membership);                                  
   }
   
	public static Boolean livesInCanada(Membership__c membership) {

     Quebecois__c q = Quebecois__c.getOrgDefaults();
     Set<String> countryStrings = new Set<String>();
     		
     for(String s:q.CountryValue__c.split(':')){
        countryStrings.add(s);
     }
     
     Boolean isCanadian = false;
     if(membership.Member_Country__c != null
        && countryStrings.contains(membership.Member_Country__c.toUpperCase())){
       isCanadian = true;
     } 
     return isCanadian;
          
   }
   
   public static String createGetPaymentRequest(String cwOrderId, String SourceValue, String callType) {
    
      // Create the GetPaymentDetails XML Request.
      String xmlString = null;
 
      XmlStreamWriter xml = new XmlStreamWriter();

      xml.writeStartDocument('UTF-8', '1.0');
      
      xml.writeStartElement(null, 'memberServiceRequest', null);

      xml.writeStartElement(null,'getPaymentMethodRequest', null);
        
      xml.writeStartElement(null,'cwOrderId', null);
      xml.writeCharacters(cwOrderId);
      xml.writeEndElement();
        
      xml.writeStartElement(null,'sourceType', null);
      xml.writeCharacters(SourceValue);
      xml.writeEndElement();
        
      xml.writeStartElement(null,'callType', null);
      xml.writeCharacters(callType);
      xml.writeEndElement();
           
      xml.writeEndElement();
      xml.writeEndElement();
       
      xmlString = xml.getXMLString();
      xml.close();
      
      return xmlString;
  }
  
  public static Date ccExpDate(String ccExpMMYYYY){
       try {
		   Integer yyyy = Integer.valueOf(ccExpMMYYYY.substring(3,7));
		   Integer mm = Integer.valueOf(ccExpMMYYYY.substring(0,2));
		   System.Debug(LoggingLevel.ERROR, 'CC put together for RH ====> ' + mm + '/' + yyyy);
		   Date d = Date.newInstance(yyyy, mm, 1);
		   Integer numberOfDays = Date.daysInMonth(d.Year(), d.Month());
		   return Date.newInstance(yyyy, mm, numberOfDays);
	   } catch (Exception ex) {
	   		return null;
	   }
  }
  
  public static Set<String> skus(){
  	 Member_Renewal_SKU__c renewalMembershipSkus = Member_Renewal_SKU__c.getOrgDefaults();
     Map<String, MembershipSKU__c> membershipSkus = MembershipSKU__c.getAll();       
     set<String> skus = new set<String>();
     for(String skuId:membershipSkus.keySet()){
        skus.add(membershipSkus.get(skuId).SKU__c);
     }
     skus.addAll(renewalMembershipSkus.SKU_Names__c.Split(':'));
  	 return skus;
  }
  
  public static Date creditCardExpDate(Membership__c m){
     Set<String> skus = MembershipService.skus(); 
     list<RH_Order__c> membershipOrders = new list<RH_Order__c>();
     for(RH_Order__c o:[SELECT Id, Name, 
                               (SELECT Id from Sales_Order_Line_Items__r WHERE CW_SKU_Name__c in :skus) 
                          from RH_Order__c WHERE Membership_Id__c = :m.Name
                          Order By CreatedDate Desc]){          
        membershipOrders.add(o);        
     }
     set<String> ordersToCheck = new Set<String>();
     for(RH_Order__c o:membershipOrders){
        if(o.Sales_Order_Line_Items__r.size() > 0){
            if(ordersToCheck.size() < 5){
               ordersToCheck.add(o.Name);
            }
        }
     }
     Date ccExpDate;
     
     // CALL getPaymentMethod API to see if valid CC exists and set ccExists AND ccExpired
     // Tied together all stories are here: SMR-91
     
     System.Debug('MemberService -> creditCardExpDate -> ' + ordersToCheck);
     for (String orderNumber : ordersToCheck) {     
    
         String ccExpMMYYYY;
         Boolean isSuccess = false;
      
         String xmlString = MembershipService.createGetPaymentRequest(orderNumber,'SF','MASK');          
         System.Debug(LoggingLevel.ERROR, 'XML Request ================> '+ xmlString);
    
         RH_Web_Services__c dataSource = RH_Web_Services__c.getInstance('getPaymentDetail');   
         String url = dataSource.Service_URL__c;
         HttpResponse response = CWCalloutService.doPostCallout(url, xmlString); 
         
         if (response != null) {         	
         	 try {
		         System.Debug(LoggingLevel.ERROR, 'XML response ================> '+ response );
		     
		         Dom.Document doc = new Dom.Document();
		         doc.load(response.getBody());         
		         System.Debug(LoggingLevel.ERROR, 'XML Response Body ================> '+ response.getBody());
		         Dom.XMLNode paymentMethodDetails = doc.getRootElement();       
		                   
		         for(Dom.XMLNode pmHeader : paymentMethodDetails.getChildElements()){                 
		            if(pmHeader.getName() == 'responseType'){
		                if(pmHeader.getText() == 'Success'){
		                    isSuccess = true;
		                } 
		            }
		            if(pmHeader.getName() == 'getPaymentMethodResponse'){       
		                for(Dom.XMLNode cc : pmHeader.getChildElements() ){  
		                    if(cc.getName() == 'creditCardExpiration'){
		                        ccExpMMYYYY = cc.getText();
		                        System.Debug(LoggingLevel.ERROR, 'CC Expiration MM/YYYY====> ' + ccExpMMYYYY);
		                    }
		                    System.Debug(LoggingLevel.ERROR, 'field====> '+ cc.getName());
		                }
		            } 
		         }
		         
		         if(isSuccess && ccExpMMYYYY != null){
		             if(ccExpMMYYYY.length() == 3){
		                ccExpMMYYYY = '0' + ccExpMMYYYY;
		                System.Debug(LoggingLevel.ERROR, 'CC Expiration MM/YYYY altered ====> ' + ccExpMMYYYY);
		             }
		             //Date d = Date.newInstance(Integer.valueOf(ccExpMMYYYY.substring(3,7)), Integer.valueOf(ccExpMMYYYY.substring(0,2)), 1);
		             Integer yyyy = Integer.valueOf(ccExpMMYYYY.substring(3,7));
		             Integer mm = Integer.valueOf(ccExpMMYYYY.substring(0,2));
		             System.Debug(LoggingLevel.ERROR, 'CC put together ====> ' + mm + '/' + yyyy);
		             Date d = Date.newInstance(yyyy, mm, 1);
		             Integer numberOfDays = Date.daysInMonth(d.Year(), d.Month());
		             ccExpDate = Date.newInstance(yyyy, mm, numberOfDays);
		             if(ccExpDate >= m.Expiration_Date__c){
		                return ccExpDate;
		             }
		         }
         	 } catch (Exception ex) {
				system.debug('failed to process cw response for membership: ' + m);
         	 }         	 
         }              
     }
     System.Debug('MemberService -> creditCardExpDate -> ' + ccExpDate);
     return ccExpDate;          
  } 
  
}