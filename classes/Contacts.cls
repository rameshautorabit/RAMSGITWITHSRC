/** 
 *  Domain class for Contact object. 
 *  Handles all functionality for its respective object,
 *  deferring complex implementations to helper classes.
 *  @author Ernesto Valdes, Traction On Demand
 *  @updated Zi Zhang, Traction On Demand
 */
public class Contacts extends SObjectDomain {

    // Static variable to store children before thier parent is deleted by merge
    private static List<Customer_Address__c> casBeforeMergeDelete = new List<Customer_Address__c>();
    private static List<Contact_Information__c> cisBeforeMergeDelete = new List<Contact_Information__c>();

    /**
     * ******************************************
     * Get a set of contactIds that are person account contacts
     * Used for excluding person account contacts
     */
    private @testVisible Set<Id> contactIds {
        get {
            if(contactIds == null) {
                contactIds = new Set<Id>();

                for(SObject rec : records) {
                    contactIds.add(rec.Id);
                }
            }

            return contactIds;
        } private set;
    }

    /**
     * Get business contacts, exclude person account contacts
     */
    private @testVisible Set<Id> businessContacts {
        get {
            if(businessContacts == null) {
                businessContacts = new Set<Id>();

                for(Contact c : [SELECT Id FROM Contact WHERE Id IN :contactIds AND Account.IsPersonAccount = false]) {
                    businessContacts.add(c.Id);
                }
            }

            return businessContacts;
        } private set;
    }

    /**
     * Get related accounts for field mapping
     */
    private @testVisible Map<Id, Account> relatedAccounts {
        get {
            if(relatedAccounts == null) {
                Set<Id> accountIds = new Set<Id>();

                for(Contact con : (List<Contact>) records) {
                    accountIds.add(con.AccountId);
                }

                relatedAccounts = new Map<Id, Account>([SELECT Id, Name, X12_Digit_Member__c FROM Account WHERE Id IN :accountIds AND IsPersonAccount = false]);
            }

            return relatedAccounts;
        } private set;
    }

    /**
     * Get related accounts for field mapping
     */
    private @testVisible Map<String, Source_System_View__c> relatedAccountSSVByAccount {
        get {
            if(relatedAccountSSVByAccount == null) {
                relatedAccountSSVByAccount = new Map<String, Source_System_View__c>();
                Set<Id> accountIds = new Set<Id>();

                for(Contact con : (List<Contact>) records) {
                    if (con.AccountId != null) {
                        accountIds.add(con.AccountId);
                    }
                }

                if(accountIds.size() > 0) {
                    List<Source_System_View__c> relatedSSVs = [SELECT Id, Contact__c, Account__c, Contact__r.Account.IsPersonAccount 
                                                               FROM Source_System_View__c 
                                                               WHERE Account__c IN :accountIds AND Source_Table__c = 'Salesforce Account'
                                                               ORDER BY Master_Record_Score__c ASC];
                    MapUtils.mapByField(relatedAccountSSVByAccount, relatedSSVs, Source_System_View__c.Account__c);
                }
            }

            return relatedAccountSSVByAccount;
        } private set;
    }

    /**
     * Custom setting for mapping contact fields to SSV records
     */
    private @testVisible List<Contact_SSV_Field_Mapping__c> contactMapSettings {
        get {
            if(contactMapSettings == null) {
                contactMapSettings = Contact_SSV_Field_Mapping__c.getAll().values();
            }

            return contactMapSettings;
        } private set;
    }

    /**
     * Get all related SSVs associated to triggered contact records
     */
    private @testVisible Map<String, Source_System_View__c> relatedSSVByContact {
        get {
            if(relatedSSVByContact == null) {
                relatedSSVByContact = new Map<String, Source_System_View__c>();

                List<Source_System_View__c> relatedSSVs = [SELECT Id, Contact__c, Contact__r.Account.IsPersonAccount 
                                                            FROM Source_System_View__c 
                                                            WHERE Contact__c IN :records AND Source_Table__c = 'Salesforce Contact'];
                MapUtils.mapByField(relatedSSVByContact, relatedSSVs, Source_System_View__c.Contact__c);
            }

            return relatedSSVByContact;
        } private set;
    }

    /**
     * Get all related Customer_Address__c records associated to triggered contact records
     */
    private @testVisible Map<String, Customer_Address__c> relatedContactCustomerAddress {
        get {
            if(relatedContactCustomerAddress == null) {
                Set<Id> contactIds = new Set<Id>();
                relatedContactCustomerAddress = new Map<String, Customer_Address__c>();

                for(SObject rec : records) {
                    contactIds.add(rec.Id);
                }

                List<Customer_Address__c> customerAddresses = [SELECT Id, Address__c, Contact__c 
                                                               FROM Customer_Address__c 
                                                               WHERE Contact__c IN :contactIds 
                                                                        AND Is_Principal_Address__c = true ];

                MapUtils.mapByField(relatedContactCustomerAddress, customerAddresses, Customer_Address__c.Contact__c);
            }

            return relatedContactCustomerAddress;
        } private set;
    }

    /**
     * @description Create contact information records for the given list of contacts
     * @author John Rogers, Traction on Demand
     * @date        2016-02-24
     * @param       contacts : Contacts to insert
     * @return The new contacts information records
     */
    public static List<Contact_Information__c> createContactInformationRecords(List<Contact> contacts) {
        List<Contact_Information__c> cis = new List<Contact_Information__c>();
    /*    for (Contact c : contacts) {
            // Create email CI
            if (!String.isBlank(c.Email)) {
                cis.add(new Contact_Information__c(
                    Contact__c = c.Id,
                    Is_Primary__c = true,
                    Contact_Information_Medium__c = 'Email',
                    Name = 'Email',
                    Email__c = c.Email,
                    RecordTypeId = ContactInformations.EMAIL_RECORD_TYPE_ID
                ));
                ContactInformations.contactsExcludedFromUpdate.add(c.Id);
            }

            // Create alternate email CI
            if (!String.isBlank(c.Alternate_Email__c)) {
                cis.add(new Contact_Information__c(
                    Contact__c = c.Id,
                    Is_Primary__c = false,
                    Contact_Information_Medium__c = 'Email',
                    Name = 'Email',
                    Email__c = c.Alternate_Email__c,
                    RecordTypeId = ContactInformations.EMAIL_RECORD_TYPE_ID
                ));
            }

            // Create phone CI
            if (!String.isBlank(c.Phone)) {
                cis.add(new Contact_Information__c(
                    Contact__c = c.Id,
                    Is_Primary__c = true,
                    Contact_Information_Medium__c = 'Phone',
                    Name = 'Phone',
                    Phone__c = c.Phone,
                    Phone_Extension__c = String.valueOf(c.Phone_Extension__c),
                    RecordTypeId = ContactInformations.PHONE_RECORD_TYPE_ID
                ));
                ContactInformations.contactsExcludedFromUpdate.add(c.Id);
            }

            // Create mobile CI
            if (!String.isBlank(c.MobilePhone)) {
                cis.add(new Contact_Information__c(
                    Contact__c = c.Id,
                    Is_Primary__c = false,
                    Contact_Information_Medium__c = 'Phone',
                    Contact_Information_Type__c = 'Mobile',
                    Name = 'Mobile',
                    Phone__c = c.MobilePhone,
                    Phone_Extension__c = String.valueOf(c.Phone_Extension__c),
                    RecordTypeId = ContactInformations.PHONE_RECORD_TYPE_ID
                ));
            }

            // Create fax CI
            if (!String.isBlank(c.Fax)) {
                cis.add(new Contact_Information__c(
                    Contact__c = c.Id,
                    Is_Primary__c = true,
                    Contact_Information_Type__c = 'Fax',
                    Name = 'Fax',
                    Phone__c = c.Fax,
                    Phone_Extension__c = String.valueOf(c.Phone_Extension__c),
                    RecordTypeId = ContactInformations.FAX_RECORD_TYPE_ID
                ));
                ContactInformations.contactsExcludedFromUpdate.add(c.Id);
            }
        }
*/
        return cis;
    }

    public override void handleBeforeDelete() {
        deleteSSVs();
    }
    /*
    public override void handleAfterDelete() {
       // for MDM2-78
       Set<Id> masters = new Set<Id>();    
       for(Contact c:(List<Contact>)records){
           if(c.MasterRecordId != null){
              masters.add(c.AccountId);
           }
       }
       if(!masters.isEmpty()){
			List<SObject> recordsToUpdate = new List<SObject>();
			OrderService.processRollups(recordsToUpdate, masters);
			for(SObject record : recordsToUpdate) {
				this.recordsToUpdateMap.put(record.id, record);
			}       	
       }       
    }
*/
    /**
     * Merges don't fire update triggers when children record lookups are
     * updated. This method collects the primary children before the lookups are
     * changed since the children may need to be unflagged.
     * @author John Rogers, Traction on Demand
     * @date        2016-03-08
     */
    public override void handleBeforeMergeDelete() {
        System.debug('records: ' + records);
        // Only need to unflag 
        /*casBeforeMergeDelete.addAll([
            SELECT Contact__c
            FROM Customer_Address__c
            WHERE Contact__c IN :records
                AND Is_Principal_Address__c = true
        ]);
        cisBeforeMergeDelete.addAll([
            SELECT Contact__c
            FROM Contact_Information__c
            WHERE Contact__c IN :records
                AND Is_Primary__c = true
        ]);
        System.debug('merge delete cas: ' + casBeforeMergeDelete);
        System.debug('merge delete cis: ' + cisBeforeMergeDelete);*/
    }

    public override void handleAfterInsert() {
        if (!UserHelper.isIntegrationUser()) {
     //remove       recordsToInsert.addAll((List<SObject>) createContactInformationRecords((List<Contact>) records));
            createSSVs();
        }
    }

    /**
     * Merges don't fire update triggers when children record lookups are
     * updated. This method performs the required logic on the children.
     * @author John Rogers, Traction on Demand
     * @date        2016-03-08
     */
    public override void handleAfterMergeDelete() {
     /*   if (mergeDeletedRecords.isEmpty()) {
            return;
        }

        // TODO-jdr could refactor ChildHierarchyGroup so that it could be called in this context
        Map<Id, List<Customer_Address__c>> contactToCA = MapUtils.mapByIdFieldToList(
                casBeforeMergeDelete, Customer_Address__c.Contact__c);
        Map<Id, List<Contact_Information__c>> contactToCI = MapUtils.mapByIdFieldToList(
                cisBeforeMergeDelete, Contact_Information__c.Contact__c);

        for (Contact c : (List<Contact>) mergeDeletedRecords) {
            List<Customer_Address__c> cas = contactToCA.get(c.Id);
            List<Contact_Information__c> cis = contactToCI.get(c.Id);

            if (cas != null) {
                for (Customer_Address__c ca : cas) {
                    // Need to recreated CA, otherwise update will update the MD lookup!
                    Customer_Address__c caToUpdate = new Customer_Address__c(
                        Id = ca.Id
                    );
                    caToUpdate = (Customer_Address__c) recordToUpdate(caToUpdate);
                    caToUpdate.Is_Principal_Address__c = false;
                    ChildHierarchyGroup.childrenToIgnore.add(caToUpdate.Id);
                }
            }

            if (cis != null) {
                for (Contact_Information__c ci : cis) {
                    // Need to recreated CI, otherwise update will update the MD lookup!
                    Contact_Information__c ciToUpdate = new Contact_Information__c(
                        Id = ci.Id
                    );
                    ciToUpdate = (Contact_Information__c) recordToUpdate(ciToUpdate);
                    ciToUpdate.Is_Primary__c = false;
                    ChildHierarchyGroup.childrenToIgnore.add(ciToUpdate.Id);
                }
            }
        }*/
    }

    /**
     * After Update for Accounts: Upsert SSV records
     * @author Zi Zhang, Traction on Demand
     * @date   2016-02-27
     */
    public override void handleAfterUpdate(Map<Id, SObject> oldMap) {
        updateSSVs(oldMap);
    }

    /**
     * Create new SSV records on insert of Accounts
     * @author Zi Zhang, Traction on Demand
     * @date   2016-02-29
     */
    @testVisible
    private void createSSVs() {
        if (!UserHelper.isIntegrationUser()) {
            for(Contact con : (List<Contact>) records) {
                if(businessContacts.contains(con.Id)) {
                    recordsToInsert.add(SSVLoader.createSSV(con, 
                                                            contactMapSettings, 
                                                            relatedContactCustomerAddress.get(con.Id), 
                                                            relatedAccounts.get(con.AccountId),
                                                            relatedAccountSSVByAccount.get(con.AccountId)));
                }
            }
        }
    }

    /**
     * Create new SSV records on insert of Business Contacts
     * @author Zi Zhang, Traction on Demand
     * @date   2016-02-29
     */
    @testVisible
    private void updateSSVs(Map<Id, SObject> oldMap) {
        if (!UserHelper.isIntegrationUser()) {
            for(Contact con : (List<Contact>) records) {
                if(businessContacts.contains(con.Id) && keyFieldsUpdated(con, oldMap, contactMapSettings) || keyFieldsCustomBusinessContact(con, oldMap)) {
                    if(relatedSSVByContact.get(con.Id) != null) {
                        SSVLoader.updateSSV(con, 
                                            relatedSSVByContact.get(con.Id), 
                                            contactMapSettings, 
                                            relatedContactCustomerAddress.get(con.Id), 
                                            relatedAccounts.get(con.AccountId),
                                            relatedAccountSSVByAccount.get(con.AccountId));
                        
                        recordToUpdate(relatedSSVByContact.get(con.Id));
                    } else {
                        recordsToInsert.add(SSVLoader.createSSV(con, 
                                                                contactMapSettings, 
                                                                relatedContactCustomerAddress.get(con.Id), 
                                                                relatedAccounts.get(con.AccountId),
                                                                relatedAccountSSVByAccount.get(con.AccountId)));
                    }
                } 
            }
        }
    }

    /**
     * Delete SSVs when related Contact record is deleted
     * @author Zi Zhang, Traction on Demand
     * @date   2016-02-29
     */
    @testVisible
    private void deleteSSVs() {
        if (!UserHelper.isIntegrationUser()) {
            recordsToDelete.addAll((List<SObject>) relatedSSVByContact.values());
        }
    }

    /**
     * Returns true if any key fields have been changed.
     * @author Zi Zhang, Traction on Demand
     * @date   2016-02-29
     */
    @testVisible
    private Boolean keyFieldsUpdated(SObject obj, Map<Id, SObject> oldMap, List<SObject> mapSettings) {
        if(oldMap == null || mapSettings == null) {
            return false;
        }

        for(SObject mapField : mapSettings) {
            String fieldName = (String) mapField.get('Source_Field__c');
            // Ignore LastModifiedDate field mapping. Trigger should not fire when this field changes
            if(fieldName == 'LastModifiedDate') {
                continue;
            }

            if(FieldMapper.hasSObjectField(fieldName, obj)) {
                if(obj.get(fieldName) != oldMap.get(obj.Id).get(fieldName)) {
                    return true;
                }
            }
        }

        return false;
    }

    /**
     * Key fields updated for company account not included in the custom setting
     * @author Zi Zhang, Traction on Demand
     * @date   2016-03-02
     */
    private Boolean keyFieldsCustomBusinessContact(SObject obj, Map<Id, SObject> oldMap) {
        if(FieldMapper.hasSObjectField('MailingStreet', obj)) {
            if(obj.get('MailingStreet') != oldMap.get(obj.Id).get('MailingStreet')) {
                return true;
            } 
        }
        
        return false;
    }
}