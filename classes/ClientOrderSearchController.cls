public with sharing class ClientOrderSearchController {

  	// search parameters
  	public String fullname {get;set;}
  	public String cwskuid {get; set;}
  	public String ecommdisplayname {get; set;}
  
  	// the sosl
  	private String sosl {get;set;}
  	
  	// the soql
  	private String soql {get;set;}
    
  	// the collection of orders to display
  	public List<RH_Order__c> oList {get;set;} 
  	
  	// the collection of orders with same Sold_To_Name__c as entered by user for fullname
  	public Set<Id> oidList = new Set<Id>();
	
	// the collection of order lines to display
 	public List<Order_Line_Items__c> olList {get;set;}
  	
	// runs the actual SOSL query
	public void runSOSLQuery() {
		
		List<List <sObject>> searchList = search.query(sosl);
		oList = ((List<RH_Order__c>)searchList[0]);
			
		System.debug('Search List: ' + searchList);
		System.debug('oList: ' + oList);
	}
  
  	// runs the actual SOQL query
  	public void runSOQLQuery() {
    	try {
      		olList = Database.query(soql);
    	} catch (Exception e) {
      		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Ooops!'));
    	}
    	
    if(olList.size() == 101){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'More than 100 records found. Please refine your search by providing more parameters.'));
			olList.remove(100);
		}
  	}

  	// runs the search with parameters passed via Javascript
  	public PageReference runSearch() {
  		
		// clear out everything before starting new search
		oidList.clear();
		olList = null;
		
		// sosl query parameter
    	fullname = Apexpages.currentPage().getParameters().get('fullname');
    	
    	// soql query parameters
    	cwskuid = Apexpages.currentPage().getParameters().get('cwskuid');
    	ecommdisplayname = Apexpages.currentPage().getParameters().get('ecommdisplayname');
    	
    	// do sosl 
    	if(fullname.length() >= 2 && fullname.contains(', ')){
    		sosl = 'Find \'' + fullname + '\' IN ALL FIELDS RETURNING RH_Order__c(id, Name, Sold_To_Name__c)';
    		
    		System.debug('SOSL Query: ' + sosl);
    		
    		runSOSLQuery();
    	}else{
    		 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please provide a valid Sold To Name (Last, First) for the client.'));
    		 return null;
    	}
    	
    	if(oList != null){
    		if(!oList.isEmpty()){
    			for(RH_Order__c o: oList){   		
					if(o.Sold_to_Name__c == fullname){
						oidList.add(o.Id);
					}	
				}
    		}else{
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'No Orders found for ' + fullname + '.'));	
    			return null;
    		}
  		}
    	
    	// do soql
    	if(!oidList.isEmpty()){
	   		soql = 'SELECT RH_Order_Number__c, RH_Order_Number__r.Name, RH_Order_Number__r.Opportunity__c, RH_Order_Number__r.Opportunity__r.Name, Name, Id, CW_SKU_ID__c, CW_SKU_ID__r.Name, CW_SKU_ID__r.Ecommerce_Display_Name__c FROM Order_Line_Items__c WHERE CW_SKU_ID__r.Name LIKE \'%' + cwskuid + '%\' AND CW_SKU_ID__r.Ecommerce_Display_Name__c LIKE \'%' + ecommdisplayname + '%\' AND RH_Order_Number__c IN :oidList LIMIT 101';
	    	runSOQLQuery();
    	}else if(oidList.isEmpty()){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'No Orders found for ' + fullname + '.'));	
    	}
    	return null;
  	}
}