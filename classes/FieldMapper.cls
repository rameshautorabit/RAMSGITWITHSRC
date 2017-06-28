/**
 *  @description Generic field mapper class
 *  @author      Zi Zhang, Traction on Demand.
 *  @date        2016-02-25
 */
public with sharing class FieldMapper {
	private static Map<Schema.SObjectType, Set<String>> fieldsBySobjectType = new Map<Schema.SObjectType, Set<String>>();

	/**
	 * Check if SObject has valid field
	 * @author Zi Zhang, Traction on Demand
	 * @date   2016-03-02
	 */
	public static Boolean hasSObjectField(String fieldName, SObject obj) {
		if(!fieldsBySobjectType.containsKey(obj.getSObjectType())) {
			fieldsBySobjectType.put(obj.getSObjectType(), obj.getSObjectType().getDescribe().fields.getMap().keySet());
		}

		return fieldsBySobjectType.get(obj.getSObjectType()).contains(fieldName.toLowerCase());
	}

	public static List<SObject> getChildren(List<SObject> parentRecords) {
		List<SObject> children;

		return children;
	}

	/**
	 * Bottom layer maps fields of one SObject to another SObject based on field mapping custom settings
	 * @author Zi Zhang, Traction on Demand
	 * @date   2016-02-27
	 * @param  source     SObject
	 * @param  target     SObject
	 * @return            Target SObject with fields mapped from source object
	 */
	public static void mapObject(SObject source, SObject target, List<SObject> mapSettings) {
		if(mapSettings == null) {
			return;
		}

		for(SObject obj : mapSettings) {
			if(obj.get('Target_Field__c') != null && 
					obj.get('Source_Field__c') != null && 
					hasSObjectField((String) obj.get('Target_Field__c'), target) && 
					hasSObjectField((String) obj.get('Source_Field__c'), source)) {						
						try {
							target.put((String) obj.get('Target_Field__c'), source.get((String) obj.get('Source_Field__c')));
						} catch(Exception ex) {
							Reporter.log('invalid source or target field');
						}
			} else {
				// todo-zz Field mapping error, report it
			}
		}
	}
}