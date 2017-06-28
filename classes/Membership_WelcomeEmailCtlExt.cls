public with sharing class Membership_WelcomeEmailCtlExt {

    /*
     *  Membership controller extension - methods to support membership welcome email.
     *
     */
    public Membership__c rhMembership {get; set;}
    public String additionalEmails {get; set;}
    ApexPages.StandardController stdController; 
     
    public Membership_WelcomeEmailCtlExt(ApexPages.StandardController stdController) {
       this.rhMembership = (Membership__c)stdController.getRecord();
       rhMembership = [select Id, Name, Member_Email__c, Send_To_Email__c
                         from Membership__c
                        where Id = :this.rhMembership.Id];
       rhMembership.Send_To_Email__c = rhMembership.Member_Email__c;       
    }
    
    public PageReference sendWelcomeEmail() {
      
        if(this.rhMembership.Send_To_Email__c == null){
          ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'You must enter the main Email Address before sending!'));
          return null;
        }
    
    
        String errMessage = '';
        String badEmailAddrs = '';
        String goodEmailAddrs = '';
        List<String> addEmailAddrs = new List<String>();
        
        if (String.isBlank(errMessage)) {            
            if (String.isNotBlank(additionalEmails)) {
                additionalEmails = additionalEmails.replaceAll('(\\s+)', '');
                addEmailAddrs.addAll(additionalEmails.split(',', 0));
            }
            for (String emailAddr :addEmailAddrs) {
                if (String.isBlank(emailAddr)) {
                    badEmailAddrs += ',,' + ',';
                } else {
                    if (!Utility.validateEmail(emailAddr)) {
                        badEmailAddrs += emailAddr + ',';
                    } else {
                        goodEmailAddrs += emailAddr + ',';
                    }
                }
            }
            
            if (String.isNotBlank(badEmailAddrs)) {
                badEmailAddrs = badEmailAddrs.removeEnd(',');
                errMessage = 'Addtional To Email Addresses must be valid and separated by a single comma. The following email addresses entered are invalid: ' + badEmailAddrs;
            }
        }
                
        if (String.isNotBlank(errMessage)) {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, errMessage));
            return null;
        } else {        
            Integer i = 1;
            for(String email:addEmailAddrs){
                if(i == 1){
                   rhMembership.Additional_Email1__c = email;
                }
                if(i == 2){
                   rhMembership.Additional_Email2__c = email;
                }
                if(i == 3){
                   rhMembership.Additional_Email3__c = email;
                }
                if(i == 4){
                   rhMembership.Additional_Email4__c = email;
                }
                if(i == 5){
                   rhMembership.Additional_Email5__c = email;
                }    
                i++;       
            }
            rhMembership.Welcome_Email_Requested_Datetime__c = System.Now();
            update rhMembership;
            PageReference pr = new PageReference('/' + rhMembership.Id);
            return pr;     
        }
    }
    
    public PageReference cancelWelcomeEmail() {
       PageReference pr = new PageReference('/' + rhMembership.Id);
       return pr;     
    }

}