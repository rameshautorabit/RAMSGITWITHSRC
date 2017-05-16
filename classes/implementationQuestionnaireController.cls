/**
*  @Description : Controller used in Questionnaire Information Page to display the Implementation Questionnaire Details and used in Force.com Sites where Customer fills in the information.
*  @Author      : Bhargavi Vadlamani
*  @Created Date: 
*  @Throws      : Exception
**/

public class implementationQuestionnaireController
{
    //Variable Declaration
    public Attachment attach {get;set;}
    public Questionnaire_Implementation__c quesObj{get;set;}
    Public string companyName{get;set;}
    public string Emailval {get;set;}
    Public string almTools{get;set;}
    public string challenges{get;set;}
    Public string currentversionControl{get;set;}
    public string deploymentUser{get;set;}
    Public string hoursEffort{get;set;}
    public string longTermGoals{get;set;}
    Public string noOfSandbox{get;set;}
    public string releaseDuration{get;set;}
    //Public string noOfSandbox{get;set;}
    public string shortTermGoals{get;set;}
    Public string sizeOfSandbox{get;set;}
    public string testAutomation{get;set;}
    public string dataLoaderTrial{get;set;}
    public boolean isclick{get;set;}
    public boolean questionPage{get;set;}
    
    List<id> OptyIdlist = new list<id>();
    List<Lead> leadIdList = new List<LEad>();
    List<id> ContactEmail = new list<id>();
    List<Opportunity> opptyList = new List<Opportunity>();
    public List<Lead> leadList{get;set;}
    
    public implementationQuestionnaireController() {
        isclick = false;
        attach = new Attachment();
        
    }
    //This method is to search for the Opportunity and lead if existing with the provided Email and Company.
    public void searchdata()
    {
     If(string.isnotempty(companyName)||string.isnotempty(Emailval))
        {
            leadList = [select id,name,company,email,isconverted,ConvertedOpportunityId from lead where (company = :companyName or email = :Emailval)];
            if(leadList.size()>0)
            {
                for(Lead leadObj : leadList)
                {
                    if(leadObj.isconverted == true)
                    {
                        OptyIdlist.add(leadObj.ConvertedOpportunityId);
                    }
                    else
                    {
                        leadIdList.add(leadObj);
                    }
                }
                
                opptyList = [select id,name,account.name,Contact_Name__r.name,Contact_Name__r.email from opportunity where id in : OptyIdlist];
            }
          
        }
      
    }
    //The below method is to save the information on submitting the implementation questionnaire form.
    public PageReference Save()
    {
        searchdata();
        isclick = true;
        Id LeadRecordTypeId = Schema.SObjectType.Questionnaire_Implementation__c.getRecordTypeInfosByName().get('Lead Questionnaire').getRecordTypeId();
        Id OptyTypeId = Schema.SObjectType.Questionnaire_Implementation__c.getRecordTypeInfosByName().get('Opportunity Questionnaire').getRecordTypeId();
        questionPage = true;
        if(Emailval==null)
        {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter Email Address '));
        return null;
        }
        if(companyName==null)
        {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter Company Name '));
        return null;
        }
       //Map all the fields to the Questionnaire_Implementation__c Object.
        try {
            quesObj = new Questionnaire_Implementation__c();
            quesObj.ALM_Tools__c = almTools;
            quesObj.Challenges__c= challenges;
            quesObj.Current_Version_Control_Tool_If_Exists__c = currentversionControl;
            quesObj.Deployment_User__c = deploymentUser;
            quesObj.Hours_of_effort__c = hoursEffort;
            quesObj.Email__c = Emailval;
            quesObj.Company_Name__c = companyName;
            quesObj.Long_Term_Goals__c = longTermGoals;
            quesObj.No_of_Sanbox_in_Release__c = noOfSandbox;
            quesObj.Release_Duration__c = releaseDuration;
            quesObj.Short_Term_Goals_with_current_RLM__c = shortTermGoals;
            quesObj.Size_of_Sanboxes__c = sizeOfSandbox;
            quesObj.Text_Automation_Details__c= testAutomation;
            quesObj.Data_Loader_Capabilities__c = dataLoaderTrial;
            
            //Check if there is any Opportunity exisitng with Email or Company name 
            if(opptyList  !=null && opptyList.size()>0)
            {
                for(Opportunity oppObj : opptyList )
                {
                    if((string.isnotempty(companyName) && oppObj.Account.name.equalsIgnoreCase(companyName))||(string.isnotempty(Emailval) && oppObj.Contact_Name__r.email.equalsIgnoreCase(Emailval)))
                    {
                        quesObj.recordtypeId = OptyTypeId;
                        quesObj.OpportunityAcc__c = oppObj.accountid;
                    } 
                }
            }
            //Else check for the Lead
            else if(leadIdList!=null && leadIdList.size()>0)
            {
                for(lead leadobjvar: leadIdList)
                {
                    if((string.isnotempty(companyName) && leadobjvar.company.equalsIgnoreCase(companyName))||(string.isnotempty(Emailval) && leadobjvar.email.equalsIgnoreCase(Emailval)))
                    {
                    quesObj.recordtypeId = LeadRecordTypeId;
                    quesObj.Lead__c = leadobjvar.id;
                    }
                }
            }
        //Iserting into Implementation Questionnaire Object.  
        insert quesObj;
        //Inserting the uploaded files as attachments on Implementation Questionnaire Object.
        if(attach.name!=null && attach.body!=null){
            attach.ParentId = quesObj.id;
            insert attach;
        }
    } 
    //Catch the Exceptions if any
    catch(System.DMLException e) {
        ApexPages.addMessages(e);
        return null;
    }
    //Redirecting to "Thank you page" after submitting Implementation Questionnaire form.
    PageReference pg = page.ThankYouPage;
    pg.setRedirect(true);
    return pg;

}

}