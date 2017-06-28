/***************************************************************************************
    CLIENT
        Restoration Hardware
            
    PURPOSE
        Test class for TimerController        
    
    CHANGE LOG
        v0.1; 2014/10/09; Philip Koshy/Forefront; Initial Build
        v0.2; 2014/10/20; Justin Wagner/ForeFront; 94% Code Coverage Test
***************************************************************************************/


@isTest
public class TimerControllerTest
{
   /* @isTest
    static void testTimerController()
    { 
        // Insert a case for our test to use
        Case myCase = new Case();
        insert myCase;
        
        // Create a page reference to the Timer page and set the caseId parameter and saveOnLoad parameter
        PageReference pageReference = new PageReference('/apex/Timer');
        Test.setCurrentPage(pageReference);
        ApexPages.currentPage().getParameters().put('caseId', myCase.Id);
        ApexPages.currentPage().getParameters().put('actionOnLoad', 'Lunch');
        
        // Instantiate a new timer controller and specify a few default values for the 
        // underlying timerEntry. Note we do *not* explicitly initialize the Case__c 
        // field for the timerEntry; this should be done within the controller when
        // the controller's save() method is called.
		TimerController timerController = new TimerController();

        Timer_Entry__c myTimeEntry = new Timer_Entry__c();
        myTimeEntry.Source__c = 'Lunch';
        myTimeEntry.Case__c = myCase.Id;
        myTimeEntry.User__c = UserInfo.getUserId();
        myTimeEntry.StartTime__c = system.now();

        insert myTimeEntry;

        //test login
        timerController.login();
        
        // Calling the save method should insert the timer entry record
        timerController.save();
        
        Timer_Entry__c timerEntry = [SELECT Duration__c, Case__c
							 		 FROM Timer_Entry__c
                                     LIMIT 1];

        // Make sure the timer entry we've retrieved has the case id saved
        System.assertEquals(timerEntry.Case__c, myCase.Id);

        //test saveOnLoad param
        PageReference pageReference2 = new PageReference('/apex/Timer');
        Test.setCurrentPage(pageReference2);
        ApexPages.currentPage().getParameters().put('caseId', myCase.Id);
        ApexPages.currentPage().getParameters().put('saveOnLoad', 'true');

        //new timer to test onPageLoad
        TimerController timerController2 = new TimerController();

        Case myCase2 = new Case();
        insert myCase2;

        Timer_Entry__c myTimeEntry2 = new Timer_Entry__c();
        myTimeEntry2.Memo__c = 'Test Memo DEBUG2';
        myTimeEntry2.Source__c = 'Lunch';
        myTimeEntry2.Case__c = myCase2.Id;
        myTimeEntry2.User__c = UserInfo.getUserId();
        myTimeEntry2.StartTime__c = system.now();

        insert myTimeEntry2;

        timerController2.login();
        timerController2.onPageLoad();
        timerController2.save();
        timerController2.logout();

        Timer_Entry__c timerEntry2 = [SELECT Duration__c, Case__c
                                     FROM Timer_Entry__c
                                     LIMIT 1];

        System.assertEquals(timerEntry2.Case__c, myCase.Id);
 
        //new timer to test logout without login
        TimerController timerController4 = new TimerController();
        timerController4.timerEntry.Action__c ='Lunch';
        timerController4.timerEntry.Source__c ='Lunch';
        timerController4.timerEntry.User__c = UserInfo.getUserId();

        timerController4.logout();

    }*/
}