@isTest
private class ChildHierarchyGroupTests {

    static List<ChildHierarchyGroupTest> testGroups = new  List<ChildHierarchyGroupTest> {
        new ContactInformationEmailGroupTest(),
        new ContactInformationPhoneGroupTest(),
        new ContactInformationFaxGroupTest(),
        new CustomerAddressHierarchyGroupTest()
    };
    	
    @testSetup
    static void setup() {
    	TestDataFactory.turnMdmFeatureFlagsOn(); 
    }	    

    @isTest
    static void test_bulk_0() {
        testGroups[0].test_bulk();
    }

    @isTest
    static void test_bulk_1() {
        testGroups[1].test_bulk();
    }

    @isTest
    static void test_bulk_2() {
        testGroups[2].test_bulk();
    }

    @isTest
    static void test_bulk_3() {
        testGroups[3].test_bulk();
    }

    @isTest
    static void test_new_primary_insert() {
        for (ChildHierarchyGroupTest testGroup : testGroups) {
            testGroup.test_new_primary_insert();
        }
    }

    @isTest
    static void test_new_primary_update() {
        for (ChildHierarchyGroupTest testGroup : testGroups) {
            testGroup.test_new_primary_update();
        }
    }

    @isTest
    static void test_two_primary_insert() {
        for (ChildHierarchyGroupTest testGroup : testGroups) {
            testGroup.test_two_primary_insert();
        }
    }

    @isTest
    static void test_two_primary_update() {
        for (ChildHierarchyGroupTest testGroup : testGroups) {
            testGroup.test_two_primary_update();
        }
    }

    @isTest
    static void test_unflag_old_primary_insert() {
        for (ChildHierarchyGroupTest testGroup : testGroups) {
            testGroup.test_unflag_old_primary_insert();
        }
    }

    @isTest
    static void test_unflag_old_primary_update() {
        for (ChildHierarchyGroupTest testGroup : testGroups) {
            testGroup.test_unflag_old_primary_update();
        }
    }

    @isTest
    static void test_remove_primary_update() {
        for (ChildHierarchyGroupTest testGroup : testGroups) {
            testGroup.test_remove_primary_update();
        }
    }

    @isTest
    static void test_remove_primary_delete() {
        for (ChildHierarchyGroupTest testGroup : testGroups) {
            testGroup.test_remove_primary_delete();
        }
    }

    @isTest
    static void test_primary_change_group() {
        for (ChildHierarchyGroupTest testGroup : testGroups) {
            testGroup.test_primary_change_group();
        }
    }

	public class ContactInformationEmailGroupTest extends ChildHierarchyGroupTest {
        public ContactInformationEmailGroupTest() {
            testGroup = new ContactInformationEmailGroup();
            numChildren = 5;
        }

        public override List<SObject> getChildren(Integer num) {
            List<Contact_Information__c> children = TestDataFactory.createContactInformations(num, false);
            for (Contact_Information__c child : children) {
                child.RecordTypeId = ContactInformations.EMAIL_RECORD_TYPE_ID;
            }
            return children;
        }

        public override SObject getParent() {
            Contact c = (Contact) getParents(1)[0];
            insert c;
            return c;
        }

        public override List<SObject> getParents(Integer num) {
            List<Contact> parents = TestDataFactory.createContacts(num, false);
            return parents;
        }
	}

    public class ContactInformationPhoneGroupTest extends ChildHierarchyGroupTest {
        public ContactInformationPhoneGroupTest() {
            testGroup = new ContactInformationPhoneGroup();
            numChildren = 5;
        }

        public override List<SObject> getChildren(Integer num) {
            List<Contact_Information__c> children = TestDataFactory.createContactInformations(num, false);
            for (Contact_Information__c child : children) {
                child.Contact_Information_Type__c = 'Home Phone';
                child.RecordTypeId = ContactInformations.PHONE_RECORD_TYPE_ID;
            }
            return children;
        }

        public override SObject getParent() {
            Contact c = (Contact) getParents(1)[0];
            insert c;
            return c;
        }

        public override List<SObject> getParents(Integer num) {
            List<Contact> parents = TestDataFactory.createContacts(num, false);
            return parents;
        }
    }

    public class ContactInformationFaxGroupTest extends ChildHierarchyGroupTest {
        public ContactInformationFaxGroupTest() {
            testGroup = new ContactInformationFaxGroup();
            numChildren = 5;
        }

        public override List<SObject> getChildren(Integer num) {
            List<Contact_Information__c> children = TestDataFactory.createContactInformations(num, false);
            for (Contact_Information__c child : children) {
                child.RecordTypeId = ContactInformations.FAX_RECORD_TYPE_ID;
            }
            return children;
        }

        public override SObject getParent() {
            List<Contact> parents = [SELECT Id FROM Contact];
            if (parents.isEmpty()) {
                Contact c = (Contact) getParents(1)[0];
                insert c;
                return c;
            } else {
                return parents[0];
            }
        }

        public override List<SObject> getParents(Integer num) {
            List<Contact> parents = TestDataFactory.createContacts(num, false);
            return parents;
        }
    }

    public class CustomerAddressHierarchyGroupTest extends ChildHierarchyGroupTest {
        private Address__c addr;

        public CustomerAddressHierarchyGroupTest() {
            testGroup = new CustomerAddressHierarchyGroup();
            numChildren = 5;
            addr = TestDataFactory.createAddress(true);
        }

        public override List<SObject> getChildren(Integer num) {
            List<Customer_Address__c> children = TestDataFactory.createCustomerAddresses(num, false, false);
            for (Customer_Address__c ca : children) {
                ca.Address__c = addr.Id;
            }
            return children;
        }

        public override SObject getParent() {
            Contact c = (Contact) getParents(1)[0];
            insert c;
            return c;
        }

        public override List<SObject> getParents(Integer num) {
            List<Contact> parents = TestDataFactory.createContacts(num, false);
            return parents;
        }
    }
}