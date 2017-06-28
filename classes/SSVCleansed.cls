/**
 *  SSVCleansed.cls
 *  @description Wrapper class for source system view records
 *               allows records to be matched against other records
 *               using consolidation match criteria
 *  @author Ernesto Valdes, Traction On Demand
 */
global class SSVCleansed implements Comparable {

	public Id recordId, accountId, contactId, parentSSV;

	public String duplicateSetId, companyDuplicateSetId, companyAccountId, firstNameMatchKey, lastNameMatchKey, companyNameMatchKey, 
				  emailMatchKey, phoneMatchKey, addressMatchKey, matchType, consolidationKey,
				  tradeId, membershipNumber;

	public Decimal masterRecordScore;

	private @testVisible SSVMatcher.IMatcher matcher;

	public Source_System_View__c ssv;


	public SSVCleansed(Source_System_View__c ssv) {
		
		// Set original record
		this.ssv = ssv;

		// Set ids
		this.recordId = ssv.Id;
		this.duplicateSetId = ssv.Duplicate_Set_ID__c;
		this.companyDuplicateSetId = ssv.Source_System_View_CW_Company__r.Duplicate_Set_ID__c;
		this.companyAccountId = ssv.Source_System_View_CW_Company__r.Account__c; 
		this.accountId = ssv.Account__c;
		this.contactId = ssv.Contact__c;
		this.parentSSV = ssv.Source_System_View_CW_Company__c;

		// Set match keys
		this.firstNameMatchKey = ssv.Cleansed_First_Name__c;
		this.lastNameMatchKey = ssv.Cleansed_Last_Name__c;
		this.companyNameMatchKey = ssv.Cleansed_Company_Name__c;
		this.emailMatchKey = ssv.Email_Match_Key__c;
		this.phoneMatchKey = ssv.Day_Phone_Match_Key__c;
		this.addressMatchKey = ssv.Address_Match_Key__c;
		
		// Set matcher type and init matcher
		this.masterRecordScore = ssv.Master_Record_Score__c;
		this.matchType = ssv.Match_Type__c;
		this.matcher = SSVMatcher.createMatcher(matchType);
		
		// add member and trade Ids
		this.tradeId = ssv.Trade_ID__c;
		this.membershipNumber = ssv.Membership_Number__c;

		// Set consolidation key
		consolidationKey = String.join(new List<String>{duplicateSetId, accountId, contactId},'');
	}

	public Boolean matches(SSVCleansed ssvc) {
		return matcher.matches(this, ssvc);
	}

	public String getConsolidationKey() {
		return consolidationKey;
	}

	public String getDuplicateSetId() {
		return duplicateSetId;
	}

	public Boolean isNew() {
		return accountId == null && contactId == null;
	}

	global Integer compareTo(Object compareToObj) {
		
		SSVCleansed compareTo =	(SSVCleansed) compareToObj;

		if (masterRecordScore == compareTo.masterRecordScore) return 0;
		if (masterRecordScore < compareTo.masterRecordScore) return 1;
		return -1;
	}
}