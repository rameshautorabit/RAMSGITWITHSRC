trigger ProjectTrigger on Project__c (after insert) {
	
	if (trigger.isAfter) {
		if (trigger.isInsert) {
			ProjectService.associateConvertedOpportunityToNewlyCreatedProject(trigger.new);
		}
	} 
}