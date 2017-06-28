Global class BatchUpdateProductPrice implements Database.Batchable<sObject> {
	
	/*
	 *	Update the price of all Products in the Standard Pricebook.
	 *	For each Product, copy the field "Direct Original Price" to its associated PricebookEntry UnitPrice
	 *	in the Standard Pricebook.  If there is no PricebookEntry for the Product, create one.
	 *
	 */
	
	public String buppQueryString;
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(buppQueryString);
	}
	
	global void execute(Database.BatchableContext BC, List<Product2> records) {
		
		Id standardPBId = '01s50000000A5kHAAS';
		List<PricebookEntry> pbeList = new List<PricebookEntry>();
		List<PricebookEntry> pbeUpList = new List<PricebookEntry>();
		Map<Id, PricebookEntry> pbeMap = new Map<Id, PricebookEntry>();
		List<Id> pIds = new List<Id>();
		
		system.debug('*****BatchUpdateProductPrice:  query string = ' + buppQueryString);
		system.debug('*****BatchUpdateProductPrice:  total number of Product records to process = ' + records.size());
		
		for (Product2 p :records) {
			pIds.add(p.Id);
		}
		
		if (!pIds.isEmpty()) {
			pbeList = [select Id, Product2Id, UnitPrice from PricebookEntry where Pricebook2Id = :standardPBId and CurrencyIsoCode = 'USD' and Product2Id in :pIds];
			for (PricebookEntry pbe :pbeList) {
				pbeMap.put(pbe.Product2Id, pbe);
			}
			
			Integer pbeUpdateCount = 0;
			Integer pbeCreateCount = 0;
			for (Product2 p :records) {
				if (pbeMap.containsKey(p.Id)) {
					pbeMap.get(p.Id).UnitPrice = p.Direct_Original_Price__c;
					pbeUpList.add(pbeMap.get(p.Id));
					pbeUpdateCount++;
				} else {
					pbeUpList.add(new PricebookEntry(
						IsActive = p.IsActive,
						CurrencyIsoCode = 'USD',
						UnitPrice = p.Direct_Original_Price__c,
						Pricebook2Id = standardPBId,
						Product2Id = p.Id)
					);
					pbeCreateCount++;
				}
			}
			system.debug('*****BatchUpdateProductPrice:  total number of PBE records to create/update = ' + pbeUpList.size() + ', total new = ' + pbeCreateCount + ', total updated = ' + pbeUpdateCount);
			
			if (!pbeUpList.isEmpty()) {
				upsert pbeUpList;
			}
		}
	}
	
    global void finish(Database.BatchableContext BC) {
    	
		// Get the status of the batch job just completed
		AsyncApexJob a = [select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =: BC.getJobId()];
		
		// Send an email to the Apex job's submitter notifying of job completion. 
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		List<String> toAddresses = new List<String>();
		toAddresses.add('salesforce@restorationhardware.com');
		mail.setToAddresses(toAddresses);
		mail.setSubject('BatchUpdateProductPrice Status: ' + a.Status);
		mail.setPlainTextBody('The batch Apex job BatchUpdateProductPrice processed ' + a.TotalJobItems + ' batches with ' + a.NumberOfErrors + ' failures.');
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}