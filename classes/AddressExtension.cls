public with sharing class AddressExtension {
	
	public Id addressContactId {get; private set;}
	public Address__c address {get; private set;}
	public Customer_Address__c customerAddress {get; private set;}
	
	public String errorMessage {get; private set;} 
	public Boolean hasErrors { get { return String.isNotBlank(this.errorMessage); } set; } 	
	
	public List<Customer_Address__c> contactCustomerAddresses {get; private set;}
    
    /* 
     * Constructors
     */
     
    public AddressExtension(Contact contact) {
    	this.initializeExtension(contact);
    }
    
    public AddressExtension(ApexPages.StandardController sc) {
    	 this.initializeExtension((Address__c) sc.getRecord());
    }
    
    /*
     * Initialize extension for editing an existing address
     */
    
    public void initializeExtension(Address__c existingAddress) {
    	this.address = this.getAddressRecord(existingAddress.Id).get(0);
    	this.errorMessage = '';
    	this.contactCustomerAddresses = getAddressContactRecords(this.address.Id);
    	
    	if (this.contactCustomerAddresses != null && this.contactCustomerAddresses.size() > 0) {
    		// default to first in list
			this.customerAddress = this.contactCustomerAddresses[0];
			this.addressContactId = this.customerAddress.Contact__c;    		
    	}
    }

    /*
     * Initialize extension for adding an address to a contact
     */
         
    public void initializeExtension(Contact contact) {
    	this.address = new Address__c();
    	this.customerAddress = new Customer_Address__c();
    	this.errorMessage = '';
    	
    	this.addressContactId = contact.Id;
    	this.contactCustomerAddresses = getContactAddressRecords(this.addressContactId);    	
    }
    
    /*
     * Buttons
     */
    
    public PageReference saveAndAddMore() {
        return insertNewAddress(true);
    }
        
    public PageReference insertNewAddress() { 
    	return this.insertNewAddress(false);  
    }
    
    public PageReference addressCancelAddNew() {
        PageReference pr = new PageReference('/' + this.addressContactId);
        pr.setRedirect(true);
        return pr;
    }  

	public PageReference updateExistingAddress() {
		return this.updateExistingAddress(false);
	}       
	
	public PageReference updateAndMore() {
		return this.updateExistingAddress(true);
	}
	
    public PageReference addressCancelUpdateExisting() {
    	String retURL = ApexPages.currentPage().getParameters().get('retURL');
        PageReference pr = new PageReference(retURL);
        pr.setRedirect(true);
        return pr;
    }  	
    
    /*
     * Insert a new address 
     */
	
    
    public PageReference insertNewAddress(Boolean stayOnPage) {   	
		return this.insertNewAddress(stayOnPage, this.address, this.customerAddress, this.addressContactId);    		
    }    
    
    private @testVisible PageReference insertNewAddress(Boolean stayOnPage, Address__c newAddress, Customer_Address__c customerAddress, Id contactId) {
    	
		this.errorMessage = null;
		PageReference pr = null;
		                
    	try {     	
			// insert the address
			database.insert(newAddress);
			// insert the customer address
			customerAddress.Address__c = newAddress.Id;	
			customerAddress.Contact__c = contactId;    	
			database.insert(customerAddress);		
     	} catch(DMLException e) {
            errorMessage = e.getMessage();
        }    	

        if (!this.hasErrors && !stayOnPage) {
	 		pr = new PageReference('/' + this.addressContactId);
			pr.setRedirect(true);        	
        } else {
    		this.address = new Address__c();
    		this.customerAddress = new Customer_Address__c();         	
        }        
        
        return pr;		
    }   
    
    /* 
     * Update an existing address
     */
    
    public PageReference updateExistingAddress(Boolean stayOnPage) {
		return this.updateExistingAddress(stayOnPage, this.address, this.contactCustomerAddresses);   		
    }
    
    private @testVisible PageReference updateExistingAddress(Boolean stayOnPage, Address__c updatedAddress, List<Customer_Address__c> contactAddresses) {
    	
    	this.errorMessage = null;
    	PageReference pr = null;
    	
    	try {
    		    	    	    	
			// update the address    		
			database.update(updatedAddress);		
			// update the related customer addresses
			if (contactAddresses != null && contactAddresses.size() > 0) {
				database.update(contactAddresses);
			}   
		 		   			    		
    	} catch(DMLException e) {
            errorMessage = e.getMessage();
        }  
        
        if (!this.hasErrors && !stayOnPage) {
	        pr = new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
			pr.setRedirect(true);        	
        }        
        
    	return pr; 
    }
    
    
   /*
    * Get list of all addresses associated with this contact for the page
    */
    
    private @testVisible List<Customer_Address__c> getContactAddressRecords(Id contactId) {
    	return [
    		SELECT 	Is_Inactive__c, Is_Principal_Address__c, Address_Type__c, Address__c, 
    				Address__r.Name, Address__r.Address_1__c, Address__r.Address_2__c, Address__r.City__c, Address__r.State__c, Address__r.Zip__c, Address__r.Country__c, Address__r.Country_Code__c     
    		FROM Customer_Address__c 
    		WHERE Contact__c =:contactId
    	];    	
    }
    
    /*
     * Get all the contacts this address record is associated with.
     * Includes those contact mailing details for comparison
     * If the customer address is set to primary, the details should always match
     */
    
    private @testVisible List<Customer_Address__c> getAddressContactRecords(Id addressId) {
    	return [
    		SELECT 	Is_Inactive__c, 
		    		Is_Principal_Address__c, 
		    		Address_Type__c,  
    		
    				Contact__c,     		
    				Contact__r.FirstName, 
    				Contact__r.LastName,   
    				
                    Contact__r.MailingStreet,
	                Contact__r.MailingCity,
	                Contact__r.MailingCountry,
	                Contact__r.MailingState,
	                Contact__r.MailingPostalCode,   
	                Contact__r.AccountId,
	                Contact__r.Account.IsPersonAccount,         
	            
	            	Address__c,
	                Address__r.Address_1__c,
	                Address__r.City__c,
	                Address__r.Country_Code__c,
	                Address__r.State__c,
	                Address__r.Zip__c
	                
    		FROM Customer_Address__c 
    		WHERE Address__c =:addressId
    	];    	
    }
    
    /* 
     * Get the details for the address being edited
     */
    
    private @testVisible List<Address__c> getAddressRecord(Id addressId) {
    	return [
    		SELECT 	Name, Address_1__c, Address_2__c, City__c, State__c, Zip__c, Country__c, Country_Code__c        
    		FROM Address__c 
    		WHERE Id =:addressId
    	];    	
    	
    }    
    
    
    
}