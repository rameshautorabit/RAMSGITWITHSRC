public with sharing class OpportunityCloneProductCtlExt {
	
	/*
	 *  Opportunity controller extension - methods to support cloning OpportunityLineItems from another Opportunity.
	 */
	
	ApexPages.StandardController stdController;
	
	public Boolean fatalError {get; set;}
	public String retURL {get; set;}
	
	String oppId;
	Id clonedFrom;
	List<OpportunityLineItem> oliToClone;
	List<OpportunityLineItem> oliCloned;
	
	// Constructor
    public OpportunityCloneProductCtlExt(ApexPages.StandardController stdController) {
    	
    	fatalError = false;
    	
    	oppId = ApexPages.currentPage().getParameters().get('oppId');
    	retURL = ApexPages.currentPage().getParameters().get('retURL');
		
		if (String.isNotBlank(oppId)) {
			
			try {
				Opportunity clonedOpp = [select Id, SyncedQuoteId, Cloned_From__c from Opportunity where Id = :oppId];
				List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
				oliList = [select Id from OpportunityLineItem where OpportunityId = :oppId];
				
				if (clonedOpp.Cloned_From__c == null || clonedOpp.SyncedQuoteId != null || !oliList.isEmpty()) {
					ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Cannot clone Opportunity Products for this Opportunity.'));
					fatalError = true;
				} else {
					clonedFrom = clonedOpp.Cloned_From__c;
				}
			} catch(Exception e) {
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Exception: ' + e.getMessage()));
				fatalError = true;
			}
			
		} else {
			
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'This page must have an Opportunity Id as a page parameter.'));
			fatalError = true;
		}
		
		if (String.isBlank(retURL)) {
			retURL = '/';
		}
    }
    
    public PageReference executeClone() {
    	PageReference pr = null;
    	
    	if (!fatalError) {
			oliToClone = getOpportunityLineItemsToClone();
			if (cloneOpportunityLineItems()) {
				pr = new PageReference('/' + oppId);
				pr.setRedirect(true);
			}
    	}
    	
    	return pr;
    }
    
    /*
    // Read in all fields of the Opportunity record to be cloned
    private Opportunity getOpportunityToClone() {
    	Opportunity opp = new Opportunity();
    	
		String selects = '';
		Map<String, Schema.SObjectField> fMap;
		List<string> selectFields;
		fMap = Schema.getGlobalDescribe().get('Opportunity').getDescribe().Fields.getMap();
		selectFields = new List<string>();
		if (fMap != null) {
			for (Schema.SObjectField ft : fMap.values()) {
				Schema.DescribeFieldResult fd = ft.getDescribe();
				selectFields.add(fd.getName());
			}
		}
		
		if (!selectFields.isEmpty()) {
			for (string s :selectFields) {
				selects += s + ',';
			}
			selects = selects.removeEnd(',');
		}
		
        system.debug('*****Opportunity field list = ' + selects);
		
		opp = (Opportunity)Database.query('SELECT ' + selects + ' FROM Opportunity WHERE Id = \'' + oppId + '\'');
		
		return opp;
    }
    */
    
    // Read in all fields of the OpportunityLineItem records to be cloned
    private List<OpportunityLineItem> getOpportunityLineItemsToClone() {
    	List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
    	
		String selects = '';
		Map<String, Schema.SObjectField> fMap;
		List<string> selectFields;
		fMap = Schema.getGlobalDescribe().get('OpportunityLineItem').getDescribe().Fields.getMap();
		selectFields = new List<string>();
		if (fMap != null) {
			for (Schema.SObjectField ft : fMap.values()) {
				Schema.DescribeFieldResult fd = ft.getDescribe();
				selectFields.add(fd.getName());
			}
		}
		
		if (!selectFields.isEmpty()) {
			for (string s :selectFields) {
				selects += s + ',';
			}
			selects = selects.removeEnd(',');
		}
		
        system.debug('*****OpportunityLineItem field list = ' + selects);
		
		oliList = (List<OpportunityLineItem>)Database.query('SELECT ' + selects + ' FROM OpportunityLineItem WHERE Active__c = true AND OpportunityId = \'' + clonedFrom + '\'');
		
		return oliList;
    }
    
    /*
    // Clone the opportunity, set a few fields, and save
    private Boolean cloneOpportunity() {
    	Boolean success = true;
    	
    	oppCloned = oppToClone.clone(false, true, false, false);
    	
    	// Set a few specific fields on the Opportunity
    	oppCloned.Collections_Efforts__c = '';
    	oppCloned.Balance_Due_Date__c = null;
    	oppCloned.TERMS_NOTES__c = '';
    	oppCloned.Terms_Customer_Notes_Prints_on_Invoice__c = '';
    	oppCloned.Paid_In_Full__c = false;
    	oppCloned.Price_Bid_Contact__c = null;
    	oppCloned.StageName = 'Quote considered - no competition';
    	oppCloned.CloseDate = system.today().addDays(30);
    	oppCloned.SyncedQuoteId = null;
    	oppCloned.Name = 'ChangeMe';
    	
    	try {
    		insert oppCloned;
    	} catch(Exception e) {
    		ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Exception cloning Opportunity: ' + e.getMessage()));
    		success = false;
    	}
    	
    	return success;
    }
    */
    
    // Clone the opportunitylineitems and save
    private Boolean cloneOpportunityLineItems() {
    	OpportunityLineItem oliClone;
    	Boolean success = true;
    	
    	oliCloned = new List<OpportunityLineItem>();
    	for (OpportunityLineItem oli :oliToClone) {
    		oliClone = new OpportunityLineItem();
    		oliClone = oli.clone(false, true, false, false);
    		oliClone.OpportunityId = oppId;
    		oliClone.TotalPrice = null;
    		oliCloned.add(oliClone);
    	}
    	
    	if (!oliCloned.isEmpty()) {
    		try {
    			insert oliCloned;
    		} catch(Exception e) {
    			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Exception cloning OpportunityLineItems: ' + e.getMessage()));
    			success = false;
    		}
    	}
    	
    	return success;
    }
}