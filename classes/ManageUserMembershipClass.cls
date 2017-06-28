public without sharing class ManageUserMembershipClass {
	
	/*
	 *	Methods to update group memberships based upon changes to Skill Set and DynamicGroup records.
	 *
	 *	Note - these methods are designed to process either new/changed Skill Set or DynamicGroup
	 *	records but not both in one invocation.  To update, old memberships should first be removed and
	 *	then new/updated memberships should be added back.
	 *
	 */
	/* 
	@future(callout = false)
	public static void addRemoveGroupMembership(Set<Id> removeUserIds, Set<String> groupNames, Set<Id> addIds, Boolean isSkillSet) {
		
		// Always remove user from groups first, then add back to new list of groups
		removeGroupMembership(removeUserIds, groupNames);
		
		addGroupMembership(addIds, isSkillSet);
	}
	*/
	
	/*
	public static void removeGroupMembership(Set<Id> userIds, Set<String> groupNames) {
		
		//system.debug('*****removeGroupMembership userIds.size = ' + userIds.size() + ' groupNames.size = ' + groupNames.size());
		
		if (!userIds.isEmpty() && !groupNames.isEmpty()) {
			try {
				Map<Id, Group> groupMap = new Map<Id, Group>([select Id, Name from Group where Name in :groupNames]);
				delete [select Id from GroupMember where UserorGroupId in :userIds and GroupId in :groupMap.keySet()]; 
			} catch (DmlException e) {
				system.debug('*****removeGroupMembership - exception while removing group memberships, exception = ' + e.getMessage());
			}
		}
	}
	
	public static void addGroupMembership(Set<Id> addIds, Boolean isSkillSet) {
		
		List<Skill_Set__c> ssList = new List<Skill_Set__c>();
		List<DynamicGroup__c> dgList = new List<DynamicGroup__c>();
		Set<String> profiles = new Set<String>();
		Set<String> workflows = new Set<String>();
		Set<String> reqcategories = new Set<String>();
		Set<String> groupNames = new Set<String>();
		List<GroupMember> groupMemberList = new List<GroupMember>();
		Map<String, List<String>> dgMap = new Map<String, List<String>>();
		Map<String, Id> groupMap = new Map<String, Id>();
		List<Group> groupList = new List<Group>();
		
		//system.debug('*****addGroupMembership addIds.size = ' + addIds.size() + ' isSkillSet = ' + isSkillSet);
		
		if (!addIds.isEmpty()) {
			
			// Read in the Skill Set and DynamicGroup records and prepare the lists of Request Categories, Workflows, Profiles, and User Ids
			// to be used to add new group membership records.
			if (isSkillSet) {
				
				ssList = [select Id, Name, Active__c, Request_Category__c, User__c, User__r.Profile.Name, Queue_Type__c 
							from Skill_Set__c where Id in :addIds];
				for (Skill_Set__c ss :ssList) {
					reqcategories.add(ss.Request_Category__c);
					workflows.add(ss.Queue_Type__c);
					profiles.add(ss.User__r.Profile.Name);
				}
				
				//system.debug('*****addGroupMembership ssreqcategories = ' + reqcategories + ' ssworkflows = ' + workflows + ' ssprofiles = ' + profiles);
				
				dgList = [select Id, Name, Department__c, Group_Name__c, Profile__c, Queue_Name__c, Request_Category__c 
							from DynamicGroup__c where Request_Category__c in :reqcategories and Department__c in :workflows and Profile__c in :profiles];
				
			} else {
				
				dgList = [select Id, Name, Department__c, Group_Name__c, Profile__c, Queue_Name__c, Request_Category__c 
							from DynamicGroup__c where Id in :addIds];
				for (DynamicGroup__c dg :dgList) {
					reqcategories.add(dg.Request_Category__c);
					workflows.add(dg.Department__c);
					profiles.add(dg.Profile__c);
				}
				ssList = [select Id, Name, Active__c, Request_Category__c, User__c, User__r.Profile.Name, Queue_Type__c 
							from Skill_Set__c where Request_Category__c in :reqcategories and Queue_Type__c in :workflows and 
							User__r.Profile.Name in :profiles and Active__c = true];
			}
			
			//system.debug('*****addGroupMembership dgList.size = ' + dgList.size() + ' ssList.size = ' + ssList.size());
			
			// Get the groups that need to be updated
			List<String> dgGroups;
			for (DynamicGroup__c dg :dgList) {
				
				//system.debug('*****addGroupMembership dg.Name = ' + dg.Name + ' dg.Group_Name__c = ' + dg.Group_Name__c + ' dg.Queue_Name__c = ' + dg.Queue_Name__c);
				
				dgGroups = new List<String>();
				dgGroups = dg.Group_Name__c.split(';', 0); 
				dgGroups.addAll(dg.Queue_Name__c.split(';', 0));
				groupNames.addAll(dgGroups);
				dgMap.put(dg.Profile__c + ' ' + dg.Department__c + ' ' + dg.Request_Category__c, dgGroups);
			}
			
			// Get the groups that will be updated
			if (!groupNames.isEmpty()) {
				groupList = [select Id, Name from Group where Name in :groupNames];
				for (Group g :groupList) {
					groupMap.put(g.Name, g.Id);
				}
			}
			
			//system.debug('*****addGroupMembership dgMap.size = ' + dgMap.size() + ' groupMap.size = ' + groupMap.size());
			
			// Prepare the list of group member records
			for (Skill_Set__c ss :ssList) {
				if (dgMap.containsKey(ss.User__r.Profile.Name + ' ' + ss.Queue_Type__c + ' ' + ss.Request_Category__c)) {
					for (String s :dgMap.get(ss.User__r.Profile.Name + ' ' + ss.Queue_Type__c + ' ' + ss.Request_Category__c)) {
						GroupMember gm = new GroupMember();
						gm.UserorGroupId = ss.User__c;
						gm.GroupId = groupMap.get(s);
						groupMemberList.add(gm);
					}
				}
			}
			
			//system.debug('*****addGroupMembership groupMemberList.size = ' + groupMemberList.size());
			
			// Add the new group memberships
			if (!groupMemberList.isEmpty()) {
				try {
					insert groupMemberList;
				} catch (DmlException e) {
					system.debug('*****addGroupMembership - exception while inserting group memberships, isSkillSet = ' + isSkillSet + ', exception = ' + e.getMessage());
				}
			}
		}
	}
	*/
}