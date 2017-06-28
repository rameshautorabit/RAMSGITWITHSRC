global class BatchMonitorMemberships implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
   
    global BatchMonitorMemberships(){}
    
    String query; 
    Integer membershipCount = 0; 
    Integer membershipUpdates = 0;
    global Boolean dmlOnly = FALSE;
    
    global database.queryLocator start(Database.BatchableContext BC) {
       //
       // Query to retrieve all Memberships that qualify for a checkup
       // NOT detected by The Trigger.
       //
       query = 'SELECT Id, Name, Enrollment_Date__c, Expiration_Date__c, Cancellation_Reason__c, Eligible_for_Member_Benefits__c, RRD_Membership_Status__c, Member_Card_Scheduled_Request_Date__c, ReprocessBatch__c';
       query += '  FROM Membership__c';
       query += ' WHERE (Expiration_Date__c != null';
       query += '        AND Expiration_Date__c < TODAY)';
       query += '    OR (Enrollment_Date__c != null';
       query += '        AND Enrollment_Date__c = TODAY)';
       query += '    OR Member_Card_Scheduled_Request_Date__c = TODAY';
       query += '    OR ReprocessBatch__c = TRUE';
       System.Debug('QUERY ====> ' + query );
       return database.getQueryLocator(query);
    }  
    
    global void execute(Database.BatchableContext BC, List<Membership__c> memberships) {
       membershipCount += memberships.size();
       Map<String, Boolean> membershipFlagMap = new Map<String, Boolean>(); 
       List<Membership__c> updateMemberships = new List<Membership__c>();
       for(Membership__c m:memberships){
           if(m.Enrollment_Date__c == System.Today() || m.ReprocessBatch__c){
              membershipFlagMap.put(m.Name, true);
           }
           if(m.Expiration_Date__c <= System.Today() || m.ReprocessBatch__c){
              membershipFlagMap.put(m.Name, false);
           }
           if(m.Member_Card_Scheduled_Request_Date__c == System.Today()){
              m.RRD_Membership_Status__c = 'MC';
              updateMemberships.add(m);
           }
       } 
       if(!updateMemberships.isEmpty() && dmlOnly){
          update updateMemberships;
       }      
       if(!membershipFlagMap.isEmpty() && !dmlOnly){
          membershipUpdates += membershipFlagMap.size(); 
          MembershipService.updateEligibleForMemberBenefitsSynchronous(membershipFlagMap);
       }
    }
    
    global void finish(Database.BatchableContext BC) {     
        //
        try{
           
           //if(setting.SendEmail__c){
              AsyncApexJob aaj = [Select Id, Status, NumberOfErrors, JobItemsProcessed, MethodName, TotalJobItems, CreatedBy.Email, CreatedDate
                                 from AsyncApexJob where Id = :BC.getJobId()];                                                     
              //                    
              Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
              String[] toAddresses = new String[] {aaj.CreatedBy.Email};
              mail.setToAddresses(toAddresses);
              mail.setSubject( 'Membership Eligible for Benefits Update Batch Job ' + aaj.Status);
              String bodyText = 'Number of batches processed ' + aaj.TotalJobItems +
                               ' with '+ aaj.NumberOfErrors + ' failures.\n';  
                               
              bodyText += 'Updated ' + membershipUpdates + ' Memberships.\n'; 
              bodyText += 'out of ' + membershipCount + ' Memberships queried.\n';
                               
              System.Debug(LoggingLevel.ERROR, 'Details==========: ' +  bodyText);  
              mail.setPlainTextBody( bodyText );
           
              Messaging.sendEmail( new Messaging.SingleEmailMessage[] { mail });
           //}
        }
        catch(Exception e)
        {
            System.Debug('Email Send Failed: ' + e.getMessage());
        }
    }
    
    
    
    
    
    
      
}