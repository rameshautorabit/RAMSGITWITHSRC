/**
 * @description A group of children under a parent. Each group can have one child flagged as primary.
 * NOTE: This implementation assumes that a child cannot belong to more than one group
 */
public class ChildHierarchyGroup {

    // Children in this set will not be processed
    public static Set<Id> childrenToIgnore = new Set<Id>();

    // The type of this group
    public ChildHierarchyGroupType groupType;

    // The flag field that marks the children as primary
    public SObjectField primaryFlag {
        get { return groupType.primaryFlag; }
    }

    // The field that connects the parents and children
    public SObjectField lookupField {
        get { return groupType.lookupField; }
    }

    // Error message displayed when more than one child in a group is marked as primary
    public String multipleNewPrimariesError {
        get { return groupType.multipleNewPrimariesError; }
    }

    // Error message displayed when the only primary child in a group is removed
    public String removeOnlyPrimaryError {
        get { return groupType.removeOnlyPrimaryError; }
    }

    // The type of the parent record
    public SObjectType parentType {
        get { return groupType.parentType; }
    }

    // The type of the child record
    public SObjectType childType {
        get { return groupType.childType; }
    }

    // The parent-child relationship 
    /*public ChildRelationship childRelationship {
        get {
            if (childRelationship == null) {
                // Find the child relationship
                List<Schema.ChildRelationship> crs = parentType.getDescribe().getChildRelationships(); 
                for (Schema.ChildRelationship cr : crs) {
                    if (cr.getField() == lookupField) {
                        childRelationship = cr;
                    }
                }
            }
            return childRelationship;
        }
        set;
    }*/

    // Id of the parent for this group of children
    public Id parentId;

    // List of children that were not primary and are now primary due to updated or creation
    protected List<SObject> newPrimaries = new List<SObject>();

    // List of children that were marked primary before the DML operation
    protected List<SObject> oldPrimaries = new List<SObject>();

    // List of children that were primary but are no longer due to update or removal
    protected List<SObject> removedPrimaries = new List<SObject>();

    // List of children that are primary and have changed groups (lookup change or criteria change)
    protected List<SObject> changedGroupPrimaries = new List<SObject>();

    /**
     * @description Given a list of children maintain the hierarchy groups that the children belong to.
     *              To be called in after trigger context when all records are guarenteed to have Ids.
     * @author John Rogers, Traction on Demand
     * @date        2016-02-23
     * @param       children : The children to maintain hierarchy groups for
     * @param       groupTypes : The types of groups to maintain
     * @return  The children to update
     */
    public static List<SObject> maintainGroups(List<SObject> children, List<ChildHierarchyGroupType> groupTypes) {
        List<SObject> filteredChildren = new List<SObject>();
        for (SObject child : children) {
            // Filter out children in ignore list
            if (childrenToIgnore.contains(child.Id)) {
                continue;
            }

            // Only interested in children with parents
            for (ChildHierarchyGroupType groupType : groupTypes) {
                if (child.get(groupType.lookupField) != null) {
                    filteredChildren.add(child);
                    break;
                }
            }
        }

        if (filteredChildren.isEmpty()) {
            return new List<SObject>();
        }

        List<ChildHierarchyGroup> groups = getChildHierarchyGroups(children, groupTypes);

        List<SObject> sObjectsToUpdate = new List<SObject>();

        // Process the groups for possible errors
        for (ChildHierarchyGroup g : groups) {
            sObjectsToUpdate.addAll(g.maintain());
        }        

        return sObjectsToUpdate;
    }

    /**
     * @description Return the hierarchy groups of the given types for the given children 
     * @author John Rogers, Traction on Demand
     * @date        2016-02-24
     * @param       children : The children to get the groups for
     * @param       groupTypes : The types of groups to get.
     * @return The hierarchy groups for the given children of the given types
     */
    public static List<ChildHierarchyGroup> getChildHierarchyGroups(List<SObject> children, List<ChildHierarchyGroupType> groupTypes) {
        // Get the missing primary children from the given list
        List<SObject> allChildren = addPrimarySiblings(children, groupTypes);

        // Put each child into the appropriate group
        Map<String, ChildHierarchyGroup> idToGroup = new Map<String, ChildHierarchyGroup>();
        for (SObject child : allChildren) {
            for (ChildHierarchyGroupType groupType : groupTypes) {
                 // If the child is part of the group
                if (groupType.belongsToGroupType(child)) {
                    // Get the ID of the child's group
                    String groupId = groupType.getGroupId(child);
                    
                    // Get the child's group
                    ChildHierarchyGroup g = (ChildHierarchyGroup) idToGroup.get(groupId);

                    // If the group DNE 
                    if (g == null) {
                        // Create a new group
                        g = new ChildHierarchyGroup((Id) child.get(groupType.lookupField), groupType);
                        idToGroup.put(g.getGroupId(), g);
                    }

                    // Add child to the group
                    g.addChild(child);
                }
            }
        }        

        return idToGroup.values();
    }

    /**
     * @description Add to the given list of children all of the primary children that are sibilings to the given children
     * @author John Rogers, Traction on Demand
     * @date        2016-02-24
     * @param       children   : The children
     * @param       groupTypes : The types of groups of concern
     * @return List containing the passed children + the primary siblings
     */
    private static List<SObject> addPrimarySiblings(List<SObject> children, List<ChildHierarchyGroupType> groupTypes) {
        if (children.isEmpty()) {
            return children;
        }

        // Query for all the required fields
        String primaryChildrenQuery = 'SELECT ';
        Set<String> fields = new Set<String>();
        for (ChildHierarchyGroupType groupType : groupTypes) {
            fields.addAll(groupType.additionalRequiredFields);
            fields.add(groupType.lookupField.getDescribe().getName());
            fields.add(groupType.primaryFlag.getDescribe().getName());
        }
        primaryChildrenQuery += String.join(new List<String>(fields), ',');

        // Querying the children table
        primaryChildrenQuery += ' FROM ' + children[0].getSObjectType().getDescribe().getName() + ' ';

        // Build the clauses that return the primary children in the groups
        primaryChildrenQuery += ' WHERE Id NOT IN :children '; // TODO-jdr this assumes children can't be in more than one group (true for RH)

        // Build 'primary children' clause for each group
        Set<String> clauses = new Set<String>();
        Set<Id> parentIds = new Set<Id>();
        for (ChildHierarchyGroupType groupType : groupTypes) {
            parentIds.addAll(ListUtils.collectIds(children, groupType.lookupField));
            clauses.add('(' + 
                groupType.lookupField.getDescribe().getName() + ' IN :parentIds ' +
                'AND ' + groupType.primaryFlag.getDescribe().getName() + ' = true)'
            );
        }

        // TODO-jdr use below to reduce query result size (not needed for RH) (make sure not over 20,000 character limit though)
        //// Build 'primary children' clause for each group
        //Set<String> clauses = new Set<String>();
        //for (ChildHierarchyGroupType groupType : groupTypes) {
        //    // TODO-jdr remove string.join parentIds ()
        //    Set<Id> parentIds = ListUtils.collectIds(children, groupType.lookupField);
        //    clauses.add('(' + 
        //        groupType.lookupField.getDescribe().getName() + ' IN (\'' + String.join(new List<Id>(parentIds), '\',\'') + '\') ' +
        //        'AND ' + groupType.primaryFlag.getDescribe().getName() + ' = true ' +
        //        'AND (' + groupType.clause + '))'
        //    );
        //}

        primaryChildrenQuery += 'AND (' + String.join(new List<String>(clauses), ' OR ') + ')';

        List<SObject> allChildren = Database.query(primaryChildrenQuery);
        allChildren.addAll(children);
        return allChildren;
    }

    /**
     * @author John Rogers, Traction on Demand
     * @date        2016-02-24
     * @param       parentId   : The ID of the parent of this group
     * @param       groupType  : The type of the group
     */
    public ChildHierarchyGroup(Id parentId, ChildHierarchyGroupType groupType) {
        this.parentId = parentId;
        this.groupType = groupType;
    }

    /**
     * @author John Rogers, Traction on Demand
     * @date        2016-02-26
     * @return The ID of this group
     */
    public String getGroupId() {
        return groupType.getGroupId(parentId);
    }

    /**
     * @author John Rogers, Traction on Demand
     * @date        2016-02-23
     * @param       record : The record to check
     * @return True if the record can be a part of this group, false otherwise.
     */
    public Boolean belongsToGroup(SObject record) {
        return groupType.belongsToGroupType(record) && record.get(lookupField) == parentId;
    }

    /**
     * @author John Rogers, Traction on Demand
     * @date        2016-02-23
     * @param       record : The record to check
     * @return True if the given record is a primary child for this group
     */
    public Boolean checkIsPrimary(SObject record) {
        return record.get(lookupField) == parentId && groupType.checkIsPrimary(record);
    }

    /**
     * @description Adds any of the given children to group if child meets group requirements
     * @author John Rogers, Traction on Demand
     * @date        2016-02-23
     * @param       children 
     */
    public void addChildren(List<SObject> children) {
        for (SObject child : children) {
            addChild(child);
        }
    }

    /**
     * @description Adds given child to group if it meets the group requirements
     * @author John Rogers, Traction on Demand
     * @date        2016-02-23
     * @param       child : Child to add
     */
    public void addChild(SObject child) {
        // Nothing to do in an undelete context (can't delete a primary record, so can't undelete either)
        if (Trigger.isUndelete) {
            return;
        }

        // Can't handle a before insert context because children don't have IDs yet
        if (Trigger.isBefore && Trigger.isInsert) {
            throw new ChildHierarchyGroupException('Cannot call addChild in this trigger context.');
        }

        // Get the current DML operation child record for adding error to if required
        SObject currentDmlChild;
        if (Trigger.isUpdate || Trigger.isInsert) {
            currentDmlChild = Trigger.newMap.get(child.Id);
        } else if (Trigger.isDelete) {
            currentDmlChild = Trigger.oldMap.get(child.Id);
        }

        // If child is not part of current DML operation
        if (currentDmlChild == null) {
            // It is an 'old' child
            if (checkIsPrimary(child)) {
                oldPrimaries.add(child);
            } 
            // Nothing else to do for old children
            return;
        }

        // Child is not part of current DML operation, put it in the correct list
        if (Trigger.isUpdate) {
            SObject oldChild = Trigger.oldMap.get(currentDmlChild.Id);
            // If the group has changed
            if (belongsToGroup(currentDmlChild) && !belongsToGroup(oldChild)) {
                changedGroupPrimaries.add(currentDmlChild);
            // If child is new primary
            } else if (checkIsPrimary(currentDmlChild) && !checkIsPrimary(oldChild)) {
                // Add to new primaries list
                newPrimaries.add(currentDmlChild);
            // If the child was a primary but is no longer
            } else if (!checkIsPrimary(currentDmlChild) && checkIsPrimary(oldChild)) {
                // Add to removed primaries list
                removedPrimaries.add(currentDmlChild);
            }
        } else if (Trigger.isInsert) {
            if (checkIsPrimary(currentDmlChild)) {
                newPrimaries.add(currentDmlChild);
            }
        } else if (Trigger.isDelete) {
            if (checkIsPrimary(currentDmlChild)) {
                removedPrimaries.add(currentDmlChild);
            }
        }
    }

    /**
     * @description When called in a trigger context performs operations to maintain the group
     *              such as unflagging old primary children and adding error messages to invalid operations
     * @author John Rogers, Traction on Demand
     * @date        2016-02-23
     * @param  groups : The groups to maintain. All groups must be of the same child type.
     * @return  The old primary children that are not longer primary to update
     */
    public List<SObject> maintain() {
        List<SObject> recordsToUpdate = new List<SObject>();

        // For each primary that has arrive from another group
        for (SObject child : changedGroupPrimaries) {
            // Unflag it as primary
            SObject newChild = childType.newSObject();
            newChild.Id = child.Id;
            newChild.put(primaryFlag, false);
            recordsToUpdate.add(newChild);
        }

        // Check for > 1 new primary child
        if (newPrimaries.size() > 1) {
            // If found then add errors to primaries and remove
            for (SObject child : newPrimaries) {
                child.addError(multipleNewPrimariesError);
            }
            newPrimaries = new List<SObject>();
        // Check for removal resulting in < 1 primary child
        } else if (newPrimaries.isEmpty() && oldPrimaries.isEmpty() && !removedPrimaries.isEmpty()) {
            // If found then add errors to removed primaries and remove
            for (SObject child : removedPrimaries) {
                child.addError(removeOnlyPrimaryError);
            }    
        // If there is a single new primary then unflag all old primaries
        } else if (newPrimaries.size() == 1) {
            for (SObject oldPrimary : oldPrimaries) {
                // Add to children to ignore list so that group is not revalidated (wastes 1 query)
                childrenToIgnore.add(oldPrimary.Id);

                // Unflag old primary
                oldPrimary.put(primaryFlag, false);
            }
            recordsToUpdate.addAll(oldPrimaries);
        }
        return recordsToUpdate;
    }

    public class ChildHierarchyGroupException extends Exception {} 
}