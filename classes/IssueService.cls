public without sharing class IssueService {
	
	public static void processIssueSharing(List<Issue__c> Issues, boolean isInsert){
		
		List<Issue__c> VendorIssues = new List<Issue__c>();
		Set<String> Vendors = new Set<String>();
		Map<String, String> VendorPublicGroupIdMap = new Map<String, String>();
		List<Issue__Share> IssueShares  = new List<Issue__Share>();
		
		
		
		for(Issue__c issue: Issues){
			
			System.debug('Is Insert: ' + isInsert + ' Issue Sharing Update: ' + issue.Issue_Sharing_Update__c);
			
			if(isInsert || !isInsert && issue.Issue_Sharing_Update__c){
				if(!String.isBlank(issue.Vendor_Number__c)){
					VendorIssues.add(issue);	
					Vendors.add(issue.Vendor_Number__c);
				
					System.debug('Vendor Issues: ' + VendorIssues);
					System.debug('Vendors:' + Vendors);
				}
			}
		}
		 
		for(Account a: [Select PublicGroupId__c, Vendor_Number__c from Account where Vendor_Number__c in :Vendors limit 1]){
			VendorPublicGroupIdMap.put(a.Vendor_Number__c, a.PublicGroupId__c);       	
		}
		            
		for(Issue__c issue :VendorIssues){  
				Issue__Share SupplierShare = new Issue__Share();          
			    SupplierShare.ParentId = issue.Id;
			    SupplierShare.UserOrGroupId = VendorPublicGroupIdMap.get(issue.Vendor_Number__c);
			    SupplierShare.AccessLevel = 'Read';  
			    SupplierShare.RowCause = Schema.Issue__Share.RowCause.Supplier_Access__c;
			    IssueShares.add(SupplierShare);
		}
		        
		if(!IssueShares.isEmpty()){
			Database.SaveResult[] issueShareInsertResult = Database.insert(IssueShares,false);
			for (Database.SaveResult sr : issueShareInsertResult) {
				if (sr.isSuccess()) {
			    	System.debug('Successfully inserted Share Record.Share ID: ' + sr.getId());
			    	System.debug('Sharing Record: ' + sr);
			    }else{
			   		// Operation failed, so get all errors                
			        for(Database.Error err : sr.getErrors()) {
			        	System.debug('The following error has occurred.');                    
			            System.debug(err.getStatusCode() + ': ' + err.getMessage());
			            System.debug('Issue fields that affected this error: ' + err.getFields());
			        }
		        }  
		    }  
		}
	}
	
	// Set the Status field on related Contract Cases to In Progress
	// - after insert
	public static void contractCaseStatus(List<Issue__c> newList) {
		Set<Id> cIds = new Set<Id>();
		
		for (Issue__c i :newList) {
			if (i.Case__c != null) {
				cIds.add(i.Case__c);
			}
		}
		
		if (!cIds.isEmpty()) {
			Map<String, Schema.RecordTypeInfo> caseRtByNameMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
			List<Case> caseList = new List<Case>();
			List<Case> caseUpList = new List<Case>();
			caseList = [select Id, Status from Case where Id in :cIds and RecordTypeId = :caseRtByNameMap.get('Contract').getRecordTypeId()];
			
			for (Case c :caseList) {
				if (c.Status == 'New') {
					c.Status = 'In Progress';
					caseUpList.add(c);
				}
			}
			
			if (!caseUpList.isEmpty()) {
				update caseUpList;
			}
		}
	}
}