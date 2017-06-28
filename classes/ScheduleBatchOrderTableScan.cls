global class ScheduleBatchOrderTableScan implements Schedulable {
   global void execute(SchedulableContext sc) {
		BatchOrderTableScan batch = new BatchOrderTableScan(); 
		Database.executeBatch(batch, 2000); 
   }
}