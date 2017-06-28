public with sharing class ContactAddressService {
	
	/*
	 * Address fields - use this to check if any change has been made to a Contact Address record that requires a new match key
	 */
	 
	private @testvisible static Set<SObjectField> contactAddressFields = new Set<SObjectField> {
		Contact_Address__c.CONTACT__C, Contact_Address__c.ADDRESS_1__C, Contact_Address__c.CITY__C, Contact_Address__c.STATE__C, Contact_Address__c.ZIP__C, Contact_Address__c.COUNTRY__C,
		Contact_Address__c.DAY_PHONE__C, Contact_Address__c.FIRST_NAME__C, Contact_Address__c.LAST_NAME__C, Contact_Address__c.COMPANY_NAME__c
	};    
   
    /*
     * Build address records from Order
     * Parameters : list of orders that may require contact address records, type of contact address to be generated
     * Returns : list of orders updated
     */
     
	public enum ORDER_ADDRESS_TYPE {SOLD_TO, BILL_TO}
     
    
    public static List<Rh_Order__c> buildAddressForOrders (List<Rh_Order__c> orders, ORDER_ADDRESS_TYPE addressType) {
    	
    	Map<String, List<Rh_Order__c>> ordersByMatchKey = new Map<String, List<Rh_Order__c>>();
    	Map<String, Contact_Address__c> addressByMatchKey = new Map<String, Contact_Address__c>();
    
    	// 1. for each order - build a contact address
    	
    	for (Rh_Order__c order : orders) {
    		
    		if (order.Contact_Sold_To__c != null) {
    			    		
	    		system.debug('buildAddressForOrders -> process order ' + order.Id + ' with contact ' + order.Contact_Sold_To__c);
    			
    			Contact_Address__c contactAddress = null;
    			
    			if (order.ADDRESS_SOLD_TO__C == null && addressType == ORDER_ADDRESS_TYPE.SOLD_TO) {    				
    				contactAddress = generateSoldToContactAddress(order);
    			} else if (order.ADDRESS_BILL_TO__C == null && addressType == ORDER_ADDRESS_TYPE.BILL_TO && String.isNotBlank(order.Bill_To_Address_1__c)) {
    				contactAddress = generateBillToContactAddress(order);
    			}
    			
    			if (contactAddress != null) {
	    			if (!ordersByMatchKey.containsKey(contactAddress.ADDRESS_MATCH_KEY_HASH__C)) {
	    				ordersByMatchKey.put(contactAddress.ADDRESS_MATCH_KEY_HASH__C, new List<Rh_Order__c>());
	    			}
	    			ordersByMatchKey.get(contactAddress.ADDRESS_MATCH_KEY_HASH__C).add(new Rh_Order__c(
	    				ID = order.ID,
	    				SOLD_TO_EMAIL__c = order.SOLD_TO_EMAIL__c
	    			));
    			
	    			addressByMatchKey.put(contactAddress.ADDRESS_MATCH_KEY_HASH__C, contactAddress);    			
    				system.debug('buildAddressForOrders -> add address match key -> ' + contactAddress.ADDRESS_MATCH_KEY_HASH__C);
    			}
    		} 
    		
    	}
    	
    	// 2. get all the contact address records that exist
    	
    	Map<ID, Contact_Address__c> existingAddressRecords = new Map<Id, Contact_Address__c>([
    		SELECT ID, ADDRESS_MATCH_KEY__C, ADDRESS_MATCH_KEY_HASH__C, EMAIL__C
    		FROM Contact_Address__c
    		WHERE ADDRESS_MATCH_KEY_HASH__C in :ordersByMatchKey.keySet()
    	]);    	
    	
    	// 3.  
    	// Go through all the existing contact address records
    	// Fo all the orders that have the match key of the existing address record
    	// Associate those orders with that existing contact address record
    	// Then remove the contact address record with that match key from the spawn list (as no longer need to create it)
    	
    	for (Contact_Address__c address : existingAddressRecords.values()) {
    		
    		if (ordersByMatchKey.containsKey(address.ADDRESS_MATCH_KEY_HASH__C)) {
    			
    			// Email is not part of the match key as it is only available on the sold-to address records
    			// When matching, we can use the match key as is for bill-to and ship-to, but not sold-to, for those
    			// we also need to match on the email address
    			
    			Boolean matchFound = false;	    				    			
    			for (Rh_Order__c order : ordersByMatchKey.get(address.ADDRESS_MATCH_KEY_HASH__C)) {
    				if (addressType == ORDER_ADDRESS_TYPE.SOLD_TO && (order.SOLD_TO_EMAIL__c == address.EMAIL__C || String.isBlank(address.EMAIL__C))) {
    					order.Address_Sold_To__c = address.Id;
    					matchFound = true;
    				} else if (addressType == ORDER_ADDRESS_TYPE.BILL_TO) {
    					order.Address_Bill_To__c = address.Id;
    					matchFound = true;
    				} else {
    					system.debug('buildAddressForOrders -> ' + addressType + ' -> match key found but no match made -> ' + address + ' -> ' + order);
    				}   				
    			}
    			
    			// Known edge-case. Let's say in the same batch we have two orders with the exact same match key, but a different email address.
    			// The first order finds a match on both match key AND email with an existing record. It will associate with that contact address record
    			// The generated contact address record in the spawn list will then be removed, even if the second order does not find a match
    			// This is fine, as the second order will be processed the next time the batch runs, and will be paired with a newly created contact address record. 
    			
    			// remove this match key from the list of address records to be spawned
    			
				if (matchFound) {    	
					system.debug('buildAddressForOrders -> match found -> ' + address.Id + ' -> address -> ' + address.ADDRESS_MATCH_KEY_HASH__C);
    				addressByMatchKey.remove(address.ADDRESS_MATCH_KEY_HASH__C);
				}
    		}
    	}
    	
    	// 4. spawn created list
    	
    	if (!Utility.isEmpty(addressByMatchKey.values())) {
    		Utility.logInsert(addressByMatchKey.values());
    	}
    	
    	// 5. for each order - reference the new contact address	
    	
    	for (Contact_Address__c spawnedAddress : addressByMatchKey.values()) {
    		if (ordersByMatchKey.containsKey(spawnedAddress.ADDRESS_MATCH_KEY_HASH__C)) {
    			for (Rh_Order__c order : ordersByMatchKey.get(spawnedAddress.ADDRESS_MATCH_KEY_HASH__C)) {
    				system.debug('buildAddressForOrders -> setting order ' + order.id + ' to generated address -> ' + spawnedAddress.Id + ' -> ' + spawnedAddress.ADDRESS_MATCH_KEY_HASH__C);
    				if (addressType == ORDER_ADDRESS_TYPE.SOLD_TO) {
    					order.Address_Sold_To__c = spawnedAddress.Id;
    				} else {
    					order.Address_Bill_To__c = spawnedAddress.Id;
    				}      				
    			}
    		} 
    	} 
    	
		// 6. return updated ship-to records
    	system.debug('buildAddressForOrders -> returning orders records for update -> ' + ordersByMatchKey.values());
    	return flatten(ordersByMatchKey.values());
    }   
        
    
    /*
     * Build address records from Ship To
     */
    
    public static List<Ship_To__c> buildAddressForShipTos (List<Ship_To__c> shipTos) {
    	
    	Map<String, List<Ship_To__c>> shipTosByMatchKey = new Map<String, List<Ship_To__c>>();
    	Map<String, Contact_Address__c> addressByMatchKey = new Map<String, Contact_Address__c>();
    
    	// 1. for each ship to - build a contact address
    	
    	for (Ship_To__c shipTo : shipTos) {
    		
    		system.debug('buildAddressForShipTos -> process shipTo ' + shipTo.Id + ' with contact ' + shipTo.Order__r.Contact_Sold_To__c + ' linked to address ' + shipTo.Address_Ship_To__c);
    		
    		if (shipTo.Order__c != null && shipTo.Order__r.Contact_Sold_To__c != null && String.isBlank(shipTo.Address_Ship_To__c)) {
    			
    			Contact_Address__c shipToContactAddress = generateShipToContactAddress(shipTo);
    			
    			if (!shipTosByMatchKey.containsKey(shipToContactAddress.ADDRESS_MATCH_KEY_HASH__C)) {
    				shipTosByMatchKey.put(shipToContactAddress.ADDRESS_MATCH_KEY_HASH__C, new List<Ship_To__c>());
    			}
    			shipTosByMatchKey.get(shipToContactAddress.ADDRESS_MATCH_KEY_HASH__C).add(new Ship_To__c(
    				ID = shipTo.ID
    			));
    			
    			addressByMatchKey.put(shipToContactAddress.ADDRESS_MATCH_KEY_HASH__C, shipToContactAddress);
    			
    			system.debug('buildAddressForShipTos -> add ship-to match key -> ' + shipToContactAddress.ADDRESS_MATCH_KEY_HASH__C);
    		} 
    		
    	}
    	
    	// 2. get all the contact address records that exist
    	
    	Map<ID, Contact_Address__c> existingAddressRecords = new Map<Id, Contact_Address__c>([
    		SELECT ID, ADDRESS_MATCH_KEY__C, ADDRESS_MATCH_KEY_HASH__C
    		FROM Contact_Address__c
    		WHERE ADDRESS_MATCH_KEY_HASH__C in :shipTosByMatchKey.keySet()
    	]);    	
    	
    	// 3. go through created list, if it exists already, reference it, then remove from list to spawn
    	
    	for (Contact_Address__c address : existingAddressRecords.values()) {
    		
    		if (shipTosByMatchKey.containsKey(address.ADDRESS_MATCH_KEY_HASH__C)) {
    			
    			// associate all the ship-to records that had that match-key with the existing address
    			
    			for (Ship_To__C shipTo : shipTosByMatchKey.get(address.ADDRESS_MATCH_KEY_HASH__C)) {
    				shipTo.Address_Ship_To__c = address.Id;
    			}
    			
    			// remove this match key from the list of address records to be spawned
    			system.debug('buildAddressForShipTos -> match found -> ' + address.Id + ' -> address -> ' + address.ADDRESS_MATCH_KEY_HASH__C);
    			addressByMatchKey.remove(address.ADDRESS_MATCH_KEY_HASH__C);
    		}
    	}
    	
    	// 4. spawn created list
    	
    	if (!Utility.isEmpty(addressByMatchKey.values())) {
    		Utility.logInsert(addressByMatchKey.values());
    	}
    	
    	// 5. for each ship to - reference the new contact address	
    	
    	for (Contact_Address__c spawnedAddress : addressByMatchKey.values()) {
    		if (shipTosByMatchKey.containsKey(spawnedAddress.ADDRESS_MATCH_KEY_HASH__C)) {
    			for (Ship_To__c shipTo : shipTosByMatchKey.get(spawnedAddress.ADDRESS_MATCH_KEY_HASH__C)) {
    				system.debug('buildAddressForShipTos -> setting ship-to -> ' + shipTo.id + ' to generated address -> ' + spawnedAddress.Id + ' -> ' + spawnedAddress.ADDRESS_MATCH_KEY_HASH__C);
    				shipTo.Address_Ship_To__c = spawnedAddress.Id;
    			}
    		} 
    	} 
    	
		// 6. return updated ship-to records
    	system.debug('buildAddressForShipTos -> returning ship-to records for update -> ' + shipTosByMatchKey.values());
    	return flatten(shipTosByMatchKey.values());
    }   
    
    /*
     * Update Contact Address records associated with the list of orders
     * Split out this to (a) keep the spawning code simple
     * and (b) so this can be called separately in a different batch/transaction
     * Parameters: Takes a list of orders
     * Returns: List of updated contact address records
     */
    
    public static List<Contact_Address__c> updateSoldToContactAddressUsage(List<Rh_Order__c> orders) {
    	return updateContactAddressUsage(orders, Rh_Order__c.ADDRESS_SOLD_TO__C, Contact_Address__c.is_Sold_To_Address__c);
    } 

    public static List<Contact_Address__c> updateBillToContactAddressUsage(List<Rh_Order__c> orders) {
    	return updateContactAddressUsage(orders, Rh_Order__c.ADDRESS_BILL_TO__C, Contact_Address__c.is_Bill_To_Address__c);
    } 
    
    public static List<Contact_Address__c> updateShipToContactAddressUsage(List<Ship_To__c> shipTos) {
    	return updateContactAddressUsage(shipTos, Ship_To__c.ADDRESS_SHIP_TO__C, Contact_Address__c.Is_Ship_To_Address__c);
    }
    
	public static List<Contact_Address__c> updateContactAddressUsage(List<SObject> sourceList, SObjectField sourceField, SObjectField destinationField) {
		
		system.debug('ContactAddressService -> updateContactAddressUsage -> ' + sourceList);
		
		// 0. Pull out references to contact address records from the list of orders/ship-to records
		
		Map<ID, SObject> addressMap = new Map<ID, SObject>();
		for (SObject source : sourceList) {
			addressMap.put((ID)source.get(sourceField), source);
		}
		addressMap.remove(null);
		
		// 1. get the contact address records associated with the orders/ship-to records
		
		system.debug('ContactAddressService -> updateContactAddressUsage -> addressMap -> ' + addressMap);
		
		List<Contact_Address__c> associatedRecords = [
			SELECT ID, is_Sold_To_Address__c, Is_Bill_To_Address__c, Is_Ship_To_Address__c
			FROM Contact_Address__C
			WHERE ID IN :addressMap.keySet()
		];
				
		// 2. if the contact address is being used as a sold-to, bill-to, ship-to, then update those flags accordingly
		
		system.debug('ContactAddressService -> updateContactAddressUsage -> associatedRecords -> ' + associatedRecords);
		
		for (Contact_Address__c address : associatedRecords) {
			address.put(destinationField, ((Boolean)address.get(destinationField)) || addressMap.containsKey(address.Id));
		}
		
		// 3. return list of updated contact address records (just return all of them, not that big a difference)		
		
		system.debug('ContactAddressService -> updateContactAddressUsage -> updated records -> ' + associatedRecords);
		
		return associatedRecords;
	}      
	
	/*
	 * Fix the sold-to email issue
	 */
	 
	public static List<Contact_Address__c> fixSoldToEmailIssue(List<Rh_Order__c> orders) {
		
		system.debug('ContactAddressService -> fixSoldToEmailIssue -> ' + orders);
		
		Map<ID, Contact_Address__c> brokenRecords = new Map<ID, Contact_Address__c>();
		
		// get the ids of the orders to check
		
		Map<ID, Rh_Order__c> orderMap = new Map<Id, Rh_Order__c>(orders);
		
		// get the actual order details which show a fix is needed
		
		List<Rh_Order__c> parentOrders = [
			SELECT id, sold_to_email__c, address_sold_to__c
			FROM rh_order__c
			WHERE ID in :orderMap.keySet()
			AND address_sold_to__c != null
			AND sold_to_email__c != null	
			AND address_sold_to__r.email__c = null 
		];
		
		// add to the list of contact address record that need the fix (use map to stop dupes)
		
		system.debug('ContactAddressService -> fixSoldToEmailIssue -> parent orders -> ' + parentOrders);
		
		for (Rh_Order__c parentOrder : parentOrders) {
			if (!brokenRecords.containsKey(parentOrder.Address_Sold_To__c)) {
				brokenRecords.put(
					parentOrder.Address_Sold_To__c,
					new Contact_Address__c(
						ID = parentOrder.Address_Sold_To__c,
						Email__c = parentOrder.Sold_To_Email__c
					)
				);
			}
		}
		
		// return the list
		
		system.debug('ContactAddressService -> fixSoldToEmailIssue -> broken records -> ' + brokenRecords);		
		return brokenRecords.values();
	}	 
	 
            
    /*
     * Build addresses for PersonAccounts
     * Takes a map containing the IDs of all the accounts to load CA records for.
     * We do not associate the CA record with the account, only the contact record. Therefore retrieve the contacts associated 
     * (only person accounts - business accounts are handled by the Contact trigger - see next method)
     */
    
    public static List<Contact_Address__c> buildAddressForPersonAccounts(Map<ID, Account> accounts) {
    	
    	system.debug('ContactAddressService -> buildAddressForPersonAccounts -> ' + accounts);
    	
    	return buildAddressForContacts([
    		SELECT ID, FirstName, LastName, Account.Name, MailingStreet, MailingCity, MailingCountry, MailingState, MailingPostalCode, Phone, Email, Account.isPersonAccount 
			FROM Contact
			WHERE AccountID in :accounts.keySet()
			AND isPersonAccount = TRUE    		
    	]);
    }

    /*
     * Build addresses for Contacts
     * Takes a map containing the IDs of all the contacts to load CA records for.
     * This enables the Service to retrieve all the fields it needs. 
     * (Account.Name is not included in the dataset available to the Contact trigger) 
     */
    
    public static List<Contact_Address__c> buildAddressForContacts(Map<Id, Contact> contactMap) {
    	
    	system.debug('ContactAddressService -> buildAddressForContacts -> ' + contactMap);
    	
    	return buildAddressForContacts([
    		SELECT ID, FirstName, LastName, Account.Name, MailingStreet, MailingCity, MailingCountry, MailingState, MailingPostalCode, Phone, Email, Account.isPersonAccount 
			FROM Contact
			WHERE ID in :contactMap.keySet()   		
    	]);    	
    } 
    
	public static List<Contact_Address__c> buildAddressForContacts(List<Contact> contacts) {
		
		system.debug('ContactAddressService -> buildAddressForContacts -> ' + contacts);
		
		// 1. build up a list of match keys for the supplied contacts
		
		Map<String, Contact_Address__c> addressesByMatchKey = new Map<String, Contact_Address__c>();
		for (Contact newContact : contacts) {
			Contact_Address__c spawnedAddress = generateContactAddress(newContact);
			addressesByMatchKey.put(spawnedAddress.ADDRESS_MATCH_KEY_HASH__C, spawnedAddress);
		} 
		
		// 2. retrieve all the contact address records that match those match keys
		
		List<Contact_Address__c> existingAddresses = [
			SELECT ID, CONTACT__C, ADDRESS_MATCH_KEY__C, ADDRESS_MATCH_KEY_HASH__C, EMAIL__C
			FROM CONTACT_ADDRESS__C
			WHERE ADDRESS_MATCH_KEY_HASH__C in :addressesByMatchKey.keySet()
		];
		
		// 3. remove from required list all that already exist
		
		system.debug('ContactAddressService -> buildAddressForContacts -> existing ContactAddress records -> ' + existingAddresses);
		for (Contact_Address__c existingAddress : existingAddresses) {
			// remember the email is not in the match key

			if (addressesByMatchKey.get(existingAddress.ADDRESS_MATCH_KEY_HASH__C)!=null && existingAddress.Email__c == addressesByMatchKey.get(existingAddress.ADDRESS_MATCH_KEY_HASH__C).Email__c) {
					addressesByMatchKey.remove(existingAddress.ADDRESS_MATCH_KEY_HASH__C);
				}
			}

		
		// 4. return that list of spawned contact address records
		
		system.debug('ContactAddressService -> buildAddressForContacts -> spawned ContactAddress records -> ' + addressesByMatchKey.values());
		return addressesByMatchKey.values();
	}      
	
	/*
	 * Clean contact address
	 * Future job as it makes a callout to Melissa. 
	 * Appends (overwrites) the matchkey on any updated record
	 */
	 
	@future(callout=true) 
	public static void cleanseContactAddressRecords(Set<ID> contactAddressIds) {
		
		system.debug('ContactAddressService -> cleanseContactAddressRecords -> cleanse IDs -> ' + contactAddressIds);
		
		List<Contact_Address__c> cleansedRecords = cleanContactAddressRecords([
		    SELECT ID, CONTACT__C, First_Name__C, Last_Name__c, Address_1__c, Address_2__c, City__c, Zip__c, State__c, Country__c, Day_Phone__c, Email__c, Company_Name__c
			FROM Contact_Address__c
			WHERE ID in :contactAddressIds
		]); 
		
		system.debug('ContactAddressService -> cleanseContactAddressRecords -> cleansed Records -> ' + cleansedRecords);
		
		Utility.logUpdate(appendMissingMatchKeys(cleansedRecords, true));
	} 
	
	/*
	 * Clean contact address
	 * Method that does the work. Yes yes it is one long ugly method but none of this code was re-usable.
	 */	
	    
	public static List<Contact_Address__c> cleanContactAddressRecords(List<Contact_Address__c> contactAddresses) {
		
		system.debug('ContactAddressService -> cleanContactAddressRecords -> ' + contactAddresses);
		
		// 1. Build the XML for the request
		
      	String xmlString = null;
      	XmlStreamWriter xml = new XmlStreamWriter();
      	xml.writeStartDocument('UTF-8', '1.0');      
      	xml.writeStartElement(null, 'PersonatorRequest', null);
      	
      	for (Contact_Address__c contactAddress : contactAddresses) {

      		xml.writeStartElement(null,'RequestRecord', null);              

      		xml.writeStartElement(null,'FirstName', null);
      		xml.writeCharacters(orElseEmpty(contactAddress.First_Name__c));
	      	xml.writeEndElement();

      		xml.writeStartElement(null,'LastName', null);
      		xml.writeCharacters(orElseEmpty(contactAddress.Last_Name__c));
	      	xml.writeEndElement();
	      	
			xml.writeStartElement(null,'EmailAddress', null);
      		xml.writeCharacters(orElseEmpty(contactAddress.Email__c));
	      	xml.writeEndElement();

      		xml.writeStartElement(null,'CompanyName', null);
      		xml.writeCharacters(orElseEmpty(contactAddress.Company_Name__c));
	      	xml.writeEndElement();
	      		      	
      		xml.writeStartElement(null,'AddressLine1', null);
      		xml.writeCharacters(orElseEmpty(contactAddress.Address_1__c));
	      	xml.writeEndElement();
	      	
      		xml.writeStartElement(null,'AddressLine2', null);
      		xml.writeCharacters(orElseEmpty(contactAddress.Address_2__c));
	      	xml.writeEndElement();
	      	
      		xml.writeStartElement(null,'City', null);
      		xml.writeCharacters(orElseEmpty(contactAddress.CITY__c));
	      	xml.writeEndElement();
	      	
      		xml.writeStartElement(null,'PostalCode', null);
      		xml.writeCharacters(orElseEmpty(contactAddress.Zip__c));
	      	xml.writeEndElement();
	      	
      		xml.writeStartElement(null,'State', null);
      		xml.writeCharacters(orElseEmpty(contactAddress.State__c));
	      	xml.writeEndElement();	      		      		      		      		      		      	
	      		      	
      		xml.writeStartElement(null,'Country', null);
      		xml.writeCharacters(orElseEmpty(contactAddress.Country__c));
	      	xml.writeEndElement();
	      	
      		xml.writeStartElement(null,'PhoneNumber', null);
      		xml.writeCharacters(orElseEmpty(contactAddress.Day_Phone__c));
	      	xml.writeEndElement();	    
	      	
      		xml.writeStartElement(null,'Reserved', null);
      		xml.writeCharacters('Billing');
	      	xml.writeEndElement();		      	  		      	
	      	
			xml.writeEndElement();
      	}      	
      	xml.writeEndElement();
       
  		xmlString = xml.getXMLString();
  		xml.close();
		
		// 2. Make the request
		
		system.debug('ContactAddressService -> cleanContactAddressRecords -> url -> ' + RH_Web_Services__c.getInstance('melisaCleanseAddress').Service_URL__c);
		system.debug('ContactAddressService -> cleanContactAddressRecords -> xmlString -> ' + xmlString);
		
		HttpResponse response = CwCalloutService.doPostCallout(RH_Web_Services__c.getInstance('melisaCleanseAddress').Service_URL__c, xmlString);
		
		// 3. Extract cleansed address from response
		
		if (response == null || String.isBlank(response.getBody())) {
			system.debug('ContactAddressService -> cleanContactAddressRecords -> invalid response');
        	return null;
		}  

		List<Map<String, String>> responseMapList = new List<Map<String, String>>(); 
		try {
			Dom.Document doc = new Dom.Document();
			doc.load(response.getBody());         
			Dom.XMLNode responseRootNode = doc.getRootElement();       
						
			for (Dom.XMLNode pmHeader : responseRootNode.getChildElements()) {                 
				if (pmHeader.getName() == 'ResponseRecord') {
					Map<String, String> responseMap = new Map<String, String>();					       
					for (Dom.XMLNode cc : pmHeader.getChildElements() ) {
						responseMap.put(cc.getName(), cc.getText());
					}
					responseMapList.add(responseMap);
				}
			}
		} catch (Exception ex) {
			Utility.logException(ex, response.getBody());
		}
		
		// 4. Populate updated Contact Address records from response
		// This assumes that the response list is in the SAME ORDER as the request. Big assumption I know. 	
		
		if (contactAddresses.size() != responseMapList.size()) {
			system.debug('ContactAddressService -> cleanContactAddressRecords -> invalid response size -> ' + responseMapList.size());
			return null; 
		}
		
		List<Contact_Address__c> updatedRecords = new List<Contact_Address__c>();
		for (Integer addressIndex = 0; addressIndex < contactAddresses.size() && addressIndex < responseMapList.size(); addressIndex ++) {
			Map<String, String> responseMap = responseMapList.get(addressIndex);
			system.debug('ContactAddressService -> cleanContactAddressRecords -> update contact address -> ' + contactAddresses.get(addressIndex).Id + ' -> ' + responseMap);
			updatedRecords.add(new Contact_Address__c (
				ID = contactAddresses.get(addressIndex).Id,
				CONTACT__C = contactAddresses.get(addressIndex).CONTACT__C, // used within match key
				Cleansed_First_Name__c = (String) orElse(responseMap.get('FirstName'), contactAddresses.get(addressIndex).FIRST_NAME__C),
				Cleansed_Last_Name__c = (String) orElse(responseMap.get('LastName'), contactAddresses.get(addressIndex).LAST_NAME__C),
				Cleansed_Email__c = (String) orElse(responseMap.get('EmailAddress'), contactAddresses.get(addressIndex).FIRST_NAME__C),
				Cleansed_Company_Name__c = (String) orElse(responseMap.get('CompanyName'), contactAddresses.get(addressIndex).EMAIL__C),
				Cleansed_Address_1__c = (String) orElse(responseMap.get('AddressLine1'), contactAddresses.get(addressIndex).ADDRESS_1__C),
				Cleansed_Address_2__c = (String) orElse(responseMap.get('AddressLine2'), contactAddresses.get(addressIndex).ADDRESS_2__C),
				Cleansed_CITY__c = (String) orElse(responseMap.get('City'), contactAddresses.get(addressIndex).CITY__C),
				Cleansed_Zip__c = (String) orElse(responseMap.get('PostalCode'), contactAddresses.get(addressIndex).ZIP__C),
				Cleansed_State__c = (String) orElse(responseMap.get('State'), contactAddresses.get(addressIndex).STATE__C),
				Cleansed_Country__c = (String) orElse(responseMap.get('Country'), contactAddresses.get(addressIndex).COUNTRY__C),
				Cleansed_Day_Phone__c = (String) orElse(responseMap.get('PhoneNumber'), contactAddresses.get(addressIndex).DAY_PHONE__C),
				Cleansed_Result_Codes__c = (String) orElse(responseMap.get('ResultsCode'), null)
			));
		}
		
		// 5. Return the response
		
		system.debug('ContactAddressService -> cleanContactAddressRecords -> updated records -> ' + updatedRecords);
		return updatedRecords;
	}	    
    
    /*
     * Helper methods
     */
     
    public static String generateHashKey(String source) {
    	return EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(source)));
    } 
     	
	public static String cleanString(String source) {
    	return String.isBlank(source) ? '' : Utility.stripNonAlphanumericCharacters(Utility.stripAccents(source.toUpperCase().trim()));
    }  
    
    public static String cleanPhone(String phoneNumber) {
    	return String.isBlank(phoneNumber) ? phoneNumber : phoneNumber.replaceAll('^1', '');
    } 
    
    public static Object orElse(Object value, Object replacementValue) {
    	return value == null ? replacementValue : value;
    }   

    public static String orElseEmpty(String value) {
    	return (String) orElse(value, '');
    }    
    
    private static List<SObject> flatten(List<List<SObject>> listOfLists) {
    	List<SObject> finalList = new List<SObject>();
    	for (List<SObject> innerlist : listOfLists) {
    		for (SObject obj : innerlist) {
    			finalList.add(obj);
    		}
    	}
    	return finalList;
    }   
    
     /*
     * Helper queries
     */
         
    public static List<Contact_Address__c> getContactAddressByContact(Set<ID> contactIds) {
        return [
            SELECT  ID,         
                    APARTMENT__c,
                    Account_Match_Key_Hash__c,
                    Account_Match_Key__c,
                    Address_1__c,
                    Address_2__c,
                    Address_3__c,
                    Address_4__c,
                    Address_Match_Key_Hash__c,
                    Address_Match_Key__c,
                    Address_for_display__c,
                    CITY__c,
                    Cleansed_Address_1__c,
                    Cleansed_Address_2__c,
                    Cleansed_CITY__c,
                    Cleansed_Company_Name__c,
                    Cleansed_Country__c,
                    Cleansed_Day_Phone__c,
                    Cleansed_Email__c,
                    Cleansed_First_Name__c,
                    Cleansed_Last_Name__c,
                    Cleansed_Result_Codes__c,
                    Cleansed_State__c,
                    Cleansed_Zip__c,
                    Company_Name__c,
                    Contact_Match_Key_Hash__c,
                    Contact_Match_Key__c,
                    Contact__c,
                    Country_Code__c,
                    Country__c,
                    Day_Phone__c,
                    Email__c,
                    First_Name__c,
                    Full_Name__c,
                    Is_Bill_To_Address__c,
                    Is_Inactive__c,
                    Is_Ship_To_Address__c,
                    Last_Name__c,
                    Night_Phone__c,
                    State__c,
                    Zip__c,
                    is_Auto_Generated__c,
                    is_CCLU_Searchable__c,
                    is_Searchable__c,
                    is_Sold_To_Address__c       
            FROM    Contact_Address__c
            WHERE   Contact__c IN :contactIds
        ];
    }     

    /*
     * Trigger handlers (before insert/update)
     * update cleansed fields (replace existing ONLY when this is not new (oldMap != null))
	 * update the match keys (replace existing ONLY when this is not new (oldMap != null))     
	 * Still call the method for new though, as this may be manually created, and the cleaned/match keys may be blank.
	 * This will NOT overwrite the cleansed values generated by Melissa UNLESS the source address fields have changed.
     */
     
	public static void handleInsertOrUpdateContactAddress(List<Contact_Address__c> contactAddresses, Map<ID, Contact_Address__c> oldMap) {		
		for (Contact_Address__c contactAddress : contactAddresses) {
			if (oldMap == null || Utility.hasChanges(contactAddress, oldMap.get(contactAddress.Id), contactAddressFields)) {
				appendMissingMatchKeys(setDefaultCleansedFields(contactAddress, oldMap != null), oldMap != null);
			}
		}
	}   
	
	/*
	 * Trigger handlers (post insert/update)
	 * If we have cleansing enabled, and if the address details have changed
	 * And if this was not auto-generated (from Order or Ship-to)
	 * Then add the ID of the contact address to a set for future processing (melissa cleansing)
	 */
	
	public static void handleInsertedOrUpdatedContactAddress(List<SObject> recordsToUpdate, List<Contact_Address__c> contactAddresses, Map<ID, Contact_Address__c> oldMap) {
		
		if (!FeatureFlagService.isSinglePaneAddressCleansingFeatureActive()) {
			return;
		}
		
		Set<ID> needsCleansing = new Set<ID>();
		for (Contact_Address__c contactAddress : contactAddresses) {
			if (oldMap == null || Utility.hasChanges(contactAddress, oldMap.get(contactAddress.Id), contactAddressFields)) {
				if (!contactAddress.is_Auto_Generated__c) {
					needsCleansing.add(contactAddress.ID);
				}
			}
		}
		
		if (!needsCleansing.isEmpty()) {
			cleanseContactAddressRecords(needsCleansing);
		}
	}  
	
	/* 
	 * Copy the standard fields into the cleansed address fields
	 * (Useful because sometimes this happens via Melisa and sometimes it needs to be done manually)
	 */ 
	 /*
	public static List<Contact_Address__c> getContactAddressCleansedFields(Set<ID> contactAddressIds) {
		return [
			SELECT 	ID, CONTACT__C, CLEANSED_FIRST_NAME__C, CLEANSED_LAST_NAME__C, CLEANSED_COMPANY_NAME__C, 
					CLEANSED_ADDRESS_1__C, CLEANSED_ADDRESS_2__C, CLEANSED_CITY__C, CLEANSED_COUNTRY__C, CLEANSED_STATE__C, CLEANSED_ZIP__C, CLEANSED_DAY_PHONE__C, EMAIL__C
			FROM 	Contact_Address__c
			WHERE	ID in :contactAddressIds					
		];
	}	*/ 
	 
	public static List<Contact_Address__c> setDefaultCleansedFields(List<Contact_Address__c> contactAddresses, Boolean replaceExisting) {
		for (Contact_Address__c contactAddress : contactAddresses) {
			setDefaultCleansedFields(contactAddress, replaceExisting);
		}	
		return contactAddresses;
	} 
	
	public static Contact_Address__c setDefaultCleansedFields(Contact_Address__c contactAddress, Boolean replaceExisting) {
		if (replaceExisting || String.isBlank(contactAddress.CLEANSED_FIRST_NAME__C)) {
			contactAddress.CLEANSED_FIRST_NAME__C = contactAddress.FIRST_NAME__C;
		}
		if (replaceExisting || String.isBlank(contactAddress.CLEANSED_LAST_NAME__C)) {
			contactAddress.CLEANSED_LAST_NAME__C = contactAddress.LAST_NAME__C;
		}
		if (replaceExisting || String.isBlank(contactAddress.CLEANSED_COMPANY_NAME__C)) {
			contactAddress.CLEANSED_COMPANY_NAME__C = contactAddress.COMPANY_NAME__C;
		}
		if (replaceExisting || String.isBlank(contactAddress.CLEANSED_ADDRESS_1__C)) {
			contactAddress.CLEANSED_ADDRESS_1__C = contactAddress.ADDRESS_1__C;
		}
		if (replaceExisting || String.isBlank(contactAddress.CLEANSED_ADDRESS_2__C)) {
			contactAddress.CLEANSED_ADDRESS_2__C = contactAddress.ADDRESS_2__C;
		}
		if (replaceExisting || String.isBlank(contactAddress.CLEANSED_CITY__C)) {		
			contactAddress.CLEANSED_CITY__C = contactAddress.CITY__C;
		}
		if (replaceExisting || String.isBlank(contactAddress.CLEANSED_COUNTRY__C)) {		
			contactAddress.CLEANSED_COUNTRY__C = contactAddress.COUNTRY__C;
		}
		if (replaceExisting || String.isBlank(contactAddress.CLEANSED_STATE__C)) {		
			contactAddress.CLEANSED_STATE__C = contactAddress.STATE__C;
		}
		if (replaceExisting || String.isBlank(contactAddress.CLEANSED_ZIP__C)) {		
			contactAddress.CLEANSED_ZIP__C = contactAddress.ZIP__C;
		}
		if (replaceExisting || String.isBlank(contactAddress.CLEANSED_DAY_PHONE__C)) {		
			contactAddress.CLEANSED_DAY_PHONE__C = contactAddress.DAY_PHONE__C;
		}
		if (replaceExisting || String.isBlank(contactAddress.CLEANSED_EMAIL__C)) {		
			contactAddress.CLEANSED_EMAIL__C = contactAddress.EMAIL__C; 
		}
		if (replaceExisting || String.isBlank(contactAddress.Cleansed_Result_Codes__c)) {
			contactAddress.Cleansed_Result_Codes__c = NULL;		
		}
		return contactAddress;
	} 

	/*
	 * Append missing match keys (including hash keys) to a Contact Address instance
	 */
	 
	public static List<Contact_Address__c> appendMissingMatchKeys(List<Contact_Address__c> contactAddresses, Boolean forceUpdate) {
		if (Utility.isNotEmpty(contactAddresses)) {
			for (Contact_Address__c contactAddress : contactAddresses) {
				appendMissingMatchKeys(contactAddress, forceUpdate);
			}
		}
		return contactAddresses;
	}
	
	public static Contact_Address__c appendMissingMatchKeys(Contact_Address__c contactAddress) {
		return appendMissingMatchKeys(contactAddress, false);
	} 
	
	public static Contact_Address__c appendMissingMatchKeys(Contact_Address__c contactAddress, Boolean forceUpdate) {
		if (forceUpdate || String.isBlank(contactAddress.ADDRESS_MATCH_KEY__C)) {
			contactAddress.ADDRESS_MATCH_KEY__C = generateAddressMatchKey(contactAddress);
			contactAddress.ADDRESS_MATCH_KEY_HASH__C = generateHashKey(contactAddress.ADDRESS_MATCH_KEY__C);
		}
		if (forceUpdate || String.isBlank(contactAddress.CONTACT_MATCH_KEY__c)) {
			contactAddress.CONTACT_MATCH_KEY__c = generateContactMatchKey(contactAddress);
			contactAddress.CONTACT_MATCH_KEY_HASH__c = generateHashKey(contactAddress.CONTACT_MATCH_KEY__c);
		}
		if (forceUpdate || String.isBlank(contactAddress.ACCOUNT_MATCH_KEY__c)) {
			contactAddress.ACCOUNT_MATCH_KEY__c = generateAccountMatchKey(contactAddress);
			contactAddress.ACCOUNT_MATCH_KEY_HASH__c = generateHashKey(contactAddress.ACCOUNT_MATCH_KEY__c);				
		}
		return contactAddress;		
	} 	 	 	
	 	  
    
    /*
     * Spawn a contact address record from the address details on a Contact record
     * This will be called on the insert of a new contact, or the updating of the address details on an existing one
     */
     
    public static Contact_Address__c generateContactAddress(Contact contact) {
    	String[] addressLines = contact.MailingStreet == null ? new List<String>{'',''} : contact.MailingStreet.split('\r\n');
		Contact_Address__c contactAddress = new Contact_Address__c (
			CONTACT__C = contact.ID,    
			FIRST_NAME__C = contact.FirstName,  
			LAST_NAME__C  = contact.LastName,
			COMPANY_NAME__C = contact.Account.isPersonAccount ? '' : contact.Account.Name,
			ADDRESS_1__C = addressLines[0],
			ADDRESS_2__C = addressLines.size() > 1 ? addressLines[1] : '',
			ADDRESS_3__C = '',				
			ADDRESS_4__C = '',
			APARTMENT__C = '',
			CITY__C = contact.MailingCity,
			COUNTRY_CODE__C = '',
			COUNTRY__C = contact.MailingCountry,
			STATE__C = contact.MailingState,
			ZIP__C = contact.MailingPostalCode,
			DAY_PHONE__C = cleanString(contact.Phone),
			NIGHT_PHONE__C = '',
			EMAIL__C = contact.Email, 
			is_Auto_Generated__c = TRUE
		);    	
		return appendMissingMatchKeys(setDefaultCleansedFields(contactAddress, true));
    }
    
    /* 
     * Build a contact address records from the sold-to order details
     */
        
	public static Contact_Address__c generateSoldToContactAddress(Rh_Order__c rhOrder) {
		Contact_Address__c contactAddress = new Contact_Address__c (
			CONTACT__C = rhOrder.CONTACT_SOLD_TO__c,    
			FIRST_NAME__C = rhOrder.SOLD_TO_FIRST_NAME__c,
			LAST_NAME__C  = rhOrder.SOLD_TO_LAST_NAME__c,
			COMPANY_NAME__C = rhOrder.Sold_to_Company__c,
			ADDRESS_1__C = rhOrder.SOLD_TO_ADDRESS_1__c,
			ADDRESS_2__C = rhOrder.SOLD_TO_ADDRESS_2__c,
			ADDRESS_3__C = '',				
			ADDRESS_4__C = '',
			APARTMENT__C = '',
			CITY__C = rhOrder.SOLD_TO_CITY__c,
			COUNTRY_CODE__C = rhOrder.SOLD_TO_COUNTRY_CODE__c,
			COUNTRY__C = rhOrder.SOLD_TO_COUNTRY__c,
			STATE__C = rhOrder.SOLD_TO_STATE__c,
			ZIP__C = rhOrder.SOLD_TO_ZIP__c,
			DAY_PHONE__C = cleanString(rhOrder.SOLD_TO_DAY_PHONE__c),
			NIGHT_PHONE__C = cleanString(rhOrder.SOLD_TO_NIGHT_PHONE__c),
			EMAIL__C = rhORder.SOLD_TO_EMAIL__c, 
			is_Sold_To_Address__c = TRUE,
			is_Auto_Generated__c = TRUE
		);
		return appendMissingMatchKeys(setDefaultCleansedFields(contactAddress, true));
	}
	
    /* 
     * Build a contact address records from the bill-to order details
     */	
		
	public static Contact_Address__c generateBillToContactAddress(Rh_Order__c rhOrder) {
		Contact_Address__c contactAddress = new Contact_Address__c (
			CONTACT__C = rhOrder.CONTACT_SOLD_TO__c,    
			FIRST_NAME__C = rhOrder.BILL_TO_FIRST_NAME__c,
			LAST_NAME__C  = rhOrder.BILL_TO_LAST_NAME__c,
			COMPANY_NAME__c = rhOrder.Bill_To_Company__c,
			ADDRESS_1__C = rhOrder.BILL_TO_ADDRESS_1__c,
			ADDRESS_2__C = rhOrder.BILL_TO_ADDRESS_2__c,
			ADDRESS_3__C = '',				
			ADDRESS_4__C = '',
			APARTMENT__C = '',
			CITY__C = rhOrder.BILL_TO_CITY__c,
			// COUNTRY_CODE__C = rhOrder.BILL_TO_COUNTRY_CODE__c,
			COUNTRY__C = rhOrder.BILL_TO_COUNTRY__c,
			STATE__C = rhOrder.BILL_TO_STATE__c,
			ZIP__C = rhOrder.BILL_TO_ZIP__c,
			DAY_PHONE__C = cleanString(rhOrder.BILL_TO_DAY_PHONE__c),
			NIGHT_PHONE__C = cleanString(rhOrder.BILL_TO_NIGHT_PHONE__c),
			EMAIL__C = rhORder.BILL_TO_EMAIL__c,
			Is_Bill_To_Address__c = TRUE,
			is_Auto_Generated__c = TRUE
		);		
		return appendMissingMatchKeys(setDefaultCleansedFields(contactAddress, true));	
	}
	
	/* 
     * Build a contact address records from the bill-to order details. 
     * There is no need for a shadow record on the Ship-to as the contact for this is always the same as the sold-to contact on the order
     */
	
	public static Contact_Address__c generateShipToContactAddress(Ship_To__c shipTo) {
		Contact_Address__c contactAddress = new Contact_Address__c (
			CONTACT__C = shipTo.Order__r.Contact_Sold_To__c,    
			FIRST_NAME__C = shipTo.Ship_to_First_Name__c,
			LAST_NAME__C  = shipTo.Ship_to_Last_Name__c,
			COMPANY_NAME__c = shipTo.Ship_to_Company__c,
			ADDRESS_1__C = shipTo.Ship_to_Address_1__c,
			ADDRESS_2__C = shipTo.Ship_to_Address_2__c,
			ADDRESS_3__C = '',				
			ADDRESS_4__C = '',
			APARTMENT__C = '',
			CITY__C = shipTo.Ship_to_City__c,
			COUNTRY__C = shipTo.Ship_to_Country__c,
			STATE__C = shipTo.SHIP_TO_STATE__c,
			ZIP__C = shipTo.Ship_to_Zip__c,
			DAY_PHONE__C = cleanString(shipTo.Ship_to_Day_Phone__c),
			NIGHT_PHONE__C = cleanString(shipTo.Ship_to_Night_Phone__c),
			EMAIL__C = shipTo.Ship_to_Email__c,
			Is_Ship_To_Address__c = TRUE,			
			is_Auto_Generated__c = TRUE		
		);		
		return appendMissingMatchKeys(setDefaultCleansedFields(contactAddress, true));
	}
	
	/* 
	 * Generate the match keys from the values within Contact Address record
	 */ 
	
    public static String generateAddressMatchKey(Contact_Address__c contactAddress) {
    	return contactAddress.CONTACT__C + cleanString(
    		orElseEmpty(contactAddress.CLEANSED_ADDRESS_1__C) +
			orElseEmpty(contactAddress.CLEANSED_CITY__C) +
			orElseEmpty(contactAddress.CLEANSED_STATE__C) +
			orElseEmpty(contactAddress.CLEANSED_ZIP__C) +	
			orElseEmpty(contactAddress.CLEANSED_COUNTRY__C) +	
			orElseEmpty(cleanPhone(contactAddress.CLEANSED_DAY_PHONE__C)) +
//			contactAddress.EMAIL__C + (not included because it is not available for all addresses)
			orElseEmpty(contactAddress.CLEANSED_FIRST_NAME__C) +
			orElseEmpty(contactAddress.CLEANSED_LAST_NAME__C) +
			orElseEmpty(contactAddress.CLEANSED_COMPANY_NAME__c)
		);       		
    }	
    
    public static String generateContactMatchKey(Contact_Address__c contactAddress) {
    	return cleanString(
    		orElseEmpty(contactAddress.CLEANSED_ADDRESS_1__C) +
			orElseEmpty(contactAddress.CLEANSED_CITY__C) +
			orElseEmpty(contactAddress.CLEANSED_STATE__C) +
			orElseEmpty(contactAddress.CLEANSED_ZIP__C) +	
			orElseEmpty(contactAddress.CLEANSED_COUNTRY__C) +	
			orElseEmpty(cleanPhone(contactAddress.CLEANSED_DAY_PHONE__C)) +
//			contactAddress.EMAIL__C + (not included because it is not available for all addresses)
			orElseEmpty(contactAddress.CLEANSED_FIRST_NAME__C) +
			orElseEmpty(contactAddress.CLEANSED_LAST_NAME__C) +
			orElseEmpty(contactAddress.CLEANSED_COMPANY_NAME__c)
		);       		
    }
    
    public static String generateAccountMatchKey(Contact_Address__c contactAddress) {
    	return cleanString(
    		orElseEmpty(contactAddress.CLEANSED_COMPANY_NAME__c) + 
    		orElseEmpty(contactAddress.CLEANSED_ZIP__C)
		); 
    }	

   
    
}