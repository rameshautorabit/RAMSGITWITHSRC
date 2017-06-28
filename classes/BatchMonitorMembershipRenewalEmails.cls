global class BatchMonitorMembershipRenewalEmails implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
                             
    global static Integer[] expirationDateList = new List<Integer>{ 60, 30, 5, 3, 1, -5, -1 };
    private Integer membershipCount = 0;  
    private Integer membershipUpdates = 0;
    private Integer jobNumber = 0;
    private Integer expirationDayCheckIndex = 0;
    private List<SObject> failedRecords = new List<SObject>();
    //private boolean disableFlag;
//test    
  /*
   * Instantiate a new batch class
   * Empty constructor is purely for backward compatibliity and should be removed after R17.01 goes live
   */
   
  global BatchMonitorMembershipRenewalEmails() {
    this.jobNumber = 0;
    this.expirationDayCheckIndex = 0;
  }  
  
  global BatchMonitorMembershipRenewalEmails(Integer job, Integer checkIndex) {
    this.jobNumber = job;
    this.expirationDayCheckIndex = checkIndex;
    //this.disableFlag = disableFlag;
  }
  
  /*
   * Get the query string
   */
        
    global String getQuery() {
      Integer expirationDay = BatchMonitorMembershipRenewalEmails.expirationDateList.get(this.expirationDayCheckIndex); 
        String dayToCheck = String.valueOf(System.Today().addDays(expirationDay)).substring(0,10);    //cadence list can be used for both expire and terminate 
        String query;
        
        System.debug('starting job -' + this.jobNumber + ' for cadence -' + expirationDay);
        
        //this query is to pull memberships based on candence for expiration date, needed to create new logic to handle cancellation date (query below)
        //if (this.jobNumber == 0 || this.jobNumber == 1 || this.jobNumber == 2)
        if (this.expirationDayCheckIndex != 6)
        {
          
          query = 'SELECT Id, Name, Enrollment_Date__c, Expiration_Date__c, Renewal_Reminder_Email_Sent_Date__c, Renewal_Term__c, Renewal_Email_Notification__c'
            + ', BC_Renewal_CC_Final_4_Digits__c, BC_Renewal_CC_Expiration_Date__c, RH_Renewal_CC_Final_4_Digits__c, RH_Renewal_CC_Expiration_Date__c, Has_Valid_CC__c'
            + ', Special_Enrollee__c, GetsChangedTandCs__c, Latest_CC_Expiration_Date__c, Created_By_Order_Id__c, Created_By_Order_Id__r.Name'
            + ', Renewal_Order_Entity_Code__c, RH_Renewal_CC_Entity_Code__c, BC_Renewal_CC_Entity_Code__c, Created_By_Order_Id__r.Division__c'
            + ', RH_Renewal_CC_Updated_DateTime__c, BC_Renewal_CC_Updated_DateTime__c, Is_Auto_Renew__c, Renew_Email_Opt_In__c, In_Target_Group__c, RenewalEmailSubjectLine__c'
            + ', Phone_Order__c, Member_State__c, Member_Country__c, Contact__c, CreatedDate'
            + ', Create_Renewal_Order__c, Contact__r.FirstName, Contact__r.LastName, Member_Email__c'
            + '  FROM Membership__c'
            + '  WHERE Cancellation_Type__c != \'Member Terminated\' AND Cancellation_Type__c != \'RH Terminated\''
            + '  AND (Membership_Type__c = NULL OR Membership_Type__c = \'Paid\')'  
            + '  AND Expiration_Date__c = ' + dayToCheck;       
        }
        //job for sending termination email notifications, query to pull memberships that were terminated +1 days ago, based on cancellation type/reason, cancellation date
        else if (this.expirationDayCheckIndex ==6)
          {
            System.debug('getting terminated memberss query results');
            
            query = 'SELECT Id, Name, Enrollment_Date__c, Expiration_Date__c, Renewal_Reminder_Email_Sent_Date__c, Renewal_Term__c, Renewal_Email_Notification__c'
            + ', BC_Renewal_CC_Final_4_Digits__c, BC_Renewal_CC_Expiration_Date__c, RH_Renewal_CC_Final_4_Digits__c, RH_Renewal_CC_Expiration_Date__c, Has_Valid_CC__c'
            + ', Special_Enrollee__c, GetsChangedTandCs__c, Latest_CC_Expiration_Date__c, Created_By_Order_Id__c, Created_By_Order_Id__r.Name'
            + ', Renewal_Order_Entity_Code__c, RH_Renewal_CC_Entity_Code__c, BC_Renewal_CC_Entity_Code__c, Created_By_Order_Id__r.Division__c'
            + ', RH_Renewal_CC_Updated_DateTime__c, BC_Renewal_CC_Updated_DateTime__c, Is_Auto_Renew__c, Renew_Email_Opt_In__c, In_Target_Group__c, RenewalEmailSubjectLine__c'
            + ', Phone_Order__c, Member_State__c, Member_Country__c, Contact__c, CreatedDate, Cancellation_Date__c '
            + ', Create_Renewal_Order__c, Contact__r.FirstName, Contact__r.LastName, Member_Email__c'
            + '  FROM Membership__c'
            + '  WHERE Cancellation_Type__c like \'RH Terminated\' AND Cancellation_Reason__c like \'Credit Card Decline\'' 
            + '  AND (Membership_Type__c = NULL OR Membership_Type__c = \'Paid\')'  
            + '  AND Cancellation_Date__c = ' + dayToCheck;           
            
            
          }
        
        
        
        return query;     
    }
    
    /*
     * Start the batch
     */
   
  global database.queryLocator start(Database.BatchableContext BC) {
    String query = this.getQuery();
    system.debug('BatchMonitorMembershipRenewalEmails -> start -> ' + this.jobNumber + ' -> ' + this.expirationDayCheckIndex + ' -> ' + query);                 
    return database.getQueryLocator(query);
  }  
  
  /*
   * Execute the batch - split into 3 batches to ensure we don't blow any SOQL limits
   * Job ONE : Assigns new expiration dates to the membership record
   * Job TWO : Assigns better expiration dates from CW if necessary
   * JOB THREE : Finds the membership records that need emails
   * JOB FOUR : Queries membership that have terminated + 1 day for email notifiation
   */
    
    global void execute(Database.BatchableContext BC, List<Membership__c> memberships) {
      
      system.debug('BatchMonitorMembershipRenewalEmails -> execute -> ' + this.jobNumber + ' -> ' + this.expirationDayCheckIndex + ' -> ' + memberships.size());
      
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
            
        system.debug('retrieve all membership records that require renewal emails');
          List<Membership__c> updateMemberships = MembershipRenewalService.buildRenewalMembershipRecords(memberships, 'renewal');
      if (!updateMemberships.isEmpty()) {
        system.debug('update the membership records -> ' + updateMemberships);
        this.failedRecords.addAll(Utility.logUpdate(updateMemberships));        
        system.debug('Insert the attachments');
        List<Attachment> attachments = MembershipRenewalService.buildAttachments(updateMemberships, 'renewal');
            Utility.logInsert(attachments);       
            system.debug('record number updated');
        membershipUpdates += updateMemberships.size();
          }         
      }  
      
      else if (this.jobNumber == 3) {
        
        membershipCount += memberships.size();  
            
        system.debug('retrieve terminated memberships');
          List<Membership__c> updateMemberships = MembershipRenewalService.buildRenewalMembershipRecords(memberships, 'terminate');
      if (!updateMemberships.isEmpty()) {
        system.debug('update the terminated membership records -> ' + updateMemberships);
        this.failedRecords.addAll(Utility.logUpdate(updateMemberships));        
        system.debug('Insert the attachments');
        List<Attachment> attachments = MembershipRenewalService.buildAttachments(updateMemberships, 'terminate');
            Utility.logInsert(attachments);       
            system.debug('record number updated');
        membershipUpdates += updateMemberships.size();
          }         
      }         
    }
    
    /*
     * Finish batch:
     * Either move onto the next batch or send email
     * Job ONE has to be run with a smaller batch size as this potentially makes call outs to CW for every membership record 
     * String of batches together, one calling another
     */
        
    global void finish(Database.BatchableContext BC) {   
      system.debug('BatchMonitorMembershipRenewalEmails -> finish -> ' + this.jobNumber + ' -> ' + this.expirationDayCheckIndex);   
      if (this.jobNumber ==  0 && this.expirationDayCheckIndex !=6 ) {        
        Database.executeBatch(new BatchMonitorMembershipRenewalEmails(1, this.expirationDayCheckIndex), 1);
      } else if (this.jobNumber == 1 && this.expirationDayCheckIndex !=6 ) {
        Database.executeBatch(new BatchMonitorMembershipRenewalEmails(2, this.expirationDayCheckIndex), 200);
        
      } 
      //only spawn the terminated email job if the cadence is +1 which is index 5 in the date array
      //spawn terminated job with new cadence index 6 and only when flag=true, will need to disable when cadence is modified to cover gap
      //else if (this.jobNumber ==2 && this.expirationDayCheckIndex==5 && !disableFlag)  {
      //  else if (this.expirationDayCheckIndex==)
      //        Database.executeBatch(new BatchMonitorMembershipRenewalEmails(3, this.expirationDayCheckIndex+1), 200); //termination job has a new cadence now, no longer sharing with expiry which is cadence 5
              
      else {           
      AsyncApexJob aaj = [
        Select Id, Status, NumberOfErrors, JobItemsProcessed, MethodName, TotalJobItems, CreatedBy.Email, CreatedDate
              from AsyncApexJob 
              where Id = :BC.getJobId()
      ];                                                     
  
      String daysOut = String.valueOf(BatchMonitorMembershipRenewalEmails.expirationDateList.get(this.expirationDayCheckIndex));
      String[] addresses = new String[] {aaj.CreatedBy.Email};
      String subject = daysOut + ' Days Out Membership Renewal CC Warning Batch Job ' + aaj.Status;              
      String bodyText =   'Number of batches processed ' + aaj.TotalJobItems + ' with '+ aaj.NumberOfErrors + ' failures.\n' +  
                              'Triggered emails for ' + membershipUpdates + ' Memberships.\n' + 'out of ' + membershipCount + ' Memberships queried.\n' +
                               (this.failedRecords.size() < 1 ? '' : 'Full list of Failed Records ' + JSON.serialize(this.failedRecords));
  
      Utility.sendEmail(addresses, bodyText, subject);
      }
    }
        
}