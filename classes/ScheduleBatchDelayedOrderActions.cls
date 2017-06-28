global class ScheduleBatchDelayedOrderActions implements Schedulable {
   global void execute(SchedulableContext sc) {
          BatchDelayedOrderActions batch = new BatchDelayedOrderActions(); 
          Database.executeBatch(batch, 20);
   }
}