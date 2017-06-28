@isTest
public with sharing class OpportunityServiceTest {

    @isTest
    public static void cloneOpportunityWithAttachments_UnitTest() {
        
        // Create test Account and insert
        Account testAccount = PrepareData.createAccount();
        insert testAccount;
        
        // Create test Contact and insert
        Contact testContact = PrepareData.createContact(testAccount.Id);
        insert testContact;
        
        // Create test Opportunity and insert
        Opportunity testOppty = PrepareData.createOpportunity(testAccount.Id);
        insert testOppty;
        
        // Create test Attachment and associate with test Opportunity
        Attachment testAttach = new Attachment();       
        testAttach.Name = 'Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        testAttach.body = bodyBlob;
        testAttach.parentId = testOppty.id;
        insert testAttach;
        
        // Create test Note and associate with test Opportunity
        Note testNote = new Note();
        testNote.Title = 'Unit Test Note';
        testNote.body = 'Unit Test Note Body';
        testNote.parentId = testOppty.id;
        insert testNote;
        
        // Clone test Opportunity and insert    
        Opportunity clonedTestOppty = testOppty.clone(false,true);
        clonedTestOppty.Cloned_Parent_Id__c = testOppty.Id;
        insert clonedTestOppty;
        
        // Evaluate assertions
        List<Attachment> attachments = [select id, name from Attachment where parent.Id = :clonedTestOppty.Id];
        List<Note> notes = [select id, title from Note where parent.Id = :clonedTestOppty.Id];
        
        System.assertEquals(1, attachments.size());
        System.assertEquals(1, notes.size());
    }
    
    @isTest
    public static void updateProjectFields_UnitTest() {
    
      
        // Create test Account and insert
        Account testAccount = PrepareData.createAccount();
        insert testAccount;
        
        // Create test Contact and insert
        Contact testContact = PrepareData.createContact(testAccount.Id);
        insert testContact;
        
        // Create test Project and insert
        Project__c testProject = new Project__c();
        testProject.Account__c = testAccount.Id;
        insert testProject;
        
        // Create test Opportunity and insert
        Opportunity testOppty = PrepareData.createOpportunity(testAccount.Id);
        testOppty.Parent_Project__c = testProject.Id;
        testOppty.Amount = 3333333;
        insert testOppty;
        
        testOppty = [Select Id, Amount, Probability, Blended_MMU__c, Total_Discount_Percent__c, Total_Project_Amount__c, Project_Avg_Probability__c, Project_Avg_MMU__c, Project_Avg_Discount__c from Opportunity where Id = :testOppty.Id];
        
        //Assertions
        System.assertEquals(testOppty.Amount, testOppty.Total_Project_Amount__c);
    }       
}