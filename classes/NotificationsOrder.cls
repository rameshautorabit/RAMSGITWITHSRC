global class NotificationsOrder {
	
	/*
	 *	Methods to send Order related transactional emails - order confirmation, order shipping, RH membership, etc.
	 *
	 */
	
	// Process the list of Order records that are ready for an order notification email
	// Note - this method makes a callout so the calling method must be an @future method
	public static Map<Id, String> sendNotification(String notificationType, Set<Id> orderIds) {
		
		Map<Id, String> resultsMap = new Map<Id, String>();
		if (!orderIds.isEmpty()) {
			
			// Get the RH internal data we need - customer service email and phone, etc.
			Account acc = new Account();
			acc = [select Id, Name from Account where RecordType.Name = 'Internal' and Name = 'Restoration Hardware' and Type = 'Internal' limit 1];
			List<Contact> cList = new List<Contact>();
    	    cList = [select Id, Name, Email, Phone, OtherPhone, Alternate_Email__c from Contact where AccountId = :acc.Id];
    	    
    	    String cscEmail = null;
			String opPhone = null;
			String opOtherPhone = null;
			for (Contact c :cList) {
				if (c.Name == 'Customer Service Center') {
					cscEmail = c.Email;
				}
				if (c.Name == 'Order Processing') {
					opPhone = c.Phone;
					opOtherPhone= c.OtherPhone;
				}
			}
			
			// Read in the Order data we need for the notification
			Map<Id, RH_Order__c> oMap = new Map<Id, RH_Order__c>([select Id, Name, Membership_ID__c, Membership_Enrollment_Date__c, 
					Membership_Expiration_Date__c, To_Email_Address__c, Additional_To_Email_Addresses__c, Sold_to_Email__c, 
					Sold_to_First_Name__c, Sold_to_Last_Name__c, Sold_To_Address_1__c, Sold_To_Address_2__c, Sold_to_City__c, 
					Sold_to_State__c, Sold_to_Zip__c, Sold_to_Day_Phone__c, Sold_to_Country__c, Division__c 
					from RH_Order__c where Id = :orderIds]);
			
			// Prepare to send out the notification emails - one per Order
			SendGrid_RH sgRH = new SendGrid_RH();
			Map<Id, SendGrid_RH.SendGrid_RH_Data> sgrhDataMap = new Map<Id, SendGrid_RH.SendGrid_RH_Data>();
			List<String> fromList;
			List<String> fromNameList;
			Map<String, String> subMap;
			List<String> subjectList;
			List<String> toList;
			List<String> bodyList;
			rhEmail rhe;
			Map<Id, rhEmail> rheMap = new Map<Id, rhEmail>();
			for (RH_Order__c o :oMap.values()) {
				
				fromList = new List<String>();
				fromNameList = new List<String>();
				subMap = new Map<String, String>();
				subjectList = new List<String>();
				toList = new List<String>();
				bodyList = new List<String>();
				rhe = null;
				
				if (notificationType == 'RH Membership Welcome') {
					rhe = buildWelcomeEmail(o);
				}
				
				if (rhe != null) {
					fromList.add(rhe.fromEmail);
					fromNameList.add(rhe.fromName);
					subjectList.add(rhe.subject);
					toList.addAll(rhe.toEmailList);
					bodyList.add(rhe.body);
					rheMap.put(o.Id, rhe);
					
					sgrhDataMap.put(o.Id, new SendGrid_RH.SendGrid_RH_Data(true, false, false, true, notificationType, subjectList, fromNameList, fromList, toList, bodyList, subMap, o.Id));
					
				}
			}
				
        	// Send the notification emails
        	if (!sgrhDataMap.isEmpty()) {
    	    	Boolean success = sgRH.rhSendEmail(sgrhDataMap.values());
        	}
			
			// Record results of sending email and create email attachments for each order
			List<Attachment> attList = new List<Attachment>();
			String toEmailAddresses = '';
			for (RH_Order__c o :oMap.values()) {
				if (sgrhDataMap.containsKey(o.Id)) {
					resultsMap.put(o.Id, sgrhDataMap.get(o.Id).SendGridResult);
				}
				
				if (rheMap.containsKey(o.Id)) {
					for (String toEmail :rheMap.get(o.Id).toEmailList) {
						toEmailAddresses += toEmail + ', ';
					}
					if (String.isNotBlank(toEmailAddresses)) {
						toEmailAddresses = toEmailAddresses.removeEnd(', ');
					}
					attList.add(new Attachment(
						ParentId = o.Id,
						Name = rheMap.get(o.Id).subject + '.html',
						ContentType = 'html',
						Body = Blob.valueof(rheMap.get(o.Id).body),
						Description = 'System Generated Attachment'
							+ '\nSendGrid Email - Sent Message' 
							+ '\nFrom Name/Address = ' + rheMap.get(o.Id).fromName + '/' + rheMap.get(o.Id).fromEmail 
							+ '\nToAddress = ' + toEmailAddresses 
							+ '\nCcAddress = ' 
							+ '\nBccAddress = ' 
							+ '\nSendGrid email send request date/time = ' + String.valueOf(system.now())
							+ '\nHasAttachment = ' + 'false' 
					));
				}
			}
			
			// Attach each email sent to its related Order
			if (!attList.isEmpty()) {
				insert attList;
			}
		}
		return resultsMap;
	}
	
	// Send a single Order Notification email - called from a custom button on the Order detail page
	@future(callout=true)
	webService static void sendSingleOrderNotification(Id orderId, String notificationType) {
		Set<Id> oIds = new Set<Id>();
		oIds.add(orderId);
		Map<Id, String> resultsMap = sendNotification(notificationType, oIds);
		
		
		// Update the Order record based upon success/failure of send
		if (resultsMap.containsKey(orderId)) {
			RH_Order__c o = new RH_Order__c();
			o.Id = orderId;
			o.SendGrid_Result__c = resultsMap.get(orderId);
			o.SendGrid_Request_Date__c = system.now();
			if (o.SendGrid_Result__c.contains('SUCCESS') && notificationType == 'RH Membership Welcome') {
				o.Membership_Welcome_Email_Sent__c = true;
			}
			update(o);
		}
	}
	
	// Send RH Membership Welcome notification for each Order if all required data exists
	@future(callout=true)
	public static void sendWelcomeNotifications(Set<Id> oIds) {
		
		List<RH_Order__c> oList = new List<RH_Order__c>();
		olist = [select Id, Name, Membership_ID__c, Membership_Enrollment_Date__c, Membership_Expiration_Date__c, 
        		To_Email_Address__c, Additional_To_Email_Addresses__c, Sold_to_Email__c, Sold_to_First_Name__c, 
        		Sold_to_Last_Name__c, Sold_To_Address_1__c, Sold_To_Address_2__c, Sold_to_City__c, 
				Sold_to_State__c, Sold_to_Zip__c, Sold_to_Day_Phone__c, Sold_to_Country__c, Membership_Welcome_Email_Sent__c 
				from RH_Order__c where Id in :oIds];
		
		// Validate that all of the Order information exists to send an RH Membership Welcome email
		Set<Id> oEmailIds = new Set<Id>();
		Boolean sendWelcome;
		for (RH_Order__c o :oList) {
			sendWelcome = true;
			if (o.Membership_Welcome_Email_Sent__c) {
				sendWelcome = false;
			}
			if (String.isBlank(o.Membership_ID__c)) {
				sendWelcome = false;
			}
			if (o.Membership_Enrollment_Date__c == null) {
				sendWelcome = false;
			}
			if (o.Membership_Expiration_Date__c == null) {
				sendWelcome = false;
			}
			if (String.isBlank(o.Sold_to_Email__c)) {
				sendWelcome = false;
			}
			
			if (sendWelcome) {
				oEmailIds.add(o.Id);
			}
		}
		
		if (!oEmailIds.isEmpty()) {
			
			Map<Id, String> resultsMap = sendNotification('RH Membership Welcome', oEmailIds);
			
			// Update the Order records based upon success/failure of send
			List<RH_Order__c> oResultList = new List<RH_Order__c>();
			for (Id key :resultsMap.keySet()) {
				RH_Order__c o = new RH_Order__c();
				o.Id = key;
				o.SendGrid_Result__c = resultsMap.get(key);
				o.SendGrid_Request_Date__c = system.now();
				if (o.SendGrid_Result__c.contains('SUCCESS')) {
					o.Membership_Welcome_Email_Sent__c = true;
				}
				oResultList.add(o);
			}
			
			if (!oResultList.isEmpty()) {
				update oResultList;
			}
		}
	}
	
	// Email data structure
	public class rhEmail {
		String fromName {get; set;}
		String fromEmail {get; set;}
		List<String> toEmailList {get; set;}
		String subject {get; set;}
		String body {get; set;}
		
		public rhEmail() {
			fromName = '';
			fromEmail = '';
			toEmailList = new List<String>();
			subject = '';
			body = '';
		}
	}
	
	// Construct the RH Membership Welcome Email
	public static rhEmail buildWelcomeEmail(RH_Order__c o) {
		
		rhEmail rhe = null;
		String toEmailAddress = o.To_Email_Address__c;
		if (String.isBlank(toEmailAddress)) {
			toEmailAddress = o.Sold_to_Email__c;
		}
		
		if (String.isNotBlank(toEmailAddress)) {
			
			// Get the RH brand data
			String rhBrand = '';
			String rhEmail = '';
			
			RH_Brand__c rhb = null;
			if (String.isNotBlank(o.Division__c)) {
				rhb = RH_Brand__c.getInstance(o.Division__c);
			}
			if (rhb == null) {
				rhb = RH_Brand__c.getInstance('999');
			}
			rhEmail = rhb.Delay_Notification_Email__c;
			rhBrand = rhb.Email_Subject_Brand__c;
			
			rhe = new rhEmail();
			rhe.fromName = rhBrand;
			rhe.fromEmail = rhEmail;
			rhe.toEmailList.add(toEmailAddress);
			rhe.subject = 'Welcome to the RH Members Program';
			
			String dayPhone = ' ';
			if (String.isNotBlank(o.Sold_to_Day_Phone__c)) {
				dayPhone = Utility.formatPhone10(o.Sold_to_Day_Phone__c);
			}
			
			String body = '';
			
			body += '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">';
			body += '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />';
			body += '<title>RH Grey Card Email</title>';
			
			body += '<style type="text/css">';
			body += 'a:link {text-decoration: none; color:inherit;}';
			body += 'a:visited {text-decoration: none; color:inherit;}';
			body += 'a:hover {text-decoration: none; color:inherit;}';
			body += 'a:active {text-decoration: none; color:inherit;}';
			body += '</style>';
			
			body += '<table style="width: 700px; font-size: 12px; font-family: sans-serif; margin: 0;" align="center" cellpadding="0" cellspacing="0">';
			body += '<tr>';
			body += '<td width="784" style="font-size:9px; color:#FFFFFF; display:none;">Your Membership is Confirmed.<br />Save 25% on Everything.</td>';
			body += '</tr>';
			
			body += '<tr>';
			body += '<td style="padding: 0; margin: 0; border:0;" valign="top" cellpadding="0" cellspacing="0"><a href="https://www.restorationhardware.com/" target="_blank"><img style="display:block;" src="https://media.restorationhardware.com/is/image/rhis/20160323_member_welcome_a?wid=784&fmt=gif&qlt=85,1&op_sharpen=0&quantize=adaptive,off,255,&resMode=sharp2&op_usm=0.3,1.0,5,0&iccEmbed=1" width="700"></a></td>';
			body += '</tr>';
			
			body += '<tr>';
			body += '<td valign="top" align="center" style="text-transform: uppercase; background-color: #54565a ; color:#ccc; letter-spacing: 1px; font-family: sans-serif; font-weight:100; text-align: left; padding: 30px 0 30px 184px; font-size: 10px; width: 700px; margin: 0;line-height: 18px;" cellpadding="0" cellspacing="0">';
			body += '<p style="color:#ccc;">MEMBERSHIP INFORMATION<br>';
			body += '<div><span style="display: inline-block; min-width: 140px; color:#ccc;">MEMBERSHIP NUMBER</span><a href="" style="text-decoration:none; color:#ccc; border:none;">' + o.Membership_ID__c + '</a></div>';
			body += '<div><span style="display: inline-block; min-width: 140px; color:#ccc;">ENROLLMENT</span><a href="" style="text-decoration:none; color:#ccc; border:none;">' + Utility.usWrittenDate(o.Membership_Enrollment_Date__c, true) + '</a></div>';
			body += '<div><span style="display: inline-block; min-width: 140px; color:#ccc;">RENEWAL DATE</span><a href="" style="text-decoration:none; color:#ccc; border:none;">' + Utility.usWrittenDate(o.Membership_Expiration_Date__c, true) + '</a></div>';
			body += '<div><span style="display: inline-block; min-width: 140px; color:#ccc; font-size: 10px; text-transform: none;">Visit <a style="text-decoration: underline; color: #ccc;" href="https://www.restorationhardware.com/my-account/sign-in.jsp">My Account</a> for details.</span></div>';
			body += '</p>';
			body += '<p style="color:#ccc;">CONTACT INFORMATION<br>';
			body += '<div><span style="display: inline-block; min-width: 140px; color:#ccc;">EMAIL</span><a href="" style="text-decoration:none; color:#ccc; border:none;">' + o.Sold_to_Email__c + '</a></div>';
			body += '<div><span style="display: inline-block; min-width: 140px; color:#ccc;">PHONE</span><a href="" style="text-decoration:none; color:#ccc; border:none;">' + dayPhone + '</a></div>';
			body += '</p>';
			body += '</td>';                    
			body += '</tr>';
			
			body += '<tr>';
			body += '<td style="text-align:left; padding:0;" colspan="3" cellpadding="0" cellspacing="0"><a href="https://www.restorationhardware.com/" target="_blank"><img src="https://media.restorationhardware.com/is/image/rhis/20160303_member_welcome_b?wid=784&fmt=gif&qlt=85,1&op_sharpen=0&quantize=adaptive,off,255,&resMode=sharp2&op_usm=0.3,1.0,5,0&iccEmbed=1" width="700" style="display:block;"></a></td>';
			body += '</tr>';
			
			// begin footer
			body += '<tr>';
			body += '<td style="background-color:#FFF; color: #999;text-align: center;font-size: 10px;font-family: sans-serif;font-color:#999; line-height: 18px;width: 700px; padding:0 0 20px 0 ;letter-spacing: 1px;" colspan="3" cellpadding="0" cellspacing="0">';
			body += '<p style="padding: 0 0 20px 0; text-decoration:none; color:#999;">Read the RH Members Program <a href="https://www.restorationhardware.com/content/page.jsp?id=rhmembers-terms" style=" color: #999;"><u>Terms & Conditions</u></a>.</p>';
			body += '<a href="https://www.restorationhardware.com/" target="_blank"><img src="https://media.restorationhardware.com/is/image/rhis/membership_email_welcome_logo_20160303?wid=120&fmt=png-alpha&qlt=85,1&op_sharpen=0&resMode=sharp2&op_usm=1,1,6,0&iccEmbed=1" alt="RH Logo" width="60"></a><br>';
			body += '<p><a href="https://www.restorationhardware.com/store-locations/index.jsp" style="text-decoration:none; color:#999">Locate the nearest RH Gallery</a></p>';
			body += '<br>';
			body += '<p style="text-transform:uppercase; text-decoration:!important none; color:#999;">';
			body += '<a href="https://www.restorationhardware.com/membership.jsp" style="text-decoration:none; color:#999">JOIN THE RH MEMBERS PROGRAM</a>&nbsp; | &nbsp;<a href="https://www.restorationhardware.com/customer-service/catalog-request.jsp" style="text-decoration:none; color:#999">REQUEST A SOURCE BOOK</a>&nbsp; | &nbsp;<a href="https://www.restorationhardware.com/content/page.jsp?id=sourcebookapp" style="text-decoration:none; color:#999">SOURCE BOOK APP</a>&nbsp; | &nbsp;<a href="https://www.restorationhardware.com/gift-registry/index.jsp" style="text-decoration:none; color:#999">REGISTRY</a>&nbsp; |&nbsp; <a href="https://www.restorationhardware.com/customer-service/privacy-policy.jsp" style="text-decoration:none; color:#999">PRIVACY</a><br>';
			body += '<a href="https://www.restorationhardware.com/" style="text-decoration:none; color:#999">RH</a>&nbsp; | &nbsp;<a href="https://www.rhmodern.com/" style="text-decoration:none; color:#999">RH MODERN</a>&nbsp; | &nbsp;<a href="https://www.rhteen.com/" style="text-decoration:none; color:#999">RH TEEN</a>&nbsp; | &nbsp;<a href="https://www.rhbabyandchild.com/" style="text-decoration:none; color:#999">RH BABY &amp; CHILD</a></p>';
			body += '<p style="text-transform:none; color:#999;"><br>';
			body += '&copy; 2016 RH&nbsp;15 Koch Road, Corte Madera, CA 94925';
			body += '</p>';
			body += '</td>';
			body += '</tr>';
			
			
			/*
			body += '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">';
			body += '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />';
			body += '<title>RH Grey Card Email</title>';
			
			body += '<style type="text/css">';
			body += 'a:link {text-decoration: none; color:inherit;}';
			body += 'a:visited {text-decoration: none; color:inherit;}';
			body += 'a:hover {text-decoration: none; color:inherit;}';
			body += 'a:active {text-decoration: none; color:inherit;}';
			body += '</style>';
			
			body += '<table style="width: 700px; font-size: 12px; font-family: sans-serif; margin: 0;" align="center" cellpadding="0" cellspacing="0">';
			
			body += '<tr>';
			body += '<td style="padding: 0; margin: 0; border:0;" valign="top" cellpadding="0" cellspacing="0"><a href="https://www.restorationhardware.com/" target="_blank"><img style="display:block;" src="https://media.restorationhardware.com/is/image/rhis/20160303_member_welcome_a?wid=780&fmt=gif&qlt=85,1&op_sharpen=0&quantize=adaptive,off,255,&resMode=sharp2&op_usm=0.3,1.0,5,0&iccEmbed=1" width="700"></a></td>';
			body += '</tr>';
			
			body += '<tr>';
			body += '<td valign="top" align="center" style="text-transform: uppercase; background-color: #54565a ; color:#FFF; letter-spacing: 1px; font-family: sans-serif; font-weight:100; text-align: left; padding: 30px 0 30px 184px; font-size: 10px; width: 700px; margin: 0;line-height: 18px;" cellpadding="0" cellspacing="0">';
			body += '<p style="color:#FFF;">MEMBERSHIP INFORMATION<br>';
			body += '<div><span style="display: inline-block; min-width: 140px; color:#FFF;">MEMBERSHIP NUMBER</span><a href="" style="text-decoration:none; color:#FFF; border:none;">' + o.Membership_ID__c + '</a></div>';
			body += '<div><span style="display: inline-block; min-width: 140px; color:#FFF;">ENROLLMENT</span><a href="" style="text-decoration:none; color:#FFF; border:none;">' + Utility.usWrittenDate(o.Membership_Enrollment_Date__c, true) + '</a></div>';
			body += '<div><span style="display: inline-block; min-width: 140px; color:#FFF;">EXPIRATION</span><a href="" style="text-decoration:none; color:#FFF; border:none;">' + Utility.usWrittenDate(o.Membership_Expiration_Date__c, true) + '</a></div>';
			body += '</p>';
			body += '<p style="color:#FFF;">CONTACT INFORMATION<br>';
			body += '<div><span style="display: inline-block; min-width: 140px; color:#FFF;">EMAIL</span><a href="" style="text-decoration:none; color:#FFF; border:none;">' + o.Sold_to_Email__c + '</a></div>';
			
			String dayPhone = ' ';
			if (String.isNotBlank(o.Sold_to_Day_Phone__c)) {
				dayPhone = Utility.formatPhone10(o.Sold_to_Day_Phone__c);
			}
			body += '<div><span style="display: inline-block; min-width: 140px; color:#FFF;">PHONE</span><a href="" style="text-decoration:none; color:#FFF; border:none;">' + dayPhone + '</a></div>';
			body += '</p>';
			body += '</td>';                 
			body += '</tr>';
			
			body += '<tr>';
			body += '<td style="text-align:left; padding:0;" colspan="3" cellpadding="0" cellspacing="0"><a href="https://www.restorationhardware.com/" target="_blank"><img src="https://media.restorationhardware.com/is/image/rhis/20160303_member_welcome_b?wid=784&fmt=gif&qlt=85,1&op_sharpen=0&quantize=adaptive,off,255,&resMode=sharp2&op_usm=0.3,1.0,5,0&iccEmbed=1" width="700" style="display:block;"></a></td>';
			body += '</tr>';
			
			// begin footer
			body += '<tr>';
			body += '<td style="background-color:#FFF; color: #999;text-align: center;font-size: 11px;font-family: sans-serif;font-color:#999; line-height: 18px;width: 700px; padding:0 0 20px 0 ;letter-spacing: 1px;" colspan="3" cellpadding="0" cellspacing="0">';
			body += '<p style="padding: 0 0 20px 0; text-decoration:none; color:#999;">Read the RH Grey Card membership <a href="https://www.restorationhardware.com/content/page.jsp?id=rhgreycard-terms" style=" color: #999;"><u>Terms & Conditions</u></a>.</p>';
			body += '<a href="https://www.restorationhardware.com/" target="_blank">';
			body += '<img src="https://media.restorationhardware.com/is/image/rhis/membership_email_welcome_logo_20160303?wid=120&fmt=png-alpha&qlt=85,1&op_sharpen=0&resMode=sharp2&op_usm=1,1,6,0&iccEmbed=1" alt="RH Logo" width="60"></a><br>';
			body += '<p><a href="https://www.restorationhardware.com/store-locations/index.jsp" style="text-decoration:none; color:#999">Locate the nearest RH Gallery</a></p>';
			body += '<br>';
			body += '<p style="text-transform:uppercase; text-decoration:!important none; color:#999;">';
			body += '<a href="https://www.restorationhardware.com/customer-service/catalog-request.jsp" style="text-decoration:none; color:#999">REQUEST A SOURCE BOOK</a>&nbsp; | &nbsp;<a href="https://www.restorationhardware.com/content/page.jsp?id=sourcebookapp" style="text-decoration:none; color:#999">SOURCE BOOK APP</a>&nbsp; | &nbsp;<a href="https://www.restorationhardware.com/gift-registry/index.jsp" style="text-decoration:none; color:#999">REGISTRY</a>&nbsp; |&nbsp; <a href="https://www.restorationhardware.com/customer-service/privacy-policy.jsp" style="text-decoration:none; color:#999">PRIVACY</a>&nbsp; | &nbsp;<a href="https://www.restorationhardware.com/customer-service/restoration-hardware-credit-card.jsp" style="text-decoration:none; color:#999">RH CREDIT CARD</a><br>';
			body += '<a href="https://www.restorationhardware.com/" style="text-decoration:none; color:#999">RH</a>&nbsp; | &nbsp;<a href="https://www.rhmodern.com/" style="text-decoration:none; color:#999">RH MODERN</a>&nbsp; | &nbsp;<a href="https://www.rhteen.com/" style="text-decoration:none; color:#999">RH TEEN</a>&nbsp; | &nbsp;<a href="https://www.rhbabyandchild.com/" style="text-decoration:none; color:#999">RH BABY &amp; CHILD</a></p>';
			body += '<p style="text-transform:none; color:#999;"><br>';
			body += '&copy; 2016 RH&nbsp;15 Koch Road, Corte Madera, CA 94925';
			body += '</p>';
			body += '</td>';
			body += '</tr>';
			*/
			
			body += '</table>';
			
			rhe.body = body;
		}
			
		return rhe;
	}
}