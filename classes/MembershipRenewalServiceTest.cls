@isTest                          
private class MembershipRenewalServiceTest {
	                     
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
         
		List<Application_Settings__c> appSettings = PrepareData.createApplicationSettings(); 
		insert appSettings;
	}
	
    static testMethod void test_getMembershipRecord() {
    	initialize();
    	
    	// given 
    	
    	Membership__c testMembership = new Membership__c(
	 		Member_Email__c = 'test@testemail.com.net',
	 		Once_was_Quebecois__c = false,
	 		Enrollment_Date_Time__c = Date.today().addDays(-1),
	 		Member_State__c = 'QC',
	 		Member_Country__c = 'CA',   
	 		Expiration_Date_Time__c = System.Today().AddDays(1)    		    		
    	);
    	database.insert(testMembership);
    	
    	// when / then
    	    	
    	system.assertEquals(testMembership.Id, MembershipRenewalService.getMembershipRecord(testMembership.Id).Id);
    }
    
    static testMethod void test_getMembershipRecords() {
    	initialize();
    	
    	// given 
    	
    	List<Membership__c> testMemberships = new List<Membership__c>();
    	testMemberships.add(new Membership__c(
		 		Member_Email__c = 'test@testemail.com.net',
		 		Once_was_Quebecois__c = false,
		 		Enrollment_Date_Time__c = Date.today().addDays(-1),
		 		Member_State__c = 'QC',
		 		Member_Country__c = 'CA',   
		 		Expiration_Date_Time__c = System.Today().AddDays(1)    		    		
	    ));
	    
	    // when / then
	    
	    database.insert(testMemberships);
	    system.assertEquals(1, MembershipRenewalService.getMembershipRecords(new List<ID>{testMemberships.get(0).Id}).size());
    }
    
    static testMethod void test_getMembershipPurchaseOrders() {
    	initialize();
    	
    	// given a test membership
    	
    	Membership__c testMembership = new Membership__c(
	 		Member_Email__c = 'test@testemail.com.net',
	 		Once_was_Quebecois__c = false,
	 		Enrollment_Date_Time__c = Date.today().addDays(-1),
	 		Member_State__c = 'QC',
	 		Member_Country__c = 'CA',   
	 		Expiration_Date_Time__c = System.Today().AddDays(1)    		    		
    	);
    	database.insert(testMembership);
    	
    	// given a test order
    	
    	Rh_Order__c testOrder = new Rh_Order__c(
	 		Name = 'test order', 
	 		Membership_ID_Lookup__c = testMembership.Id	    		
    	);
    	database.insert(testOrder);    
    	
    	// given a test product
    	
    	Product2 testProduct = new Product2(
    		Name = '91020003BC30'
    	);	
    	database.insert(testProduct);
    	
    	// given a test order line item
    	
    	Order_Line_Items__c testLineItem = new Order_Line_Items__c(
    		RH_Order_Number__c = testOrder.Id,
    		CW_SKU_ID__c = testProduct.Id
    	);
    	database.insert(testLineItem);
		    	
    	// when
    	
    	Map<ID, List<RH_Order__c>> orders = MembershipRenewalService.getMembershipPurchaseOrders(new List<Membership__c>{testMembership});
    	
    	// then
    	
    	system.assertEquals(1, orders.values().size());
    }
    
    static testMethod void test_makePaymentRequest() {
    	initialize();
    	
    	// given a test order.
    	
    	Rh_Order__c testOrder = new Rh_Order__c(
	 		Name = 'test order'	    		
    	);
    	database.insert(testOrder);      	
    	    	
    	// when - make a request out for that order
    	
    	HttpResponse response = MembershipRenewalService.makePaymentRequest(testOrder.Name);
    	
    	// then
    	
    	system.assertNotEquals(null, response);
    	
    }
    
    static testMethod void test_processPaymentResponse() {
    	
    	// given
    	
    	// when
    	
    	// then
    }
    
    static testMethod void test_cwPaymentDateToSalesforcePaymentDate() {
    	
    	// given - a CW date string
    	
    	String cwPaymentDate = '01/2008';
    	
    	// when - convert to date
    	
    	 Date sfDate = MembershipRenewalService.cwPaymentDateToSalesforcePaymentDate(cwPaymentDate); 
    	
    	// then
    	
    	system.assertNotEquals(null, sfDate);
    }
    
    static testMethod void test_callCwForBetterCardDetails() {
    	initialize();
    	
    	// given a test membership
    	
    	Membership__c testMembership = new Membership__c(
	 		Member_Email__c = 'test@testemail.com.net',
	 		Once_was_Quebecois__c = false,
	 		Enrollment_Date_Time__c = Date.today().addDays(-1),
	 		Member_State__c = 'QC',
	 		Member_Country__c = 'CA',   
	 		Expiration_Date_Time__c = System.Today().AddDays(1)    		    		
    	);
    	database.insert(testMembership);
    	
    	// given a test order
    	
    	Rh_Order__c testOrder = new Rh_Order__c(
	 		Name = 'test order', 
	 		Membership_ID_Lookup__c = testMembership.Id	    		
    	);
    	database.insert(testOrder);    
    	
    	// given a test product
    	
    	Product2 testProduct = new Product2(
    		Name = '91020003BC30'
    	);	
    	database.insert(testProduct);
    	
    	// given a test order line item
    	
    	Order_Line_Items__c testLineItem = new Order_Line_Items__c(
    		RH_Order_Number__c = testOrder.Id,
    		CW_SKU_ID__c = testProduct.Id
    	);
    	database.insert(testLineItem);
    	
    	// when
    	
    	MembershipRenewalService.CalloutResponse response = MembershipRenewalService.callCwForBetterCardDetails(new List<Membership__c>{testMembership});        	 
    	
    	// then
    	
    	system.assertEquals(true, response.updatedMemberships.isEmpty());
    	system.assertEquals(false, response.resultingErrors.isEmpty());
    }
    
    static testMethod void test_getDaysNotice() {
    	initialize();
    	
    	// given
    	Map<String, Membership__c> testMembers = new Map<String, Membership__c>();
    	testMembers.put('60-Day Notice', new Membership__c(Renewal_Email_Notification__c = '60-Day Notice'));
    	testMembers.put('30-Day Notice', new Membership__c(Renewal_Email_Notification__c = '30-Day Notice'));
    	testMembers.put('5-Day Notice', new Membership__c(Renewal_Email_Notification__c = '5-Day Notice'));
    	testMembers.put('3-Day Notice', new Membership__c(Renewal_Email_Notification__c = '3-Day Notice'));
    	testMembers.put('1-Day Notice', new Membership__c(Renewal_Email_Notification__c = '1-Day Notice'));
    	testMembers.put('5-Day Post Expiration', new Membership__c(Renewal_Email_Notification__c = '5-Day Post Expiration'));
    	testMembers.put('1-Day Post Termination', new Membership__c(Renewal_Email_Notification__c = '1-Day Post Termination'));
    	    	
    	// when
    	
    	Map<String, Integer> daysOut = new Map<String, Integer>();
    	for (String key : testMembers.keySet()) {
    		daysOut.put(key, MembershipRenewalService.getDaysNotice(testMembers.get(key)));	
    	} 
    	
    	// then
    	
		system.assertEquals(60, daysOut.get('60-Day Notice'));
		system.assertEquals(30, daysOut.get('30-Day Notice'));
		system.assertEquals(5, daysOut.get('5-Day Notice'));
		system.assertEquals(3, daysOut.get('3-Day Notice'));
		system.assertEquals(1, daysOut.get('1-Day Notice'));
		system.assertEquals(-5, daysOut.get('5-Day Post Expiration'));	
		system.assertEquals(-1, daysOut.get('1-Day Post Termination'));		    	
			    	
    }
    
    static testMethod void test_buildAttachments() {
    	initialize();
    	
    	// given 
    	
    	Map<String, Membership__c> testMembers = new Map<String, Membership__c>();
    	testMembers.put('60-Day Notice', new Membership__c(
    		RH_Renewal_CC_Entity_Code__c = 'RH',
			Member_Email__c = '60@testemail.com.net',
			Once_was_Quebecois__c = false,
			Enrollment_Date_Time__c = Date.today().addDays(-1),
			Member_State__c = 'QC',
			Member_Country__c = 'CA',   
			Expiration_Date_Time__c = System.Today().AddDays(1),    	
    		Name = '123456', 
    		Renewal_Email_Notification__c = '60-Day Notice')
    	);
    	database.insert(testMembers.values());
    	
    	// when
    	
    	
		List<Attachment> attachments = MembershipRenewalService.buildAttachments(testMembers.values(), 'renewal'); 
		 
		// then    	
		
		system.assertEquals(1, attachments.size());
		system.assertEquals('(60 Day Notice) - RH Membership No AutoRenew Email - Member 123456.html', attachments.get(0).name);
		
		//test case for terminated membership
		testMembers = new Map<String, Membership__c>();
    	testMembers.put('-Day Post Termination', new Membership__c(
    		RH_Renewal_CC_Entity_Code__c = 'RH',
			Member_Email__c = 'termtest@testemail.com.net',
			Once_was_Quebecois__c = false,
			Enrollment_Date_Time__c = Date.today().addDays(-7),
			Member_State__c = 'IL',
			Member_Country__c = 'US',   
			Expiration_Date_Time__c = System.Today().AddDays(1), 
			Cancellation_date__c = Date.today().addDays(-5),
			Cancellation_reason__c =  'Credit Card Decline',  
			Cancellation_type__c = 'RH Terminated',	
    		Name = '123456term', 
    		Renewal_Email_Notification__c = '1-Day Post Termination')
    	);
    	database.insert(testMembers.values());
    	
    	// when
    	
		attachments = MembershipRenewalService.buildAttachments(testMembers.values(), 'terminate'); 
		 
		// then    	
		
		system.assertEquals(1, attachments.size());
		
		system.assertEquals('(-1 Day Notice) - RH Membership Terminate Email - Member 123456term.html', attachments.get(0).name);
    }
      
    static testMethod void test_buildRenewalMembershipRecords() {
    	initialize();
    	
     	// given - a test membership record for each expiration date
     	  
	     Integer uniqueEmail = 0; 
	     List<Membership__C> testMemberships = new List<Membership__c>();	     
	     for (Integer isCanadian = 0; isCanadian < 2; isCanadian ++) {
		     for (Integer index = 0; index < BatchMonitorMembershipRenewalEmails.expirationDateList.size()-1; index ++ ) {
		     	for (Integer range = -1; range < 2; range ++ ) {
		     		 
			     	Integer daysOut = BatchMonitorMembershipRenewalEmails.expirationDateList.get(index);
//System.debug(String.valueOf('membership-'  +uniqueEmail) + '@testemail.com.net-enrollment-' + Date.today().addDays(-1) + '-state-' + ((isCanadian == 0) ? 'QC' : 'CA') + '-country-' + ((isCanadian == 0) ? 'CA' : 'US') + '-expiry-' + System.Today().AddDays(daysOut+range));
//System.debug('membership-' + Date.today().addDays(-1) + '-state-' + ((isCanadian == 0) ? 'QC' : 'CA') + '-country-' + ((isCanadian == 0) ? 'CA' : 'US') + '-expiry-' + System.Today().AddDays(daysOut+range));

			     	testMemberships.add(new Membership__c(
			     		Member_Email__c = String.valueOf(uniqueEmail) + '@testemail.com.net',
			     		Once_was_Quebecois__c = false,
				 		Enrollment_Date_Time__c = Date.today().addDays(-1),
			     		Member_State__c = (isCanadian == 0) ? 'QC' : 'CA',
			     		Member_Country__c = (isCanadian == 0) ? 'CA' : 'US',   
			     		Expiration_Date_Time__c = System.Today().AddDays(daysOut+range)

			     	));
                    
			     	uniqueEmail++;
		     	}
		     }
	     }
	     insert testMemberships;

         for (membership__c m : testMemberships)
            System.debug('expiry - ' + m.expiration_date_time__c + '-props-' + new MembershipRenewalService.MembershipRenewalProperties(m));

	          	
     	// when
      	 
     	List<Membership__c> expiredMemberships = new List<Membership__c>();
		for (Integer index = 0; index < BatchMonitorMembershipRenewalEmails.expirationDateList.size()-1; index ++ ) {
	     	Integer daysOut = BatchMonitorMembershipRenewalEmails.expirationDateList.get(index);
			BatchMonitorMembershipRenewalEmails bm = new BatchMonitorMembershipRenewalEmails(0, index);
			List<Membership__c> testRecords = database.query(bm.getQuery());
			expiredMemberships.addAll(MembershipRenewalService.buildRenewalMembershipRecords(testRecords, 'renewal' ));
		}
      	
     	// then
     	
     	system.assertEquals(9, expiredMemberships.size());
     	
    }
    
    static testMethod void test_assignExpirationDates() {
    	initialize();
    	
    	// given
    	
    	Map<String, Membership__C> testMemberships = new Map<String, Membership__c>();
    	testMemberships.put('RH', new Membership__c(
    		RH_Renewal_CC_Expiration_Date__c = '01/2017',
    		RH_Renewal_CC_Entity_Code__c = 'RH',
			Member_Email__c = 'RH@testemail.com.net',
			Once_was_Quebecois__c = false,
			Enrollment_Date_Time__c = Date.today().addDays(-1),
			Member_State__c = 'QC',
			Member_Country__c = 'CA',   
			Expiration_Date_Time__c = System.Today().AddDays(1)
    	));
    	database.insert(testMemberships.values());
    		 
    	// when

		List<Membership__c> assignedDates = MembershipRenewalService.assignExpirationDates(testMemberships.values());
		    	
    	// then
    	
    	system.assertEquals(1, assignedDates.size());
    	system.assertEquals('RH', assignedDates.get(0).Renewal_Order_Entity_Code__c);    	
    	system.assertNotEquals(null, assignedDates.get(0).Latest_CC_Expiration_Date__c);
    	system.assertEquals(true, assignedDates.get(0).Has_Valid_CC__c);
    	
    }
    
    static testMethod void test_MembershipRenewalService_additional_tests() {

initialize();

System.debug('running new test');

MembershipRenewalService.qualifiesFor1DayEmail(new MembershipRenewalService.MembershipRenewalProperties(new Membership__c(
            
            Member_Email__c = 'RH-1@testemail.com.net',
            Once_was_Quebecois__c = false,
            Enrollment_Date_Time__c = Date.today().addDays(-1),
            Member_State__c = 'IL',
            Member_Country__c = 'US',
            is_auto_renew__c = true,
            Has_Valid_CC__c = false,
            Expiration_Date_Time__c = System.Today().AddDays(1))));

MembershipRenewalService.qualifiesFor1DayEmail(new MembershipRenewalService.MembershipRenewalProperties(new Membership__c(
            RH_Renewal_CC_Expiration_Date__c = '01/2017',
            RH_Renewal_CC_Entity_Code__c = 'RH',
            Member_Email__c = 'RH11@testemail.com.net',
            Once_was_Quebecois__c = false,
            Enrollment_Date_Time__c = Date.today().addDays(-1),
            Member_State__c = 'IL',
            Member_Country__c = 'US',   
            Expiration_Date_Time__c = System.Today().AddDays(1))));

    MembershipRenewalService.qualifiesFor1DayEmail(new MembershipRenewalService.MembershipRenewalProperties(new Membership__c(
            RH_Renewal_CC_Expiration_Date__c = '01/2017',
            RH_Renewal_CC_Entity_Code__c = 'RH',
            Member_Email__c = 'RH1@testemail.com.net',
            Once_was_Quebecois__c = false,
            Enrollment_Date_Time__c = Date.today().addDays(-1),
            Member_State__c = 'QC',
            Member_Country__c = 'CA',   
            Expiration_Date_Time__c = System.Today().AddDays(1))));

MembershipRenewalService.qualifiesFor1DayEmail(new MembershipRenewalService.MembershipRenewalProperties(new Membership__c(
            RH_Renewal_CC_Expiration_Date__c = '01/2017',
            RH_Renewal_CC_Entity_Code__c = 'RH',
            Member_Email__c = 'RH2@testemail.com.net',
            Once_was_Quebecois__c = false,
            Enrollment_Date_Time__c = Date.today().addDays(-1),
            Member_State__c = 'IL',
            Member_Country__c = 'US',
            is_auto_renew__c = false,
            Has_Valid_CC__c = true,
            Latest_CC_Expiration_Date__c = system.today().adddays(-5),   
            Expiration_Date_Time__c = System.Today().AddDays(1))));


MembershipRenewalService.qualifiesFor1DayEmail(new MembershipRenewalService.MembershipRenewalProperties(new Membership__c(
            RH_Renewal_CC_Expiration_Date__c = '01/2017',
            RH_Renewal_CC_Entity_Code__c = 'RH',
            Member_Email__c = 'RH3@testemail.com.net',
            Once_was_Quebecois__c = false,
            Enrollment_Date_Time__c = Date.today().addDays(-1),
            Member_State__c = 'IL',
            Member_Country__c = 'US',
            is_auto_renew__c = false,
            Has_Valid_CC__c = true,
            Latest_CC_Expiration_Date__c = system.today()+300,   
            Expiration_Date_Time__c = System.Today().AddDays(1))));

    
    

MembershipRenewalService.qualifiesFor1DayEmail(new MembershipRenewalService.MembershipRenewalProperties(new Membership__c(
            RH_Renewal_CC_Expiration_Date__c = '01/2017',
            RH_Renewal_CC_Entity_Code__c = 'RH',
            Member_Email__c = 'RH4@testemail.com.net',
            Once_was_Quebecois__c = false,
            Enrollment_Date_Time__c = Date.today().addDays(-1),
            Member_State__c = 'ON',
            Member_Country__c = 'CA',
            is_auto_renew__c = true,
            Has_Valid_CC__c = true,
            Latest_CC_Expiration_Date__c = system.today().adddays(-5),   
            Expiration_Date_Time__c = System.Today().AddDays(-3))));


MembershipRenewalService.qualifiesFor1DayEmail(new MembershipRenewalService.MembershipRenewalProperties(new Membership__c(
            RH_Renewal_CC_Expiration_Date__c = '01/2020',
            RH_Renewal_CC_Entity_Code__c = 'RH',
            Member_Email__c = 'RH5@testemail.com.net',
            Once_was_Quebecois__c = false,
            Enrollment_Date_Time__c = Date.today().addDays(-1),
            Member_State__c = 'ON',
            Member_Country__c = 'CA',
            is_auto_renew__c = false,
            Has_Valid_CC__c = true,
            Latest_CC_Expiration_Date__c = system.today().adddays(200),   
            Expiration_Date_Time__c = System.Today().AddDays(600))));


MembershipRenewalService.qualifiesFor1DayEmail(new MembershipRenewalService.MembershipRenewalProperties(new Membership__c(
            RH_Renewal_CC_Expiration_Date__c = '01/2017',
            RH_Renewal_CC_Entity_Code__c = 'RH',
            Member_Email__c = 'RH5@testemail.com.net',
            Once_was_Quebecois__c = false,
            Enrollment_Date_Time__c = Date.today().addDays(-1),
            Member_State__c = 'CA',
            Member_Country__c = 'US',
            is_auto_renew__c = false,
            Has_Valid_CC__c = true,
            Latest_CC_Expiration_Date__c = system.today().adddays(-5),   
            Expiration_Date_Time__c = System.Today().AddDays(1))));




MembershipRenewalService.qualifiesFor1DayEmail(new MembershipRenewalService.MembershipRenewalProperties(new Membership__c(
            
            Member_Email__c = 'RH12@testemail.com.net',
            Once_was_Quebecois__c = false,
            Enrollment_Date_Time__c = Date.today().addDays(-1),
            Member_State__c = 'ON',
            Member_Country__c = 'CA',
            is_auto_renew__c = true,
            Has_Valid_CC__c = false,
            Expiration_Date_Time__c = System.Today().AddDays(1))));


MembershipRenewalService.qualifiesFor1DayEmail(new MembershipRenewalService.MembershipRenewalProperties(new Membership__c(
            RH_Renewal_CC_Expiration_Date__c = '01/2017',
            RH_Renewal_CC_Entity_Code__c = 'RH',
            Member_Email__c = 'RH13@testemail.com.net',
            is_auto_renew__c = false,
            Once_was_Quebecois__c = true,
            Enrollment_Date_Time__c = Date.today().addDays(-1),
            Member_State__c = 'QC',
            Member_Country__c = 'CA',   
            Expiration_Date_Time__c = System.Today().AddDays(1))));

MembershipRenewalService.qualifiesFor1DayEmail(new MembershipRenewalService.MembershipRenewalProperties(new Membership__c(
            RH_Renewal_CC_Expiration_Date__c = '01/2017',
            RH_Renewal_CC_Entity_Code__c = 'RH',
            Member_Email__c = 'RH14@testemail.com.net',
            Once_was_Quebecois__c = false,
            Enrollment_Date_Time__c = Date.today().addDays(-1),
            Member_State__c = 'IL',
            Member_Country__c = 'US',
            Has_Valid_CC__c = false,
            Latest_CC_Expiration_Date__c =null,
            is_auto_renew__c = false,            
            Expiration_Date_Time__c = System.Today().AddDays(1))));

MembershipRenewalService.qualifiesFor5DayEmail(new MembershipRenewalService.MembershipRenewalProperties(new Membership__c(
            
            Member_Email__c = 'RH-1@testemail.com.net',
            Once_was_Quebecois__c = false,
            Enrollment_Date_Time__c = Date.today().addDays(-1),
            Member_State__c = 'IL',
            Member_Country__c = 'US',
            is_auto_renew__c = true,
            Has_Valid_CC__c = false,
            Expiration_Date_Time__c = System.Today().AddDays(1))));

MembershipRenewalService.qualifiesFor5DayEmail(new MembershipRenewalService.MembershipRenewalProperties(new Membership__c(
            RH_Renewal_CC_Expiration_Date__c = '01/2017',
            RH_Renewal_CC_Entity_Code__c = 'RH',
            Member_Email__c = 'RH11@testemail.com.net',
            Once_was_Quebecois__c = false,
            Enrollment_Date_Time__c = Date.today().addDays(-1),
            Member_State__c = 'IL',
            Member_Country__c = 'US',   
            Expiration_Date_Time__c = System.Today().AddDays(1))));

    MembershipRenewalService.qualifiesFor5DayEmail(new MembershipRenewalService.MembershipRenewalProperties(new Membership__c(
            RH_Renewal_CC_Expiration_Date__c = '01/2017',
            RH_Renewal_CC_Entity_Code__c = 'RH',
            Member_Email__c = 'RH1@testemail.com.net',
            Once_was_Quebecois__c = false,
            Enrollment_Date_Time__c = Date.today().addDays(-1),
            Member_State__c = 'QC',
            Member_Country__c = 'CA',   
            Expiration_Date_Time__c = System.Today().AddDays(1))));

MembershipRenewalService.qualifiesFor5DayEmail(new MembershipRenewalService.MembershipRenewalProperties(new Membership__c(
            RH_Renewal_CC_Expiration_Date__c = '01/2017',
            RH_Renewal_CC_Entity_Code__c = 'RH',
            Member_Email__c = 'RH2@testemail.com.net',
            Once_was_Quebecois__c = false,
            Enrollment_Date_Time__c = Date.today().addDays(-1),
            Member_State__c = 'IL',
            Member_Country__c = 'US',
            is_auto_renew__c = false,
            Has_Valid_CC__c = true,
            Latest_CC_Expiration_Date__c = system.today().adddays(-5),   
            Expiration_Date_Time__c = System.Today().AddDays(1))));


MembershipRenewalService.qualifiesFor5DayEmail(new MembershipRenewalService.MembershipRenewalProperties(new Membership__c(
            RH_Renewal_CC_Expiration_Date__c = '01/2017',
            RH_Renewal_CC_Entity_Code__c = 'RH',
            Member_Email__c = 'RH3@testemail.com.net',
            Once_was_Quebecois__c = false,
            Enrollment_Date_Time__c = Date.today().addDays(-1),
            Member_State__c = 'IL',
            Member_Country__c = 'US',
            is_auto_renew__c = false,
            Has_Valid_CC__c = true,
            Latest_CC_Expiration_Date__c = system.today()+300,   
            Expiration_Date_Time__c = System.Today().AddDays(1))));

    
    

MembershipRenewalService.qualifiesFor5DayEmail(new MembershipRenewalService.MembershipRenewalProperties(new Membership__c(
            RH_Renewal_CC_Expiration_Date__c = '01/2017',
            RH_Renewal_CC_Entity_Code__c = 'RH',
            Member_Email__c = 'RH4@testemail.com.net',
            Once_was_Quebecois__c = false,
            Enrollment_Date_Time__c = Date.today().addDays(-1),
            Member_State__c = 'ON',
            Member_Country__c = 'CA',
            is_auto_renew__c = true,
            Has_Valid_CC__c = true,
            Latest_CC_Expiration_Date__c = system.today().adddays(-5),   
            Expiration_Date_Time__c = System.Today().AddDays(-3))));


MembershipRenewalService.qualifiesFor5DayEmail(new MembershipRenewalService.MembershipRenewalProperties(new Membership__c(
            RH_Renewal_CC_Expiration_Date__c = '01/2020',
            RH_Renewal_CC_Entity_Code__c = 'RH',
            Member_Email__c = 'RH5@testemail.com.net',
            Once_was_Quebecois__c = false,
            Enrollment_Date_Time__c = Date.today().addDays(-1),
            Member_State__c = 'ON',
            Member_Country__c = 'CA',
            is_auto_renew__c = false,
            Has_Valid_CC__c = true,
            Latest_CC_Expiration_Date__c = system.today().adddays(200),   
            Expiration_Date_Time__c = System.Today().AddDays(600))));


MembershipRenewalService.qualifiesFor5DayEmail(new MembershipRenewalService.MembershipRenewalProperties(new Membership__c(
            RH_Renewal_CC_Expiration_Date__c = '01/2017',
            RH_Renewal_CC_Entity_Code__c = 'RH',
            Member_Email__c = 'RH5@testemail.com.net',
            Once_was_Quebecois__c = false,
            Enrollment_Date_Time__c = Date.today().addDays(-1),
            Member_State__c = 'CA',
            Member_Country__c = 'US',
            is_auto_renew__c = false,
            Has_Valid_CC__c = true,
            Latest_CC_Expiration_Date__c = system.today().adddays(-5),   
            Expiration_Date_Time__c = System.Today().AddDays(1))));




MembershipRenewalService.qualifiesFor5DayEmail(new MembershipRenewalService.MembershipRenewalProperties(new Membership__c(
            
            Member_Email__c = 'RH12@testemail.com.net',
            Once_was_Quebecois__c = false,
            Enrollment_Date_Time__c = Date.today().addDays(-1),
            Member_State__c = 'ON',
            Member_Country__c = 'CA',
            is_auto_renew__c = true,
            Has_Valid_CC__c = false,
            Expiration_Date_Time__c = System.Today().AddDays(1))));


MembershipRenewalService.qualifiesFor5DayEmail(new MembershipRenewalService.MembershipRenewalProperties(new Membership__c(
            RH_Renewal_CC_Expiration_Date__c = '01/2017',
            RH_Renewal_CC_Entity_Code__c = 'RH',
            Member_Email__c = 'RH13@testemail.com.net',
            is_auto_renew__c = false,
            Once_was_Quebecois__c = true,
            Enrollment_Date_Time__c = Date.today().addDays(-1),
            Member_State__c = 'QC',
            Member_Country__c = 'CA',   
            Expiration_Date_Time__c = System.Today().AddDays(1))));

MembershipRenewalService.qualifiesFor5DayEmail(new MembershipRenewalService.MembershipRenewalProperties(new Membership__c(
            RH_Renewal_CC_Expiration_Date__c = '01/2017',
            RH_Renewal_CC_Entity_Code__c = 'RH',
            Member_Email__c = 'RH14@testemail.com.net',
            Once_was_Quebecois__c = false,
            Enrollment_Date_Time__c = Date.today().addDays(-1),
            Member_State__c = 'IL',
            Member_Country__c = 'US',
            Has_Valid_CC__c = false,
            Latest_CC_Expiration_Date__c =null,
            is_auto_renew__c = false,            
            Expiration_Date_Time__c = System.Today().AddDays(1))));


MembershipRenewalService.assignExpirationDates(new Membership__c(
            RH_Renewal_CC_Expiration_Date__c = '01/2017',
            RH_Renewal_CC_Entity_Code__c = 'RH',
            Member_Email__c = 'RH14@testemail.com.net',
            Once_was_Quebecois__c = false,
            Enrollment_Date_Time__c = Date.today().addDays(-1),
            Member_State__c = 'IL',
            Member_Country__c = 'US',
            Has_Valid_CC__c = false,
            Latest_CC_Expiration_Date__c =null,
            is_auto_renew__c = false,            
            Expiration_Date_Time__c = System.Today().AddDays(1)));

List<membership__c> m = new List<membership__c>();
membership__c mem = new Membership__c(
            RH_Renewal_CC_Expiration_Date__c = '01/2017',
            RH_Renewal_CC_Entity_Code__c = 'RH',
            Member_Email__c = 'RH14@testemail.com.net',
            Once_was_Quebecois__c = false,
            Enrollment_Date_Time__c = Date.today().addDays(-1),
            Member_State__c = 'IL',
            Member_Country__c = 'US',
            Has_Valid_CC__c = false,
            Latest_CC_Expiration_Date__c =null,
            Cancellation_date__c = system.today().adddays(-1),
            Renewal_Email_Notification__c = '1-Day Post Termination',
            is_auto_renew__c = false,            
            Expiration_Date_Time__c = System.Today().AddDays(1));
m.add(mem);
    
//MembershipRenewalService.buildRenewalMembershipRecords(m, 'terminate');



    
}
    
}