/***************************************************************************************
    CLIENT
        Restoration Hardware
            
    PURPOSE
        This is the controller for the Timer Page. The Timer Page is a javascript 
        timer that counts the number of seconds elapsed. It has a stop/start button

    TEST CLASS
        TimerControllerTest
         
    ENTRY POINTS
        This is the controller for the Timer page.               
    
    CHANGE LOG
        v0.1; 2014/10/09; Philip Koshy/Forefront; Initial Build
        v0.2; 2014/10/09; Carl Weiss/Forefront; udpate case number logic, validate case found.
        v0.3; 2014/10/20; Carl Weiss/Forefront; update logic to write new  events on change of action, create close entries methods
***************************************************************************************/


public class TimerController
{
       /* public Timer_Entry__c timerEntry {get;set;}
        public String caseNumber {get;set;}
        public String orderNumber {get;set;}
        public Timer_Entry__c loginEntry {get;set;}
        public boolean isLoggedIn {get;set;}
        public String actionOnLoad {get;set;}
        public String oldAction {get;set;}
        public String currentTimerCount {get; set;}
        public Integer currentSeconds {get; set;}
        private Id userId{get;set;}
    
        public TimerController()
        {
            isLoggedIn = false;
            oldAction = '';
            caseNumber = '';
            orderNumber = '';
            loginEntry = new Timer_Entry__c();
            //Check if the user has already created a login record 
            userId = UserInfo.getUserId();
            checkLoggedIn(userId);
            init();
        }
    
        private void init()
        {
            System.debug('*****TimerController init actionOnLoad 1: ' + actionOnLoad);
            // Initialize a new timer entry and specify the current user id
            if(timerEntry == null)
            {
                timerEntry = new Timer_Entry__c();
            }
            
            timerEntry.User__c = userId;//UserInfo.getUserId();
            timerEntry.StartTime__c = System.now();
            
			// If a caseId parameter was passed in the URL, initialize our interal caseId field
            String caseIdString = ApexPages.currentPage().getParameters().get('caseId');
            String source = ApexPages.currentPage().getParameters().get('source');
            if(String.isNotBlank(source)) 
			{
				//Added by vk@ff on 02/19/2015
				
				/*if(source.equals('Closed - Successful') || source.equals('Closed - Unsuccessful') || source.equals('Closed - Invalid') || source.equals('Cancelled'))
				{
					timerEntry.Source__c = 'Case Closed';
				}
				else*/
			/*	{
					timerEntry.Source__c = source;
					system.debug('*****TimerController init - setting Source = ' + source);
				}
			}*/
			
			
          /*  if(String.isNotBlank(caseIdString))
            {
                //Carl Weiss/Forefront 20141009 get the case Number
                System.debug('caseIdString: ' + caseIdString);
                try
                {
                    Id caseid = Id.valueOf(caseIdString);
                    Case c = [Select CaseNumber, RH_Order_Number__c, RH_Order_Number__r.Name from Case where id =:caseid LIMIT 1];
                    if (String.isnotBlank(c.CaseNumber))
                    {
                        caseNumber = c.CaseNumber;
                        //case number is an autonumber if the id exists the case number exists. 
                        timerEntry.Case__c = Id.valueOf(caseIdString);
						timerEntry.Order_Number__c = c.RH_Order_Number__c;
						orderNumber = c.RH_Order_Number__r.Name;
                    }
                }
                catch (Exception ex)
                { System.debug('Failed to lookup CaseId: ' + caseIdString + ' ' + ex.getMessage());}
            }

            actionOnLoad = ApexPages.currentPage().getParameters().get('actionOnLoad');
            System.debug('*****TimerController init actionOnLoad 2: ' + actionOnLoad);
            if(String.isNotEmpty(actionOnLoad))
            {
                timerEntry.Action__c = actionOnLoad;
            }
            
            // Initialize the time displayed on the stop watch
            initClock();
        }
    
        private void reset()
        {
            timerEntry = null;
            caseNumber = '';
            orderNumber = '';
            init();

        }
    
        public PageReference save()
        {  
             
            system.debug('*****TimerController save 1 timerEntry = ' + timerEntry);
            
            timerEntry.EndTime__c = System.now();
            if(String.isNotEmpty(actionOnLoad))
            {
                timerEntry.Action__c = null;
            }
            if (timerEntry.Id !=null)
            {
                if(String.isNotEmpty(actionOnLoad))
                {
                   timerEntry.Action__c = oldAction;
                }
                
                // The Source field may have been set by CaseTrigger.trigger - make sure not to overwrite it
                List<Timer_Entry__c> teList = new List<Timer_Entry__c>();
                teList = [select Id, EndTime__c, Source__c from Timer_Entry__c where Id = :timerEntry.Id];
                if (String.isNotBlank(teList[0].Source__c)) {
                	timerEntry.Source__c = teList[0].Source__c;
                }
                
                // The timer may have already been stopped by a nightly batch job, don't stop it twice
                if (teList[0].EndTime__c == null) {
					system.debug('*****TimerController save about to update timerEntry = ' + timerEntry);
					update timerEntry;
                }
            }
            else
            {
                insert timerEntry;
                oldAction = timerEntry.Action__c;
                System.debug('*****TimerController save oldAction: ' + oldAction);
            }
            // Reset the current timer entry so that if save() is called again,
            // we will initialize a *new* TimerEntry__c
            System.debug('*****TimerController save actionOnLoad: ' + actionOnLoad);
            if(String.isNotEmpty(actionOnLoad))
            {
                
                PageReference pageRef = new PageReference('/apex/Timer?autoStart=1&actionOnLoad=' + actionOnLoad); 
                pageRef.setRedirect(true);
                reset();
                return pageRef;
            }
            else
            {
                reset();
                return null;
            }
        }

        public void onPageLoad()
        {
            //insert the record and mark the start time if save on load = true
            String saveOnLoad = ApexPages.currentPage().getParameters().get('saveOnLoad');
            
            system.debug('*****TimerController onPageLoad saveOnLoad = ' + saveOnLoad);
            
            if(saveOnLoad != null && Boolean.valueOf(saveOnLoad)) 
            {
             InsertStartTime();
            }
        }
        
        public void InsertStartTime()
        {
            // InsertStartTime is only called when we are just starting a brand new non-login timer.
            // Set the start time and insert the Timer Entry record.
            
            System.debug('*****TimerController InsertStartTime isLoggedIn: ' + isLoggedIn + ' timerEntry: ' + timerEntry);
            
            //Close any open timers if we are dealing with a new timer
            closeOpenTimers(timerEntry.Id, null);
            if(timerEntry.Id == null)
            {
                timerEntry.StartTime__c = system.now();
                insert timerEntry;
                oldAction = timerEntry.Action__c;
				System.debug('oldAction: ' + oldAction);
            }
        }

        public void login()
        {
            System.debug('*****TimerController login isLoggedIn: ' + isLoggedIn + ' LoginEntryId: ' +loginEntry.Id  + ' UserId: ' + userId);
            if (!isLoggedIn)
            {
                // First close all timers that are currently running
                closeOpenTimers(null, 'Login');
                
                // Start a login timer and a idle timer
                loginEntry.Id = null;
                loginEntry.User__c = userId;
                loginEntry.StartTime__c = System.now();
                loginEntry.EndTime__c = null;
                loginEntry.Action__c = 'Work Session';
                loginEntry.Source__c = 'Work Session';
                insert loginEntry;
                
                timerEntry.Action__c = 'Idle';
            }
			
			System.debug('*****TimerController login loginEntry = ' + loginEntry);
            checkLoggedIn(userId);
        }

        private void checkLoggedIn(Id userId)
        {
            //check for existing login records
            /*
            List<Timer_Entry__c> loginEntries = [SELECT Id, StartTime__c, Source__c FROM Timer_Entry__c WHERE 
                User__c =: userId AND Source__c ='LoginEvent' 
                AND EndTime__c = null AND StartTime__c = Today ORDER BY CreatedDate DESC LIMIT 1];
            */
		/*	List<Timer_Entry__c> loginEntries = [SELECT Id, StartTime__c, Source__c FROM Timer_Entry__c 
					WHERE User__c =: userId AND Source__c ='Work Session' AND EndTime__c = null ORDER BY CreatedDate DESC LIMIT 1];

            if (!loginEntries.isEmpty())
                {
                    loginEntry = loginEntries[0]; 
                    isLoggedIn = true;
                }
                else {isLoggedIn = false;loginEntry.EndTime__c = null;loginEntry.Id = null;}
            System.debug('*****TimerController checkedLoggedIn loginEntry: ' + loginEntry);
            System.debug('*****TimerController checkedLoggedIn isLoggedIn: ' + isLoggedIn + ' LoginEntryId: ' +loginEntry.Id  + ' UserId: ' + userId);
        }*/

       /* public PageReference logOut()
        {    
            String sourceFilter = 'Work Session';
            //Id userId = UserInfo.getUserId();
            try 
            {
				// First close all running timers
				closeOpenTimers(null, 'Logout');
				/*
            //Integer timerCount = Database.countQuery('SELECT Count() FROM Timer_Entry__c WHERE User__c =: userId AND Source__c !=:sourceFilter AND EndTime__c = null AND Duration__c = null AND CreatedDate = Today');
            List<Timer_Entry__c> teList = [SELECT Id, EndTime__c FROM Timer_Entry__c WHERE User__c =: UserInfo.getUserId() AND Source__c !=:sourceFilter AND EndTime__c = null AND Duration__c = null AND CreatedDate = Today];
                if(teList.size() > 0 )
                {
                for (Timer_entry__c te : teList)
                {
                    te.EndTime__c = system.Now();
                   }
                   // ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot Log out: you have '+timerCount+' open timer entry, please complete all timers.');
                   // ApexPages.addMessage(msg);
                   // return null;
                update teList;
                }
                
                //update the existing login record with the end time
                loginEntry.EndTime__c = System.now();
                //try and update if failure return page message
                if(loginEntry.Id !=null)
                {
                    update loginEntry;
                }
                */
          /*      checkLoggedIn(userId);
                //initClock();
                PageReference pageRef = new PageReference('/apex/Timer?autoStart=1'); 
                pageRef.setRedirect(true);
                reset();
                return pageRef;
            }
            catch (Exception ex)
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
                ApexPages.addMessage(msg);
            }
            return null;
                
        } */

      /*  private void closeOpenTimers(String currentTimerId, String operation)
        {
            //find any open times and "close" them except for the time we are workign with 
            try
            {
                System.debug('*****closeOpenTimers currentTimerId: ' + currentTimerId);
                List<Timer_Entry__c> openTimers = null;
                String queryString = 'SELECT Id, Name, Duration__c, EndTime__c, Memo__c, Source__c FROM Timer_Entry__c WHERE User__c = :userId AND EndTime__c = null AND Duration__c = null';
                if (operation == null) {
                	queryString += ' AND Source__c != \'Work Session\'';
                }
                if (String.isNotEmpty(currentTimerId)) {
                	queryString += ' AND Id != :currentTimerId';
                }
                system.debug('*****closeOpenTimers queryString = ' + queryString);
                
                openTimers = Database.Query(queryString);
                
                /*
                if (String.isNotEmpty(currentTimerId))
                {    
                    //openTimers = [SELECT id, Name FROM Timer_Entry__c WHERE User__c =: userId AND Source__c !='LoginEvent' AND EndTime__c = null AND Duration__c = null AND CreatedDate = Today AND id !=:currentTimerId];
                    openTimers = [SELECT id, Name FROM Timer_Entry__c WHERE User__c =: userId AND Source__c !='LoginEvent' AND EndTime__c = null AND Duration__c = null AND id !=:currentTimerId];
                }
                else
                {
                    //openTimers = [SELECT id, Name FROM Timer_Entry__c WHERE User__c =: userId AND Source__c !='LoginEvent' AND EndTime__c = null AND Duration__c = null AND CreatedDate = Today ];
                    openTimers = [SELECT id, Name FROM Timer_Entry__c WHERE User__c =: userId AND Source__c !='LoginEvent' AND EndTime__c = null AND Duration__c = null];
                }
                */
                
            /*    system.debug('*****closeOpenTimers operation = ' + operation + ' openTimers = ' + openTimers);
                
                //close the open timers 
                for (Timer_Entry__c t : openTimers)
                {
                    t.EndTime__c = System.now();
                    //append a note to the memo field
                    String opString;
                    if (operation != null) {
                    	opString = ' at ' + operation + '.';
                    } else {
                    	opString = '.';
                    }
                    
                    if (String.isNotBlank(t.Memo__c))
                    {
                        t.Memo__c += 'Timer automatically closed by System' + opString;
                    }
                    else
                    {
                        t.Memo__c = 'Timer automatically closed by System' + opString;
                    }
                }
                System.debug('*****closeOpenTimers openTimers: ' + openTimers);
                update openTimers;
            }
            catch (exception ex)
            { 
                System.Debug('*****closeOpenTimers Failed Close Open Timers' + ex.getMessage());
            }
        }
        
	private void initClock() {
		
		// Find the running timer record if there is one
		Timer_Entry__c te = new Timer_Entry__c();
		try {
			te = [select Id, StartTime__c, EndTime__c, Duration__c, Source__c, User__c, Case__c, Case__r.CaseNumber, Order_Number__c, Order_Number__r.Name, Action__c from Timer_Entry__c 
					where EndTime__c = null and Duration__c = null and User__c = :userId and Source__c != 'Work Session' limit 1];
		} catch(Exception e) {
			system.debug('*****TimerController initClock exception reading Timer Entry = ' + e.getMessage());
		}
		
		// Initialize the clock appropriately if there is a timer running.
		// If there is a running timer record and we are not trying to start a new timer,
		// set the clock to the time it has been running and start the clock ticking, otherwise set the clock time to zero.
		if (te.Id == null || (String.isNotBlank(caseNumber) && caseNumber != te.Case__r.CaseNumber)) {
			
			// No timer running, set the clock to zero
			currentSeconds = 0;
			currentTimerCount = '00:00:00';
			
		} else {
			
			// Timer running, set the clock time and the other fields on the timer window and for the in-memory copy
			DateTime now;
			now = system.now();
			currentSeconds = Integer.valueOf(now.getTime() - te.StartTime__c.getTime()) / 1000;
			timerEntry.Id = te.Id;
			timerEntry.StartTime__c = te.StartTime__c;
			timerEntry.Source__c = te.Source__c;
			timerEntry.Case__c = te.Case__c;
			timerEntry.Order_Number__c = te.Order_Number__c;
			timerEntry.Action__c = te.Action__c;
			oldAction = te.Action__c;
			caseNumber = te.Case__r.CaseNumber;
			orderNumber = te.Order_Number__r.Name;
			
			system.debug('*****TimerController initClock now = ' + now + ' StartTime__c = ' + te.StartTime__c + ' currentSeconds = ' + currentSeconds);
		}
	}*/
}