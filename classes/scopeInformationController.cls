/**
*  @Description : Controller used in ScopeInformationPage to display the Scope Information Details in Opportunity
*                 where VF page is rendered as PDF to display the content.
*  @Author      : Bhargavi Vadlamani
*  @Created Date: 
*  @Throws      : Exception
**/
public class scopeInformationController {

//Variables that are used in Visualforce Page
    public String opptyId{get;set;}
    public Opportunity OppObj{get;set;}
    public List<Scope_Poc_Information__c> scopeObjList{get;set;}
    public scopeInformationController(ApexPages.StandardController controller) {

    }
    
    public scopeInformationController ()
    {
        opptyId = System.currentPageReference().getParameters().get('opptyId');
    }
// Get the Scope Information for the Opportunity
    public List<Scope_Poc_Information__c> getScopinfo()
    {
        //Get the Opportunity associated with
        OppObj = [select id,Account.name from opportunity where id =:opptyId  ];
        //Get the Scope Information Details 
        try
        {
            scopeObjList = [Select id,name,Scope__c ,Approver__c,AutoRABIT_POC__c,AutoRABIT_POC__r.name,sign_off_Criteria__c,Assumptions__c,License_provision_complete__c,Demo_Completed__c,Opportunity__c,Opportunity__r.name,Opportunity__r.Account.name,Out_ofScope__c,Person_to_Contact__c,Poc_End_Date__c,Poc_Scope__c,Poc_Start_Date__c from Scope_Poc_Information__c where Opportunity__r.id = :opptyId and Is_primary__c=true];
        }
        
        Catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());

        }
        return scopeObjList;
    }    
}