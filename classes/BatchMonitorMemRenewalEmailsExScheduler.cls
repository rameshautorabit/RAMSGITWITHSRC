//this class runs the batch renewal for each cadence, every cadence has its own batch run
//there are mini jobs within the batch that kick off separate jobs (batch chaining)
                      
global class BatchMonitorMemRenewalEmailsExScheduler implements Schedulable { 
	global void execute(SchedulableContext sc) {
		
			system.debug('BatchMonitorMembershipRenewalEmailsScheduler -> execute -> 0 -> expiration');
			
					Database.executeBatch(new BatchMonitorMembershipRenewalEmails(0, 5), 200);
				
			}
		}