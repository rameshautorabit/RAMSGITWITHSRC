global class ScheduleBatchStaleDate implements Schedulable {
   global void execute(SchedulableContext sc) {
          BatchStaleDate batch = new BatchStaleDate(); 
          Database.executeBatch(batch, 20);
   }
}