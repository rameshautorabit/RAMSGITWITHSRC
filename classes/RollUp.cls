/**
 * @description A roll up operation.
 * @author John Rogers, Traction on Demand
 * @date 2016-02-09
 * @see traction utilities library for more complete version
 */
public virtual class RollUp {

    public enum RollUpType {
        SUM,
        COUNT,
        MIN,
        MAX
    }

    // The type of roll up operation to preform
    public RollUpType ruType;

    // The field that relates the parent and the children
    public SObjectField lookupField;

    // The child roll up field
    public SObjectField childField;

    // The parent roll up field
    public SObjectField parentField;

    // The IDs of the parents to update
    public Set<Id> parentIds = new Set<Id>();

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

    // The 'where' clause that describes the roll up criteria
    public String rollUpCriteriaClause;

    /**
     * @description Prepares the roll up for serialzation by nullifying non-serializable properties
     * @author John Rogers, Traction on Demand
     * @date 2016-02-11
     */
    public void prepForSerialization() {
        childRelationship = null;
    }

    public class RollUpException extends Exception { }
}