public with sharing class CaseComment_NewCtlExt {
	
	//ApexPages.StandardController stdController;
	private ApexPages.StandardSetController stdSetCon;
	
	private Id recordId;
	private String orderFieldId = '00N50000003N7sU';
	private String caseFieldId = '00N500000039seq';
	private String caseCommentPrefix = 'a0m';
	private String caseCommentEnt = '01I50000000GFP1';
	
	public List<Case_Comments__c> selectedComments;
	public String tabName {get; set;}
	public String pageURL {get; set;}
	public Boolean isError {get; set;}
	public Boolean isPartnerUser {get; set;}
	
	//public CaseComment_NewCtlExt(ApexPages.StandardController stdController) {
	public CaseComment_NewCtlExt(ApexPages.StandardSetController stdSetCon) {
		
		isError = false;
		tabName = 'New Comment';
		pageURL = '../';
		recordId = ApexPages.currentPage().getParameters().get('id');
		
		if (UserInfo.getUserType() == 'PowerPartner') {
			isPartnerUser = true;
		} else {
			isPartnerUser = false;
		}
	}
	
	public PageReference newCaseComment() {
		
		String fieldId;
		String recordName;
		String ccRTName = 'Standard';
		
		if (String.isNotBlank(recordId)) {
			
			try {
				Map<String, Schema.RecordTypeInfo> ccRTByNameMap = Schema.SObjectType.Case_Comments__c.getRecordTypeInfosByName();
				Map<Id, Schema.RecordTypeInfo> caseRTByIdMap = Schema.SObjectType.Case.getRecordTypeInfosById();
				Map<String, CaseToCaseLineRecordTypes__c> ctcMap = CaseToCaseLineRecordTypes__c.getAll();
				
				String objName = recordId.getSObjectType().getDescribe().getName();
				String queryString = 'SELECT Id, RecordTypeId, ';
				if (objName == 'Case') {
					queryString += 'CaseNumber';
				} else {
					queryString += 'Name';
				}
				queryString += ' FROM ' + objName + ' WHERE Id = \'' + recordId + '\'';
				SObject sObj = Database.query(queryString);
				
				if (objName == 'RH_Order__c') {
					RH_Order__c orderRecord = (RH_Order__c)sObj;
					ccRTName = 'Order';
					recordName = orderRecord.Name;
					fieldId = orderFieldId;
				}
				
				if (objName == 'Case') {
					Case caseRecord = (Case)sObj;
					if (caseRTByIdMap.containsKey(caseRecord.RecordTypeId)) {
						if (ctcMap.containsKey(caseRTByIdMap.get(caseRecord.RecordTypeId).getName())) {
							ccRTName = ctcMap.get(caseRTByIdMap.get(caseRecord.RecordTypeId).getName()).CaseComment_Record_Type__c;
						}
					}
					recordName = caseRecord.CaseNumber;
					fieldId = caseFieldId;
				}
				
				pageURL = '../' + caseCommentPrefix + '/e?CF' + fieldId + '=' + recordName + '&CF' + fieldId + '_lkid=' + recordId + '&retURL=/' + recordId + '&RecordType=' + ccRTByNameMap.get(ccRTName).getRecordTypeId() + '&ent=' + caseCommentEnt;
			
			} catch(Exception e) {
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Fatal exception: ' + e.getMessage()));
				isError = true;
			}
			
		} else {
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Invalid page parameters.'));
			isError = true;
		}
		
		return null;
	}
}