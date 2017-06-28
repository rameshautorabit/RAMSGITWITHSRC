global class Quote_To_CW {
	
	public List<Quote> Qlist {get; set;}
	public static String xmlContent {get; set;}
	public Boolean isAdminUser {get; set;}
	
	//private final Quote q; String qid;
	
	public Quote_To_CW() {
		// qid=[Select Id from Quote where Id=:ApexPages.currentPage().getParameters().get('quoteId')].id;
		Qlist=[Select Conversion_Status__c,Id,IsSyncing, Bill_To_Blank__c from Quote where Id=:ApexPages.currentPage().getParameters().get('quoteId')];
		system.debug('////////////' +Qlist[0].Conversion_status__c);
		
		// Determine if running user is an admin user
		isAdminUser = false;
		Profile prof = [select Id, Name from Profile where Id = :UserInfo.getProfileId()];
		if (prof.Name == 'System Administrator' || prof.Name == 'Contract Business Administrator') {
			isAdminUser = true;
		}
	}
	
	RH_Web_Services__c rohc = RH_Web_Services__c.getInstance('Quote>CW');
	public PageReference invokeMule() {
		RH_Web_Services__c rohc = RH_Web_Services__c.getInstance('Quote>CW');
		PageReference pr = null;
		
		if (Qlist[0].IsSyncing == true && Qlist[0].Bill_To_Blank__c == false &&
			((Qlist[0].Conversion_Status__c != 'Sent' && Qlist[0].Conversion_Status__c != 'In Progress') || isAdminUser)) {
			
			String url;
			HTTPResponse resp;
			
			url=  rohc.Service_URL__c+ Qlist[0].Id;
			HttpRequest req = new HttpRequest();
			Http http = new Http();
			req.setMethod('GET');
			req.setEndpoint(url);
			req.setHeader('Content-Type', 'application/x-www-form-urlencoded'); 
			 
			try {
				// make the callout to send the quote to CW
				resp = http.send(req);
				Qlist[0].Conversion_Status__c = 'In Progress';
				update Qlist[0];
				pr = new PageReference('/' + Qlist[0].Id);
				pr.setRedirect(true);
			} catch(Exception e) {
				if (resp != null) {
					System.debug('*****Quote to CW exception - callout response: ' + resp.toString());
				}
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Quote to CW exception: ' + e.getMessage()));
			}
			
			if (resp != null) {
				xmlContent = String.valueOf(resp.getBody()).replace('\n', '');
				system.debug('*****Quote to CW resp.getBody = ' + resp.getBody());
				system.debug('*****Quote to CW xmLContent = ' + xmlContent);
				system.debug('*****Quote to CW request end point = ' + url);
			}
		}
		
		return pr;
	}
	
	// Cancel to return to the previous page
	public PageReference Cancel() {
		PageReference qPage = new PageReference('/' + Qlist[0].Id);
		qPage.setRedirect(true);
		return qPage;
	}
}