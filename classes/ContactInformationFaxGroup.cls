/**
 * @description A child hierarchy group containing contact information records of 'Fax' record type
 */
public class ContactInformationFaxGroup extends ChildHierarchyGroupType {
    public static SObjectField PRIMARY_FLAG = Contact_Information__c.Is_Primary__c;
    public static SObjectField LOOKUP_FIELD = Contact_Information__c.Contact__c;
    public static String MULTIPLE_NEW_PRIMARIES_ERROR = 'There can only be one fax contact information record marked as primary';
    public static String REMOVE_ONLY_PRIMARY_ERROR = 'You cannot remove the only fax phone contact information record';
    public static List<String> ADDITIONAL_REQUIRED_FIELDS = new List<String> {
        Contact_Information__c.RecordTypeId.getDescribe().getName(), 
        Contact_Information__c.Contact_Information_Type__c.getDescribe().getName()
    };

    public ContactInformationFaxGroup() {
        primaryFlag = PRIMARY_FLAG;
        lookupField = LOOKUP_FIELD;
        multipleNewPrimariesError = MULTIPLE_NEW_PRIMARIES_ERROR;
        removeOnlyPrimaryError = REMOVE_ONLY_PRIMARY_ERROR;
        groupTypeId = ContactInformations.FAX_RECORD_TYPE_ID;
        additionalRequiredFields = ADDITIONAL_REQUIRED_FIELDS;
    }
    
    /**
     * @author John Rogers, Traction on Demand
     * @date        2016-02-23
     * @param       record : The record to check
     * @return True if the record can be a part of this group type, false otherwise.
     */
    public override Boolean belongsToGroupType(SObject record) {
        return record.get(Contact_Information__c.RecordTypeId) == ContactInformations.FAX_RECORD_TYPE_ID;
    }
}