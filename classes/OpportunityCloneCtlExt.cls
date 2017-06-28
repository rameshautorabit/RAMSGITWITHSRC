public with sharing class OpportunityCloneCtlExt {
	
	/*
	 *  Opportunity controller extension - methods to support Opportunity cloning with pre-populating 
	 *	a few specific fields.
	 */
	
	ApexPages.StandardController stdController;
	
	public Boolean fatalError {get; set;}
	public String retURL {get; set;}
	
	String oppId;
	Opportunity oppToClone;
	Opportunity oppCloned;
	
	// Constructor
    public OpportunityCloneCtlExt(ApexPages.StandardController stdController) {
    	
    	fatalError = false;
    	
    	oppId = ApexPages.currentPage().getParameters().get('oppId');
    	retURL = ApexPages.currentPage().getParameters().get('retURL');
		
		if (String.isBlank(oppId)) {
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'This page must have an Opportunity Id as a page parameter.'));
			fatalError = true;
		}
		
		if (String.isBlank(retURL)) {
			retURL = '/';
		}
    }
    
    public PageReference executeClone() {
    	PageReference pr = null;
    	String fields = '';
    	
    	if (!fatalError) {
    		
    		try {
    			// Get the Name field from the Opportunity we are cloning
    			Opportunity oppToClone = [select Id, Name from Opportunity where Id = :oppId];
    			
    			// Get the field Ids of the specific fields we need to pre-populate
    			Map<String, FieldIdLookup__c> fieldIdMap = FieldIdLookup__c.getAll();
    			
    			// Create the page reference to clone the Opportunity, set the fields, and take the user to the edit page
    			fields += '&' + fieldIdMap.get('Opp.BalanceDueDate').FieldId__c + '=';
    			fields += '&CF' + fieldIdMap.get('Opp.ClonedFrom').FieldId__c + '=' + oppToClone.Name + '&CF' + fieldIdMap.get('Opp.ClonedFrom').FieldId__c + '_lkid=' + oppId;
    			fields += '&' + fieldIdMap.get('Opp.CollectionsEfforts').FieldId__c + '=';
    			fields += '&' + fieldIdMap.get('Opp.FinalInvoiceAmount').FieldId__c + '=';
    			fields += '&' + fieldIdMap.get('Opp.PaidInFull').FieldId__c + '=';
    			fields += '&' + fieldIdMap.get('Opp.PMT1Amount').FieldId__c + '=';
    			fields += '&' + fieldIdMap.get('Opp.PMT2Amount').FieldId__c + '=';
    			fields += '&' + fieldIdMap.get('Opp.PMT3Amount').FieldId__c + '=';
    			//fields += '&CF' + fieldIdMap.get('Opp.PriceBidContact').FieldId__c + '=&CF' + fieldIdMap.get('Opp.PriceBidContact').FieldId__c + '_lkid=';
    			fields += '&' + fieldIdMap.get('Opp.TermsCustomerNotesPrintsonInvoice').FieldId__c + '=';
    			fields += '&' + fieldIdMap.get('Opp.TERMSNOTES').FieldId__c + '=';
    			fields += '&opp11=Quote considered - no competition';				// StageName
    			fields += '&opp9=';													// CloseDate
    			//fields += '&opp3=';													// Name
    			
    			pr = new PageReference('/' + oppId + '/e?clone=1' + fields + '&ent=Opportunity&retURL=/' + oppId);
    			pr.setRedirect(true);
    			
    		} catch(Exception e) {
    			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Exception: ' + e.getMessage()));
    		}
    	}
    	
    	return pr;
    }
}