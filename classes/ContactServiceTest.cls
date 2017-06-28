@isTest
public with sharing class ContactServiceTest {
	
    @testSetup
    static void setup() {
    	TestDataFactory.turnMdmFeatureFlagsOn(); 
    	initializeMembershipTables();
    }	

	public static testMethod void test_handleInsertedUpdatedContact() {
	
		// given a feature flag turned on
		
		Feature_Flags__c customSetting = new Feature_Flags__c(
			Single_Pane_Address_Feature__c = true
		);
		insert customSetting;	
				
		// given a new contact
		
		Contact testContact = new Contact(
			FirstName = 'paul',
			LastName = 'hemmings',
			Email = 'paul@paul.com'
		);
		
		// when that contact is inserted
		
		database.insert(testContact);
		
		// then a contact address record is inserted that is linked to this contact
		
		system.assertEquals(1, [SELECT ID FROM CONTACT_ADDRESS__C WHERE CONTACT__C = :testContact.Id].size());
		system.assertEquals(testContact.Id, [SELECT CONTACT__C FROM CONTACT_ADDRESS__C].CONTACT__C); 
		system.assertEquals(testContact.Email, [SELECT EMAIL__C FROM CONTACT_ADDRESS__C].EMAIL__C);	
		
		// when that contact is updated
		
		testContact.Email = 'aiden@test.com';
		database.update(testContact);
		
		// then a new contact address is created
		
		system.assertEquals(2, [SELECT ID FROM CONTACT_ADDRESS__C WHERE CONTACT__C = :testContact.Id].size()); 
	}
	
	public static testMethod void testMatchingOrderOnMember() {
		
		RecordType tradeAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Trade' and SObjectType = 'Account'];
		
		// given custom setting

		MembershipNumber__c customSetting = new MembershipNumber__c(
			Adjustor__c = 1
		);
		insert customSetting;		
				
		// given (user to insert records)

		User u = TestDataFactory.createUser();
        u.Single_View_of_Customer_Process_User__c = false;
        		
		// give (a test account) 
		
		Account[] testAccounts = new List<Account>{new Account(
			Name = 'test-account',
			RecordType = tradeAccountRecordType
		)};
		System.runAs(u) {
			database.insert(testAccounts);
		}
		String tradeId = [SELECT X12_Digit_Member__c FROM Account WHERE ID = :testAccounts.get(0).Id].X12_Digit_Member__c;
		system.assertNotEquals(null, tradeId, 'no trade id set');
		
		// given (a test contact)
		
		Contact[] testContacts = new List<Contact>{new Contact(
			FirstName = 'paul',
			LastName = 'hemmings'
		)};
		database.insert(testContacts);
		
		// given (a test member)
		
		MemberShip__c[] testMembers = new List<MemberShip__c>{new Membership__c(
			Contact__c = testContacts.get(0).Id
        	,Member_Email__c = 'paul@paul.com'
        	,Cancellation_Type__c = 'RH Terminated'
        	,Cancellation_Reason__c = 'Duplicate membership'			
		)};
		System.runAs(u) {
			database.insert(testMembers);
		}
		ID membershipId = [SELECT ID FROM Membership__c WHERE Contact__c = :testContacts.get(0).Id].Id;
		
		
		// given (a test order)
		
		Rh_Order__c[] testOrders = new List<Rh_Order__c>();
		testOrders.add(new Rh_Order__c(
			Membership_ID_Lookup__c = membershipId
		));
		testOrders.add(new Rh_Order__c(
			Trade_ID__c = tradeId
		));	
		
		// when (match order to member's contact)
		
		system.debug('call mapping orders with: ' + testOrders);
		ContactService.mapOrders(testOrders);
		
		// then (the orer should link to the contact)
		
		system.assertEquals(testContacts.get(0).Id, testOrders.get(0).Contact_Sold_To__c);
		system.assertEquals(testAccounts.get(0).Id, testOrders.get(1).Account_Sold_To__c);
	}    
	
	private static void initializeMembershipTables() {
  	
		TriggerManager__c settings = TriggerManager__c.getOrgDefaults();
		settings.runMembershipTriggers__c = true;
		upsert settings TriggerManager__c.Id;
     
		MembershipNumber__c settings2 = MembershipNumber__c.getOrgDefaults();
		settings2.Adjustor__c = 1000000000;
		upsert settings2 MembershipNumber__c.Id;     
     
		List<SObject> customSettings = new List<SObject>();
		customSettings.add(new Quebecois__c(
			CountryValue__c = 'CA:C.A.:CAN:C.A.N.:CANADA',
    	    ProvinceValue__c = 'QC:QC:Q.C.:QUE.:QUEBEC:QU�BEC'
		));        
		database.insert(customSettings);      
	
	     MembershipExpiration__c me = new MembershipExpiration__c();
	     me.Cancellation_Type__c = 'Member Cancelled';
	     me.Name = 'Default';
	     database.insert(me);	
	      
	     Member_Renewal_SKU__c mr = new Member_Renewal_SKU__c();
	     mr.SKU_Names__c = '91020003BC30:91020005RH30:91020006EXPR:91020007EXPR:91020009BC1Y:91020008RH1Y:91020001RH';
	     mr.Name = 'a2G2C0000008PQq';
	     database.insert(mr);
	      
	     MembershipSKU__c msku = new MembershipSKU__c();
	     msku.SKU__c = '91020001RH';
	     msku.Name = '01t50000002ZvLDAA0';
	     database.insert(msku);
	    
	     MembershipAmount__c ma = new MembershipAmount__c();
	     ma.Name = 'Annual';
	     ma.Unit__c = 'year';
	     ma.Amount__c = 100;
	     ma.Tax__c = 15;
	     database.insert(ma);   
	      
	     RH_Brand__c brand = new RH_Brand__c();
	     brand.Name = '999';
	     brand.RH_Members_Program_Profile_URL__c = 'https://www.restorationhardware.com/my-account/membership.jsp';
	     database.insert(brand);		
	     
		 RH_Web_Services__c dataSource = new RH_Web_Services__c();
		 dataSource.Name = 'getPaymentDetail';   
         dataSource.Service_URL__c = 'test-url';
         database.insert(dataSource);
	}  
		
}