/**
 * Customer Reconciliation Process
 * Accounts trigger - Upsert SSV records
 * @author Zi Zhang, Traction on Demand
 * @date   2016-02-27
 */
public class Accounts extends SObjectDomain {

    public static final Map<String, Schema.RecordTypeInfo> ACCOUNT_RECORD_TYPES = Schema.SObjectType.Account.getRecordTypeInfosByName();
    
    public static final Id CONTRACT_RECORD_TYPE_ID = ACCOUNT_RECORD_TYPES.get('Contract').getRecordTypeId();

    public static final Id TRADE_RECORD_TYPE_ID = ACCOUNT_RECORD_TYPES.get('Trade').getRecordTypeId();
            
    // Static variable to store children before thier parent is deleted by merge
    private static Contacts childrenContacts = new Contacts();

    private @testVisible List<Company_Account_SSV_Field_Mapping__c> companyMapSettings {
        get {
            if(companyMapSettings == null) {
                companyMapSettings = Company_Account_SSV_Field_Mapping__c.getAll().values();
            }

            return companyMapSettings;
        } private set;
    }

    private @testVisible List<Person_Account_SSV_Field_Mapping__c> personMapSettings {
        get {
            if(personMapSettings == null) {
                personMapSettings = Person_Account_SSV_Field_Mapping__c.getAll().values();
            }

            return personMapSettings;
        } private set;
    }

    private @testVisible Map<String, Source_System_View__c> relatedSSVByAccount {
        get {
            if(relatedSSVByAccount == null) {
                relatedSSVByAccount = new Map<String, Source_System_View__c>();

                List<Source_System_View__c> relatedSSVs = [SELECT Id, Account__c 
                                                            FROM Source_System_View__c 
                                                            WHERE Account__c IN :records AND 
                                                                (Source_Table__c = 'Salesforce Account' OR Source_Table__c = 'Salesforce Person Account')];
                MapUtils.mapByField(relatedSSVByAccount, relatedSSVs, Source_System_View__c.Account__c);
            }

            return relatedSSVByAccount;
        } private set;
    }

    private @testVisible Map<String, Customer_Address__c> relatedContactCustomerAddress {
        get {
            if(relatedContactCustomerAddress == null) {
                Set<Id> contactIds = new Set<Id>();
                relatedContactCustomerAddress = new Map<String, Customer_Address__c>();

                for(Account rec : (List<Account>) records) {
                    if(String.isNotEmpty(rec.PersonContactId)) {
                        contactIds.add(rec.PersonContactId);
                    }
                }

                List<Customer_Address__c> customerAddresses = [SELECT Id, Address__c, Contact__c 
                                                               FROM Customer_Address__c 
                                                               WHERE Contact__c IN :contactIds 
                                                                        AND Is_Principal_Address__c = true];

                MapUtils.mapByField(relatedContactCustomerAddress, customerAddresses, Customer_Address__c.Contact__c);
            }

            return relatedContactCustomerAddress;
        } private set;
    }

    /**
     * Given a list of accounts, set the X12_Digit_Member__c field if the account
     * is of the correct record type and has no current X12_Digit_Member__c
     * @author John Rogers, Traction on Demand
     * @date        2016-03-15
     * @param       accs : The accounts 
     */
    public static void setMemberNumbers(List<Account> accs) {
        
        System.debug('processing accs: ' + accs);
        List<Account> needsMemberNumber = new List<Account>();
            
        for (Account a : accs) {                            
            if ((a.RecordTypeId == CONTRACT_RECORD_TYPE_ID || a.RecordTypeId == TRADE_RECORD_TYPE_ID) && String.isBlank(a.X12_Digit_Member__c)) {
                needsMemberNumber.add(a);
            }           
        }
        
        System.debug('setting mem num on accs: ' + needsMemberNumber.size());
        
        if (needsMemberNumber.isEmpty()) {
            return;
        }

        // Create Membership_Number_Sequence_Reference__c records to get member numbers
        List<Membership_Number_Sequence_Reference__c> memNums = new List<Membership_Number_Sequence_Reference__c>();
                
        for (Account a : needsMemberNumber) {
            memNums.add(new Membership_Number_Sequence_Reference__c());
        }
        insert memNums;
        
        // Get the member numbers
        memNums = [SELECT X12_Digit_Member__c FROM Membership_Number_Sequence_Reference__c WHERE Id IN :memNums];
        System.debug('created mem numbers: ' + memNums);

        // Assign the member numbers
        for (Integer i = 0; i < memNums.size(); i++) {                       
            needsMemberNumber[i].X12_Digit_Member__c = memNums[i].X12_Digit_Member__c;
        }
            
        // Delete the used member numbers
        delete memNums;
    
    }

    public override void handleBeforeInsert() {
        setMemberNumbers((List<Account>) records);
    }

    public override void handleBeforeUpdate(Map<Id, SObject> oldRecordMap) {
        setMemberNumbers((List<Account>) records);
    }

    /**
     * Before delete for deleted Accounts which includes losers during a merge
     * Trigger will remove all child SSVs related to Accounts being deleted
     * @author Zi Zhang, Traction on Demand
     * @date   2016-02-29
     */
    public override void handleBeforeDelete() {
        deleteSSVs();
    }

    /**
     * Merges don't fire delete triggers when children records are
     * deleted/updated. This method performs the required logic on the children.
     * @author John Rogers, Traction on Demand
     * @date        2016-03-08
     */
    public override void handleBeforeMergeDelete() {
        // Collect the contacts that will be deleted
        childrenContacts.records = [
            SELECT Id 
            FROM Contact 
            WHERE AccountId IN :records AND Account.IsPersonAccount = true
        ];
        // TODO-jdr TODO-zz does beforeDelete() also need to be called?
        childrenContacts.handleBeforeMergeDelete();
    }
    /*
    public override void handleAfterDelete() {
       // for MDM2-78
       Set<Id> masters = new Set<Id>();    
       for(Account a:(List<Account>)records){
           if(a.MasterRecordId != null){
              masters.add(a.MasterRecordId);
           }
       }
       if(!masters.isEmpty()){
			List<SObject> recordsToUpdate = new List<SObject>();
			OrderService.processRollups(recordsToUpdate, masters);
			for(SObject record : recordsToUpdate) {
				this.recordsToUpdateMap.put(record.id, record);
			}
       }
    }   */     

    /**
     * After Update for Accounts: Upsert SSV records
     * @author Zi Zhang, Traction on Demand
     * @date   2016-02-27
     */
    public override void handleAfterUpdate(Map<Id, SObject> oldMap) {
        updateSSVs(oldMap);
    }

    /**
     * After Insert for Accounts: Upsert SSV records
     * @author Zi Zhang, Traction on Demand
     * @date   2016-02-27
     */
    public override void handleAfterInsert() {
        createSSVs();
    }

    /**
     * Create new SSV records on insert of Accounts
     * @author Zi Zhang, Traction on Demand
     * @date   2016-02-29
     */
    @testVisible
    private void createSSVs() {
        if (!UserHelper.isIntegrationUser()) {
            for(Account acc : (List<Account>) records) {
                if(acc.IsPersonAccount) {
                    recordsToInsert.add(SSVLoader.createSSV(acc, personMapSettings, relatedContactCustomerAddress.get(acc.PersonContactId)));
                   // CusContactInfoAndCusAddress.CusContactInfoAndCusAddress(acc,true);
                    
                } else {
                    recordsToInsert.add(SSVLoader.createSSV(acc, companyMapSettings, null));
                }
            }
        }
    }

    /**
     * Create new SSV records on insert of Accounts
     * @author Zi Zhang, Traction on Demand
     * @date   2016-02-29
     */
    @testVisible
    private void updateSSVs(Map<Id, SObject> oldMap) {
        if (!UserHelper.isIntegrationUser()) {
            for(Account acc : (List<Account>) records) {
                if(acc.IsPersonAccount && keyFieldsUpdated(acc, oldMap, personMapSettings) || keyFieldsCustomPersonAccount(acc, oldMap)) {
                    // todo-zz put if else into method maybe?
                    if(relatedSSVByAccount.get(acc.Id) != null) {
                        SSVLoader.updateSSV(acc, relatedSSVByAccount.get(acc.Id), personMapSettings, relatedContactCustomerAddress.get(acc.PersonContactId));
                        recordToUpdate(relatedSSVByAccount.get(acc.Id));
                    } else {
                        recordsToInsert.add(SSVLoader.createSSV(acc, personMapSettings, relatedContactCustomerAddress.get(acc.PersonContactId)));
                    }
                } else if(!acc.IsPersonAccount && keyFieldsUpdated(acc, oldMap, companyMapSettings) || keyFieldsCustomCompanyAccount(acc, oldMap)) {
                    if(relatedSSVByAccount.get(acc.Id) != null) {
                        SSVLoader.updateSSV(acc, relatedSSVByAccount.get(acc.Id), companyMapSettings, null);
                        recordToUpdate(relatedSSVByAccount.get(acc.Id));
                    } else {
                        recordsToInsert.add(SSVLoader.createSSV(acc, companyMapSettings, null));
                    }
                }
            }
        }
    }

    /**
     * Create new SSV records on insert of Accounts
     * @author Zi Zhang, Traction on Demand
     * @date   2016-02-29
     */
    @testVisible
    private void deleteSSVs() {
        if (!UserHelper.isIntegrationUser()) {
            recordsToDelete.addAll((List<SObject>) relatedSSVByAccount.values());
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
    private Boolean keyFieldsCustomCompanyAccount(SObject obj, Map<Id, SObject> oldMap) {
        if(FieldMapper.hasSObjectField('BillingStreet', obj)) {
            if(obj.get('BillingStreet') != oldMap.get(obj.Id).get('BillingStreet')) {
                return true;
            } 
        }
        
        return false;
    }

    /**
     * Key fields updated for person account not included in the custom setting
     * @author Zi Zhang, Traction on Demand
     * @date   2016-03-02
     */
    private Boolean keyFieldsCustomPersonAccount(SObject obj, Map<Id, SObject> oldMap) {
        if(FieldMapper.hasSObjectField('PersonMailingStreet', obj)) {
            if(obj.get('PersonMailingStreet') != oldMap.get(obj.Id).get('PersonMailingStreet')) {
                return true;
            }
        }

        return false;
    }
}