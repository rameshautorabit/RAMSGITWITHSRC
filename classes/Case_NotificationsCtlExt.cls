public with sharing class Case_NotificationsCtlExt {
	
	/*
	 *	Case controller extension to support Case based email notifications. Allows the user to 
	 *	select the notification type to preview and/or send. The user can only select those notifications
	 *	supported by the Case record type.
	 *
	 */
	
	ApexPages.StandardController stdController;
	
	private List<SelectOption> emailTypes;
	private String emailSelected;
	
	public Case rhCase {get; set;}
	public Boolean isError {get; set;}
	
	public Case_NotificationsCtlExt(ApexPages.StandardController stdController) {
		
		isError = false;
		emailTypes = new List<SelectOption>();
		emailSelected = '--None--';
		
		rhCase = new Case();
		this.rhCase = (Case)stdController.getRecord();
		rhCase = [select Id, CaseNumber, RecordTypeId, Notification_Type__c, Membership_Auto_Renewal_Order__c, 
				RH_Order_Number__c, RH_Order_Number__r.Name, RH_Order_Number__r.Order_Type_Code__c 
				from Case where Id = :this.rhCase.Id];
	}
	
	// Take the user immediately to the preview page if there is only one notification type for the Case record type
	public PageReference previewOne() {
		PageReference pr = null;
		Map<Id,Schema.RecordTypeInfo> rtMapById = Schema.SObjectType.Case.getRecordTypeInfosById();
		
		if (!rtMapById.containsKey(rhCase.RecordTypeId) || (rtMapById.get(rhCase.RecordTypeId).getName() != 'Credit Card Declines' && rtMapById.get(rhCase.RecordTypeId).getName() != 'Delay Notifications')) {
			isError = true;
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Invalid case record type.'));
		}
		
		// Verify that the user has permissions to update the case record
		UserRecordAccess ura = [select RecordId, HasEditAccess from UserRecordAccess where UserId = :UserInfo.getUserId() and RecordId = :rhCase.Id];
		Profile sysAdmin = [select Id from Profile where Name = 'System Administrator'];
		if (!ura.HasEditAccess || (Approval.isLocked(rhCase.Id) && UserInfo.getProfileId() != sysAdmin.Id)) {
			isError = true;
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Insufficient privileges. The case cannot be locked and you must be able to edit the case.'));
		}
		
		if (!isError) {
			if (rtMapById.containsKey(rhCase.RecordTypeId) && rtMapById.get(rhCase.RecordTypeId).getName() == 'Delay Notifications') {
				// Go to Delay Notifications preview page
				pr = new PageReference('/apex/Case_DNPreview?caseId=' + rhCase.Id + '&retURL=/' + rhCase.Id);
			}
		}
		
		return pr;
	}
    
	// Get the list of notifications for the current case record type
	public List<SelectOption> notificationTypes {
		get {
			// Get all of the possible notification types
			Schema.DescribeFieldResult fieldResult = Case.Notification_Type__c.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			
			// Set our possible selections based upon case record type
			emailTypes.clear();
			emailTypes.add(new SelectOption('--None--', '--None--'));
			Map<Id,Schema.RecordTypeInfo> rtMapById = Schema.SObjectType.Case.getRecordTypeInfosById();
			if (rtMapById.containsKey(rhCase.RecordTypeId)) {
				String rtName = rtMapById.get(rhCase.RecordTypeId).getName();
				for (Schema.PicklistEntry f :ple) {
					if (f.getLabel().startsWith(rtName)) {
						emailTypes.add(new SelectOption(f.getLabel(), f.getLabel()));
					}
				}
			}
			
			return emailTypes;
		}
		set;        
	}
	
	public String getnotificationSelected() {
		return emailSelected;
	}
	
	public void setnotificationSelected(String ns) {
		emailSelected = ns;
	}
	
	// Take the user to the preview page based upon the selected notification type
	public PageReference notificationPreview() {
		PageReference pr = null;
		
		if (String.isBlank(emailSelected) || emailSelected == '--None--') {
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Please select notification type.'));
		} else {
			if (emailSelected.startsWith('Credit Card Declines')) {
				rhCase.Notification_Type__c = emailSelected;
				
				// Set subject line of CCD email
				Map<String, CreditCardDeclineEmail__c> ccdEmailMap = CreditCardDeclineEmail__c.getAll();
				String noticeType = rhCase.Notification_Type__c.substringAfter('Credit Card Declines - ');
				if (rhCase.RH_Order_Number__r.Order_Type_Code__c == 'Z') {
					noticeType += ' - Contract';
				} else {
					if (rhCase.Membership_Auto_Renewal_Order__c) {
						noticeType += ' - Membership';
					} else {
						noticeType += ' - Regular';
					}
				}
				rhCase.CCD_Email_Subject__c = ccdEmailMap.get(noticeType).Subject__c;
				if (ccdEmailMap.get(noticeType).Include_Order_Number__c) {
					rhCase.CCD_Email_Subject__c += rhCase.RH_Order_Number__r.Name;
				}
				
				update rhCase;
				pr = new PageReference('/apex/Case_CCDPreview?caseId=' + rhCase.Id + '&retURL=/' + rhCase.Id);
			} else {
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Notification type ' + emailSelected + ' is not supported at this time.'));
			}
		}
		return pr;
	}
}