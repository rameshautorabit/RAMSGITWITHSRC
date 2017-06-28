/**
 *  SSVDuplicateDetector.cls
 *  @description Detects source system view records that have been added
 *               to a duplicate record set, and stamps record set ids onto
 *               source system view records
 *  @author Ernesto Valdes, Traction On Demand
 */
public class SSVDuplicateDetector {

	/**
	 *  Records in class scope, denoting a junction between a duplicate record set
	 *  and a member of the duplicate record set
	 */
	List<DuplicateRecordItem> records;

	/**
	 *  Duplicate record ids
	 */
	Set<Id> recordIds {
		get {
			if (recordIds == null) {
				recordIds = new Set<Id>();
				for (DuplicateRecordItem dri : records) recordIds.add(dri.RecordId);
			}
			return recordIds;
		}
		set;
	}

	/**
	 *  Duplicate record set ids
	 */
	Set<Id> duplicateRecordSetIds {
		get {
			if (duplicateRecordSetIds == null) {
				duplicateRecordSetIds = new Set<Id>();
				for (DuplicateRecordItem dri : records) duplicateRecordSetIds.add(dri.DuplicateRecordSetId);
			}
			return duplicateRecordSetIds;
		}
		set;
	}

	Map<Id, DuplicateRecordSet> duplicateRecordSetsById {
		get {
			if (duplicateRecordSetsById == null) {
				duplicateRecordSetsById = new Map<Id, DuplicateRecordSet>([
					SELECT Id, Duplicate_Record_Set_Number__c
					FROM DuplicateRecordSet
					WHERE Id IN :duplicateRecordSetIds
				]);
			}
			return duplicateRecordSetsById;
		}
		set;
	}


	/**
	 *  List of duplicate source sytem view recods
	 */
	Map<Id, Source_System_View__c> duplicateSSVList {
		get {
			if (duplicateSSVList == null) {
				duplicateSSVList = new Map<Id, Source_System_View__c>([
					SELECT Id, Duplicate_Set_ID__c
					FROM Source_System_View__c
					WHERE Id IN :recordIds
				]);
			}
			return duplicateSSVList;
		}
		set;
	}


	Map<String, Set<Id>> recordIdsByDuplicateSet {
		get {
			if (recordIdsByDuplicateSet == null) {
				recordIdsByDuplicateSet = new Map<String, Set<Id>>();

				// Collect duplicate set numbers
				Set<String> duplicateRecordSetNumber = new Set<String>();
				for (DuplicateRecordSet drs : duplicateRecordSetsById.values())
					duplicateRecordSetNumber.add(drs.Duplicate_Record_Set_Number__c);
				for (Source_System_View__c ssv : duplicateSSVList.values())
					duplicateRecordSetNumber.add(ssv.Duplicate_Set_ID__c);
				duplicateRecordSetNumber.remove(null);

				// Query duplicate record items
				for (DuplicateRecordItem dri : [SELECT RecordId, DuplicateRecordSet.Duplicate_Record_Set_Number__c
												FROM DuplicateRecordItem 
												WHERE DuplicateRecordSet.Duplicate_Record_Set_Number__c != null
													AND DuplicateRecordSet.Duplicate_Record_Set_Number__c IN :duplicateRecordSetNumber]) {
					
					if (!recordIdsByDuplicateSet.containsKey(dri.DuplicateRecordSet.Duplicate_Record_Set_Number__c))
						recordIdsByDuplicateSet.put(dri.DuplicateRecordSet.Duplicate_Record_Set_Number__c, new Set<Id>());

					recordIdsByDuplicateSet.get(dri.DuplicateRecordSet.Duplicate_Record_Set_Number__c).add(dri.RecordId);
				}
			}
			return recordIdsByDuplicateSet;
		}
		set;
	}

	/**
	 *  @description Constructor, initializes duplciate record items in scope
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2016-02-08
	 *  @param       records       List of DuplicateRecordItem
	 */
	public SSVDuplicateDetector(List<DuplicateRecordItem> records) {
		this.records = records;
	}

	/**
	 *  @description Stamps the Duplicate Set ID field on source system view records
	 *               that have been identified as belonging to a duplicate record set.
	 *               Also flags records for stewardship review if their duplicate record
	 *               set has changed
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2016-02-08
	 *  @return      The list of modified source system view records
	 */
	public List<Source_System_View__c> stampDuplicates() {

		Map<Id, Source_System_View__c> ssvForUpdate = new  Map<Id, Source_System_View__c>();
		for (DuplicateRecordItem dri : records) {

			// If source system view exists
			if (duplicateSSVList.containsKey(dri.RecordId) && 
				duplicateRecordSetsById.containsKey(dri.DuplicateRecordSetId)) {

				Source_System_View__c currentSSV = duplicateSSVList.get(dri.RecordId);
				DuplicateRecordSet currentDuplicateSet = duplicateRecordSetsById.get(dri.DuplicateRecordSetId);

				// If source system view has a different duplicate set id
				// then flag for stewardship review
				if (currentSSV.Duplicate_Set_ID__c != null &&
					currentSSV.Duplicate_Set_ID__c != currentDuplicateSet.Duplicate_Record_Set_Number__c) {

					// if duplicate set has changed
					// determine if new duplicate set contains same records as old duplicate set
					Set<Id> oldSetRecordIds = recordIdsByDuplicateSet.get(currentSSV.Duplicate_Set_ID__c);
					Set<Id> newSetRecordIds = recordIdsByDuplicateSet.get(currentDuplicateSet.Duplicate_Record_Set_Number__c);
					
					if (newSetRecordIds != null &&
						oldSetRecordIds != null &&
						!newSetRecordIds.containsAll(oldSetRecordIds)) {
						// if records in old and new duplicate set are the same, then don't flag for review
						// since salesforce has merely switched all records from set A to set B

						// flag for review
						currentSSV.Stewardship_Review_Required__c = true;
						currentSSV.Stewardship_Review_Description__c = 'Duplicate Set Id changed from: ' + currentSSV.Duplicate_Set_ID__c 
																	+ ' to: ' + currentDuplicateSet.Duplicate_Record_Set_Number__c;
					}

				}

				// Stamp duplicate set id
				currentSSV.Duplicate_Set_ID__c = currentDuplicateSet.Duplicate_Record_Set_Number__c;
				currentSSV.Duplicate_Set_ID_Set_Datetime__c = DateTime.now();

				// Store for update
				ssvForUpdate.put(currentSSV.Id, currentSSV);
			}
		}

		return ssvForUpdate.values();
	}


}