/**
 * @description Utility methods for maps
 * @group Standard Object Utilities
 * @author John Rogers, Traction on Demand
 * @date 04-02-2016
 */
public with sharing class MapUtils {

    ///**
    // * Map field values to lists of SObjects
    // * @param source : The list used to create the map 
    // * @param field : The key field
    // * @return  The The { SObject.field.value => SObject } map map
    // */
    //public static Map<Object, List<SObject>> mapByFieldToList(List<SObject> source,
    //        SObjectField field) {
    //    Map<Object, List<SObject>> result = new Map<Object, List<SObject>>();
    //    mapByFieldToList(result, source, field);
    //    return result;
    //}

    ///**
    // * Map field values to lists of SObjects (convience method so you don't have to cast the map)
    // * @param result : The { SObject.field.value => SObject } map
    // * @param source : The list used to create the map 
    // * @param field : The key field
    // */
    //public static void mapByFieldToList(Map<Object, List<SObject>> result, List<SObject> source,
    //        SObjectField field) {
    //    for (SObject record : source) {
    //        Object key = record.get(field);
    //        List<SObject> objects = result.get(key);
    //        if (objects == null) {
    //            objects = new List<SObject>();
    //            result.put(key, objects);
    //        }
    //        objects.add(record);   
    //    }
    //}

    /**
     * Map field values to lists of SObjects (convience method for ID fields)
     * @param source : The list used to create the map 
     * @param field : The key field
     * @return  The { SObject.field.value => SObject } map
     */
    public static Map<Id, List<SObject>> mapByIdFieldToList(List<SObject> source,
            SObjectField field) {
        Map<Id, List<SObject>> result = new Map<Id, List<SObject>>();
        for (SObject record : source) {
            Id key = (Id) record.get(field);
            List<SObject> objects = result.get(key);
            if (objects == null) {
                objects = new List<SObject>();
                result.put(key, objects);
            }
            objects.add(record);   
        }
        return result;
    }

    /**
     * Map field values to lists of SObjects (convience method for ID fields)
     * @param source : The list used to create the map 
     * @param field : The key field
     * @return  The { SObject.field.value => SObject } map
     */
    public static Map<Id, SObject> mapByIdField(List<SObject> source,
            SObjectField field) {
        Map<Id, SObject> result = new Map<Id, SObject>();
        for (SObject record : source) {
            Id key = (Id) record.get(field);
            result.put(key, record);
        }
        return result;
    }

    ///**
    // * Map field values to SObjects
    // * @param source : The list used to create the map
    // * @param field : The map of field values to list of SObjects
    // * @return : The { SObject.field.value => SObject } map
    // */
    //public static Map<Object, SObject> mapByField(List<SObject> source, 
    //        SObjectField field) {
    //    Map<Object, SObject> result = new Map<Object, SObject>();
    //    mapByField(result, source, field);
    //    return result;
    //}

    /**
     * Map field values to SObjects (convience method so you don't have to cast the map)
     * @param result : The { SObject.field.value => SObject } map
     * @param source : The list to retrieve values (keys) and SObjects (values) from
     * @param field : The map of field values to list of SObjects
     */
    public static void mapByField(Map<String, SObject> result, List<SObject> source, 
            SObjectField field) {
        for (SObject record : source) {
            String key = (String) record.get(field);
            result.put(key, record);    
        }
    }

    /**
     * Retrieve a value from a map, and if the value is not present, add the given default to the map and return it 
     * @author John Rogers, Traction on Demand
     * @date        2016-03-09
     * @param       theMap     Map to accesss
     * @param       key        Key of value
     * @param       defaultValue    Returned if the given key maps to null
     * @return theMap.get(key) or default if theMap.get(key)  is null
     * TODO-jdr add to traction-utilities
     */
    public static Object get(Map<Id, Object> theMap, Id key, Object defaultValue) {
        Object value = theMap.get(key);
        if (value == null) {
            theMap.put(key, defaultValue);
            return defaultValue;
        } else {
            return value;
        }
    }
}