public with sharing class AccountExtension {
    
    public AddressExtension addressExtension {get; private set;}
    
    public AccountExtension(ApexPages.StandardController sc) {
    	Account account = (Account) sc.getRecord();
    	List<Contact> contact = [ SELECT Id FROM Contact WHERE AccountId =:account.Id];
    	if (contact.size() > 0) {
    		this.addressExtension = new AddressExtension(contact.get(0));
    	}     	
    }
}