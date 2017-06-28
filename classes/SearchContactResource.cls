@RestResource(urlMapping='/SearchContact/*')
global with sharing class SearchContactResource {

	public enum ResponseTypes {SUCESS, ERROR}
	public static final Map<String, Schema.RecordTypeInfo> ACCOUNT_RECORD_TYPES = Schema.SObjectType.Account.getRecordTypeInfosByName();
	public static final Map<Id,Schema.RecordTypeInfo> ACCOUNTS_RECORD_TYPE_IDS = Schema.SObjectType.Account.getRecordTypeInfosById();
	public static Integer DEFAULT_ROW_LIMIT = 40;

	/*
	 * Class that wraps the SearchParameters
	 * Utterly pointless. But something MULE DEMANDED we provide
	 * Because they were incapable of passing this
	 * {
	 *   FirstName : ''
	 *   ...
	 * }
	 *
	 */

	 global class PointlessClientLookupRequestWrapper {
		public SearchParameters ClientLookupRequest;
	 }

	/*
	 * Class that contains all the search parameters
	 * Also holds the Ids of any Accounts that match search
	 */

	global class SearchParameters {

        public String SFAccountID {get;set;} // unused (currently)
        public String FirstName {get;set;}
        public String LastName {get;set;}
        public String Email {get;set;}
        public String Company {get;set;}
        public String PostalCode {get;set;}
        public String PhoneNumber {get;set;}
        public String RHMemberID {get;set;} // unused (currently)
        public String ATGID {get;set;} // unused (currently)
        public String TradeID {get;set;}
		public String AccountTypes {get;set;}
		public Integer RowLimit {
			get {
				return RowLimit == null ? DEFAULT_ROW_LIMIT : RowLimit;
			}
			set;
		}
		public String RequestingSystem {get;set;} // placeholder
		public String IncludeInactive {
			get {
				// if not provided, default to FALSE - as in do not include inactive elements
				// has to be a String and not a Boolean because.... ?
				return String.isEmpty(this.includeInactive) ? 'false' : this.includeInactive;
			}
			set;
		}

		public Boolean hasAccountFilter() {
			return !(String.isBlank(Company) && String.isBlank(TradeID));
		}

		public Boolean hasContactFilter() {
			return String.isNotEmpty(FirstName) || String.isNotEmpty(LastName);
		}

		public Boolean hasContactInformationFilter() {
			return String.isNotEmpty(Email) || String.isNotEmpty(PhoneNumber);
		}

		public Boolean hasCustomerAddressFilter() {
			return String.IsNotBlank(PostalCode);
		}

		public Boolean hasMemberFilter() {
			return String.IsNotBlank(RHMemberID);
		}
		
		public Boolean hasContactAddressFilter() {
			return String.isNotEmpty(PostalCode) || String.isNotEmpty(Email) || String.isNotEmpty(PhoneNumber);
		}
	}

	/*
	 * Class that contains the details of any Contacts found
	 * Cannot use the Contact object as we need Customer Address and Contact Info
	 * inside this object
	 * If the response hierarchy allowed them to be side by side we could use the Contact object
	 *
	 *   <xs:element ref="ID" minOccurs="0" maxOccurs="1"/>
	 *   <xs:element ref="Title" minOccurs="0"/>
	 *   <xs:element ref="FirstName" minOccurs="0"/>
	 *   <xs:element ref="LastName" minOccurs="0"/>
	 *   <xs:element ref="Emails" minOccurs="0" maxOccurs="1"/>
	 *   <xs:element ref="Company" minOccurs="0"/>
	 *   <xs:element ref="Addresses" minOccurs="0" maxOccurs="1"/>
  	 * 	 <xs:element ref="IsUnauthorized" minOccurs="0"/>
	 *   <xs:element ref="PhoneNumbers" minOccurs="0" maxOccurs="1"/>
	 *   <xs:element ref="RHMemberID" minOccurs="0" maxOccurs="1"/>
	 *   <xs:element ref="RHMember" minOccurs="0" maxOccurs="1"/>
	 */

	global class ContactDet {

		public String ID {get;set;}
		public String Title {get;set;}
		public String FirstName {get;set;}
		public String LastName {get;set;}
		public Set<EmailDet> Emails {get;set;}
		public String Company {get;set;}
		public Set<AddressDet> Addresses {get;set;}
		public Boolean IsUnauthorized {get;set;}
		public Set<PhoneNumberDet> PhoneNumbers {get;set;}
		public String RHMemberID {get;set;}
		public Boolean RHMember {get;set;}
		public Boolean EligibleForMemberBenefits {get;set;}
		public String MemberCancellationType {get;set;}
		public String MemberCancellationReason {get;set;}
		public Date MemberCancellationDate {get;set;}
		public Datetime MemberExpirationDateTime {get;set;}
		public Datetime MemberEnrollmentDateTime {get;set;}
		public String MemberRenewalTerm {get;set;}

		public transient String AccountId {get;set;}

		public ContactDet(Contact c) {
			this.id = c.Id;
			this.accountId = c.AccountId;
			this.title = c.Title;
			this.firstName = c.FirstName;
			this.lastName = c.LastName;
			this.addresses = new Set<AddressDet>();
			this.emails = new Set<EmailDet>();
			this.phoneNumbers = new Set<PhoneNumberDet>();
			this.isUnauthorized = c.Unauthorized_Contact_Checkbox__c;
			this.company = c.Account.IsPersonAccount ? null : c.Account.Name;
			
			if (FeatureFlagService.isSinglePaneCCLUFeatureActive()) {
				// SCASI-40 >> load Contact detail address, phone, email with records on Contact itself
				this.addresses.add(new AddressDet(c));		
				this.addEmail(new EmailDet(c));
				this.phoneNumbers = new PhoneNumberBuilder().build(c);
			}
		}
		
		public void addAddress(AddressDet addr) {
			if (addr.isNotEmpty()) {
				this.addresses.add(addr);
			}
		}
		
		public void addEmail(EmailDet email) {
			if (email.isNotEmpty()) {
				this.emails.add(email);
			}
		}
		public void addPhoneNumber(PhoneNumberDet phone) {
			if (phone.isNotEmpty()) {
				this.phoneNumbers.add(phone);
			}			
		}
	}

	/*
	 * Class that contains the details of the Account found
	 */

	global class AccountDet {
		public String Id {get;set;}
		public String TradeId {get;set;}
		public String Name {get;set;}
		public String AccountType {get;set;}
		public Boolean TaxExempt {get;set;}
		public List<AddressDet> Addresses {get;set;}
		public List<EmailDet> Emails {get;set;}
		public Set<PhoneNumberDet> PhoneNumbers {get;set;}
		public List<ContactDet> Contacts {get;set;}
		public transient Map<String, ContactDet> ContactMap {get;set;}

		public AccountDet(Account account) {
			this.Id = account.Id;
			this.TradeId = account.X12_Digit_Member__c;
			this.AccountType = getAccountName(account.RecordTypeId);
			this.TaxExempt = account.Verify_Tax_Exempt_Credentials__c;
			this.contactMap = new Map<String, ContactDet>();
			this.Name = account.Name;
			this.Addresses = new AddressBuilder().build(account);
			this.Emails = new List<EmailDet>();
			this.PhoneNumbers = new PhoneNumberBuilder().build(account);
		}

		public AccountDet(Contact contact, Boolean isEmptyNode) {
			this.Id = contact.AccountId;
			this.TradeId = contact.Account.X12_Digit_Member__c;
			this.AccountType = getAccountName(contact.Account.RecordTypeId);
			this.TaxExempt = contact.Account.Verify_Tax_Exempt_Credentials__c;
			this.contactMap = new Map<String, ContactDet>();

			if (!isEmptyNode) {
				this.Name = contact.Account.Name;
				this.Addresses = new AddressBuilder().build(contact.Account);
				this.Emails = new List<EmailDet>();
				this.PhoneNumbers = new PhoneNumberBuilder().build(contact.Account);
			}
		}
	}
	
	private class PhoneNumberBuilder {
		public Set<PhoneNumberDet> build(Account account) {
			Set<PhoneNumberDet> phoneNumbers = new Set<PhoneNumberDet>();
			if (String.isNotBlank(account.Phone)) {
				phoneNumbers.add(new PhoneNumberDet(account));
			}
			return phoneNumbers;
		}
		public Set<PhoneNumberDet> build(Contact contact) {
			Set<PhoneNumberDet> phoneNumbers = new Set<PhoneNumberDet>();
			if (String.isNotBlank(contact.HomePhone)) {
				phoneNumbers.add(new PhoneNumberDet(contact.HomePhone, true));
			}
			if (String.isNotBlank(contact.AssistantPhone)) {
				phoneNumbers.add(new PhoneNumberDet(contact.AssistantPhone, true));
			}
			if (String.isNotBlank(contact.MobilePhone)) {
				phoneNumbers.add(new PhoneNumberDet(contact.MobilePhone, true));
			}
			if (String.isNotBlank(contact.WorkPhone__c)) {
				phoneNumbers.add(new PhoneNumberDet(contact.WorkPhone__c, true));
			}
			if (String.isNotBlank(contact.Phone)) {
				phoneNumbers.add(new PhoneNumberDet(contact.Phone, true));
			}			
			return phoneNumbers;
		}
	}

	private class AddressBuilder {
		public List<AddressDet> build(Account acc) {
			List<AddressDet> addresses = new List<AddressDet>();
			if (String.isNotBlank(acc.BillingStreet)) {
				AddressDet address = new AddressDet();
				address.StreetAddress1 = acc.BillingStreet;
				address.City = acc.BillingCity;
				address.State = acc.BillingState;
				address.PostalCode = acc.BillingPostalCode;
				address.Country = acc.BillingCountry;
				address.IsPrimary = true; // billing always primary
				address.IsInactive = false;  // billing always active
				addresses.add(address);
			}
			if (String.isNotBlank(acc.ShippingStreet)) {
				AddressDet address = new AddressDet();
				address.StreetAddress1 = acc.ShippingStreet;
				address.City = acc.ShippingCity;
				address.State = acc.ShippingState;
				address.PostalCode = acc.ShippingPostalCode;
				address.Country = acc.ShippingCountry;
				address.IsPrimary = false; // Shipping always not primary
				address.IsInactive = false;  // Shipping always active
				addresses.add(address);
			}
			return addresses;
		}
	}

	global class AddressDet {
		public String ID;
		public String StreetAddress1;
		public String StreetAddress2;
		public String City;
		public String State;
		public String PostalCode;
		public String Country;
		public Boolean IsPrimary;
		public Boolean IsInactive;

		public String email;
		public String phone;
		public String firstName;
		public String lastName;
		public String companyName;

		public AddressDet() {
		}
		
		public AddressDet(Contact c) {
			this.ID = c.Id;
			this.StreetAddress1 = c.MailingStreet;
			this.StreetAddress2 = '';
			this.City = c.MailingCity;
			this.State = c.MailingState;
			this.Country = c.MailingCountry;
			this.PostalCode = c.MailingPostalCode;
			this.IsPrimary = true;
			this.IsInactive = false;			
		}

		public AddressDet(Customer_Address__c ca) {
			this.ID = ca.Id;
			this.StreetAddress1 = ca.Address__r.Address_1__c;
			this.StreetAddress2 = ca.Address__r.Address_2__c;
			this.City = ca.Address__r.City__c;
			this.State = ca.Address__r.State__c;
			this.Country = ca.Address__r.Country__c;
			this.PostalCode = ca.Address__r.Zip__c;
			this.IsPrimary = ca.Is_Principal_Address__c;
			this.IsInactive = ca.Is_Inactive__c;
		}

		public AddressDet(Contact_Address__c ca) {
			this.ID = ca.Id;
			this.StreetAddress1 = ca.Address_1__c;
			this.StreetAddress2 = ca.Address_2__c;
			this.City = ca.City__c;
			this.State = ca.State__c;
			this.Country = ca.Country__c;
			this.PostalCode = ca.Zip__c;
			this.IsPrimary = false;
			this.IsInactive = ca.Is_Inactive__c;
			this.email = ca.Email__c;
			this.phone = cleanString(ca.Day_Phone__c);
			this.firstName = ca.First_Name__c;
			this.lastName = ca.Last_Name__c;
			this.companyName = ca.Company_Name__c;
		}
		
		private String matchKey() {
			return Utility.stripNonAlphanumericCharacters(
    			this.StreetAddress1 +
				this.City +
				this.State +
				this.PostalCode
			).toUpperCase().trim();			
		}
		public Boolean isNotEmpty() {
			return String.isNotBlank(this.StreetAddress1);
		}
	    public Boolean equals(Object rhs) {
            return (rhs instanceof AddressDet) && (this.matchKey() == ((AddressDet)rhs).matchKey());
	    }		
		public Integer hashCode() {			
			return this.matchKey().hashCode();
		}		
	}

	global class EmailDet {
		public String ID;
		public String EmailAddress;
		public Boolean IsPrimary;
		public Boolean IsInactive;
		public String ContactInformationType;
		public String ContactInformationDescription;

		public EmailDet(Account account) {
		}
		public EmailDet(Contact_Information__c ci) {
			this.ID = ci.Id;
			this.EmailAddress = ci.Email__c;
			this.IsPrimary = ci.Is_Primary__c;
			this.IsInactive = ci.Is_Inactive__c;
		}
		public EmailDet(Contact_Address__c ca) {
			this.ID = ca.ID;
			this.EmailAddress = ca.Email__c;
			this.IsPrimary = false;
			this.IsInactive = ca.Is_Inactive__c;			
		}
		public EmailDet(Contact c) {
			this.Id = c.Id;
			this.EmailAddress = c.Email;
			this.IsPrimary = true;
			this.IsInactive = false;
		}
		public Boolean isNotEmpty() {
			return String.isNotBlank(this.EmailAddress);
		}
	    public Boolean equals(Object rhs) {
            return (rhs instanceof EmailDet) && (this.EmailAddress == ((EmailDet)rhs).EmailAddress);
	    }		
		public Integer hashCode() {
			if (this.EmailAddress == null) {
				return 0;
			}
			return this.EmailAddress.hashCode();
		}
	}

	global class PhoneNumberDet {
		public String ID;
		public String Phone;
		public String PhoneExtension;
		public Boolean IsPrimary;
		public Boolean IsInactive;
		public String ContactInformationType;
		public String ContactInformationDescription;

		public PhoneNumberDet(Account account) {
			if (String.isNotBlank(account.Phone)) {
				this.Phone = account.Phone;
				this.IsPrimary = true;
				this.IsInactive = false;
			}
		}
		public PhoneNumberDet(Contact_Information__c ci) {
			this.ID = ci.Id;
			this.Phone = ci.Phone__c;
			this.PhoneExtension = ci.Phone_Extension__c;
			this.IsPrimary = ci.Is_Primary__c;
			this.IsInactive = ci.Is_Inactive__c;
		}		
		public PhoneNumberDet(Contact_Address__c ca) {
			this.ID = ca.Id;
			this.Phone = cleanString(ca.Day_Phone__c);
			this.IsPrimary = false;
			this.IsInactive = ca.Is_Inactive__c;
		}
		public PhoneNumberDet(String phoneNumber, Boolean isPrimary) {
			this.Phone = cleanString(phoneNumber);
			this.IsPrimary = isPrimary;
			this.IsInactive = false;
		}
		public Boolean isNotEmpty() {
			return String.isNotBlank(this.Phone);
		}		
	    public Boolean equals(Object rhs) {
            return (rhs instanceof PhoneNumberDet) && (this.Phone == ((PhoneNumberDet)rhs).Phone);
	    }		
		public Integer hashCode() {
			if (this.Phone == null) {
				return 0;
			}			
			return this.Phone.hashCode();
		}
	}

    @testVisible
	private class MatchingRecords {
		public Set<Id> matchingContactIds;
		public Map<Id, Account> matchingAccounts;
		public MatchingRecords() {
			this.matchingContactIds = new Set<Id>();
		}
		public Integer totalRecords() {
			return  matchingAccounts == null ? matchingContactIds.size() : matchingAccounts.keySet().size();
		}
	}


	/*
	 * Class that encapsulates the Search Results
	 */

	global class PointlessSearchResponseWrapper {
		public SearchResponse ClientLookUpResponse;
		public PointlessSearchResponseWrapper(SearchResponse response) {
			ClientLookUpResponse = response;
		}
	}

	global class SearchResponse {

		public List<AccountDet> Accounts {get;set;}
		public String ResponseType {get;set;}
		public String ErrorCode {get;set;}
		public String ErrorDescription {get;set;}
		public Integer TotalRecords {get;set;}

		public transient Map<String, AccountDet> accountMap {get;set;}
		public SearchResponse() {
			this.accountMap = new Map<String, AccountDet>();
		}
	}

	/*
	 * Handle POST request
	 * Take a primitive String data type and de-serialize, as MULE had problems passing in
	 * an object. Also, this is a POST because MULE demanded it be one, even though no change
	 * is being made and this by rights (and convention) should be a GET. Because the string is being
	 * passed in and then deserialized, instead of being deserialized in the transport layer
	 * (not sure why this was a problem for MULE) a wrapper class was required to allow the incoming JSON to be:
	 *
	 * {
	 *    "ClientLookupRequest" : { ... }
	 * }
	 *
	 * If the transport layer had deserialized the JSON, then this would have been achieved by
	 * naming the object parameter in the doPost method ClientLookupRequest:
	 * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_rest_methods.htm
	 *
	 * Another(!) way this is wrong is that it deserializes the JSON in the code instead of allowing this to
	 * happen in the transport layer (based on the Content-Type property)
	 * "If the Apex method has a non-void return type, the resource representation is serialized into the response body."
	 *
	 * TO BE HONEST, this isn't really being called like a REST resource should be. Makes me wonder why it is one.
	 */

	@HttpPost
    global static String doPost(String request) {
		system.debug('doPost: ' + request);
		SearchResponse response = null;
		try {
			response = handleRequest(buildSearchParameters(request));
		} catch (Exception ex) {
			system.debug('doPost -> error -> ' + ex.getMessage());
			Utility.logException(ex, request);
		}
		
		system.debug('doPost -> response -> ' + response);
		return JSON.serialize (new PointlessSearchResponseWrapper(response), true);
    }

    /*
     * For testing because making me serialize the JSON in the code instead
     * of in the transport layer makes for some really nasty unit test code
     */

	@testVisible private static  SearchResponse doPost(SearchParameters parameters) {
    	SearchResponse response = handleRequest(parameters);
    	system.debug('final results ' + JSON.serialize (new PointlessSearchResponseWrapper(response), true));
		return response;
    }

	/*
	 * Handle Search Request
	 * Builds the list of contacts that match the filters, retrieves all the information from those contact Ids,
	 * then builds the search response object using that list of contacts. Returns the search response.
	 */

	@testVisible private  static SearchResponse handleRequest(SearchParameters parameters) {

    	// 1. build a list of all contacts that match with the search criteria
    	system.debug('handleRequest -> 1');
    	MatchingRecords matchingRecords = findMatchingRecords(parameters);

    	// 2. Get the actual contacts matching those Ids (if any matching contacts found)
    	system.debug('handleRequest -> 2 -> ' + matchingRecords);
    	Map<ID, Contact> matchingContacts = getContactMap(matchingRecords.matchingContactIds, parameters.rowLimit);

    	// 3. build a search response from list of contacts (or accounts)
    	system.debug('handleRequest -> 3 -> ' + matchingContacts);
    	SearchResponse searchResponse = buildSearchResponse(parameters, matchingRecords.matchingAccounts, matchingContacts);

    	// 4 set the totalRecords and response type
    	system.debug('handleRequest -> 4 -> ' + searchResponse);
    	searchResponse.ResponseType = 'Success';
    	searchResponse.TotalRecords = matchingRecords.totalRecords();

    	// 5. add details for each contact. return response
    	system.debug('handleRequest -> 5 -> ' + searchResponse.TotalRecords);
    	return buildFinalResponseLists(appendContactDetails(searchResponse, matchingContacts == null ? null : matchingContacts.keySet()));
    }

    /*
     * AppendContactDetails
     * Append the customer address and contact information details each found Contact to the ContactDet object
     * Keep this separate so we can return just the contact information if performance restrictions makes this additional detail unviable.
     * This is separate to the call that retrieves Contact details as it may be necessary to split this into a 2nd call if performance issues arise.
     */

	@testVisible private  static SearchResponse appendContactDetails(SearchResponse searchResponse, Set<Id> contactIds) {

    	if (isEmpty(contactIds)) {
    		system.debug('no contacts passed into method. No details to retrieve');
    		return searchResponse;
    	}

    	List<Membership__c> contactMembershipRecords = [
    		SELECT ID, Contact__c, Contact__r.AccountId, MembershipExternalID__c,
    		Eligible_for_Member_Benefits__c, Cancellation_Type__c, Cancellation_Reason__c, Cancellation_Date__c, Expiration_Date_Time__c, Enrollment_Date_Time__c, Renewal_Term__c
    		FROM Membership__c
    		WHERE Contact__c in :contactIds
    	];
  	
		if (!FeatureFlagService.isSinglePaneCCLUFeatureActive()) {
			
	    	List<Customer_Address__c> customerAddressRecords = [
	    		SELECT Id, Contact__c, Contact__r.AccountId, Is_Inactive__c, Is_Principal_Address__c, Address__c,
	       		Address__r.Address_1__c, Address__r.Address_2__c, Address__r.City__c, Address__r.State__c, Address__r.Country__c, Address__r.Zip__c
				FROM Customer_Address__c
				WHERE Contact__c in :contactIds
				AND Is_Inactive__c = false
	    	];
	
	    	List<Contact_Information__c> contactInformationRecords = [
				SELECT ID, Contact__c, Contact__r.AccountId, Email__c, Phone__c, Phone_Extension__c, Is_Inactive__c, Is_Primary__c, Contact_Information_Medium__c
	    		FROM Contact_Information__c
	    		WHERE Contact__c in :contactIds
	    		AND Is_Inactive__c = false
	    	];			
	    	
	    	if (!isEmpty(customerAddressRecords)) {
	    		system.debug('append customer address/address records: ' + customerAddressRecords);
		    	for (Customer_Address__c addr : customerAddressRecords) {
		    		AccountDet accountDetail = searchResponse.accountMap.get(addr.Contact__r.AccountId);
		    		ContactDet contactDetail = accountDetail.contactMap.get(addr.Contact__c);
		    		contactDetail.addAddress(new AddressDet(addr));
		    	}
	    	}	
	    	if (!isEmpty(contactInformationRecords)) {
	    		system.debug('append contact information records: ' + contactInformationRecords);
		    	for (Contact_Information__c info : contactInformationRecords) {
		    		AccountDet accountDetail = searchResponse.accountMap.get(info.Contact__r.AccountId);
		    		ContactDet contactDetail = accountDetail.contactMap.get(info.Contact__c);
		    		if (info.Contact_Information_Medium__c == 'Email') {
		    			system.debug('add email' + info);
		    			contactDetail.addEmail(new EmailDet(info));
		    		} else if (info.Contact_Information_Medium__c == 'Phone') {
		    			system.debug('add phone' + info);
		    			contactDetail.addPhoneNumber(new PhoneNumberDet(info));
		    		}
		    	}
	    	}
		} else {
			
			List<Contact_Address__c> contactAddressRecords = [
	    		SELECT Id, Contact__c, Contact__r.AccountId, Is_Inactive__c,
	    		First_Name__c, Last_Name__c, Company_Name__c,
	    		Email__c, Day_Phone__c,
	       		Address_1__c, Address_2__c, City__c, State__c, Country__c, Zip__c
				FROM Contact_Address__c
				WHERE Contact__c in :contactIds
				AND is_Searchable__c = true
	    	];
	    				
			if (!isEmpty(contactAddressRecords)) {
	    		system.debug('append contact address records: ' + contactAddressRecords);
		    	for (Contact_Address__c addr : contactAddressRecords) {
		    		AccountDet accountDetail = searchResponse.accountMap.get(addr.Contact__r.AccountId);
		    		ContactDet contactDetail = accountDetail.contactMap.get(addr.Contact__c);
		    		contactDetail.addAddress(new AddressDet(addr));
		    		contactDetail.addEmail(new EmailDet(addr));
		    		contactDetail.addPhoneNumber(new PhoneNumberDet(addr));
		    	}
	    	}
		}

    	if (!isEmpty(contactMembershipRecords)) {
    		Map<Object, List<Membership__c>> membershipMap = Utility.mapByProperty(Membership__c.Contact__c, contactMembershipRecords);
    		system.debug('append membership details: ' + contactMembershipRecords);
    		for (Object contactId : membershipMap.keySet()) {
    			List<Membership__c> membershipRecords = membershipMap.get(contactId);
    			if (membershipRecords != null && membershipRecords.size() > 0) {
		    		AccountDet accountDetail = searchResponse.accountMap.get(membershipMap.get(contactId).get(0).Contact__r.AccountId);
		    		ContactDet contactDetail = accountDetail.contactMap.get((String)contactId);

		    		for (Integer index = 0; index < membershipRecords.size(); index ++) {
			    		if (contactDetail.EligibleForMemberBenefits != true) {
			    			if ((membershipRecords.get(index).Cancellation_Type__c != 'RH Terminated' && membershipRecords.get(index).Cancellation_Reason__c != 'Created in error' && membershipRecords.get(index).Cancellation_Reason__c != 'Duplicate membership')
			    				|| (index == membershipRecords.size()-1 && contactDetail.RHMemberId == null)) {
								contactDetail.RHMemberId = membershipRecords.get(index).MembershipExternalID__c;
								contactDetail.EligibleForMemberBenefits = contactDetail.RHMember = membershipRecords.get(index).Eligible_for_Member_Benefits__c;
				    			contactDetail.MemberCancellationType = membershipRecords.get(index).Cancellation_Type__c;
				    			contactDetail.MemberCancellationReason = membershipRecords.get(index).Cancellation_Reason__c;
				    			contactDetail.MemberCancellationDate = membershipRecords.get(index).Cancellation_Date__c;
				    			contactDetail.MemberExpirationDateTime = membershipRecords.get(index).Expiration_Date_Time__c;
				    			contactDetail.MemberEnrollmentDateTime = membershipRecords.get(index).Enrollment_Date_Time__c;
				    			contactDetail.MemberRenewalTerm = membershipRecords.get(index).Renewal_Term__c;
			    			}

			    		}
		    		}

    			}
    		}
    	}

    	system.debug('appended search results: ' + searchResponse);
    	return searchResponse;
    }

    /*
     * buildSearchResponse
     * Populate the SearchResponse object based on the contacts found
     * Check
     * 1. if there matching contacts to attach to search response
     * 2. if the search response contains that account already
     * 3. if not then add matching account (create blank node if account details were not explicitly searched on)
     */

	@testVisible private  static SearchResponse buildSearchResponse(SearchParameters parameters, Map<Id, Account> matchingAccounts, Map<Id, Contact> matchingContacts) {
    	SearchResponse searchResponse = new SearchResponse();

    	// add matching accounts
    	
    	if (matchingAccounts != null && !isEmpty(matchingAccounts.values())) {
    		for(Id accountId : matchingAccounts.keySet()) {
    			searchResponse.accountMap.put(accountId, new AccountDet(matchingAccounts.get(accountId)));
    		}
    	}

    	// add matching contacts
    	
		if (matchingContacts != null && !isEmpty(matchingContacts.values())) {
    		system.debug('add matching contacts: ' + matchingContacts.keySet());
    		for(Contact contact : matchingContacts.values()) {
				// generate the account for contact if not already in map
    			if (!searchResponse.accountMap.containsKey(contact.AccountId)) {
    				searchResponse.accountMap.put(contact.AccountId, new AccountDet(contact, !parameters.hasAccountFilter()));
    			}
    			// add the contact to that account
    			searchResponse.accountMap.get(contact.AccountId).contactMap.put(contact.Id, new ContactDet(contact));
    		}
		}
    	return searchResponse;
    }

    /*
     * Retrieve the Contact details required for the found contact Ids
     * Collects all Contact and Account details required for the ContactDet object
     * Also collects all Account information required for the non-empty Account node (if Accounts were included in the search)
     */

	@testVisible private  static Map<Id, Contact> getContactMap(Set<ID> foundContactIds, Integer rowLimit) {
    	system.debug('getMatchingContacts: ' + foundContactIds);
		if (isEmpty(foundContactIds)) {
			return null;
		}

    	return new Map<Id, Contact>([
    		SELECT Id, AccountId, FirstName, LastName, Title, Unauthorized_Contact_Checkbox__c, 
    			   MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode, Email,
    			   HomePhone, AssistantPhone, MobilePhone, WorkPhone__c, Phone,
    		       Account.RecordTypeId, Account.X12_Digit_Member__c, Account.Name, Account.IsPersonAccount, Account.Verify_Tax_Exempt_Credentials__c,
    		       Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry, Account.Phone,
    		       Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingPostalCode, Account.ShippingCountry
    		FROM Contact
    		WHERE ID in :foundContactIds
    		LIMIT :rowLimit
    	]);
    }

    /*
     * Find all the contacts (or accounts) that match with the search parameters.
     * If filter includes postal code then need to filter by customer address
     * If filter includes email / phone then need to filter by contact information
     * If filter includes contact filter then need to filter by contact
     * else can filter on account (covers accounts that have no contacts associated)
     */

	@testVisible private  static MatchingRecords findMatchingRecords(SearchParameters parameters) {

		MatchingRecords records = new MatchingRecords();		
		
		if(FeatureFlagService.isSinglePaneCCLUFeatureActive()) {
		
			if (parameters.hasMemberFilter()) {
				// Get all the matching Contacts from the Membership__c records
				List<Membership__c> matchingMembers = filterMembership(parameters);
				if (!isEmpty(matchingMembers)) {
					for (Membership__c filteredMember : matchingMembers) {
						system.debug('Membership__c.Contact.ID : ' + filteredMember.Contact__c);
						records.matchingContactIds.add(filteredMember.Contact__c);
					}
				} 
			} else {
	    		// Get all the matching Contacts from contact address
	    		system.debug('filter on contact address: ' + FeatureFlagService.isMdmAddressFeatureActive());
				List<Contact_Address__c> matchingContactAddresses = filterContactAddress(parameters);
				if(!isEmpty(matchingContactAddresses)) {
					for(Contact_Address__c filteredAddress : matchingContactAddresses) {
						system.debug('ContactAddress.Contact.ID : ' + filteredAddress.Contact__c);
						records.matchingContactIds.add(filteredAddress.Contact__c);
					}
				}
		    	// Get all the matching Contacts
		    	// Can be called without any contact filter - if so all contacts under company will be returned
				List<Contact> matchingContacts = filterContacts(parameters);
				if (!isEmpty(matchingContacts)) {
					for (Contact c : matchingContacts) {
						system.debug('Contact.ID : ' + c.Id);
						records.matchingContactIds.add(c.Id);
					}
				}					
			}		
			
		} else {
			
			if (parameters.hasMemberFilter()) {
				// Get all the matching Contacts from the Membership__c records
				List<Membership__c> matchingMembers = filterMembership(parameters);
				if (!isEmpty(matchingMembers)) {
					for (Membership__c filteredMember : matchingMembers) {
						system.debug('Membership__c.Contact.ID : ' + filteredMember.Contact__c);
						records.matchingContactIds.add(filteredMember.Contact__c);
					}
				}
			} else if (parameters.hasCustomerAddressFilter()) {    		
	    		// Get all the matching Contacts from customer address
				List<Customer_Address__c> matchingCustomerAddresses = filterCustomerAddress(parameters);
				if(!isEmpty(matchingCustomerAddresses)) {
					for(Customer_Address__c filteredAddress : matchingCustomerAddresses) {
						system.debug('CA.Contact.ID : ' + filteredAddress.Contact__c);
						records.matchingContactIds.add(filteredAddress.Contact__c);
					}
				}
	    	} else if (parameters.hasContactInformationFilter()) {
	    		// Get all the matching Contacts from contact information
				List<Contact_Information__c> matchingContactInformation = filterContactInformation(parameters);
				if(!isEmpty(matchingContactInformation)) {
					for(Contact_Information__c filteredContactInfo : matchingContactInformation) {
						system.debug('CI.Contact.ID : ' + filteredContactInfo.Contact__c);
						records.matchingContactIds.add(filteredContactInfo.Contact__c);
					}
				}
	    	} else {
		    	// Get all the matching Contacts
		    	// Can be called without any contact filter - if so all contacts under company will be returned
				List<Contact> matchingContacts = filterContacts(parameters);
				if (!isEmpty(matchingContacts)) {
					for (Contact c : matchingContacts) {
						system.debug('Contact.ID : ' + c.Id);
						records.matchingContactIds.add(c.Id);
					}
				}
	    	}			
		}
    
    	if (isEmpty(records.matchingContactIds) && !parameters.hasMemberFilter() && !parameters.hasContactFilter() && !parameters.hasContactInformationFilter() && !parameters.hasCustomerAddressFilter()) {
    		// Get all the matching Accounts
    		// Catches edge case where matching account has no contacts
    		// Should only be called if the only filter is company level.
			records.matchingAccounts = filterAccounts(parameters);
    	}

		return records;
    }

    /*
     * Take the maps that are used to generate the hierarchical data, and convert them to LISTS
     * for the JSON/XML response. Maps would not be easy to traverse for the end user.
     */

    private static SearchResponse buildFinalResponseLists(SearchResponse response) {
    	response.Accounts = new List<AccountDet>();
    	response.Accounts.addAll(response.accountMap.values());

    	for (AccountDet account : response.Accounts) {
    		account.Contacts = new List<ContactDet>();
    		account.Contacts.addAll(account.contactMap.values());
    	}

    	return response;
    }

    /**
     * Helper methods
     * Some of these may be useful enough to move to Utility class
     */

	@testVisible private  static Set<Id> buildRecordTypeFilter(SearchParameters parameters) {
    	Set<Id> ids = new Set<Id>();
    	if (String.isEmpty(parameters.accountTypes)) {
    		return null;
    	}
    	if (ACCOUNT_RECORD_TYPES == null || ACCOUNT_RECORD_TYPES.values().size() < 1) {
    		return null;
    	}
    	for(String accountType : parameters.accountTypes.split(',')) {
    		if (ACCOUNT_RECORD_TYPES.containsKey(accountType)) {
    			ids.add(ACCOUNT_RECORD_TYPES.get(accountType).getRecordTypeId());
    		}
    	}
    	return ids;
    }

    private static String getAccountName(Id recordTypeId) {
    	if (ACCOUNTS_RECORD_TYPE_IDS.containsKey(recordTypeId)) {
    		return ACCOUNTS_RECORD_TYPE_IDS.get(recordTypeId).Name;
    	}
    	return null;
    }

    private static String getFilterType(Integer filterCount) {
    	return filterCount == 0 ? ' WHERE ' : ' AND ';
    }

    private static Boolean isEmpty(List<SObject> listObject) {
    	return listObject == null || listObject.size() < 1;
    }

    private static Boolean isEmpty(Set<Id> setIds) {
    	return setIds == null || setIds.size() < 1;
    }

    private static String removeNonAlphanumericCharacters(String originalText) {
		Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9]');
		Matcher matcher = nonAlphanumeric.matcher(originalText);
		return matcher.replaceAll('');
    }

    private static String getNodeText(Dom.XmlNode rootNode, String elementName) {
    	Dom.XmlNode childElement = rootNode.getChildElement(elementName, null);
    	return childElement == null ? null : childElement.getText();
    }

	@testVisible private  static SearchParameters buildSearchParameters(String request) {
    	system.debug('build client look up request: ' + request);
   		if (request.startsWith('{')) {
			PointlessClientLookupRequestWrapper pointlessWrapper = (PointlessClientLookupRequestWrapper)JSON.deserialize(request, PointlessClientLookupRequestWrapper.class);
			return pointlessWrapper.ClientLookupRequest;
   		}
   		return null;
    }

	@testVisible private  static SearchParameters buildSearchParameters(RestRequest req) {
    	if (req.params.containsKey('json')) {
    		return (SearchParameters)JSON.deserialize(req.params.get('json'), PointlessClientLookupRequestWrapper.class);
    	}
	    SearchParameters parameters = new SearchParameters();
	    parameters.firstName = req.params.get('FirstName');
	    parameters.lastName = req.params.get('LastName');
    	return parameters;
    }
    
	public static String cleanString(String source) {
    	return String.isBlank(source) ? '' : Utility.stripNonAlphanumericCharacters(Utility.stripAccents(source.toUpperCase().trim()));
    }       

    /*
     * Search Accounts
     * ONLY search when Account specific search parameters are provided
     * Currently this is just the company name and TradeID
     */

	@testVisible private  static Map<Id, Account> filterAccounts(SearchParameters parameters) {

    	system.debug('filterAccounts: ' + parameters);
    	Integer filterCount = 0;
    	String query = 'SELECT ID, '
					 + 'RecordTypeId, X12_Digit_Member__c, Name, IsPersonAccount, Verify_Tax_Exempt_Credentials__c, '
					 + 'BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone, '
					 + 'ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry '
    				 + 'FROM ACCOUNT';

    	if (String.isNotEmpty(parameters.company)) {
    		String company = parameters.company.trim();
    		query = query + getFilterType(filterCount) + 'Name = :company AND IsPersonAccount = false';
    		filterCount++;
    	}

    	if (String.isNotEmpty(parameters.tradeID)) {
    		String tradeID = parameters.tradeID.trim();
    		query = query + getFilterType(filterCount) + 'X12_Digit_Member__c = :tradeID';
    		filterCount++;
    	}
    	
		if (!isEmpty(buildRecordTypeFilter(parameters))) {
			Set<Id> recordTypeIds = buildRecordTypeFilter(parameters);
			query = query + getFilterType(filterCount) + 'RecordTypeId in :recordTypeIds';
			filterCount++;
		}    
		
		if (String.isNotEmpty(parameters.phoneNumber)) {
    		String phoneNumberFilter = removeNonAlphanumericCharacters(parameters.phoneNumber);
    		query = query + getFilterType(filterCount) + 'Phone = :phoneNumberFilter';
    		filterCount++;
    	}

		if (filterCount == 0) {
			return null;
		}

		integer rowLimit = parameters.RowLimit;
		
		system.debug('filterAccounts: ' + query);
		return new Map<Id, Account>((List<Account>)Database.query(query +  ' LIMIT :rowLimit'));
    }

    /*
     * Search contacts based on provided search parameters
     */

	@testVisible private  static List<Contact> filterContacts(SearchParameters parameters) {

    	system.debug('filterContacts: ' + parameters);
    	Integer filterCount = 0;
    	String query = 'SELECT ID FROM CONTACT ';

    	if (String.isNotEmpty(parameters.rhMemberId)) {
    		String rhMemberId = parameters.rhMemberId.trim();
    		query = query + getFilterType(filterCount) + 'Membership_ID__c = :rhMemberId';
    		filterCount++;
    	}

    	if (String.isNotEmpty(parameters.email)) {
    		String emailfilter = parameters.email.trim();
    		query = query + getFilterType(filterCount) + 'Email = :emailfilter';
    		filterCount++;
    	}

    	if (String.isNotEmpty(parameters.phoneNumber)) {
    		String phoneNumberFilter = removeNonAlphanumericCharacters(parameters.phoneNumber);
    		query = query + getFilterType(filterCount) + '(Phone = :phoneNumberFilter OR Account.Phone = :phoneNumberFilter)';
    		filterCount++;
    	}

		if (String.isNotEmpty(parameters.firstname)) {
			String firstName = parameters.firstName.trim();
			query = query + getFilterType(filterCount) + 'FirstName = :firstName';
			filterCount++;
		}

		if (String.isNotEmpty(parameters.lastName)) {
			String lastName = parameters.lastName.trim();
			query = query + getFilterType(filterCount) + 'LastName = :lastName';
			filterCount++;
		}

		if (String.isNotEmpty(parameters.postalCode)) {
			String postalCode = parameters.postalCode.trim() + '%';
			query = query + getFilterType(filterCount) + 'MailingPostalCode LIKE :postalCode';
			filterCount++;
		}

		if (!isEmpty(buildRecordTypeFilter(parameters))) {
			Set<Id> recordTypeIds = buildRecordTypeFilter(parameters);
			query = query + getFilterType(filterCount) + 'Account.RecordTypeId in :recordTypeIds';
			filterCount++;
		}

		if (String.isNotEmpty(parameters.company)) {
    		String company = parameters.company.trim();
    		query = query + getFilterType(filterCount) + 'Account.Name = :company AND IsPersonAccount = false';
    		filterCount++;
    	}

    	if (String.isNotEmpty(parameters.tradeID)) {
    		String tradeID = parameters.tradeID.trim();
    		query = query + getFilterType(filterCount) + 'Account.X12_Digit_Member__c = :tradeID';
    		filterCount++;
    	}

		if (filterCount == 0) {
			return null;
		}

		Integer rowLimit = parameters.RowLimit + 1; 
		system.debug('filterContacts: ' + query);		
		return Database.query(query + ' LIMIT :rowLimit');
    }

	/**
     * Returns all the membership records which match with all provided filters.
     * If no filters provided, returns null.
     */

	@testVisible private  static List<Contact_Address__c> filterContactAddress(SearchParameters parameters) {

    	system.debug('filterContactAddress: ' + parameters);
    	Integer filterCount = 0;
    	String query = 'SELECT Contact__c FROM Contact_Address__c ';

    	if (String.isNotEmpty(parameters.email)) {
    		String emailfilter = parameters.email.trim();
    		query = query + getFilterType(filterCount) + 'Email__c = :emailfilter AND is_Searchable__c = true';
    		filterCount++;
    	}

    	if (String.isNotEmpty(parameters.phoneNumber)) {
    		String phoneNumberFilter = removeNonAlphanumericCharacters(parameters.phoneNumber);
    		query = query + getFilterType(filterCount) + 'Day_Phone__c = :phoneNumberFilter AND is_Searchable__c = true';
    		filterCount++;
    	}

    	if (String.isNotEmpty(parameters.postalCode)) {
			String postalCode = parameters.postalCode.trim() + '%';
			query = query + getFilterType(filterCount) + 'Zip__c LIKE :postalCode AND is_Searchable__c = true';
			filterCount++;
		}

		if (String.isNotEmpty(parameters.firstName)) {
			String firstName = parameters.firstName.trim();
			// query = query + getFilterType(filterCount) + 'First_Name__c = :firstName AND is_Searchable__c = true';
			query = query + getFilterType(filterCount) + 'Contact__r.FirstName = :firstName';
			filterCount++;
		}

		if (String.isNotEmpty(parameters.lastName)) {
			String lastName = parameters.lastName.trim();
			// query = query + getFilterType(filterCount) + 'Last_Name__c = :lastName AND is_Searchable__c = true';
			query = query + getFilterType(filterCount) + 'Contact__r.LastName = :lastName';
			filterCount++;
		}

		if (!isEmpty(buildRecordTypeFilter(parameters))) {
			Set<Id> recordTypeIds = buildRecordTypeFilter(parameters);
			query = query + getFilterType(filterCount) + 'Contact__r.Account.RecordTypeId in :recordTypeIds';
			filterCount++;
		}

		if (String.isNotEmpty(parameters.company)) {
    		String company = parameters.company.trim();
    		query = query + getFilterType(filterCount) + 'Contact__r.Account.Name = :company AND Contact__r.IsPersonAccount = false';
    		filterCount++;
    	}

    	if (String.isNotEmpty(parameters.tradeID)) {
    		String tradeID = parameters.tradeID.trim();
    		query = query + getFilterType(filterCount) + 'Contact__r.Account.X12_Digit_Member__c = :tradeID';
    		filterCount++;
    	}
    	
		if (filterCount == 0) {
			return null;
		}

		Integer rowLimit = parameters.RowLimit + 1;
		system.debug('filterContactAddress: ' + query);
		return Database.query(query + ' LIMIT :rowLimit');
    }

    /**
     * Returns all the membership records which match with all provided filters.
     * If no filters provided, returns null.
     */

	@testVisible private  static List<Membership__c> filterMembership(SearchParameters parameters) {

    	system.debug('filterMembership: ' + parameters);
    	Integer filterCount = 0;
    	String query = 'SELECT Contact__c FROM Membership__c ';

    	if (String.isNotEmpty(parameters.RhMemberId)) {
    		String memberName = parameters.RhMemberId.trim();
    		query = query + getFilterType(filterCount) + 'Name = :memberName';
    		filterCount++;
    	}

		if (String.isNotEmpty(parameters.firstName)) {
			String firstName = parameters.firstName.trim();
			query = query + getFilterType(filterCount) + 'Contact__r.FirstName = :firstName';
			filterCount++;
		}

		if (String.isNotEmpty(parameters.lastName)) {
			String lastName = parameters.lastName.trim();
			query = query + getFilterType(filterCount) + 'Contact__r.LastName = :lastName';
			filterCount++;
		}

		if (!isEmpty(buildRecordTypeFilter(parameters))) {
			Set<Id> recordTypeIds = buildRecordTypeFilter(parameters);
			query = query + getFilterType(filterCount) + 'Contact__r.Account.RecordTypeId in :recordTypeIds';
			filterCount++;
		}

		if (String.isNotEmpty(parameters.company)) {
    		String company = parameters.company.trim();
    		query = query + getFilterType(filterCount) + 'Contact__r.Account.Name = :company AND Contact__r.IsPersonAccount = false';
    		filterCount++;
    	}

    	if (String.isNotEmpty(parameters.tradeID)) {
    		String tradeID = parameters.tradeID.trim();
    		query = query + getFilterType(filterCount) + 'Contact__r.Account.X12_Digit_Member__c = :tradeID';
    		filterCount++;
    	}

		if (filterCount == 0) {
			return null;
		}

		system.debug('filterMembership: ' + query);
		return Database.query(query);
    }

    /**
     * Returns all the contact information records which match with all provided filters.
     * If no filters provided, returns null.
     */

	@testVisible private  static List<Contact_Information__c> filterContactInformation(SearchParameters parameters) {

    	system.debug('filterContactInformation: ' + parameters);
    	Integer filterCount = 0;
    	String query = 'SELECT Contact__c FROM Contact_Information__c ';

    	if (String.isNotEmpty(parameters.email)) {
    		String emailfilter = parameters.email.trim();
    		query = query + getFilterType(filterCount) + 'Email__c = :emailfilter AND Is_Inactive__c = false';
    		filterCount++;
    	}

    	if (String.isNotEmpty(parameters.phoneNumber)) {
    		String phoneNumberFilter = removeNonAlphanumericCharacters(parameters.phoneNumber);
    		query = query + getFilterType(filterCount) + 'Phone__c = :phoneNumberFilter AND Is_Inactive__c = false';
    		filterCount++;
    	}

		if (String.isNotEmpty(parameters.firstName)) {
			String firstName = parameters.firstName.trim();
			query = query + getFilterType(filterCount) + 'Contact__r.FirstName = :firstName';
			filterCount++;
		}

		if (String.isNotEmpty(parameters.lastName)) {
			String lastName = parameters.lastName.trim();
			query = query + getFilterType(filterCount) + 'Contact__r.LastName = :lastName';
			filterCount++;
		}

		if (!isEmpty(buildRecordTypeFilter(parameters))) {
			Set<Id> recordTypeIds = buildRecordTypeFilter(parameters);
			query = query + getFilterType(filterCount) + 'Contact__r.Account.RecordTypeId in :recordTypeIds';
			filterCount++;
		}

		if (String.isNotEmpty(parameters.company)) {
    		String company = parameters.company.trim();
    		query = query + getFilterType(filterCount) + 'Contact__r.Account.Name = :company AND Contact__r.IsPersonAccount = false';
    		filterCount++;
    	}

    	if (String.isNotEmpty(parameters.tradeID)) {
    		String tradeID = parameters.tradeID.trim();
    		query = query + getFilterType(filterCount) + 'Contact__r.Account.X12_Digit_Member__c = :tradeID';
    		filterCount++;
    	}

		if (filterCount == 0) {
			return null;
		}

		Integer rowLimit = parameters.RowLimit + 1;
		system.debug('filterContactInformation: ' + query);
		return Database.query(query + ' LIMIT :rowLimit');
    }

    /*
     * Search Customer Address For contacts that match the search parameters
     * Currently this only differs from Contact search by the ZIP code.
     */

	@testVisible private  static List<Customer_Address__c> filterCustomerAddress(SearchParameters parameters) {

    	system.debug('filterCustomerAddress: ' + parameters);
    	Integer filterCount = 0;
    	String query = 'SELECT Contact__c FROM Customer_Address__c ';

    	if (String.isNotEmpty(parameters.email)) {
    		String emailfilter = parameters.email.trim();
    		query = query + getFilterType(filterCount) + 'Contact__r.Email = :emailfilter';
    		filterCount++;
    	}

    	if (String.isNotEmpty(parameters.phoneNumber)) {
    		String phoneNumberFilter = removeNonAlphanumericCharacters(parameters.phoneNumber);
    		query = query + getFilterType(filterCount) + 'Contact__r.Phone = :phoneNumberFilter';
    		filterCount++;
    	}

		if (String.isNotEmpty(parameters.firstName)) {
			String firstName = parameters.firstName.trim();
			query = query + getFilterType(filterCount) + 'Contact__r.FirstName = :firstName';
			filterCount++;
		}

		if (String.isNotEmpty(parameters.lastName)) {
			String lastName = parameters.lastName.trim();
			query = query + getFilterType(filterCount) + 'Contact__r.LastName = :lastName';
			filterCount++;
		}

		if (String.isNotEmpty(parameters.postalCode)) {
			String postalCode = parameters.postalCode + '%';
			query = query + getFilterType(filterCount) + 'Address__r.Zip__c LIKE :postalCode';
			filterCount++;
		}

		if (!isEmpty(buildRecordTypeFilter(parameters))) {
			Set<Id> recordTypeIds = buildRecordTypeFilter(parameters);
			query = query + getFilterType(filterCount) + 'Contact__r.Account.RecordTypeId in :recordTypeIds';
			filterCount++;
		}

		if (String.isNotEmpty(parameters.company)) {
    		String company = parameters.company.trim();
    		query = query + getFilterType(filterCount) + 'Contact__r.Account.Name = :company AND Contact__r.IsPersonAccount = false';
    		filterCount++;
    	}

    	if (String.isNotEmpty(parameters.tradeID)) {
    		String tradeID = parameters.tradeID.trim();
    		query = query + getFilterType(filterCount) + 'Contact__r.Account.X12_Digit_Member__c = :tradeID';
    		filterCount++;
    	}

		if (filterCount == 0) {
			return null;
		}

		Integer rowLimit = parameters.RowLimit + 1;
		system.debug('filterCustomerAddress: ' + query);
		return Database.query(query + ' LIMIT :rowLimit');
    }
}