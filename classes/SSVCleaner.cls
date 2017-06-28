/**
 *  SSVCleaner.cls
 *  @description Helper class to prepare fields for Source System View duplicate rules
 *               to perform duplicate matching on normalized fields
 *  @author Ernesto Valdes, Traction On Demand
 */
public class SSVCleaner {

	private @testVisible List<Source_System_View__c> records;
	private @testVisible List<Source_System_View__c> filteredRecords;
	private @testVisible Boolean filtered = false;

	/**
	 *  Field set containing relevant fields to determine duplicates, and if a sync is needed
	 */
	private static List<Schema.FieldSetMember> integrationFields =
		SObjectType.Source_System_View__c.FieldSets.Duplicate_Person_Identification_Fields.getFields();


	public SSVCleaner(List<Source_System_View__c> records) {
		this.records = records;
	}
	
	public List<Source_System_View__c> getFilteredRecords() {
		return this.filteredRecords;
	}

	/**
	 *  @description Determines if a record is new or has a relevant change,
	 *               and schedules a queued sync of the record to its related objects
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2015-11-03
	 *  @param       oldMap        The old versions of the records, used to determine if
	 *                             relevant fields have changed, or that the record is new (if map is null)
	 */
	public SSVCleaner filterChangedRecords(Map<Id, Source_System_View__c> oldMap) {

		filteredRecords = new List<Source_System_View__c>();
		filtered = true;

		// Iterate through records, and check if relevant fields have changed
		for (Source_System_View__c ssv : records) {

			// Get old version of record, if it exists
			Source_System_View__c oldSSV = (oldMap != null) ? oldMap.get(ssv.Id) : null;

			// Check if a relevant change has occurred
			if (hasIntegrationFieldChange(ssv, oldSSV)) {
				// mark records in need of reprocessing
				filteredRecords.add(ssv);
			}
		}

		return this;
	}

	/**
	 *  @description Iterates through integration fields and determines if a field has changed
	 *               or if the record is new
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2015-11-03
	 *  @param       ssv           Record to check
	 *  @param       oldSSV        Old Version of record to check 
	 *                             (if null, then record has no old version, and is therefore new)
	 *  @return                    True if record is new or changed, false otherwise
	 */
	private Boolean hasIntegrationFieldChange(Source_System_View__c ssv, Source_System_View__c oldSSV) {

		for (Schema.FieldSetMember field : integrationFields) {
			if (isNewOrFieldChanged(ssv, oldSSV, field)) return true;
		}
		return false;
	}

	/**
	 *  @description Determines if a record is new or changed, by checking the given field
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2015-11-03
	 *  @param       ssv           Record to check
	 *  @param       oldSSV        Old version of record to check
	 *  @param       field         Field to check for changes
	 *  @return                    True if record is new or changed, false otherwise
	 */
	private Boolean isNewOrFieldChanged(Source_System_View__c ssv, Source_System_View__c oldSSV, Schema.FieldSetMember field) {
		String fieldPath = field.getFieldPath();
		return (oldSSV == null) || (ssv.get(fieldPath) != oldSSV.get(fieldPath));
	}

	public SSVCleaner prepareMatchFields() {

		List<Source_System_View__c> recordsToPrepare = (filtered) ? filteredRecords : records;

		for (Source_System_View__c ssv :recordsToPrepare) {

			// Prepare company name
			String cleansedCompanyName = matchExcludedCompanyNames(ssv.Company_Name__c);
			ssv.Cleansed_Company_Name__c = cleanseCompanyName(cleansedCompanyName);

			// Prepare first & last name
			String cleansedFirstname = cleanseFirstName(ssv.First_Name__c);
			ssv.Cleansed_First_Name__c = normalizeFirstName(cleansedFirstName);
			ssv.Cleansed_Last_Name__c = cleanseLastName(ssv.Last_Name__c);

			// Prepare phone field for duplicate matching
			String cleansedPhone = cleansePhone(ssv.Day_Phone__c);
			ssv.Day_Phone_Match_Key__c = matchExcludedPhones(cleansedPhone);

			// Prepare address fields
			ssv.Address_Match_Key__c = cleanseAddress(	ssv.Address_1__c, 
														ssv.Address_2__c, 
														ssv.City__c,
														ssv.State__c, 
														ssv.Zip__c,
														ssv.Country_Code__c);
			ssv.Address_Match_Key_Hash__c = encodeHash(ssv.Address_Match_Key__c);

			// Set the match type
			ssv.Match_Type__c = determineMatchType(ssv);
			
			// If not a company prepare email field for duplicate matching
            if (ssv.Match_Type__c != 'Company') {            	
				String cleansedEmail = cleanseEmail(ssv.Email__c);
				cleansedEmail = matchExcludedEmails(cleansedEmail);
				if (!ssv.Is_RH_Employee__c) {
					cleansedEmail = matchExcludedEmailDomains(cleansedEmail);
				}            	
			   	ssv.Email_Match_Key__c =  cleansedEmail;
            }			

			// Set ready for duplicate check
			ssv.Processing_Status__c = SSVSelector.PROCESSING_STATUS_READY;
			ssv.Processing_Ready_Time__c = DateTime.now();
			ssv.Is_Ready_For_Duplicate_Check__c = true;
		}

		return this;
	}

	/**
	 *  @description Creates a SHA digest for a given string, and encodes it as base 64
	 *               for storage in a text field. Returns null if string is blank.
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2016-02-15
	 *  @param       toEncode      The given text string to encode
	 *  @return                    The encoded text string
	 */
	public static String encodeHash(String toEncode) {
		if (String.isBlank(toEncode)) {
			return null;
		}

		// Get string as blob
		Blob blobToEncode = Blob.valueOf(toEncode);

		// Generate digest for blob
		Blob encodedBlob = Crypto.generateDigest('SHA-256', blobToEncode);

		// Get 64bit encoded string 
		String encodedString = EncodingUtil.base64Encode(encodedBlob);

		return encodedString;
	}

	/**
	 *  @description Builds an address match key using the same method and pattern
	 *               as the one used for Source System View records
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2016-02-18
	 *  @param       addr          The given address for which to make a match key
	 *  @return                    The match key for the given address as a text string
	 */
	public static String buildAddressMatchKey(Address__c addr) {
		return cleanseAddress(	addr.Address_1__c, 
								addr.Address_2__c, 
								addr.City__c,
								addr.State__c, 
								addr.Zip__c,
								addr.Country_Code__c);
	}

	/**
	 *  @description Builds a contact information match key for a given contact information record
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2016-02-18
	 *  @param       contactInfo   The given contact information record for which to build a match key
	 *  @return                    The match key for the given record as a text string
	 */
	public static String buildContactInfoMatchKey(Contact_Information__c contactInfo) {
		return contactInfo.Contact__c + '' 
			+ contactInfo.Contact_Information_Medium__c + ''
			+ contactInfo.Email__c + '' 
			+ cleansePhone(contactInfo.Phone__c);
	}

	/**
	 *  @description Determines the match type of a given source system view record
	 *               if the Source_Table__c = 'Salesforce Account' then 'Company'
	 *               if the Source_Table__c = 'Salesforce Contact' then 'Contact'
	 *               else if cleansed company name exists (post exclusion) then 'Contact'
	 *               else 'Person'
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2016-02-11
	 *  @param       ssv           The source system view for which to determine match type
	 *  @return                    The requested match type as a string
	 */
	private @testVisible String determineMatchType(Source_System_View__c ssv) {

		if (ssv.Match_Type__c != null  && ssv.Match_Type__c != '') return ssv.Match_Type__c;

		String matchType;
		if (ssv.Source_Table__c == 'Salesforce Account') {
			matchType = 'Company';
		} else if (ssv.Source_Table__c == 'Salesforce Contact') {
			matchType = 'Contact';
		} else if (String.isNotEmpty(ssv.Trade_ID__c) || String.isNotEmpty(ssv.Cleansed_Company_Name__c)) {
			matchType = 'Contact';
		} else {
			matchType = 'Person';
		}

		return matchType;
	}

	private @testVisible String cleanseCompanyName(String companyNameToCleanse) {
		return companyNameToCleanse == null ? companyNameToCleanse : Utility.stripNonAlphanumericCharacters(Utility.stripAccents(companyNameToCleanse.toUpperCase()));
	}

	private @testVisible String matchExcludedCompanyNames(String companyNameToMatch) {
		if (companyNameToMatch == null) {
			return companyNameToMatch; 
		}
		return  (excludedCompanyNames.contains(companyNameToMatch.toUpperCase().trim())) ? null: companyNameToMatch;
	}

	public String normalizeCompanyName(String companyNameToCleanse) {

		String cleansedCompanyName = companyNameToCleanse;

		for (Cleanse_Company_Name__c ccn : companyNameAliases) {

			// If nothing to replace, just return
			if (cleansedCompanyName == null || cleansedCompanyName == '') return cleansedCompanyName;

			if (ccn.Match_Type__c == 'A') {

				// If match type is all, then replace all occurrences of current text
				cleansedCompanyName = cleansedCompanyName.replaceAll(ccn.Word_Match_String__c, ccn.Word_Replace_String__c);

			} else if (ccn.Match_Type__c == 'S') {

				// If match type is start of string, then replace the current text only at the start
				cleansedCompanyName = cleansedCompanyName.replaceFirst(
					'^' + ccn.Word_Match_String__c, 
					ccn.Word_Replace_String__c);

			} else if (ccn.Match_Type__c == 'E') {

				// If match type is end of string, then replace the current text only at the end
				cleansedCompanyName = cleansedCompanyName.replaceFirst(
					ccn.Word_Match_String__c + '$', 
					ccn.Word_Replace_String__c);
			}
		}

		return cleansedCompanyName;
	}

	private static @testVisible String cleanseAddress(	String address1, 
												String address2, 
												String city,
												String state, 
												String zip,
												String countryCode) {

		List<String> addressFields = new List<String>();
		if (address1 != null) addressFields.add(address1.trim());
		if (address2 != null) addressFields.add(address2.trim());
		if (city != null) addressFields.add(city.trim());
		if (state != null) addressFields.add(state.trim());
		if (zip != null) {
			if (String.isNotBlank(countryCode) && String.isNotBlank(zip) && (countryCode.trim() == 'US' || countryCode.trim() == 'USA') && zip.length() > 5) {
				addressFields.add(zip.trim().substring(0,5));
			} else {
				addressFields.add(zip.trim());
			}
		}

		String cleansedAddress = String.join(addressFields, '');

		if (cleansedAddress != null) {
			cleansedAddress = Utility.stripNonAlphanumericCharacters(cleansedAddress.toUpperCase());
		}

		return cleansedAddress;
	}

	/**
	 *  @description Matches a given first name against a table of possible aliases
	 *               and returns the normalized version if a match is found
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2016-01-26
	 *  @param       firstNameToNormalize The first name to be matched
	 *  @return                           The normalized version, if a match was found
	 *                                    The same name otherwise
	 */
	private @testVisible String normalizeFirstName(String firstNameToNormalize) {

		return (firstNameAliasMap.containsKey(firstNameToNormalize)) ?
											firstNameAliasMap.get(firstNameToNormalize) :
											firstNameToNormalize;		
	}

	/**
	 *  @description Converts a given first name to standard form, using an alias table
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2016-01-14
	 *  @param       firstNameToCleanse The given first name to standardize
	 *  @return                         The standardized first name as a string
	 */
	private static @testVisible String cleanseFirstName(String firstNameToCleanse) {
		return firstNameToCleanse == null ? firstNameToCleanse : Utility.stripNonAlphanumericCharacters(Utility.stripAccents(firstNameToCleanse.toUpperCase()));
	}

	/**
	 *  @description Cleans a given last name
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2016-01-14
	 *  @param       lastNameToCleanse The given last name to standardize
	 *  @return                        The standardized last name as a string
	 */
	private static @testVisible String cleanseLastName(String lastNameToCleanse) {
		return lastNameToCleanse == null ? lastNameToCleanse : Utility.stripNonAlphanumericCharacters(Utility.stripAccents(lastNameToCleanse.toUpperCase()));
	}

	/**
	 *  @description Matches a given phone number to a table of excluded phone numbers
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2016-01-26
	 *  @param       phoneToMatch  The phone number to match
	 *  @return                    Null string if a match is found and the phone must be excluded
	 *                             Same given phone number if no match is found
	 */
	private @testVisible String matchExcludedPhones(String phoneToMatch) {
		return  (excludedPhoneNumbers.contains(phoneToMatch)) ? 
										null: 
										phoneToMatch;
	}

	/**
	 *  @description Sets phone match key from phone
	 *               Removes spaces punctuation, and common phone characters
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2016-01-12
	 *  @param       phoneToCleanse The phone to cleanse
	 *  @return 				    The cleansed phone as a string
	 */
	public static @testVisible String cleansePhone(String phoneToCleanse) {
		String cleansedPhone;
		if (phoneToCleanse != null) {
			
			// Remove common punctuation
			cleansedPhone = phoneToCleanse.replaceAll('[+-. ()]', '');

			// Remove leading 1s (removes US & Canada Country Code)
			cleansedPhone = (cleansedPhone != null) ? cleansedPhone.replaceAll('^1', '') : null;
		}
		return cleansedPhone;
	}

	private @testVisible String matchExcludedEmails(String emailToMatch) {
		return (excludedEmails.contains(emailToMatch)) ?
										null:
										emailToMatch;
	}

	/**
	 *  @description Match a given email's domain to a table of excluded email domains
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2016-01-26
	 *  @param       emailToMatch  The given email for which to match the domain
	 *  @return                    A null string if email domain is an excluded domain
	 *                             The given email if email domain is not an excluded domain
	 */
	private @testVisible String matchExcludedEmailDomains(String emailToMatch) {
		return (excludedEmailDomains.contains(getEmailDomain(emailToMatch))) ?
										null:
										emailToMatch;
	}

	/**
	 *  @description Sets email match key from email, 
	 *               unless email domain is invalid
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2016-01-12
	 *  @param       emailToCleanse The email to cleanse
	 *  @return 				    The cleansed email as a string
	 */
	private static @testVisible String cleanseEmail(String emailToCleanse) {

		String cleansedEmail = null;

		// Skip empty emails
		if (String.isNotEmpty(emailToCleanse)) {

			// Check for valid email format
			Pattern emailPattern = Pattern.compile('.+@.+\\..+');
			Matcher emailMatcher = emailPattern.matcher(emailToCleanse);

			// If email format is valid
			if (emailMatcher.matches()) {
				cleansedEmail = emailToCleanse.toUpperCase().trim();
			}
		}
		return cleansedEmail;
	}

	/**
	 *  @description Parses an email domain from a given email
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2016-01-12
	 *  @param       email         The email for which to get the domain
	 *  @return                    The extracted email domain
	 */
	private @testVisible String getEmailDomain(String email) {
		if (email == null) return email;

		if (email.contains('@')) {
			
			List<String> splitEmail = email.split('@');
			return (splitEmail.size() > 1 && splitEmail[1] != null) ? splitEmail[1].trim() : null;

		} else return null;
	}

	/**
	 *  Set of excluded email domains
	 */
	private @testVisible Set<String> excludedEmailDomains {
		get {
			if (excludedEmailDomains == null) {
				excludedEmailDomains = new Set<String>();

				Set<String> currentEmailDomains = new Set<String>();
				for (Source_System_View__c ssv : records) {
					if (ssv.Email__c != null) {
						String emailDomain = getEmailDomain(ssv.Email__c);
						if (emailDomain != null) {
							currentEmailDomains.add(emailDomain);
						}
						
					}
				}
				currentEmailDomains.remove(null);

				for (Cleanse_Match_Exclusion__c ee : [SELECT Exclusion_Value__c 
												FROM Cleanse_Match_Exclusion__c 
												WHERE Exclusion_Value__c IN :currentEmailDomains
													AND Exclusion_Value__c != null
													AND Exclusion_Type__c = 'Email Domain']) {
					excludedEmailDomains.add(ee.Exclusion_Value__c.toUpperCase());
				}
			}
			return excludedEmailDomains;
		} set;
	}

	/**
	 *  Set of excluded email domains
	 */
	private @testVisible Set<String> excludedEmails {
		get {
			if (excludedEmails == null) {
				excludedEmails = new Set<String>();

				Set<String> currentEmailDomains = new Set<String>();
				for (Source_System_View__c ssv : records) 
					currentEmailDomains.add(ssv.Email__c);
				currentEmailDomains.remove(null);

				for (Cleanse_Match_Exclusion__c ee : [SELECT Exclusion_Value__c 
												FROM Cleanse_Match_Exclusion__c 
												WHERE Exclusion_Value__c IN :currentEmailDomains
													AND Exclusion_Value__c != null
													AND Exclusion_Type__c = 'Email']) {
					excludedEmails.add(ee.Exclusion_Value__c.toUpperCase());
				}
			}
			return excludedEmails;
		} set;
	}

	/**
	 *  Set of excluded email domains
	 */
	private @testVisible Set<String> excludedPhoneNumbers {
		get {
			if (excludedPhoneNumbers == null) {
				excludedPhoneNumbers = new Set<String>();

				Set<String> cleansedPhones = new Set<String>();
				for (Source_System_View__c ssv : records) 
					cleansedPhones.add(cleansePhone(ssv.Day_Phone__c));
				cleansedPhones.remove(null);

				for (Cleanse_Match_Exclusion__c ee : [SELECT Exclusion_Value__c 
												FROM Cleanse_Match_Exclusion__c 
												WHERE Exclusion_Value__c IN :cleansedPhones
													AND Exclusion_Value__c != null
													AND Exclusion_Type__c = 'Phone']) {
					excludedPhoneNumbers.add(ee.Exclusion_Value__c.toUpperCase());
				}
			}
			return excludedPhoneNumbers;
		} set;
	}

	/**
	 *  Set of excluded company names
	 */
	private @testVisible Set<String> excludedCompanyNames {
		get {
			if (excludedCompanyNames == null) {
				excludedCompanyNames = new Set<String>();

				Set<String> companyNames = new Set<String>();
				for (Source_System_View__c ssv : records) 
					companyNames.add(ssv.Company_Name__c);
				companyNames.remove(null);

				for (Cleanse_Match_Exclusion__c ee : [SELECT Exclusion_Value__c 
												FROM Cleanse_Match_Exclusion__c 
												WHERE Exclusion_Value__c IN :companyNames
													AND Exclusion_Value__c != null
													AND Exclusion_Type__c = 'Company Name']) {
														
					excludedCompanyNames.add(ee.Exclusion_Value__c.toUpperCase());
					
				}
			}
			return excludedCompanyNames;
		} set;
	}

	/**
	 *  Map of first name common alias -> to standardized first name
	 */
	private @testVisible Map<String, String> firstNameAliasMap {
		get {
			if (firstNameAliasMap == null) {
				firstNameAliasMap = new Map<String, String>();

				Set<String> firstNames = new Set<String>();
				for (Source_System_View__c ssv :records) firstNames.add(cleanseFirstname(ssv.First_Name__c));			

				for (Cleanse_First_Name_Alias__c mka : [SELECT First_Name__c, First_Name_Corrected__c
												FROM Cleanse_First_Name_Alias__c
												WHERE First_Name__c IN :firstNames]) {
					firstNameAliasMap.put(mka.First_Name__c, mka.First_Name_Corrected__c);
				}
			}
			return firstNameAliasMap;
		} set;
	}

	/**
	 *  Map of company name alias -> to replacement alias
	 */
	private @testVisible List<Cleanse_Company_Name__c> companyNameAliases {
		get {
			if (companyNameAliases == null) {
				companyNameAliases = [
					SELECT Word_Match_String__c, Word_Replace_String__c, Match_Type__c
					FROM Cleanse_Company_Name__c
				];
			}
			return companyNameAliases;
		}
		set;
	}
}