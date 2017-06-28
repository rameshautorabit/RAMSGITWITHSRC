@isTest
private class testMembership {
     
  static Membership__c m;
  static RH_Order__c o;
  static Account p;
  
  static void setup() {
     
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
      
     m = new Membership__c();
     m.Member_Email__c = 'peter@testemail.com.net';
     m.Once_was_Quebecois__c = false;
	 m.Enrollment_Date_Time__c = Date.today().addDays(-1);
	 // m.Expiration_Date_Time__c = Date.today().addDays(1);   
     m.Member_State__c = 'QC';
     m.Member_Country__c = 'CA';   
     m.Expiration_Date_Time__c = System.Today().AddDays(60);       
     insert m;
     
	 m = new Membership__c();
     m.Member_Email__c = 'paul@testemail.com.net';
     m.Once_was_Quebecois__c = false;
	 m.Enrollment_Date_Time__c = Date.today().addDays(-1);
	 // m.Expiration_Date_Time__c = Date.today().addDays(1);   
     m.Member_State__c = 'QC';
     m.Member_Country__c = 'CA';   
     m.Expiration_Date_Time__c = System.Today().AddDays(61);       
     insert m;
     
     List<Application_Settings__c> appSettings = PrepareData.createApplicationSettings(); 
	 insert appSettings;
  }
    
    static testMethod void testAllTheMissingStuff() {
        setup();
        MembershipService.skus();
        MembershipRenewalService.MembershipRenewalProperties mrp = new MembershipRenewalService.MembershipRenewalProperties(m);
        MembershipRenewalService.qualifiesForMinus1DayEmail(mrp);
        MembershipRenewalService.qualifiesFor1DayEmail(mrp);        
        MembershipRenewalService.qualifiesFor3DayEmail(mrp);
        MembershipRenewalService.qualifiesFor5DayEmail(mrp);
        MembershipRenewalService.qualifiesFor30DayEmail(mrp);
        MembershipRenewalService.qualifiesFor60DayEmail(mrp);
        MembershipService.createGetPaymentRequest('cwOrderId', 'SourceValue', 'callType');
        MembershipService.SetDefaults(new List<Membership__c>{m}, null);
        MembershipService.SetDefaultsDeprecated(new List<Membership__c>{m}, null);                
        MembershipService.validationRules(new List<Membership__c>{m}, null);

        MembershipRenewalEmailTemplateController.setProperCase('Joe Smith');
         
    }
     
    static testMethod void testMembershipRenewalService() {  
    	setup();  	
    	Membership__c testMember = MembershipRenewalService.getMembershipRecord(m.Id);
    	List<Membership__c> testMembers = MembershipRenewalService.getMembershipRecords(new List<ID>{m.Id});
    	MembershipRenewalService.buildAttachments(testMembers, 'renewal');
    	MembershipRenewalService.buildRenewalMembershipRecords(testMembers, 'renewal');
    }

  static testMethod void testUpdatingIlegibleContacts() {
  	
  	// given - custom settings
  	
	List<SObject> customSettings = new List<SObject>();
	customSettings.add(new Quebecois__c(
		CountryValue__c = 'QC:QC:Q.C.:QUE.:QUEBEC:QUÉBEC',
        ProvinceValue__c = 'CA:C.A.:CAN:C.A.N.:CANADA'
	));
	customSettings.add(new MembershipNumber__c(
		Adjustor__c = 1
	));        
	database.insert(customSettings);  	
  	
  	// given - a test contact
  	
  	List<Contact> testContacts = new List<Contact>();
  	testContacts.add(new Contact(
  		FirstName = 'test first',
  		LastName = 'test last',
  		Has_Membership__c = true
  	));
  	database.insert(testContacts);
  	
  	// when - a test membership
  	
  	List<Membership__c> testMemberships = new List<Membership__c>();
  	testMemberships.add(new Membership__c(
  		 Contact__c = testContacts.get(0).Id  	
    	,Member_Email__c = 'paul@paul.com'
    	,Cancellation_Type__c = 'RH Terminated'
    	,Cancellation_Reason__c = 'Duplicate membership'
        ,Once_was_Quebecois__c = false  	
  	));
  	database.insert(testMemberships);
  	
  	// then -  the membership exists, and contact is set to have a membership
  	
  	system.assertEquals(true, [SELECT Has_Membership__c FROM Contact WHERE ID = :testContacts.get(0).ID].Has_Membership__c);
  	
  	// given - the name of the inserted membership record
  	
  	String membershipName = [SELECT Name FROM Membership__c].Name;  	
  	  	
  	// given - that membership included in a map with eligible set to false
  	
  	Map<String, Boolean> mapMembersFlag = new Map<String, Boolean>();
  	mapMembersFlag.put(membershipName, false);
  	
  	// when - that membership set to illegible
  	
  	MembershipService.updateMembershipContactEligibility(mapMembersFlag);
  	
  	// then -  the contact is set to not have a membership
  	
  	system.assertEquals(false, [SELECT Has_Membership__c FROM Contact WHERE ID = :testContacts.get(0).ID].Has_Membership__c);  	
  }
  
  static testMethod void testBatch() {
      setup();
      m.ReprocessBatch__c = true; 
      update m;
      Test.StartTest();      
      Id batchJobId = Database.executeBatch(new BatchMonitorMemberships(), 10);       
      Test.StopTest();  
  }
  
  static testMethod  void testScheduled() {
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        EligibleForMemberBenefitsScheduler efmbs = new EligibleForMemberBenefitsScheduler();
        Test.startTest();
        String jobId = System.schedule('ScheduleApexClassTest',CRON_EXP,efmbs);
        Test.stopTest();
  }
    
  static testMethod void testOrderLines() {
      setup();
      p = TestDataFactory.createPersonAccount(true);
      o = TestDataFactory.createRhOrder(false);
      o.Account_Sold_To__c = p.Id;
      o.Total_Order_Amount__c = 200.0;
      o.Status__c = 'Closed';
      insert o;         
      Order_Line_Items__c line = new Order_Line_Items__c();
      line.RH_Order_Number__c = o.Id;
      insert line; 
      Map<String, Order_Line_Items__c> mapOL = new Map<String, Order_Line_Items__c>();
      mapOL.put(String.valueOf(o.Id), line);
      m = new Membership__c();
      m.Member_Email__c = 'peter@testemail.com.orderlines';      
      m.Created_by_Order_ID__c = o.Id;
      insert m;
      MembershipService.UpdateOrderLineLevelInfo(mapOL);
      Set<Id> orderIds = new Set<Id>();
      o.Membership_ID_Lookup__c = m.Id;
      update o;
      orderIds.add(o.Id);
      MembershipService.UpdateDates(orderIds);
  //
  }

  static testMethod void testCreateMembership() {
     
     setup();
     
     m.Welcome_Email_Requested_Datetime__c = System.Now();
     m.Enrollment_Date_Time__c = System.Now().addDays(1123);
     update m;
     
     m.Enrollment_Date_Time__c = System.Now().addDays(-23);
     m.Cancellation_Reason__c = 'Does not use it';
     m.Cancellation_Type__c = 'Member Terminated'; 
     update m;
     
     m.Expiration_Date_Time__c = System.Now().addDays(223);
     update m;

     m.Membership_Card_Opt_in__c = true;
     m.Membership_Restore_Date__c = System.Today();
     update m;
     
     Map<String, Boolean> mapMembersFlag = new Map<String, Boolean>();
     mapMembersFlag.put(m.Name, true);
     MembershipService.updateEligibleForMemberBenefits(mapMembersFlag);

  }
  
  static testMethod void testCreateMembershipAsMULE() {
  
     User u = [SELECT Id, Name from User where Name = 'MULE API User'];
     setup();
          
     System.RunAs(u){
       
       m = new Membership__c();
       m.Member_Email__c = 'peter@testemail.com.net2';
       m.Membership_Type__c = 'Complimentary - VIP';
       m.Welcome_Email_Requested_Datetime__c = System.Now();
       m.Enrollment_Date_Time__c = System.Now().addDays(1123);
       insert m;
       
       //System.DmlException: Insert failed. First exception on row 0; 
       //first error: INSUFFICIENT_ACCESS_OR_READONLY, user does not have access to use approval assignment
       // email template: []
       
       m = new Membership__c();
       m.Member_Email__c = 'peter@testemail.com.net3';
       m.Enrollment_Date_Time__c = System.Now().addDays(-23);
       m.Cancellation_Reason__c = 'Does not use it';
       m.Cancellation_Type__c = 'Member Terminated'; 
       insert m;

       m = new Membership__c();
       m.Member_Email__c = 'peter@testemail.com.net4';
       m.Membership_Card_Opt_in__c = true;
       m.Membership_Restore_Date__c = System.Today();
       insert m;
       
       m.Cancellation_Type__c = 'Member Cancelled';
       m.Membership_Restore_Date__c  = System.Today();
       update m;
     
     }
  
  
  }

}