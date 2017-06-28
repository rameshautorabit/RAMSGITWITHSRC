/************************************************/
/*                                              */
/* This class contains 1-off utility functions  */
/* such as sending email notifications          */
/*                                              */
/************************************************/

public class UtilityFunctions 
{
	// This is the custom Log Class used to write records to the custom Log__c table
    public class logEntry
    {
    	public Id targetRecordId;
    	public String script;
    	public String message;
    }
    
    // Conducts a Database.Insert method and processes errors accordingly
    public static List<Database.Saveresult> databaseInsert (List<SObject> sObjects, boolean bool, String script)
    {
    	// Declare local variables
    	List<UtilityFunctions.logEntry>	logentries = new List<UtilityFunctions.logEntry>(); // A list of logentries to be added
    	List<Database.Saveresult> 		lsr = new List<Database.Saveresult>(); // The SaveResult array to be returned
    	
    	// Conduct the insert method
    	lsr = Database.insert(sObjects, bool);
    	
    	// Loop through the records processing errors
    	for (integer i = 0; i < lsr.size(); i++)
    	{
    		if (!lsr[i].isSuccess())
    		{
    			UtilityFunctions.logEntry le = new UtilityFunctions.logEntry();
    			le.targetRecordId = sObjects[i].Id;
    			le.script = script;
    			le.message = 'Insert failed: ';
    			
    			// Loop through the error messages adding them to the list
    			for (Database.error de : lsr[i].getErrors())
    			{
    				le.message += de.getMessage() + '; \n\r';
    			}
    			
   				System.debug('Error inserting records: ' + le.message);
   				
    			logentries.add(le);
    		}
    		
    	} // END LOOP through the records processing errors
    	
    	// Write the Log entries to the database
    	UtilityFunctions.writeLog(logentries);
    	
    	// Return the SaveResults
    	return lsr;
    }
    
    // Conducts a Database.Upsert method and processes errors accordingly
    public static List<Database.Saveresult> databaseUpdate (List<SObject> sObjects, boolean bool, String script)
    {
    	// Declare local variables
    	List<UtilityFunctions.logEntry>	logentries = new List<UtilityFunctions.logEntry>(); // A list of logentries to be added
    	List<Database.Saveresult> 		lsr = new List<Database.Saveresult>(); // The SaveResult array to be returned
    	
    	// Conduct the update method
    	lsr = Database.update(sObjects, bool);
    	
    	// Loop through the records processing errors
    	for (integer i = 0; i < lsr.size(); i++)
    	{
    		if (!lsr[i].isSuccess())
    		{
    			UtilityFunctions.logEntry le = new UtilityFunctions.logEntry();
    			le.targetRecordId = sObjects[i].Id;
    			le.script = script;
    			le.message = 'Update failed: ';
    			
    			// Loop through the error messages adding them to the list
    			for (Database.error de : lsr[i].getErrors())
    			{
    				le.message += de.getMessage() + '; \n\r';
    			}
    			
   				System.debug('Error updating records: ' + le.message);
   				
    			logentries.add(le);
    		}
    		
    	} // END LOOP through the records processing errors
    	
    	// Write the Log entries to the database
    	UtilityFunctions.writeLog(logentries);
    	
    	// Return the SaveResults
    	return lsr;
    }
    
    // These methods are used for sending email notifications when various conditions arise - usually errors
    // The methods are polymorphic depending on the information required in the Email.
    
    // Email a simple debug line
    public static void sendEmail(String body)
    {
    	sendEmail('RH Software debug', body);
    }
    
    // Email a simple debug line with a customizeable Subject line
    public static void sendEmail(String subject, String body)
    {
    	sendEmail(subject + 'From RH', body, 'marc.friedman@cadalys.com');
    }
    
    // Email a simple debug line with a customizeable Subject line and To Address
    public static void sendEmail(String subject, String body, String toAddress)
    {
    	if(subject != null && body != null && toAddress != null)
    	{
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	        String[] toAddresses = new String[] {toAddress};
	        mail.setToAddresses(toAddresses);
	        String[] bccAddresses = new String[] {'marc.friedman@cadalys.com','tgibson@restorationhardware.com'};
	        mail.setBccAddresses(bccAddresses);
	        mail.setSubject(subject);
	        mail.setPlainTextBody(body);
	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    	}
    }
    
    // Email a simple debug line with a customizeable Subject line and multiple To Addresses
    public static void sendEmail(String subject, String body, String[] toAddresses)
    {
    	if(subject != null && body != null && toAddresses != null && toAddresses.size() > 0)
    	{
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	        mail.setToAddresses(toAddresses);
	        String[] bccAddresses = new String[] {'marc.friedman@cadalys.com','tgibson@restorationhardware.com'};
	        mail.setBccAddresses(bccAddresses);
	        mail.setSubject(subject);
	        mail.setPlainTextBody(body);
	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    	}
    }

    // Writes a single string to the custom Log table
    public static void writeLog (String script, String message)
    {
    	// Get the Custom Setting to determine whether Custom Logging is enabled. Default is "on".
    	map<String, Application_Settings__c> appSettings = Application_Settings__c.getAll();
    	System.debug('Application Settings: ' + appSettings);
    	
    	if (appSettings.size() == 0)
    	{ 
    		if (!appSettings.containsKey('EnableCustomLogging') || appSettings.get('EnableCustomLogging').Value_Text__c != 'True')
    		{
   				Log__c l = new Log__c (Script_Event__c = script, Log_Message__c = message);
   				insert l;
    		}
    	}
    }
    
    // Writes multiple records to the custom Log table
    public static void writeLog (List <logEntry> logentries)
    {
    	// Declare local variables
    	List <Log__c>	logRecords = new List<Log__c>(); // A List of Log records to be inserted
    	
    	// If there are records to process then do so
    	if (logentries.size() > 0)
    	{
    		// Loop through the list creating the entry
    		for (logEntry le : logentries)
    		{
    			Log__c l = new Log__c (Target_Record_Id__c = le.targetRecordId, Script_Event__c = le.script,
    				Log_Message__c = le.message);
    			logRecords.add(l);
    			
    		} // END LOOP through the list creating the entry
    		
    		// Insert the log records
    		Database.SaveResult[] lsr = Database.Insert (logRecords, false);
    		
    		// Loop through the Save Result looking for errors
    		for (Database.Saveresult sr : lsr)
    		{
    			// If the record failed then email the error
    			if (!sr.IsSuccess())
    			{
    				// Email any errors
    				sendEmail('UtilityFunctions.writeLog', sr.getErrors()[0].getMessage(), 'marc.friedman@cadalys.com');
    				
    			} // END IF the record failed then email the error
    			
    		} // END LOOP through the Save Result looking for errors
    		
    	} // END IF there are records to process then do so
    }
    
    // Emails errors from an Exception object to a single To Address
    public static Boolean sendError(Exception e, String toAddress)
    {
    	Boolean retVal = true;
    	
		String body = '';
		body += 'Type: ' + e.getTypeName() + '\n';
		body += 'Message: ' + e.getMessage() + '\n';
		body += 'Line: ' + e.getLineNumber() + '\n';
		body += 'Stack: ' + e.getStackTraceString() + '\n';
				
		sendEmail('Error from Salesforce at RH', body, toAddress);
		
		return retVal;
    }

	// For emailing errors with the offending Script in the subject line
    public static Boolean sendError(String subject, Exception e, String[] toAddress)
    {
    	Boolean retVal = true;
    	
		String body = '';
		body += 'Type: ' + e.getTypeName() + '\n';
		body += 'Message: ' + e.getMessage() + '\n';
		body += 'Line: ' + e.getLineNumber() + '\n';
		body += 'Stack: ' + e.getStackTraceString() + '\n';
				
		sendEmail('Error from Salesforce at RH' + subject, body, toAddress);
		
		return retVal;
    }

    // Emails an Exception to a default error recipient
    public static Boolean sendError(Exception e)
    {
		return sendError(e, 'marc.friedman@cadalys.com');
    }
    
    // Creates the SELECT portion of a SOQL statement for a given SObject. Excludes fields in the excludedFields array. Also excludes known legacy artifacts
    // that should never be returned
    public static string generateSelect(String sObjectName, Set<String> excludedFields)
    {
    	Map<String, Schema.SObjectField>    sObjectFields = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
        String								query = 'SELECT';
        
        // Add known artifacts to the excludedFields
        excludedFields.add('jigsaw');
        excludedFields.add('jigsawcompanyid');
        excludedFields.add('jigsawcontactid');
        
        // Loop through the SObject fields constructing the SELECT statement, excluding fields in the excludedFields array as well as known legacy artifacts.
        for (String s : sObjectFields.keySet()) {
            if (!excludedFields.contains(s))
            {
            	query += ' ' + s + ',';
            }
            
        } // END LOOP through the SObject fields constructing the SELECT statement, excluding fields in the excludedFields array.
        
        // Remove the trailing comma from the query
        if (query.subString(query.Length()-1,query.Length()) == ',')
        {
            query = query.subString(0, query.Length()-1);
        }
        
        // Return the completed string
        return query;
    } 
}