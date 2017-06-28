public class CaseTriggerHelper {
	
	/*
	 *	Used by Case triggers to avoid making recursive updates.
	 *	Works for fields on the Case object of type Boolean, Decimal, Integer, Double, Long, Date, DateTime and String
	 *
	 */
	
	private static Map<String, Map<Id, String>> oldFieldValuesMap = null;
	
	public static Map<Id, Case> caseAfterUpdate(Map<Id, Case> newMap, Map<Id, Case> oldMap, String compareValue, String fieldName, String fieldDataType, Boolean useNewValue, Boolean notEqual) {
        
        system.debug('*****caseAfterUpdate oldFieldValuesMap = ' + oldFieldValuesMap + ' compareValue = ' + compareValue + ' fieldName = ' + fieldName + ' fieldDataType = ' + fieldDataType + ' useNewValue = ' + useNewValue + ' notEqual = ' + notEqual);
        
        if (oldFieldValuesMap == null) {
            oldFieldValuesMap = new Map<String, Map<Id, String>>();
		}
		
		Map<Id, Case> justChangedCasesMap = new Map<Id, Case>();
		
		String oldValue;
		String newValue;
		for (Case c :newMap.values()) {
			
			// convert new and old values to strings for comparison based upon data type
			if (fieldDataType == 'Boolean') {
				if (c.get(fieldName) == true) {
					newValue = 'true';
				} else {
					newValue = 'false';
				}
				if (oldMap.get(c.Id).get(fieldName) == true) {
					oldValue = 'true';
				} else {
					oldValue = 'false';
				}
			} else {
				If (fieldDataType == 'String') {
					newValue = (String)c.get(fieldName);
					oldValue = (String)oldMap.get(c.Id).get(fieldName);
				} else {
					newValue = String.valueOf(c.get(fieldName));
					oldValue = String.valueOf(oldMap.get(c.Id).get(fieldName));
				}
			}
			
			system.debug('*****caseAfterUpdate newValue = ' + newValue + ' oldValue = ' + oldValue);
			
			// If useNewValue is true, set compareValue to newValue and simply test if the field has changed
			// otherwise we are testing if the field has changed to a specific value
			if (useNewValue) {
				compareValue = newValue;
			}
			
			// Set oldValue to the to the "correct" old value in case the trigger is run again in the same context
			if (oldFieldValuesMap.containsKey(fieldName)) {
				if (oldFieldValuesMap.get(fieldName).containsKey(c.Id)) {
					oldValue = (String) oldFieldValuesMap.get(fieldName).get(c.Id);
				}
			}
			
			system.debug('*****caseAfterUpdate newValue2 = ' + newValue + ' oldValue2 = ' + oldValue);
			
			//This checks the current case value with the 'correct' old value
			if (notEqual) {
				if (newValue != compareValue && oldValue == compareValue) {
					justChangedCasesMap.put(c.Id, c);
				}
			} else {
				if (newValue == compareValue && oldValue != compareValue) {
					justChangedCasesMap.put(c.Id, c);
				}
			}
			
			//this puts in the 'correct' old value in case the trigger is run again in the same context
			if (oldValue != newValue) {
				if (!oldFieldValuesMap.containsKey(fieldName)) {
					oldFieldValuesMap.put(fieldName, new Map<Id, String>());
				}
				oldFieldValuesMap.get(fieldName).put(c.Id, newValue);
			}
		}
		
		system.debug('*****caseAfterUpdate justChangedCasesMap.size = ' + justChangedCasesMap.size());
		
		return justChangedCasesMap;
	}
	
	/*
	 *	Used by Case_CompleteMilestone.trigger to make sure we don't attempt to complete milestones
	 *	for a Case more than once in the same context.
	 *
	 */
	
	private static Map<Id, Case> completedCasesMap = null;
	
	public static Map<Id, Case> checkCompletedCases(Map<Id, Case> caseMap) {
		
        if (completedCasesMap == null) {
            completedCasesMap = new Map<Id, Case>();
		}
		
		Map<Id, Case> casesToCompleteMap = new Map<Id, Case>();
		
		// If the Case is not in our completed map, add it to our completed map and return 
		// it so that the milestones will be completed.
		for (Case c :caseMap.values()) {
			if (!completedCasesMap.containsKey(c.Id)) {
				completedCasesMap.put(c.Id, c);
				casesToCompleteMap.put(c.Id, c);
			}
		}
		
		return casesToCompleteMap;
	}
}