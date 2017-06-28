public with sharing class CW_Accommodation {
	
	/*
	 *	Methods to populate Case fields with the information needed to create an Accommodation Order Line in CW
	 *	Accommodations supported:
	 *		- Gift Card due to Delay Notification case
	 *
	 */
	
	public static void createCWAccommodation(Case accCase, RH_Order__c accOrder, Ship_To__c accShipTo) {
		
		String firstName;
		String lastName;
		String company;
		String address1;
		String address2;
		String city;
		String state;
		String zip;
		String countryCode;
		String emailAddress;
		String addressType;
		
		// Populate accommodation fields on the Case that are used in the Outbound message to Mule/CW
		accCase.Acc_Expiration__c = 'N';
		accCase.Acc_Requesting_User__c = UserInfo.getUserId();
		accCase.Acc_Type__c = 'Gift Card';
		
		// Determine which address to use
		addressType = '';
		if (accOrder != null && (String.isBlank(accCase.Send_To__c) || accCase.Send_To__c == 'Sold To')) {
			addressType = 'SOLD_TO';
			firstName = accOrder.Sold_to_First_Name__c;
			lastName = accOrder.Sold_to_Last_Name__c;
			company = accOrder.Sold_to_Company__c;
			address1 = accOrder.Sold_to_Address_1__c;
			address2 = accOrder.Sold_to_Address_2__c;
			city = accOrder.Sold_to_City__c;
			state = accOrder.Sold_to_State__c;
			zip = accOrder.Sold_to_Zip__c;
			countryCode = accOrder.Sold_to_Country_Code__c;
			emailAddress = accOrder.Sold_to_Email__c;
		}
		
		if (accShipTo != null && accCase.Send_To__c == 'Ship To 1') {
			addressType = 'SHIP_TO';
			firstName = accShipTo.Ship_to_First_Name__c;
			lastName = accShipTo.Ship_to_Last_Name__c;
			company = accShipTo.Ship_to_Company__c;
			address1 = accShipTo.Ship_to_Address_1__c;
			address2 = accShipTo.Ship_to_Address_2__c;
			city = accShipTo.Ship_to_City__c;
			state = accShipTo.Ship_to_State__c;
			zip = accShipTo.Ship_to_Zip__c;
			countryCode = accShipTo.Ship_to_Country_Code__c;
			emailAddress = accShipTo.Ship_to_Email__c;
		}
		
		if (accCase.Send_To__c == 'Alternate Address (Contact)') {
			addressType = 'SPECIAL';
			firstName = accCase.Send_to_First_Name__c;
			lastName = accCase.Send_to_Last_Name__c;
			company = accCase.Send_to_Company__c;
			address1 = accCase.Send_to_Address_1__c;
			address2 = accCase.Send_to_Address_2__c;
			city = accCase.Send_to_City__c;
			state = accCase.Send_to_State__c;
			zip = accCase.Send_to_Zip__c;
			countryCode = accCase.Send_to_Country_Code__c;
			emailAddress = accCase.Send_to_Email__c;
		}
		
		// Determine if we should provide address information
		if ( String.isBlank(addressType) || String.isBlank(firstName) || String.isBlank(lastName) || String.isBlank(address1) || 
			 String.isBlank(city) || String.isBlank(state) || String.isBlank(zip) || String.isBlank(countryCode) ) {
			addressType = 'SOLD_TO';
			firstName = '';
			lastName = '';
			company = '';
			address1 = '';
			address2 = '';
			city = '';
			state = '';
			zip = '';
			countryCode = '';
			emailAddress = '';
		}
		
		// Store data in the case fields in CW format and length
		accCase.Acc_Address_Type__c = addressType;
		if (String.isNotBlank(firstName)) {
			if (firstName.length() > 15) {
				firstName = firstName.subString(0, 15);
			}
			firstName = firstName.toUpperCase();
		}
		accCase.Acc_First_Name__c = firstName;
		
		if (String.isNotBlank(lastName)) {
			if (lastName.length() > 25) {
				lastName = lastName.subString(0, 25);
			}
			lastName = lastName.toUpperCase();
		}
		accCase.Acc_Last_Name__c = lastName;
		
		if (String.isNotBlank(company)) {
			if (company.length() > 30) {
				company = company.subString(0,30);
			}
			company = company.toUpperCase();
		}
		accCase.Acc_Company__c = company;
		
		if (String.isNotBlank(address1)) {
			if (address1.length() > 32) {
				address1 = address1.subString(0, 32);
			}
			address1 = address1.toUpperCase();
		}
		accCase.Acc_Address_1__c = address1;
					
		if (String.isNotBlank(address2)) {
			if (address2.length() > 32) {
				address2 = address2.subString(0, 32);
			}
			address2 = address2.toUpperCase();
		}
		accCase.Acc_Address_2__c = address2;
		
		if (String.isNotBlank(city)) {
			if (city.length() > 25) {
				city = city.subString(0, 25);
			}
			city = city.toUpperCase();
		}
		accCase.Acc_City__c = city;
		
		if (String.isNotBlank(state)) {
			if (state.length() > 2) {
				state = state.subString(0, 2);
			}
			state = state.toUpperCase();
		}
		accCase.Acc_State__c = state;
		
		if (String.isNotBlank(zip)) {
			if (zip.length() > 10) {
				zip = zip.subString(0, 10);
			}
			zip = zip.toUpperCase();
		}
		accCase.Acc_Postal_Code__c = zip;
		
		if (String.isNotBlank(countryCode)) {
			if (countryCode.length() != 3) {
				if (countryCode.startsWith('C')) {
					countryCode = 'CAN';
				} else {
					countryCode = 'USA';
				}
			}
			countryCode = countryCode.toUpperCase();
		}
		accCase.Acc_Country_Code__c = countryCode;
		
		if (String.isNotBlank(emailAddress)) {
			if (emailAddress.length() > 50) {
				emailAddress = emailAddress.subString(0, 50);
			}
		}
		accCase.Acc_Email__c = emailaddress;
	}
}