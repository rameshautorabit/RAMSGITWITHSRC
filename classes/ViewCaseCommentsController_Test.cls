@isTest(SeeAlldata=true)
public class ViewCaseCommentsController_Test {
    static testMethod void ViewCaseCommentsControllerTest() {
        Case c = new Case();
        insert c;
        
        Case_Comments__c cc = new Case_Comments__c(Case__c = c.Id, Comment__c = 'Test Case Comments');
        insert cc;
                
        //Apex.PageReference='/apex/ViewCaseComments?Id='+ c.Id+ '&ViewAll=true';
        ApexPages.StandardController csc = new ApexPages.StandardController(c);
        PageReference pageRef = Page.ViewCaseComments;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', c.Id);
        ApexPages.currentPage().getParameters().put('ViewAll','true');
        
        String objName='Case_Comments';
        String FieldName='Case';
        ViewCaseCommentsController.getButtonFieldValue(objName,FieldName);
        ViewCaseCommentsController caseComments = new ViewCaseCommentsController(csc);
       
             
        caseComments.Next();
        caseComments.Previous();
        caseComments.getCaseRecords(); 
    }

}