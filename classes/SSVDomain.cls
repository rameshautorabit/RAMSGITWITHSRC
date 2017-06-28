/**
 *  SSVDomain.cls
 *  @description Domain class for Source_System_View__c object. 
 *               Handles all functionality for its respective object,
 *               deferring complex implementations to helper classes.
 *  @author Ernesto Valdes, Traction On Demand
 */
public class SSVDomain {

	/**
	 *  The records that the domain class methods will act on
	 */
	private List<Source_System_View__c> records;

	/**
	 *  Helper class to clean source system view record fields for duplicate matching
	 */
	public SSVCleaner ssvCleaner {
		get {
			if (ssvCleaner == null) 
				ssvCleaner = new SSVCleaner(this.records);
			return ssvCleaner;
		} set;
	}

	public SSVLoader ssvLoader {
		get {
			if (ssvLoader == null) 
				ssvLoader = new SSVLoader(this.records);
			return ssvLoader;
		} set;
	}

	/**
	 *  @description Constructor, casts given records to appropiate type
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2015-11-03
	 *  @param       records       List of sObjects (should be of type Source_System_View__c)
	 */
	public SSVDomain(List<sObject> records) {
		this.records = (List<Source_System_View__c>) records;
	}

	public static void triggerHandler() {
		
	    if(!FeatureFlagService.isMdmMergeFeatureActive()){
	    	return;
		}		

		if (trigger.isBefore) {
			if (trigger.isInsert) new SSVDomain(trigger.new).handleBeforeInsert();
			if (trigger.isUpdate) new SSVDomain(trigger.new).handleBeforeUpdate(trigger.oldMap);	
		}
		
	}

	private void handleBeforeInsert() {
		ssvCleaner.prepareMatchFields();

		List<Source_System_View__c> companyRecords = ssvLoader
			.createCompanyRecordsForCustomers()
			.getCompanyRecords();

		if (!companyRecords.isEmpty()) insert companyRecords;

		ssvLoader.linkCustomerRecordsToCompanyRecords();
	}

	private void handleBeforeUpdate(Map<Id, sObject> oldMap) {
        Long checkpoint = Datetime.now().getTime();
		ssvCleaner.filterChangedRecords((Map<Id, Source_System_View__c>) oldMap).prepareMatchFields();
		Reporter.log('SSV Update trigger. Time: ' + (Datetime.now().getTime() - checkpoint));		
	}

	private void handleAfterInsert() {}

	private void handleAfterUpdate(Map<Id, sObject> oldMap) {}
}