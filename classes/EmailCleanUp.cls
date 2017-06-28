public class EmailCleanUp {
    
    /*
     *  For each EmailMessage record that is associated with a Case record, 
     *  create a copy of the EmailMessage as an Attachment and associate it
     *  with the Case. Also, execute a future process that will delete the
     *  EmailMessage record.
     *
     */
     
    /*
    public static void EmailMessageToAttachment(List<EmailMessage> emails){

        List<Id> emIds = new List<Id>();
        List<Attachment> attList = new List<Attachment>();
        String messageBody;
        String contentType;
        
        List<EmailMessage> caseEmailsToProcess = new List<EmailMessage>();
        Set<Id> caseIds = new Set<Id>();
        for (EmailMessage em :emails) {    
           if (em.ParentId.getSobjectType().getDescribe().getName() == 'Case') {
              caseIds.add(em.ParentId);
           }        
           caseEmailsToProcess.add(em); 
        }
        //
        Set<Id> caseIdsToProcess = new Set<Id>();
        for(Case c:[SELECT Id, RecordType.Name
                      from Case 
                     where Id in :caseIds
                       and RecordType.Name != 'Email and Web Inquiries']){
            caseIdsToProcess.add(c.Id);
        }
        
        for (EmailMessage em :caseEmailsToProcess) {
            if (caseIdsToProcess.Contains(em.ParentId)) {
                emIds.add(em.Id);
                messageBody = ' ';
                contentType = 'text';
                if (em.HtmlBody != null) {
                    messageBody = em.HtmlBody;
                    contentType = 'html';
                } else {
                    if (em.TextBody != null) {
                        messageBody = em.TextBody;
                        contentType = 'text';
                    }
                }
                attList.add(new Attachment(
                    ParentId = em.ParentId,
                    Name = em.Subject,
                    ContentType = contentType,
                    Body = Blob.valueof(messageBody),
                    Description = 'System Generated Attachment'
                            + '\nSendGrid Email - Sent Message' 
                            + '\nFrom Name/Address = ' + em.FromName + '/' + em.FromAddress 
                            + '\nToAddress = ' + em.ToAddress 
                            + '\nCcAddress = ' + em.CcAddress 
                            + '\nBccAddress = ' + em.BccAddress 
                            + '\nMessageDate = ' + em.MessageDate 
                            + '\nHasAttachment = ' + em.HasAttachment 
                    )
                );
            }
        }
        
        // Create the Attachment record copies of the EmailMessage records and delete the EmailMessage records
        if (!attList.isEmpty()) {
            insert attList;
            EmailCleanUp.deleteEmail(emIds);
        } 
    
   }
   */
    
  /*
   *  Methods for cleaning up EmailMessage records
   *
   */
  
  /*
  @future
  public static void deleteEmail(List<Id> emIdList) {
    
    // Delete all EmailMessage records with the supplied Ids
    List<EmailMessage> emList = new List<EmailMessage>();
    for (Id emId :emIdList) {
      emList.add(new EmailMessage(Id = emId));
    }
    
    system.debug('EmailCleanUp about to delete ' + emList.size() + ' EmailMessage records');
    
    try {
      delete emList;
    } catch(Exception e) {
      system.debug('EmailCleanUp - delete exception = ' + e.getMessage());
    }
  }
  */
}