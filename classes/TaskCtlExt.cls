public with sharing class TaskCtlExt {
	
	/*
	 *	Controller extension for CaseTask_new page. Automatically selects Task record type
	 *	based upon Case record type.
	 *
	 */
	
	private String caseId;
	private String retURL;
	
	public TaskCtlExt(ApexPages.StandardController stdCon) {
		
		caseId = ApexPages.currentPage().getParameters().get('caseId');
		retURL = ApexPages.currentPage().getParameters().get('retURL');
	}
	
	public PageReference newTask() {
		Case caseRec;
		PageReference pr = null;
		String taskRTName = 'Standard';
		Map<Id, Schema.RecordTypeInfo> rtCaseByIdMap = Schema.SObjectType.Case.getRecordTypeInfosById();
		Map<String, Schema.RecordTypeInfo> rtTaskByNameMap = Schema.SObjectType.Task.getRecordTypeInfosByName();
		Map<String, CaseToCaseLineRecordTypes__c> caseToCaseLineMap = CaseToCaseLineRecordTypes__c.getAll();
		
		try {
			caseRec = [select Id, CaseNumber, RecordTypeId from Case where Id = :caseId];
			if (rtCaseByIdMap.containsKey(caseRec.RecordTypeId)) {
				if (caseToCaseLineMap.containsKey(rtCaseByIdMap.get(caseRec.RecordTypeId).getName())) {
					if (rtTaskByNameMap.containsKey(caseToCaseLineMap.get(rtCaseByIdMap.get(caseRec.RecordTypeId).getName()).Task_Record_Type__c)) {
						taskRTName = caseToCaseLineMap.get(rtCaseByIdMap.get(caseRec.RecordTypeId).getName()).Task_Record_Type__c;
					}
				}
			}
			
			pr = new PageReference('/00T/e?what_id=' + caseRec.Id + '&retURL=' + retURL + '&RecordType=' + rtTaskByNameMap.get(taskRTName).getRecordTypeId() + '&ent=Task');
			pr.setRedirect(true);
			
		} catch(Exception e) {
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Fatal exception: ' + e.getMessage()));
		}
		
		return pr;
	}
}