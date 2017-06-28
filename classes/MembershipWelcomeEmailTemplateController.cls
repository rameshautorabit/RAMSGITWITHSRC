public class MembershipWelcomeEmailTemplateController{
 
 public String membershipId{get;set;}

 public String dayPhone{get;set;}
 
 public Boolean isQuebec{get{ 
    return MembershipService.isQuebecois(membershipId, true);
 }set;}
 
 public MembershipWelcomeEmailTemplateController(){}
 
 public List<MembershipWelcomeEmailTemplateController.MembershipInfo> getMembershipDetails(){ 
   
   List<MembershipWelcomeEmailTemplateController.MembershipInfo> listMembershipDetails = new List<MembershipWelcomeEmailTemplateController.MembershipInfo>();
   Contact con;
   Membership__c m = [SELECT Id, Name, Contact__c, Enrollment_Date__c, Expiration_Date__c, Member_Email__c
                        from Membership__c
                       where Id = :membershipId];
   if(m.Contact__c != null){
      for(Contact c:[SELECT Id, Name, Phone from Contact where Id = :m.Contact__c]){
         con = c;
      } 
   }else{
      con = new Contact();  
   }
   listMembershipDetails.add(new MembershipInfo(m, con));
   return listMembershipDetails;
 }
 
	public class MembershipInfo {
		public Membership__c membership{get;set;}
		public Contact membershipParty{get;set;}
		public String dayPhone{get;set;} 
		public String EnrollmentDate{get;set;}
		public String ExpirationDate{get;set;}

		public MembershipInfo(Membership__c m, Contact con){
			this.membership = m;
			this.membershipParty = con;
			if (String.isNotBlank(con.Phone)) {
				this.dayPhone = Utility.formatPhone10(con.Phone);
			}
			this.EnrollmentDate = Utility.usWrittenDate(m.Enrollment_Date__c, true);
			this.ExpirationDate = Utility.usWrittenDate(m.Expiration_Date__c, true);      
		}
	}
 
 }