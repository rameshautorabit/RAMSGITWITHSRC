@isTest
private class IssueServiceTest {

    static testMethod void createIssueAndShare() {	
	 
	    // Create vendors public group
	    Group vendorGroup = new Group(Name = 'Vendor Partner Users');
	    insert vendorGroup;
	    
	    // Create test Account and insert
	    Account testAccount = new Account(Name='Partner Account');
		testAccount.Vendor_Number__c = '1234';
		insert testAccount;
		
		testAccount.isPartner = true;
		update testAccount;
		
		// Create test Product and insert
		PrepareData.productClass testProductClass = PrepareData.createProduct('59030274COCO', 25.00, 'testProd', 25.00);
		
		System.debug('Product: ' + testProductClass.p);
		
		Product2 testProduct = testProductClass.p;
		
		testProduct.Vendor_Number__c = '1234'; 
		update testProduct;
		
		// Create test Issue and insert
		Issue__c testIssue = new Issue__c(
										CW_SKU_ID__c = testProduct.Id, 
										What_Product_Type_is_the_SKU__c = 'Bath Water Supply', 
										Where_is_the_Problem__c = 'Faucet', 
										Issue_Type__c = 'Contamination', 
										Other_Notes__c = 'tesht');
		insert testIssue;
		
		testIssue = [Select Vendor_Number__c from Issue__c where Id = :testIssue.Id];
		
		testAccount = [Select Id, Name, PublicGroupId__c, isPartner from Account where Id= :testAccount.Id];
		Group testGroup = [Select Name from Group where Id = :testAccount.PublicGroupId__c];
		List<Issue__Share> issueShare = [SELECT ParentId from Issue__Share where UserOrGroupId = :testAccount.PublicGroupId__c limit 1];
				
		
		System.assertEquals('VEND-' + testAccount.Name + '-' + testAccount.Id, testGroup.name);
		System.assertEquals(testAccount.isPartner, true);
		System.assertEquals(testIssue.Id, issueShare[0].ParentId);
    }
}