global class Case_Accept {
	
	/*
	 *	Mimics the standard Salesforce Case list view Accept button. Called from a Case custom list view button.
	 *	Changes ownership of the supplied Cases to the running user.
	 *
	 *	If no errors (not trying to accept a case that has already been accepted), returns TRUE so that the custom 
	 *	button will take the user to the detail page of the first Case record selected.
	 */
	
	webService static Boolean acceptCases(List<Id> caseIds) {
		
		Boolean notAlreadyAccepted = true;
		List<Case> caseList = new List<Case>();
		caseList = [select Id, CaseNumber, OwnerId, RecordTypeId, Status from Case where Id in :caseIds];
		if (!caseList.isEmpty()) {
			for (Case c :caseList) {
				if (c.OwnerId.getSObjectType().getDescribe().getName() == 'User') {
					notAlreadyAccepted = false;
					break;
				}
				c.OwnerId = UserInfo.getUserId();
			}
			
			if (notAlreadyAccepted) {
				update caseList;
			}
		}
		
		return notAlreadyAccepted;
	}
}