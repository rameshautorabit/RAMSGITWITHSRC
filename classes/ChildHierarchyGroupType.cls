/**
 * A type of child hierarchy group
 */
public abstract class ChildHierarchyGroupType {

    // The flag field that marks the children as primary
    public SObjectField primaryFlag;

    // The field that connects the parents and children
    public SObjectField lookupField;

    // Error message displayed when more than one child in a group is marked as primary
    public String multipleNewPrimariesError;

    // Error message displayed when the only primary child in a group is removed
    public String removeOnlyPrimaryError;

    // The ID for this particular group type
    public String groupTypeId;

    // Additional fields that need to be queried when children are added to the group
    public List<String> additionalRequiredFields = new List<String>();

    // The type of the parent record
    public SObjectType parentType {
        get {
            DescribeFieldResult fieldDescribe = lookupField.getDescribe();
            List<SObjectType> objs = fieldDescribe.getReferenceTo();
            return objs[0];
        }
        set;
    }

    // The type of the child record
    public SObjectType childType {
        get {
            if (childType == null) {
                return childRelationship.getChildSObject();
            }
            return childType;
        }
    }

    // The parent-child relationship 
    public ChildRelationship childRelationship {
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
    }

    /**
     * @author John Rogers, Traction on Demand
     * @date        2016-02-23
     * @param       record : The record to check
     * @return True if the record can be a part of this group type, false otherwise.
     */
    public abstract Boolean belongsToGroupType(SObject record);

    /**
     * @author John Rogers, Traction on Demand
     * @date        2016-02-23
     * @param       record : The record to check
     * @return True if the given record is a primary child of this group type.
     */
    public Boolean checkIsPrimary(SObject record) {
        Type ci = Type.forName('Contact_Information__c');
        SObject obj = (Sobject)ci.newInstance();
        SObjectType ciType = obj.getSObjectType();
        if (record.getSObjectType() == ciType)
            return false;
        else
            return (Boolean) record.get(primaryFlag) && belongsToGroupType(record);
    }

    /**
     * @author John Rogers, Traction on Demand
     * @date        2016-02-23
     * @param       record : The record to get the group ID for
     * @return The ID of the Child Hierarchy Group that this child belongs to
     */
    public String getGroupId(SObject record) {
        return getGroupId((Id) record.get(lookupField));
    }


    /**
     * @author John Rogers, Traction on Demand
     * @date        2016-02-23
     * @param       record : The record to get the group ID for
     * @return The ID of the Child Hierarchy Group of this type under the given parent
     */
    public String getGroupId(Id parentId) {
        return String.valueOf(parentId) + groupTypeId;
    }
}