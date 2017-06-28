global class ScheduleDelayNotificationsHold implements Schedulable {
   global void execute(SchedulableContext sc) {
          DelayNotificationsHold batch = new DelayNotificationsHold();
          Database.executeBatch(batch, 50);
   }
}