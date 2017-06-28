@isTest
public with sharing class MembershipServiceTest {

	static testMethod void test_handleMembershipContactChange() {
   	
    	// GIVEN
    	
    	initialize();
    			
		// GIVEN (two contacts)
		
		Contact[] testContacts= new List<Contact>{
			new Contact(
				FirstName = 'paul',
				LastName = 'hemmings',
				Has_Membership__c = true				
			),
			new Contact(
				FirstName = 'non',
				LastName = 'member',
				Has_Membership__c = false				
			)			
		};
		database.insert(testContacts);
		
		// GIVEN (a member pointing to the first contact)
		
		Membership__c testUkMembership = new Membership__c(
		    Member_Email__c = 'testUk@testemail.com.net',
		    Once_was_Quebecois__c = false,
		    Enrollment_Date_Time__c = Date.today().addDays(-1),
		    Member_State__c = '',
		    Member_Country__c = 'UK',   
		    Expiration_Date_Time__c = System.Today().AddDays(1), 
		    Membership_Type__c = 'Paid',
		    Member_Street_1__c = '1',
			Member_City__c = 'city',
		    Member_Postal_Code__c = 'sg18 8bp',
		    Contact__c = testContacts.get(0).Id
		);		
	 	database.insert(testUkMembership);
	 	
	 	// WHEN (member moved from first contact to second)
	 	
	 	testUkMembership.Contact__c = testContacts.get(1).Id;
	 	database.update(testUkMembership);
	 	
	 	// THEN has membership flag to swap from 1st to 2nd contact.
	 	
	 	system.assertEquals(false, [SELECT has_membership__c FROM Contact WHERE ID = :testContacts.get(0).Id].has_membership__c);
	 	system.assertEquals(true, [SELECT has_membership__c FROM Contact WHERE ID = :testContacts.get(1).Id].has_membership__c);
	}  
	  	
    static testMethod void test_validationRules() {
    	
    	// GIVEN
    	
    	initialize();
        
    	// GIVEN
    	
		Membership__c testBlankMembership = new Membership__c(
		    Member_Email__c = 'testBlank@testemail.com.net',
		    Once_was_Quebecois__c = false,
		    Enrollment_Date_Time__c = Date.today().addDays(-1),
		    Member_State__c = '',
		    Member_Country__c = '',   
		    Expiration_Date_Time__c = System.Today().AddDays(1), 
		    Membership_Type__c = 'Paid',
		    Member_Street_1__c = '',
			Member_City__c = '',
		    Member_Postal_Code__c = ''
		);
		
		// WHEN 
		
		Map<ID, String> errorBlankMessagesVR = MembershipService.validationRules(new List<Membership__c>{testBlankMembership}, null);
		
		// THEN
		
		system.assertEquals(1, errorBlankMessagesVR.values().size());       
		system.assertEquals(true, errorBlankMessagesVR.containsKey(testBlankMembership.Id));  
		system.assertEquals('All Paid memberships must have an address.', errorBlankMessagesVR.get(testBlankMembership.Id));         
    	
    	// GIVEN
    	
		Membership__c testUkMembership = new Membership__c(
		    Member_Email__c = 'testUk@testemail.com.net',
		    Once_was_Quebecois__c = false,
		    Enrollment_Date_Time__c = Date.today().addDays(-1),
		    Member_State__c = '',
		    Member_Country__c = 'UK',   
		    Expiration_Date_Time__c = System.Today().AddDays(1), 
		    Membership_Type__c = 'Paid',
		    Member_Street_1__c = '1',
			Member_City__c = 'city',
		    Member_Postal_Code__c = 'sg18 8bp'
		);
		
		// WHEN 
		
		Map<ID, String> errorUkMessagesVR = MembershipService.validationRules(new List<Membership__c>{testUkMembership}, null);
		
		// THEN
		
		system.assertEquals(0, errorUkMessagesVR.values().size());
		
    	// GIVEN
    	
		Membership__c testUsValidMembership = new Membership__c(
		    Member_Email__c = 'testUsValid@testemail.com.net',
		    Once_was_Quebecois__c = false,
		    Enrollment_Date_Time__c = Date.today().addDays(-1),
		    Member_State__c = 'CA',
		    Member_Country__c = 'US',   
		    Expiration_Date_Time__c = System.Today().AddDays(1), 
		    Membership_Type__c = 'Paid',
		    Member_Street_1__c = '1',
			Member_City__c = 'city',
		    Member_Postal_Code__c = '94949'
		);
		
		// WHEN 
		
		Map<ID, String> errorUsValidMessagesVR = MembershipService.validationRules(new List<Membership__c>{testUsValidMembership}, null);
		
		// THEN
		
		system.assertEquals(0, errorUsValidMessagesVR.values().size());  		

        // GIVEN
    	
		Membership__c testUsMembership = new Membership__c(
		    Member_Email__c = 'testUs@testemail.com.net',
		    Once_was_Quebecois__c = false,
		    Enrollment_Date_Time__c = Date.today().addDays(-1),
		    Member_State__c = '',
		    Member_Country__c = 'US',   
		    Expiration_Date_Time__c = System.Today().AddDays(1), 
		    Membership_Type__c = 'Paid',
		    Member_Street_1__c = '1',
			Member_City__c = 'city',
		    Member_Postal_Code__c = '94949'
		);
		
		// WHEN 
		
		Map<ID, String> errorUsMessagesVR = MembershipService.validationRules(new List<Membership__c>{testUsMembership}, null);
		
		// THEN
		
		system.assertEquals(1, errorUsMessagesVR.values().size());
		system.assertEquals(true, errorUsMessagesVR.containsKey(testUsMembership.Id));  
		system.assertEquals('All Paid memberships must have an address.', errorUsMessagesVR.get(testUsMembership.Id));    	
    }
    
	private static void initialize() {
  	
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
         
         MembershipValidation__c validationRules = new MembershipValidation__c(
         	Name = 'MemberAddressFieldsCannotbeBlank',
         	Active__c = true,
         	Message__c = 'All Paid memberships must have an address.'
         );
         database.insert(validationRules);
	} 
}