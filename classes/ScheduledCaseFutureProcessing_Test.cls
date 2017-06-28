/* Author SP@ForeFront
 * Purpose To Test scheduled a batch job to set cases whose future processing dates are today or earlier not to future processing
 * Last Modified 8/19/2014
 */
@isTest
(SeeAllData=false)
public class ScheduledCaseFutureProcessing_Test{
    static testMethod void testSchedule(){
        
        Test.startTest();
        	PrepareData.populateCustomSettings();
        	List<Case> cases = new List<Case>();
        for(Integer i=-5;i<5;i++){
        	Case c = new Case();
            c.Future_Processing_Date__c = Date.today().addDays(5);
            c.Future_Processing__c = true;
            c.New_Address__c = 'Adress';
            
            cases.add(c);
        }
        insert cases;
          // Schedule the test job
        
          String jobId = ScheduledCaseFutureProcessing.scheduleJob();
        
          // Get the information from the CronTrigger API object
          CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
             NextFireTime
             FROM CronTrigger WHERE id = :jobId];
        
        
          // Verify the job has not run
          System.assertEquals(0, ct.TimesTriggered);
        
          
          List<Case> out = [SELECT Id, Future_Processing__c, Future_Processing_Date__c FROM Case];
          System.debug('Record number: ' + out.size());
          for(Case c: out){
              System.debug('Future Date: ' + c.Future_Processing_Date__c + ' : ' + c.Future_Processing__c);
          }
          
       Test.stopTest();
        out = [SELECT Id, Future_Processing__c, Future_Processing_Date__c FROM Case WHERE Future_Processing__c = false];
          System.debug('Record number: ' + out.size());
          for(Case c: out){
              System.debug('Future Date Completed: ' + c.Future_Processing_Date__c + ' : ' + c.Future_Processing__c);
          }
    
    }
    
}