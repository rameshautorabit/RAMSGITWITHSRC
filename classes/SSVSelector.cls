/**
 *  SSVSelector.cls
 *  @description Selector class for Source System View
 *               Provides the ability to centralize and reuse queries
 *  @author Ernesto Valdes, Traction On Demand
 */
public with sharing class SSVSelector {

	public static String PROCESSING_STATUS_READY = 'Ready for Match Step';
	public static String PROCESSING_ORDER_LINK_READY = 'Ready for Order Linking';
	public static String PROCESSING_STATUS_COMPLETE = 'Processing Complete';

	private static Set<Schema.SObjectField> fields = new Set<Schema.SObjectField>{
		Source_System_View__c.Id,
		Source_System_View__c.Duplicate_Set_ID__c,
		Source_System_View__c.Is_Ready_For_Duplicate_Check__c,
		Source_System_View__c.Processing_Status__c,
		Source_System_View__c.Processing_Ready_Time__c,
		Source_System_View__c.EXT_Source_System_Customer_ID__c,
		Source_System_View__c.Source_System_View_CW_Company__c,
		Source_System_View__c.Account__c,
		Source_System_View__c.Contact__c,
		Source_System_View__c.Customer_Address__c,
		Source_System_View__c.Company_Name__c,
		Source_System_View__c.First_Name__c,
		Source_System_View__c.Last_Name__c,
		Source_System_View__c.Email__c,
		Source_System_View__c.Day_Phone__c,
		Source_System_View__c.Alternative_Phone__c,
		Source_System_View__c.Address_1__c,
		Source_System_View__c.Address_2__c,
		Source_System_View__c.City__c,
		Source_System_View__c.State__c,
		Source_System_View__c.Zip__c,
		Source_System_View__c.Country__c,
		Source_System_View__c.Country_Code__c,
		Source_System_View__c.Cleansed_First_Name__c,
		Source_System_View__c.Cleansed_Last_Name__c,
		Source_System_View__c.Cleansed_Company_Name__c,
		Source_System_View__c.Email_Match_Key__c,
		Source_System_View__c.Day_Phone_Match_Key__c,
		Source_System_View__c.Address_Match_Key__c,
		Source_System_View__c.Address_Match_Key_Hash__c,
		Source_System_View__c.Match_Type__c,
		Source_System_View__c.Master_Record_Score__c,
		Source_System_View__c.Trade_ID__c,
		Source_System_View__c.Membership_Number__c,
		Source_System_View__c.Fraud_Warning__c		
	};
	
	public static List<String> getFields() {
		List<String> fieldList = new List<String>();
		for (Schema.SObjectField field : fields) {
			fieldList.add(String.valueOf(field));
		}
		return fieldList;		
	}

	public static List<String> getFieldList() {
		List<String> fieldList = getFields();
		fieldList.add('Source_System_View_CW_Company__r.Duplicate_Set_ID__c');
		fieldList.add('Source_System_View_CW_Company__r.Account__c');
		fieldList.add('Account__r.RecordTypeId');
		return fieldList;
	}
	
    public static String getBatchSyncQuery(Integer batchLimit, Datetime processingReadyTime) {

        String query = String.format('SELECT {0} ' 
                                    + 'FROM Source_System_View__c '
                                    + 'WHERE Processing_Ready_Time__c < {1} '
                                    + 'AND Is_Ready_For_Duplicate_Check__c = true '                                    
                                    + 'AND Processing_Status__c = :PROCESSING_STATUS_READY '
                                    + 'ORDER BY Master_Record_Score__c DESC '
                                    + ((batchLimit != null) ? ('LIMIT ' + batchLimit) : '')
                                , new List<String> {
                                    String.join(getFieldList(), ', '),
                                    processingReadyTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')
                                });

        return query;
    }

	public static List<Source_System_View__c> getExistingSSVByDuplicateSetId(Set<String> duplicateSetIds) {

		String query = String.format('SELECT {0} ' 
									+ ' FROM Source_System_View__c '
									+ ' WHERE Duplicate_Set_ID__c IN :duplicateSetIds '
									+ ' AND (Processing_Status__c = :PROCESSING_STATUS_COMPLETE '
									+ '		OR Processing_Status__c = :PROCESSING_ORDER_LINK_READY) '
									+ ' AND Is_Ready_For_Duplicate_Check__c = true '
									+ ' ORDER BY Master_Record_Score__c DESC'
								, new List<String> {String.join(getFieldList(), ', ')});

		return Database.query(query);

	}

	public static List<Source_System_View__c> getSSVsByDuplicateSetIdAndExcludeRecordIds(
		Set<String> duplicateSetIds,
		Set<Id> excludedRecordIds) {

		// exclude following to improve performance
		// + ' AND (Account__c != null OR Contact__c != null)'
		
		String query = String.format('SELECT {0} ' 
									+ ' FROM Source_System_View__c '
									+ ' WHERE Duplicate_Set_ID__c IN :duplicateSetIds '
									+ ' AND (Processing_Status__c = :PROCESSING_STATUS_COMPLETE '
									+ '		OR Processing_Status__c = :PROCESSING_ORDER_LINK_READY) '
									+ ' AND Is_Ready_For_Duplicate_Check__c = true '
									+ ' AND Id NOT IN :excludedRecordIds'									
									+ ' ORDER BY Master_Record_Score__c DESC'
								, new List<String> {String.join(getFieldList(), ', ')});

		return Database.query(query);

	}

	public static List<Source_System_View__c> getSSVsById(Set<Id> recordIds) {

		String query = String.format('SELECT {0} ' 
									+ 'FROM Source_System_View__c '
									+ 'WHERE Id IN :recordIds'
								, new List<String> {String.join(getFieldList(), ', ')});

		return Database.query(query);
	}


	public static List<Source_System_View__c> getSSVsByConsolidationKey(Set<String> keys, Set<Id> excludedRecordIds) {

		String query = String.format('SELECT {0} ' 
									+ 'FROM Source_System_View__c '
									+ 'WHERE Duplicate_Set_ID__c IN :keys'
									+ 'AND Id NOT IN :excludedRecordIds'
								, new List<String> {String.join(getFieldList(), ', ')});

		return Database.query(query);
	}
}