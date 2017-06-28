global class SSVSyncOrdersService implements Database.Batchable<sObject> {
 
 	private SSVBatchSelectorBuilder batchQueryBuilder;
 	private final Boolean repeating;
 	 	
    global Database.QueryLocator start(Database.BatchableContext jobId) {
    	return this.start();
    }
    
    global Database.QueryLocator start() {    	
    	String query = this.batchQueryBuilder
    					.withProcessStatus(SSVSelector.PROCESSING_ORDER_LINK_READY) // always search for records at order link stage
    					.withOrderByMasterRecordScoreOn(false) // never include order by
    					.withFieldList(SSVSelector.getFields()) // do not include "Source_System_View_CW_Company__r.Duplicate_Set_ID__c"
    					.buildQuery();
    					
		Reporter.log(query);   
        return Database.getQueryLocator(query);
    }

    /**
     *  @description Batch execute method. Required by batchable interface.
     */

    global void execute(Database.BatchableContext jobId, List<sObject> scope) {    	
        try {
            this.linkOrders(scope);
        } catch (Exception e) {
            Reporter.report(e);
        }
    }

    /**
     *  @description Batch finish method.
     */
     
    global void finish(Database.BatchableContext BC) {
    			
        if (this.repeating) {
        	SSVSyncScheduler.scheduleNextJob();
        }
    }
    
    /**
     * Constructor - take the query builder
     */
     
    public SSVSyncOrdersService(SSVBatchSelectorBuilder queryBuilder) {
    	this.batchQueryBuilder = queryBuilder;
    	this.repeating = false;
    }     
    
    public SSVSyncOrdersService(SSVBatchSelectorBuilder queryBuilder, Boolean repeating) {
    	this.batchQueryBuilder = queryBuilder;
    	this.repeating = repeating;
    }
    
    /**
     * do the work (public for unit tests)
     */
     
    public void linkOrders(List<Source_System_View__c> records) {
    
    	// link orders
    	SSVCreator.linkOrdersToCustomers(records);
    	
        // mark records as processed
        List<Source_System_View__c> ssvToUpdate = new List<Source_System_View__c>();
        for (Source_System_View__c ssv : records) {
            // set processed status and timestamp
            ssv.Processing_Status__c = SSVSelector.PROCESSING_STATUS_COMPLETE;
            ssv.Processing_Complete_Time__c = DateTime.now();
            ssvToUpdate.add(ssv);
        }
        
        if (!ssvToUpdate.isEmpty()) {
        	Reporter.log('before update SSV record status update:' + Datetime.now().getTime());        	
        	update ssvToUpdate;
        	Reporter.log('after update SSV record status update:' + Datetime.now().getTime());
        }	
    } 
    
}