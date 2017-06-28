/*
 *  Methods to test MyTasks_CSC.cls and TaskTrigger.trigger
 *
 */
 
@isTest(SeeAllData=true)
private class testMyTasks_CSC {
    
    static testMethod void mtTest1() {
        
        // Initialize test date
        String orderNumber = 'mtT1O1';
        RH_Order__c order = PrepareData.createOrder(orderNumber);
        insert order;
        
        List<Case> cList = new List<Case>();
        cList.add(new Case(
            OwnerId = UserInfo.getUserId(),
            Request_Category__c = 'Gift Card',
           // Queue_Type__c = 'Accommodations',
            Send_to_First_Name__c = 'Bob',
            Send_to_Last_Name__c = 'Jones',
            Send_to_City__c = 'Santa Cruz',
            Send_to_State__c = 'CA',
            Send_to_Zip__c = '94500',
            Send_to_Country__c = 'USA',
            Send_to_Day_Phone__c = '555-555-5555',
            RH_Order_Number__c = order.Id)
        );
        insert cList;
        
        List<Task> tList = new List<Task>();
        Map<String, Schema.RecordTypeInfo> tRtMap = Schema.SObjectType.Task.getRecordTypeInfosByName();
        Task t1 = PrepareData.createTask(System.today().addDays(30), 'Not Started', 'Test Task', cList[0].Id, tRtMap.get('Standard').getRecordTypeId());
        t1.Contact_Type__c = 'Sold To';
        tList.add(t1);
        t1 = PrepareData.createTask(System.today().addDays(30), 'Not Started', 'Test Task', cList[0].Id, tRtMap.get('Standard').getRecordTypeId());
        t1.Contact_Type__c = 'Ship To 1';
        tList.add(t1);
        t1 = PrepareData.createTask(System.today().addDays(30), 'Not Started', 'Test Task', cList[0].Id, tRtMap.get('Standard').getRecordTypeId());
        t1.Contact_Type__c = 'Send To';
        tList.add(t1);
        t1 = PrepareData.createTask(System.today().addDays(30), 'Not Started', 'Test Task', cList[0].Id, tRtMap.get('Standard').getRecordTypeId());
        tList.add(t1);
        t1 = PrepareData.createTask(System.today().addDays(30), 'Not Started', 'Test Task', cList[0].Id, tRtMap.get('Standard').getRecordTypeId());
        tList.add(t1);
        
        insert tList;
        
        ApexPages.StandardController std = new ApexPages.StandardController(tList[0]);
        MyTasks_CSC ctl = new MyTasks_CSC(std);
        
        String disp = ctl.getdisplaySelected();
        system.assertEquals('All Open', disp);
        List<Task> tctlList;
        tctlList = ctl.gettaskList();
        ctl.setdisplaySelected('Overdue');
        tctlList = ctl.gettaskList();
        ctl.setdisplaySelected('Due Today');
        tctlList = ctl.gettaskList();
        ctl.setdisplaySelected('Tomorrow');
        tctlList = ctl.gettaskList();
        ctl.setdisplaySelected('Next 7 Days');
        tctlList = ctl.gettaskList();
        ctl.setdisplaySelected('This Month');
        tctlList = ctl.gettaskList();
        ctl.setdisplaySelected('All Completed');
        tctlList = ctl.gettaskList();
    }
    
     static testMethod void lacTest(){
        
        //Create test Account and insert
        Account testAccount = PrepareData.createAccount();
        insert testAccount;
        
        // Create test Contact and insert
        Contact testContact = PrepareData.createContact(testAccount.Id);
        insert testContact;
        
        // Create test Log A Call Task and insert
        
        Id testUser = UserInfo.getUserId();
        Id testRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CSC InMoment Survey').getRecordTypeId();
        
        Task testLogACallTask = new Task(WhatId = testAccount.Id, WhoId = testContact.Id, InMoment_Interaction_Type__c = 'Inbound Call', InMoment_Who__c = 'Customer', InMoment_Reason__c = 'Gallery Inquiry', Status = 'Not Started', Priority = 'Medium', RecordTypeId = testRecordTypeId);
        
        insert testLogACallTask;
        // Validate
        
        testLogACallTask = [Select Id, InMoment_Survey_Status__c from Task where Id = : testLogACallTask.Id];
        System.assertEquals(testLogACallTask.InMoment_Survey_Status__c, 'Sent');
    }  
}