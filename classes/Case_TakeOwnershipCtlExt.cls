public with sharing class Case_TakeOwnershipCtlExt {
	
	/*
	 *	Case controller extension - methods to support ownership change.
	 *
	 */
	
	ApexPages.StandardController stdController;
	public Case caseRec {get; set;}
	
	// Constructor
	public Case_TakeOwnerShipCtlExt(ApexPages.StandardController stdController) {
		
		caseRec = new Case();
		this.caseRec = (Case)stdController.getRecord();
		caseRec = [select Id, CaseNumber from Case where Id = :this.caseRec.Id];
	}
	
	public PageReference takeOwnership() {
		PageReference pr = null;
		UserRecordAccess ura = new UserRecordAccess();
		
		ura = [select RecordId, HasTransferAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :caseRec.Id];
		if (ura.HasTransferAccess) {
			
			caseRec.OwnerId = UserInfo.getUserId();
			
			try {
				update caseRec;
				pr = new PageReference('/' + caseRec.Id);
			} catch (Exception e) {
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Ownership change failed - exception: ' + e.getMessage()));
			}
		} else {
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Ownership change failed - insufficient privileges.'));
		}
		return pr;
	}
}