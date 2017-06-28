trigger OrderLine_DelayedOrder on Order_Line_Items__c (after insert, after update, before insert, before update) {
    
    /*
     *  Before insert
     *      Initialize Original Available Date, Current Available Date, Current Delay Date - set equal to Contact Date (Available_Date__c).
     *		Check for stale In Warehouse Date (date is in the past).
     *		Check for any delayed order date changes that came to salesforce before the Order Line was created.
     *
     *  Before update
     *      Set Original Available Date, Current Available Date and Current Delay Date equal to Contact Date (Available_Date__c) if 
     *      Original Available Date is null.
     *      Process the most recent delayed order feed data if any - move it to history and update Current Delay Date.
     *		Check if In Warehouse Date had been set to a date in the past - stale date
     *
     *	After insert
     *		Clean up any delayed order date change records that came in before the Order Line was created.
     *
     */
    
    // Process delayed order feed data
    if (trigger.isBefore) {
        
        if (trigger.isInsert) {
            
            // Check to see if there are any Delay Feed messages we have already received for these new Order Lines
            Set<String> olExtIds = new Set<String>();
            for (Order_Line_Items__c ol: trigger.new) {
                if (String.isNotBlank(ol.EXT_OrderShipToLine_Number__c)) {
                    olExtIds.add(ol.EXT_OrderShipToLine_Number__c);
                }
            }
            
            if (!olExtIds.isEmpty()) {
                List<Delay_Feed__c> dfList = new List<Delay_Feed__c>();
                dfList = [select Id, EXT_OrderShipToLine_Number__c, Delay_Feed__c from Delay_Feed__c where EXT_OrderShipToLine_Number__c in :olExtIds];
                Map<String, Delay_Feed__c> dfMap = new Map<String, Delay_Feed__c>();
                for (Delay_Feed__c df :dfList) {
                    dfMap.put(df.EXT_OrderShipToLine_Number__c, df);
                }
                for (Order_Line_Items__c ol: trigger.new) {
                    if (dfMap.containsKey(ol.EXT_OrderShipToLine_Number__c)) {
                        ol.Delay_Feed__c = dfMap.get(ol.EXT_OrderShipToLine_Number__c).Delay_Feed__c;
                    }
                }
            }
        }
            
        Date dofCD;
        List<DelayedOrderFeed.DelayedOrderFeedHistory> dofhList;
        List<DelayedOrderFeed.DelayedOrderFeedHistory> dofhNewList;
        DelayedOrderFeed.DelayedOrderFeedDateChange dofdc;
        Date tdate = system.today();
        Integer doCount = 0;
        
        Integer historyLength = Schema.SObjectType.Order_Line_Items__c.fields.Delay_Feed_History__c.getLength();
		Integer historyMaxRecords = (historyLength / 50);
		Integer lastNoticeNumber;
		Boolean convert;
        for (Order_Line_Items__c ol: trigger.new) {

            if (ol.Original_Available_Date__c == null) {
                ol.Original_Available_Date__c = ol.Available_Date__c;
                ol.Current_Available_Date__c = ol.Original_Available_Date__c;
                ol.Current_Delay_Date__c = ol.Original_Available_Date__c;
            }
            
            if (ol.In_Warehouse_Date__c != null) {
				if (ol.In_Warehouse_Date__c < tdate && ol.Backorder_Quantity__c > 0 && (ol.Line_Status_Description__c == 'Open' || ol.Line_Status_Description__c == 'Held')) {
					if (trigger.isInsert || ol.In_Warehouse_Date__c != trigger.oldMap.get(ol.Id).In_Warehouse_Date__c) {
						ol.StaleDate__c = true;
						ol.DelayFeed__c = true;
					}
				}
            }
            
            if (String.isNotBlank(ol.Delay_Feed__c) && ((trigger.isInsert) || (trigger.isUpdate && ol.Delay_Feed__c != trigger.oldMap.get(ol.Id).Delay_Feed__c))) {
                
                ol.DelayFeed__c = true;
                lastNoticeNumber = 0;
                convert = false;
                
                // Get the Backorder Date Change information
                dofdc = new DelayedOrderFeed.DelayedOrderFeedDateChange();
                dofdc = (DelayedOrderFeed.DelayedOrderFeedDateChange)JSON.deserialize(ol.Delay_Feed__c, DelayedOrderFeed.DelayedOrderFeedDateChange.class);
                
                // Set the backorder date fields for this Backorder Date Change
                dofhList = new List<DelayedOrderFeed.DelayedOrderFeedHistory>();
                dofCD = date.valueOf(dofdc.CD + ' 00:00:00');
                if (String.isBlank(ol.Delay_Feed_History__c)) {
                    if (ol.Original_Available_Date__c == null) {
                        ol.Original_Available_Date__c = dofCD;
                    }
                    if (ol.Current_Available_Date__c == null) {
                        ol.Current_Available_Date__c = ol.Original_Available_Date__c;
                    }
                } else {
                    dofhList = (List<DelayedOrderFeed.DelayedOrderFeedHistory>)JSON.deserialize(ol.Delay_Feed_History__c, List<DelayedOrderFeed.DelayedOrderFeedHistory>.class);
                    if (!dofhList.isEmpty() && String.isNotBlank(dofhList[0].NN)) {
                		lastNoticeNumber = Integer.valueOf(dofhList[0].NN);
                		if (lastNoticeNumber == 1 && dofhList.size() > 1) {
                			convert = true;
                			lastNoticeNumber = dofhList.size();
                		}
                	}
                }
                
                // Record the current delayed order feed
                ol.Current_Delay_Date__c = dofCD;
                ol.Available_Date__c = ol.Current_Delay_Date__c;
                dofhNewList = new List<DelayedOrderFeed.DelayedOrderFeedHistory>();
                dofhNewList.add(new DelayedOrderFeed.DelayedOrderFeedHistory(String.valueOf(lastNoticeNumber + 1), dofdc.ND, dofdc.CD));
                
                // If convert is true, convert delay feed history notice number order from low-to-high to high-to-low
                if (convert) {
                	for (Integer i=dofhList.size() - 1; i >= 0 && dofhNewList.size() < historyMaxRecords; i--) {
                		dofhNewList.add(dofhList[i]);
                	}
                } else {
                	for (Integer i=0; i<dofhList.size() && i+1<historyMaxRecords; i++) {
                		dofhNewList.add(dofhList[i]);
                	}
                }
                ol.Delay_Feed_History__c = JSON.serialize(dofhNewList);
            }
        }
    }
    
    // Clean up the associated Delay Feed records if any
    if (trigger.isAfter) {
        
        if (trigger.isInsert) {
            Set<String> olExtIds = new Set<String>();
            for (Order_Line_Items__c ol: trigger.new) {
                if (String.isNotBlank(ol.EXT_OrderShipToLine_Number__c)) {
                    olExtIds.add(ol.EXT_OrderShipToLine_Number__c);
                }
            }
            if (!olExtIds.isEmpty()) {
                List<Delay_Feed__c> dfList = new List<Delay_Feed__c>();
                dfList = [select Id, EXT_OrderShipToLine_Number__c, Delay_Feed__c from Delay_Feed__c where EXT_OrderShipToLine_Number__c in :olExtIds];
                if (!dfList.isEmpty()) {
                    delete dfList;
                }
            }
        }
		
		// Update state of related open Delay Notification cases
		if (trigger.isUpdate) {
			Set<Id> oIds = new Set<Id>();
			
			for (Order_Line_Items__c oli: trigger.new) {
				if ( oli.Backorder_Quantity__c != trigger.oldMap.get(oli.Id).Backorder_Quantity__c || 
					 oli.Line_Status_Description__c != trigger.oldMap.get(oli.Id).Line_Status_Description__c || 
					 oli.In_Warehouse_Date__c != trigger.oldMap.get(oli.Id).In_Warehouse_Date__c ) {
					oIds.add(oli.RH_Order_Number__c);
				}
			}
			
			if (!oIds.isEmpty()) {
				List<SObject> recordsToUpdate = new List<SObject>();
				DelayedOrderActions.updateDelayNotificationCases(recordsToupdate, oIds);
				Utility.logUpdate(Utility.compileUpdates(recordsToUpdate));
			}
		}
    }
}