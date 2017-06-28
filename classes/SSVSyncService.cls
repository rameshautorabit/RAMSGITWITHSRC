/**
 *  Queueable service class to handle integration of Source_System_View__c object. 
 *  This class is queued by the object's trigger, and runs after Duplicate rules have
 *  determined whether the given records are duplicates. Duplicate and non-duplicate
 *  records are synced to their respective objects in different ways.
 *  @author Ernesto Valdes, Traction On Demand
 */
global class SSVSyncService implements Database.Batchable<sObject> {
    
    public static final String PROCESSING_STATUS_READY = SSVSelector.PROCESSING_STATUS_READY;
    public static final String BATCH_JOB_NAME = 'SSVSyncService';

    private final Boolean repeating;
    private Integer bulkBatchSize;
    private SSVBatchSelectorBuilder batchQueryBuilder;

    /**
     *  Query string used by batch/asynch job
     */ 
    global String query;

    /**
     *  The given records to be synced
     */
    @testVisible List<Source_System_View__c> records {
        get {
            if (records == null) {
                records = new List<Source_System_View__c>();
            }
            return records;
        }
        set;
    }

    /**
     *  The records identified as belonging to a duplicate set
     */
    List<Source_System_View__c> duplicateRecords {
        get {
            if (duplicateRecords == null) 
                duplicateRecords = new List<Source_System_View__c>();
            return duplicateRecords;
        }
        set;
    }

    /**
     *  The records identified as NOT belonging to a duplicate set
     */
    List<Source_System_View__c> nonDuplicateRecords {
        get {
            if (nonDuplicateRecords == null) 
                nonDuplicateRecords = new List<Source_System_View__c>();
            return nonDuplicateRecords;
        }
        set;
    }

    /**
     *  @description Constructor, takes in a query for batch as argument
     *  @author      Ernesto Valdes, Traction on Demand.
     *  @date        2015-11-03
     */
     
    public SSVSyncService(String selectionQuery, Boolean repeating) {
    	this.query = selectionQuery;
        this.repeating = repeating;
    }     
     
    public SSVSyncService(SSVBatchSelectorBuilder queryBuilder, Boolean repeating) {
    	this.batchQueryBuilder = queryBuilder;
        this.query = queryBuilder.buildQuery();
        this.repeating = repeating;
    }
    
    public SSVSyncService(SSVBatchSelectorBuilder queryBuilder, Boolean repeating, Integer batchSize) {
    	Reporter.log('Instantiate new SSVSyncService with queryBuilder, repeating and batch size');        
    	this.batchQueryBuilder = queryBuilder;
        this.query = queryBuilder.buildQuery();
        this.repeating = repeating;
        this.bulkBatchSize = batchSize;
    }        

    /**
     *  @description Constructor, takes in records in scope as arguments
     *  @author      Ernesto Valdes, Traction on Demand.
     *  @date        2015-11-03
     */
          
    public SSVSyncService(List<Source_System_View__c> records) {
        this.records = records;        
        repeating = false;
    }
    
    /**
     * Various helper methods that call the enqueBatchSync method. Used mainly in unit tests
     */

    public Static Id enqueueBatchSync(Boolean repeating) {
        return enqueueBatchSync(repeating, null, Datetime.now().addMinutes(-SSVSyncScheduler.TIME_INTERVAL_MINUTES));
    }

    public Static Id enqueueBatchSync(Boolean repeating, Integer batchLimit) {
        return enqueueBatchSync(repeating, batchLimit, Datetime.now().addMinutes(-SSVSyncScheduler.TIME_INTERVAL_MINUTES));
    }
    
    public Static Id enqueueBatchSync(Boolean repeating, Datetime processingReadyTime) {

        return enqueueBatchSync(repeating, null, processingReadyTime);
    }    

    /**
     * @description Schedules current class to run as a batch job  
     */
     
	public Static Id enqueueBatchSync(Boolean repeating, Integer batchLimit, Datetime processingReadyTime) {
		
		SSVBatchSelectorBuilder builder = new SSVBatchSelectorBuilder()
											.withBatchLimit(batchLimit)
											.withProcessingReadyTime(processingReadyTime)
											.withOrderByMasterRecordScoreOn(true)
											.withProcessStatus(SSVSelector.PROCESSING_STATUS_READY);											
				
		Reporter.log('Query:: ' + builder.buildQuery());		
		return Database.executeBatch(new SSVSyncService(builder, repeating));
	}
	
    /**
     *  @description Schedules current class with increased filters - just for bulk load
     *  @return      The scheduled job id
     */
     
    public Static Id enqueueBatchSync(Boolean repeating, Integer batchLimit, Datetime processingReadyTime, Boolean includeDuplicates, String customFilter, Integer bulkBatchSize) {
    	
    	Reporter.log('Build bulk-load selective query');
    	  
		SSVBatchSelectorBuilder builder = new SSVBatchSelectorBuilder()
											.withBatchLimit(batchLimit)
											.withProcessingReadyTime(processingReadyTime)
											.withProcessStatus(SSVSelector.PROCESSING_STATUS_READY)
											.withIncludingDuplicates(includeDuplicates)
											.withCustomFilter(customFilter)
											.withOrderByMasterRecordScoreOn(includeDuplicates == true);											
    	
        // Enqueue batch if not running already    
            
        Reporter.log('Queueing Selective (for bulk) Batch job...');
        SSVSyncService syncService = new SSVSyncService(builder, repeating, bulkBatchSize);
                
		return Database.executeBatch(syncService, bulkBatchSize);
    }

    /**
     *  @description Batch start method, returns a query locator with the
     *               records to proces. Required by batchable interface.
     *  @author      Ernesto Valdes, Traction on Demand.
     *  @date        2016-02-09
     *  @param       BC            Batchable context, SFDC
     *  @return                    Query locator to be used by batch execution
     */
     
    global Database.QueryLocator start(Database.BatchableContext BC){    	
    	Reporter.log(query);       
        return Database.getQueryLocator(query);
    }

    /**
     *  @description Batch execute method, performs APEX logic on a subset of
     *               batch records, executed for up to 200 records at a time.
     *               Required by batchable interface.
     *  @author      Ernesto Valdes, Traction on Demand.
     *  @date        2016-02-09
     *  @param       BC            Batchable context, SFDC
     *  @param       scope         List of records in scope of current batch transaction
     */
    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        // set current records in scope
        this.records = scope;

        Reporter.log('Syncing records: ' + records);
        Reporter.log('Repeating: ' + repeating);

        // sync current records in scope
        try {
            sync(records);
        } catch (Exception e) {
            Reporter.report(e);
        }
		
        Reporter.createErrorLogs();
    }

    /**
     *  @description Batch finish method, performs apex logic after records have been
     *               processed, and in a separate independent transaction. Schedules
     *               next batch run.
     *  @author      Ernesto Valdes, Traction on Demand.
     *  @date        2016-02-09
     *  @param       BC            Batchable context, SFDC
     */
    global void finish(Database.BatchableContext BC){
    	
		// link back to customers
		if (this.batchQueryBuilder != null) {
			if (this.bulkBatchSize != null) {
				Database.executeBatch(new SSVSyncOrdersService(this.batchQueryBuilder, this.repeating), this.bulkBatchSize);	
			} else {
				Database.executeBatch(new SSVSyncOrdersService(this.batchQueryBuilder, this.repeating));
			}		
		}

    }

    /**
     *  @description Main method, syncs duplicate and non-duplicate Source System View records
     *               For duplicate records: consolidates duplicates and spawns data from consolidated records
     *               For non-duplicate records: spawns data from records
     *  @author      Ernesto Valdes, Traction on Demand.
     *  @date        2016-02-23
     *  @param       records       List of Source System View records to sync
     *  @return                    The current class instance
     */
    public SSVSyncService sync(List<Source_System_View__c> records) {
    	
    	List<Source_System_View__c> linkCandidates = new List<Source_System_View__c>();

        // determine duplicate records vs unique records
        
        for (Source_System_View__c ssv : records) {
            if (ssv.Duplicate_Set_ID__c != null) {
                duplicateRecords.add(ssv);
            } else {
                nonDuplicateRecords.add(ssv);
            }
        }
        
        SSVCreator creator = new SSVCreator();

        // consolidate duplicate records
        
        if (!duplicateRecords.isEmpty()) {

            List<SSVConsolidated> consolidatedGroups = SSVConsolidator.getConsolidatedGroups(duplicateRecords);

            // spawn data for consolidated groups of duplicate records
            if (!consolidatedGroups.isEmpty()) {
                creator.setRecords(consolidatedGroups);
            }
        }

        // spawn data for unique records
        
        if (!nonDuplicateRecords.isEmpty()) {
            creator.setRecords(nonDuplicateRecords);
        }   
        
        // do the work
        
        linkCandidates.addAll(creator.syncToCustomers().spawnData());
        
        // build up a map of all records updated by spawnData()
        // this is for test purposes. may not be required going forward
        
        Map<String, Source_System_View__c> updatedRecordsMap = new Map<String, Source_System_View__c>();
        MapUtils.mapByField(updatedRecordsMap, linkCandidates, Source_System_View__c.Id);           

        // mark records as processed
        // goes through every record in the batch to update the status
        
        List<Source_System_View__c> ssvToUpdate = new List<Source_System_View__c>();
        for (Source_System_View__c ssv : records) {
        	
        	String newStatus = SSVSelector.PROCESSING_STATUS_COMPLETE;
        	boolean linkCandidate = updatedRecordsMap.containsKey(ssv.Id);
        	
        	// if this was updated by spawnData() we need to link it
        	if (linkCandidate) {
        		newStatus = SSVSelector.PROCESSING_ORDER_LINK_READY;
        	}
        	
            // set processed status and timestamp
            
            ssv.Processing_Status__c = newStatus;
            ssv.Processing_Complete_Time__c = DateTime.now();
            ssvToUpdate.add(ssv);
        }
        
        // DO the DML on all bulkified records
        
        if (!ssvToUpdate.isEmpty()) {
        	update ssvToUpdate;
        }

        return this;
    }
    
}