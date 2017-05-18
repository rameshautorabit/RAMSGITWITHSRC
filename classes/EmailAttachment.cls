public with sharing class EmailAttachment {
	
	public static void sendAttachments(Id LeadID){
		
		List<Attachment> attachments = [SELECT Id, Name, Body, ContentType FROM Attachment WHERE Parentid IN (Select Id from Lead where id = :leadID)];
		//':leadID';
		system.debug('@@attachments'+attachments);
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {'bhargavi.v@autorabit.com'};
		//simon.w@autorabit.com','vijay@autorabit.com
		email.setToAddresses(toAddresses);
		//email.setTargetObjectId(LeadID);
		//email.setTemplateId('00XF0000000k6MR');
		email.setSubject('Questionnaire Received');
		email.setPlainTextBody('Bar');
		
		List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
		if(attachments.size()>0){
			
			for(Attachment att : attachments) {
			
			Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
    		// You may need to do some work here to figure out the correct file extension
    		efa.setFileName(att.Name);
    		// Take the blob data from the Attachment and put it on the email.
    		efa.setBody(att.Body);
    		efa.setContentType(att.ContentType);
    		emailAttachments.add(efa);
    		}
    		
    		email.setFileAttachments(emailAttachments);
    		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    		}
		}
	}