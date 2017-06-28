/* Author SP@ForeFront
 * Purpose To schedule a batch job to set cases whose future processing dates are today or earlier not to future processing
 * Last Modified 8/19/2014
 */
global class ScheduledCaseFutureProcessing implements Schedulable {
   global void execute(SchedulableContext sc) {
          UpdateCaseFutureProcessing batch = new UpdateCaseFutureProcessing(); 
          Database.executeBatch(batch, 50);
   }
    global static String scheduleJob(){
        return System.schedule('CaseFutureProcessingScheduled',
          '0 0 8 * * ? ', 
             new ScheduledCaseFutureProcessing());
    }
}