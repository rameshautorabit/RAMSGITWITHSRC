/**
    * Description: Extensions class which closes a case from the Case Comments Page
    * Author: vk@ff 
    * TestClass:
    * Change Log:
        -V0.1-Initial
        -v0.2 - Update controller to take Case or case Comment as parameters cweiss@forefrontcorp.com 20140826
**/
        
public without sharing class CloseCaseController
{
    //Variables
    private Id commentId;
    private Id caseId;
    public Case_Comments__c c{get;Set;}
    public Case caseToClose{get;set;}
    public String cStatus{get;Set;}
    public Boolean isStatusError {get; set;}
    
    //Contructor
    public CloseCaseController(ApexPages.StandardController controller)
    {
        isStatusError = false;
        map<String, String> UrlParameterMap = ApexPages.currentPage().getParameters();
        System.debug(UrlParameterMap);
        if (UrlParameterMap.containsKey('caseid'))
        {
            caseId = UrlParameterMap.get('caseid');
        }
        if (UrlParameterMap.containsKey('id'))
        {
            commentId = UrlParameterMap.get('id');
        }
    System.debug('CaseId: ' + caseId + ' CommentId: ' + commentId);

        //commentId=controller.getId();
        //check to see if this is a case or another object
        if(commentId!=null)
        {
            c=[SELECT Id,Name,Case__c FROM Case_Comments__c WHERE Id=: commentId];
            if(c!=null && c.Case__c!=null)
            {
                caseId=c.Case__c;
            }
          
        }
            caseToClose=new Case();
            if(caseId!=null)
            {
                caseToClose=[SELECT Id,CaseNumber,Status, Case_Resolution_Notes__c FROM Case WHERE Id=:caseId];
            }
        
       System.debug('Case TO CLOSE' + caseToClose);
    }
    
    // Get Close-Status Picklist values for a Case
    public static List<SelectOption> getStatusValues() {
		
        // Retrieve the sorted list of Case Status values
		List<CaseStatus> csList = new List<CaseStatus>();
		csList = [select Id, IsClosed, MasterLabel, IsDefault, SortOrder from CaseStatus order by SortOrder asc];
        
        // Retrieve close status values to display from the custom setting
        Map<String, CaseCloseStatuses__c> ccsMap = CaseCloseStatuses__c.getAll();
		
		// Create Status selectOption list with appropriate sort order
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('--None--','--None--'));
		for (CaseStatus cs :csList) {
        	if (ccsMap.containsKey(cs.MasterLabel)) {
        		options.add(new SelectOption(cs.MasterLabel, cs.MasterLabel));
        	}
		}
		
		return options;
    }
    
    //Close the Case
    public PageReference closeCase()
    {
        if(caseToClose!=null)
        {
            if (cStatus != '--None--') {
            	caseToClose.Status=cStatus;
            	try
            	{
                	update caseToClose;
            	}
            	catch(DmlException e)
            	{
                	System.debug(e.getMessage());
                	ApexPages.addMessages(e);
                	return null;
            	}
            	
            	return new PageReference('/'+caseToClose.Id);
            } else {
            	isStatusError = true;
            	ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Invalid Data. Status field is required.'));
            }
        }
        return null;
    }
	
	// Cancel the close operation
	public PageReference cancelClose() {
		PageReference pr;
		if (commentId != null) {
			pr = new PageReference('/' + commentId);
		} else {
			pr = new PageReference('/' + caseToClose.Id);
		}
		return pr;
	}
}