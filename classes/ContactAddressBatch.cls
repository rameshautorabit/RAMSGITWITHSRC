global class ContactAddressBatch implements Database.Batchable<sObject> {
	
	/*
	 * Batch Parameters
	 */
 	
	public Integer[] jobList;
	public Integer currentIndex;
	public List<String> jobQueries;
	public Boolean scheduleAgain;
	public Integer queryLimit;
	public Integer batchSize {get;set;}
	

	/*
	 * Helper methods
	 * Allows you to enqueue the batch job directly (without scheduling it)
	 */
	
	public Static Id executeFullBatch(Boolean schedule, Integer batchSize) {
		system.debug('ContactAddressBatch -> executeFullBatch -> enqueue batch job 0 with full job list');
		return Database.executeBatch(new ContactAddressBatch(new List<Integer>{0,1,2,3}, 0, batchSize, schedule, false, null), batchSize);	
	} 	

	public Static Id executeAddressBatch(Boolean schedule, Integer batchSize) {
		system.debug('ContactAddressBatch -> executeAddressBatch -> enqueue batch job 0 with address job list');
		return Database.executeBatch(new ContactAddressBatch(new List<Integer>{1,2,3}, 0, batchSize, schedule, false, null), batchSize);	
	} 	

	/*
	 * Constructor
	 */
	 
	public ContactAddressBatch() {
		// used just for cloning		
	}
	
	public ContactAddressBatch(Integer[] toToList, Integer currentIndex, Integer batch, Boolean schedule, Boolean allRecords, Integer queryLimit) {
        system.debug('ContactAddressBatch -> Instantiate Contact Address Batch job: ' + currentIndex);
        this.jobList = toToList;
		this.currentIndex = currentIndex;
		this.batchSize = batch;
		this.scheduleAgain = schedule;
		this.jobQueries = new List<String>{
			buildCustomerQuery(allRecords, queryLimit), buildSoldToOrderQuery(allRecords, queryLimit), buildBillToOrderQuery(allRecords, queryLimit), buildShipToQuery(allRecords, queryLimit) 
		};
	}  
	
	public static ContactAddressBatch clone(ContactAddressBatch rhs, Integer currentIndex) {
		ContactAddressBatch cab = new ContactAddressBatch();
		cab.jobList = rhs.jobList;
		cab.currentIndex = currentIndex;
		cab.jobQueries = rhs.jobQueries;
		cab.scheduleAgain = rhs.scheduleAgain;
		cab.queryLimit = rhs.queryLimit;
		cab.batchSize = rhs.batchSize;		
		return cab;
	}
	
	/*
	 * Queries specific to each job 
	 */
    
    global static String buildShipToQuery(Boolean allRecords, Integer queryLimit) {
    	return 'SELECT' +
			' CONTACT_SHIP_TO__c, ' +    
			' Order__r.Contact_Sold_To__c, ' +
			' Address_Ship_To__c, ' +
			' Ship_to_First_Name__c, ' +  
			' Ship_to_Last_Name__c, ' +
			' Ship_to_Company__c, ' +
			' Ship_to_Address_1__c, ' +
			' Ship_to_Address_2__c, ' +
			' Ship_to_City__c, ' +
			' Ship_to_Country__c, ' +
			' SHIP_TO_STATE__c, ' +
			' SHIP_TO_ZIP__c, ' +
			' Ship_to_Day_Phone__c, ' +
			' Ship_to_Night_Phone__c, ' +
			' Ship_to_Email__c  ' +
			' FROM Ship_To__c ' +
			' WHERE Order__r.Contact_Sold_To__c != null ' +
			' AND Address_Ship_To__c = NULL' + 
			(allRecords ? '' : ' AND SystemModStamp = LAST_N_DAYS:1') +
			' ORDER BY CreatedDate DESC' +
			(queryLimit == null ? '' : ' LIMIT ' + String.valueOf(queryLimit));
    }
    
    global static String buildSoldToOrderQuery(Boolean allRecords, Integer queryLimit) {
    	return 
    		'SELECT' +
    		' Contact_Sold_To__c, ' + 
			' Address_Sold_To__c, ' + 
			' Address_Bill_To__c, ' +
			' SOLD_TO_FIRST_NAME__c, ' +  
			' SOLD_TO_LAST_NAME__c, ' +
			' SOLD_TO_Company__c, ' +
			' SOLD_TO_ADDRESS_1__c, ' +
			' Sold_to_Address_2__c, ' +
			' SOLD_TO_CITY__c, ' +
			' SOLD_TO_COUNTRY_CODE__c, ' +
			' SOLD_TO_COUNTRY__c, ' +
			' SOLD_TO_STATE__c, ' +
			' SOLD_TO_ZIP__c, ' +
			' SOLD_TO_DAY_PHONE__c, ' +
			' SOLD_TO_NIGHT_PHONE__c, ' +
			' SOLD_TO_EMAIL__c ' +
			' FROM Rh_Order__c ' +
			' WHERE Contact_Sold_To__c != null ' + 
			' AND Address_Sold_To__c = NULL ' + 
			(allRecords ? '' : ' AND SystemModStamp = LAST_N_DAYS:1') +
			' ORDER BY CreatedDate DESC' +
			(queryLimit == null ? '' : ' LIMIT ' + String.valueOf(queryLimit));
    }
    			
    global static String buildBillToOrderQuery(Boolean allRecords, Integer queryLimit) {
    	return 
    		'SELECT' +
    		' Contact_Sold_To__c, ' + 
			' Address_Sold_To__c, ' + 
			' Address_Bill_To__c, ' +			
			' BILL_TO_FIRST_NAME__c, ' +  
			' BILL_TO_LAST_NAME__c, ' +
			' Bill_To_Company__c, ' +
			' BILL_TO_ADDRESS_1__c, ' +
			' BILL_to_Address_2__c, ' +
			' BILL_TO_CITY__c, ' +
			' BILL_TO_COUNTRY__c, ' +
			' BILL_TO_STATE__c, ' +
			' BILL_TO_ZIP__c, ' +
			' BILL_TO_DAY_PHONE__c, ' +
			' BILL_TO_NIGHT_PHONE__c, ' +
			' BILL_TO_EMAIL__c, ' +
			' SOLD_TO_EMAIL__c ' +			    							
			' FROM Rh_Order__c ' +
			' WHERE Contact_Sold_To__c != null ' + 
			' AND Address_Bill_To__c = NULL ' +
			' AND Bill_To_Address_1__c != NULL ' + 
			(allRecords ? '' : ' AND SystemModStamp = LAST_N_DAYS:1') +
			' ORDER BY CreatedDate DESC' +
			(queryLimit == null ? '' : ' LIMIT ' + String.valueOf(queryLimit));
    }
    
    global static String buildCustomerQuery(Boolean allRecords, Integer queryLimit) {
    	return 
    		'SELECT' +
    		' Contact_Sold_To__c, ' + 
			' Address_Sold_To__c, ' + 
			' Address_Bill_To__c, ' +
			' SOLD_TO_FIRST_NAME__c, ' +  
			' SOLD_TO_LAST_NAME__c, ' +
			' Sold_to_Company__c, ' +
			' SOLD_TO_ADDRESS_1__c, ' +
			' Sold_to_Address_2__c, ' +
			' SOLD_TO_CITY__c, ' +
			' SOLD_TO_COUNTRY_CODE__c, ' +
			' SOLD_TO_COUNTRY__c, ' +
			' SOLD_TO_STATE__c, ' +
			' SOLD_TO_ZIP__c, ' +
			' SOLD_TO_DAY_PHONE__c, ' +
			' SOLD_TO_NIGHT_PHONE__c, ' +
			' SOLD_TO_EMAIL__c, ' +
			' BILL_TO_FIRST_NAME__c, ' +  
			' BILL_TO_LAST_NAME__c, ' +
			' Bill_To_Company__c, ' +
			' BILL_TO_ADDRESS_1__c, ' +
			' BILL_to_Address_2__c, ' +
			' BILL_TO_CITY__c, ' +
			' BILL_TO_COUNTRY__c, ' +
			' BILL_TO_STATE__c, ' +
			' BILL_TO_ZIP__c, ' +
			' BILL_TO_DAY_PHONE__c, ' +
			' BILL_TO_NIGHT_PHONE__c, ' +
			' BILL_TO_EMAIL__C, ' +    			
			' FRAUD_WARNING__C ' +    							
			' FROM Rh_Order__c ' +
			' WHERE Contact_Sold_To__c = null ' +
			(allRecords ? '' : ' AND SystemModStamp = LAST_N_DAYS:1') +
			' ORDER BY CreatedDate DESC' +
			(queryLimit == null ? '' : ' LIMIT ' + String.valueOf(queryLimit)); 
    }
    
    /*
     * Start the job. 
     */
    
    global Database.QueryLocator start(Database.BatchableContext jobId) {
		system.debug('ContactAddressBatch -> start -> batch process: ' + jobQueries[this.jobList[this.currentIndex]]);		
    	return Database.getQueryLocator(jobQueries[this.jobList[this.currentIndex]]); 
    }    
    
    /*
     * Execute the batch
     * Depending on the records, build contact address records for orders, or for ship-to
     */

    global void execute(Database.BatchableContext jobId, List<sObject> scope) {
    	Integer currentJob = this.jobList[this.currentIndex];
    	system.debug('ContactAddressBatch -> execute -> process current job: ' + currentJob);
        ContactAddressBatch.processRecords(currentJob, scope);
    }

    
    /*
     * Finish processing the batch
     * If just processed orders, process ship-to, otherwise finish
     */

    global void finish(Database.BatchableContext BC) {
    	system.debug('ContactAddressBatch -> finished: ' + this.currentIndex);
    	if (this.currentIndex < this.jobList.size()-1) {
    		system.debug('ContactAddressBatch -> move to next batch job');
			Database.executeBatch(ContactAddressBatch.clone(this, this.currentIndex+1), this.batchSize);
		} else if (scheduleAgain) {
			system.debug('ContactAddressBatch -> finished, fire this off again in 2 minutes');
			Utility.scheduleJobAt(
				new ContactAddressBatchScheduler(ContactAddressBatch.clone(this, 0)), 
				'Contact Address Batch Job', 
				Utility.buildCronExpression(2)
			);
		} else {
			system.debug('ContactAddressBatch -> finished -> not scheduled to repeat');
		}  			
    }
    
    /*
     * Process records - do the actual work
     */
         
    global static void processRecords(Integer currentJob, List<sObject> records) {
        try {
        	
        	if (records == null || records.size() < 0) {
        		system.debug('ContactAddressBatch -> processRecords-> no reccords found to process');
        		return;
        	}
        	
			if (currentJob == 0) {
        		system.debug('ContactAddressBatch -> processRecords -> generate missing customers');
        		Utility.logUpdate(ContactAddressMergeService.buildCustomerForOrders((List<Rh_Order__c>)records));		
        	} else if (currentJob == 1) {
        		system.debug('ContactAddressBatch -> processRecords -> generate order missing sold-to contact address records');
        		List<Rh_Order__c> updatedOrders = ContactAddressService.buildAddressForOrders((List<Rh_Order__c>)records, ContactAddressService.ORDER_ADDRESS_TYPE.SOLD_TO);        		
        		system.debug('ContactAddressBatch -> processRecords -> update effected Contact Address records');
        		Utility.logUpdate(ContactAddressService.updateSoldToContactAddressUsage(updatedOrders));
        		system.debug('ContactAddressBatch -> processRecords -> update affected Order records');        		
        		Utility.logUpdate(updatedOrders);
        		system.debug('ContactAddressBatch -> processRecords -> fix the sold-to email issue (hack alert)');
        		Utility.logUpdate(ContactAddressService.fixSoldToEmailIssue(updatedOrders));
        	} else if (currentJob == 2) {        		
        		system.debug('ContactAddressBatch -> processRecords -> generate order missing bill-to contact address records');
        		List<Rh_Order__c> updatedOrders = ContactAddressService.buildAddressForOrders((List<Rh_Order__c>)records, ContactAddressService.ORDER_ADDRESS_TYPE.BILL_TO);
        		system.debug('ContactAddressBatch -> processRecords -> update effected Contact Address records');
        		Utility.logUpdate(ContactAddressService.updateBillToContactAddressUsage(updatedOrders));
        		system.debug('ContactAddressBatch -> processRecords -> update affected Order records');
        		Utility.logUpdate(updatedOrders);        		
			} else if (currentJob == 3) {
        		system.debug('ContactAddressBatch -> processRecords -> generate ship-to missing contact address records');
        		List<Ship_To__c> updatedShipTos = ContactAddressService.buildAddressForShipTos((List<Ship_To__c>)records);
        		system.debug('ContactAddressBatch -> processRecords -> update effected Contact Address records');        		
        		Utility.logUpdate(ContactAddressService.updateShipToContactAddressUsage(updatedShipTos));
        		system.debug('ContactAddressBatch -> processRecords -> update affected Ship-To records');
        		Utility.logUpdate(updatedShipTos);
        	} else {
        		system.debug('ContactAddressBatch -> processRecords -> invalid job number -> ' + currentJob);
        	}        	
        	
        } catch (Exception ex) {
			Utility.logException(ex, records);
        }
    }     
    
}