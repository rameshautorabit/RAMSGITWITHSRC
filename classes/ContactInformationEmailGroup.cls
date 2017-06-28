/**
 * @description A child hierarchy group containing contact information records of 'email' record type
 */
public class ContactInformationEmailGroup extends ChildHierarchyGroupType {
    public static SObjectField PRIMARY_FLAG = Contact_Information__c.Is_Primary__c;
    public static SObjectField LOOKUP_FIELD = Contact_Information__c.Contact__c;
    public static String MULTIPLE_NEW_PRIMARIES_ERROR = 'There can only be one email contact information record marked as primary';
    public static String REMOVE_ONLY_PRIMARY_ERROR = 'You cannot remove the only primary email contact information record';
    public static List<String> ADDITIONAL_REQUIRED_FIELDS = new List<String> {'RecordTypeId'};

    public ContactInformationEmailGroup() {
        primaryFlag = PRIMARY_FLAG;
        lookupField = LOOKUP_FIELD;
        multipleNewPrimariesError = MULTIPLE_NEW_PRIMARIES_ERROR;
        removeOnlyPrimaryError = REMOVE_ONLY_PRIMARY_ERROR;
        groupTypeId = ContactInformations.EMAIL_RECORD_TYPE_ID;
        additionalRequiredFields = ADDITIONAL_REQUIRED_FIELDS;
    }
    
    /**
     * @author John Rogers, Traction on Demand
     * @date        2016-02-23
     * @param       record : The record to check
     * @return True if the record can be a part of this group type, false otherwise.
     */
    public override Boolean belongsToGroupType(SObject record) {
        return record.get('RecordTypeId') == ContactInformations.EMAIL_RECORD_TYPE_ID;
    }
}