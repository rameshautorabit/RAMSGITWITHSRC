/**
 * @description Utility methods for lists
 * @group Standard Object Utilities
 * @author John Rogers, Traction on Demand
 * @date 04-02-2016
 * TODO-jdr pull new methods into utils library
 */
public with sharing class ListUtils {

    ///**
    // * Given a list of sObjects returns a set containing that list
    // * @param  aList : The list
    // * @return  A set
    // */
    //public static Set<Object> listToSet(List<Object> aList) {
    //    Set<Object> newSet = new Set<Object>();
    //    newSet.addAll(aList);
    //    return newSet;
    //}

    ///**
    // * Given a set of sObjects returns a list containing that set
    // * @param  aSet : The set
    // * @return  A list
    // */
    //public static List<Object> setToList(Set<Object> aSet) {
    //    List<Object> newList = new List<Object>();
    //    newList.addAll(aSet);
    //    return newList;
    //}

    ///**
    // * Given a list of sObjects return a subset of that list
    // * @param aList : The list to return a subset of
    // * @param endIndex : The index of the last element to include in the subset
    // * @return The subset
    // */
    //public static List<SObject> subset(List<SObject> aList, Integer endIndex) {
    //    return subset(aList, 0, endIndex);
    //}

    ///**
    // * Given a set of sObjects return a subset of that list
    // * @param aSet : The set to return a subset of
    // * @param endIndex : The index of the last element to include in the subset
    // * @return The subset
    // */
    //public static Set<SObject> subset(Set<SObject> aSet, Integer endIndex) {
    //    return subset(aSet, 0, endIndex);
    //}

    /**
     * Given a list of SObjects return a subset of that list
     * @param aList : The list to return a subset of
     * @param startIndex : The index of the first element to include in the subset
     * @param endIndex : The index of the last element to include in the subset
     * @return The subset
     */
    public static List<SObject> subset(List<SObject> aList, Integer startIndex, Integer endIndex) {
        List<SObject> returnList = new List<SObject>();
        if(aList != null && aList.size() > 0 
                && startIndex <= aList.size() - 1 
                && endIndex <= aList.size() - 1 
                && endIndex >= startIndex){
            Integer length = aList.size();
            for(Integer i = startIndex; i < length && i <= endIndex; i++) {
                returnList.add(aList.get(i));
            }
        }
        return returnList;
    }

    ///**
    // * Given a set of SObjects return a subset of that set
    // * @param aSet: The set to return a subset of
    // * @param startIndex : The index of the first element to include in the subset
    // * @param endIndex : The index of the last element to include in the subset
    // * @return The subset
    // */
    //public static Set<SObject> subset(Set<SObject> aSet, Integer startIndex, Integer endIndex) {
    //    return listToSet(subset(setToList(aSet), startIndex, endIndex));
    //}

    ///**
    // * Given a list of objects return a subset of that list
    // * @param aList : The list to return a subset of
    // * @param startIndex : The index of the first element to include in the subset
    // * @param endIndex : The index of the last element to include in the subset
    // * @return The subset
    // */
    //public static List<Object> subset(List<Object> aList, Integer startIndex, Integer endIndex) {
    //    List<Object> returnList = new List<Object>();
    //    if(aList != null && aList.size() > 0 
    //            && startIndex <= aList.size() - 1 
    //            && endIndex <= aList.size() - 1 
    //            && endIndex >= startIndex){
    //        Integer length = aList.size();
    //        for(Integer i = startIndex; i < length && i <= endIndex; i++) {
    //            returnList.add(aList.get(i));
    //        }
    //    }
    //    return returnList;
    //}

    ///**
    // * Given a set of SObjects return a subset of that set
    // * @param aSet: The set to return a subset of
    // * @param startIndex : The index of the first element to include in the subset
    // * @param endIndex : The index of the last element to include in the subset
    // * @return The subset
    // */
    //public static Set<Object> subset(Set<Object> aSet, Integer startIndex, Integer endIndex) {
    //    return listToSet(subset(setToList(aSet), startIndex, endIndex));
    //}

    /**
     * Reads set values from given 'source' list and inserts them into the given 'result' list
     * @param result : The list to insert the values into
     * @param source : The list to retrieve values from
     * @param field : The field to read values from
     */
    public static Set<Id> collectIds(List<SObject> source, Schema.SObjectField field) {
        Set<Id> result = new Set<Id>();
        for(SObject record : source) {
            result.add((Id) record.get(field));
        }
        return result;
    }

    /**
     * Reads set values from given 'source' list and inserts them into the given 'result' list
     * @param result : The list to insert the values into
     * @param source : The list to retrieve values from
     * @param field : The field to read values from
     */
    public static Set<Id> collectIds(List<SObject> source, String field) {
        Set<Id> result = new Set<Id>();
        for(SObject record : source) {
            result.add((Id) record.get(field));
        }
        return result;
    }


    ///**
    // * Returns list of field values for the given sObject
    // * @param source : The list to retrieve values from
    // * @param field : The field to read values from
    // * @return The list of values
    // */
    //public static List<Object> collectValues(List<SObject> source, Schema.SObjectField field) {
    //    List<Object> result = new List<Object>();
    //    collectValues(result, source, field);
    //    return result;
    //}

    ///**
    // * Reads field values from given 'source' list and inserts them into the given 'result' list
    // * @param result : The list to insert the values into
    // * @param source : The list to retrieve values from
    // * @param field : The field to read values from
    // */
    //public static void collectValues(List<Object> result, List<SObject> source, 
    //        Schema.SObjectField field) {
    //    for(SObject record : source) {
    //        result.add(record.get(field));
    //    }
    //}

    ///**
    // * @description Add all records to the 'result' list for which obj.get(field) is
    // *              equal to the given value
    // * @param source : The list to filter
    // * @param field : The field to filter on
    // * @param value : The value to match on
    // * @return The filtered list
    // */
    //public static List<SObject> filterByField(List<SObject> source, 
    //        Schema.SObjectField field, Object value) {
    //    List<SObject> result = new List<SObject>();
    //    filterByField(result, source, field, value);
    //    return result;
    //}

    ///**
    // * @description Add all records to the 'result' list for which obj.get(field) is
    // *              equal to the given value
    // * @param result : The list to store the results in
    // * @param source : The list to filter
    // * @param field : The field to filter on
    // * @param value : The value to match on
    // */
    //public static void filterByField(List<SObject> result, List<SObject> source, 
    //        Schema.SObjectField field, Object value) {
    //    for (SObject obj : source) {
    //        if(obj.get(field) == value) {
    //            result.add(obj);
    //        }
    //    }
    //}

    /**
     * @author John Rogers, Traction on Demand
     * @date   2015-12-04
     * @param  objs : records to read from
     * @param  field : field to sum
     * @return The sum of the values in the given field 
     */
    public static Double getSum(List<SObject> objs, Schema.SObjectField field) {
        Double sum = 0;
        for (SObject obj : objs) {
            sum += (Double) obj.get(field);
        }
        return sum;
    }
}