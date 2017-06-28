public with sharing class Case_CCDPreviewCtlExt {
	
	/*
	 *	Preview and manual send of Credit Card Declines notifications.
	 *
	 */
	
	ApexPages.StandardController stdController;
	
	public Case rhCase {get; set;}
	public Id caseId {get; set;}
	public String retURL {get; set;}
	public Boolean isError {get; set;}
	public Boolean noSend {get; set;}
	
	public Case_CCDPreviewCtlExt(ApexPages.StandardController stdController) {
		
		isError = true;
		noSend = false;
		caseId = ApexPages.currentPage().getParameters().get('caseId');
		retURL = ApexPages.currentPage().getParameters().get('retURL');
		
		rhCase = new Case();
		
		// Validate page parameters and get the data needed for the notification
		if (String.isNotBlank(caseId) && String.isNotBlank(retURL)) {
			rhCase = [select Id, CaseNumber, IsClosed, RecordTypeId, Status, 
						Email_Alert_Trigger__c, Notification_Type__c, To_Email_Address__c, WasReopened__c, 
						RH_Order_Number__c, RH_Order_Number__r.Name, RH_Order_Number__r.Sold_to_Email__c, 
						RH_Order_Number__r.Sold_to_First_Name__c, RH_Order_Number__r.Sold_to_Last_Name__c 
						from Case where Id = :caseId];
		
			// Validate data
			Map<Id,Schema.RecordTypeInfo> rtMapById = Schema.SObjectType.Case.getRecordTypeInfosById();
			if (String.isNotBlank(rhCase.Notification_Type__c) && rhCase.Notification_Type__c.startsWith('Credit Card Declines') && rtMapById.containsKey(rhCase.RecordTypeId) && rtMapById.get(rhCase.RecordTypeId).getName() == 'Credit Card Declines') {
				if (rhCase.RH_Order_Number__c != null) {
					isError = false;
					if (rhCase.isClosed || rhCase.WasReopened__c) {
						noSend = true;
					}
					
					if (Utility.isValidDomain(rhCase.RH_Order_Number__r.Sold_to_Email__c)) {
						rhCase.To_Email_Address__c = rhCase.RH_Order_Number__r.Sold_to_Email__c;
					} else {
						rhCase.To_Email_Address__c = null;
					}
					
				} else {
					ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Case must be associated with an Order.'));
				}
			} else {
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Invalid notification type for case record type.'));
			}
		} else {
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Invalid page parameters.'));
		}
	}
	
	public PageReference cancelCCDPreview() {
		PageReference pr;
		if (String.isNotBlank(retURL)) {
			pr = new PageReference(retURL);
		} else {
			pr = new PageReference('/');
		}
		return pr;
	}
	
	// Send the notification email and attach a copy to the case
	public PageReference sendNotification() {
		PageReference pr = null;
		
		// Make sure the email address is in the appropriate domain for our environment
		if (Utility.isValidDomain(rhCase.To_Email_Address__c)) {
			
			// Send the email
			try {
				// Send the email
				rhCase.Email_Alert_Trigger__c = true;
				update rhCase;
				
				// Attach a copy of the email to the case
				Blob pageContent;
				if (!Test.isRunningTest()) {
					pageContent = new PageReference('/apex/CreditCardDeclineHTML?caseId=' + caseId).getContent();
				} else {
					pageContent = Blob.valueOf('Test Class');
				}
				
				Attachment caseAttachment = new Attachment(
					ParentId = rhCase.Id,
					Name = rhCase.Notification_Type__c + ': on-demand.html',
					ContentType = 'html',
					Body = pageContent,
					Description = 'System Generated Attachment'
						+ '\nNotification sent on-demand: ' + rhCase.Notification_Type__c 
						+ '\nToAddress = ' + rhCase.To_Email_Address__c
						+ '\nSend Date/Time = ' + String.valueOf(system.now())
				);
				insert caseAttachment;
				pr = new PageReference(retURL);
			} catch(Exception e) {
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Error while processing send email request, exception: ' + e.getMessage()));
			}
			
		} else {
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'To Email Address must be in domain "rh.com" or "restorationhardware.com".'));
		}
		
		return pr;
	}
}