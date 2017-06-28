/**
 *  SSVConsolidator.cls
 *  @description Helper class to match and consolidate records inside duplciate sets
 *  @author Ernesto Valdes, Traction On Demand
 */
public class SSVConsolidator {
		
	/// put into one method so we can work out what the hell is going on
	/// OTHERWISE it was a nightmare to read. 
	/// Will split into readable static methods after solving bug.
	
	// WHAT this does is:
	// 1. Get the SSV records to be processed, gets their duplicate set Ids.
	// 2. Goes and gets all the SSV records that have that same duplicate set ID.
	// 3. For each duplicate set ID, it consolidates the existing SSV records into a single SSVConsolidated class (based on consolidation key)
	// 4. Adds the new SSV record with matching duplicate set ID to that SSVConsolidated class if it matches with ANY records already in there.
	// 5. Returns the list of consolidated records
	
	
	public static List<SSVConsolidated> getConsolidatedGroups(List<Source_System_View__c> recordsToConsolidate) {
		
		// 1. go through list of SSVs we are processing

		Set<Id> excludedIds = new Set<Id>();
		Map<String, List<SSVCleansed>> ssvByDuplicateSetId = new Map<String, List<SSVCleansed>>();
		
		for (Source_System_View__c ssv : recordsToConsolidate) {
			if (ssv.Duplicate_Set_ID__c != null) {
				excludedIds.add(ssv.Id);
				if (!ssvByDuplicateSetId.containsKey(ssv.Duplicate_Set_ID__c)) {
					ssvByDuplicateSetId.put(ssv.Duplicate_Set_ID__c, new List<SSVCleansed>());		
				}
				ssvByDuplicateSetId.get(ssv.Duplicate_Set_ID__c).add(new SSVCleansed(ssv));				
			} 
		}	
		
		// 4 get all the SSV records that have those duplicate set IDs 
		
		List<Source_System_View__c> existingList = SSVSelector.getSSVsByDuplicateSetIdAndExcludeRecordIds(ssvByDuplicateSetId.keySet(), excludedIds);
		
		
		// 5 put those into a map (only bring in those that already have an account or contact mapped)
		
		Map<String, List<Source_System_View__c>> existingSSVsByDuplicateSetId = new Map<String, List<Source_System_View__c>>();
		for (Source_System_View__c existing : existingList) {			
			if (existing.Account__c != null || existing.Contact__c != null) {
				if (!existingSSVsByDuplicateSetId.containsKey(existing.Duplicate_Set_ID__c)) {
					existingSSVsByDuplicateSetId.put(existing.Duplicate_Set_ID__c, new List<Source_System_View__c>());
				}	
				existingSSVsByDuplicateSetId.get(existing.Duplicate_Set_ID__c).add(existing);
			}
		}
		
		// 6 create a list to hold the consolidated records (by duplicate set ID)
		
		Map<String, Map<String, SSVConsolidated>> ssvConsolidatedByDuplicateSetId = new Map<String, Map<String, SSVConsolidated>>();		
		
		// 7. populate the consolidate list 
		
		for (String duplicateSetId : ssvByDuplicateSetId.keySet()) {
		
			if (existingSSVsByDuplicateSetId.containsKey(duplicateSetId)) {
				
				for (Source_System_View__c ssv : existingSSVsByDuplicateSetId.get(duplicateSetId)) {
	
					// Create SSV wrapper
					SSVCleansed newSSVCleansed = new SSVCleansed(ssv);
	
					// Get existing consolidated records under duplicate set
					
					if (!ssvConsolidatedByDuplicateSetId.containsKey(duplicateSetId)) {
						ssvConsolidatedByDuplicateSetId.put(duplicateSetId, new Map<String, SSVConsolidated>());
					}				
					Map<String, SSVConsolidated> existingConsolidatedRecords = ssvConsolidatedByDuplicateSetId.get(duplicateSetId);
	
					// Check if current record belongs in existing consolidated group
					// if not, then create a new consolidated group for current record
					// SO - upshot is that for every unique duplicates set, we will have a
					// SSVConsolidated object containing all SSVCleansed objects that share the same consolidation key				
					
					if (!existingConsolidatedRecords.containsKey(newSSVCleansed.getConsolidationKey())) {
						existingConsolidatedRecords.put(newSSVCleansed.getConsolidationKey(), new SSVConsolidated(newSSVCleansed));
					} else {
						existingConsolidatedRecords.get(newSSVCleansed.getConsolidationKey()).addSSV(newSSVCleansed);
					}
				}
			}		
			
			// 8. consolidate the new into the existing
			// loop through all the duplicate set ids of the records to consolidate			
			// process every current SSV that has that duplicate set ID.
			
			for (SSVCleansed currentSSV : ssvByDuplicateSetId.get(duplicateSetId)) {

				Boolean currentSSVMatched = false;

				// add a list for that duplicate set if one does not already exist
				
				if (!ssvConsolidatedByDuplicateSetId.containsKey(duplicateSetId)) {
					ssvConsolidatedByDuplicateSetId.put(duplicateSetId, new Map<String, SSVConsolidated>());
				}
				List<SSVConsolidated> consolidatedList = ssvConsolidatedByDuplicateSetId.get(duplicateSetId).values();
				
				// For each record, match against existing consolidated records (for that duplicate set id)
				
				for (SSVConsolidated currentConsolidatedSSV : consolidatedList) {

					if (currentConsolidatedSSV.matches(currentSSV)) {
						
						// if record matches existing consolidated group
						// then add to consolidated group
						currentConsolidatedSSV.addSSV(currentSSV);
						currentSSVMatched = true;
						break;
					}
				}

				// if record does not match any existing consolidated records,
				// then create new consolidated record
				
				if (!currentSSVMatched) {
					// Set the record id as the map key since the current record is new and does not have a consolidation key
					// and i guess want to make sure single duplicate set doesn't have same record mapped more than once.
					ssvConsolidatedByDuplicateSetId.get(duplicateSetId).put(currentSSV.recordId, new SSVConsolidated(currentSSV));
				}
			}
		}
		
		// 9. finally, return the consolidated groups
		
		List<SSVConsolidated> consolidatedGroups = new List<SSVConsolidated>();

		for (Map<String, SSVConsolidated> currentGroup : ssvConsolidatedByDuplicateSetId.values()) {
			consolidatedGroups.addAll(currentGroup.values());
		}

		return consolidatedGroups;		
		
		
	}
	
		
}