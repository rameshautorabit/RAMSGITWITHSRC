/***************************************************************************************
    CLIENT
        Restoration Hardware
            
    PURPOSE
        CreateCoachingCaseClass_TEST            
    
    CHANGE LOG
        [[Version; Date; Author; Description]]
        v0.1; 2014/10/03; Chris Del Fattore/Forefront; Initial Build
***************************************************************************************/
@isTest
private class CreateCoachingCaseClass_TEST {
	
	@isTest static void test_method_one() {
		PrepareData.populateCustomSettings();
		Case parCase = new Case();
		parCase.Sold_To_Name__c = 'FirstLastName';
		insert parCase;

		PageReference pageRef = Page.CreateCoachingCasePage;
		ApexPages.currentPage().getParameters().put('id',parCase.Id);
		CreateCoachingCaseClass caseClass = new CreateCoachingCaseClass();
		caseClass.createCoachingCase();
	}
}