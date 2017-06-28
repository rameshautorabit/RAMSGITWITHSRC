public class Addresses extends SObjectDomain {
	
    /**
     * @description On field update, updates contacts related via a primary Customer_Address__c record
     * @author John Rogers, Traction on Demand
     * @date        2016-02-25
     * @param       addrs : The address records
     * @param       oldMap : The pre-update address records
     * @return Modified contact records to update
     */
    public static List<SObject> updateContacts(List<Address__c> addrs, Map<Id, SObject> oldMap) {
    	
    	// do not update contacts based on MDM records once Single Pane goes live
    	
		if (FeatureFlagService.isSinglePaneAddressFeatureActive()) {
			system.debug('Addresses -> updateContacts -> single pane feature enabled');
			return new List<Contact>();
		}
		    	
        // Fields linked to related contacts
        List<SObjectField> linkedFields = new List<SObjectField> {
            Address__c.Address_1__c,
            Address__c.City__c,
            Address__c.Country_Code__c,
            Address__c.State__c,
            Address__c.Zip__c
        };

        // Get all addresses that have been modified in a way that impacts related contacts
        List<Address__c> modifiedAddrs = new List<Address__c>();
        for (Address__c addr : addrs) {
            Address__c oldAddr = (Address__c) oldMap.get(addr.Id);
            for (SObjectField field : linkedFields) {
                if (addr.get(field) != oldAddr.get(field)) {
                    modifiedAddrs.add(addr);
                }
            }
        }

        if (modifiedAddrs.isEmpty()) {
            return new List<Contact>();
        }

        // Retrieve all the address information for the principle addresses
        List<Customer_Address__c> cas = [
            SELECT Contact__c, 
                Address__r.Address_1__c,
                Address__r.City__c,
                Address__r.Country_Code__c,
                Address__r.State__c,
                Address__r.Zip__c,
                Contact__r.Account.IsPersonAccount
            FROM Customer_Address__c
            WHERE Address__c IN :modifiedAddrs
                AND Address__c != NULL
                AND Is_Principal_Address__c = true
        ];

        Map<Id, SObject> contactsToUpdate = new Map<Id, SObject>();
        for (Customer_Address__c ca : cas) {
            contactsToUpdate.put(ca.Contact__c, new Contact(
                Id = ca.Contact__c,
                MailingStreet = ca.Address__r.Address_1__c,
                MailingCity = ca.Address__r.City__c,
                MailingCountry = ca.Address__r.Country_Code__c,
                MailingState = ca.Address__r.State__c,
                MailingPostalCode = ca.Address__r.Zip__c
            ));
            
            if (ca.Contact__r.Account.IsPersonAccount) {
            	// updated customer address is associated with a person account. update the billing address of the account as well as the contact mailing address
            	contactsToUpdate.put(ca.Contact__r.AccountId, new Account(
            		Id = ca.Contact__r.AccountId,
					BillingStreet = ca.Address__r.Address_1__c,
					BillingCity = ca.Address__r.City__c,
					BillingState = ca.Address__r.State__c,
					BillingPostalCode = ca.Address__r.Zip__c,
					BillingCountry = ca.Address__r.Country_Code__c		            		
            	));
    		}
    		            
        }
        return contactsToUpdate.values();
    }

    /**
     * @description Sets the Address_Match_Key__c and Address_Match_Key_Hash__c field on the given address records
     * @author John Rogers, Traction on Demand
     * @date        2016-02-24
     * @param       addrs : The address records
     */
    public static void setMatchKey(List<Address__c> addrs) {
        for (Address__c addr : addrs) {
            addr.Address_Match_Key__c = SSVCleaner.buildAddressMatchKey(addr);
            addr.Address_Match_Key_Hash__c = SSVCleaner.encodeHash(addr.Address_Match_Key__c);
        }
    }

    public override void handleBeforeInsert() {
        setMatchKey((List<Address__c>) records);
    }

    public override void handleBeforeUpdate(Map<Id, SObject> oldRecordMap) {
        setMatchKey((List<Address__c>) records);
    }

    public override void handleAfterUpdate(Map<Id, SObject> oldMap) {
        recordsToUpdate(updateContacts(records, oldMap));
    }
}