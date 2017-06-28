/* Class: ViewCaseCommentsController
** Test Class: 
** Description: Class used to display Case_Comments__c on a case record detail page.
** Edits:   Chris Del Fattore @ ForeFront Corp 8/25/2014
**          Added standard set controller to create pagination for the page.
**          Added hideNextPre boolean to show/hide next and previous page link.
**          Other changes denoted by cd@ff 8/25/2014
**          CarlWeiss/Forefront 9/18/2014 added remote action
**          Added code to parse URL parameters for Service Console vk@ff on 12/10/2014
*/

global without sharing class ViewCaseCommentsController
{
    public Id caseId{get;set;}
    public Case ca{get;set;}
    public List<Case_Comments__c> lstOfComments{get;Set;} 
    public ApexPages.StandardSetController setOfComments {get;Set;}
    public Boolean hideNextPre {get;set;}
    public String viewAll {get;Set;}
    
    public ViewCaseCommentsController(ApexPages.StandardController controller)
    {
        //caseId is the Id of the case
        //caseId=controller.getId();
        System.debug('URL PASSED' + ApexPages.currentPage().getParameters());
        
        //Standard screen
        if(ApexPages.currentPage().getParameters().get('id')!=null)
        {
            caseId=ApexPages.currentPage().getParameters().get('id');
        }
        //For Service Console, the parameter passed as isdtp=nv?Id=500R0000004MccI. Parse the string to get the case Id
        //Added by vk@ff on 12/10/2014 
        else
        {
            String s=ApexPages.currentPage().getParameters().get('isdtp');
            List<String> lstOfStr=s.split('=');
            caseId=(Id)lstOfStr[1];
        }
            
        System.debug('CASE ID' + caseId);
        ca=new Case();
        ca=[SELECT Id, CaseNumber,Call_Outcome__c FROM Case WHERE Id=:caseId];

        //viewall is a url parameter, used when the the modal window is displayed on the viewcasecomments
        viewAll = ApexPages.currentPage().getParameters().get('ViewAll');

        if(caseId!=null)
        {
            //query for comments related to the list, store them in a list of case comments cd@ff 8/25/2014
            lstOfComments=[SELECT Id, Action_Required__c, Comment__c,Contact__c,Case__c, CreatedDate, CreatedBy.Name, Name,Call_Outcome__c FROM Case_Comments__c WHERE Case__c=: caseId ORDER BY CreatedDate DESC];
            
            //take the list of case comments and place them in a standard set controller. this will create the pagination cd@ff 8/25/2014
            setOfComments = new ApexPages.StandardSetController(lstOfComments);
            

            if(viewAll != 'true') {
                //set the pagination size to 10 records per page. cd@ff 8/25/2014
                setOfComments.setPageSize(10);
                //if less than 10 case comments are returned hide the previous and next page links cd@ff 8/25/2014
                hideNextPre = (lstOfComments.size() > 10) ? true : false;
            }
            else {
                setOfComments.setPageSize(lstOfComments.size());
                //hideNextPre is rendered on the vf page cd@ff 8/25/2014
                hideNextPre = false;
            }            
        }
        

    }
    //method used to pass the case comments to the ViewCaseComments page cd@ff 8/25/2014
    public List<Case_Comments__c> getCaseRecords(){
        return (List<Case_Comments__c>) setOfComments.getRecords();
    }
    //method for the next page link cd@ff 8/25/2014
    public void Next(){
        setOfComments.next();
    }
    //method for the previous page link cd@ff 8/25/2014
    public void Previous(){
        setOfComments.previous();
    }

    @RemoteAction
    global static String getButtonFieldValue(String objectName, String fieldName)
    {
        System.debug(objectName);
        System.debug(fieldName);
        FieldIdLookup__c  fIdL = [SELECT FieldId__c FROM FieldIdLookup__c WHERE FieldName__c =: fieldName AND ObjectName__c =: objectName LIMIT 1];
        if(String.isNotEmpty(fIdL.FieldId__c))
        {
            return fIdL.FieldId__c;
        }
        else return '';
    }
}