@isTest
private class ManageUserMembershipClass_Test {
	/*static testMethod void myUnitTest() 
	{
		Profile p=[SELECT Id, Name FROM Profile WHERE Name='CSC Backend Associate'];
		
		//Create User 
		User u = new User(alias = 'testuser', 
      					email='standarduser@test.com', 
            			emailencodingkey='UTF-8', 
            			lastname='Testing', 
            			languagelocalekey='en_US', 
            			localesidkey='en_US', 
            			profileid = p.Id, 
            			timezonesidkey='America/Los_Angeles', 
            			username='standarduserFF@testorg.com'
            			);
        insert u;
		
		
		//Create Skill Sets
		List<Skill_Set__c> lstOfSkillSets=new List<Skill_Set__c>();
		
		Skill_Set__c s1=new Skill_Set__c();
		s1.Active__c=true;
		s1.Active_Date__c=Date.today();
		s1.Queue_Type__c='Accommodations';
		s1.Request_Category__c='Cash Accommodation';
		s1.User__c=u.Id;
		insert s1;
		
		Skill_Set__c s2=new Skill_Set__c();
		s2.Active__c=false;
		s2.Active_Date__c=Date.today();
		s2.Queue_Type__c='Order Inquiries';
		s2.Request_Category__c='Gift Card';
		s2.User__c=u.Id;
		insert s2;
		
		
		//Activate the skill set
		s2.Active__c=true;
		update s2;
		
		//Change Queue Type
		s2.Queue_Type__c='Order Inquiries';
		s2.Request_Category__c='All';
		update s2;
		
		DynamicGroup__c d1=new DynamicGroup__c();
		d1.Profile__c='CSC Backend Associate';
		d1.Department__c='Accommodations';
		d1.Request_Category__c='Cash Accommodation';
		d1.Queue_Name__c='Accommodations Queue';
		d1.Group_Name__c='Accommodations';
		insert d1;
		
		DynamicGroup__c d2=new DynamicGroup__c();
		d2.Profile__c='CSC Frontline Associate';
		d2.Department__c='Order Inquiries';
		d2.Request_Category__c='All';
		d2.Queue_Name__c='DC';
		d2.Group_Name__c='Order Inquiries - All';
		insert d2;
		
		
		
	} */
}