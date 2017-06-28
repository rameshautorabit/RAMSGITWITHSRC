global class BatchExpireMembershipsScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		Database.executeBatch(new BatchExpireMemberships(), 50);
	}    
}