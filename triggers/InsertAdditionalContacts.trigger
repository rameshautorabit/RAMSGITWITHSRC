trigger InsertAdditionalContacts on Contact (after insert) 
{
            
    List<Contact> additionalContacts = new List<Contact>();
    List<Id> accountIds = new List<Id>();
    List<Contact> currentContacts = new List<Contact>();
    Map<String,Contact> currentContactsMap = new Map<String,Contact>();
    
    for (Contact c : Trigger.new)
    {
    	if (c.AccountId <> null) {
        	accountIds.add(c.AccountId);
    	}        
    }
    
    if (accountIds.isEmpty()) {
    	return;
    }
    
    currentContacts = [select Id, AccountId, LastName, FirstName from Contact where AccountId in :accountIds];
    
    // CREATE A MAP OF CURRENT CONTACTS FOR THE ACCOUNTS, KEYED ON ACCOUNTID, LAST AND FIRST NAME
    
    for (Contact c : currentContacts)
    {
        currentContactsMap.put(c.AccountId + c.LastName + c.FirstName, c);
    }
        
    for (Contact c : Trigger.new)
    {
        if (c.AccountId <> null)
        {
            //  INSERT ONLY IF NEW CONTACT DOES NOT ALREADY EXIST KEYED ON ACCOUNTID, LAST AND FIRST NAME
            
            if (c.Last_Name_Additional1__c <> null && currentContactsMap.get(c.AccountId + c.Last_Name_Additional1__c + c.First_Name_Additional1__c) == null)
            {
                Contact n = new Contact(AccountId = c.AccountId, 
                                            LastName = c.Last_Name_Additional1__c, 
                                            FirstName = c.First_Name_Additional1__c,
                                            Email = c.Email_Additional1__c,
                                            Phone = c.Phone_Additional1__c,
                                            Fax = c.Fax_Additional1__c,
                                            Title = c.Title_Additional1__c);
                additionalContacts.add(n);
            }
            if (c.Last_Name_Additional2__c <> null && currentContactsMap.get(c.AccountId + c.Last_Name_Additional2__c + c.First_Name_Additional2__c) == null)
            {
                Contact n = new Contact(AccountId = c.AccountId, 
                                            LastName = c.Last_Name_Additional2__c, 
                                            FirstName = c.First_Name_Additional2__c,
                                            Email = c.Email_Additional2__c,
                                            Phone = c.Phone_Additional2__c,
                                            Fax = c.Fax_Additional2__c,
                                            Title = c.Title_Additional2__c);
                additionalContacts.add(n);
            }
        }
    }
        
    if (additionalContacts <> null)
    {
        insert additionalContacts;
             
    }
}