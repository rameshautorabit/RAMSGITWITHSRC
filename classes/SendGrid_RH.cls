global class SendGrid_RH {
	
	/*
	 *	Restoration Hardware specific helper methods for SendGrid.
	 *
	 */

	public SendGrid_RH() {}
	
	public class SendGrid_RH_Data {
		public Boolean SingleEmail {get; set;}
		public Boolean UseBcc {get; set;}
		public Boolean Email2Case {get; set;}
		public Boolean SubAll {get; set;}
		public String EmailName {get; set;}
		public List<String> Subjects {get; set;}
		public List<String> EmailFromName {get; set;}
		public List<String> EmailFrom {get; set;}
		public List<String> EmailTo {get; set;}
		public List<String> SubBody {get; set;}
		public Map<String, String> SubMap {get; set;}
		public String EmailTrackingId {get; set;}
		public String SendGridResult {get; set;}
		
		public SendGrid_RH_Data(Boolean se, Boolean ub, Boolean e2c, Boolean sa, String en, List<String> ss, List<String> efn, List<String> ef, List<String> et, List<String> sb, Map<String, String> sm, String etId) {
			SingleEmail = se;
			UseBcc = ub;
			Email2Case = e2c;
			SubAll = sa;
			EmailName = en;
			Subjects = ss;
			EmailFromName = efn;
			EmailFrom = ef;
			EmailTo = et;
			SubBody = sb;
			SubMap = sm;
			EmailTrackingId = etId;
			SendGridResult = null;
		}
	}
	
	// Based upon the data in SendGrid_RH_Data, send email messages via SendGrid
	//
	// TODO: implement SingleEmail=false, SubAll=false
	//
	public Boolean rhSendEmail(List<SendGrid_RH_Data> sgrhData) {
		Boolean success = true;
		Id rhProductionOrgId = '00D500000007MjVEAU';
		String sandboxSendToEmailAddress = null;
		String emailToCase = null;
		SendGrid_Email__c sge;
		Integer recipients;
		
		// Get the default sandbox send to address and the email2case address
		Account acc = new Account();
		acc = [select Id, Name from Account where RecordType.Name = 'Internal' and Name = 'SendGrid Email' and Type = 'System' limit 1];
		Contact con = new Contact();
		con = [select Id, Name, Email, Alternate_Email__c from Contact where AccountId = :acc.Id limit 1];
		emailToCase = con.Alternate_Email__c;
		
		// If we are not running in production, set the sandbox send to email address - must be domain rh.com
        if (UserInfo.getOrganizationId() != rhProductionOrgId) {
			if (con.Email != null && (con.Email.endsWith('@rh.com') || con.Email.endsWith('@restorationhardware.com'))) {
				sandboxSendToEmailAddress = con.Email;
			}
        }
		
		SendGrid_Credentials__c sgc = SendGrid_Credentials__c.getOrgDefaults();
		
		for (SendGrid_RH_Data sgd :sgrhData) {
			sge = SendGrid_Email__c.getInstance(sgd.EmailName);
			
			// Set up the SendGrid login credentials and the email template
			SendGrid sendgrid = new SendGrid(sgc.Username__c, sgc.Password__c);  
			SendGrid.email email = new SendGrid.Email();
			email.addFilter('templates', 'enable', '1');
			email.addFilter('templates', 'template_id', sge.Template_Id__c);
			
			recipients = 0;
			if (sgd.SingleEmail) {
				email.setFromName(sgd.EmailFromName[0]);
				email.setFrom(sgd.EmailFrom[0]);
				
				if (sgd.EmailTo[0] != 'PREVIEW') {
					if (UserInfo.getOrganizationId() != rhProductionOrgId) {
						for (String to :sgd.EmailTo) {
							if (String.isNotBlank(to) && (to.endsWith('@rh.com') || to.endsWith('@restorationhardware.com'))) {
								email.addTo(to);
							} else {
								email.addTo(sandboxSendToEmailAddress);
							}
							recipients++;
						}
					} else {
						email.addTo(sgd.EmailTo);
						recipients = sgd.EmailTo.size();
					}
					
					if (sgd.Email2Case) {
						email.addBcc(emailToCase);
						recipients++;
					}
					
					if (sgd.UseBcc) {
						email.addBcc(sgc.BCC_Email__c);
						recipients++;
					}
					
				} else {
					
					// Preview email - set To address to Email2Case address and/or BCC Email
					if (sgd.Email2Case) {
						email.addTo(emailToCase);
						recipients++;
					}
					
					if (sgd.UseBcc) {
						email.addTo(sgc.BCC_Email__c);
						recipients++;
					}
				}
				
				email.setSubject(sgd.Subjects[0]);
				email.setText(sgd.SubBody[0]);
				email.setHtml(sgd.SubBody[0]);
				
				substituteMultiple(email, sgd.SubMap, recipients);
				addRHEmailTracking(email, sgd.EmailTrackingId);
				
				if (!Test.isRunningTest()) {
					SendGrid.SendGridResponse response = sendgrid.send(email);
					if (response.success) {
						sgd.SendGridResult = 'SUCCESS - email type = ' + sgd.EmailName;
					} else {
						sgd.SendGridResult = 'FAILURE - email type = ' + sgd.EmailName + ', SendGrid response = ' + response;
						success = false;
					}
				} else {
					sgd.SendGridResult = 'SUCCESS - email type = ' + sgd.EmailName + ', Test';
				}
			}
		}
			
		return success;
	}
	
	// When using SendGrid to send an email using a SendGrid email template to multiple email addresses in
	// a single call to SendGrid, there must be a separate email template substitution value for each email
	// address (To, Cc, & Bcc).  This method calls the SendGrid addSubstitution method for each substitution value
	// for the number of email recipients.
	public SendGrid.Email substituteMultiple(SendGrid.Email email, Map<String, String> subMap, Integer recipientCount) {
		List<String> subList;
		for (String key :subMap.keySet()) {
			subList = new List<String>();
			for (Integer i=0; i<recipientCount; i++) {
				subList.add(subMap.get(key));
			}
			email.addSubstitution(key, subList);
		}
		return email;
    }
    
    // Add the RH standard unique arguments to the email for tracking purposes.  The RH standard
    // unique arguements are the object name and object Id associated with the email.
    public SendGrid.Email addRHEmailTracking(SendGrid.Email email, Id recordId) {
    	email.addUniqueArg('RHobjectId', recordId);
    	return email;
    }

}