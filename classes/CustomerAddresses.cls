/**
 * @description Domain class for Customer_Address__c object. 
 *  Handles all functionality for its respective object,
 *  deferring complex implementations to helper classes.
 * @author John Rogers, Traction on Demand
 * @date 17-02-2016
 */
public class CustomerAddresses extends SObjectDomain {

    public static List<ChildHierarchyGroupType> CHG_TYPES = new List<ChildHierarchyGroupType> {
        new CustomerAddressHierarchyGroup()
    };

    /**
     * @description Update the parent contact with the information contained in the contact's principle CA record (if update is needed)
     * @author John Rogers, Traction on Demand
     * @date        2016-02-25
     * @param       cas : The customer address records that may trigger an update to thier parent contact
     * @return The updated parent contacts
     */
    private static List<SObject> updateContacts(List<Customer_Address__c> cas) {
    	
    	// do not update contacts based on MDM records once Single Pane goes live
    	
		if (FeatureFlagService.isSinglePaneAddressFeatureActive()) {
			system.debug('CustomerAddresses -> updateContacts -> single pane feature enabled');
			return new List<Contact>();
		}    	

        // Collect customer address records that are new principle addresses
        // Only do this if the customer address has a valid related address
        
        List<Customer_Address__c> newPrinciples = new List<Customer_Address__c>();
        for(Customer_Address__c ca : cas) {
        	if (ca.Address__c != NULL) {
	            if (Trigger.isInsert && ca.Is_Principal_Address__c) {
	                newPrinciples.add(ca);
	            } else if (Trigger.isUpdate) {
	                Customer_Address__c oldCa = (Customer_Address__c) Trigger.oldMap.get(ca.Id);
	                if (ca.Is_Principal_Address__c && !oldCa.Is_Principal_Address__c) {
	                    newPrinciples.add(ca);
	                }
	            }
        	}
        }

        if (newPrinciples.isEmpty()) {
            return new List<Contact>();
        }

        // Retrieve all the address information for the principle addresses
        // Also retrieve the contact mailing details (does this slow it down?)
        
        newPrinciples = [
            SELECT Contact__c, 
            
                Contact__r.MailingStreet,
                Contact__r.MailingCity,
                Contact__r.MailingCountry,
                Contact__r.MailingState,
                Contact__r.MailingPostalCode,   
                Contact__r.AccountId,
                Contact__r.Account.IsPersonAccount,         
            
                Address__r.Address_1__c,
                Address__r.City__c,
                Address__r.Country_Code__c,
                Address__r.State__c,
                Address__r.Zip__c
                
            FROM Customer_Address__c
            WHERE Id IN :newPrinciples
        ];
        
        // Update the parent contact mailing address with the details from the primary
        // address, but only if the details are currently different.

        Map<Id, SObject> contactsToUpdate = new Map<Id, SObject>();
        for (Customer_Address__c ca : newPrinciples) {
        	
        	if (!contactsToUpdate.containsKey(ca.Contact__c)) {
        		
				if (ca.Contact__r.MailingStreet != ca.Address__r.Address_1__c ||
	                ca.Contact__r.MailingCity != ca.Address__r.City__c ||
	                ca.Contact__r.MailingCountry != ca.Address__r.Country_Code__c ||
	                ca.Contact__r.MailingState != ca.Address__r.State__c ||
	                ca.Contact__r.MailingPostalCode != ca.Address__r.Zip__c
				) {       
					
					// updated customer address has address details different to the existing contact mailing address. update the contact mailing address to match customer address associated address details 	        	
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
        	}
        }
        
        // return all the contacts to update
        
        return contactsToUpdate.values();
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