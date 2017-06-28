@isTest                
public with sharing class BatchMonitorMembershipRenewalEmailsTest {
 	  
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
	     
	     Integer uniqueEmail = 0; 
	     List<Membership__C> testMemberships = new List<Membership__c>();	     
	     for (Integer isCanadian = 0; isCanadian < 2; isCanadian ++) {
		     for (Integer index = 0; index < BatchMonitorMembershipRenewalEmails.expirationDateList.size()-1; index ++ ) {
		     	for (Integer range = -1; range < 2; range ++ ) {
			     	Integer daysOut = BatchMonitorMembershipRenewalEmails.expirationDateList.get(index);
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
	     
	     
	     testMemberships.add(new Membership__c(
			     		Member_Email__c = String.valueOf(uniqueEmail) + '@testemail.com.net',
			     		Once_was_Quebecois__c = false,
				 		Enrollment_Date_Time__c = Date.today().addDays(-7),
			     		Member_State__c =  'CA',
			     		Member_Country__c =  'US',   
			     		Expiration_Date_Time__c = System.Today().AddDays(5),
			     		Cancellation_date__c = Date.today().addDays(-1),
						Cancellation_reason__c =  'Credit Card Decline',  
						Cancellation_type__c = 'RH Terminated',	
    					Renewal_Email_Notification__c = '1-Day Post Termination'));
    					
	     insert testMemberships;
  	}	
    
    public static testMethod void testStart() {
    	setup();
    	BatchMonitorMembershipRenewalEmails bm = new BatchMonitorMembershipRenewalEmails(0, 0);
    	
    	//test new if condition in start for termination emails
    	BatchMonitorMembershipRenewalEmails bm2 = new BatchMonitorMembershipRenewalEmails(3, 6);
    	
    	bm.start(null);
    	bm2.start(null);
	}

	public static testMethod void testExecute() {
		setup();
		for (Integer index = 0; index < BatchMonitorMembershipRenewalEmails.expirationDateList.size()-1; index ++ ) {
			for (Integer job = 0; job < 3; job ++) {
		     	Integer daysOut = BatchMonitorMembershipRenewalEmails.expirationDateList.get(index);
				BatchMonitorMembershipRenewalEmails bm = new BatchMonitorMembershipRenewalEmails(job, index);
				bm.execute(null, database.query(bm.getQuery()));    							
			}
		}
    	
    	Integer daysOut = BatchMonitorMembershipRenewalEmails.expirationDateList.get(6);
				BatchMonitorMembershipRenewalEmails bm = new BatchMonitorMembershipRenewalEmails(3, 6);
				bm.execute(null, database.query(bm.getQuery()));  
    	
	}
	
	public static testMethod void testFinish() {
		setup();
	}


	
    public static testMethod void testBatchMonitorMemRenewalEmailsExScheduler() {       

         test.starttest();
   		String chron = '0 0 13 * * ?' ;       
         system.schedule('job', chron, new BatchMonitorMemRenewalEmailsExScheduler());
         test.stopTest();

    }

public static testMethod void testBatchMonitorMemRenewalEmailsScheduler() {       

         test.starttest();
   		String chron = '0 0 13 * * ?' ;       
         system.schedule('job', chron, new BatchMonitorMemRenewalEmailsScheduler());
         test.stopTest();

    }

public static testMethod void testBatchMonitorMembershipRenewalEmails_additional_tests() {

BatchMonitorMembershipRenewalEmails b = new BatchMonitorMembershipRenewalEmails ();


}
}