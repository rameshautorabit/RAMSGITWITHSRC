public class OrderService {
  
  private @testvisible static Set<SObjectField> orderSoldToAddressFields = new Set<SObjectField> {
    Rh_Order__c.SOLD_TO_ADDRESS_1__C,
    Rh_Order__c.SOLD_TO_ADDRESS_2__C,
    Rh_Order__c.SOLD_TO_CITY__C,
    Rh_Order__c.SOLD_TO_STATE__C, 
    Rh_Order__c.SOLD_TO_ZIP__C, 
    Rh_Order__c.SOLD_TO_COUNTRY__C,
    Rh_Order__c.SOLD_TO_DAY_PHONE__C,
    Rh_Order__c.SOLD_TO_FIRST_NAME__C,
    Rh_Order__c.SOLD_TO_LAST_NAME__C,
    Rh_Order__c.SOLD_TO_COMPANY__C     
  };  
  
  private @testvisible static Set<SObjectField> orderBilltoAddressFields = new Set<SObjectField> {
    Rh_Order__c.BILL_TO_ADDRESS_1__C,
    Rh_Order__c.BILL_TO_ADDRESS_2__C,
    Rh_Order__c.BILL_TO_CITY__C,
    Rh_Order__c.BILL_TO_STATE__C, 
    Rh_Order__c.BILL_TO_ZIP__C, 
    Rh_Order__c.BILL_TO_COUNTRY__C,
    Rh_Order__c.BILL_TO_DAY_PHONE__C,
    Rh_Order__c.BILL_TO_FIRST_NAME__C,
    Rh_Order__c.BILL_TO_LAST_NAME__C,
    Rh_Order__c.BILL_TO_COMPANY__C     
  };    

  public static void renewMembership(List<RH_Order__c> orders, Map<Id, RH_Order__c> oldMap){
       set<id> ordersToCheck = new set<id>();
       for(RH_Order__c o:orders){
          RH_Order__c oldOrder;
          if(oldMap != null){
             oldOrder = oldMap.get(o.Id);
          }
          if((oldMap == null && o.Membership_Renewal_Term__c != null)
            || (oldMap != null && Utility.isChanged(oldOrder.Membership_Renewal_Term__c, o.Membership_Renewal_Term__c))){
            ordersToCheck.add(o.Id);
          }
       }
       if(!ordersToCheck.isEmpty()){
          MembershipService.ManageRenewal(ordersToCheck);
       }
    }

    /*
     * IF an update to an existing order changes the existing Contact to a new Contact
     * Remove all references to the contact-address objects
     */

  public static void handleSoldToContactChange(List<RH_Order__c> orders, Map<Id, RH_Order__c> oldMap) {
    if (oldMap != null) {
      for (RH_Order__c order : orders) {
        if (oldMap.get(order.id).Contact_Sold_To__c != null && order.Contact_Sold_To__c != oldMap.get(order.id).Contact_Sold_To__c) {
          order.Address_Sold_To__c = null;
          order.Address_Bill_To__c = null;          
        } else if (Utility.hasChanges(order, oldMap.get(order.ID), orderSoldToAddressFields)) {
          order.Address_Sold_To__c = null;
        } else if (Utility.hasChanges(order, oldMap.get(order.ID), orderBilltoAddressFields)) {
          order.Address_Bill_To__c = null;          
        }
      }
    }
  }

  /*
   * If an order comes in that doesn't have a contact address - create one.
   * Hide this behind a feature flag - as we may process this by batch job in the future.
   */

  
  public static void buildContactAddressForOrders(List<SObject> recordsToUpdate, List<RH_Order__c> orders, Map<Id, RH_Order__c> oldMap) {
    if (!FeatureFlagService.isSinglePaneAddressFeatureActive()) {
      return;
    }
    List<Rh_Order__c> ordersMissingContactAddress = new List<Rh_Order__c>();
    for (RH_Order__c order : orders) {
      if (order.Contact_Sold_To__c != null && (String.isEmpty(order.Address_Sold_To__c) || String.isEmpty(order.Address_Bill_To__c))) {
        ordersMissingContactAddress.add(order);
      }
    }
    if (ordersMissingContactAddress.size() > 0) {
      try {
        List<Rh_Order__c> soldToOrdersUpdated = ContactAddressService.buildAddressForOrders(ordersMissingContactAddress, ContactAddressService.ORDER_ADDRESS_TYPE.SOLD_TO);
        List<Rh_Order__c> billToOrdersUpdated = ContactAddressService.buildAddressForOrders(ordersMissingContactAddress, ContactAddressService.ORDER_ADDRESS_TYPE.BILL_TO);

        system.debug('OrderService -> buildContactAddressForOrder -> buildAddressForOrder -> sold-to updated ' + soldToOrdersUpdated);
        system.debug('OrderService -> buildContactAddressForOrder -> buildAddressForOrder -> bill-to updated ' + billToOrdersUpdated);
        if (!Utility.isEmpty(soldToOrdersUpdated)) {
          recordsToUpdate.addAll((List<SObject>)soldToOrdersUpdated);
        }
        if (!Utility.isEmpty(billToOrdersUpdated)) {
          recordsToUpdate.addAll((List<SObject>)billToOrdersUpdated);
        }       
      } catch (Exception ex) {
        Utility.logException(ex, ordersMissingContactAddress);
      }
    }
  }

    public static void sendEmail(List<SObject> recordsToupdate, List<RH_Order__c> orders, Map<Id, RH_Order__c> oldMap){
        Set<Id> orderIds = new Set<Id>();
        for(RH_Order__c rho:orders){
            if(rho.EXT_Order_Number__c == rho.Name
            && rho.Billing_Request_Flag__c == 'R'
            && Utility.isChanged(rho.Billing_Request_Flag__c, oldMap.get(rho.Id).Billing_Request_Flag__c)){
                orderIds.add(rho.Id);
            }
        }
        if(!orderIds.isEmpty()){
            for(RH_Order__c o:orders){
               if(orderIds.Contains(o.Id)){
                     BillingSummaryEmail.sendEmail(o.Id, null, true);
               }
            }
        }
    }

    /*
     * Set Fraud Warning on Order Account
     */

    public static void gatherPersonsNeedingFraudWarning(List<SObject> recordsToupdate, List<RH_Order__c> orders, Map<Id, RH_Order__c> oldMap) {
      Set<Id> personAccountIds = new Set<Id>();
      for (RH_Order__c rhOrder : orders) {
        system.debug('process order: ' + rhOrder.Sold_to_Last_Name__c + ':' + rhOrder.Account_Sold_To__c + ':' + rhOrder.fraud_warning__c);
        if (rhOrder.Account_Sold_To__c != null) {
          if (oldMap == null) {
            system.debug('process new order: ' + rhOrder);
            personAccountIds.add(rhOrder.Account_Sold_To__c);
          } else if (rhOrder.fraud_warning__c != oldMap.get(rhOrder.Id).fraud_warning__c) {
            system.debug('process updated order: ' + rhOrder);
            personAccountIds.add(rhOrder.Account_Sold_To__c);
          }
        }
      }
        if (!personAccountIds.isEmpty()) {
        system.debug('process fraud: ' + personAccountIds);
          processFraudWarnings(recordsToupdate, personAccountIds);
        }
    }

    public static void processFraudWarnings(List<SObject> recordsToupdate, Set<Id> personAcctIds) {
      Set<Id> fraudulantAccounts = new Set<ID>();
      List<Account> updateAccounts = new List<Account>();
      system.debug('processFraudWarnings: ' + personAcctIds);
      for (RH_Order__c fraudulantOrders : [SELECT Account_Sold_To__c FROM RH_Order__c WHERE Account_Sold_To__c IN :personAcctIds AND fraud_warning__c = TRUE]) {
        system.debug('processFraudWarnings - record account that has fraudulant order: ' + fraudulantOrders.Account_Sold_To__c);
        fraudulantAccounts.add(fraudulantOrders.Account_Sold_To__c);
      }
        for (Account a:[SELECT Id, fraud_warning__c FROM Account where Id in :personAcctIds]) {
          system.debug('processFraudWarnings - set fraud warning and add to update account list: ' + a.Id);
            a.fraud_warning__c = fraudulantAccounts.contains(a.Id);
            updateAccounts.add(a);
        }
        if (!updateAccounts.isEmpty()) {
          system.debug('processFraudWarnings - updating accounts: ' + updateAccounts[0].fraud_warning__c);
            recordsToUpdate.addAll((List<SObject>)updateAccounts);
        }
    }

 
  public static void gatherPersonsNeedingRollup(List<SObject> recordsToupdate, List<RH_Order__c> orders, Map<Id, RH_Order__c> oldMap, Boolean isInsert, Boolean isUpdate, Boolean isDelete, Boolean isUndelete){
        Set<Id> personAccountIds = new Set<Id>();
        for(RH_Order__c o:orders){
            Decimal orderTotal = (o.Total_Order_Amount__c == null) ? 0.0: o.Total_Order_Amount__c;
            if(isInsert
               && orderTotal > 0.0
               && o.Account_Sold_To__c != null){
                personAccountIds.add(o.Account_Sold_To__c);
            }
            if(isUpdate){
                RH_Order__c oldOrder = oldMap.get(o.Id);
                Decimal oldOrderTotal = (oldOrder.Total_Order_Amount__c == null) ? 0.0: oldOrder.Total_Order_Amount__c;
                if((Utility.isChanged(String.valueOf(oldOrderTotal), String.valueOf(orderTotal))
                    || Utility.isChanged(String.valueOf(oldOrder.Account_Sold_To__c), String.valueOf(o.Account_Sold_To__c))
                    || Utility.isChanged(String.valueOf(oldOrder.Contact_Sold_To__c), String.valueOf(o.Contact_Sold_To__c))
                    || (oldOrder.Account_Sold_To__c == null && o.Account_Sold_To__c != null)
                    || (oldOrder.Contact_Sold_To__c == null && o.Contact_Sold_To__c != null)
                    )
                   && o.Account_Sold_To__c != null){
                    personAccountIds.add(o.Account_Sold_To__c);
                }

            }
            if((isUndelete || isDelete)
                && orderTotal > 0.0
                && o.Account_Sold_To__c != null){
                personAccountIds.add(o.Account_Sold_To__c);
            }
        }
        if (!personAccountIds.isEmpty()) {
                     recordsToupdate.addAll(processRollupForAccountsForBatch(personAccountIds));
        }
    }
    
    @future
    public static void processRollUpForContacts(Set<ID> contactIds) {
        
        system.debug('processRollUpForContacts: ' + contactIds);
        
        List<SObject> contactsToUpdate = new List<SObject>();
        Map<Id, Double> newLifetimeContactValues = new Map<Id, Double>();

        for(RH_Order__c o:[select Account_Sold_To__c
                                 ,Contact_Sold_To__c
                                 ,Total_Order_Amount__c
                            from RH_Order__c
                           where Contact_Sold_To__c in :contactIds
                             and Status__c != 'Cancelled'
                             and Total_Order_Amount__c != null]){


             //Total contact order amounts
            if(newLifetimeContactValues.ContainsKey(o.Contact_Sold_To__c)){
                newLifetimeContactValues.put(o.Contact_sold_to__c, newLifetimeContactValues.get(o.Contact_sold_to__c)  + o.Total_Order_Amount__c);
               // newLifetimeContactValues.put(o.Contact_Sold_To__c, contactsToUpdate.get(o.Contact_Sold_To__c) + o.Total_Order_Amount__c);
            }else{
                newLifetimeContactValues.put(o.Contact_Sold_To__c, o.Total_Order_Amount__c);
            }

        }
            for(Contact c:[SELECT Id, Total_Lifetime_Value__c
                         from Contact
                        where Id in :newLifetimeContactValues.keySet()]){
            c.Total_Lifetime_Value__c = (decimal)newLifetimeContactValues.get(c.Id);
            contactsToUpdate.add((SObject)c);

        }

        update contactsToUpdate;

}

       /* return OrderService.processRollups( [
            SELECT AccountId
            FROM Contact
            WHERE ID IN :contactIds
        ], contactIds); */
    

    @future
    public static void processRollupForAccounts(Set<Id> personAcctIds) {

        system.debug('processing roll ups: ' + personAcctIds.size());

        List<SObject> recordsToupdate = new List<SObject>();
        Map<Id, Double> lifetimePersonValueMap = new Map<Id, Double>();
        Map<Id, Double> lifetimeCompanyValueMap = new Map<Id, Double>();

        for(RH_Order__c o:[select Account_Sold_To__c
                                 ,Contact_Sold_To__c
                                 ,Total_Order_Amount__c
                                 ,Account_Sold_To__r.IsPersonAccount
                            from RH_Order__c
                           where Account_Sold_To__c in :personAcctIds
                             and Status__c != 'Cancelled'
                             and Total_Order_Amount__c != null]){
            // Set Person Rollups
            if(lifetimePersonValueMap.ContainsKey(o.Contact_Sold_To__c)){
                lifetimePersonValueMap.put(o.Contact_Sold_To__c, lifetimePersonValueMap.get(o.Contact_Sold_To__c) + o.Total_Order_Amount__c);
            }else{
                lifetimePersonValueMap.put(o.Contact_Sold_To__c, o.Total_Order_Amount__c);
            }
            // Set Company Rollups
            if(!o.Account_Sold_To__r.IsPersonAccount){
                if(lifetimeCompanyValueMap.ContainsKey(o.Account_Sold_To__c)){
                    lifetimeCompanyValueMap.put(o.Account_Sold_To__c, lifetimeCompanyValueMap.get(o.Account_Sold_To__c) + o.Total_Order_Amount__c);
                }else{
                    lifetimeCompanyValueMap.put(o.Account_Sold_To__c, o.Total_Order_Amount__c);
                }
            }
        }
        for(Contact c:[SELECT Id, Total_Lifetime_Value__c
                         from Contact
                        where Id in :lifetimePersonValueMap.keySet()]){
            c.Total_Lifetime_Value__c = (decimal)lifetimePersonValueMap.get(c.Id);
            recordsToupdate.add((SObject)c);
        }
        for(Account a:[SELECT Id, Total_Company_Lifetime_Value__c
                         from Account
                        where Id in :lifetimeCompanyValueMap.keySet()]){
            a.Total_Company_Lifetime_Value__c = (decimal)lifetimeCompanyValueMap.get(a.Id);
            recordsToupdate.add((SObject)a);
        }
        
        //return recordsToupdate;
        update recordsToupdate;

    }

public static List<sobject> processRollupForAccountsForBatch(Set<Id> personAcctIds) {

        system.debug('processing roll ups: ' + personAcctIds.size());

        List<SObject> recordsToupdate = new List<SObject>();
        Map<Id, Double> lifetimePersonValueMap = new Map<Id, Double>();
        Map<Id, Double> lifetimeCompanyValueMap = new Map<Id, Double>();

        for(RH_Order__c o:[select Account_Sold_To__c
                                 ,Contact_Sold_To__c
                                 ,Total_Order_Amount__c
                                 ,Account_Sold_To__r.IsPersonAccount
                            from RH_Order__c
                           where Account_Sold_To__c in :personAcctIds
                             and Status__c != 'Cancelled'
                             and Total_Order_Amount__c != null]){
            // Set Person Rollups
            if(lifetimePersonValueMap.ContainsKey(o.Contact_Sold_To__c)){
                lifetimePersonValueMap.put(o.Contact_Sold_To__c, lifetimePersonValueMap.get(o.Contact_Sold_To__c) + o.Total_Order_Amount__c);
            }else{
                lifetimePersonValueMap.put(o.Contact_Sold_To__c, o.Total_Order_Amount__c);
            }
            // Set Company Rollups
            if(!o.Account_Sold_To__r.IsPersonAccount){
                if(lifetimeCompanyValueMap.ContainsKey(o.Account_Sold_To__c)){
                    lifetimeCompanyValueMap.put(o.Account_Sold_To__c, lifetimeCompanyValueMap.get(o.Account_Sold_To__c) + o.Total_Order_Amount__c);
                }else{
                    lifetimeCompanyValueMap.put(o.Account_Sold_To__c, o.Total_Order_Amount__c);
                }
            }
        }
        for(Contact c:[SELECT Id, Total_Lifetime_Value__c
                         from Contact
                        where Id in :lifetimePersonValueMap.keySet()]){
            c.Total_Lifetime_Value__c = (decimal)lifetimePersonValueMap.get(c.Id);
            recordsToupdate.add((SObject)c);
        }
        for(Account a:[SELECT Id, Total_Company_Lifetime_Value__c
                         from Account
                        where Id in :lifetimeCompanyValueMap.keySet()]){
            a.Total_Company_Lifetime_Value__c = (decimal)lifetimeCompanyValueMap.get(a.Id);
            recordsToupdate.add((SObject)a);
        }
        
        return recordsToupdate;
        //update recordsToupdate;

    }

   

    public static void CopyToRelatedCases(List<SObject> recordsToupdate, List<RH_Order__c> orders, Map<Id, RH_Order__c> oldMap){
        // Determine if there is updated order data to copy to related cases
        List<CasetoOrderFieldMapping__c> caseToRHOMapping = CasetoOrderFieldMapping__c.getall().values();
        Map<Id,RH_Order__c> mIdOrder = new Map<Id,RH_Order__c>();
        Map<Id,RH_Order__c> mIdOrderOld = new Map<Id,RH_Order__c>();

        for (RH_Order__c o :orders) {

            for (CasetoOrderFieldMapping__c cofm :caseToRHOMapping) {
                if (o.get(cofm.Order_Field__c) != oldMap.get(o.Id).get(cofm.Order_Field__c)) {
                    mIdOrder.put(o.Id, o);
                    mIdOrderOld.put(o.Id, oldMap.get(o.Id));
                }
            }
        }

        // Update related cases with new order data
        if (mIdOrder.size() > 0 && mIdOrderOld.size() > 0) {
            UpdateCaseFromRHOrder.updateCase(recordsToupdate, mIdOrder, mIdOrderOld);
        }
    }

    public static void setOrderFieds(List<RH_Order__c> orders){
        for (RH_Order__c o :orders) {
            o.Order_Type_Category__c = DelayedOrderActions.getOrderTypeCategory(o.Order_Type_Code__c);
            if (o.Membership_Expiration_Date__c == null && o.Membership_Enrollment_Date__c != null) {
                o.Membership_Expiration_Date__c = o.Membership_Enrollment_Date__c.addYears(1);
            }
        }
    }


    // Update state of related open Delay Notification cases
    public static void updateDNCases(List<SObject> recordsToupdate, List<RH_Order__c> orders, Map<Id, RH_Order__c> oldMap) {
      Set<Id> oIds = new Set<Id>();

      for (RH_Order__c o :orders) {
        if (o.Status__c != oldMap.get(o.Id).Status__c) {
          oIds.add(o.Id);
        }
      }

      if (!oIds.isEmpty()) {
        DelayedOrderActions.updateDelayNotificationCases(recordsToupdate, oIds);
      }
    }

     public static void processDAOrders(List<SObject> recordsToupdate, List<RH_Order__c> orders,  Map<Id, RH_Order__c> oldMap, Boolean isInsert) {
        Set<Id> oIds = new Set<Id>();
        Set<String> qIds = new Set<String>();

        for (RH_Order__c o :orders) {
            if(o.opportunity_record_type__c == 'Design_Atelier' || (!isInsert && o.opportunity_record_type__c == null && oldMap.get(o.Id).opportunity_record_type__c =='Design_Atelier')){
                if (isInsert) {
                    if (o.Opportunity__c != null) {
                        oIds.add(o.Opportunity__c);
                    }
                    if (String.isNotBlank(o.Quote_Id__c)) {
                        qIds.add(o.Quote_Id__c);
                    }
                } else {
                    if ((o.Merchandise_Subtotal__c != oldMap.get(o.Id).Merchandise_Subtotal__c && o.Opportunity__c != null)||(o.DA_Order_Update__c)) {
                        oIds.add(o.Opportunity__c);
                    }
                    if (o.Opportunity__c != oldMap.get(o.Id).Opportunity__c) {
                        if (o.Opportunity__c != null) {
                            oIds.add(o.Opportunity__c);
                        }
                        if (oldMap.get(o.Id).Opportunity__c != null) {
                            oIds.add(oldMap.get(o.Id).Opportunity__c);
                        }
                    }
                    if (o.Quote_Id__c != oldMap.get(o.Id).Quote_Id__c) {
                        if (String.isNotBlank(o.Quote_Id__c)) {
                            qIds.add(o.Quote_Id__c);
                        }
                        if (String.isNotBlank(oldMap.get(o.Id).Quote_Id__c)) {
                            qIds.add(oldMap.get(o.Id).Quote_Id__c);
                        }
                    }
                }
            }
        }


        // Get all the opportunities and quotes that need to be updated and all the orders associated with our opportunities and quotes
        List<Opportunity> oppList = new List<Opportunity>();
        List<Design_Atelier_Quote__c> daQuoteList = new List<Design_Atelier_Quote__c>();
        List<RH_Order__c> orderOList = new List<RH_Order__c>();
        List<RH_Order__c> orderQList = new List<RH_Order__c>();
        if (!oIds.isEmpty()) {
            oppList = [select Id, Total_Order_Amount__c from Opportunity where Id in :oIds];
            orderOList = [select Id, Opportunity__c, Quote_Id__c, Merchandise_Subtotal__c
                from RH_Order__c where Opportunity__c in :oIds];
        }
        if (!qIds.isEmpty()) {
            daQuoteList = [select Id, Converted__c, Quote_Id__c from Design_Atelier_Quote__c where Quote_Id__c in :qIds];
            orderQList = [select Id, Opportunity__c, Quote_Id__c, Merchandise_Subtotal__c
                from RH_Order__c where Quote_Id__c in :qIds];
        }

        // Create one map of all orders associated with our opportunities and quotes
        Map<Id, RH_Order__c> oMap = new Map<Id, RH_Order__c>();
        for (RH_Order__c o : orderOList) {
          oMap.put(o.Id, o);
        }
        for (RH_Order__c o : orderQList) {
          oMap.put(o.Id, o);
        }

        // Calculate the new Order Total Amount for each Opportunity
        Map<Id, Double> oppToOrderTotalMap = new Map<Id, Double>();
        Map<String, RH_Order__c> quoteToOrderMap = new Map<String, RH_Order__c>();
        for (RH_Order__c o :oMap.values()) {
            if (oIds.contains(o.Opportunity__c)) {
                if (oppToOrderTotalMap.containsKey(o.Opportunity__c)) {
                    oppToOrderTotalMap.put(o.Opportunity__c, oppToOrderTotalMap.get(o.Opportunity__c) + o.Merchandise_Subtotal__c);
                } else {
                    oppToOrderTotalMap.put(o.Opportunity__c, o.Merchandise_Subtotal__c);
                }
            }
            if (qIds.contains(o.Quote_Id__c)) {
                quoteToOrderMap.put(o.Quote_Id__c, o);
            }
        }

        for (Opportunity o :oppList) {
            if (oppToOrderTotalMap.containsKey(o.Id)) {
                o.Total_Order_Amount__c = oppToOrderTotalMap.get(o.Id);
            } else {
                o.Total_Order_Amount__c = 0;
            }
        }

        // Determine converted status for each DA quote
        for (Design_Atelier_Quote__c q :daQuoteList) {
            if (quoteToOrderMap.containsKey(q.Quote_Id__c)) {
                q.Converted__c = true;
            } else {
                q.Converted__c = false;
            }
        }

        // update the opportunities and quotes
        if (!oppList.isEmpty()) {
            recordsToUpdate.addAll((List<SObject>)oppList);
        }

        if (!daQuoteList.isEmpty()) {
            recordsToUpdate.addAll((List<SObject>)daQuoteList);
        }
    }

    // Update Tax Exempt Verification flag on related Accounts
    public static void accountTaxExemptVerification(List<SObject> recordsToupdate, List<RH_Order__c> orders, Map<Id, RH_Order__c> oldMap, Boolean isInsert) {
        Set<Id> aIds = new Set<Id>();

        // Get the Account Ids for order that are being processed
        for (RH_Order__c o :orders) {
            if (o.Status__c == 'Open' || o.Status__c == 'In Process' || o.Status__c == 'Held') {
                if (o.Account_Sold_To__c != null) {
                    if (isInsert) {
                        aIds.add(o.Account_Sold_To__c);
                    } else {
                        if (String.isNotBlank(o.Tax_Exempt__c) && o.Tax_Exempt__c != oldMap.get(o.Id).Tax_Exempt__c) {
                            aIds.add(o.Account_Sold_To__c);
                        }
                    }
                }
            }
        }

        if (!aIds.isEmpty()) {
            Map<Id, Account> accMap = new Map<Id, Account>([select Id, Verify_Tax_Exempt_Credentials__c from Account where Id in :aIds]);
            Map<Id, Account> accUpMap = new Map<Id, Account>();

            if (isInsert) {

                // Get all to orders being processed related to our list of Accounts
                List<RH_Order__c> orderList = new List<RH_Order__c>();
                orderList = [select Id, Account_Sold_To__c, Tax_Exempt__c from RH_Order__c
                        where Account_Sold_To__c in :aIds and (Status__c = 'Open' or Status__c = 'In Process' or Status__c = 'Held')];

                // Create a map with a list of orders related to each Account
                Map<Id, List<RH_Order__c>> accToOrderMap = new Map<Id, List<RH_Order__c>>();
                for (RH_Order__c o :orderList) {
                    if (!accToOrderMap.containsKey(o.Account_Sold_To__c)) {
                        accToOrderMap.put(o.Account_Sold_To__c, new List<Rh_Order__c>());
                    }
                    accToOrderMap.get(o.Account_Sold_To__c).add(o);
                }

                Boolean taxExempt;
                for (RH_Order__c o :orders) {
                    if (accMap.containsKey(o.Account_Sold_To__c)) {

                        // If tax exempt order, set Account flag true
                        if (String.isNotBlank(o.Tax_Exempt__c)) {
                            accMap.get(o.Account_Sold_To__c).Verify_Tax_Exempt_Credentials__c = true;
                            accUpMap.put(o.Account_Sold_To__c, accMap.get(o.Account_Sold_To__c));

                        } else {

                            // If non-tax exempt order, set Account flag false if no orders being processed related to Account are tax exempt
                            if (accToOrderMap.containsKey(o.Account_Sold_To__c)) {
                                taxExempt = false;
                                for (RH_Order__c accO :accToOrderMap.get(o.Account_Sold_To__c)) {
                                    if (String.isNotBlank(accO.Tax_Exempt__c)) {
                                        taxExempt = true;
                                    }
                                }
                                accMap.get(o.Account_Sold_To__c).Verify_Tax_Exempt_Credentials__c = taxExempt;
                                accUpMap.put(o.Account_Sold_To__c, accMap.get(o.Account_Sold_To__c));
                            }
                        }
                    }
                }

            } else {

                // If order tax exemption has changed and it is tax exempt, set Account flag true
                for (RH_Order__c o :orders) {
                    if (accMap.containsKey(o.Account_Sold_To__c)) {
                        if (String.isNotBlank(o.Tax_Exempt__c)) {
                            accMap.get(o.Account_Sold_To__c).Verify_Tax_Exempt_Credentials__c = true;
                            accUpMap.put(o.Account_Sold_To__c, accMap.get(o.Account_Sold_To__c));
                        }
                    }
                }
            }

            if (!accUpMap.isEmpty()) {
                recordsToUpdate.addAll((List<SObject>)accUpMap.values());
            }
        }
    }

  public static void linkMembership(List<SObject> recordsToupdate, List<RH_Order__c> orders, Map<Id, RH_Order__c> oldMap){

    Set<String> membershipNames = new Set<String>();

    // Get a list of all the membership names that have been newly referenced, or newly dereferenced, or referenced with a new contact

    for (RH_Order__c order :orders) {
      if (order.Membership_ID__c != null && (oldMap == null || oldMap.get(order.id).Membership_ID__c == null)) {
        // new membership reference
        membershipNames.add(order.Membership_ID__c);
      } else if (order.Membership_ID__c == null && oldMap != null && oldMap.get(order.id).Membership_ID__c != null) {
        // membership de-referenced
          membershipNames.add(oldMap.get(order.id).Membership_ID__c);
            } else if (order.Membership_ID__c != null && order.Contact_Sold_To__c != null && (oldMap == null || oldMap.get(order.id).Contact_Sold_To__c == null)) {
              // contact sold to changed (and member referenced)
              membershipNames.add(order.Membership_ID__c);
            }
    }

    // Turn that list of membership names into a map

    List<Membership__c> membersReferenced = [
      SELECT ID, Name, Created_By_Order_ID__c, Created_by_Alternate_Order_ID__c, Contact__c
      FROM Membership__c
      WHERE Name in :membershipNames
    ];

    Map<String, Membership__c> memberNameMap = new Map<String, Membership__c>();
    for (Membership__c m : membersReferenced) {
      memberNameMap.put(m.Name, m);
    }

    // Go through all the orders

    for (RH_Order__c order : orders) {

            // handle when a member with that name doesn't exist
            // this ONLY happens when badly written unit tests are run.

            if (!memberNameMap.containsKey(order.Membership_ID__c)) {
                continue;
            }

      // new membership associated with this order

      if (order.Membership_ID__c != null && (oldMap == null || oldMap.get(order.id).Membership_ID__c == null)) {

          // associate the order with the member record

          recordsToUpdate.add(new RH_Order__c(
            ID = order.Id,
            Membership_ID_Lookup__c = memberNameMap.get(order.Membership_ID__c).Id
        ));

          // associate the member with this order (if not associated with one already)

          if (memberNameMap.get(order.Membership_ID__c).Created_By_Order_ID__c == null) {
            recordsToUpdate.add(new Membership__c(
              ID = memberNameMap.get(order.Membership_ID__c).Id,
              Created_By_Order_ID__c = order.Id
            ));
          }

      } else if (order.Membership_ID__c == null && oldMap != null && oldMap.get(order.id).Membership_ID__c != null) {

        // order now does not have a member id associated with it

          recordsToUpdate.add(new RH_Order__c(
            ID = order.Id,
            Membership_ID_Lookup__c = null
        ));

        // do we now un-associate that member with this order ??

        if (memberNameMap.get(oldMap.get(order.id).Membership_ID__c).Created_By_Order_ID__c == order.Id) {
            recordsToUpdate.add(new Membership__c(
              ID = memberNameMap.get(oldMap.get(order.id).Membership_ID__c).Id,
              Created_By_Order_ID__c = null
            ));
          }

            }

            // if this order has a member id and has a contact (that's changed)
            // lets try and associate the member with the order contact

            if (order.Membership_ID__c != null && order.Contact_Sold_To__c != null && (oldMap == null || oldMap.get(order.id).Contact_Sold_To__c == null)) {
              if (memberNameMap.get(order.Membership_ID__c).Contact__c == null) {
            recordsToUpdate.add(new Membership__c(
              ID = memberNameMap.get(order.Membership_ID__c).Id,
              Contact__c = order.Contact_Sold_To__c
            ));
            recordsToUpdate.add(new Contact(
              ID = order.Contact_Sold_To__c,
              Has_Membership__c = TRUE
            ));
              }
            }
    }
    }

  // Associate existing Operations Request records with Orders when the Operations Request and Order records reference the same Opportunity.
  // NOTE: this assumes a one to one relationship between Orders and Opportunities.
  public static void operationsRequest(List<SObject> recordsToupdate, List<RH_Order__c> newList,  Map<Id, RH_Order__c> oldMap, Boolean isInsert) {
    Set<Id> oppIds = new Set<Id>();

    for (RH_Order__c o :newList) {
      if (isInsert) {
        if (o.Opportunity__c != null) {
          oppIds.add(o.Opportunity__c);
        }
      } else {
        if (o.Opportunity__c != oldMap.get(o.Id).Opportunity__c) {
          if (o.Opportunity__c != null) {
            oppIds.add(o.Opportunity__c);
          }
          if (oldMap.get(o.Id).Opportunity__c != null) {
            oppIds.add(oldMap.get(o.Id).Opportunity__c);
          }
        }
      }
    }

    if (!oppIds.isEmpty()) {

      // Create map of Opportunity Id to List of Operations Request records
      List<Operations_Request__c> operationsRequestList = new List<Operations_Request__c>();
      operationsRequestList = [select Id, Name, Opportunity__c, Order__c from Operations_Request__c where Opportunity__c in :oppIds];
      Map<Id, List<Operations_Request__c>> oppToOpRequestMap = new Map<Id, List<Operations_Request__c>>();
      for (Operations_Request__c opr :operationsRequestList) {
        if (!oppToOpRequestMap.containsKey(opr.Opportunity__c)) {
          oppToOpRequestMap.put(opr.Opportunity__c, new List<Operations_Request__c>());
        }
        oppToOpRequestMap.get(opr.Opportunity__c).add(opr);
      }

      // Iterate through the trigger orders and associate the Operations Request records with the same Opportunity as the Order, with the Order
      Map<Id, Operations_Request__c> oppReqMap = new Map<Id, Operations_Request__c>();
      Boolean clearOld;
      Boolean setNew;
      for (RH_Order__c o :newList) {

        if (isInsert) {
          if (oppToOpRequestMap.containsKey(o.Opportunity__c)) {
            for (Operations_Request__c opr :oppToOpRequestMap.get(o.Opportunity__c)) {
              opr.Order__c = o.Id;
              oppReqMap.put(opr.Id, opr);
            }
          }
        }

        if (!isInsert) {
          if (oppToOpRequestMap.containsKey(oldMap.get(o.Id).Opportunity__c)) {
            for (Operations_Request__c opr :oppToOpRequestMap.get(oldMap.get(o.Id).Opportunity__c)) {
              opr.Order__c = null;
              oppReqMap.put(opr.Id, opr);
            }
          }

          if (oppToOpRequestMap.containsKey(o.Opportunity__c)) {
            for (Operations_Request__c opr :oppToOpRequestMap.get(o.Opportunity__c)) {
              opr.Order__c = o.Id;
              oppReqMap.put(opr.Id, opr);
            }
          }
        }
      }

      if (!oppReqMap.isEmpty()) {
        recordsToUpdate.addAll((List<SObject>)oppReqMap.values());
      }
    }
  }

  /*
   * Handle any sold-to or bill-to address change
   */
   
    private static @testVisible Set<Schema.SObjectField> soldToAddressFields = new Set<Schema.SObjectField> {
    Rh_Order__c.Sold_to_Name__c,
    Rh_Order__c.Sold_To_Company__c,
    Rh_Order__c.Sold_to_Address_1__c,
    Rh_Order__c.Sold_to_Address_2__c,
    Rh_Order__c.Sold_to_Address_3__c,
    Rh_Order__c.Sold_to_Address_4__c,
    Rh_Order__c.Sold_to_City__c,
    Rh_Order__c.Sold_to_State__c,
    Rh_Order__c.Sold_to_Zip__c,
    Rh_Order__c.Sold_to_Country__c
    };
    
  private static @testVisible Set<Schema.SObjectField> billToAddressFields = new Set<Schema.SObjectField> {
    Rh_Order__c.Bill_to_Name__c,
    Rh_Order__c.Bill_To_Company__c,
    Rh_Order__c.Bill_to_Address_1__c,
    Rh_Order__c.Bill_to_Address_2__c,
    Rh_Order__c.Bill_to_Address_3__c,
    Rh_Order__c.Bill_to_Address_4__c,
    Rh_Order__c.Bill_to_City__c,
    Rh_Order__c.Bill_to_State__c,
    Rh_Order__c.Bill_to_Zip__c,
    Rh_Order__c.Bill_to_Country__c
    };
   
    public static void handleAddressChange(List<Rh_Order__c> orders, Map<Id, Rh_Order__c> oldMap) {
      
      system.debug('OrderService -> handleAddressChange -> ' + orders);
      
        for (Rh_Order__c order : orders) {
            if (oldMap == null || Utility.hasChanges(order, oldMap.get(order.id), soldToAddressFields)) {
              system.debug('OrderService -> handleAddressChange -> setting Sold_To_Contact_Address__c -> ' + order);
                order.Sold_To_Contact_Address__c = Utility.aggregateFields(order, soldToAddressFields, ', ');  
            }
            if (oldMap == null || Utility.hasChanges(order, oldMap.get(order.id), billToAddressFields)) {
              system.debug('OrderService -> handleAddressChange -> setting Bill_To_Contact_Address__c -> ' + order);
                order.Bill_To_Contact_Address__c = Utility.aggregateFields(order, billToAddressFields, ', ');  
            }                
        }   
    }
    
    // If the system hold code on the order was just changed from a CCD declined code to null and the order is a
    // membership auto-renewal order, update the membership record and close the CCD case
    // - after update
    public static void updateCCDMembership(List<SObject> recordsToupdate, List<RH_Order__c> newList, Map<Id, RH_Order__c> oldMap) {
      Set<Id> oIds = new Set<Id>();
      Set<Id> mIds = new Set<Id>();
      Set<String> ccdHoldCodes = new Set<String>();
      
      ccdHoldCodes.addAll(Application_Settings__c.getInstance('CCD System Hold Codes').Value_Text__c.split(',', 0));
      for (RH_Order__c o :newList) {
        if (String.isBlank(o.System_Hold_code__c) && String.isNotBlank(oldMap.get(o.Id).System_Hold_Code__c) && o.Status__c != 'Cancelled') {
          if (ccdHoldCodes.contains(oldMap.get(o.Id).System_Hold_Code__c) && o.Membership_ID_Lookup__c != null) {
            if (o.Number_of_Order_Lines__c > 0 && o.Number_of_Order_Lines__c == o.Number_of_MembershipAutoRenewalSKUs__c) {
              oIds.add(o.Id);
              mIds.add(o.Membership_ID_Lookup__c);
            }
          }
        }
      }
      
      // Update the membership records and membership auto-renewal CCD cases to reflect the Order coming off hold
      if (!mIds.isEmpty()) {
        List<Membership__c> memberList = new List<Membership__c>();
        memberList = [select Id, Name, AutoRenew_CCD_Order_Number__c, Cancellation_Reason__c, Cancellation_Type__c from Membership__c where Id in :mIds];
        for (Membership__c m :memberList) {
          m.Cancellation_Reason__c = '';
            m.Cancellation_Type__c = '';
            m.AutoRenew_CCD_Order_Number__c = '';
        }
        
        Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
        List<Case> caseList = new List<Case>();
        caseList = [select Id, CaseNumber, RecordTypeId, Status, RH_Order_Number__c from Case 
            where RH_Order_Number__c in :oIds and 
            RecordTypeId = :rtMap.get('Credit Card Declines').getRecordTypeId() and 
            IsClosed = false];
        for (Case c :caseList) {
          c.Status = 'Closed - Successful';
        }
        
        if (!caseList.isEmpty()) {
          recordsToUpdate.addAll((List<SObject>)caseList);
        }
        
        if (!memberList.isEmpty()) {
          recordsToUpdate.addAll((List<SObject>)memberList);
        }
      }
    }



/*public static List<sobject> processRollups(  List<SObject> recordsToupdate, Set<Id> personAcctIds){

        system.debug('processing roll ups: ' + personAcctIds.size());

        List<Contact> updateContacts = new List<Contact>();
        List<Account> updateAccounts = new List<Account>();
        Map<Id, Double> lifetimePersonValueMap = new Map<Id, Double>();
        Map<Id, Double> lifetimeCompanyValueMap = new Map<Id, Double>();

        for(RH_Order__c o:[select Account_Sold_To__c
                                 ,Contact_Sold_To__c
                                 ,Total_Order_Amount__c
                                 ,Account_Sold_To__r.IsPersonAccount
                            from RH_Order__c
                           where Account_Sold_To__c in :personAcctIds
                             and Status__c != 'Cancelled'
                             and Total_Order_Amount__c != null]){
            // Set Person Rollups
            if(lifetimePersonValueMap.ContainsKey(o.Contact_Sold_To__c)){
                lifetimePersonValueMap.put(o.Contact_Sold_To__c, lifetimePersonValueMap.get(o.Contact_Sold_To__c) + o.Total_Order_Amount__c);
            }else{
                lifetimePersonValueMap.put(o.Contact_Sold_To__c, o.Total_Order_Amount__c);
            }
            // Set Company Rollups
            if(!o.Account_Sold_To__r.IsPersonAccount){
                if(lifetimeCompanyValueMap.ContainsKey(o.Account_Sold_To__c)){
                    lifetimeCompanyValueMap.put(o.Account_Sold_To__c, lifetimeCompanyValueMap.get(o.Account_Sold_To__c) + o.Total_Order_Amount__c);
                }else{
                    lifetimeCompanyValueMap.put(o.Account_Sold_To__c, o.Total_Order_Amount__c);
                }
            }
        }
        for(Contact c:[SELECT Id, Total_Lifetime_Value__c
                         from Contact
                        where Id in :lifetimePersonValueMap.keySet()]){
            c.Total_Lifetime_Value__c = (decimal)lifetimePersonValueMap.get(c.Id);
            updateContacts.add(c);
        }
        for(Account a:[SELECT Id, Total_Company_Lifetime_Value__c
                         from Account
                        where Id in :lifetimeCompanyValueMap.keySet()]){
            a.Total_Company_Lifetime_Value__c = (decimal)lifetimeCompanyValueMap.get(a.Id);
            updateAccounts.add(a);
        }
        if(!updateAccounts.isEmpty()){
            recordsToUpdate.addAll((List<SObject>)updateAccounts);
        }
        if(!updateContacts.isEmpty()){
            recordsToUpdate.addAll((List<SObject>)updateContacts);
        }
        return recordsToUpdate;
    }*/

}