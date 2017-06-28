trigger syncOLI_QLI_on_OLI_AfterUpdate on OpportunityLineItem (after update) {
/*
    List<QuoteLineItem>                 	lstQLI = new List<QuoteLineItem>();
    String                              	oppProductId; // To set the key for the map
    Map<id,id>                          	mapOppQuoteId = new Map<id,id>();
    Map<String, OpportunityLineItem>    	mapOLI = new Map<String, OpportunityLineItem>(); // hold opportunity Line items
    Set<id>                             	setQuoteId = new Set<id>(); // hold the Quoteids 
    Set<id>                             	setOppId = new Set<id>(); // hold the opportunityids from OLI
    List<OpportunityLineItem>           	orderedByIdOLI = new List<OpportunityLineItem>();
    List<QuoteLineItem>                 	orderedByIdQLI = new List<QuoteLineItem>();
    
    Set<Id>									setPriceBookEntries = new Set<Id>();
    Map<String, List<OpportunityLineItem>>	oppProdKey2OLIList = new Map<String, List<OpportunityLineItem>>();
    Map<String, List<QuoteLineItem>>		oppProdKey2QLIList = new Map<String, List<QuoteLineItem>>();
    Set<Id>									changedOLI = new Set<Id>();
    
    if(!Utility.triggerIsInProcess())
    {
        for (OpportunityLineItem oli : Trigger.New)
        {
            if(oli.Est_Delivery_Date__c != Trigger.oldMap.get(oli.ID).Est_Delivery_Date__c || 
            oli.Fulfillment_Method__c != Trigger.oldMap.get(oli.ID).Fulfillment_Method__c ||
            oli.Delivery_Date__c != Trigger.oldMap.get(oli.ID).Delivery_Date__c ||
            oli.Expected_Customer_Delivery_Date__c != Trigger.oldMap.get(oli.ID).Expected_Customer_Delivery_Date__c ||
            oli.Notes__c != Trigger.oldMap.get(oli.Id).Notes__c)
            {
                setOppId.add(oli.OpportunityId);
                setPriceBookEntries.add(oli.PricebookEntryId);
                changedOLI.add(oli.Id);
            }
        }
		
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
        
        for(Quote q : [SELECT Id, OpportunityId FROM Quote WHERE OpportunityId IN : setOppId AND IsSyncing = true])
        {
            setQuoteId.add(q.ID);
            mapOppQuoteId.put(q.id,q.OpportunityId);
        }

        if (!setQuoteId.isEmpty()) {
            orderedByIdQLI = [
                SELECT Id, UnitPrice, Quantity, Expected_Customer_Delivery_Date__c,Est_Delivery_Date__c, Delivery_Date__c, Fulfillment_Method__c, Notes__c, PricebookEntryId, QuoteID
                FROM QuoteLineItem
                WHERE QuoteID IN :setQuoteId
                    AND PricebookEntryId IN :setPriceBookEntries
                ORDER BY Id
            ];            
            
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
            
            for (String key : oppProdKey2OLIList.keySet()) {
                List<OpportunityLineItem> OLIList = oppProdKey2OLIList.get(key);
                List<QuoteLineItem> QLIList = oppProdKey2QLIList.get(key);
                for (Integer i = 0; i < OLIList.size(); i++) {
                    if (changedOLI.contains(OLIList[i].Id)) {
                        QuoteLineItem qli = QLIList.get(i);
                        qli.Est_Delivery_Date__c = OLIList.get(i).Est_Delivery_Date__c;
                        qli.Delivery_Date__c = OLIList.get(i).Delivery_Date__c;
                        qli.Expected_Customer_Delivery_Date__c = OLIList.get(i).Expected_Customer_Delivery_Date__c;
                        qli.Fulfillment_Method__c = OLIList.get(i).Fulfillment_Method__c;
                        qli.Notes__c = OLIList.get(i).Notes__c;
                        qli.Quantity = OLIList.get(i).Quantity;
                        qli.UnitPrice = OLIList.get(i).UnitPrice;
                        lstQLI.add(qli);
                    }
                }
            }
            update lstQLI;
        }
    }
*/
}