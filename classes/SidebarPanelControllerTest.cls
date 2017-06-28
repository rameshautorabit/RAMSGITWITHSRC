/**
 *  @description  Test class for SidebarPanelController (Relationship sidebar VF pages (Account/Contact))
 *  @author      Zi Zhang, Traction on Demand.
 *  @date        2016-02-17
 */
@isTest
private class SidebarPanelControllerTest {

	static {
		Tier_Hierarchy__c tier = new Tier_Hierarchy__c(X1__c='Top Tier', X2__c='Tier 2', X3__c='Tier 3', X4__c='Tier 4');
		insert tier;
	}

	@isTest 
	private static void testControllerAccountPage() {
		// Create Test Data (contacts, person accounts, relationships)
		List<Contact> testContacts = createContacts(1, 0);
		insert testContacts;

		List<Account> testPersonAccounts = createPersonAccounts(3, 0);
		insert testPersonAccounts;

		List<Contact> personAccountContacts = [SELECT Id, AccountId FROM Contact WHERE Account.IsPersonAccount = true];
		System.assertEquals(3, personAccountContacts.size(), 'Person Account Contacts do not exist');

		List<Relationship__c> testRelationships = createRelationships(personAccountContacts[0], testContacts, false);
		insert testRelationships;

		ApexPages.currentPage().getParameters().put('id',personAccountContacts[0].AccountId);

		Test.startTest();
		SidebarPanelController spc = new SidebarPanelController();

		System.assertEquals(1, spc.relationshipToRelatedContactMap.size(), 'Relationship not related to contact');
		System.assertEquals(true, spc.relationshipToRelatedContactMap.containsKey('Client'), 'Relationship map does not contain Client Relationship key');
		System.assertEquals(1, spc.relationshipToRelatedContactMap.get('Client').size(), 'Related contacts in relationship size mismatch');
		Test.stopTest();
	}

	@isTest 
	private static void testControllerContactPage() {
		// Create Test Data (contacts, person accounts, relationships)
		List<Contact> testContacts = createContacts(1, 0);
		insert testContacts;

		List<Account> testPersonAccounts = createPersonAccounts(3, 0);
		insert testPersonAccounts;

		List<Contact> personAccountContacts = [SELECT Id FROM Contact WHERE Account.IsPersonAccount = true];
		System.assertEquals(3, personAccountContacts.size(), 'Person Account Contacts do not exist');

		List<Relationship__c> testRelationships = createRelationships(testContacts[0], personAccountContacts, false);
		insert testRelationships;

		ApexPages.currentPage().getParameters().put('id',testContacts[0].Id);

		Test.startTest();
		SidebarPanelController spc = new SidebarPanelController();

		System.assertEquals(1, spc.relationshipToRelatedContactMap.size(), 'Relationship not related to contact');
		System.assertEquals(true, spc.relationshipToRelatedContactMap.containsKey('Client'), 'Relationship map does not contain Client Relationship key');
		System.assertEquals(3, spc.relationshipToRelatedContactMap.get('Client').size(), 'Related contacts in relationship size mismatch');
		Test.stopTest();
	}

	@isTest 
	private static void testInnerClass() {
		// Test data
		List<Contact> testContacts = createContacts(3, 0);
		insert testContacts;

        Relationship__c newRel = new Relationship__c(
    		Contact__c = testContacts[0].Id,
    		Related_Contact__c = testContacts[1].Id,
    		Relationship_Type__c = 'Client',
    		Is_Inactive__c = false
    	);

    	insert newRel;

        SidebarPanelController.TreeWrapper twrapper = new SidebarPanelController.TreeWrapper();

        SidebarPanelController.ContactBase cb1 = new SidebarPanelController.ContactBase(newRel, testContacts[1], false, 1);
        SidebarPanelController.ContactBase cb2 = new SidebarPanelController.ContactBase(newRel, testContacts[0], false, 2);
        SidebarPanelController.ContactBase cb3 = new SidebarPanelController.ContactBase(newRel, testContacts[1], false, 2);
        Integer result = cb1.compareTo(cb2);

        System.assertEquals(-1, result, 'compareTo method result does not match result ');

        result = cb2.compareTo(cb1);

        System.assertEquals(1, result, 'compareTo method result does not match result ');

        result = cb2.compareTo(cb3);

        System.assertEquals(0, result, 'compareTo method result does not match result ');
	}

	/********************************************************************************************* Data Creation Method *****************************************************************/

	private static List<Contact> createContacts(Integer nbRecord, Integer start) {
        Account testAccount = new Account(Name = 'testAccount');

        insert testAccount;

        List<Contact> contacts = new List<Contact>();
        for(Integer i = start; i < nbRecord + start; i++) {
            Contact aContact = new Contact(
                FirstName   = 'FirstName' + i,
                LastName    = 'LastName' + i,
                AccountId = testAccount.Id,
                Total_Lifetime_Value__c = 60000
            );

            contacts.add(aContact);
        }

        return contacts;
    }

    private static List<Account> createPersonAccounts(Integer nbRecord, Integer start) {
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RH End Customer').getRecordTypeId();

        List<Account> personAccounts = new List<Account>();
        for(Integer i = start; i < nbRecord + start; i++) {
            Account acc = new Account(
				RecordTypeID = recordTypeId,
				FirstName = 'FirstName' + i,
				LastName = 'LastName' + i,
				PersonMailingStreet='123 Fake St.',
				PersonMailingPostalCode='12345',
				PersonMailingCity='SFO',
				PersonEmail='test@yahoo.com',
				PersonHomePhone='1234567',
				PersonMobilePhone='12345678'
			);

            personAccounts.add(acc);
        }

        return personAccounts;
    }


    private static List<Relationship__c> createRelationships(Contact con, List<Contact> relatedContacts, Boolean isInactive) {
        List<Relationship__c> newRelationships = new List<Relationship__c>();

        for(Contact c : relatedContacts) {
        	Relationship__c newRel = new Relationship__c(
        		Contact__c = con.Id,
        		Related_Contact__c = c.Id,
        		Relationship_Type__c = 'Client',
        		Is_Inactive__c = isInactive
        	);

        	newRelationships.add(newRel);
        }

        return newRelationships;
    }
}