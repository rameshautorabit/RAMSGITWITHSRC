trigger SyncQLI_OLI_on_QLI_AfterUpdate on QuoteLineItem (after update) {
/*
    List<OpportunityLineItem>           lstOLI = new List<OpportunityLineItem>();
    Map<String, OpportunityLineItem>    mapOLI = new Map<String, OpportunityLineItem>(); // hold opportunity Line items
    Map<String, QuoteLineItem>          mapQLI = new Map<String, QuoteLineItem>(); // hold Quote Line items 
    Map<id,id>                          mapOppQuoteId = new Map<id,id>();    
    Map<Id, Quote>                      mapQ = new Map<Id, Quote>(); // hold Quote
    Set<id>                             setQuoteId = new Set<id>(); // hold the Quoteids from QuoteLineItems
    Set<id>                             setOppId = new Set<id>(); // hold the opportunityids from Quotes
    String                              oppProductId; // To set the key for the map
    String                              quoteProductId; // To set the key for the map
    List<OpportunityLineItem>           orderedByIdOLI = new List<OpportunityLineItem>();
    List<QuoteLineItem>                 orderedByIdQLI = new List<QuoteLineItem>();
    
    Set<Id>									setPriceBookEntries = new Set<Id>();
    Map<String, List<OpportunityLineItem>>	oppProdKey2OLIList = new Map<String, List<OpportunityLineItem>>();
    Map<String, List<QuoteLineItem>>		oppProdKey2QLIList = new Map<String, List<QuoteLineItem>>();
    Set<Id>									changedQLI = new Set<Id>();
    
        if(!Utility.triggerIsInProcess())
        {  
            for (QuoteLineItem qli : Trigger.New)
            {
                
                if((qli.Est_Delivery_Date__c != Trigger.oldMap.get(qli.ID).Est_Delivery_Date__c 
                    || qli.Fulfillment_Method__c != Trigger.oldMap.get(qli.ID).Fulfillment_Method__c) 
                    || qli.Delivery_Date__c != Trigger.oldMap.get(qli.ID).Delivery_Date__c
                    || qli.Expected_Customer_Delivery_Date__c != Trigger.oldMap.get(qli.ID).Expected_Customer_Delivery_Date__c
                    || qli.Notes__c != Trigger.oldMap.get(qli.ID).Notes__c)
                {
                    if (qli.Is_Quote_Synced__c == 'TRUE')
                    {
                        setQuoteId.add(qli.QuoteId); // Store the Quote ids 
		                setPriceBookEntries.add(qli.PricebookEntryId);
		                mapQLI.put(quoteProductId,qli);
		                changedQLI.add(qli.Id);
                    }
                }
            }
            
            orderedByIdQLI = [
                SELECT Id, UnitPrice, Quantity, Expected_Customer_Delivery_Date__c,Est_Delivery_Date__c, Delivery_Date__c, Fulfillment_Method__c, Notes__c, PricebookEntryId, QuoteID
                FROM QuoteLineItem
                WHERE QuoteID IN :setQuoteId
                	AND PricebookEntryId IN :setPriceBookEntries
                ORDER BY Id
            ];
            
            for(Quote q : [SELECT id,OpportunityId FROM Quote WHERE id in : setQuoteId]) {
                setOppId.add(q.OpportunityId); // store the oppid from Quote and use this to retrieve the OLI records
                mapOppQuoteId.put(q.id, q.OpportunityId);
            }
            
            for (QuoteLineItem item : orderedByIdQLI) {
	        	String key = mapOppQuoteId.get(item.QuoteID) + '-' + item.PricebookEntryId;
	        	if (oppProdKey2QLIList.get(key) != NULL) {
	        		List<QuoteLineItem> tmp = oppProdKey2QLIList.get(key);
	        		tmp.add(item);
	        		oppProdKey2QLIList.put(key, tmp);
	        	} else {
	        		oppProdKey2QLIList.put(key, new List<QuoteLineItem>{item});
	        	}
	        }
            
            if (!setOppId.isEmpty()) {
                orderedByIdOLI = [
                    SELECT Id, UnitPrice, Quantity, Expected_Customer_Delivery_Date__c,Est_Delivery_Date__c, Delivery_Date__c, Fulfillment_Method__c, Notes__c, PricebookEntryId, OpportunityId
                    FROM OpportunityLineItem
                    WHERE OpportunityId IN :setOppId
                    	AND PricebookEntryId IN :setPriceBookEntries
                    ORDER BY Id
                ];
                
                for (OpportunityLineItem item : orderedByIdOLI) {
    	        	String key = item.OpportunityId + '-' + item.PricebookEntryId;
    	        	if (oppProdKey2OLIList.get(key) != NULL) {
    	        		List<OpportunityLineItem> tmp = oppProdKey2OLIList.get(key);
    	        		tmp.add(item);
    	        		oppProdKey2OLIList.put(key, tmp);
    	        	} else {
    	        		oppProdKey2OLIList.put(key, new List<OpportunityLineItem>{item});
    	        	}
    	        }
                
                for (String key : oppProdKey2OLIList.keySet()) {
    	        	List<OpportunityLineItem> OLIList = oppProdKey2OLIList.get(key);
    	        	List<QuoteLineItem> QLIList = oppProdKey2QLIList.get(key);
    	        	for (Integer i = 0; i < QLIList.size(); i++) {
    	        		if (changedQLI.contains(QLIList[i].Id)) {
    	        			OpportunityLineItem oli = OLIList.get(i);
    			            oli.Est_Delivery_Date__c = QLIList.get(i).Est_Delivery_Date__c;
    			            oli.Delivery_Date__c = QLIList.get(i).Delivery_Date__c;
    			            oli.Expected_Customer_Delivery_Date__c = QLIList.get(i).Expected_Customer_Delivery_Date__c;
    			            oli.Fulfillment_Method__c = QLIList.get(i).Fulfillment_Method__c;
    			            oli.Notes__c = QLIList.get(i).Notes__c;
    			            oli.Quantity = QLIList.get(i).Quantity;
    			            oli.UnitPrice = QLIList.get(i).UnitPrice;
    			            lstOLI.add(oli);
    	        		}
    	        	}
    	        }
    	        update lstOLI;
                Utility.setTriggerInProcess();
            }
        }
*/
}