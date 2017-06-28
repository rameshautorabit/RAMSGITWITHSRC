/**
 * @description Batch class for large updates after recalculating many roll up fields
 * @author John Rogers, Traction on Demand
 * @date 11-02-2016
 */
public class RollUpUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {

    public static final Integer SUGGESTED_BATCH_SIZE = 2000;

    // Variable used as work around testing limits concerning field history records
    public static Boolean TEST_MODIFIED_PARENT = false;

    // The records to perform the DML on
    public Set<Id> parentIds;

    // Map of parent records to roll up values
    Map<Id, Double> parentToRollUpValue;

    // The roll up that is being preformed
    RollUp theRollUp;

    // If any parent records are modified after this time don't update them
    Datetime cutOff;

    /**
     * @author John Rogers, Traction on Demand
     * @date        2016-02-11
     * @param       theRollUp           The roll up that is being preformed
     * @param       parentToRollUpValue Map of parent records to roll up values
     * @param       cutOff              If any parent records are modified after this time don't update them
     */
    public RollUpUpdateBatch(RollUp theRollUp, Map<Id, Double> parentToRollUpValue, Datetime cutOff) {
        this.theRollUp = theRollUp;
        this.parentToRollUpValue = parentToRollUpValue;
        this.parentIds = parentToRollUpValue.keySet();
        this.cutOff = cutOff;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String parentQuery = '' +
            'SELECT ' + theRollUp.parentField.getDescribe().getName() + ' ' +
            'FROM ' + theRollUp.parentType.getDescribe().getName() + ' ' +
            'WHERE Id IN :parentIds';

        System.debug('Kicking off RollUpUpdateBatch: ' + this);
        System.debug('Query: ' + parentQuery);
        theRollUp.prepForSerialization();
        return Database.getQueryLocator(parentQuery);
    }

    public void execute(Database.BatchableContext BC, List<SObject> parents) {
        System.debug('Processing ' + parents.size() + ' parent records');

        Set<Id> modifiedParents = getModifiedParents(parents);
        System.debug('found ' + modifiedParents.size() + ' modified parents');

        List<SObject> parentsToUpdate = new List<SObject>();
        for (SObject parent : parents) {
            // If the roll up field has been modified since the roll up batch operations kicked off
            if (modifiedParents.contains(parent.Id)) {
                // Can't rely on our current information - don't update the parent
                Reporter.report('Parent record ' + parent.Id + ' updated during roll up recalcuation batch run - not updating parent');
                continue;
            }

            Object oldValue = parent.get(theRollUp.parentField);
            Object newValue = MapUtils.get(parentToRollUpValue, parent.Id, 0);
            if (oldValue != newValue) {
                Reporter.report('Roll up incorrect on parent: ' + parent + '. ' +
                                    'Expected: ' + newValue + '; found: ' + oldValue);
                parent.put(theRollUp.parentField, newValue);
                parentsToUpdate.add(parent);
            }
        }

        System.debug('Updating ' + parentsToUpdate.size() + ' parent records');
        List<Database.SaveResult> results = Database.update(parentsToUpdate, false);
        for (Database.SaveResult result : results) {
            if (!result.isSuccess()) {
                for (Database.Error err : result.getErrors()) {
                    Reporter.report(err);
                }
            }
        }
        theRollUp.prepForSerialization();
        Reporter.createErrorLogs();
    }

    public void finish(Database.BatchableContext BC) { 
        System.debug('Finished processing updates for roll up operation: ' + theRollUp);
    }

    /**
     * @description Given a list of parents return a set containing the IDs of
     * the parents that have had thier roll up fields modified since the outset
     * of the job.
     * @author John Rogers, Traction on Demand
     * @date 2016-02-16
     * @param parents : parents to examine
     * @return A set containing the IDs of the parents that have had thier roll
     * up fields modified since the outset of the job.
     */
    private Set<Id> getModifiedParents(List<SObject> parents) {
        String parentIdField;
        String historyTable;
        if (theRollUp.parentType == Account.getSObjectType()) {
            parentIdField = 'AccountId';
            historyTable = 'AccountHistory';
        } else if (theRollUp.parentType == Contact.getSObjectType()) {
            parentIdField = 'ContactId';
            historyTable = 'ContactHistory';
        } else {
            throw new RollUp.RollUpException('Parent type ' + theRollUp.parentType + ' not supported by RollUpUpdateBatch');
        }

        String query = 'SELECT ' + parentIdField + ' ' +
            'FROM ' + historyTable + ' ' + 
            'WHERE CreatedDate > :cutOff ' +
                'AND ' + parentIdField + ' IN :parents ' +
                'AND Field = \'' + theRollUp.parentField.getDescribe().getName() + '\'';

        System.debug('Getting field history for parents with query: \n' + query);
        System.debug('cutOff: ' + cutOff);
        List<SObject> fieldHistories = Database.query(query);
        Set<Id> modifiedParents = new Set<Id>();
        for (SObject fieldHistory : fieldHistories) {
            modifiedParents.add((Id) fieldHistory.get(parentIdField));           
        }

        // Tests cannot create field history records
        if (Test.isRunningTest() && TEST_MODIFIED_PARENT) {
           for (SObject parent : parents) {
               modifiedParents.add(parent.Id);           
           } 
        }

        return modifiedParents;
    }

}