/**
 *  SSVSyncScheduler.cls
 *  @description Schedulable class to perform different scheduled syncing tasks
 *               for the source system view object
 *  @author Ernesto Valdes, Traction On Demand
 */
global with sharing class SSVSyncScheduler implements Schedulable {

    public static integer TIME_INTERVAL_MINUTES = 2;
    public static String SSV_SYNC_JOB_NAME = 'Source System View Sync';

    public SSVSyncScheduler() {
        
    }

    global void execute(SchedulableContext sc) {

        // determine if should fire batch job
        SSVSyncService.enqueueBatchSync(true);
    }

    /**
     *  @description Schedules the current class instance to run X minutes from now
     *  @author      Ernesto Valdes, Traction on Demand.
     *  @date        2016-02-01
     *  @return      The scheduled job id
     */
    public static Id scheduleNextJob() {

        // Query currently scheduled job for this class
        List<CronTrigger> myCrons = [
            SELECT Id, CronJobDetail.Name, CronJobDetail.Id, CronJobDetail.JobType, TimesTriggered, NextFireTime, StartTime, EndTime, State 
            FROM CronTrigger
            WHERE CronJobDetail.Name = :SSV_SYNC_JOB_NAME
        ];

        // If the current class is already scheduled
        if(!myCrons.isEmpty()){

            // Abort the current schedule
            system.abortJob(myCrons[0].Id);
        }


        // Set how many minutes in the future to fire next scheduled class
        Integer nextMinutesFire = Datetime.now().addMinutes(TIME_INTERVAL_MINUTES).minute();

        // Create scheduled job cron expression for a job every hour,
        // starting in the next X minutes
        String CRON_EXP = '0 '+nextMinutesFire+' * * * ?';

        // Schedule the next run
        return System.schedule(SSV_SYNC_JOB_NAME, CRON_EXP, new SSVSyncScheduler());
    }
    
    /**
     *  @description Schedules the current class instance to run at the specified time
     *  @author      Ernesto Valdes, Traction on Demand.
     *  @date        2016-02-01
     *  @return      The scheduled job id
     */
    public static Id scheduleJobAt(String cronExp) {

        // Query currently scheduled job for this class
        List<CronTrigger> myCrons = [
            SELECT Id, CronJobDetail.Name, CronJobDetail.Id, CronJobDetail.JobType, TimesTriggered, NextFireTime, StartTime, EndTime, State 
            FROM CronTrigger
            WHERE CronJobDetail.Name = :SSV_SYNC_JOB_NAME
        ];

        // If the current class is already scheduled
        if(!myCrons.isEmpty()){

            // Abort the current schedule
            system.abortJob(myCrons[0].Id);
        }

        String CRON_EXP = cronExp;

        // Schedule the next run
        return System.schedule(SSV_SYNC_JOB_NAME, CRON_EXP, new SSVSyncScheduler());
    }
}