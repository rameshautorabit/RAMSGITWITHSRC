public class StewardshipRequests {
    // TODO-jdr check if retrieving by label is safe
	public static final Map<String, Schema.RecordTypeInfo> STEWARDSHIP_REQUEST_RECORD_TYPES = Schema.SObjectType.Stewardship_Request__c.getRecordTypeInfosByName();

    public static final Id SSV_RECORD_TYPE_ID = STEWARDSHIP_REQUEST_RECORD_TYPES.get('Source System View Request').getRecordTypeId();

    public static final Id ORDER_RECORD_TYPE_ID = STEWARDSHIP_REQUEST_RECORD_TYPES.get('Order Stewardship Request').getRecordTypeId();

    public static final Id SHIP_TO_RECORD_TYPE_ID = STEWARDSHIP_REQUEST_RECORD_TYPES.get('Ship To Stewardship Request').getRecordTypeId();

}