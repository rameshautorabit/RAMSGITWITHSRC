/*
 *  Methods to test Case_TakeOwnershipCtlExt.cls and related classes/methods
 *
 */

@isTest(SeeAllData=true)
private class testCase_TakeOwnershipCtlExt {
    
    static testMethod void ctoTest1() {
        
        User u = new User();
        u = [select Id from User where IsActive = true and Profile.Name = 'CSC Advocate' limit 1];
        
        // Create a case
        List<Case> cList = new List<Case>();
        cList.add(new Case(
            OwnerId = u.Id,
            Status = 'In Progress',
            Request_Category__c = 'Gift Card',
        //    Queue_Type__c = 'Accommodations',
            Send_to_First_Name__c = 'Bob',
            Send_to_Last_Name__c = 'Jones',
            Send_to_City__c = 'Santa Cruz',
            Send_to_State__c = 'CA',
            Send_to_Zip__c = '94500',
            Send_to_Country__c = 'USA',
            Send_to_Day_Phone__c = '555-555-5555')
        );
        insert cList;
        
        // Test the controller extension
        ApexPages.StandardController std = new ApexPages.StandardController(cList[0]);
        Case_TakeOwnershipCtlExt ctl = new Case_TakeOwnershipCtlExt(std);
        
        PageReference pr = ctl.takeOwnership();
        system.assertNotEquals(null, pr);
        
        cList = [select Id, OwnerId from Case where Id = :cList[0].Id];
        system.assertEquals(UserInfo.getUserId(), cList[0].OwnerId);
    }
}