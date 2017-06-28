/**
 * @description Abstract domain class for objects. 
 *  Handles all functionality for its respective object,
 *  deferring complex implementations to helper classes.
 * @author John Rogers, Traction on Demand
 * @date 17-02-2016
 */
public abstract class SObjectDomain {

    // Flag allowing top level domain to detect that is the top level domain
    public static Boolean tld = true;

    public Boolean isTld {
        get {
            if (SObjectDomain.tld) {
                isTld = true;
                SObjectDomain.tld = false;
            } else {
                isTld = false;
            }
            return isTld;
        } set;
    }

    // The records that the domain class methods will act on
    public List<SObject> records {
        get {
            if (records == null) records = new List<SObject>();
            return records;
        }
        set;
    }

    public List<SObject> mergeDeletedRecords {
        get {
            if (mergeDeletedRecords == null) {
                mergeDeletedRecords = new List<SObject>();
                for (SObject record : records) {
                    // MasterRecordId is only set during after delete merge triggers
                    if (record.get('MasterRecordId') != null) {
                        mergeDeletedRecords.add(record);
                    }
                }
            }
            return mergeDeletedRecords;
        }
        set;
    }

    // New record map, initialized from domain records, if available
    public Map<Id, SObject> newRecordMap {
        get {
            if (newRecordMap == null) {
                if (records != null) newRecordMap = new Map<Id, SObject>(records);
                else newRecordMap = new Map<Id, SObject>();
            }
            return newRecordMap;
        }
        set;
    }

    // The records to update after trigger operations complete
    public Map<Id, SObject> recordsToUpdateMap = new Map<Id, SObject>();

    // The records to insert after trigger operations complete
    public List<SObject> recordsToInsert;

    // The records to delete after trigger operations complete
    public List<SObject> recordsToDelete;

    public SObjectDomain() {
        records = new List<SObject>();
        recordsToInsert = new List<SObject>();
        recordsToDelete = new List<SObject>();
    }

    /**
     * @description When called within a Trigger context executes the appropriate logic
     * @author John Rogers, Traction on Demand
     * @date 2016-02-17
     */
    public static void domainTriggerHandler(SObjectDomain domain) {
    	
	    if(!FeatureFlagService.isMdmMergeFeatureActive()){
	    	return;
		}
    
        if (Trigger.isBefore) {
            if (Trigger.isInsert) { 
                domain.records.addAll(Trigger.new);
                domain.handleBeforeInsert();
            } else if (Trigger.isUpdate) {
                domain.records.addAll(Trigger.new);
                domain.newRecordMap = trigger.newMap;
                domain.handleBeforeUpdate(Trigger.oldMap);
            } else if (Trigger.isDelete) {
                domain.records.addAll(Trigger.old);
                domain.handleBeforeDelete();
                domain.handleBeforeMergeDelete();
            }
        } else if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                domain.records.addAll(Trigger.new);
                domain.newRecordMap = trigger.newMap;
                domain.handleAfterInsert();
            } else if (Trigger.isUpdate) {
                domain.records.addAll(Trigger.new);
                domain.newRecordMap = trigger.newMap;
                domain.handleAfterUpdate(Trigger.oldMap);
            } else if (Trigger.isDelete) {
                domain.records.addAll(Trigger.old);
                domain.handleAfterDelete();
                domain.handleAfterMergeDelete();
            } else if (Trigger.isUndelete) {
                domain.records.addAll(Trigger.new);
                domain.newRecordMap = trigger.newMap;
                domain.handleAfterUndelete();
            }
        }
        domain.doDml();

        // Only create error logs at the very end of the transaction
        if (domain.isTld) {
            Reporter.createErrorLogs();
        }
    }

    public virtual void handleBeforeInsert() { }

    public virtual void handleBeforeUpdate(Map<Id, SObject> oldRecordMap) {}

    public virtual void handleBeforeDelete() { }

    public virtual void handleBeforeMergeDelete() { }

    public virtual void handleAfterInsert() { }

    public virtual void handleAfterUpdate(Map<Id, SObject> oldRecordMap) {}

    public virtual void handleAfterDelete() { }

    public virtual void handleAfterMergeDelete() { }

    public virtual void handleAfterUndelete() { }

    /**
     * @description Registers all records in the given list for update. If a
     * record is already registered for an update then it is replaced with the
     * record to update
     * @author John Rogers, Traction on Demand
     * @date        2016-03-09
     * @param       record : The records to retrieve/add to the records to
     * update map
     * @return  the list containing references to records in the given list or
     * references to the update map
     */
    public List<SObject> recordsToUpdate(List<SObject> records) {
        List<SObject> retList = new List<SObject>();
        for (SObject record : records) {
            retList.add(recordToUpdate(record));
        }
        return retList;
    }

    /**
     * @description If recordsToUpdateMap contains the given record, set the
     * record to the contained record, otherwise adds the given record to the
     * recordsToUpdateMap
     * @author John Rogers, Traction on Demand
     * @date        2016-03-09
     * @param       record : The record to retrieve/add to the records to update
     * map
     * @return recordsToUpdateMap.get(record.Id) if not null, otherwise return
     * the given record
     */
    public SObject recordToUpdate(SObject record) {
        // If the given record is registered for an update
        SObject registeredRecord = recordsToUpdateMap.get(record.Id);
        if (registeredRecord != null) {
            // Return the record
            return registeredRecord;
        }

        // Otherwise add record to list of records to upate
        recordsToUpdateMap.put(record.Id, record);
        return record;
    }

    /**
     * @description Updates all records in the records to update list
     * @author John Rogers, Traction on Demand
     * @update Zi Zhang, Traction on Demand
     * @date        2016-02-22
     */
    private void doDml() {
        doUpdates();
        doInserts();
        doDeletes();
    }

    /**
     * Deletes all records in the records to delete list
     * @author Zi Zhang, Traction on Demand
     * @date   2016-02-29
     */
    private void doDeletes() {
        if (recordsToDelete.isEmpty()) {
            return;
        }
        List<Database.DeleteResult> results = Database.delete(recordsToDelete, false);
        Reporter.report(recordsToDelete, results);
    }

    /**
     * @description Updates all records in the to update map
     * @author John Rogers, Traction on Demand
     * @date        2016-03-21
     */
    private void doUpdates() {
        if (recordsToUpdateMap.isEmpty()) { 
            return;
        }
        List<Database.SaveResult> results = Database.update(recordsToUpdateMap.values(), false);
        Reporter.report(recordsToUpdateMap.values(), results);
    }

    /**
     * @description Inserts all records in the to insert list
     * @author John Rogers, Traction on Demand
     * @date        2016-03-21
     */
    private void doInserts() {
        if (recordsToInsert.isEmpty()) {
            return;
        }
        List<Database.SaveResult> results = Database.insert(recordsToInsert, false);
        Reporter.report(recordsToInsert, results);
    }
}