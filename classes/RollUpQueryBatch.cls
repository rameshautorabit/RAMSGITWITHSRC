/**
 * @description Batch job for building a query for, and executing, a
 * RollUpCalculationBatch job. The job doesn't actually build a query; it
 * collects all the Ids of parent records that have had thier roll up value
 * impacted since 'cutOffDate', and passes those IDs to RollUpCalculationBatch
 * to be used in the RollUpCalculationBatch query. It does this by looking at a
 * 'lastImpactOnRollUpField' timestamp on the child object, and if the timestamp
 * is AFTER the given 'cutOffDate' then the roll up for that child's parent will
 * be recalculated.
 *
 * NOTE: The reason we must look at a timestamp on the child, not the
 * parent, is that there is a chance that the parent won't be timestamped on
 * roll up change due to validation rules. Therefore the child record is a more
 * reliable indicator that a roll up has changed and needs recalcuation
 * / verification.
 * 
 * @author John Rogers, Traction on Demand
 * @date 11-02-2016
 */
public class RollUpQueryBatch implements Database.Batchable<sObject>, Database.Stateful {

    // The maximum size of the map before heap size limits are a concern 
    /*
        10 MB heap size limit for asyncronous jobs. 
        Expecting map to be largest potential user of the heap.
        Each map entry takes appx. 60 bytes. 
        1,000,000 bytes per megabyte (to be on the safe side - docs say MB not MiB)
        Assuming 8.1 MB of space free for the map this allows for 8,100,000 bytes of space
        8,100,000 bytes / (60 bytes/entry) = 135,000 entries
        The job is safe to run on only a set of 135,000 parent ids.  
     */
    public static final Integer MAX_MAP_SIZE = 135000;

    public static final Integer SUGGESTED_BATCH_SIZE = 2000;

    // The map of parent ID to roll up value
    /* 
        NOTE: 
        Using double to store currency values instead of decimal to increase
        number of map entries before 10MB limit is exceeded. Since this class
        and the RollUpUpdateBatch don't do multiplication or division this
        should be fine.
     */
    public Map<Id, Double> parentToRollUpValue = new Map<Id, Double>();

    // The roll up operation to build a query for
    public LazyRollUp theRollUp;

    // The query to find all children that have impacted the batch since last run
    public String query;

    // Any children with lastImpactOnRollUpField < cutOffDate are not processed for building the query
    public Datetime cutOffDate;

    // Used when parentToRollUpValue is reset because it exceeds the max batch size
    private Id lastParentId;

    /**
     * @description Constructor to use if running batch to collect IDs of parents with null roll up values
     * @author John Rogers, Traction on Demand
     * @date 2016-02-11
     * @param theRollUp : Roll up operation to build a query for
     */
    public RollUpQueryBatch(LazyRollUp theRollUp) {
        this.theRollUp = theRollUp;
        this.cutOffDate = cutOffDate;
        // Build the query to find all parents
        query = '' +
            'SELECT Id ' +
            'FROM ' + theRollUp.parentType + ' ' +
            'WHERE ' + theRollUp.parentField.getDescribe().getName() + ' = NULL ';
        theRollUp.prepForSerialization();
    }

    /**
     * @description Constructor to use if running batch to collect IDs of parents with modified children
     * @author John Rogers, Traction on Demand
     * @date 2016-02-11
     * @param theRollUp : Roll up operation to build a query for
     * @param cutOffDate : Any children with lastImpactOnRollUpField < cutOffDate are not processed
     */
    public RollUpQueryBatch(LazyRollUp theRollUp, Datetime cutOffDate) {
        this.theRollUp = theRollUp;
        this.cutOffDate = cutOffDate;
        // Build the query to find all children that have impacted the batch since last run
        // Since timestamp can't be set on deleted or undeleted children, include clauses for those too
        query = '' +
            'SELECT ' + theRollUp.lookupField + ' ' +
            'FROM ' + theRollUp.childType + ' ' + 
            'WHERE ' + theRollUp.lastImpactOnRollUpField.getDescribe().getName() + ' >= :cutOffDate ' + // Get inserted / updated / undeleted records
                'OR ((' + theRollUp.rollUpCriteriaClause + ') AND IsDeleted = true AND LastModifiedDate >= :cutOffDate) ' + // Get deleted records
            'ORDER BY ' + theRollUp.lookupField.getDescribe().getName();
        theRollUp.prepForSerialization();
    }

    /**
     * @description Starts the batch job
     * @author John Rogers, Traction on Demand
     * @date 2016-02-11
     * @param BC : The batchable context
     * @return A query locator to iterate through during the batch job
     */
    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('Kicking off RollUpQueryBatch:' + this);
        return Database.getQueryLocator(query);
    }

    /**
     * @description Populates the list of Ids of parents to have roll ups
     * recalcuated
     * @author John Rogers, Traction on Demand
     * @date 2016-02-11
     * @param BC : The batchable context
     * @param scope : The children that have been modified since the last job
     * run, or the parents that need a roll up recalcuated
     */
    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        // If the previous execution added more records than the calculation batch can handle, reset the map
        if (parentToRollUpValue.size() >= MAX_MAP_SIZE) {
            parentToRollUpValue = new Map<Id, Double>();
        }

        // Populate the list of parent IDs to roll up
        for (SObject obj : scope) {
            Id parentId;
            if (obj.getSObjectType() == theRollUp.parentType) {
                parentId = obj.Id;
            } else {
                parentId = (Id) obj.get(theRollUp.lookupField);
            }

            // If parentToRollUpValue was reinitialized don't re-add a parent ID to the new set
            if (parentId != lastParentId) {
                parentToRollUpValue.put(parentId, 0);
                lastParentId = parentId;
            }
        }

        // Kick off the batch job to recalcuate the parent IDs
        if (parentToRollUpValue.size() >= MAX_MAP_SIZE) {
            System.debug('Finished collecting ' + MAX_MAP_SIZE + ' parentIds.');
            System.debug('Kicking off RollUpCalculationBatch on RollUp: ' + theRollUp);
            System.enqueueJob(new ExecuteBatchQueueable(theRollUp, parentToRollUpValue));
        }
        theRollUp.prepForSerialization();
    }

    /**
     * @description Initiates the recalcuation of the roll up on the modified parents
     * @author John Rogers, Traction on Demand
     * @date 2016-02-11
     * @param BC : The batchable context
     */
    public void finish(Database.BatchableContext BC) {
        if (parentToRollUpValue.size() < MAX_MAP_SIZE) {
           // Initiate roll up recalc for all discovered parents
           System.debug('Finished collecting parentIds.');
           System.debug('Kicking off RollUpCalculationBatch on RollUp: ' + theRollUp);
           Database.executeBatch(new RollUpCalculationBatch(theRollUp, parentToRollUpValue)); 
       }
    }

    // Hack to work around restrictions of where batches can be executed
    public class ExecuteBatchQueueable implements Queueable {

        LazyRollUp theRollUp;
        Map<Id, Double> parentToRollUpValue;

        public ExecuteBatchQueueable(LazyRollUp theRollUp, Map<Id, Double> parentToRollUpValue) {
            this.theRollUp = theRollUp;
            this.parentToRollUpValue = parentToRollUpValue;
        }

        public void execute(QueueableContext context) {
            Database.executeBatch(
                new RollUpCalculationBatch(theRollUp, parentToRollUpValue),
                RollUpCalculationBatch.SUGGESTED_BATCH_SIZE
            );
        }
    }
}