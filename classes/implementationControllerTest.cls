/**
*  @Description : Test class for Implementation Questionnaire Information Page to display the Implementation Questionnaire Details and used in Force.com Sites where Customer fills in the information.
*  @Author      : Bhargavi Vadlamani
*  @Created Date: 
*  @Throws      : Exception
**/
@istest(seeAllData=true)
Public class implementationControllerTest{

public static testmethod void testImplementationQuestData(){

Account a= new Account();
a.Name = 'Test Account';
insert a;

Opportunity oppty = new Opportunity();
oppty.name = 'Test Opportunity';
oppty.closedate = DATE.TODAY()+30;
oppty.Accountid = a.id;
oppty.stagename = 'scoping';
insert oppty;

lead leadObj = new Lead();
leadObj.Lastname = 'Test';
leadObj.IsConverted = true;
leadObj.Company = 'Test Account';
leadObj.ConvertedAccountId = a.id;
leadObj.ConvertedOpportunityId = oppty.id;
Insert leadObj;



Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
                
                 
implementationQuestionnaireController implementQuest = new implementationQuestionnaireController();
implementQuest.Emailval = 'test@testmail.com';
implementQuest.almTools = 'Jira,IBM Rally';
implementQuest.challenges = 'Setting up profiles permission is a big challenge';
implementQuest.longTermGoals = 'Set up full CI';
implementQuest.releaseDuration = '4';
implementQuest.shortTermGoals = 'Usage of version control';
implementQuest.sizeOfSandbox = '300MB';
implementQuest.testAutomation = 'Nothing in place';
implementQuest.dataLoaderTrial = 'Yes';
implementQuest.companyName = 'Test Account';
implementQuest.deploymentUser = 'Developers';
implementQuest.save();
attach.parentId= implementQuest.quesObj.id;
        
       
}
}