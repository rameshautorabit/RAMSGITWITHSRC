/***********************************************************

    * Name: ManageRHUserClass
    * Description: Class to add and delete RH User records
    * Entry points: UserTrigger
    * Test Class: ManageRHUserClass_Test
    * Author: vk@ff 
    * Change log:
        ~ V0.0 Initial Creation 
          V1.0 Added methods createRHUsers and removeRHUsers
          
************************************************************/

public without sharing class ManageRHUserClass
{
    //Method to create RH User Records
   /* @future
    public static void createRHUsers(Map<Id,String> mapOfUsers)
    {
        List<RH_User__c> RHUsersToInsert=new List<RH_User__c>();
        
        for(Id uId:mapOfUsers.keySet())
        {
            RH_User__c rhu=new RH_User__c();
            rhu.User__c=uId;
            if(mapOfUsers.get(uId)!=null)
            {
                rhu.Name=mapOfUsers.get(uId);
            }
            RHUsersToInsert.add(rhu);
        }
        
        try
        {
            insert RHUsersToInsert; 
            System.debug('CREATED RH USERS' + RHUsersToInsert);
        }
        catch(DmlException e)
        {
            System.debug(e.getMessage());   
        }
    }
    
    //Method to delete the RH User records when the user is inActive
    @future
    public static void removeRHUsers(List<Id> lstOfUIds)
    {
        List<RH_User__c> RHUsersToDelete=new List<RH_User__c>();
        
        try
        {
            RHUsersToDelete=[SELECT Id FROM RH_User__c WHERE User__c IN:lstOfUIds];
            System.debug('RH USERS TO delete' + RHUsersToDelete);
            if(!RHUsersToDelete.isEmpty())
            {
                delete RHUsersToDelete;
            }
        }
        catch(DmlException e)
        {
            System.debug(e.getDMLMessage(0));   
        }
    }*/
}