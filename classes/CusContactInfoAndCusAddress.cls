/* Helper class which is called 
   to insert Customer Contact information and customerAddress Automatically
   when a person Account is inserted manually*/    



public class CusContactInfoAndCusAddress {
    
  public static Contact_Information__c primaryPhone, primaryEmail;
    
    public static List<Contact_Information__c> contactInfos {
        get {
            if (contactInfos == null) contactInfos = new List<Contact_Information__c>();
            return contactInfos;
        }
        set;
    }
    
    public static set<Address__c> AddrSet=new Set<Address__c>();
    
        private static Map<String, Schema.RecordTypeInfo> contactInfoRecordTypes {
        get {
            if (contactInfoRecordTypes == null) {
                contactInfoRecordTypes = Schema.SObjectType.Contact_Information__c.getRecordTypeInfosByName();
            }
            return contactInfoRecordTypes;
        }
        set;
    }
    
        public static  void CusContactInfoAndCusAddress(Account acc,Boolean isPrimary) {
        	
        	List<Account> accList=[Select Id,PersonContactId,PersonMailingStreet,BillingCity,PersonMailingCity,PersonMailingPostalCode,PersonMailingState,PersonMailingCountry
        						   from Account where Id=:acc.Id];
        	
        	String phone=acc.Phone;
		
			Contact_Information__c newContactInfo;
			
        
        	if (acc.PersonEmail != null) {
            // Check if primary email exists
            if (primaryEmail == null) {
                newContactInfo = createEmailContactInformation(acc.PersonContactId	
                , acc.PersonEmail, true);
                primaryEmail = newContactInfo;
            } else {
                newContactInfo = createEmailContactInformation(acc.PersonContactId	
                , acc.PersonEmail, isPrimary);     
            }

            if (newContactInfo != null) {
                contactInfos.add(newContactInfo);
                system.debug('Size of contact Info is' + contactInfos.size() );
            }
        }
        // Check for Phone information
        
        if(acc.Phone!=null){
      if (primaryPhone == null) {
				// then make current phone primary
				newContactInfo = createPhoneContactInformation(acc,acc.PersonContactId, phone, true);
				primaryPhone = newContactInfo;
			} else {
				newContactInfo = createPhoneContactInformation(acc,acc.PersonContactId, phone, isPrimary);
			}
			
			if (newContactInfo != null) {
				contactInfos.add(newContactInfo);
			}
			if(contactInfos.size()>0){
			insert contactInfos;
			
			}
        
      //return  newContactInfo;
      }
      
     // Billing information is not null
      IF(acc.PersonMailingStreet!=null){
    	createAddress(accList[0].PersonContactId,accList[0].PersonMailingStreet, accList[0].PersonMailingCity,accList[0].PersonMailingPostalCode,accList[0].PersonMailingState,accList[0].PersonMailingCountry);
      }
      
  }
    
    public static Contact_Information__c createEmailContactInformation( Id contactId,
                                                                    String email, 
                                                                    Boolean isPrimary) {
                                                                        
            Contact_Information__c newContactInformation = new Contact_Information__c(
                Contact__c = contactId,
                Is_Primary__c = isPrimary,
                 Contact_Information_Medium__c = 'Email',
                Name = email,
                Email__c = email
            );

        // Set record type
        newContactInformation.RecordTypeId = contactInfoRecordTypes.get('Email').getRecordTypeId();

        // Set contact information match keys
        newContactInformation.Contact_Information_Match_Key__c = 
            SSVCleaner.buildContactInfoMatchKey(newContactInformation);
        newContactInformation.Contact_Information_Match_Key_Hash__c = 
            SSVCleaner.encodeHash(newContactInformation.Contact_Information_Match_Key__c);
            
            return newContactInformation;                                                           
                                                                        
          }
          
          //Method for creating PhoneContactInformation...
          
        public static Contact_Information__c createPhoneContactInformation(	Account acc,Id contactId,
																	String phone,
																	Boolean isPrimary) {
				String PhExtension=null;														
				if(acc.Phone_Extension__c!=null){
				PhExtension=acc.Phone_Extension__c;
					}
		// Build contact information record
		Contact_Information__c newContactInformation_Phone = new Contact_Information__c(
				Contact__c = contactId,
				Is_Primary__c = isPrimary,
				Name = phone,
				Phone_Extension__c=PhExtension,
				Contact_Information_Medium__c = 'Phone',
				Phone__c = phone
				
			);
		// Set record type
		newContactInformation_Phone.RecordTypeId = contactInfoRecordTypes.get('Phone').getRecordTypeId();
		// Set contact information match keys
		newContactInformation_Phone.Contact_Information_Match_Key__c = 
			SSVCleaner.buildContactInfoMatchKey(newContactInformation_Phone);
		newContactInformation_Phone.Contact_Information_Match_Key_Hash__c = 
			SSVCleaner.encodeHash(newContactInformation_Phone.Contact_Information_Match_Key__c);

		return newContactInformation_Phone;
	}   
	
	// Method for creating customer Address
	
	
	public static Address__c createAddress(Id PersonContactId,String Address1,String City,String Zip, String State,String country) {
	
	Id ContactId=PersonContactId;
	
	// check for address matchkey exists in the address table... else... if it already exists... associate with customer address
			List<Address__c> AddInsertList=new List<Address__c>();
			List<Address__c> NewAddrInsertList=new List<Address__c>();
			List<String> addressFields = new List<String>();
		if (address1 != null) addressFields.add(address1.trim());
		if (city != null) addressFields.add(city.trim());
		if (state != null) addressFields.add(state.trim());
		if (zip != null) addressFields.add(zip.trim());
		if (country!= null) addressFields.add(country.trim());

		String addressMatchKey = String.join(addressFields, '');
		addressMatchKey = addressMatchKey.toUpperCase().replaceAll('[+-. ()]', '');
		
		List<Address__c> AddressList=new List<Address__c>(/*[Select Address_Match_Key__c from Address__c]*/);
		
		Set<String> AddressMatchKeySet=new Set<String>();
		
		for(Address__C addr:AddressList){
			
			AddressMatchKeySet.add(addr.Address_Match_Key__c);
			AddrSet.add(addr);
			
		}
		
		if(!AddressMatchKeySet.contains(addressMatchKey)){
			/*pick the existing address */
			/* pass the address to be added to customer address*/
			// CreateCusAddress(AddrSet);
			
			for(Address__C addr:AddrSet){
				CreateCusAddress(ContactId,Addr);
				
			}
		}


		else {
			/*call method to create addresses*/
			Address__c newAddr= new Address__c(
			Address_1__c=Address1,
			Address_2__c='',
			City__c=City,
			Zip__c=Zip,
			State__c=State,
			Country__c=country
			);
			/*add this to a different list*/		
		newAddr.Address_Match_Key__c = SSVCleaner.buildAddressMatchKey(newAddr);
		newAddr.Address_Match_Key_Hash__c = SSVCleaner.encodeHash(newAddr.Address_Match_Key__c);
			
			
			if(newAddr!=null){
				AddInsertList.add(newAddr);
				
			}
			
			insert AddInsertList;
			
			// Iterate over the inserted address list
			if(AddInsertList.size()>0){
			for(Address__c addr:AddInsertList){
				/*Pass this method to customer address*/
				CusAddressForNewAddresses(ContactId,addr);
			}
				
			}
		}
// Build address
		return null;
	}
	
	
	public static void CreateCusAddress(Id contactId,Address__c addr){
		
		List<Customer_Address__c> CusAddrList=new List<Customer_Address__c>();
		
		Customer_Address__c CusAddr=new Customer_Address__c(
			Contact__c = contactId,
			Address__c = addr.Id,
			Is_Principal_Address__c =true,
			Is_Inactive__c = false,
			Address_Type__c = 'Residence'
		);
		
		if(CusAddr!=null){
		CusAddrList.add(CusAddr);
			
		}
		
		insert CusAddrList;
}
	
	// Create CusAddressForNewAddresses
	
	public static void CusAddressForNewAddresses(Id ContactId,Address__c addr){
		List<Customer_Address__c> CusNewAddressList=new List<Customer_Address__c>();
		Customer_Address__c CusAddr=new Customer_Address__c(Contact__c = contactId,
			Address__c = addr.Id,
			Is_Principal_Address__c =true,
			Is_Inactive__c = false,
			Address_Type__c = 'Residence');
			
			if(CusAddr!=null){
			CusNewAddressList.add(CusAddr);
			 }
			 insert CusNewAddressList;
		}
}