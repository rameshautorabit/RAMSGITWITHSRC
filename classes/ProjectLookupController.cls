public with sharing class ProjectLookupController {
	
	public Project__c project {get;set;} // new project to create
  	public List<Project__c> results{get;set;} // search results
  	public string searchString{get;set;} // search keyword
  		
  	public Id associatedProjectId {get; set;}
  	
  	Opportunity oppty = new Opportunity();
  	
  	public ProjectLookupController(ApexPages.StandardController stdController) {
  		
  		this.oppty = (Opportunity)stdController.getRecord();
  		
  		System.debug('The Opportunity: ' + this.oppty);
  				
    	project = new Project__c();
    	project.name = oppty.name;
    	project.Account__c = oppty.AccountId;
    	project.Temp_Account_Name__c = oppty.Account_Name__c;
    	project.Initial_Inquiry_Date__c = oppty.Initial_Inquiry_Date__c;
    	project.Total_Project_Amount__c = oppty.Amount;
    	project.Total_Project_Budget__c = oppty.Project_Budget__c;
    	project.Close_Date__c = oppty.CloseDate;
    	project.Opportunity_Id__c = oppty.Id;
    	
    	// get the current search string
    	searchString = System.currentPageReference().getParameters().get('lksrch');
    	runSearch();  
  	}

  	// performs the keyword search
  	public PageReference search() {
    	runSearch();
    	return null;
  	}

  	// prepare the query and issue the search command
  	private void runSearch() {
    	results = performSearch(searchString);               
  	} 

  	// run the search and return the records found. 
  	private List<Project__c> performSearch(string searchString) {

		String soql = 'select id, name, Account__c from Project__c';
    	if(searchString != '' && searchString != null)
      		soql = soql +  ' where name LIKE \'%' + searchString +'%\'';
    	soql = soql + ' limit 5';
    	System.debug(soql);
    	return database.query(soql); 
  	}

  	// associate the opportunity to the selected project record
  	@RemoteAction
  	public static void associateProject(Id associatedProjectId, Id originatingOpptyId){
    	
		System.debug('Associated Project: ' + associatedProjectId);
		System.debug('Associated Project: ' + originatingOpptyId);
		
		Opportunity originatingOppty = [Select Id,Parent_Project__c from Opportunity where Id =:originatingOpptyId];
		originatingOppty.Parent_Project__c = associatedProjectId;
		
		update originatingOppty;
  	}
  	
  	// save the new project record
  	public PageReference saveProject() {
    	insert project;
    	return null;
  	}
}