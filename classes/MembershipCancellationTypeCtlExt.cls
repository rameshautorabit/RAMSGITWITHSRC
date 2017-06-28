public with sharing class MembershipCancellationTypeCtlExt {
	
	/*
	 *	Membership object controller extension to control what picklist values of field Cancellation_Type__c can be
	 *	set via the UI depending on who the running user is and what the current value is.
	 */
	
	ApexPages.StandardController stdController;
	
	public Membership__c rhMembership {get; set;}
	public Boolean isReadOnly {get; set;}
	public Boolean isEditMode {get; set;}
	public Boolean isNonAdminUser {get; set;}
	
	private Map<String, Set<String>> nonAdminReasonMap;
	private Map<String, Set<String>> adminReasonMap;
	Map<String, MembershipCancellationTypes__c> memCancelMap;
	
	public MembershipCancellationTypeCtlExt(ApexPages.StandardController stdController) {
		
		isEditMode = false;
		
		this.rhMembership = (Membership__c)stdController.getRecord();
		this.rhMembership = [select Id, Name, Cancellation_Type__c, Cancellation_Reason__c, Cancellation_Date__c, Membership_Restore_Date__c from Membership__c where Id = :this.rhMembership.Id];
		
		List<User> uList = new List<User>();
		uList = [select Id, Name, UserRoleId, UserRole.Name from User where Id = :UserInfo.getUserId()];
		isNonAdminUser = (uList[0].UserRole.Name == 'Administration') ? false : true;
		
		// Create the set of allowable Cancellation Reason values for non-admin and admin users
		memCancelMap = MembershipCancellationTypes__c.getAll();
		List<String> reasons = new List<String>();
		nonAdminReasonMap = new Map<String, Set<String>>();
		adminReasonMap = new Map<String, Set<String>>();
		for (String cancelType :memCancelMap.keySet()) {
			nonAdminReasonMap.put(cancelType, new Set<String>());
			if (String.isNotBlank(memCancelMap.get(cancelType).Reasons_non_Admin__c)) {
				reasons = memCancelMap.get(cancelType).Reasons_non_Admin__c.split(';');
				nonAdminReasonMap.get(cancelType).addAll(reasons);
			}
			
			adminReasonMap.put(cancelType, new Set<String>());
			if (String.isNotBlank(memCancelMap.get(cancelType).Cancellation_Reasons__c)) {
				reasons = memCancelMap.get(cancelType).Cancellation_Reasons__c.split(';');
				adminReasonMap.get(cancelType).addAll(reasons);
			}
		}
		
		// Determine if fields are read only based upon user type and value of Cancellation Type
		isReadOnly = false;
		if (String.isNotBlank(rhMembership.Cancellation_Type__c)) {
			if (memCancelMap.containsKey(rhMembership.Cancellation_Type__c)) {
				if (isNonAdminUser && !memCancelMap.get(rhMembership.Cancellation_Type__c).nonAdmin__c) {
					isReadOnly = true;
				}
			}
		}
	}
	
	public List<SelectOption> getcancellationTypes() {
		List<SelectOption> options = new List<SelectOption>();
		
		Schema.DescribeFieldResult fieldResult = Membership__c.Cancellation_Type__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		
		options.add(new SelectOption('', '--None--'));
		for (Schema.PicklistEntry f : ple) {
			if (memCancelMap.containsKey(f.getLabel())) {
				if (!isNonAdminUser || memCancelMap.get(f.getLabel()).nonAdmin__c) {
					options.add(new SelectOption(f.getLabel(), f.getValue()));
				}
			}
		}
		
		return options;
	}
	
	public List<SelectOption> getcancellationReasons() {
		List<SelectOption> options = new List<SelectOption>();
		
		Schema.DescribeFieldResult fieldResult = Membership__c.Cancellation_Reason__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		
		options.add(new SelectOption('', '--None--'));
		for( Schema.PicklistEntry f : ple) {
			if (isNonAdminUser) {
				if (nonAdminReasonMap.containsKey(rhMembership.Cancellation_Type__c)) {
					if (nonAdminReasonMap.get(rhMembership.Cancellation_Type__c).contains(f.getLabel())) {
						options.add(new SelectOption(f.getLabel(), f.getValue()));
					}
				}
			} else {
				if (adminReasonMap.containsKey(rhMembership.Cancellation_Type__c)) {
					if (adminReasonMap.get(rhMembership.Cancellation_Type__c).contains(f.getLabel())) {
						options.add(new SelectOption(f.getLabel(), f.getValue()));
					}
				}
			}
		}
		
		return options;
	}
	
	public PageReference cancellationTypeChanged() {
		return null;
	}
	
	public PageReference cancelCancellationType() {
		isEditMode = false;
		rhMembership = [select Id, Name, Cancellation_Type__c, Cancellation_Reason__c, Cancellation_Date__c, Membership_Restore_Date__c from Membership__c where Id = :rhMembership.Id];
		return null;
	}
	
	public PageReference editCancellationType() {
		isEditMode = true;
		return null;
	}
	
	public PageReference saveCancellationType() {
		PageReference pr = null;
		
		try {
			update rhMembership;
			rhMembership = [select Id, Name, Cancellation_Type__c, Cancellation_Reason__c, Cancellation_Date__c, Membership_Restore_Date__c from Membership__c where Id = :rhMembership.Id];
			isEditMode = false;
			
			// Determine if fields are read only based upon user type and value of Cancellation Type
			isReadOnly = false;
			if (String.isNotBlank(rhMembership.Cancellation_Type__c)) {
				if (memCancelMap.containsKey(rhMembership.Cancellation_Type__c)) {
					if (isNonAdminUser && !memCancelMap.get(rhMembership.Cancellation_Type__c).nonAdmin__c) {
						isReadOnly = true;
					}
				}
			}
			
		} catch(Exception e) {
			if (!ApexPages.hasMessages()) {
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Save exception: ' + e.getMessage()));
			}
		}
		
		return pr;
	}
}