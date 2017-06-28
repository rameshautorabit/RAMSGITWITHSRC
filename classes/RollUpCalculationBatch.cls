/**
 * @description Batch job for calculating a roll up 
 * @author John Rogers, Traction on Demand
 * @date 2016-02-10
 */
public class RollUpCalculationBatch implements Database.Batchable<sObject>, Database.Stateful {

    public static final Integer SUGGESTED_BATCH_SIZE = 2000;

    // The roll up to preform
    public RollUp theRollUp;

    // The query to retrieve the children records for calculating the roll up
    public String childQuery;

    // List of parents that will have roll up calculated
    public Set<Id> parentIds {
        get {
            return parentToRollUpValue.keySet();
        } 
        set;
    }

    // The moment the job was kicked off
    public Datetime startTime;

    // Map of parents to the parent roll up field value
    public Map<Id, Double> parentToRollUpValue;

    /**
     * @author John Rogers, Traction on Demand
     * @date 2016-02-10
     * @param theRollUp : The roll up operation to preform
     * @return Batch job that when executed will calculate the given roll up
     */
    public RollUpCalculationBatch(RollUp theRollUp) { 
        this(theRollUp, new Map<Id, Double>());

        for(Id parentId : theRollUp.parentIds) {
            parentToRollUpValue.put(parentId, 0);
        }
    }
    
    /**
     * @author John Rogers, Traction on Demand
     * @date 2016-02-10
     * @param theRollUp : The roll up operation to preform
     * @param parentToRollUpValue : The map of parent IDs to roll up values to populate
     * @return Batch job that when executed will calculate the given roll up
     */
    public RollUpCalculationBatch(RollUp theRollUp, Map<Id, Double> parentToRollUpValue) { 
        this.theRollUp = theRollUp;
        this.parentToRollUpValue = parentToRollUpValue;

        // Set query to retrieve all children with parents in parentIds
        childQuery = 'SELECT ' + 
                theRollUp.childField.getDescribe().getName() + ', ' +
                theRollUp.lookupField.getDescribe().getName() + ' ' +
            'FROM ' + theRollUp.childType.getDescribe().getName() + ' ' +
            'WHERE (' + theRollUp.rollUpCriteriaClause + ') ' +
                'AND ' + theRollUp.lookupField.getDescribe().getName() + ' IN :parentIds ';

        theRollUp.prepForSerialization();
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('Kicking off RollUpCalculationBatch: ' + this);
        System.debug('Query: ' + childQuery);
        startTime = Datetime.now();
        return Database.getQueryLocator(childQuery);
    }

    /**
     * @description Update parent records' roll up field value given a batch of children records
     * @author John Rogers, Traction on Demand
     * @date 2016-02-10
     * @param BC : The batchable context
     * @param children : The batch of children records
     */
    public void execute(Database.BatchableContext BC, List<SObject> children) {
        System.debug('Processing roll ups. Current roll up calcuation state: ' + parentToRollUpValue);
        if (theRollUp.ruType == RollUp.RollUpType.SUM) {
            // Iterate through children and update parent roll up value 
            for (SObject child : children) {
                Id parentId = (Id) child.get(theRollUp.lookupField);
                Object childValue = child.get(theRollUp.childField);
                if (childValue != null) {
                    Double rollUpValue = parentToRollUpValue.get(parentId);
                    if (rollUpValue == null) {
                        rollUpValue = 0;
                    }
                    parentToRollUpValue.put(parentId, rollUpValue + Double.valueOf(childValue));
                }
            }    
        } else {
            throw new RollUp.RollUpException('Roll up operation ' + theRollUp.ruType + ' not supported');
        }

        theRollUp.prepForSerialization();
    }

    /**
     * @description Initiate process for updating the roll up field values with
     * the values calcuated during the batch run
     * @author John Rogers, Traction on Demand
     * @date 2016-02-10
     * @param BC : The batchable context
     */
    public void finish(Database.BatchableContext BC) {
        System.debug('Finished calculating roll ups, kicking of batch job to perform updates');
        RollUpUpdateBatch batch = new RollUpUpdateBatch(theRollUp, parentToRollUpValue, startTime);
        Database.executeBatch(batch, RollUpUpdateBatch.SUGGESTED_BATCH_SIZE);
    }
}