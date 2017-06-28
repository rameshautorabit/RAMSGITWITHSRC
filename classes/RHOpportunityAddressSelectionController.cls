/*Created by: Snehal Asare 5/23/2017
 * Note: In this classes the field address1, address 2, city, state, zip are hard coded as their is no way to find the field id by standard method
 */
public with sharing class RHOpportunityAddressSelectionController {
    private final Account rhAccount;
    public List<Contact_Address__c> contactAdressList{get; set;}
    List<string> recordTypeListt= new List<string>();
    public String selectedRecordType{get;set;}
    public String selectedContactId{get;set;}
    public String accountId{get;set;}   
    public List<RecordType> recordTypeDescription{get; set;}    
    public SelectOption[] recordTypeOptions { //this is where we're going to pull the list
		public get;
		private set;
	}   
    Public List<Contact_Address__c> getcontactAdressList () {
		return contactAdressList ;
	}
    
    public RHOpportunityAddressSelectionController() {
        contactAdressList= new List<Contact_Address__c>();
        accountId=ApexPages.currentPage().getParameters().get('id');
       
		recordTypeListt = getAvailableRecordTypeNamesForOpportunity();
		recordTypeDescription=getOpportunityRecordTypeDescription(recordTypeListt);
		 
		this.recordTypeOptions = new SelectOption[]{};
		//fill dropdown with all record type available to the logged in user
		for (string record: recordTypeListt) {
			this.recordTypeOptions.add(new SelectOption(record,record));
		}
        //Fetch all contact address associated to the account
         contactAdressList.add(new Contact_Address__c());
         contactAdressList.addAll([SELECT name,Address_for_display__c,Contact__r.name, Company_Name__c,Day_Phone__c,Email__c,First_Name__c,
                                                           Address_1__c,Address_2__c,CITY__c,State__c,Zip__c FROM Contact_Address__c
                                                          where Contact__r.accountid =:accountId]);        
	}
     
    //Get the id of contact that has been selected  
    public void getSelectedContactAddress(){            
        selectedContactId = ApexPages.currentPage().getParameters().get('contactAddressid');       
    }
    
    public PageReference generateUrl(){
        
        String address1fieldId,address2fieldId,cityfieldId,statefieldId,zipcodefieldId,phonefieldId;
                       
        system.debug('selected contactaddress '+selectedContactId); 
        
        //Get details of selected contact address
        contactAdressList=getContactAddressDetailsFromSelectedContactAddress(contactAdressList,selectedContactId);
                       
        //Get prefix of opportunity run time
        String prefix = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getKeyPrefix();
        //Get selected recordtype id of opportunity run time
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(selectedRecordType).getRecordTypeId();
        system.debug(' Selected record type ' +devRecordTypeId);
        PageReference opportunityPage = new PageReference('/' + prefix + '/e?RecordType='+devRecordTypeId +'&retURL=%2F'+accountId);
        String html;
        Blob pageContent; 
        
        //skip getcontent() method as the this method cannot be run via test class
        if (Test.IsRunningTest()){          
            pageContent=Blob.valueOf('<label for="1">Address 1</label><label for="2">City</label><label for="3">State</label><label for="4">Zip Code</label><label for="6">Address 2</label>');
          }
        else{            
            pageContent= opportunityPage.getContent();
      	  } 
        if (pageContent != null ) 
       		 {
            html = pageContent.toString();
        	}
        system.debug('html'+ html);
        Matcher macher = Pattern.compile('<label for="(.*?)">(<span class="requiredMark">\\*</span>)?(.*?)</label>').matcher(html);
        while ( macher.find() ) 
        {
            String label = macher.group(3);
            String fldId = macher.group(1);
            system.debug(label+' ############ '+fldId);
            
            if(label=='Address 1')
            {                
                address1fieldId=fldId;
            }
             if(label=='Address 2')
            {               
                 address2fieldId=fldId;
            }            
             if(label=='City')
            {                
                 cityfieldId=fldId;
            }
             if(label=='State')
            {                
                 statefieldId=fldId;
            }
             if(label=='Zip Code')
            {               
                 zipcodefieldId=fldId;
            }  
             if(label=='Phone')
            {                
                 phonefieldId=fldId;
            }             
    	}
        system.debug('reached after while loop');
        opportunityPage.setRedirect(true);  
        
        //Fill parameter
        opportunityPage= fillUrlParamters(opportunityPage,address1fieldId,address2fieldId,cityfieldId,statefieldId,zipcodefieldId,phonefieldId,contactAdressList,accountId);      
      
        return opportunityPage;
    }
    
    public List<String> getAvailableRecordTypeNamesForOpportunity() {
      List<String> names = new List<String>();
      List<RecordTypeInfo> infos = Opportunity.SObjectType.getDescribe().getRecordTypeInfos();
	      // If there are 2 or more RecordTypes...
	      if (infos.size() > 1) {
              system.debug('recordtype fields'+infos[0]);
	          // We check the Id because Name can change depending on the user's language.
	          for(RecordTypeInfo i : infos) {
	              if (i.isAvailable()&& !String.valueOf(i.getRecordTypeId()).endsWith('AAA')){  
	                 names.add(i.getName());
	              }
	           }
	       }else{ // Otherwise there's just the Master record type,so add it in, since it MUST always be available
            	names.add(infos[0].getName());
        		}
            return names;
        }
    
    public PageReference doCancel()  {
      PageReference pr = new PageReference('/' + accountId ); 
      pr.setRedirect(true); 
      return pr;
    }
    
    //Fill URL parameters so that the address field data get auto populated
    public PageReference fillUrlParamters(PageReference opportunityPage, string address1fieldId, string address2fieldId,string cityfieldId,
                                          string statefieldId, string zipcodefieldId,string phonefieldId, List<Contact_Address__c> contactAdressList, string accountId ){
       
        list<account> accList = [SELECT phone FROM account WHERE id =:accountId];
        opportunityPage.getParameters().put('accid',accountId);
        IF(string.isNotBlank(phonefieldId) && accList.size() >0 ){
             opportunityPage.getParameters().put(phonefieldId,accList[0].phone);
        }

        if(contactAdressList.size()!=0){            
        	 
            IF(string.isNotBlank(address1fieldId)){
            opportunityPage.getParameters().put(address1fieldId,contactAdressList[0].Address_1__c);
            }
            IF(string.isNotBlank(address2fieldId)){
             opportunityPage.getParameters().put(address2fieldId,contactAdressList[0].Address_2__c);
            }
            IF(string.isNotBlank(cityfieldId)){
             opportunityPage.getParameters().put(cityfieldId,contactAdressList[0].CITY__c);
            }
            IF(string.isNotBlank(statefieldId)){
             opportunityPage.getParameters().put(statefieldId,contactAdressList[0].State__c);
            }
            IF(string.isNotBlank(zipcodefieldId)){
             opportunityPage.getParameters().put(zipcodefieldId,contactAdressList[0].Zip__c);
            }
                        
    		return opportunityPage;
        } 
        return opportunityPage;                                     
    } 

    //get field details of selected contact address  
    public List<Contact_Address__c> getContactAddressDetailsFromSelectedContactAddress(List<Contact_Address__c> contactAdressList,String selectedContactId){
       
        if(string.isNotBlank(selectedContactId)){
         
            system.debug('selected contactaddress '+selectedContactId);
            for(Contact_Address__c con: contactAdressList){
                if(con.id ==selectedContactId){
                   system.debug(' Selected contact id ' +con.id);                   
                   contactAdressList.clear(); 
                   contactAdressList.add(con);
                   break;
                }
            }        	
        }else{
            contactAdressList.clear();
        } 
        return contactAdressList;
    }
       
      public List<RecordType> getOpportunityRecordTypeDescription(List<String> availableRecordTypes) {
      	
      	List<RecordType> rtypes = [SELECT Name,description, id FROM RecordType WHERE sObjectType='Opportunity' and name in: availableRecordTypes];
      	return rtypes;
      	
      }     
}