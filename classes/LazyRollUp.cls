/**
 * @description A class used to maintain a roll up relationship without
 * recalcuating the rollup after every change. This approach uses fewer DML
 * rows. This is like having a running tally instead of recalculating after
 * every change. A risk in this approach is that if the update to the parent
 * roll up field fails then the roll up will be incorrect until corrected by
 * calculating the roll up by looking at all the children records.
 * @author John Rogers, Traction on Demand
 * @date 2016-02-09
 */
public abstract class LazyRollUp extends RollUp {

    // Date field that is set whenever the child record impacts the roll up
    public SObjectField lastImpactOnRollUpField;

    // The IDs of the parents that will be updated
    public Set<Id> parentIds {
        get {
            // Get & return super class's parent ID property
            parentIds = (((RollUp) this).parentIds);
            parentIds.addAll(parentToNewRollUpChildren.keySet());
            parentIds.addAll(parentToRemovedRollUpChildren.keySet());
            parentIds.addAll(parentToModifiedRollUpChildren.keySet());
            return parentIds;
        }
        set {
            ((RollUp) this).parentIds = value;
        }
    }

    // Map of parents to children that have been added to the roll up
    public Map<Id, List<SObject>> parentToNewRollUpChildren = new Map<Id, List<SObject>>();

    // Map of parents to children that have been removed from the roll up
    public Map<Id, List<SObject>> parentToRemovedRollUpChildren = new Map<Id, List<SObject>>();

    // Map of parents to children in the roll up that have been modified
    public Map<Id, List<SObject>> parentToModifiedRollUpChildren = new Map<Id, List<SObject>>();

    /**
     * @description Executes the given roll ups, timestamps children if in undelete context, and executes DML
     * @author John Rogers, Traction on Demand
     * @date 2016-02-17
     * @param lrus : Roll ups to execute
     * @return records to update
     */
    public static List<SObject> executeRollUps(List<LazyRollUp> lrus) {
        Map<Id, SObject> recordsToUpdate = new Map<Id, SObject>();

        for (LazyRollUp lru : lrus) {
            // Add parents to map of things to update
            for (SObject parent : lru.execute()) {
                SObject recordToUpdate = recordsToUpdate.get(parent.Id);
                if (recordToUpdate == null) {
                    recordToUpdate = parent;
                    recordsToUpdate.put(recordToUpdate.Id, recordToUpdate);
                }

                recordToUpdate.put(lru.parentField, parent.get(lru.parentField));
            }

            // If undelete context also timestamp the undeleted child via update
            if (Trigger.isUndelete) {
                Datetime now = Datetime.now();
                // Add child to map of things to update
                for (SObject child : lru.getChildren(true, false, false)) {
                    SObject recordToUpdate = recordsToUpdate.get(child.Id);
                    if (recordToUpdate == null) {
                        recordToUpdate = lru.childType.newSObject();
                        recordToUpdate.Id = child.Id;
                        recordsToUpdate.put(recordToUpdate.Id, recordToUpdate);
                    }
                    recordToUpdate.put(lru.lastImpactOnRollUpField, now);
                }
            }
        }

        return recordsToUpdate.values();
    }

    /**
     * @description Returns true if the given child record fits the roll up criteria
     * @author John Rogers, Traction on Demand
     * @date   2016-02-09
     * @param  obj : The record
     * @return True if the child record fits the roll up criteria
     */
    public abstract Boolean fitsRollUpCriteria(SObject obj);

    /**
     * @description Kicks off a roll up calculation batch for this roll up
     * @author John Rogers, Traction on Demand
     * @date        2016-03-22
     */
    public void executeBatch() {
        if (!parentIds.isEmpty()) {
            Database.executeBatch(
                new RollUpCalculationBatch(this), 
                RollUpCalculationBatch.SUGGESTED_BATCH_SIZE
            );
        }
    }

    /**
     * @description Performs the roll up, sets roll up impact timestamps and
     * returns the updated parents. To be called in a trigger context.
     * @author John Rogers
     * @date 12-02-2016
     * @return The updated parents
     */
    public List<SObject> execute() {
        if (Trigger.isDelete) {
            addChildren(Trigger.old);
        } else {
            addChildren(Trigger.new);
        }

        if (parentIds.isEmpty()) {
            return new List<SObject>();
        }

        // Get the parents
        String query = '' +
            'SELECT ' + parentField + ' ' +
            'FROM ' + parentType.getDescribe().getName() + ' ' +
            'WHERE Id IN :parentIds';

        Map<Id, SObject> parents = new Map<Id, SObject> (Database.query(query));
        
        // Perform the roll ups
        updateParents(parents);

        // If children are updatable
        if (Trigger.isUpdate || Trigger.isInsert) {
            // Set timestamps on children that impacted the roll up
            Datetime now = Datetime.now();
            for (SObject child : getChildren(true, false, true)) {
                child.put(lastImpactOnRollUpField, now);
            }
        }

        return parents.values();
    }

    /**
     * @description Updates the given parent records' roll up field. To be called in a trigger context.
     * @author John Rogers, Traction on Demand
     * @date   2016-02-09
     * @param  parents : The parents to update
     */
    public void updateParents(Map<Id, SObject> parents) {
        if (ruType == RollUp.RollUpType.SUM) {
            sum(parents);
        } else {
            throw new RollUp.RollUpException('Roll up type ' + ruType + ' not supported');
        }
    }

    /**
     * @description Add the given children to the given roll up operation if
     * suitable. To be called in a trigger context.
     * @author John Rogers, Traction on Demand
     * @date   2016-02-09
     * @param  rollUp : The roll up operation
     * @param  child : The child record
     */
    public void addChildren(List<SObject> children) {
        for (SObject child : children) {
            addChild(child);
        }
    }

    /**
     * @description Add the given child to the given roll up operation if
     * suitable. To be called in a trigger context.
     * @author John Rogers, Traction on Demand
     * @date   2016-02-09
     * @param  rollUp : The roll up operation
     * @param  child : The child record
     */
    public void addChild(SObject child) {
        Boolean newFitsRollUpCriteria = fitsRollUpCriteria(child);
        if (newFitsRollUpCriteria && (Trigger.isInsert || Trigger.isUndelete)) {
            // Child has been added to the roll up
            addNewChild(child);
        } else if (newFitsRollUpCriteria && Trigger.isDelete) {
            // Child has been removed from the roll up
            addRemovedChild(child);
        } else if (Trigger.isUpdate) {
            SObject oldRecord = Trigger.oldMap.get(child.Id);
            Boolean oldFitsRollUpCriteria = fitsRollUpCriteria(oldRecord);

            // If the lookup field has changed 
            if (handleLookupChange(child, oldRecord)) {
                return;
            }

            // If the child has been added/removed from the roll up
            if (handleFitsCriteriaChange(child, oldRecord)) {
                return;
            }

            // If the child fits the criteria and the roll up field has changed
            if (newFitsRollUpCriteria && oldRecord.get(childField) != child.get(childField)) {
                // Child in roll up has been modified
                addModifiedChild(child);
            }
        }        
    }

    /**
     * @description Check if the lookup field has changed on the given child. If
     * true and the child, or the old version of the child, impacts the roll
     * up add the child/old version to the roll up calculation
     * @author John Rogers, Traction on Demand
     * @date        2016-02-17
     * @param child : The child record to check
     * @param oldRecord : The old version of the child record
     * @return True if the lookup field has changed
     */
    public Boolean handleLookupChange(SObject child, SObject oldRecord) {
        if (oldRecord.get(lookupField) != child.get(lookupField)) {
            if (fitsRollUpCriteria(child)) {        
                // Added to new parent's roll up
                 addNewChild(child);
            }

            if (fitsRollUpCriteria(oldRecord)) {
                // Removed from old parent's roll up
                addRemovedChild(oldRecord);
            }
            return true;
        }
        return false;
    }

    /**
     * @description Check if child used to fit the roll up criteria and now
     * doesn't, or used to not fit the criteria and now does. If true and the
     * child, or the old version of the child, impacts the roll up add the
     * child/old version to the roll up calculation
     * @author John Rogers, Traction on Demand
     * @date        2016-02-17
     * @param child : The child record to check
     * @param oldRecord : The old version of the child record
     * @return True if the lookup field has changed
     */
    public Boolean handleFitsCriteriaChange(SObject child, SObject oldRecord) {
        if (fitsRollUpCriteria(child) != fitsRollUpCriteria(oldRecord)) {
            if (fitsRollUpCriteria(child)) {
                // Child has been added to roll up
                addNewChild(child);
            } else {
                // Child has been removed from the roll up
                addRemovedChild(oldRecord);
            }
            return true;
        }
        return false;
    }

    /**
     * @description Add a child record that is not currently included in the
     * roll up and should be added
     * @author John Rogers, Traction on Demand
     * @date   2016-02-09
     * @param  child : The child to add to the roll up
     */
    public void addNewChild(SObject child) {
        List<SObject> newChildren = parentToNewRollUpChildren.get((Id) child.get(lookupField));
        if (newChildren == null) {
            newChildren = new List<SObject>();
            parentToNewRollUpChildren.put((Id) child.get(lookupField), newChildren);
        }
        newChildren.add(child);
    }

    /**
     * @description Add a child record is currently included in the roll up
     * and should be removed
     * @author John Rogers, Traction on Demand
     * @date   2016-02-09
     * @param  child : The child to add to the roll up
     */
    public void addRemovedChild(SObject child) {
        List<SObject> removedChildren = parentToRemovedRollUpChildren.get((Id) child.get(lookupField));
        if (removedChildren == null) {
            removedChildren = new List<SObject>();
            parentToRemovedRollUpChildren.put((Id) child.get(lookupField), removedChildren);
        }
        removedChildren.add(child);
    }

    /**
     * @description Add a child record is currently included in the roll up
     * that has had its roll up field modified
     * @author John Rogers, Traction on Demand
     * @date   2016-02-09
     * @param  child : The child to add to the roll up
     */
    public void addModifiedChild(SObject child) {
        List<SObject> modifiedChildren = parentToModifiedRollUpChildren.get((Id) child.get(lookupField));
        if (modifiedChildren == null) {
            modifiedChildren = new List<SObject>();
            parentToModifiedRollUpChildren.put((Id) child.get(lookupField), modifiedChildren);
        }
        modifiedChildren.add(child);
    }

    /**
     * @description Update the roll up field on the given parents.
     * @author John Rogers, Traction on Demand
     * @date 2016-02-09
     * @param  parents : The parent records to update
     */
    public void sum(Map<Id, SObject> parents) { 
        // Update the given parents' roll up fields
        for (Id parentId : parents.keySet()) {
            SObject parent = parents.get(parentId);
            if (parent == null) {
                continue;
            }

            // Get current sum
            Double currentRollUpValue = 0;
            if (parent.get(parentField) != null) {
                currentRollUpValue = Double.valueOf(parent.get(parentField));
            }

            // For each new child under a parent add to the parent sum
            List<SObject> newRollUpChildren = parentToNewRollUpChildren.get(parentId);
            if (newRollUpChildren != null) {
                for (SObject newChild : newRollUpChildren) {
                    if (newChild.get(childField) != null) {
                        currentRollUpValue += Double.valueOf(newChild.get(childField));
                    }
                }
            }

            // For each removed child under a parent subtract from the parent sum
            List<SObject> removedRollUpChildren = parentToRemovedRollUpChildren.get(parentId);
            if (removedRollUpChildren != null) {
                for (SObject removedChild : removedRollUpChildren) {
                    if (removedChild.get(childField) != null) {
                        currentRollUpValue -= Double.valueOf(removedChild.get(childField));
                    }
                }
            }

            // For each child under a parent that has a modified roll up field, add the difference
            List<SObject> modifiedRollUpChildren = parentToModifiedRollUpChildren.get(parentId);
            if (modifiedRollUpChildren != null) {
                for (SObject modifiedChild : modifiedRollUpChildren) {
                    // Find the difference
                    SObject oldRecord = Trigger.oldMap.get(modifiedChild.Id);
                    Double oldValue = 0;
                    if (oldRecord.get(childField) != null) {
                        oldValue = Double.valueOf(oldRecord.get(childField));
                    }

                    Double newValue = 0;
                    if (modifiedChild.get(childField) != null) {
                        newValue = Double.valueOf(modifiedChild.get(childField));
                    }

                    currentRollUpValue += newValue - oldValue;
                }
            }

            // Set sum
            setParentField(parent, currentRollUpValue);
        }
    }

    /**
     * @author John Rogers, Traction on Demand
     * @date        2016-02-11
     * @param  newRollUp : If true return children that are new to a roll up
     * @param  removedRollUp : If true return children that are removed from a roll up
     * @param  modifiedRollUp : If true return children in a roll up that have been modified
     * @return List of children that impacted the roll up
     */
    public List<SObject> getChildren(Boolean newRollUp, Boolean removedRollUp, Boolean modifiedRollUp) {
        List<SObject> children = new List<SObject>();
        for (Id parentId : parentIds) {
            // For each new child under a parent add to the parent sum
            List<SObject> newRollUpChildren = parentToNewRollUpChildren.get(parentId);
            if (newRollUpChildren != null && newRollUp) {
                children.addAll(newRollUpChildren);
            }

            // For each removed child under a parent subtract from the parent sum
            List<SObject> removedRollUpChildren = parentToRemovedRollUpChildren.get(parentId);
            if (removedRollUpChildren != null && removedRollUp) {
                children.addAll(removedRollUpChildren);
            }

            // For each child under a parent that has a modified roll up field, add the difference
            List<SObject> modifiedRollUpChildren = parentToModifiedRollUpChildren.get(parentId);
            if (modifiedRollUpChildren != null && modifiedRollUp) {
                children.addAll(modifiedRollUpChildren);
            }
        }

        return children;
    }

    /**
     * Given a parent record, a field name, and a value, casts the value to the
     * field type and sets the field to the value
     * @author John Rogers, Traction on Demand
     * @date 2016-02-09
     * @param  parent : The record to set the field on
     * @param  value : The value to set the field to
     */
    private void setParentField(SObject parent, Object value) {
         DisplayType type = parentField.getDescribe().getType();
         if (type == DisplayType.Integer) {
            parent.put(parentField, Integer.valueOf(value));
         } else if (type == DisplayType.Double 
                || type == DisplayType.Currency) {
            parent.put(parentField, Double.valueOf(value));
         }
    }
}