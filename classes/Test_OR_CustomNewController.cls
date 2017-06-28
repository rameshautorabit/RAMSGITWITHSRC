/**
 * Description: This class contains unit tests for validating the behavior of Operations_Request_CustomNewController apex class
 * Author: Eashan Parlewar
 * Created Date : 21-04-2017
*/
@isTest
private class Test_OR_CustomNewController 
{
	    static testMethod void Test_RedirectOnclick() 
	    {
	        PrepareData.populateCustomSettings();
	        
	        PrepareData.productClass ProductWithProPrice_1 = PrepareData.createProduct('63420784BRN', 100, '63420784BRN', 100); 
	        
	        ApexPages.StandardController OR_Contllr = new ApexPages.standardController(ProductWithProPrice_1.p);
            Operations_Request_CustomNewController OR_Contllr_Obj=new Operations_Request_CustomNewController(OR_Contllr);
            
            test.starttest(); 
            System.assertNotEquals(null,OR_Contllr_Obj.RedirectUrl());
            test.stoptest();
	    }
}