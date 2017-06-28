/**
 * @description Domain class for Contact_Information__c object. 
 *  Handles all functionality for its respective object,
 *  deferring complex implementations to helper classes.
 * @author John Rogers, Traction on Demand
 * @date 17-02-2016
 */
public class ContactInformations extends SObjectDomain {

    public static final Map<String, Schema.RecordTypeInfo> CONTACT_INFO_RECORD_TYPES = Schema.SObjectType.Contact_Information__c.getRecordTypeInfosByName();

    public static final Id EMAIL_RECORD_TYPE_ID = CONTACT_INFO_RECORD_TYPES.get('Email').getRecordTypeId();

    public static final Id PHONE_RECORD_TYPE_ID = CONTACT_INFO_RECORD_TYPES.get('Phone').getRecordTypeId();

    public static final Id FAX_RECORD_TYPE_ID = CONTACT_INFO_RECORD_TYPES.get('Fax').getRecordTypeId();

    public static final List<ChildHierarchyGroupType> CHG_TYPES = new List<ChildHierarchyGroupType> {
        new ContactInformationEmailGroup(),
        new ContactInformationPhoneGroup(),
        new ContactInformationFaxGroup()
    };

    // Any contacts in this list will not be updated on insertion of a primary contact information record
    public static Set<Id> contactsExcludedFromUpdate = new Set<Id>();

    /**
     * @description Sets the Contact_Information_Match_Key__c and Contact_Information_Match_Key_Hash__c fields on the given CI records
     * @author John Rogers, Traction on Demand
     * @date        2016-02-24
     * @param       cis : The contact information records
     */
    public static void setMatchKey(List<Contact_Information__c> cis) {
        for (Contact_Information__c ci : cis) {
            ci.Contact_Information_Match_Key__c = ci.Contact__c + 
                    ci.Contact_Information_Medium__c + 
                    ci.Email__c +
                    SSVCleaner.cleansePhone(ci.Phone__c);
                                        
            ci.Contact_Information_Match_Key_Hash__c = SSVCleaner.encodeHash(ci.Contact_Information_Match_Key__c);
        }
    }

    /**
     * @description Update the parent contact with the information contained in the contact's primary CI records (if update is needed)
     * @author John Rogers, Traction on Demand
     * @date        2016-02-25
     * @param       cis : The customer information records that may trigger an update to thier parent contact
     * @return The updated parent contacts
     */
    private static List<Contact> updateContacts(List<Contact_Information__c> cis) {
    	
    	// do not update contacts based on MDM records once Single Pane goes live
    	
		if (FeatureFlagService.isSinglePaneAddressFeatureActive()) {
			system.debug('ContactInformations -> updateContacts -> single pane feature enabled');
			return new List<Contact>();
		}
		    	
        Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
        System.debug('cis: ' + cis);

        // If CI is primary then corresponding contact should have the same field values as CI
        for(Contact_Information__c ci : cis) {
            // Skip CI if not primary, or contact should not be updated
            if (!ci.Is_Primary__c || 
                    (Trigger.isInsert && contactsExcludedFromUpdate.contains(ci.Contact__c))) {
                continue;
            }

            Contact_Information__c oldCi;
            if (Trigger.isUpdate) {
                oldCi = (Contact_Information__c) Trigger.oldMap.get(ci.Id);
            }

            Contact c = contactsToUpdate.get(ci.Contact__c);
            if (c == null) {
                c = new Contact(Id = ci.Contact__c);
            }
            // If insert of primary OR update to new primary OR update to old primary
            if (ci.RecordTypeId == PHONE_RECORD_TYPE_ID && ci.Contact_Information_Type__c != 'Fax' && (
                    (Trigger.isInsert) ||
                    (Trigger.isUpdate && ci.Is_Primary__c && !oldCi.Is_Primary__c) ||
                    (Trigger.isUpdate && (ci.Phone__c != oldCi.Phone__c || ci.Phone_Extension__c != oldCi.Phone_Extension__c)))) {
                c.Phone = ci.Phone__c;
                if (ci.Phone_Extension__c != null) {
                    c.Phone_Extension__c = Double.valueOf(ci.Phone_Extension__c);
                }
                contactsToUpdate.put(c.Id, c); 
            // If insert of primary OR update to new primary OR update to old primary
            } else if (ci.RecordTypeId == EMAIL_RECORD_TYPE_ID && (
                    (Trigger.isInsert) ||
                    (Trigger.isUpdate && ci.Is_Primary__c && !oldCi.Is_Primary__c) || 
                    (Trigger.isUpdate && ci.Email__c != oldCi.Email__c))) {
                c.Email = ci.Email__c;
                contactsToUpdate.put(c.Id, c); 
            // If insert of primary OR update to new primary OR update to old primary
            } else if (ci.RecordTypeId == FAX_RECORD_TYPE_ID && (
                    (Trigger.isInsert) ||
                    (Trigger.isUpdate && ci.Is_Primary__c && !oldCi.Is_Primary__c) || 
                    (Trigger.isUpdate && ci.Phone__c != oldCi.Phone__c))) {
                c.Fax = ci.Phone__c;
                contactsToUpdate.put(c.Id, c); 
            }
        }

        return contactsToUpdate.values();
    }

    public override void handleBeforeInsert() {
        setMatchKey((List<Contact_Information__c>) records);
    }

    public override void handleBeforeUpdate(Map<Id, SObject> oldRecordMap) {
        setMatchKey((List<Contact_Information__c>) records);
    }

    public override void handleAfterInsert() {    	
	    recordsToUpdate(ChildHierarchyGroup.maintainGroups(records, CHG_TYPES));
	    if (!UserHelper.isIntegrationUser()) {
	        recordsToUpdate((List<SObject>) updateContacts(records));
    	}
    }

    public override void handleAfterUpdate(Map<Id, SObject> oldMap) {    	
        recordsToUpdate(ChildHierarchyGroup.maintainGroups(records, CHG_TYPES));
        if (!UserHelper.isIntegrationUser()) {
	        recordsToUpdate((List<SObject>) updateContacts(records));
    	}
    }

    public override void handleAfterDelete() {
        recordsToUpdate(ChildHierarchyGroup.maintainGroups(records, CHG_TYPES));
    }
}