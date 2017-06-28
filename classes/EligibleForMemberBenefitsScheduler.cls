global class EligibleForMemberBenefitsScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchMonitorMemberships batchEligibleForMemberBenefitsUpdate = new BatchMonitorMemberships();
        batchEligibleForMemberBenefitsUpdate.dmlOnly = true;
        database.executeBatch(batchEligibleForMemberBenefitsUpdate, 10);             
        batchEligibleForMemberBenefitsUpdate.dmlOnly = false;
        database.executeBatch(batchEligibleForMemberBenefitsUpdate, 10);    
    }
}