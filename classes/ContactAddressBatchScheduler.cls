global with sharing class ContactAddressBatchScheduler implements Schedulable { 
                
        private ContactAddressBatch batchJob;
        
        global ContactAddressBatchScheduler(ContactAddressBatch job) {
            system.debug('ContactAddressBatchScheduler -> ' + job);
            this.batchJob = job;    
        } 
        
        global void execute(SchedulableContext sc) {
            system.debug('ContactAddressBatchScheduler -> execute -> ' + this.batchJob);
            Database.executeBatch(this.batchJob, this.batchJob.batchSize);
        }               
    }