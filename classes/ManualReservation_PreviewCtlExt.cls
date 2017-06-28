public with sharing class ManualReservation_PreviewCtlExt {
	
	/*
	 *	Preview and manual send of Auto MIRV email (manual reservation of back ordered 
	 *	product). Back ordered product is now available earlier than expected.
	 *
	 */
	
	ApexPages.StandardController stdController;
	
	public Manual_Reservation__c rhMR {get; set;}
	public Id mrId {get; set;}
	public String retURL {get; set;}
	public Boolean isError {get; set;}
	public Boolean noSend {get; set;}
	
	public ManualReservation_PreviewCtlExt(ApexPages.StandardController stdController) {
		
		isError = true;
		noSend = false;
		mrId = ApexPages.currentPage().getParameters().get('mrId');
		retURL = ApexPages.currentPage().getParameters().get('retURL');
		
		rhMR = new Manual_Reservation__c();
		
		// Validate page parameters and get the data needed for the notification
		if (String.isNotBlank(mrId) && String.isNotBlank(retURL)) {
			
			try {
				rhMR = [select Id, Name, Ship_To__c, Early_Delivery_Date__c, Late_Delivery_Date__c,  
						Email_Subject_Brand__c, Email_To_Address__c, Order_Lines__c, Send_Email__c, 
						Order_Number__c, Order_Number__r.Sold_to_Email__c 
						from Manual_Reservation__c where Id = :mrId];
				
				rhMR.Email_To_Address__c = rhMR.Order_Number__r.Sold_to_Email__c;
				if (!Utility.isValidDomain(rhMR.Email_To_Address__c)) {
					rhMR.Email_To_Address__c = null;
				}
				
				isError = false;
				
			} catch(Exception e) {
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Manual Reservation read exception: ' + e.getMessage()));
			}
			
		} else {
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Invalid page parameters.'));
		}
	}
	
	public PageReference cancelMRPreview() {
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
		if (Utility.isValidDomain(rhMR.Email_To_Address__c)) {
			
			// Send the email
			try {
				// Send the email
				rhMR.Send_Email__c = true;
				update rhMR;
				
				// Attach a copy of the email
				Blob pageContent;
				if (!Test.isRunningTest()) {
					pageContent = new PageReference('/apex/ManualReservationHTML?mrId=' + mrId).getContent();
				} else {
					pageContent = Blob.valueOf('Test Class');
				}
				
				Attachment mrAttachment = new Attachment(
					ParentId = rhMr.Id,
					Name = 'Manual Reservation ' + rhMR.Name + ': on-demand.html',
					ContentType = 'html',
					Body = pageContent,
					Description = 'System Generated Attachment'
						+ '\nManual Reservation Notification sent on-demand: ' + rhMR.Name 
						+ '\nToAddress = ' + rhMR.Email_To_Address__c
						+ '\nSend Date/Time = ' + String.valueOf(system.now())
				);
				insert mrAttachment;
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