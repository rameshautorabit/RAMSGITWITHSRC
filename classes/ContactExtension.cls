public with sharing class ContactExtension {
    
    public AddressExtension addressExtension {get; private set;}
    
    public ContactExtension(ApexPages.StandardController sc) {
    	Contact contact = (Contact) sc.getRecord();
		this.addressExtension = new AddressExtension(contact);
    }    
}