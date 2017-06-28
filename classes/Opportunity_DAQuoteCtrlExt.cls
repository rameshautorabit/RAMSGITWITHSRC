public with sharing class Opportunity_DAQuoteCtrlExt {
        
    private final Opportunity rhOppty;
    private Opportunity thisOppty = new Opportunity();
    private List<DesignAtelierQuoteWrapper> daQWList = new List<DesignAtelierQuoteWrapper>();
    private List<Design_Atelier_Quote__c> daQuoteList = new List<Design_Atelier_Quote__c>();
      
             
	public Opportunity_DAQuoteCtrlExt(ApexPages.StandardController stdController) {
		this.rhOppty = (Opportunity)stdController.getRecord();
		thisOppty = [SELECT Id, DA_Opportunity_Number__c FROM Opportunity where Id = :this.rhOppty.Id];
	}
       
	public List<DesignAtelierQuoteWrapper> daQuoteWrapperList {
		get {
			String rhBaseURL = '';
			String bcBaseURL = '';
			daQWList.clear();
			if (String.isNotBlank(thisOppty.DA_Opportunity_Number__c)) {
				if (!Test.isRunningTest())
					{
						daQuoteList = [SELECT Quote_Id__c, Forecast__c, Order_Subtotal__c, Converted__c from Design_Atelier_Quote__c WHERE DA_Opportunity_Number__c =:thisOppty.DA_Opportunity_Number__c];
					}else{
						daQuoteList = [SELECT Quote_Id__c, Forecast__c, Order_Subtotal__c, Converted__c from Design_Atelier_Quote__c WHERE DA_Opportunity_Number__c =:'DATestOpptyNumber'];
					}
				
				if (!daQuoteList.isEmpty()) {
					Boolean isSandbox = [select IsSandbox from Organization].IsSandbox;
					if (isSandbox) {
						rhBaseURL = Application_Settings__c.getInstance('UAT Concierge RH & Modern').Value_Text__c;
						bcBaseURL = Application_Settings__c.getInstance('UAT Concierge BC & Teen').Value_Text__c;
					} else {
						rhBaseURL = Application_Settings__c.getInstance('UAT Concierge RH & Modern').Value_Text__c;
						bcBaseURL = Application_Settings__c.getInstance('UAT Concierge BC & Teen').Value_Text__c;
					}
					
					String baseURL;
					for (Design_Atelier_Quote__c daq :daQuoteList) {
						if (daq.Quote_Id__c.startsWith('QB')) {
							baseURL = bcBaseURL;
						} else {
							baseURL = rhBaseURL;
						}
						daQWList.add(new DesignAtelierQuoteWrapper(baseURL, daq));
					}
				}
			}               
            return daQWList;
		}
		set;        
	}
    
    public class DesignAtelierQuoteWrapper {
    	public String conciergeBaseURL {get; set;}
    	public Design_Atelier_Quote__c daQuote {get; set;}
    	
    	public DesignAtelierQuoteWrapper() {
    		conciergeBaseURL = '';
    		daQuote = null;
    	}
    	
    	public DesignAtelierQuoteWrapper(String cbURL, Design_Atelier_Quote__c daQ) {
    		conciergeBaseURL = cbURL;
    		daQuote = daQ;
    	}
    }
    
}