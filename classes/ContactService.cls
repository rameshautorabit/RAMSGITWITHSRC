public with sharing class ContactService {

	private @testvisible static SObjectField[] orderProperties = new List<SObjectField>{
		Rh_Order__c.ATG_Account_ID__c, Rh_Order__c.Membership_ID_Lookup__c, Rh_Order__c.Trade_ID__c, Rh_Order__c.Contact_Sold_To__c, Rh_Order__c.Address_Sold_To__c
	};
	
	private @testvisible static Set<SObjectField> contactAddressFields = new Set<SObjectField> {
		Contact.FirstName, Contact.LastName, Contact.MailingStreet, Contact.MailingCity, Contact.MailingState, Contact.Email, Contact.Phone
	};
	
	private static Set<String> convertObjectSet(Set<Object> properties) {
		Set<String> ids = new Set<String>();
        for (Object obj : properties) {
            ids.add((String)obj);
        }		
        return ids;			
	}	

	/*
	 * Parameters: field name, list of values for that field
	 * Return: A single SObject that has a field of that name with that value, in a map keyed by that field value 
	 */
	
	private @testvisible static Map<Object, List<SObject>> getMatching(SObjectField field, Set<Object> properties) {
		Map<Object, List<SObject>> results = null;
		if (properties == null || properties.size() < 1) {
			system.debug('getMatching: no properties');
		} else if (field == Rh_Order__c.ATG_Account_ID__c) {
			system.debug('getMatching: ATG ID not yet implemented'); // [SELECT Contact__c FROM ATG__c WHERE ID IN :properties];
		} else if (field == Rh_Order__c.Membership_ID_Lookup__c) {
            Set<String> ids = convertObjectSet(properties);
			// results = new Map<Object, Membership__c>([SELECT ID, Contact__c FROM Membership__c WHERE ID IN :ids]);
			results = Utility.mapByProperty(Membership__c.Id, [SELECT ID, Contact__c FROM Membership__c WHERE ID IN :ids]);
		} else if (field == Rh_Order__c.Trade_ID__c) {
			system.debug('getMatching: match on trade ID');
			Set<String> tradeIds = convertObjectSet(properties);
			results = Utility.mapByProperty(Account.X12_Digit_Member__c, [SELECT ID, X12_Digit_Member__c FROM Account WHERE X12_Digit_Member__c IN :tradeIds]);
			system.debug('getMatching: find list of matching: ' + results);
		} else if (field == Rh_Order__c.Contact_Sold_To__c) {
			Set<String> ids = convertObjectSet(properties);
			results = Utility.mapByProperty(Contact.Id, [SELECT ID FROM CONTACT WHERE ID IN :ids]);
		} else if (field == Rh_Order__c.Address_Sold_To__c) {
			Set<String> ids = convertObjectSet(properties);
			results = Utility.mapByProperty(Contact_Address__c.Id, [SELECT ID, Contact__c FROM Contact_Address__c WHERE ID IN :ids]);
		}
		
		system.debug('getMatching: ' + results);
		return results;		
	}
	
	/*
	 * Parameters field name, order to link, reference object containing a link to the customer to link to order
	 * Return: the order linked to the customer
	 */
	
	private @testVisible static Rh_Order__c linkOrder(SObjectField field, Rh_Order__c order, SObject reference) {
		if (field == Rh_Order__c.ATG_Account_ID__c) {
			system.debug('linkOrders: ATG not yet implemented'); 
		} else if (field == Rh_Order__c.Membership_ID_Lookup__c) {
			order.Contact_Sold_To__c = ((Membership__c)reference).Contact__c;
		} else if (field == Rh_Order__c.Trade_ID__c) {
			system.debug('linkOrders: ' + order.Account_Sold_To__c + ' : ' + ((Account)reference).Id);
			order.Account_Sold_To__c = ((Account)reference).Id;
		} else if (field == Rh_Order__c.Contact_Sold_To__c) {
			order.Contact_Sold_To__c = ((Contact)reference).Id;
		} else if (field == Rh_Order__c.Address_Sold_To__c) {
			order.Contact_Sold_To__c = ((Contact_Address__c)reference).Contact__c;
		}
		return order;
	}		
	
	/*
	 * Parameters: A list of orders
	 * Return: nothing - each order in the parameter list is associated with either an account or contact if matching one is found.
	 */
	
	public static void mapOrders(List<Rh_Order__c> orders) {
		
		system.debug('mapOrders -> start');
		
		Set<Rh_Order__c> orderOutstandingSet = new Set<Rh_Order__c>();		
		for (Rh_Order__c order : orders) {
			system.debug('mapOrders -> build distinct list of orders');
			orderOutstandingSet.add(order);
		}
		
		for (SObjectField orderProperty : orderProperties) {
			
			system.debug('mapOrders -> orderProperty -> ' + orderProperty);
			
			// extract order properties
			
			Map<Object, List<Rh_Order__c>> orderMap = Utility.mapByProperty(orderProperty, new List<Rh_Order__c>(orderOutstandingSet) );
			system.debug('mapOrders -> orderMap -> ' + orderMap);
			
			// get all the contacts that match
			
			Map<Object, List<SObject>> matching = getMatching(orderProperty, orderMap.keySet());
			system.debug('mapOrders -> matching -> ' + matching);
			
			// join the two
			
			if (matching != null) {
				for(Object propertyValue : matching.keySet()) {
					for (RH_Order__c order : orderMap.get(propertyValue)) {
						system.debug('mapOrders -> linking -> ' + order + ' => ' + matching.get(propertyValue).get(0));
						linkOrder(orderProperty, order, matching.get(propertyValue).get(0));
						orderOutstandingSet.remove(order);
					}
				}
			}			
		}
	}
	
	/*
	 * Handle insert or updated Contact
	 */

	public static void handleInsertedUpdatedContact(List<Contact> contacts, Map<ID, Contact> oldMap) {
		
		system.debug('ContactService -> handleInsertedUpdatedContact');
		
		// Handle contacts where the address records have changed
		
		if (!FeatureFlagService.isSinglePaneAddressFeatureActive()) {
			system.debug('ContactService -> handleInsertedUpdatedContact -> single pane feature disabled');
			return;
		}
		
		Map<Id, Contact> contactsChanged = new Map<Id, Contact>();
		for (Contact contact : contacts) {
			if (oldMap == null || Utility.hasChanges(contact, oldMap.get(contact.ID), contactAddressFields)) {
				system.debug('ContactService -> handleInsertedUpdatedContact -> contact changed -> ' + contact);
				contactsChanged.put(contact.Id, contact);
			} 			
		}
		
	 	if (Utility.isNotEmpty(contactsChanged.values())) {
	 		system.debug('ContactService -> handleInsertedUpdatedContact -> build address for contact');
			Utility.logInsert(ContactAddressService.buildAddressForContacts(contactsChanged));
	 	}
	}	
	
	

	/* 
	 * Handle deletes
	 * Merging a contact will not fire an update trigger on the effected child objects (Contact_Address__c)
	 * So update the contact address records here.  
	 */
	 
	public static void handleAfterDeleteContact(List<Contact> contacts) {
		
		system.debug('ContactService -> handleAfterDeleteContact -> ' + contacts);
		
		
		Set<ID> winningContacts = new Set<ID>();
		for (Contact deletedContact : contacts) {
			if (deletedContact.masterRecordId != null) {
				winningContacts.add(deletedContact.masterRecordId);
			}
		}
		
		if (winningContacts.isEmpty()) {
			return;
		}
		
		system.debug('ContactService -> handleAfterDeleteContact -> update related contact address records -> ' + winningContacts);

		List<Contact_Address__c> relatedContactAddressRecords = ContactAddressService.getContactAddressByContact(winningContacts);
		Utility.logUpdate(ContactAddressService.appendMissingMatchKeys(ContactAddressService.setDefaultCleansedFields(relatedContactAddressRecords, false), true));
		
		system.debug('ContactService -> handleAfterDeleteContact -> update contact lifetime values -> ' + winningContacts);
		OrderService.processRollUpForContacts(winningContacts);
		//Utility.logUpdate(OrderService.processRollUpForContacts(winningContacts));	
	}
	
		
}