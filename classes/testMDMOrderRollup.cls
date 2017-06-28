@isTest
private class testMDMOrderRollup {

    static Account p;
    static Account ba;
    static Contact baCon;
    static Account personAccount;
    static RH_Order__c o;
    static RH_Order__c o2;
    static RH_Order__c oBusiness;

    static void setup(){
        
        PrepareData.populateCustomSettings();
        
        p = TestDataFactory.createPersonAccount(true);
        o = TestDataFactory.createRhOrder(false);
        o.Account_Sold_To__c = p.Id;
        personAccount = [select Id, PersonContactId, IsPersonAccount from Account where Id = :p.Id];
        o.Contact_Sold_To__c = personAccount.PersonContactId;
        o.Total_Order_Amount__c = 200.0;
        o.Status__c = 'Closed';
        insert o;            
    }
    
    static void setupBusinessAccount(){
        
        PrepareData.populateCustomSettings();
        
        ba = TestDataFactory.createAccount(true);
        baCon = TestDataFactory.createContacts(1, false)[0];
        baCon.AccountId = ba.Id;
        insert baCon;
        //
        oBusiness = TestDataFactory.createRhOrder(false);
        oBusiness.Account_Sold_To__c = ba.Id;
        oBusiness.Contact_Sold_To__c = baCon.Id;
        oBusiness.Total_Order_Amount__c = 200.0;
        oBusiness.Status__c = 'Closed';
        insert oBusiness;            
    }

    static testMethod void testOrderRollups() {
        
        Test.startTest();
        setup();
        o.Total_Order_Amount__c = 300.0;
        update o;             
        Test.stopTest();
       
        Account aPostRollup = [SELECT Id, PersonContactId, PersonContact.Total_Lifetime_Value__c from Account WHERE Id = :p.Id];
        System.AssertEquals(aPostRollup.PersonContact.Total_Lifetime_Value__c, 300.0);
         
    }

    static testMethod void testOrderRollupsCompany() {
        
        Test.startTest();
        setupBusinessAccount();   
        oBusiness.Total_Order_Amount__c = 900.0;
        update oBusiness;             
        Test.stopTest();
        
        Account aPostRollup = [SELECT Id, Total_Company_Lifetime_Value__c from Account WHERE Id = :ba.Id];
        System.AssertEquals(aPostRollup.Total_Company_Lifetime_Value__c, 900.0);
         
    }
        
    static testMethod void testOrderRollupsDelete() {
        
        Test.startTest();
        setup();   
        o2 = TestDataFactory.createRhOrder(false);
        o2.Account_Sold_To__c = p.Id;
        o2.Contact_Sold_To__c = personAccount.PersonContactId;
        o2.Total_Order_Amount__c = 500.0;
        o2.Status__c = 'Closed';
        insert o2;
        delete o2;                     
        Test.stopTest();
        
        Account aPostRollup = [SELECT Id, PersonContact.Total_Lifetime_Value__c from Account WHERE Id = :p.Id];
        System.AssertEquals(aPostRollup.PersonContact.Total_Lifetime_Value__c, 200.0);
        
    }  
    
    static testMethod void testOrderRollupsUndelete() {
        
        Test.startTest();
        setup();   
        o2 = TestDataFactory.createRhOrder(false);
        o2.Account_Sold_To__c = p.Id;
        o2.Contact_Sold_To__c = personAccount.PersonContactId;
        o2.Total_Order_Amount__c = 500.0;
        o2.Status__c = 'Closed';
        insert o2;
        delete o2;
        undelete o2;                     
        Test.stopTest();
        
        Account aPostRollup = [SELECT Id, PersonContact.Total_Lifetime_Value__c from Account WHERE Id = :p.Id];
        System.AssertEquals(aPostRollup.PersonContact.Total_Lifetime_Value__c, 700.0);
        
    }       
        
}