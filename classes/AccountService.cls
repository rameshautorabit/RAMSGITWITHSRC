public without sharing class AccountService {
	
	private @testvisible static Set<String> accountAddressFields = new Set<String> {
		'FirstName', 'LastName', 'PersonMailingStreet', 'PersonMailingCity', 'PersonMailingState', 'PersonEmail', 'Phone'
	};
		
	/*
	 * Handle changes to the Account
	 * Parameters: list of inserted/updated accounts
	 * Returns: nothing. Inserts all new contact address records within the method.
	 */
       	 
	public static void handleInsertedUpdatedAccount(List<Account> accounts, Map<ID, Account> oldMap) {
		
		system.debug('AccountService -> handleInsertedUpdatedAccount');
		
		// Handle accounts where the address records have changed
		
		if (!FeatureFlagService.isSinglePaneAddressFeatureActive()) {
			system.debug('AccountService -> handleInsertedUpdatedAccount -> single pane feature disabled');
			return;
		}
		
		Map<Id, Account> accountsChanged = new Map<Id, Account>();
		for (Account account : accounts) {
			if (account.isPersonAccount && (oldMap == null || Utility.hasChanges(account, oldMap.get(account.ID), accountAddressFields))) {
				system.debug('AccountService -> handleInsertedUpdatedAccount -> account changed -> ' + account);
				accountsChanged.put(account.Id, account);
			} 			
		}
		
	 	if (Utility.isNotEmpty(accountsChanged.values())) {
	 		system.debug('AccountService -> handleInsertedUpdatedAccount -> build address for account');
			Utility.logInsert(ContactAddressService.buildAddressForPersonAccounts(accountsChanged));
	 	}
	}


	/*
	 * Handle the deletion of an Account. 
	 * Only care if deletion was because of a merge
	 */
	
	public static void handleAfterDeleteAccount(List<Account> accounts) {
		
		system.debug('ContactService -> handleAfterDeleteAccount -> ' + accounts);
		
		Set<ID> winningAccounts = new Set<ID>();
		for (Account deletedAccount : accounts) {
			//if (deletedAccount.isPersonAccount == true && deletedAccount.masterRecordId != null) {
			if (deletedAccount.masterRecordId != null) {

				winningAccounts.add(deletedAccount.masterRecordId);
			}
		}
		
		system.debug('AccountService -> handleAfterDeleteAccount -> update account lifetime values -> ' + winningAccounts);
		//Utilty.logUpdate(OrderService.processRollupForAccounts(winningAccounts));
		OrderService.processRollupForAccounts(winningAccounts);
	}


	// Verify that Vendor Number is unique
	// - before insert, before update
	
	public static void vendorNumberUnique(List<Account> newList, Map<Id, Account> oldMap, Boolean isInsert) {
		Map<Id, Account> vendorNumberMap = new Map<Id, Account>();
		Set<String> vendorNumbers = new Set<String>();
		
		for (Account a :newList) {
			if (String.isNotBlank(a.Vendor_Number__c)) {
				if (isInsert || a.Vendor_Number__c != oldMap.get(a.Id).Vendor_Number__c) {
					if (vendorNumbers.contains(a.Vendor_Number__c)) {
						a.Vendor_Number__c.addError('Multiple Account records with same Vendor Number: ' + a.Vendor_Number__c + '.');
					} else {
						vendorNumberMap.put(a.Id, a);
						vendorNumbers.add(a.Vendor_Number__c);
					}
				}
			}
		}
		
		if (!vendorNumbers.isEmpty()) {
			List<Account> accList = new List<Account>();
			accList = [select Id, Vendor_Number__c from Account where Vendor_Number__c in :vendorNumbers];
			for (Account a :accList) {
				if (vendorNumberMap.containsKey(a.Id)) {
					vendorNumberMap.get(a.Id).Vendor_Number__c.addError('Vendor Number ' + a.Vendor_Number__c + ' is already in use.');
				}
			}
		}
	}
	
	public static void createVendorPublicGroup(List<Account> accounts){        
        
        List<Group> vendorGroups = new List<Group>();
        Set<Id> vendorGroupIds = new Set<Id>();
        Map<String, Account> vendorGroupNameAccountMap = new Map<String, Account>();
        List<Account> upVendorAccounts = new List<Account>();
        String accName;
   		
   		// Create map of names of vendor groups to be created and associated accounts
        for(Account acc:accounts){
            if(acc.isPartner){
                if (String.isBlank(acc.PublicGroupId__c)) {
                	accName = acc.Name.length() > 16 ? acc.Name.substring(0,16) : acc.Name; // make sure group name is no more than 40 characters and unique
                	vendorGroupNameAccountMap.put('VEND-' + accName + '-' + acc.id, acc);
                }
            }
        }
       	
       	// Create list of vendor groups to be created and insert
		if(!vendorGroupNameAccountMap.isEmpty()){
        	for(String vgn: vendorGroupNameAccountMap.keySet()){
				Group vendorGroup = new Group(Name = vgn);
				vendorGroups.add(vendorGroup);
        	}
        	
        	insert vendorGroups; // add Paul's utility error handling
     		
     		// Gather Ids of newly created vendor public groups 
     		for(Group vg: vendorGroups){
     			vendorGroupIds.add(vg.Id);
     		}
     		// Add newly created vendor public groups to the Vendor Partner Users group
     		addToVendorPartnerUserGroup(vendorGroupIds);
		}
		
		// Update the relevant Accounts with their associated Vendor Public Group Id 
		if(!vendorGroups.isEmpty()){	
			for(Group vg: vendorGroups){
				Account upAcc = [Select Id from Account where Id = :vendorGroupNameAccountMap.get(vg.Name).Id];
				upAcc.PublicGroupId__c = vg.Id;
				upVendorAccounts.add(upAcc); 
			}
		update upVendorAccounts;
		}
	}

	@future
  	public static void addToVendorPartnerUserGroup(Set<Id> vendorGroupIds) {
    	List<GroupMember> vendorPartnerUserGroups = new List<GroupMember>();
    	Group parentGroup = [Select Id From Group Where Name = 'Vendor Partner Users'];
			
		for(Id vgi: vendorGroupIds){
			GroupMember gm = new GroupMember(GroupId = parentGroup.Id, UserOrGroupId = vgi);
			vendorPartnerUserGroups.add(gm);
		}	
    	insert vendorPartnerUserGroups; // add Paul's utility error handling
	}
}