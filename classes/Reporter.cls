/**
 *  Reporter.cls
 *  @description	Reporting layer used to centralize debugging
 *               	and error logging accross the system
 *  @author Ernesto Valdes, Salesforce.com + Traction On Demand
 */
public class Reporter {

	static final String STEWARDSHIP_REQUEST_ERROR_DESCRIPTION = '' +
			'The related Source System View record failed to generate a complete Single Customer ' + 
			'View record. The {0} record encountered a validation error on an {1} operation.\n' +
			'Error(s): {2}';
	@testVisible
	static final String INVALID_CALL_ERROR = 'Reporter has been passed invalid parameters. All lists must be of equal size.';
	static @testVisible Boolean logging = !Test.isRunningTest();
	static @testVisible Integer logCount = 1;

	static @testVisible List<Stewardship_Request__c> requests = new List<Stewardship_Request__c>();

	static @testVisible List<Error_Log__c> logs {
		get {
			if (logs == null) logs = new List<Error_Log__c>();
			return logs;
		}
		set;
	}

	public static void startLogging() {
		logging = true;
		system.debug(LoggingLevel.DEBUG, 'Starting Log ');
	}

	public static void stopLogging() {
		logging = false;
		system.debug(LoggingLevel.DEBUG, 'Stopping Log ');
	}

	public static void log(String logText) {
		if (logging) {
			system.debug(LoggingLevel.DEBUG, 'Log ' + logCount + ': ' + logText);
			logCount++;
		}
	}

	/**
	 * @description Creates error reports and stewardship requests on error
	 * @author John Rogers, Traction on Demand
	 * @date        2016-03-17
	 * @param       customers : SSVCustomer objects mapped to 'records' via index 
	 * @param       records : The records inserted into the database
	 * @param       results : The results of the DML call
	 */
	public static void integrationReport(List<SSVCustomer> customers, List<SObject> records, List<Database.SaveResult> results) {
		report(records, results);

		Boolean hasError = false;

		for (Database.SaveResult sr : results) {
			if (!sr.isSuccess()) { hasError = true; }}

		if (customers.size() != records.size() || records.size() != results.size()) {
			if (hasError) {
				logInvalidCall();
				return;
			} else {
				return;
			}
		}

		Integer count = 0;
		for (Database.SaveResult sr : results) {
			if (!sr.isSuccess()) { 
				SSVCustomer customer = customers[count];
				SObject obj = records[count];
				List<SSVCleansed> ssvCleansedList = new List<SSVCleansed> { customer.ssvCleansedMaster };
				ssvCleansedList.addAll(customer.ssvCleansedList);
				for (SSVCleansed ssvclean : ssvCleansedList) {
					if (!ssvclean.isNew()) {
						continue;
					}
					Stewardship_Request__c stew = createRequest(obj, sr);
					stew.Source_System_View__c = ssvclean.ssv.Id;
				}
			}
			count++;
		}
	}

	/**
	 * @description Creates error reports and stewardship requests on error
	 * @author John Rogers, Traction on Demand
	 * @date        2016-03-17
	 * @param       records : The inserted/updated records
	 * @param       results : The results of the DML call
	 */
	public static void integrationReport(List<SObject> records, List<Database.SaveResult> results) {
		if (records.size() != results.size()) {
			logInvalidCall();
			return;
		}

		report(records, results);

		// Create stewardship review requests
		Integer count = 0;
		for (Database.SaveResult sr : results) {
			if (!sr.isSuccess()) {
				SObject record = records[count];
				Stewardship_Request__c stew = createRequest(record, sr);
				if (record.getSObjectType() == Source_System_View__c.getSObjectType()) {
					stew.Source_System_View__c = record.Id;
				} else if (record.getSObjectType() == RH_Order__c.getSObjectType()) {
					stew.Source_Order__c = record.Id;
				} else if (record.getSObjectType() == Ship_To__c.getSObjectType()) {
					stew.Source_Ship_To__c = record.Id;
				}
			}
			count++;
		}
	}

	/**
	 * @description Creates a stewardship request for the given failed DML
	 * record, and adds request to 'requests' property
	 * @author John Rogers, Traction on Demand
	 * @date        2016-03-17
	 * @param       record : The DML fail record
	 * @param       sr : The DML save result
	 * @return The stewardship request
	 */
	public static Stewardship_Request__c createRequest(SObject record, Database.SaveResult sr) {
		String operation = record.Id == null ? 'insert' : 'update';
		String description = String.format(
			STEWARDSHIP_REQUEST_ERROR_DESCRIPTION,
			new List<String> {
				record.getSObjectType().getDescribe().getName(),
				operation,
				JSON.serializePretty(sr.getErrors())
			}
		);

		String type = operation == 'insert' ? 
			'System Detected Record Creation Error' : 
			'System Detected Record Update Error';
		Stewardship_Request__c stew = new Stewardship_Request__c(
			Description__c = description,
			RecordTypeId = StewardshipRequests.SSV_RECORD_TYPE_ID,
			Request_Type__c = type
		);
		requests.add(stew);
		return stew;
	}

	/**
	 * @description Add records to the error log list if needed
	 * @author John Rogers, Traction on Demand
	 * @date        2016-03-17
	 * @param       records : DML operation records
	 * @param       results : DML operation results
	 */
	public static void report(List<SObject> records, List<Database.DeleteResult> results) {
		report(records, DatabaseResultHolder.createHolders(results));
	}

	/**
	 * @description Add records to the error log list if needed
	 * @author John Rogers, Traction on Demand
	 * @date        2016-03-17
	 * @param       records : DML operation records
	 * @param       results : DML operation results
	 */
	public static void report(List<SObject> records, List<Database.SaveResult> results) {
		report(records, DatabaseResultHolder.createHolders(results));
	}

	/**
	 * @description Add records to the error log list if needed
	 * @author John Rogers, Traction on Demand
	 * @date        2016-03-17
	 * @param       records : DML operation records
	 * @param       results : DML operation results
	 */
	public static void report(List<SObject> records, List<DatabaseResultHolder> results) {
		if (records.size() != results.size()) {
			logInvalidCall();
			return;
		}

		/*
		NOTE:
			getStackTraceString has issues in Spring 16
			https://success.salesforce.com/issues_view?id=a1p300000008dVIAAY
		 */
		String stackTrace = (new ReporterException()).getStackTraceString();
		Integer count = 0;

		for (DatabaseResultHolder result : results) {
			if (!result.isSuccess()) {
				for (Database.Error e : result.getErrors()) {
					logs.add(new Error_Log__c(
						Record__c = JSON.serializePretty(records[count]),
						Type__c = 'DML ERROR',
						Message__c = e.getMessage() + '\nSTATUSCODE:' + e.getStatusCode() + '\nFIELDS:' + e.getFields(),
						Stack_Trace__c = stackTrace
					));

					log(e.getMessage());
				}
			}
			count++;
		}
	}

	public static void report(List<Database.SaveResult> results) {
		for (Database.SaveResult sr : results) {
			if (!sr.isSuccess()) {
				for (Database.Error err : sr.getErrors()) {
					report(err);
				}
			}
		}
	}

	public static void report(Exception e) {

		if (logging && e != null) {

			logs.add(new Error_Log__c(
				Type__c = 'APEX RUNTIME ERROR',
				Message__c = e.getMessage(),
				Stack_Trace__c = e.getStackTraceString()
			));

			log(e.getMessage());
		}
	}

	public static void report(Database.Error e) {
		if (logging && e != null) {

			logs.add(new Error_Log__c(
				Type__c = 'DML ERROR',
				Message__c = e.getMessage(),
				Stack_Trace__c = e.getStatusCode() + ':' + e.getFields()
			));

			log(e.getMessage());
		}
	}

	public static void report(String message) {
		if (logging && message != null) {

			logs.add(new Error_Log__c(
				Type__c = 'INTEGRATION ERROR',
				Message__c = message
				));

			log(message);
		}
	}

	public static void createErrorLogs() {
		insert requests;
		requests.clear();
		insert logs;
		logs.clear();
	}

	private static void logInvalidCall() {
		logs.add(new Error_Log__c(
			Type__c = 'APEX RUNTIME ERROR',
			Message__c = INVALID_CALL_ERROR,
			Stack_Trace__c = (new ReporterException()).getStackTraceString()
		));
	}

	public class ReporterException extends Exception { }
}