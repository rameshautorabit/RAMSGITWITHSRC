/**
 *  TestDataFactory.cls
 *  @description Utility class for APEX unit tests to create necessary data
 *  @author Ernesto Valdes, Traction On Demand
 */
@isTest
public with sharing class TestDataFactory {
	
	public static void turnMdmFeatureFlagsOn() {
		Feature_Flags__c customSetting = new Feature_Flags__c(
			MDM_Address_Feature__c = true,
			MDM_Merge_feature__c = true
		);
		database.insert(customSetting);					
	}

	public static User createUser() {
		return (User) TestDataFactoryHelper.createSObject(User.getSObjectType());
	}

	public static Contact_Information__c createContactInformation(Boolean doInsert) {
		return createContactInformations(1, doInsert)[0];
	}

	public static List<Contact_Information__c> createContactInformations(Integer howMany, Boolean doInsert) {
		List<Contact_Information__c> contactInformations = (List<Contact_Information__c>) 
				TestDataFactoryHelper.createSObjects(Contact_Information__c.getSObjectType(), howMany);

		if (doInsert) {
			insert contactInformations;
		}

		return contactInformations;
	}

	public static Ship_To__c createShipTo(Boolean doInsert) {
		return createShipTos(1, doInsert)[0];
	}

	public static List<Ship_To__c> createShipTos(Integer howMany, Boolean doInsert) {
		List<Ship_To__c> shipTos = (List<Ship_To__c>) 
			TestDataFactoryHelper.createSObjects(Ship_To__c.getSObjectType(), howMany);

		if (doInsert) {
			insert shipTos;
		}

		return shipTos;
	}

	public static Address__c createAddress(Boolean doInsert) {
		return createAddresses(1, doInsert)[0];
	}

	public static List<Address__c> createAddresses(Integer howMany, Boolean doInsert) {
		List<Address__c> addrs = (List<Address__c>) 
			TestDataFactoryHelper.createSObjects(Address__c.getSObjectType(), howMany);

		if (doInsert) {
			insert addrs;
		}

		return addrs;
	}

	public static Customer_Address__c createCustomerAddress(Boolean doInsert) {
		return createCustomerAddresses(1, doInsert)[0];
	}

	public static Customer_Address__c createCustomerAddress(Boolean doInsert, Boolean createParents) {
		return createCustomerAddresses(1, doInsert, createParents)[0];
	}

	public static List<Customer_Address__c> createCustomerAddresses(Integer howMany, Boolean doInsert) {
		return createCustomerAddresses(howMany, doInsert, true);
	}

	public static List<Customer_Address__c> createCustomerAddresses(Integer howMany, Boolean doInsert, Boolean createParents) {
		// Account c = createAccount(true); // removed in favor of contact lookup, data model change Feb 18th
		Contact c;
		Address__c a;
		if (createParents) {
			c = createContact(true);
			a = createAddress(true);
		}
		List<Customer_Address__c> customerAddresses = (List<Customer_Address__c>) 
				TestDataFactoryHelper.createSObjects(Customer_Address__c.getSObjectType(), howMany);

		for (Customer_Address__c ca : customerAddresses) {
			if (createParents) {
				ca.Address__c = a.Id;
				ca.Contact__c = c.Id;
			}
		}

		if (doInsert) {
			insert customerAddresses;
		}

		return customerAddresses;
	}

	public static Account createPersonAccount(Boolean doInsert) {
		return createPersonAccounts(1, doInsert)[0];
	}

	public static List<Account> createPersonAccounts(Integer howMany, Boolean doInsert) {
		RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'RH End Customer' and SObjectType = 'Account'];
		List<Account> accs = new List<Account>();
		for (Integer i = 0; i < howMany; i++) {
			accs.add(
				new Account(
					LastName = 'test ' + i,
					RecordType = personAccountRecordType
				)
			);
		}

		if (doInsert) {
			insert accs;
		}
		return accs;
	}

	public static Account createAccount(Boolean doInsert) {
		return createAccount(1, doInsert)[0];
	}

	public static List<Account> createAccount(Integer howMany, Boolean doInsert) {
		List<Account> createdRecords = new List<Account>();
		for (Integer i = 0; i < howMany; i++) {
			createdRecords.add(
				new Account(
					Name = 'Test Account ' + i
				));
		}

		if (doInsert) insert createdRecords;

		return createdRecords;
	}

	public static Contact createContact(Boolean doInsert) {
		return createContacts(1, doInsert)[0];
	}

	public static List<Contact> createContacts(Integer howMany, Boolean doInsert) {
		List<Contact> contacts = TestDataFactoryHelper.createSObjects(Contact.getSObjectType(), howMany);

		if (doInsert) {
			insert contacts;
		} 

		return contacts;
	}

	public static Order_Role__c createOrderRole(Boolean doInsert) {
		return createOrderRoles(1, doInsert)[0];
	}

	public static List<Order_Role__c> createOrderRoles(Integer howMany, Boolean doInsert) {
		Account a = createAccount(true);
		List<RH_Order__c> orders = createRhOrders(howMany, true);

		List<Order_Role__c> orderRoles = TestDataFactoryHelper.createSObjects(Order_Role__c.getSObjectType(), howMany);
		Integer i = 0;
		for (Order_Role__c orderRole : orderRoles) {
			orderRole.Account__c = a.Id;
			orderRole.Order__c = orders[i++].Id;
		}

		if (doInsert) {
			insert orderRoles;
		} 

		return orderRoles;
	}

	public static RH_Order__c createRhOrder(Boolean doInsert) {
		return createRhOrders(1, doInsert)[0];
	}

	public static List<RH_Order__c> createRhOrders(Integer howMany, Boolean doInsert) {
		List<RH_Order__c> rhOrders = TestDataFactoryHelper.createSObjects(RH_Order__c.getSObjectType(), howMany);

		if (doInsert) {
			insert rhOrders;
		} 

		return rhOrders;
	}

	public static Case createCase(Boolean doInsert) {
		return createCases(1, doInsert)[0];
	}

	public static List<Case> createCases(Integer howMany, Boolean doInsert) {
		List<Case> cases = TestDataFactoryHelper.createSObjects(Case.getSObjectType(), howMany);

		if (doInsert) {
			insert cases;
		} 

		return cases;
	}

	public static Source_System_View__c createSSV(Boolean doInsert) {
		return createSSV(1, doInsert)[0];
	}

	static Integer uniqueSSVId = 1;
	public static List<Source_System_View__c> createSSV(Integer howMany, Boolean doInsert) {

		List<Source_System_View__c> createdRecords = new List<Source_System_View__c>();
		for (Integer i = 1; i <= howMany; i++) {
			createdRecords.add(
				new Source_System_View__c(
					EXT_Source_System_Customer_ID__c = String.valueOf(uniqueSSVId),
					Day_Phone__c = '+1.(555)-555-' + padLeft(i, 4),
					Email__c = 'test' + i + '+email@domain.test.com',
					Company_Name__c = 'Test Company' + i,
					First_Name__c = 'TestFirst' + i,
					Last_Name__c = 'TestLast' + i,
					Address_1__c = padLeft(i, 4) + ' Test St ',
					Address_2__c = ' Apt 456A',
					City__c = 'San Francisco',
					State__c = ' CA ',
					Zip__c = '12345 ',
					Country__c = 'US',
					Country_Code__c = 'US'
				));
			uniqueSSVId++;
		}

		if (doInsert) insert createdRecords;

		return createdRecords;
	}

	/**
	 *  @description Converts a given integer to string, and pads the string
	 *               up to the given number of characters with leading zeroes
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2016-01-26
	 *  @param       i             The given integer to convert and pad
	 *  @param       pad           The size of the returned string, leading zeroes are added if needed
	 *  @return                    The padded string
	 */
	public static String padLeft(Integer i, Integer pad) {

		// Convert int to string, empty string if int is null
		String iString = (i != null) ? String.valueOf(i) : '';

		while ((pad - iString.length()) > 0) {

			// Add zero to left of string
			iString = '0' + iString;
		}

		return iString;
	}
}