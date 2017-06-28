public class MembershipExtension{

 public Membership__c rhMembership {get; set;}
 
 public MembershipExtension(ApexPages.StandardController stdController) {
       this.rhMembership = (Membership__c)stdController.getRecord();      
 }
 
 public PageReference newMembership(){
    String prfx = Membership__c.sObjectType.getDescribe().getKeyPrefix(); 
    PageReference pr = new PageReference('/' + prfx + '/e?Name=Automated&nooverride=1' );
    return pr; 
 }   

}