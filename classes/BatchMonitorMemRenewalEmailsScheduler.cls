//this class runs the batch renewal for each cadence, every cadence has its own batch run
//there are mini jobs within the batch that kick off separate jobs (batch chaining)
                 
global class BatchMonitorMemRenewalEmailsScheduler implements Schedulable {
	global void execute(SchedulableContext sc) { 
		for (Integer index = 0; index < BatchMonitorMembershipRenewalEmails.expirationDateList.size(); index ++ ) {
			system.debug('BatchMonitorMembershipRenewalEmailsScheduler -> execute -> 0 -> ' + index);
			if (index!=5)
			{
				if (index==6) //cadence for termination emails, we only want to run part 3 of the batch which builds emails other parts not necessary
					Database.executeBatch(new BatchMonitorMembershipRenewalEmails(3, index), 200);
				else
					Database.executeBatch(new BatchMonitorMembershipRenewalEmails(0, index), 200);
			}
		}
	}
}