/***************************************************************************************
    CLIENT
        Restoration Hardware
            
    PURPOSE
        CaseTimerEntries_TEST            
    
    CHANGE LOG
        [[Version; Date; Author; Description]]
        v0.1; 2014/11/03; CarlWeiss/Forefront; Initial Build
***************************************************************************************/
@isTest
private class CaseTimerEntries_TEST {
    
  /*  @isTest static void test_method_one() 
    {

//-------------------------------------------------------------------
        //Create cases
        List<Case> c = new List<Case>(); 
        Case c1 = new Case();
        c1.In_Progress_Team__c = 'Accommodations';
        c1.Queue_Type__c ='Accommodations';
        c.add(c1);

        Case c2 = new Case();
        c2.In_Progress_Team__c = 'Order Processing';
        c2.Queue_Type__c ='Order Processing';
        c.add(c2);

        //insert our cases
        insert c;

//-------------------------------------------------------------------
        //Create timer entries 
        List<Timer_Entry__c> testTimerList = new List<Timer_Entry__c>();
        Timer_Entry__c t1 = new Timer_Entry__c();
        t1.Case__c = c1.id;
        t1.User__c = UserInfo.getUserId();
        t1.Source__c = 'Test Class';
        t1.StartTime__c = System.now();
        testTimerList.add(t1);

        Timer_Entry__c t2 = new Timer_Entry__c();
        t2.Case__c = c2.id;
        t2.User__c = UserInfo.getUserId();
        t2.Source__c = 'Test Class';
        t2.StartTime__c = System.now();
        testTimerList.add(t2);

        insert testTimerList;
        System.debug('*****CaseTimerEntries_TEST Timers: ' + testTimerList);
//-------------------------------------------------------------------
        Map<id, Case> caseMap = new Map<Id,Case>();
        caseMap.putAll(c);

//-------------------------------------------------------------------
        Test.startTest();


        //update values and update records 
        c1.Queue_Type__c = 'Accommodations';
        c2.Queue_Type__c = 'Credit Card Declines';
        update c;
        
        Test.stopTest();
 //-------------------------------------------------------------------
        //look for the newly created records
        List<Timer_Entry__c> CaseTimers = new List<Timer_Entry__c>();
        CaseTimers = [select Id, Case__c, Source__c, CreatedById FROM Timer_Entry__c WHERE Case__c in :caseMap.keySet()];
        system.debug('*****CaseTimerEntries_TEST CaseTimers.size = ' + CaseTimers.size() + 'user Id = ' + UserInfo.getUserId());
        for (Timer_Entry__c te :CaseTimers) {
            system.debug('*****CaseTimerEntries_TEST Source = ' + te.Source__c + ' CreatedById = ' + te.CreatedById);
        }
        
        
        List<Timer_Entry__c> relatedCaseTimers = new List<Timer_Entry__c>();
    
        for (Id cId :caseMap.keyset())
        {
            //use the current user as the filter as the map will not contain the user field unless required
            List<Timer_Entry__c> te = [SELECT Id, Case__c FROM Timer_Entry__c WHERE Case__c = :cId AND CreatedById =: UserInfo.getUserId() AND Source__c = 'Transfer Back'];
            for (Timer_Entry__c t : te)
            {
                relatedCaseTimers.add(t);
            }
        } 
        System.debug('*****CaseTimerEntries_TEST Timer Entries: ' + relatedCaseTimers.size());
        //verify the 2 timer record was created.
        //System.assert(relatedCaseTimers.size() == 2);
        //System.debug('*****CaseTimerEntries_TEST c1id ' + String.valueOf(c1.id).left(15) + '  case id ' + relatedCaseTimers[0].Case__c);
        //System.assertEquals(relatedCaseTimers[0].Case__c, c1.id);
    }*/
    

    
}