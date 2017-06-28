Global class ScheduleBatchCloseWorkTimers implements Schedulable {

    // Schedule Class for BatchEmailToAttachment
    global void execute(SchedulableContext SC) {
        BatchCloseWorkTimers bCWT =  new BatchCloseWorkTimers();
		Database.executeBatch(bCWT, 2000);
    }
}