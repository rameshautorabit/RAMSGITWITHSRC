public with sharing class SSVLoader {
	private static final String SALESFORCE = 'Salesforce';
	private static final String SALESFORCE_ACCOUNT = 'Salesforce Account';
	private static final String SALESFORCE_PERSON_ACCOUNT = 'Salesforce Person Account';
	private static final String SALESFORCE_CONTACT = 'Salesforce Contact';
	private static final String COMPANY_ACCOUNT_PREFIX = 'SFDC-';
	private static final String BUSINESS_CONTACT_PREFIX = 'SFDC-';
	private static final String PERSON_ACCOUNT_PREFIX = 'SFDC PA-';
	private static final String CLIENT_TYPE = 'Employee';
	private static final String PROCESSING_STATUS = 'Waiting to Start';
	private static final Boolean IS_RDY_FOR_DUPE_CHECK = false;

	private @testVisible List<Source_System_View__c> records;

	private @testVisible Map<Integer, Source_System_View__c> companyRecordsMap {
		get {
			if (companyRecordsMap == null) companyRecordsMap = new Map<Integer, Source_System_View__c>();
			return companyRecordsMap;	
		}
		set;
	}

	public SSVLoader(List<Source_System_View__c> records) {
		this.records = records;
	}

	public SSVLoader createCompanyRecordsForCustomers() {

		Integer currentIndex = 0;
		for (Source_System_View__c ssv : records) {

			if (shouldCreateCompanyMatch(ssv)) {
				companyRecordsMap.put(currentIndex, createCompanyMatchSSV(ssv));
			}

			currentIndex++;
		}
		return this;
	}

	public SSVLoader linkCustomerRecordsToCompanyRecords() {

		for (Integer currentIndex : companyRecordsMap.keySet()) {
			records[currentIndex].Source_System_View_CW_Company__c = companyRecordsMap.get(currentIndex).Id;
		}
		return this;
	}

	public List<Source_System_View__c> getCompanyRecords() {
		return companyRecordsMap.values();
	}

	public static Boolean shouldCreateCompanyMatch(Source_System_View__c customerRecord) {

		return 
			(String.isNotEmpty(customerRecord.Cleansed_Company_Name__c) || String.isNotEmpty(customerRecord.Trade_ID__c)) 
			&&
			customerRecord.Match_Type__c == 'Contact' 
			&&
			customerRecord.Source_Table__c != 'Salesforce Contact';
	}

	public static Source_System_View__c createCompanyMatchSSV(Source_System_View__c customerRecord) {

		return new Source_System_View__c(
			Source_Table__c = 'CW Replicated Company',
			Match_Type__c = 'Company',
			EXT_Source_System_Customer_ID__c = customerRecord.EXT_Source_System_Customer_ID__c + 'C',
			Is_Ready_For_Duplicate_Check__c = false,
			Name = customerRecord.EXT_Source_System_Customer_ID__c + 'C',
			Source_System_Last_Modified_Date__c = customerRecord.Source_System_Last_Modified_Date__c,
			Originating_Source_System__c = customerRecord.Originating_Source_System__c,
			Company_Name__c = customerRecord.Company_Name__c, 
			Day_Phone__c = customerRecord.Day_Phone__c,
			Email__c = customerRecord.Email__c,
			Address_1__c = customerRecord.Address_1__c,
			Address_2__c =  customerRecord.Address_2__c,
			City__c = customerRecord.City__c,
			State__c = customerRecord.State__c,
			Zip__c = customerRecord.Zip__c,
			Country__c = customerRecord.Country__c,
			Source_System_Create_Date__c = DateTime.now(),
			Trade_ID__c = customerRecord.Trade_ID__c,
			Source_Table_ID__c = customerRecord.ID,
			Order_Type_Code__c = customerRecord.Order_Type_Code__c,
			Account__c = customerRecord.Account__c,
			Country_Code__c = customerRecord.Country_Code__c,
			Fraud_Warning__c = customerRecord.Fraud_Warning__c
		);
	}
	
	/**
	 * Create Source System View record given ship_to record
	 * @param  orderRecord Order record
	 * @param  mapSetting  Custom Setting of field mapping
	 * @return             new Source System View record
	 */
	 
	public static Source_System_View__c createSSV(Ship_To__c shipToRecord, 
											 	  List<SObject> mapSettings) {
											 	  	
		Source_System_View__c newSSV = new Source_System_View__c();
		FieldMapper.mapObject((SObject) shipToRecord, newSSV, mapSettings); 
		
		// Inline mapping (until I build the map settings)
		// TODO :: put all these mappings into Order_SSV_Field_Mapping__c
		
	   newSSV.Name = shipToRecord.Ship_to_Customer_Number__c;
	   newSSV.EXT_Source_System_Customer_ID__c = shipToRecord.Ship_to_Customer_Number__c;	
	  newSSV.Source_Table__c = 'CW Customer Ship To';				
	  newSSV.Account__c = NULL;									
	  newSSV.Contact__c = NULL;									
	  newSSV.First_Name__c = shipToRecord.Ship_to_First_Name__c;				
	  newSSV.Last_Name__c = shipToRecord.Ship_to_Last_Name__c;														
	  newSSV.Company_Name__c = shipToRecord.Ship_to_Company__c;				
	  newSSV.Apartment__c = NULL;
	  newSSV.Address_1__c = shipToRecord.Ship_To_Address_1__c;					
	  newSSV.Address_2__c = shipToRecord.Ship_to_Address_2__c;					
	  newSSV.City__c = shipToRecord.Ship_to_City__c;							
	  newSSV.State__c = shipToRecord.Ship_to_State__c;							
	  newSSV.Zip__c = shipToRecord.Ship_to_Zip__c;
	  newSSV.Country__c = shipToRecord.Ship_to_Country__c;								
	  newSSV.Country_Code__c = Utility.substring(shipToRecord.Ship_to_Country_Code__c, 0, 2); // or Ship_to_Country_Code__c 	         
	  newSSV.Email__c = shipToRecord.Ship_to_Email__c;							
	  newSSV.Day_Phone__c = shipToRecord.Ship_to_Day_Phone__c;					
	  newSSV.Alternative_Phone__c = shipToRecord.Ship_to_Night_Phone__c;								    
	  newSSV.ATG_Profile_ID__c = NULL;		
	  newSSV.Originating_Source_System__c = (shipToRecord.order__r.Order_Type_Code__c == 'W' || shipToRecord.order__r.Order_Type_Code__c == 'O') ? 'ATG' : 'CW'; 
	  newSSV.Source_Table_ID__c = shipToRecord.ID;	
	  newSSV.Source_System_Create_Date__c = DateTime.now();						

		return newSSV;													 	  	
	}	
	
	/**
	 * Create Source System View record given order record
	 * @param  orderRecord Order record
	 * @param  mapSetting  Custom Setting of field mapping
	 * @return             new Source System View record
	 */
	 
	public static Source_System_View__c createSSV(RH_Order__c orderRecord, 
											 	  List<SObject> mapSettings) {
														
		Source_System_View__c newSSV = new Source_System_View__c();
		FieldMapper.mapObject((SObject) orderRecord, newSSV, mapSettings); 
		
		// Inline mapping (until I build the map settings)
		// TODO :: put all these mappings into Order_SSV_Field_Mapping__c
		
		newSSV.Name = orderRecord.Sold_to_Customer_Number__c;
	  	newSSV.EXT_Source_System_Customer_ID__c = orderRecord.Sold_To_Customer_Number__c;	
	  	newSSV.Source_Table__c = 'CW Customer';
	  	newSSV.Account__c = orderRecord.Account_Sold_To__c;								
	  	newSSV.Contact__c = orderRecord.Contact_Sold_To__c;
      	newSSV.First_Name__c = orderRecord.Sold_to_First_Name__c;			
      	newSSV.Last_Name__c = orderRecord.Sold_to_Last_Name__c;
		newSSV.Company_Name__c = orderRecord.Sold_to_Company__c;       					
       	newSSV.Apartment__c = NULL;
      	newSSV.Address_1__c = orderRecord.Sold_To_Address_1__c;	
      	newSSV.Address_2__c = orderRecord.Sold_to_Address_2__c;	
      	newSSV.City__c = orderRecord.Sold_to_City__c;						
      	newSSV.State__c = orderRecord.Sold_to_State__c;						
      	newSSV.Zip__c = orderRecord.Sold_to_Zip__c;
      	newSSV.Country__c = orderRecord.Sold_to_Country__c;
      	newSSV.Country_Code__c = Utility.substring(orderRecord.Sold_to_Country_Code__c, 0, 2); // or Sold_to_Country_Code__c  							
	  	newSSV.Email__c = orderRecord.Sold_to_Email__c;						
      	newSSV.Day_Phone__c = Utility.stripNonAlphanumericCharacters(orderRecord.Sold_to_Day_Phone__c); // clean all phone numbers coming in so stored 				
      	newSSV.Alternative_Phone__c = Utility.stripNonAlphanumericCharacters(orderRecord.Sold_to_Night_Phone__c); // clean all phone numbers coming in			
       	newSSV.Source_System_Last_Modified_Date__c = orderRecord.Order_Date__c;				
	  	newSSV.ATG_Profile_ID__c = orderRecord.ATG_Account_ID__c;
		// newSSV.Is_RH_Employee__c = orderRecord.Order_Type_Code__c == 'E' ? true : false;
	  	newSSV.Membership_Number__c = orderRecord.Membership_ID__c;
	  	newSSV.Originating_Source_System__c = (orderRecord.Order_Type_Code__c == 'W' || orderRecord.Order_Type_Code__c == 'O') ? 'ATG' : 'CW';
	  	// newSSV.Last_Order_Number = orderRecord.EXT_Order_Number__c;
	  	newSSV.Source_Table_ID__c = orderRecord.ID;
	  	newSSV.Trade_ID__c = orderRecord.Trade_ID__c;
	  	newSSV.Order_Type_Code__c = orderRecord.Order_Type_Code__c;
	  	newSSV.Fraud_Warning__c = orderRecord.Fraud_Warning__c;
	  	newSSV.Source_System_Create_Date__c = DateTime.now();
	  	 				
		// Mapping not handled by field mapper (done inline, no reason to split out)
		
		return newSSV;
	}	

	/**
	 * Create Source System View record given parent record
	 * @author Zi Zhang, Traction on Demand
	 * @date   2016-02-27
	 * @param  accountRecord Company/Person Account record
	 * @param  mapSetting    Custom Setting of field mapping
	 * @return               new Source System View record
	 */
	public static Source_System_View__c createSSV(Contact contactRecord, 
													List<SObject> mapSettings, 
													Customer_Address__c relatedContactCustomerAddress, 
													Account relatedAccount,
													Source_System_View__c relatedAccountSSV) {
														
		Source_System_View__c newSSV = new Source_System_View__c();
		newSSV.Source_Table_ID__c = contactRecord.ID;
		newSSV.Source_System_Create_Date__c = DateTime.now();
		newSSV.Membership_Number__c = contactRecord.Membership_ID__c;
		newSSV.Trade_ID__c = (relatedAccount == null) ? null : relatedAccount.X12_Digit_Member__c;
		
		FieldMapper.mapObject((SObject) contactRecord, newSSV, mapSettings); 

		// Mapping not handled by field mapper
		businessContactMapping(contactRecord, newSSV, relatedContactCustomerAddress, relatedAccount, relatedAccountSSV);

		return newSSV;
	}

	/**
	 * Update existing Source System View record given parent record
	 * @author Zi Zhang, Traction on Demand
	 * @date   2016-02-27
	 * @param  accountRecord Company/Person Account record
	 * @param  mapSetting    Custom Setting of field mapping
	 * @return               new Source System View record
	 */
	public static void updateSSV(Contact contactRecord, 
								Source_System_View__c ssv, 
								List<SObject> mapSettings, 
								Customer_Address__c relatedContactCustomerAddress, 
								Account relatedAccount,
								Source_System_View__c relatedAccountSSV) {
									
		FieldMapper.mapObject((SObject) contactRecord, ssv, mapSettings); 

		// Mapping not handled by field mapper
		businessContactMapping(contactRecord, ssv, relatedContactCustomerAddress, relatedAccount, relatedAccountSSV);
	}

	/**
	 * Create Source System View record given parent record
	 * @author Zi Zhang, Traction on Demand
	 * @date   2016-02-27
	 * @param  accountRecord Company/Person Account record
	 * @param  mapSetting    Custom Setting of field mapping
	 * @return               new Source System View record
	 */
	public static Source_System_View__c createSSV(Account accountRecord, List<SObject> mapSettings, Customer_Address__c relatedContactCustomerAddress) {
		
		Source_System_View__c newSSV = new Source_System_View__c();
		newSSV.Source_Table_ID__c = accountRecord.ID;
		newSSV.Source_System_Create_Date__c = DateTime.now();
		newSSV.Membership_Number__c = accountRecord.Membership_ID__pc;
		newSSV.Trade_ID__c = accountRecord.X12_Digit_Member__c;
				
		FieldMapper.mapObject((SObject) accountRecord, newSSV, mapSettings); 

		if(accountRecord.IsPersonAccount) {
			personAccountMapping(accountRecord, newSSV, relatedContactCustomerAddress);
		} else {
			companyAccountMapping(accountRecord, newSSV);
		}
		return newSSV;
	}

	/**
	 * Update existing Source System View record given parent record
	 * @author Zi Zhang, Traction on Demand
	 * @date   2016-02-27
	 * @param  accountRecord Company/Person Account record
	 * @param  mapSetting    Custom Setting of field mapping
	 * @return               new Source System View record
	 */
	public static void updateSSV(Account accountRecord, Source_System_View__c ssv, List<SObject> mapSettings, Customer_Address__c relatedContactCustomerAddress) {
		
		FieldMapper.mapObject((SObject) accountRecord, ssv, mapSettings); 

		if(accountRecord.IsPersonAccount) {
			personAccountMapping(accountRecord, ssv, relatedContactCustomerAddress);
		} else {
			companyAccountMapping(accountRecord, ssv);
		}
	}

	/**
	 * Specific field mapping that field mapper doesn't handle
	 * @author Zi Zhang, Traction on Demand
	 * @date   2016-02-29
	 * @param  companyRecord Company Account
	 * @param  ssvRecord     SSV
	 */
	private static void businessContactMapping(Contact contactRecord, 
												Source_System_View__c ssvRecord, 
												Customer_Address__c relatedContactCustomerAddress, 
												Account relatedAccount,
												Source_System_View__c relatedAccountSSV) {
		if (ssvRecord == null) return;

		ssvRecord.Name = BUSINESS_CONTACT_PREFIX + ssvRecord.Name;
		ssvRecord.EXT_Source_System_Customer_ID__c = BUSINESS_CONTACT_PREFIX + ssvRecord.EXT_Source_System_Customer_ID__c;
		ssvRecord.Source_Table__c = SALESFORCE_CONTACT;
		ssvRecord.Originating_Source_System__c = SALESFORCE;
		// ssvRecord.Is_Ready_For_Duplicate_Check__c = IS_RDY_FOR_DUPE_CHECK;
		// ssvRecord.Processing_Status__c = PROCESSING_STATUS;
		ssvRecord.Company_Name__c = (relatedAccount != null) ? relatedAccount.Name : null;
		ssvRecord.Source_System_Last_Modified_Date__c = contactRecord.LastModifiedDate;
		ssvRecord.Customer_Address__c = (relatedContactCustomerAddress != null) ? relatedContactCustomerAddress.Id : null;
		ssvRecord.Source_System_View_CW_Company__c = (relatedAccountSSV != null) ? relatedAccountSSV.Id : null;
		
		if (contactRecord != null) parseAddress(contactRecord.MailingStreet, ssvRecord);
	}

	/**
	 * Specific field mapping that field mapper doesn't handle
	 * @author Zi Zhang, Traction on Demand
	 * @date   2016-02-29
	 * @param  companyRecord Company Account
	 * @param  ssvRecord     SSV
	 */
	private static void companyAccountMapping(Account companyRecord, Source_System_View__c ssvRecord) {
		if (ssvRecord == null) return;

		ssvRecord.Name = COMPANY_ACCOUNT_PREFIX + ssvRecord.Name;
		ssvRecord.EXT_Source_System_Customer_ID__c = COMPANY_ACCOUNT_PREFIX + ssvRecord.EXT_Source_System_Customer_ID__c;
		ssvRecord.Source_Table__c = SALESFORCE_ACCOUNT;
		ssvRecord.Originating_Source_System__c = SALESFORCE;
		// ssvRecord.Is_Ready_For_Duplicate_Check__c = IS_RDY_FOR_DUPE_CHECK;
		// ssvRecord.Processing_Status__c = PROCESSING_STATUS;
		ssvRecord.Source_System_Last_Modified_Date__c = companyRecord.LastModifiedDate;

		if (companyRecord != null) parseAddress(companyRecord.BillingStreet, ssvRecord);
	}

	/**
	 * Specific field mapping that field mapper doesn't handle
	 * @author Zi Zhang, Traction on Demand
	 * @date   2016-02-29
	 * @param  personRecord Person Account
	 * @param  ssvRecord     SSV
	 */
	private static void personAccountMapping(Account personRecord, Source_System_View__c ssvRecord, Customer_Address__c relatedCustomerAddress) {

		if (ssvRecord == null) return;

		ssvRecord.Name = PERSON_ACCOUNT_PREFIX + ssvRecord.Name;
		ssvRecord.EXT_Source_System_Customer_ID__c = PERSON_ACCOUNT_PREFIX + ssvRecord.EXT_Source_System_Customer_ID__c;
		ssvRecord.Source_Table__c = SALESFORCE_PERSON_ACCOUNT;
		ssvRecord.Originating_Source_System__c = SALESFORCE;
		// ssvRecord.Is_Ready_For_Duplicate_Check__c = IS_RDY_FOR_DUPE_CHECK;
		// ssvRecord.Processing_Status__c = PROCESSING_STATUS;
		ssvRecord.Customer_Address__c = (relatedCustomerAddress != null) ? relatedCustomerAddress.Id : null;
		ssvRecord.Source_System_Last_Modified_Date__c = personRecord.LastModifiedDate;

		if (personRecord != null) parseAddress(personRecord.PersonMailingStreet, ssvRecord);
	}

	/**
	 * Parse address field on first line break, assign to 2 Address fields on SSV record
	 * @author Zi Zhang, Traction on Demand
	 * @date   2016-02-29
	 * @param  streetAddress String of street addres with line breaks
	 * @param  ssvRecord     SSV record
	 */
	private static void parseAddress(String streetAddress, Source_System_View__c ssvRecord) {
		if(String.isNotEmpty(streetAddress)) {
			String[] result = streetAddress.split('\r\n', 2);
			ssvRecord.Address_1__c = result[0];
			if(result.size() == 2) {
				ssvRecord.Address_2__c = result[1];
			}
		}
	}
}