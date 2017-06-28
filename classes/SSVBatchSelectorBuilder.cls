public with sharing class SSVBatchSelectorBuilder {
	
	private Integer batchLimit = null; 
	private Datetime processingReadyTime; 
	private Boolean includeDuplicates = null;
	private String customFilter = null;
	private String processStatus = SSVSelector.PROCESSING_STATUS_READY;
	private boolean orderByMasterRecordScore = true;
	private List<String> fieldList = SSVSelector.getFieldList();
	
    
    public static String FILTER_LAST_NAME_AM 
    								= ' AND ('
									+ 'Last_Name__c LIKE \'A%\' OR Last_Name__c LIKE \'B%\' OR Last_Name__c LIKE \'C%\' OR Last_Name__c LIKE \'D%\' OR Last_Name__c LIKE \'E%\' OR Last_Name__c LIKE \'F%\' OR '
									+ 'Last_Name__c LIKE \'G%\' OR Last_Name__c LIKE \'H%\' OR Last_Name__c LIKE \'I%\' OR Last_Name__c LIKE \'J%\' OR Last_Name__c LIKE \'K%\' OR Last_Name__c LIKE \'L%\' OR '
									+ 'Last_Name__c LIKE \'M%\' '
									+ ') ';
									  								
	public static String FILTER_LAST_NAME_NZ 
									= ' AND ('
									+ 'Last_Name__c LIKE \'N%\' OR Last_Name__c LIKE \'O%\' OR Last_Name__c LIKE \'P%\' OR Last_Name__c LIKE \'Q%\' OR Last_Name__c LIKE \'R%\' OR Last_Name__c LIKE \'S%\' OR '
									+ 'Last_Name__c LIKE \'T%\' OR Last_Name__c LIKE \'U%\' OR Last_Name__c LIKE \'V%\' OR Last_Name__c LIKE \'W%\' OR Last_Name__c LIKE \'X%\' OR Last_Name__c LIKE \'Y%\' OR '
									+ 'Last_Name__c LIKE \'Z%\' '									
									+ ') ';	
																
																		
    public static String FILTER_LAST_NAME_AG 
    								= ' AND ('
									+ 'Last_Name__c LIKE \'A%\' OR Last_Name__c LIKE \'B%\' OR Last_Name__c LIKE \'C%\' OR Last_Name__c LIKE \'D%\' OR '
									+ 'Last_Name__c LIKE \'E%\' OR Last_Name__c LIKE \'F%\' OR Last_Name__c LIKE \'G%\' '
									+ ') ';
									
    public static String FILTER_LAST_NAME_HO 
    								= ' AND ('
    								+ 'Last_Name__c LIKE \'H%\' OR '
									+ 'Last_Name__c LIKE \'I%\' OR Last_Name__c LIKE \'J%\' OR Last_Name__c LIKE \'K%\' OR Last_Name__c LIKE \'L%\' OR '
									+ 'Last_Name__c LIKE \'M%\' OR Last_Name__c LIKE \'N%\' OR Last_Name__c LIKE \'O%\' '
									+ ') ';
  								
	public static String FILTER_LAST_NAME_PZ 
									= ' AND ('
									+ 'Last_Name__c LIKE \'P%\' OR Last_Name__c LIKE \'Q%\' OR '
									+ 'Last_Name__c LIKE \'R%\' OR Last_Name__c LIKE \'S%\' OR Last_Name__c LIKE \'T%\' OR Last_Name__c LIKE \'U%\' OR '
									+ 'Last_Name__c LIKE \'V%\' OR Last_Name__c LIKE \'W%\' OR Last_Name__c LIKE \'X%\' OR Last_Name__c LIKE \'Y%\' OR '
									+ 'Last_Name__c LIKE \'Z%\' '									
									+ ') ';										
	
	public SSVBatchSelectorBuilder withBatchLimit(Integer blimit) {
		this.batchLimit = blimit;
		return this;
	}
	public SSVBatchSelectorBuilder withProcessingReadyTime(Datetime pTime) {
		this.processingReadyTime = (pTime != null) ? pTime : Datetime.now();
		return this;
	}
	public SSVBatchSelectorBuilder withIncludingDuplicates(boolean include) {
		this.includeDuplicates = include;
		return this;
	}
	public SSVBatchSelectorBuilder withCustomFilter(String filter) {
		this.customFilter = filter;
		return this;
	}
	public SSVBatchSelectorBuilder withProcessStatus(String status) {
		this.processStatus = status;
		return this;
	}
	public SSVBatchSelectorBuilder withOrderByMasterRecordScoreOn(boolean orderOn) {
		this.orderByMasterRecordScore = orderOn;
		return this;
	}
	public SSVBatchSelectorBuilder withFieldList(List<String> fList) {
		this.fieldList = fList;
		return this;
	} 
	
    public String getBaseQuery() {

        String query = String.format('SELECT {0} ' 
                                    + ' FROM Source_System_View__c '
                                    + ' WHERE Processing_Ready_Time__c < {1} '
                                    + ' AND Is_Ready_For_Duplicate_Check__c = true '
                                , new List<String> {
                                    String.join(this.fieldList, ', '),
                                    this.processingReadyTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')
                                });

        return query;
    }	

	private String orderByMasterRecordScore() {
		return (orderByMasterRecordScore) ? ' ORDER BY Master_Record_Score__c DESC' : '';
	}    
	
	private String filterByProcessStatus() {
		return (this.processStatus != null) ? ' AND Processing_Status__c = \'' + this.processStatus +'\' ' : '';
	}
	
	private String filterByCustomFilter() {
		return (this.customFilter != null) ? this.customFilter : '';
	}
	
	private String filterByDuplicates() {
		if (this.includeDuplicates != null) {
			return (this.includeDuplicates == true) ? ' AND Duplicate_Set_ID__c != NULL ' : ' AND Duplicate_Set_ID__c = NULL ';
		}
		return '';
	}
	
	private String limitBatchSize() {
		return (this.batchLimit != null) ? ' LIMIT ' + this.batchLimit : '';		
	}
	
	public SSVBatchSelectorBuilder() {		
	}
	
	public String buildQuery() {
		String builtQuery =  this.getBaseQuery() 
								+ this.filterByProcessStatus()
								+ this.filterByCustomFilter()
								+ this.filterByDuplicates()
								+ this.orderByMasterRecordScore()
								+ this.limitBatchSize();
								
		system.debug('Query built:: ' + builtQuery);		
		return builtQuery;								
	}
	
}