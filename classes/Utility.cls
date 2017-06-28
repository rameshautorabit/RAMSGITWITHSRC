public with sharing class Utility {

     // Delare variable and initialize it to false
    private static boolean  inProcess = false;

    // This function is called by Triggers to see if an instance of the Class is already in process
    public static boolean triggerIsInProcess() {
        return inProcess;
    }

    // This function is called by Triggers after all the in-memory processing and before the DML execution to inform the Class
    // that it is already in process.
    public static void setTriggerInProcess() {
        inProcess = true;
    }

    public static void resetTriggerInProcess() {
        inProcess = false;
    }

    public static String substring(String fullString, Integer startIndex, Integer endIndex) {
    	if (fullString != null) {
    		return fullString.substring(startIndex, endIndex);
    	}
    	return null;
    }

    /*
     * Scheduler helper methods
     */

    public static Id scheduleJobAt(Schedulable scheduler, String jobName, String cronExp) {
    	system.debug('Utility -> scheduleJobAt -> ' + jobName + ' -> ' + cronExp);
        List<CronTrigger> runningJobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :jobName];
        if (!runningJobs.isEmpty()) {
        	system.debug('Utility -> scheduleJobAt -> abort job -> ' + runningJobs[0].Id);
            system.abortJob(runningJobs[0].Id);
        }
        String jobID = System.schedule(jobName, cronExp, scheduler);        
        system.debug('Utility -> scheduleJobAt -> scheduled job -> ' + jobID);
        return jobId;
    }

    public static String buildCronExpression(Integer timeInterval) {
    	Datetime dt = Datetime.now().addMinutes(timeInterval);
    	return '0 ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
    }

    /*
     * Helper method to
     * - Find if a particular set of fields has changed
     * - Aggregate the values for a set of fields
     */

    public static String aggregateFields(SObject obj, Set<SOBjectField> fieldList, String delimeter) {
        Set<String> fieldValues = new Set<String>();
        for (SOBjectField field : fieldList) {
            fieldValues.add(String.valueOf(obj.get(field)));
        }
        fieldValues.remove(null);
        fieldValues.remove('');
        return String.join(new List<String>(fieldValues), delimeter);
    }
    
    public static Boolean hasChanges(SObject lhs, SObject rhs, Set<SOBjectField> checkFields) {
        for (SOBjectField field : checkFields) {
            if (lhs.get(field) != rhs.get(field)) {
                return true;
            }           
        }
        return false;
    }
    
    public static Boolean hasChanges(SObject lhs, SObject rhs, Set<String> fieldNames) {
        for (String fieldName : fieldNames) {
            if (lhs.get(fieldName) != rhs.get(fieldName)) {
                return true;
            }           
        }
        return false;
    }    
        
    /*
     * build up a map based on record attribute
     */

	public @testvisible static Map<Object, List<SObject>> mapByProperty(SObjectField field, List<SObject> source) {
	    Map<Object, List<SObject>> results = new Map<Object, List<SObject>>();
	    for (SObject record : source) {
	      if (record.get(field) != null) {
	        if (!results.containsKey(record.get(field))) {
	          results.put(record.get(field), new List<SObject>());
	        }
	        results.get(record.get(field)).add(record);
	      }
	    }
		system.debug('mapByProperty: ' + results);
    	return results;
	}

    /*
     * Compile a list of updates so each record appears once, whilst maintaining all the
     * values that were set for that object across multiple records in the original list
     */

	public static List<SObject> compileUpdates(List<SObject> recordsToUpdate) {

		// Compile a list of the objects to update. IF an object is present in the list
		// more than once, build up a single array of field/value pairs from the additional ones.
		// (if the field is present more than once, use the last value)
		// A database.update will fail if an object is present more than once

		Map<ID, SObject> consolidatedRecords = new Map<Id, SObject>();
		for (SObject record : recordsToUpdate) {
			if (record.id == null) {
				continue;
			}
		    if (!consolidatedRecords.containsKey(record.id)) {
		        consolidatedRecords.put(record.Id, record);
		    } else {
			    for(String fieldName : record.getPopulatedFieldsAsMap().keySet()) {
                    system.debug('consolidate field name: ' + fieldName + ' for ID ' + record.Id);
                    try {
		        	  consolidatedRecords.get(record.Id).put(fieldName, record.get(fieldName));
                    } catch(Exception ex) {
		                system.debug('failed to add ' + fieldName + ' to ' + record.Id + ' with value ' + record.get(fieldName));
                    }
			    }
		    }
		}

		// Update values.

		return consolidatedRecords.values();
	}

	/*
	 * Send an email
	 */

	public static void sendEmail(String[] toAddresses, String bodyText, String subject) {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      	mail.setToAddresses(toAddresses);
      	mail.setSubject(subject);
      	mail.setPlainTextBody(bodyText);
      	if (!Test.isRunningTest()) {
      		Messaging.sendEmail( new Messaging.SingleEmailMessage[] { mail });
      	}
	}

    /*
     * Logging utilities
     */

	public static void logException(Exception ex, String additionalInfo) {
		database.insert(new Error_Log__c(
				Type__c = 'APEX RUNTIME ERROR',
				Message__c = ex.getMessage(),
				Process_Summary__c = additionalInfo,
				Stack_Trace__c = ex.getStackTraceString()
		));		
	} 
	     
	public static void logException(Exception ex, List<SObject> records) {
		database.insert(new Error_Log__c(
				Type__c = 'APEX RUNTIME ERROR',
				Message__c = ex.getMessage(),
				Stack_Trace__c = ex.getStackTraceString(),
				Target_Object_Name__c = Utility.isEmpty(records) ? null : records.get(0).getSObjectType().getDescribe().getName(),
				Target_Object__c =  Utility.isEmpty(records) ? null : records.get(0).Id
		));		
	}    

	public static List<SObject> logInsert(List<SObject> records) {
		return Utility.logInsert(records, false);
	}

    public static List<SObject> logInsert(List<SObject> records, Boolean optAllOrNone) {
    	try {
    		if (Utility.isEmpty(records)) {
    			return records;
    		}
    		return log(database.insert(records, optAllOrNone), records);
    	} catch(Exception ex) {
    		logException(ex, records);
    	}
		return records;
    }

	public static List<SObject> logUpdate(List<SObject> records) {
		return Utility.logUpdate(records, false);
	}

    public static List<SObject> logUpdate(List<SObject> records, Boolean optAllOrNone) {
    	try {
    		if (Utility.isEmpty(records)) {
    			return records;
    		}    		
    		return log(database.update(records, optAllOrNone), records);
    	} catch (Exception ex) {
			logException(ex, records);
    	}
		return records;
    }

    public static List<SObject> log(List<Database.SaveResult> results) {
    	return log(results, null);
    }

    public static List<SObject> log(List<Database.SaveResult> results, List<SObject> records) {
    	List<SObject> failedRecords = new List<SObject>();
    	List<Error_Log__c> errorLogs = new List<Error_Log__c>();
		for (Integer i = 0; i < results.size(); i++) {
		    if (!results[i].isSuccess()) {
		    	if (records != null) {
		    		failedRecords.add(records.get(i));
		    	}
                for (Database.Error err : results[i].getErrors()) {
					errorLogs.add(new Error_Log__c(
						Type__c = 'DML ERROR',
						Message__c = err.getMessage(),
						Status_Code__c = err.getStatusCode() + '',
						Affected_Fields__c = String.join(err.getFields(), ', '),
						Target_Object_Name__c = (records == null || records.get(i).Id == null ? null : records.get(i).Id.getSObjectType().getDescribe().getName()),
						Target_Object__c = (records == null ? null : records.get(i).Id)
					));
                }
            }
        }
        if (!isEmpty(errorLogs)) {
        	database.insert(errorLogs);
        }
        return failedRecords;
    }
    
    /*
     * Simple utilities
     */    

    public static Boolean isEmpty(List<SObject> listObject) {
    	return listObject == null || listObject.isEmpty();
    }

    public static Boolean isNotEmpty(List<SObject> listObject) {
    	return !isEmpty(listObject);
    }
    
    public static Boolean isEmpty(Set<SObject> setObject) {
    	return setObject == null || setObject.isEmpty();
    }

    public static Boolean isNotEmpty(Set<SObject> setObject) {
    	return !isEmpty(setObject);
    }

    /*
     * End Simple utilities
     */


    // Sort the supplied sObject list by column/field colName.
    public static List<sObject> sObjSort(String colName, String dataType, Boolean sortASC, List<sObject> listToSort) {
        Boolean added;
        String srcField;
        String tempListField;

        Schema.SObjectType objType = listToSort.getSObjectType();
        String listType = 'List<' + objType + '>';

        List<SObject> srcList = (List<SObject>)Type.forName(listType).newInstance();
        srcList.addAll((List<sObject>)listToSort);
        List<SObject> tempList = (List<SObject>)Type.forName(listType).newInstance();
        List<SObject> sortedList = (List<SObject>)Type.forName(listType).newInstance();

        // Sort the list of records
        for (sObject s :srcList) {
            tempList.clear();
            tempList.addAll(sortedList);
            sortedList.clear();
            if (tempList.size() == 0) {
                sortedList.add(s);
            } else {
                added = false;
                while (!added) {
                    for (Integer i=0; i<tempList.size(); i++) {
                        if (!added) {

                            // nulls are first if ascending sort, otherwise nulls are last
                            if (s.get(colName) == null || tempList[i].get(colName) == null) {
                                if (sortASC && s.get(colName) == null) {
                                    sortedList.add(s);
                                    added = true;
                                }
                                if (!sortASC && tempList[i].get(colName) == null) {
                                    sortedList.add(s);
                                    added = true;
                                }

                            } else {

                                if (dataType == 'String') {
                                    srcField = String.valueOf(s.get(colName));
                                    tempListField = String.valueOf(tempList[i].get(colName));
                                    if (sortASC) {
                                        if (srcField.compareTo(tempListField) < 0) {
                                            sortedList.add(s);
                                            added = true;
                                        }
                                    } else {
                                        if (srcField.compareTo(tempListField) >= 0) {
                                            sortedList.add(s);
                                            added = true;
                                        }
                                    }
                                }

                                if (dataType == 'Number') {
                                    if (sortASC) {
                                        if ((Decimal)s.get(colName) < (Decimal)tempList[i].get(colName)) {
                                            sortedList.add(s);
                                            added = true;
                                        }
                                    } else {
                                        if ((Decimal)s.get(colName) >= (Decimal)tempList[i].get(colName)) {
                                            sortedList.add(s);
                                            added = true;
                                        }
                                    }
                                }
                            }
                        }
                        sortedList.add(tempList[i]);
                    }
                    if (!added) {
                        sortedList.add(s);
                        added = true;
                    }
                }
            }
        }
        return sortedList;
    }

    // Convert supplied string to a string with the first letter of each word capitalized.
    // Only convert those words that have at least minLen characters and those that do not
    // contain numeric characters.
    public static String toFirstCap(String inStr, Integer minLen) {
        String rtnStr = '';
        String tStr = '';
        String subStr = '';
        List<String> subStrs = new List<String>();
        List<String> subSubStrs = new List<String>();

        if (String.isNotBlank(inStr) && minLen >= 0) {
            subStrs = inStr.split(' ');
            for (String sub :subStrs) {
                if (!sub.containsAny('0123456789')) {

                    if (sub.contains('-')) {
                        subSubStrs = sub.split('-');
                        for (String s :subSubStrs) {

                            if (minLen > 0) {
                                if (s.length() >= minLen) {
                                    tStr = s.toLowerCase().capitalize();
                                } else {
                                    tStr = s;
                                }
                            } else {
                                tStr = s.toLowerCase().capitalize();
                            }
                            subStr += tStr + '-';
                        }
                        tStr = subStr.removeEnd('-');
                    } else {
                        if (minLen > 0) {
                            if (sub.length() >= minLen) {
                                tStr = sub.toLowerCase().capitalize();
                            } else {
                                tStr = sub;
                            }
                        } else {
                            tStr = sub.toLowerCase().capitalize();
                        }
                    }
                } else {
                    tStr = sub;
                }
                rtnStr += tStr + ' ';
            }
            rtnStr = rtnStr.removeEnd(' ');
        }
        return rtnStr;
    }

    // Convert a date field to a string in the format of MM[delimiter]DD[delimiter]YY
    public static String usDate(Date inputDate, String delimiter) {
        String returnDate = '';
        if (inputDate != null && String.isNotBlank(delimiter)) {
            String tempDate = String.valueOf(inputDate).replaceAll('-', delimiter);
            returnDate = tempDate.substringAfter(delimiter);
            returnDate = returnDate + delimiter + tempDate.substring(2,4);
        }
        return returnDate;
    }

    // Convert a date datatype to a written string - example: either "November 2, 2015" or "NOV 02, 15"
    public static String usWrittenDate(Date inputDate, Boolean fullDate) {
        Map<Integer, String> monthNames = new Map<Integer, String>();
        String writtenDate = '';
        String mn;
        String dy;
        String yr;

        if (inputDate != null) {
            monthNames.put(1, 'January');
            monthNames.put(2, 'February');
            monthNames.put(3, 'March');
            monthNames.put(4, 'April');
            monthNames.put(5, 'May');
            monthNames.put(6, 'June');
            monthNames.put(7, 'July');
            monthNames.put(8, 'August');
            monthNames.put(9, 'September');
            monthNames.put(10, 'October');
            monthNames.put(11, 'November');
            monthNames.put(12, 'December');

            mn = monthNames.get(inputDate.month());
            dy = String.valueOf(inputDate.day());
            yr = String.valueOf(inputDate.year());

            if (!fullDate) {
                mn = mn.substring(0, 3).toUpperCase();
                if (inputDate.day() < 10) {
                    dy = '0' + dy;
                }
                yr = yr.substring(2, 4);
            }
            writtenDate = mn + ' ' + dy + ', ' + yr;
        }

        return writtenDate;
    }

    public static String stripAccents(String source) {
    	if (String.isBlank(source)) {
    		return source;
    	}
		
		return source
			.replaceAll('à', 'a')
			.replaceAll('è', 'e')
			.replaceAll('ì', 'i')
			.replaceAll('ò', 'o')
			.replaceAll('ù', 'u')
			.replaceAll('À', 'A')
			.replaceAll('È', 'E')
			.replaceAll('Ì', 'I')
			.replaceAll('Ò', 'O')
			.replaceAll('Ù', 'U')
			.replaceAll('á', 'a')
			.replaceAll('é', 'e')
			.replaceAll('í', 'i')
			.replaceAll('ó', 'o')
			.replaceAll('ú', 'u')
			.replaceAll('ý', 'y')
			.replaceAll('Á', 'A')
			.replaceAll('É', 'E')
			.replaceAll('Í', 'I')
			.replaceAll('Ó', 'O')
			.replaceAll('Ú', 'U')
			.replaceAll('Ý', 'Y')
			.replaceAll('â', 'a')
			.replaceAll('ê', 'e')
			.replaceAll('î', 'i')
			.replaceAll('ô', 'o')
			.replaceAll('û', 'u')
			.replaceAll('Â', 'A')
			.replaceAll('Ê', 'E')
			.replaceAll('Î', 'I')
			.replaceAll('Ô', 'O')
			.replaceAll('Û', 'U')
			.replaceAll('ã', 'a')
			.replaceAll('ñ', 'n')
			.replaceAll('õ', 'o')
			.replaceAll('Ã', 'A')
			.replaceAll('Ñ', 'N')
			.replaceAll('Õ', 'O')
			.replaceAll('ä', 'a')
			.replaceAll('ë', 'e')
			.replaceAll('ï', 'i')
			.replaceAll('ö', 'o')
			.replaceAll('ü', 'u')
			.replaceAll('ÿ', 'y')
			.replaceAll('Ä', 'A')
			.replaceAll('Ë', 'E')
			.replaceAll('Ï', 'I')
			.replaceAll('Ö', 'O')
			.replaceAll('Ü', 'U')
			.replaceAll('Ÿ', 'Y')
			.replaceAll('å', 'a')
			.replaceAll('Å', 'A')
			.replaceAll('ç', 'c')
			.replaceAll('Ç', 'C')
			.replaceAll('ð', 'o')
			.replaceAll('Ð', 'D')
			.replaceAll('ø', 'o')
			.replaceAll('Ø', 'O');
    }

    public static String stripNonAlphanumericCharacters(String source) {
    	if (String.isBlank(source)) {
    		return source;
    	}
    	Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9]');
		Matcher matcher = nonAlphanumeric.matcher(source);
		return matcher.replaceAll('');
    }

    // Validate an email address
    public static Boolean validateEmail(String email) {

        Boolean res = true;
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: <a rel="nofollow" href="http://www.regular-expressions.info/email.html" target="_blank">http://www.regular-expressions.info/email.html</a>

        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
        if (!MyMatcher.matches()) {
            res = false;
        }

        return res;
    }

    // Validate email address domain - return true if ok for the environment
    public static Boolean isValidDomain(String email) {
    	Boolean domainOK = true;

    	// If we are running in production, domain can be anything, if sandbox, domain must be RH
    	Boolean isSandbox = [select IsSandbox from Organization].IsSandbox;
    	if (isSandbox) {
    		if (String.isNotBlank(email) && !email.toUpperCase().endsWith('@RH.COM') && !email.toUpperCase().endsWith('@RESTORATIONHARDWARE.COM')) {
    			domainOK = false;
    		}
    	}

    	return domainOK;
    }

    // Format 10 digit phone number
    public static String formatPhone10(String cphone) {

        String fphone = cphone;
        if (String.isNotBlank(fphone)) {
            String s = cphone.replaceAll('\\D',''); // strip out all non-digits
            if (s.length() == 10) {
                fphone = s.substring(0, 3) + '.' + s.substring(3, 6) + '.' + s.substring(6);
            }
        }
        return fphone;
    }

    // Convert the decimal dollar amount to an html string dollar amount
    public static String htmlDollarAmount(Decimal dAmt, Boolean zeroOk) {
        Decimal absAmt;
        String sAmt = '';
        String zeroZero = '';

        if (dAmt != null) {
            if (dAmt == 0) {
                if (zeroOk) {
                    //sAmt = '$' + String.valueOf(dAmt);
                    sAmt = '$0.00';
                }
            } else {
                absAmt = math.abs(dAmt);
                if ((absAmt * 10) - Decimal.valueOf((absAmt * 10).intValue()) == 0) {
                    zeroZero = '0';
                }
                if (absAmt - Decimal.valueOf(absAmt.intValue()) == 0) {
                    zeroZero = '.00';
                }

                if (dAmt < 0) {
                    sAmt = '<span style="color:#ff0000">($' + String.valueOf(absAmt.format()) + zeroZero + ')</span>';
                } else {
                    sAmt = '$' + String.valueOf(absAmt.format()) + zeroZero;
                }
            }
        }
        return sAmt;
    }

    public static Boolean isChanged(String fieldOldValue, String fieldNewValue){
      String oldval = (fieldOldValue == null) ? '': fieldOldValue;
      String newval = (fieldNewValue == null) ? '': fieldNewValue;
      if(oldval == newval){
         return false;
      }else{
         return true;
      }
   }

   public class RecordTypeNotFoundException extends Exception {}

   private static final Map<String,Map<String,Schema.RecordTypeInfo>> sObjectRecordTypes = new Map<String,Map<String,Schema.RecordTypeInfo>>();

    public static Id getRecordTypeId(SObjectType so, String recordTypeName) {
      if (so != null && recordTypeName != null && recordTypeName != '') {
        Schema.DescribeSObjectResult r = so.getDescribe();
        if (r != null && !sObjectRecordTypes.containsKey(r.getName())) {
          sObjectRecordTypes.put(r.getName(), r.getRecordTypeInfosByName());
        }

        Map<String, Schema.RecordTypeInfo> recTypeInfos = sObjectRecordTypes.get(r.getName());
        Schema.RecordTypeInfo recTypeInfo = recTypeInfos.get(recordTypeName);
        if (recTypeInfo != null){
           return recTypeInfo.getRecordTypeId();
        }
      }
      throw new RecordTypeNotFoundException('RecordType \'' + recordTypeName + '\' was not found for SObjectType \'' + so + '\'.');
    }

}