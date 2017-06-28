public with sharing class Order_BillingSummaryCtlExt {
    
    /*
     *  Order controller extension - methods to support billing summary email.
     *
     */
    
    ApexPages.StandardController stdController;
    public RH_Order__c rhOrder {get; set;}
    public Boolean noInvoiceData {get; set;}
    public Map<String, String> subMap {get;set;}
    public Boolean isLargeOrder{get;set;}
    public transient List<RH_Invoice.InvoiceLineWrapper> ILWrapper{get;set;}
    
    // Constructor    
    public Order_BillingSummaryCtlExt(ApexPages.StandardController stdController) {
        isLargeOrder = false;
        rhOrder = new RH_Order__c();
        this.rhOrder = (RH_Order__c)stdController.getRecord();
        rhOrder = [select Id, Name, Sold_to_Email__c, Sold_to_First_Name__c, Sold_to_Last_Name__c, Client_Type__c, 
                Opportunity__c, Opportunity__r.Ops_Contact__c, Opportunity__r.Ops_Contact__r.Phone, 
                To_Email_Address__c, Additional_To_Email_Addresses__c 
                from RH_Order__c where Id = :this.rhOrder.Id];
        
        // Set the default To email address
        rhOrder.To_Email_Address__c = rhOrder.Sold_to_Email__c;
        rhOrder.Additional_To_Email_Addresses__c = '';
        rhOrder.Client_Type__c = 'Standard';        
        // Verify that invoice data exists for this order.        
        ILWrapper = BillingSummaryEmail.bsInvoiceLineWrapper(rhOrder.Id, rhOrder.Client_Type__c);         
    }
    
    public PageReference EmailContent(){
        try{
            subMap = getHTMLStrings();
        }catch(BillingSummaryEmail.CPUTimeoutException ex){
            BillingSummaryEmail.deleteContent(rhOrder.Id);
            BillingSummaryEmail.writeEmailContent(rhOrder.Id, rhOrder.Client_Type__c);
            isLargeOrder = true;
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, 'Your Order contains very many invoices and will take a while to generate.  Please press preview.'));
        }
        
        if(ILWrapper.isEmpty()){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'There is no invoice data for order ' + rhOrder.Name + '.'));
            noInvoiceData = true;
        } else {
            noInvoiceData = false;
        }
        return null;
    }
    
    public PageReference generatePreview(){
        String subMapString = '';
        for(OrderEmailContent__c oec:[select id, RH_Order__c, Sequence__c, EmailContent__c from OrderEmailContent__c where RH_Order__c = :rhOrder.Id order by Sequence__c]){
            subMapString += oec.EmailContent__c;            
        }
        if(subMapString != ''){
           Map<String, String> subMapDirty = (Map<String, String>) JSON.deserialize(subMapString, Map<String, String>.class);
           subMap = new Map<String, String>();
        
           for(String tag:subMapDirty.keySet()){
              if(subMapDirty.get(tag) == null){
                 subMap.put(tag, '');        
              }else{
                 subMap.put(tag, subMapDirty.get(tag));
              }
           }
        }else{
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, 'Your Billing Summary Email is still generating.  Please press preview again in a few seconds.'));
        }
        
        return null;
    }
    
    public PageReference cancelBillingSummary() {
        BillingSummaryEmail.deleteContent(rhOrder.Id);
        PageReference pr = new PageReference('/' + rhOrder.Id);
        return pr;
    }
    
    public PageReference sendBillingSummary() {
         if(this.rhOrder.To_Email_Address__c == null || this.rhOrder.Client_Type__c == null){
           ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'You must enter a Client Type and Send To Email Address.'));
           return null;
        }  
        PageReference pr = null;
        String errMessage = '';
        
        // Validate the additional email address entered
        String badEmailAddrs = '';
        String goodEmailAddrs = '';
        if (String.isBlank(errMessage)) {
            List<String> addEmailAddrs = new List<String>();
            if (String.isNotBlank(rhOrder.Additional_To_Email_Addresses__c)) {
                rhOrder.Additional_To_Email_Addresses__c = rhOrder.Additional_To_Email_Addresses__c.remove(' ');
                addEmailAddrs.addAll(rhOrder.Additional_To_Email_Addresses__c.split(',', 0));
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
        } else {
            
            // Save the selected/entered email addresses and send the Billing Summary email
            try {
                rhOrder.Additional_To_Email_Addresses__c = goodEmailAddrs.removeEnd(',');        
                update rhOrder;
                refreshSubMapForClientType();
                if(!isLargeOrder){
                   BillingSummaryEmail.sendEmail(rhOrder.Id, subMap, false);
                }else{
                    // Email Services allow a larger (36MB Heap Size)                   
                    BillingSummaryEmail.useEmailService(rhOrder.Id, subMap);
                    BillingSummaryEmail.deleteContent(rhOrder.Id);
                }
                pr = new PageReference('/' + rhOrder.Id);
            
            } catch(Exception e) {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Billing Summary Email - Order update exception: ' + e.getMessage()));
            }
        }

        return pr;
    }    
    
    public void refreshSubMapForClientType(){       
       Map<String, String> newSubMap = BillingSummaryEmail.headerFooterContent(rhOrder.Id, rhOrder.Client_Type__c);
       for(String s:newSubMap.keySet()){
          if(newSubMap.get(s) == null){
             subMap.put(s, '');
          }else{ 
             subMap.put(s, newSubMap.get(s));
          }
       }    
    }
    
   public Map<String, String> getHTMLStrings(){
     Map<String, String> htmlMap = BillingSummaryEmail.getEmailContent(this.rhOrder.Id, this.rhOrder.Client_Type__c, ILWrapper, CPULimitThreshold__c.getInstance('Synchronous').Milliseconds__c - 1000);
     Map<String, String> mapBillingEmailValuesHandleNULLs = new Map<String, String>();
     for(String tag:htmlMap.keySet()){
        if(htmlMap.get(tag) == null){
           mapBillingEmailValuesHandleNULLs.put(tag, '');        
        }else{
           mapBillingEmailValuesHandleNULLs.put(tag, htmlMap.get(tag));
        }
     }     
     return mapBillingEmailValuesHandleNULLs;
  }
  
}