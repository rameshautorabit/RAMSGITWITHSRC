public without sharing class CreateCaseClass
{
    
    public List<SelectOption> recordTypeList {get; Set;}
    public String selectedRecordTypeId {get; Set;}
    public Boolean isError {get; set;}
    private @testvisible String currentOrderId;
    private Boolean createCaseLine;
    private String parentCaseId;
	
    
    public CreateCaseClass(ApexPages.StandardController stdCon){
        
        isError = false;
        createCaseLine = false;
        
        currentOrderId = ApexPages.currentPage().getParameters().get('orderId');
        parentCaseId = ApexPages.currentPage().getParameters().get('parentCaseId');
        
    }
    
    // Initialize the set of record types that can be selected
    public PageReference initRecordTypes() {
    	PageReference pr = null;
    	
    	selectedRecordTypeId = null;
    	Map<Id, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById();
		recordTypeList = new List<SelectOption>();
		for (Id rt: rtMap.keySet()) {
			if (rtMap.get(rt).isAvailable() && rtMap.get(rt).getName() != 'Master') {
				recordTypeList.add(new SelectOption(rt, rtMap.get(rt).getName()));
				if (rtMap.get(rt).isDefaultRecordTypeMapping()) {
					selectedRecordTypeId = rt;
				}
			}
		}
        
        if (!recordTypeList.isEmpty()) {
        	if (selectedRecordTypeId == null) {
        		selectedRecordTypeId = String.valueOf(recordTypeList[0].getValue());
        	}
        	
        	if (recordTypeList.size() == 1) {
        		pr = CreateCase();
        	}
        } else {
        	isError = true;
        	ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'No Case record types assigned. You must have at least one assigned Case record type.'));
        }
    	
    	return pr;
    }
    
    public PageReference cancelCreateCase() {
    	PageReference pr;
    	
    	if (String.isNotBlank(parentCaseId)) {
    		pr = new PageReference('/' + parentCaseId);
    	} else {
    		pr = new PageReference('/' + currentOrderId);
    	}
    	return pr;
    }
    
    public PageReference CreateCase(){
		PageReference pr = null;
		String retURL;
		RH_Order__c rhOrder = new RH_Order__c();
		Map<String, CasetoOrderFieldMapping__c> ctoMap = CasetoOrderFieldMapping__c.getAll();
        Map<Id, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById();
        Map<String, CaseToCaseLineRecordTypes__c> CaseToCaseLineRTMap = CaseToCaseLineRecordTypes__c.getAll();
        CaseToCaseLineRecordTypes__c crt = new CaseToCaseLineRecordTypes__c();
        
        if (rtMap.containsKey(selectedRecordTypeId)  &&  CaseToCaseLineRTMap.containsKey(rtMap.get(selectedRecordTypeId).getName())) {
			crt = CaseToCaseLineRTMap.get(rtMap.get(selectedRecordTypeId).getName());
			if (String.isNotBlank(crt.CaseLine_Record_Type__c) && String.isNotBlank(currentOrderId)) {
				List<Order_Line_Items__c> oliList = new List<Order_Line_Items__c>();
				oliList = [select Id, RH_Order_Number__c from Order_Line_Items__c where RH_Order_Number__c = :currentOrderId];
				if (!oliList.isEmpty() && !crt.NoCaseLineAtCreate__c) {
					createCaseLine = true;
				}
			}
		}
		
		// Create the new case
		Case c = new Case();
        c.RecordTypeId = selectedRecordTypeId;
        c.ParentId = parentCaseId;
        if (crt.Case_Required_Fields__c && String.isNotBlank(crt.CaseLine_Record_Type__c) && !crt.NoCaseLineAtCreate__c) {
        	c.Status = 'New';
        } else {
        	c.Status = 'In Progress';
        }
        
        if (String.isNotBlank(currentOrderId)) {
			c.RH_Order_Number__c = currentOrderId;
			
			String query = 'SELECT Id, Name, ';
			for (CasetoOrderFieldMapping__c cof: ctoMap.values()) {
				query += cof.Order_Field__c + ', ';
			}
        	
        	query = query.removeEnd(', ');
        	query += ' FROM RH_Order__c WHERE Id=: currentOrderId LIMIT 1';
        		
        	rhOrder = Database.query(query);
			
			for (CasetoOrderFieldMapping__c cof: ctoMap.values()) {
				
				// Verify that the user has access to the Opportunity before copying the Opportunity Id
				if (cof.Case_Field__c == 'Opportunity_del__c') {
					String oppId = (String)(rhOrder.get(cof.Order_Field__c));
					if (String.isNotBlank(oppId)) {
						Boolean hasOppRead = [select RecordId, HasReadAccess from UserRecordAccess where UserId = :UserInfo.getUserId() and RecordId = :oppId].HasReadAccess;
						if (!hasOppRead) {
							continue;
						}
					}
				}
				c.put(cof.Case_Field__c, rhOrder.get(cof.Order_Field__c));
			}
            
			system.debug('case to build: ' + c);
        }
		
		// Determine appropriate return url
		if (String.isNotBlank(parentCaseId)) {
			retURL = '/' + parentCaseId;
		} else {
			retURL = '/' + currentOrderId;
		}
		
		// Take user to the next step and save the case if necessary
		if (!createCaseLine) {
			String pageURL = '/500/e?retURL=' + retURL + '&cas7=' + c.Status + '&RecordType=' + selectedRecordTypeId;
			if (String.isNotBlank(currentOrderId)) {
				pageURL += '&CF00N500000039sdk=' + rhOrder.Name + '&CF00N500000039sdk_lkid=' + rhOrder.Id;
			}
			if (String.isNotBlank(parentCaseId)) {
				pageURL += '&def_parent_id=' + parentCaseId;
			}
			pageURL += '&ent=Case';
			pr = new PageReference(pageURL);
			
		} else {
			
			try {
				insert c;
				
				if (rtMap.containsKey(selectedRecordTypeId) && rtMap.get(selectedRecordTypeId).getName() == 'Returns') {
					pr = new PageReference('/apex/Case_ReturnReceipt?caseId=' + c.Id);
				} else {
					pr = new PageReference('/apex/CreateCaseLinePage?caseId=' + c.Id + '&orderId=' + currentOrderId + '&retURL=' + retURL);
				}
				
			} catch(DMLException de) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, de.getDMLMessage(0)));
			}
		}
        
        return pr;
    }  
}