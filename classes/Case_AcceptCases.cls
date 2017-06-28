public class Case_AcceptCases {
	
	private ApexPages.StandardSetController stdSetCon;
	
	public List<Case> selectedCases;
	public Boolean isError {get; set;}
	public Boolean isPartnerUser {get; set;}
	public String pageURL {get; set;}
	public String listViewPageURL {get; set;}
	public String caseNumber {get; set;}
	
	private String listViewFilterId;
	
	public Case_AcceptCases(ApexPages.StandardSetController stdSetCon){
		this.stdSetCon = stdSetCon;
		selectedCases = stdSetCon.getSelected();
		listViewFilterId = stdSetCon.getFilterId();
		isError = false;
		
		if (UserInfo.getUserType() == 'PowerPartner') {
			isPartnerUser = true;
		} else {
			isPartnerUser = false;
		}
    }
    
    public PageReference acceptCases() {
    	PageReference pr = null;
    	
    	isError = false;
    	pageURL = '../';
    	if (selectedCases.size() > 0) {
    		
			Set<Id> cIds = new Set<Id>();
    		for (Case c :selectedCases) {
    			cIds.add(c.Id);
    		}
    		
    		List<Case> acceptList = new List<Case>();
    		acceptList = [select Id, CaseNumber, OwnerId, RecordTypeId from Case where Id in :cIds];
    		
    		Map<Id,Schema.RecordTypeInfo> rtByIdMap = Schema.SObjectType.Case.getRecordTypeInfosById();
    		for (Case c :acceptList) {
    			if (c.OwnerId.getSObjectType().getDescribe().getName() == 'User') {
					ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'One or more selected cases have already been accepted. Please try again.'));
					isError = true;
					break;
				}
				
				if (rtByIdMap.containsKey(c.RecordTypeId) && rtByIdMap.get(c.RecordTypeId).getName() == 'Email and Web Inquiries' && selectedCases.size() > 1) {
					ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Only one case can be selected when selecting Email and Web Inquiries cases. Please try again.'));
					isError = true;
					break;
				}
				c.OwnerId = UserInfo.getUserId();
    		}
    		
    		if (!isError) {
    			try {
    				update acceptList;
    				caseNumber = acceptList[0].CaseNumber;
    				pageURL = '../' + acceptList[0].Id;
    				listViewPageURL = '../500?fcf=' + listViewFilterId;
    				//pr = new PageReference('/' + selectedCases[0].Id);
    				//pr.setRedirect(true);
    			} catch(Exception e) {
    				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Case change ownership exception: ' + e.getMessage()));
    				isError = true;
    			}
    		}
    		
    	} else {
    		ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'You must select at least one Case.'));
    		isError = true;
    	}
    	
    	return pr;
    }
}