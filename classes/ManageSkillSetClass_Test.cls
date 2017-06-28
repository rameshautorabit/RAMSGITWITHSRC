@isTest
private class ManageSkillSetClass_Test 
{
	/*static testMethod void testManageSkillSetClass() 
	{
		//Create Skill Sets
		List<Skill_Set__c> lstOfSkillSets=new List<Skill_Set__c>();
		
		Skill_Set__c s1=new Skill_Set__c();
		s1.Active__c=true;
		s1.Active_Date__c=Date.today();
		s1.Queue_Type__c='Accommodations';
		s1.Request_Category__c='Cash Accommodation';
		s1.User__c=UserInfo.getUserId();
		lstOfSkillSets.add(s1);
		
		Skill_Set__c s2=new Skill_Set__c();
		s2.Active__c=true;
		s2.Active_Date__c=Date.today();
		s2.Queue_Type__c='Order Inquiries';
		s2.Request_Category__c='Gift Card';
		s2.User__c=UserInfo.getUserId();
		lstOfSkillSets.add(s2);
		
		insert lstOfSkillSets;
		
		PageReference p=Page.ManageSkillSetPage;
		p.setRedirect(true);
		
		ManageSkillSetClass ms=new ManageSkillSetClass();
		
		//Get Skill Set
		ms.isActive='true';
		ms.User=UserInfo.getUserId();
        ms.profile=UserInfo.getProfileId();
		ms.filterSkillSet();
		ms.next();
		ms.previous();
		ms.last();
		ms.first();
		
		//Add New Skill Set
		Skill_Set__c sNew=new Skill_Set__c();
		sNew.Active__c=true;
		sNew.Queue_Type__c='Accommodations';
		sNew.Request_Category__c='Cash Accommodation';
		sNew.User__c=UserInfo.getUserId();
		
		ms.displayNewSkillSet=true;
		ms.newSkillSet=sNew;
        ms.displayNewSkillSet=true;
		ms.addNewSkillSet();	//Test Add
		ms.cancelNewSkillSet();	//Test Cancel
		
        List<Skill_Set__c> skillSetList=ms.getskillSetList();
		for(Skill_Set__c ss:skillSetList)
		{
			ss.Queue_Type__c='Accommodations';
			ss.Request_Category__c='All';		
		}
		ms.updateSkillSetList();	//Update
		
		//Test Clone
		//if(ms.skillSetList.size()>0)
		{
			//ms.cloneskillSetId=ms.skillSetList[0].Id;
			ms.cloneskillSetId=s1.Id;
			ms.cloneSkillSet();
            for(Skill_Set__c ss:skillSetList)
			{
                ss.isDelete__c=true;
            }
            ms.deleteSkillSet();
		}
	} */
}