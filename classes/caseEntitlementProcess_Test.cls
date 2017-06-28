/***************************************************************************************
    CLIENT
        Client Name
            
    PURPOSE
        caseEntitlementProcess_Test            
    
    CHANGE LOG
        [[Version; Date; Author; Description]]
        v0.1; 2014/06/02; /Forefront; Initial Build
***************************************************************************************/
@isTest(SeeAllData=true)
public class caseEntitlementProcess_Test {
    
    @isTest static void caseEntitlementProcessTestMethod() {
        Id AccomodationsRecordType = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Accommodations - Order Header').getRecordTypeId();

        //Select a profile
        Profile p=[SELECT Id FROM Profile WHERE Name = 'Contract' LIMIT 1];
        
        //create user
        User u=new User();
        u.FirstName='Test';
        u.LastName='User 1';
        u.ProfileId=p.Id;
        u.Username='TestUser@rhtest.com';
        u.Email='testuser@rhtest.com';
        u.Alias='TestUser';
        u.CommunityNickname='testcomm';
        u.TimeZoneSidKey='America/Los_Angeles';
        u.LocaleSidKey='en_US';
        u.EmailEncodingKey='UTF-8';
        u.LanguageLocaleKey='en_US';
        insert u;

        //RH_User__c ru = new RH_User__c(User__c = u.Id, Name = 'Test RH User');
        //insert u;

        //create cases
        
        Case c1 = new Case();
        c1.RecordTypeId = AccomodationsRecordType;
        c1.Send_to_First_Name__c='Test First Name';
        c1.Send_to_Last_Name__c='Test Last Name';
        c1.Send_to_Day_Phone__c='1112223344';
        c1.Send_to_City__c = 'Santa Cruz';
        c1.Send_to_State__c = 'CA';
        c1.Send_to_Zip__c = '94500';
        c1.Send_to_Country__c = 'USA';
        c1.Original_Requested_Percentage__c=.95;
        insert c1;

        /*
        test.startTest();

        Case testcase = [SELECT Id, CaseNumber, RecordTypeId, Queue_Type__c FROM Case WHERE Id =: c1.Id];
        System.debug('Test Case Insertion' + testcase);
        */

        c1.Request_Category__c = 'Gift Card';
        c1.Accommodation_Reason__c = 'Backorder Delay';
        c1.Original_Requested_Percentage__c= .85;
      //  c1.Actual_Gift_Card_Amount__c=95;
        //c1.Accommodation_Requested_By__c = u.Id;
        //c1.Accommodation_Approved_By__c = u.Id;
        update c1;
        
       // c1.Status = 'Transfer';
        //c1.To__c = 'Accommodations';
        //update c1;
        
        test.startTest();
        
        /*List<CaseMilestone> milestones = [SELECT CaseId, IsCompleted, MilestoneTypeId FROM CaseMilestone WHERE CaseId =: c1.Id];
        c1.Status='In Progress';
        update c1;
        
        c1.Status = 'Callout Team';
        update c1;

        List<CaseMilestone> milestones2 = [SELECT CaseId, IsCompleted, MilestoneTypeId FROM CaseMilestone WHERE CaseId =: c1.Id AND IsCompleted = false];
       
        System.assert(milestones2.size() > 0);*/             

        test.stopTest();
    }
    
}