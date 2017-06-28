trigger UserTrigger on User bulk (after insert,after update,after delete) 
{
  /*  List<Id> lstOfUIds=new List<Id>();
    List<Id> lstOfRHUsersToDelete=new List<Id>(); 
    Map<Id,String> mapOfUsers=new Map<Id,String>();
    
    if(trigger.isInsert && trigger.isAfter)
    {       
        List<RHUserCriteria__c> lstRHUserDeps=RHUserCriteria__c.getAll().values();
        System.debug(lstRHUserDeps);
        Set<String> setOfDeps=new Set<String>();
                
        for(RHUserCriteria__c rhu: lstRHUserDeps)
        {
            setOfDeps.add(rhu.Name);
        }
        for(User u:Trigger.new)
        {
            //Commented by vk@ff on 11/25/2014
            /*Reason: RH will be doing a data import of 600 Active/InActive Users and wants the RH User records to be created for all Users 
            irrespective of Active/InActive status. */
            
            //if(u.IsActive==true && setOfDeps.contains(u.Department))
            
          /*  if(setOfDeps.contains(u.Department))
            {
                lstOfUIds.add(u.Id);
                String uName='';
                if(String.isNotBlank(u.FirstName))
                {
                    uName=u.FirstName+' ';
                }
                if(String.isNotBlank(u.LastName))
                {
                    uName=uName+u.LastName; 
                }
                
                mapOfUsers.put(u.Id,uName);
            }
        }
    }*/
    
    /*if(trigger.isUpdate && trigger.isAfter)
    {
        List<RHUserCriteria__c> lstRHUserDeps=[SELECT Id,Name FROM RHUserCriteria__c];
        Set<String> setOfDeps=new Set<String>();
                
        for(RHUserCriteria__c rhu: lstRHUserDeps)
        {
            setOfDeps.add(rhu.Name);
        }
        
        for(User u:trigger.new)
        {
            User oldUser=trigger.oldMap.get(u.Id);
            
            //Commented by vk@ff on 11/25/2014
            /*Reason: RH will be doing the data import of 600 Users but going live with 20 Users initially. 580 Users will be Inactivated but
            RH User records for Inactived users should still exist in the database as they will be used. The below code will be uncommented post 
            Go-Live of all Users*/
            
            /*if(oldUser.IsActive!=u.IsActive && u.IsActive==false)
            {
                lstOfRHUsersToDelete.add(u.Id);             
            }*/
            
                        
            //Added by vk@ff on 11/25/2014 
            //Check for department change
            
            //If the old department was not part of custom setting values and now changed to a department part of Custom setting values, add RH User record
          /*  if(oldUser.Department!=u.Department && (!setOfDeps.contains(oldUser.Department)) && setOfDeps.contains(u.Department))
            {
                String userName='';
                if(String.isNotBlank(u.FirstName))
                {
                    userName=u.FirstName+' ';
                }
                if(String.isNotBlank(u.LastName))
                {
                    userName=userName+u.LastName; 
                }
                mapOfUsers.put(u.Id,userName);
            }
            
            //If the new department does not belong to the values specified in the custom setting, remove the RH User record
            if(oldUser.Department!=u.Department && setOfDeps.contains(oldUser.Department) && (!setOfDeps.contains(u.Department)))
            {
                lstOfRHUsersToDelete.add(u.Id);
            }
        }
    }*/
    
    /*if(mapOfUsers.size()>0)
    {
        ManageRHUserClass.createRHUsers(mapOfUsers);
    }
    
    if(lstOfRHUsersToDelete.size()>0)
    {
        ManageRHUserClass.removeRHUsers(lstOfRHUsersToDelete);
    }*/
}