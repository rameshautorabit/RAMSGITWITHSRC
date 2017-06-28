/**
 * @description A child hierarchy group containing customer address records
 */
public with sharing class CustomerAddressHierarchyGroup extends ChildHierarchyGroupType {
    public static SObjectField PRIMARY_FLAG = Customer_Address__c.Is_Principal_Address__c;
    public static SObjectField LOOKUP_FIELD = Customer_Address__c.Contact__c;
    public static String MULTIPLE_NEW_PRIMARIES_ERROR = 'There can only be one customer address record marked as primary';
    public static String REMOVE_ONLY_PRIMARY_ERROR = 'You cannot remove the only primary customer address record';
    public static SObjectType CHILD_TYPE = Customer_Address__c.getSObjectType();

    public CustomerAddressHierarchyGroup() {
        primaryFlag = PRIMARY_FLAG;
        lookupField = LOOKUP_FIELD;
        multipleNewPrimariesError = MULTIPLE_NEW_PRIMARIES_ERROR;
        removeOnlyPrimaryError = REMOVE_ONLY_PRIMARY_ERROR;
        groupTypeId = CHILD_TYPE.getDescribe().getName();
    }

    /**
     * @author John Rogers, Traction on Demand
     * @date        2016-02-23
     * @param       record : The record to check
     * @return True if the record can be a part of this group type, false otherwise.
     */
    public override Boolean belongsToGroupType(SObject record) {
        return record.getSObjectType() == CHILD_TYPE;
    }
}