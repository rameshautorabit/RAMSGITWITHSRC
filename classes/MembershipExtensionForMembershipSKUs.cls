public class MembershipExtensionForMembershipSKUs{

 public Membership__c rhMembership {get; set;}
 ApexPages.StandardController stdController; 
     
 public MembershipExtensionForMembershipSKUs(ApexPages.StandardController stdController) {
       this.rhMembership = (Membership__c)stdController.getRecord();
       this.rhMembership = [select Id, Name 
                         from Membership__c
                        where Id = :this.rhMembership.Id];

 }
 
 public list<Order_Line_Items__c> getLines(){

    Member_Renewal_SKU__c renewalSKUs = Member_Renewal_SKU__c.getOrgDefaults();
    map<String, MembershipSKU__c> membershipSKUs = MembershipSKU__c.getAll(); 
    list<Order_Line_Items__c> MembershipSkuLines = new list<Order_Line_Items__c>();
    
    for(Order_Line_Items__c ol:[select ID, RH_Order_Number__c, RH_Order_Number__r.Name, Name, CreatedDate, CW_SKU_ID__c, CW_SKU_ID__r.Name,
                                          CW_SKU_ID__r.ECommerce_Display_Name__c, Line_Total__c, Line_Status__c,
                                          Return_Reason_Description__c, Line_Number__c, RH_Order_Number__r.Membership_Renewal_Term__c,
                                          CW_SKU_Name__c
                                     FROM Order_Line_Items__c 
                                    WHERE RH_Order_Number__r.Membership_ID__C = :rhMembership.Name
                                      AND CW_SKU_ID__c != null]){
          if(membershipSKUs.ContainsKey(ol.CW_SKU_ID__c)
             || renewalSKUs.SKU_Names__c.Contains(ol.CW_SKU_Name__c)){
             MembershipSkuLines.add(ol);
          }
    }
    return MembershipSkuLines;
 }

}