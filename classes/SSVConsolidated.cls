/**
 *  SSVConsolidated.cls
 *  @description Represents a group of consolidated source system view records
 *  @author Ernesto Valdes, Traction On Demand
 */
public class SSVConsolidated {

	private List<SSVCleansed> consolidatedRecords = new List<SSVCleansed>();

	private String consolidationKey, duplicateSetId;

	public Id accountId, contactId;
	
	public Id consolidatedAccountId, consolidatedContactId;

	private Boolean isNew, sorted;

	private Set<String> distinctEmails {
		get {
			if (distinctEmails == null)
				distinctEmails = new Set<String>();
			return distinctEmails;
		}
		set;
	}

	public SSVConsolidated(SSVCleansed initialRecord) {

		consolidatedRecords.add(initialRecord);

		consolidationKey = initialRecord.getConsolidationKey();
		duplicateSetId = initialRecord.duplicateSetId;
		accountId = initialRecord.accountId;
		contactId = initialRecord.contactId;

		isNew = initialRecord.isNew();
		sorted = false;

		//Reporter.log('Is New Init: ' + isNew);
		//Reporter.log('Account: ' + accountId);
		//Reporter.log('Contact: ' + contactId);
	}

	public String getConsolidationKey() {
		return consolidationKey;
	}

	public Boolean matches(SSVCleansed ssvToMatch) {

		for (SSVCleansed ssvc : consolidatedRecords) {
			if (ssvc.matches(ssvToMatch)) return true;
		}

		return false;
	}

	public Boolean isNew() {
		return isNew;
	}

	public SSVConsolidated addSSV(SSVCleansed ssvToAdd) {
		consolidatedRecords.add(ssvToAdd);

		distinctEmails.add(ssvToAdd.ssv.Email__c);
		if (!ssvToAdd.isNew()) {
			isNew = false;
			this.consolidatedAccountId = (this.consolidatedAccountId == null && ssvToAdd.accountID != null) ? ssvToAdd.accountID : this.consolidatedAccountId;
			this.consolidatedContactId = (this.consolidatedContactId == null && ssvToAdd.contactId != null) ? ssvToAdd.contactId : this.consolidatedContactId;  
		}

		sorted = false;

		//Reporter.log('Is New Update: ' + isNew);
		//Reporter.log('Account: ' + ssvToAdd.accountId);
		//Reporter.log('Contact: ' + ssvToAdd.contactId);
		return this;
	}

	public List<SSVCleansed> getConsolidatedRecords() {

		if (!sorted) {
			consolidatedRecords.sort();
			sorted = true;
		}
		return consolidatedRecords;
	}

	public SSVCleansed getPrimaryRecord() {
		
		// Sort record list by master record score, descending
		return getConsolidatedRecords()[0];
	}

	public List<SSVCleansed> getNonPrimaryRecords() {

		List<SSVCleansed> nonPrimaryRecords = new List<SSVCleansed>();
		for (SSVCleansed ssvc : getConsolidatedRecords()) nonPrimaryRecords.add(ssvc);
		
		nonPrimaryRecords.remove(0);
		return nonPrimaryRecords;
	}
}