public with sharing class Case_DNPreviewCtlExt {
	
	/*
	 *	Preview and manual send of delayed order notifications.
	 *
	 */
	
	ApexPages.StandardController stdController;
	
	public Case rhCase {get; set;}
	public Id caseId {get; set;}
	public String retURL {get; set;}
	public Boolean isError {get; set;}
	public Boolean noSend {get; set;}
	
	public Case_DNPreviewCtlExt(ApexPages.StandardController stdController) {
		
		isError = true;
		noSend = false;
		caseId = ApexPages.currentPage().getParameters().get('caseId');
		retURL = ApexPages.currentPage().getParameters().get('retURL');
		
		rhCase = new Case();
		
		// Validate page parameters and get the data needed for the notification
		if (String.isNotBlank(caseId) && String.isNotBlank(retURL)) {
			rhCase = [select Id, CaseNumber, IsClosed, RecordTypeId, Status, Gift_Card_Status__c, Request_Category__c, 
						Email_Alert_Trigger__c, Notification_Type__c, To_Email_Address__c, Actual_Gift_Card_Amount__c, 
						Order_Type_Code__c, Opportunity_PM__c, WasReopened__c, RH_Order_Number__c, 
						RH_Order_Number__r.Name, RH_Order_Number__r.Sold_to_Email__c, 
						RH_Order_Number__r.Sold_to_First_Name__c, RH_Order_Number__r.Sold_to_Last_Name__c 
						from Case where Id = :caseId];
		
			// Validate data
			Map<Id,Schema.RecordTypeInfo> rtMapById = Schema.SObjectType.Case.getRecordTypeInfosById();
			if (String.isNotBlank(rhCase.Notification_Type__c) && rhCase.Notification_Type__c == 'Delay Notifications' && rtMapById.containsKey(rhCase.RecordTypeId) && rtMapById.get(rhCase.RecordTypeId).getName() == 'Delay Notifications') {
				if (rhCase.RH_Order_Number__c != null && rhCase.isClosed != true && rhCase.Gift_Card_Status__c != 'Pending' && rhCase.WasReopened__c != true) {
					
					// If contract order/case, verify there is an Opportunity PM
					if (rhCase.Order_Type_Code__c != 'Z' || (rhCase.Order_Type_Code__c == 'Z' && rhCase.Opportunity_PM__c != null && !(rhCase.Actual_Gift_Card_Amount__c > 0))) {
						isError = false;
						
						if (Utility.isValidDomain(rhCase.RH_Order_Number__r.Sold_to_Email__c)) {
							rhCase.To_Email_Address__c = rhCase.RH_Order_Number__r.Sold_to_Email__c;
						} else {
							rhCase.To_Email_Address__c = null;
						}
					} else {
						ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'The Opportunity PM field on the Case must not be blank and Actual Gift Card must not be greater than zero for Delay Notifications for Contract Orders.'));
					}
				} else {
					ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Case must not be closed, must not have been re-opened, must not have Gift Card Status pending, and must be associated with an Order.'));
				}
			} else {
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Invalid notification type for case record type.'));
			}
		} else {
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Invalid page parameters.'));
		}
	}
	
	public PageReference cancelDNPreview() {
		PageReference pr;
		if (String.isNotBlank(retURL)) {
			pr = new PageReference(retURL);
		} else {
			pr = new PageReference('/');
		}
		return pr;
	}
	
	// Send the notification email
	public PageReference sendNotification() {
		PageReference pr = null;
		
		// Make sure the email address is in the appropriate domain for our environment
		if (Utility.isValidDomain(rhCase.To_Email_Address__c)) {
			update rhCase;
			DelayedOrderNotification.sendSingleDelayNotification(rhCase.Id);
			pr = new PageReference(retURL);
		} else {
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'To Email Address must be in domain "rh.com" or "restorationhardware.com".'));
		}
		
		return pr;
	}
}