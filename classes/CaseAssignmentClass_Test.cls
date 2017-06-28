/**
    *   Class: CaseAssignmentClass
    *   Test Class: CaseAssignmentClass_Test
    *   Commented out portions of code relating Skill Set and updating the case ownership - RC, 05/05/2016
**/


@isTest(SeeAllData=true)
private class CaseAssignmentClass_Test 
{
    testMethod static void myUnitTest() {
        
        User u = new User();
        u.Id = UserInfo.getUserId();
        
        //create skill set
     /*   Skill_Set__c s1=new Skill_Set__c();
        s1.Queue_Type__c='Accommodations';
        s1.Request_Category__c = 'Gift Card';
        s1.User__c=UserInfo.getUserId();
        s1.Active__c=true;
        insert s1;*/
          String strRecordTypeId;
        
         List<RecordType> RecordTypeList = [Select Id From RecordType Where SobjectType = 'Case' and Name='Credit Card Declines'];
        
		if(RecordTypeList.size()>0){
			strRecordTypeId=RecordTypeList[0].Id;
			
		}        
        //create cases
        
        List<Case> cList = new List<Case>();
        cList.add(new Case(
            OwnerId = u.Id,
            //Status='Transfer',
            Request_Category__c = 'Gift Card',
            RecordTypeId=strRecordTypeId,
          //  Queue_Type__c = 'Accommodations',
            Send_to_First_Name__c = 'Bob',
            Send_to_Last_Name__c = 'Jones',
            Send_to_City__c = 'Santa Cruz',
            Send_to_State__c = 'CA',
            Send_to_Zip__c = '94500',
            Send_to_Country__c = 'USA',
            //Flat_Rate_Accommodation_Amount__c = 1,
            //Actual_Gift_Card_Amount__c=100,
            Original_Requested_Percentage__c=.95,
            Send_to_Day_Phone__c = '555-555-5555')
        );
        cList.add(new Case(
            OwnerId = u.Id,
            //Status='Transfer',
            Request_Category__c = 'Gift Card',
            RecordTypeId=strRecordTypeId,
            //Queue_Type__c = 'Accommodations',
            Send_to_First_Name__c = 'Bob',
            Send_to_Last_Name__c = 'Jones',
            Send_to_City__c = 'Santa Cruz',
            Send_to_State__c = 'CA',
            Send_to_Zip__c = '94500',
            Send_to_Country__c = 'USA',
            //Flat_Rate_Accommodation_Amount__c = 1,
            //Actual_Gift_Card_Amount__c=100,
            Original_Requested_Percentage__c=.95,
            Send_to_Day_Phone__c = '555-555-5555')
        );
        insert cList;
        
        for (Case c :cList) {
            //c.Flat_Rate_Accommodation_Amount__c = 1;
            c.Accommodation_Reason__c = 'Because';
            c.Send_to_First_Name__c = 'Bob';
            c.Send_to_Last_Name__c = 'Jones';
            c.Send_to_Day_Phone__c = '555-555-5555';
            /*c.Status = 'Transfer';*/
        }
        update cList;
        
        //When cases are present
        List<Case> lstOfCases=[SELECT Id FROM Case WHERE OwnerId=:u.Id];
        CaseAssignmentClass cac=new CaseAssignmentClass(new ApexPages.StandardSetController(lstOfCases));
        cac.listViewName='My Open Cases';
        cac.cherryPicking();
        cac.findCase();
        
        //No Cases
        lstOfCases.clear();
        CaseAssignmentClass cac2=new CaseAssignmentClass(new ApexPages.StandardSetController(lstOfCases));
        cac2.findCase();
        
     }
}