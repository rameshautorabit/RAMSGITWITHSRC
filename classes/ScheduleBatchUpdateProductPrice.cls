Global class ScheduleBatchUpdateProductPrice implements Schedulable {

    // Schedule Class for BatchUpdateProductPrice
    global void execute(SchedulableContext SC) {
        launchBatchUpdateProductPrice.launchBatchUpdateProductPrice(false);
    }

}