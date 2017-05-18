/**
*  @Description : Trigger to update Contact Name on opportunity based on Primary Contact under Contact Roles
*                 This trigger fires after update.
*  @Author      : Bhargavi Vadlamani
*  @Created Date: 
**/
trigger UpdateContactRole on Opportunity(before update) {
    Set < Id > OppIds = new Set < Id > ();
    List<Opportunity> OpptyIDs = new List<Opportunity>();
    for (Opportunity o: Trigger.new) {
        OppIds.add(o.id);
    }
    Map < Id, List < OpportunityContactRole >> Opp_OCR = new Map < Id, List < OpportunityContactRole >> ();
    
    for (OpportunityContactRole ocr: [select id, contactid, Opportunityid, role, isprimary, createddate from OpportunityContactRole where opportunityid in : OppIds and isprimary = true]) {
       
        List < OpportunityContactRole > tmp_ocr = new List < OpportunityContactRole > ();
        tmp_ocr = Opp_OCR.get(ocr.opportunityid); 
        if (tmp_ocr == null) {
            Opp_OCR.put(ocr.opportunityid, new List < OpportunityContactRole > {
                ocr
            });
        } else {
           
            tmp_ocr.add(ocr);
            Opp_OCR.put(ocr.opportunityid, tmp_ocr);
        }
    }
    for (Opportunity opps: Trigger.new) {
       
        List < OpportunityContactRole > this_OCR = new List < OpportunityContactRole > ();
        this_OCR = Opp_OCR.get(opps.id);
       
       if (this_OCR == null) {
        opps.Contact_Name__c = null;
        }
        else {
            for (OpportunityContactRole r: this_OCR) {
                if (r.isprimary) opps.Contact_Name__c = r.contactid;
            }
         
        } 
   }
}