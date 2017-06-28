/**
 *  @description  Controller for relationship sidebar (Person Account and Contact layout)
 *  @author      Zi Zhang, Traction on Demand.
 *  @date        2016-02-01
 */
public with sharing class SidebarPanelController {
	public Contact con {get; set;}
	public Account acc {get; set;}
	public Id personContactID {get; set;}
	public slpf__Settings__c settings {get; set;}
	public TreeWrapper primaryRecord {get; set;}
	public Map<String, List<ContactBase>> relationshipToRelatedContactMap {get; set;}
	public String contactAddress {get; set;}
	public Tier_Hierarchy__c tierHierarchy;
	public Map<String, Integer> tierRankByName;

	// constructor queries contact or person account info depending on the VF page loaded
	public SidebarPanelController() {
		setupData();

		List<Account> accounts;
		List<Contact> contacts;
		con = new Contact();
		acc = new Account();
		primaryRecord = new TreeWrapper();
		personContactID = ApexPages.CurrentPage().getParameters().get('Id');

		if(String.isNotEmpty(personContactID)) {
        	if(personContactID.getSObjectType() == Account.sObjectType) {
        		accounts = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, IsPersonAccount 
							FROM Account 
							WHERE Id =: personContactID];
        	} else if(personContactID.getSObjectType() == Contact.sObjectType) {
        		contacts = [SELECT Id, Name, MailingStreet, MailingCity, MailingState, MailingPostalCode, AccountId, Account.Name, Account.IsPersonAccount 
        					FROM Contact 
        					WHERE Id =: personContactID];
        	}
        }

		// Get Account and related contact info
		if(accounts != null && accounts.size() == 1) {
			acc = accounts[0];
			primaryRecord.Id = accounts[0].Id;
			contactAddress = accounts[0].BillingStreet + '\r\n' + accounts[0].BillingCity + ', ' + accounts[0].BillingState + ' ' + accounts[0].BillingPostalCode;

			List<Contact> relatedContacts = [SELECT Id, Name, AccountId, Account.Name, Account.IsPersonAccount 
											 FROM Contact 
											 WHERE AccountId =: acc.Id];
			if(relatedContacts.size() == 1) {
				con = relatedContacts[0];
			}

			relationshipToRelatedContactMap = generateRelationshipMap(con.Id);
		} else if(contacts != null && contacts.size() == 1) {
			con = contacts[0];
			primaryRecord.Id = contacts[0].Id;
			contactAddress = contacts[0].MailingStreet + '\r\n' + contacts[0].MailingCity + ', ' + contacts[0].MailingState + ' ' + contacts[0].MailingPostalCode;

			List<Account> parentAccounts = [SELECT Id, Name FROM Account WHERE Id =: con.AccountId];
			if(parentAccounts.size() == 1) {
				acc = parentAccounts[0];
			}

			relationshipToRelatedContactMap = generateRelationshipMap(con.Id);
		}
	}

	@TestVisible
	private void setupData() {
		settings = slpf__Settings__c.getOrgDefaults();
		tierHierarchy = Tier_Hierarchy__c.getOrgDefaults();

		tierRankByName = new Map<String, Integer>();

		// populate tier names with an integer value to be used for compareTo sort
		tierRankByName.put(tierHierarchy.X1__c, 1);
		tierRankByName.put(tierHierarchy.X2__c, 2);
		tierRankByName.put(tierHierarchy.X3__c, 3);
		tierRankByName.put(tierHierarchy.X4__c, 4);
	}

	// Populate map of relationship types to list of related contacts
	@TestVisible
	private Map<String, List<ContactBase>> generateRelationshipMap(Id contactId) {
		Map<String, List<ContactBase>> rMap = new Map<String, List<ContactBase>>();

		Schema.DescribeFieldResult fieldResult = Relationship__c.Relationship_Type__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

		for(Schema.PicklistEntry f : ple) {
			rMap.put(f.getValue(), new List<ContactBase>());
		}   

		if(String.isNotEmpty(contactId)) {
			for(Relationship__c rel : [SELECT Id, Name, Relationship_Type__c, Is_Inactive__c, Related_Contact__r.Id, Related_Contact__r.Name, 
											Related_Contact__r.Account.Name, Related_Contact__r.Tier_Name__c,
											Related_Contact__r.Tier_Icon__c, Related_Contact__r.Account.IsPersonAccount  
										FROM Relationship__c 
										WHERE Contact__c =: contactId 
										ORDER BY Related_Contact__r.Tier_Name__c]) {
				if(rMap.containsKey(rel.Relationship_Type__c)) {
					// Some Relationship records do not have related accounts or contacts, check if there's a related contact, if so, display in sidebar
					if(String.isNotEmpty(rel.Related_Contact__r.Id)) {
						Integer tierValue = 9999;

						if(tierRankByName != null && tierRankByName.get(rel.Related_Contact__r.Tier_Name__c) != null) {
							tierValue = tierRankByName.get(rel.Related_Contact__r.Tier_Name__c);
						}

						rMap.get(rel.Relationship_Type__c).add(new ContactBase(rel, rel.Related_Contact__r, rel.Is_Inactive__c, tierValue));
					} 
				}
			}
		}

		// Remove relationship types without related accounts
		for(String rType : rMap.keySet()) {
			if(rMap.get(rType).size() == 0) {
				// No related accounts, remove from map so it won't show on tree
				rMap.remove(rType);
			} else {
				// There are at least one related contact, sort List
				rMap.get(rType).sort();
			}
		}

		return rMap;
	}

	public class TreeWrapper {
		public String cssClass {get; set;}
		public String icon {get; set;}
		public String hover {get; set;}
		public String id {get; set;}

		public TreeWrapper() {
			cssClass = 'default';
			icon = '';
			hover = '';
			id = '';
		}
	}

	public class ContactBase implements Comparable{
		public Contact relatedContact {get; set;}
		public Relationship__c relationship {get; set;}
		public Boolean isInactive {get; set;}
		public Integer tier {get; set;}

		public ContactBase(Relationship__c relationship, Contact relatedContact, Boolean isInactive, Integer tier) {
			this.relatedContact = relatedContact;
			this.relationship = relationship;
			this.isInactive = isInactive;
			this.tier = tier;
		}

		public Integer compareTo(Object compareTo) {
			ContactBase compareToContact = (ContactBase)compareTo;
	        if (tier == compareToContact.tier) return 0;
	        if (tier > compareToContact.tier) return 1;
	        return -1;
		}
	}
}