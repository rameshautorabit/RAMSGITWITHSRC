trigger CaseLineItemsTrigger on Case_Line_Items__c (after insert, after update, after delete, before insert, before update) {
    
    /*
     *  Before triggers
	 *		- Set the Case Line record type based upon the associated Case record type
	 *		- Populate Case Line record with information from the associated Order Line record
	 *		- Populate Case Line record with information from the associated Product record
	 *		- Set CW Return Code based upon value in Return Reason
     *
     *  After triggers
	 *		- Update the reorder count on associated Order Line records
	 *		- Update the reorder count on associated Case records
	 *		- Update the Case Line and CW SKU ID fields on associated Case records
     *
     */
    
    if (trigger.isBefore) {
        
        Set<Id> cIds = new Set<Id>();
        Set<Id> oliIds = new Set<Id>();
        Set<Id> p2Ids = new Set<Id>();
        List<Case_Line_Items__c>cliRTList = new List<Case_Line_Items__c>();
        List<Case_Line_Items__c>cliOLIList = new List<Case_Line_Items__c>();
        List<Case_Line_Items__c>cliP2List = new List<Case_Line_Items__c>();
        Map<String, GalleryRtnToCWRtn__c> rtnCodeMap = GalleryRtnToCWRtn__c.getAll();
        
        if (trigger.isInsert) {
            for (Case_Line_Items__c cli :trigger.new) {
                if (cli.Case_Number__c != null) {
                    cIds.add(cli.Case_Number__c);
                    cliRTList.add(cli);
                }
                if (cli.Line_Number__c != null) {
                    oliIds.add(cli.Line_Number__c);
                    cliOLIList.add(cli);
                } else {
                    if (cli.CW_SKU_ID__c != null) {
                        p2Ids.add(cli.CW_SKU_ID__c);
                        cliP2List.add(cli);
                    }
                }
				if (String.isNotBlank(cli.Return_Reason__c) && rtnCodeMap.containsKey(cli.Return_Reason__c)) {
					cli.CW_Return_Code__c = rtnCodeMap.get(cli.Return_Reason__c).CW_Return_Code__c;
				}
			}
			
			if (!cIds.isEmpty()) {
				UpdateCaseLineItemClass.populateOrderLineWithOrderInformation(Trigger.new);
			}
		}
        
        if (trigger.isUpdate) {
            for (Case_Line_Items__c cli :trigger.new) {
                if (cli.Case_Number__c != null && cli.Case_Number__c != trigger.oldMap.get(cli.Id).Case_Number__c) {
                    cIds.add(cli.Case_Number__c);
                    cliRTList.add(cli);
                }
                if (cli.Line_Number__c != null) {
                    if (cli.Line_Number__c != trigger.oldMap.get(cli.Id).Line_Number__c) {
                        oliIds.add(cli.Line_Number__c);
                        cliOLIList.add(cli);
                    }
                } else {
                    if (cli.CW_SKU_ID__c != null && cli.CW_SKU_ID__c != trigger.oldMap.get(cli.Id).CW_SKU_ID__c) {
                        p2Ids.add(cli.CW_SKU_ID__c);
                        cliP2List.add(cli);
                    }
				}
				if (String.isNotBlank(cli.Return_Reason__c) && rtnCodeMap.containsKey(cli.Return_Reason__c)) {
					cli.CW_Return_Code__c = rtnCodeMap.get(cli.Return_Reason__c).CW_Return_Code__c;
				}
				
				if (!TriggerStopper.insertCaseLine) {
					cli.Status__c = 'In Progress';
				}
			}
		}
		
		// Set the Case Line record type based upon the associated Case record type
		if (!cliRTList.isEmpty()) {
			//UpdateCaseLineItemClass.defaultRecordType(cliRTList, cIds);
		}
        
        // Populate Case Line record with associated Order Line records
        if (!cliOLIList.isEmpty()) {
           UpdateCaseLineItemClass.populateOrderLineInformation(cliOLIList, oliIds);
        }
        
        // Populate Case Line record with associated Product records
        if (!cliP2List.isEmpty()) {
          UpdateCaseLineItemClass.populateProductInfo(cliP2List, p2Ids);
        }
    }
    
    if (trigger.isAfter) {
        Set<Id> cIds = new Set<Id>();
        Set<Id> decOLIIds = new Set<Id>();
        Set<Id> incOLIIds = new Set<Id>();
        
        Map<Id, Schema.RecordTypeInfo> cliRTMap = Schema.SObjectType.Case_Line_Items__c.getRecordTypeInfosById();
        
        if (trigger.isDelete) {
            for (Case_Line_Items__c cli :trigger.old) {
                if (cliRTMap.containsKey(cli.RecordTypeId) && cliRTMap.get(cli.RecordTypeId).getName() == 'Reorders' && cli.Line_Number__c != null) {
                    decOLIIds.add(cli.Line_Number__c);
                    cIds.add(cli.Case_Number__c);
                }
            }
            
            // Decrement the reorder count on associated Order Line records
            if (!decOLIIds.isEmpty()) {
                List<Order_Line_Items__c> decOrderLineItems = [select Id, Reorder_Count__c from Order_Line_Items__c where Id in :decOLIIds];
                for (Order_Line_Items__c oli :decOrderLineItems) {
                    if (oli.Reorder_Count__c != null) {
                        oli.Reorder_Count__c = oli.Reorder_Count__c - 1;
                    }
                    if (oli.Reorder_Count__c == null || oli.Reorder_Count__c < 2) {
                        oli.Reorder_Count__c = 0;
                    }
                }
                update decOrderLineItems;
            }
        }
        
        if (trigger.isInsert) {
            Map<Id, Case_Line_Items__c> caseToCaseLineMap = new Map<Id, Case_Line_Items__c>();
            
            for (Case_Line_Items__c cli :trigger.new) {
                if (cliRTMap.containsKey(cli.RecordTypeId) && cliRTMap.get(cli.RecordTypeId).getName() == 'Reorders' && cli.Line_Number__c != null) {
                    incOLIIds.add(cli.Line_Number__c);
                    cIds.add(cli.Case_Number__c);
                }
                
                if (!caseToCaseLineMap.containsKey(cli.Case_Number__c)) {
                	caseToCaseLineMap.put(cli.Case_Number__c, cli);
                }
            }

            // Increment the reorder count on associated Order Line records
            if (!incOLIIds.isEmpty()) {
                List<Order_Line_Items__c> incOrderLineItems = [select Id, Reorder_Count__c from Order_Line_Items__c where Id in :incOLIIds];
                for (Order_Line_Items__c oli :incOrderLineItems) {
                    if (oli.Reorder_Count__c != null && oli.Reorder_Count__c > 1) {
                        oli.Reorder_Count__c++;
                    } else {
                        oli.Reorder_Count__c = 2;
                    }
                }
                update incOrderLineItems;
            }
            
            // If this is the first Case Line for a Contract Case, update the parent Case Case_Line_Item__c 
            // and CW_SKU_ID__c fields
            if (!caseToCaseLineMap.isEmpty()) {
            	Map<String, Schema.RecordTypeInfo> caseRtByNameMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
            	List<Case> caseList = new List<Case>();
            	caseList = [select Id, Case_Line_Item__c, CW_SKU_ID__c from Case where Id in :caseToCaseLineMap.keySet() 
            			and Case_Line_Item__c = null and RecordTypeId = :caseRtByNameMap.get('Contract').getRecordTypeId()];
            	
            	for (Case c :caseList) {
            		if (caseToCaseLineMap.containsKey(c.Id)) {
            			c.Case_Line_Item__c = caseToCaseLineMap.get(c.Id).Id;
            			c.CW_SKU_ID__c = caseToCaseLineMap.get(c.Id).CW_SKU_ID__c;
            		}
            	}
            	
            	if (!caseList.isEmpty()) {
            		update caseList;
            	}
            }
        }
        
        if (trigger.isUpdate) {
            for (Case_Line_Items__c cli :trigger.new) {
                if (cliRTMap.containsKey(cli.RecordTypeId) && cliRTMap.get(cli.RecordTypeId).getName() == 'Reorders') {
                    if (cli.Line_Number__c != trigger.oldMap.get(cli.Id).Line_Number__c) {
                        if (cli.Line_Number__c != null) {
                            incOLIIds.add(cli.Line_Number__c);
                        }
                        if (trigger.oldMap.get(cli.Id).Line_Number__c != null) {
                            decOLIIds.add(trigger.oldMap.get(cli.Id).Line_Number__c);
                        }
                    }
                    
                    if (cli.Reorder_Count__c != trigger.oldMap.get(cli.Id).Reorder_Count__c) {
                        cIds.add(cli.Case_Number__c);
                    }
                }
            }
            
            // Increment/decrement the reorder count on associated Order Line records
            if (!incOLIIds.isEmpty() || !decOLIIds.isEmpty()) {
                List<Order_Line_Items__c> oliList = new List<Order_Line_Items__c>();
                oliList = [select Id, Reorder_Count__c from Order_Line_Items__c where Id in :incOLIIds or Id in :decOLIIds];
                for (Order_Line_Items__c oli :oliList) {
                    if (decOLIIds.contains(oli.Id)) {
                        if (oli.Reorder_Count__c != null) {
                            oli.Reorder_Count__c = oli.Reorder_Count__c - 1;
                        }
                        if (oli.Reorder_Count__c == null || oli.Reorder_Count__c < 2) {
                            oli.Reorder_Count__c = 0;
                        }
                    }
                    if (incOLIIds.contains(oli.Id)) {
                        if (oli.Reorder_Count__c != null && oli.Reorder_Count__c > 1) {
                            oli.Reorder_Count__c++;
                        } else {
                            oli.Reorder_Count__c = 2;
                        }
                    }
                }
                update oliList;
            }
        }
        
        // Update the Case fields Reorder Count and Interim Update
        if (!cIds.isEmpty()) {
            Map<Id, Schema.RecordTypeInfo> cRTMap = Schema.SObjectType.Case.getRecordTypeInfosById();
            Map<Id, Case> cMap = new Map<Id, Case>([select Id, Interim_Update__c, RecordTypeId, Reorder_Count__c from Case where Id in :cIds]);
            List<Case_Line_Items__c> cliList = new List<Case_Line_Items__c>();
            cliList = [select Id, Case_Number__c, Interim_Update__c, IsStaleDate__c, Reorder_Count__c from Case_Line_Items__c where Case_Number__c in :cIds];
            Map<Id, List<Case_Line_Items__c>> cToCLIMap = new Map<Id, List<Case_Line_Items__c>>();
            for (Id cId :cMap.keySet()) {
                if (!cToCLIMap.containsKey(cId)) {
                    cToCLIMap.put(cId, new List<Case_Line_Items__c>());
                }
                for (Case_Line_Items__c cli :cliList) {
                    if (cli.Case_Number__c == cId) {
                        cToCLIMap.get(cId).add(cli);
                    }
                }
            }
            
            Decimal cliReorderCount;
            for (Id cId :cToCLIMap.keySet()) {
                cliReorderCount = 0;
                for (Case_Line_Items__c cli :cToCLIMap.get(cId)) {
                    if (cRTMap.containsKey(cMap.get(cId).RecordTypeId) && cRTMap.get(cMap.get(cId).RecordTypeId).getName() == 'Reorders') {
                        if (cli.Reorder_Count__c != null && cli.Reorder_Count__c > cliReorderCount) {
                            cliReorderCount = cli.Reorder_Count__c;
                        }
                    }
                }
                if (cRTMap.containsKey(cMap.get(cId).RecordTypeId) && cRTMap.get(cMap.get(cId).RecordTypeId).getName() == 'Reorders') {
                    cMap.get(cId).Reorder_Count__c = cliReorderCount;
                }
            }
            update cMap.values();
        }
        
        if (trigger.isInsert) {
        	TriggerStopper.insertCaseLine = true;
        }
    }
}

/*
 * Rewritten to improve efficiency 9/22/2015 - reduce the number of queries and to do as much as possible in
 * before triggers rather than after triggers.
 *
 *
/* Author SP- ForeFront
 * Purpose increment and decrement counts of OrderLines for CaseLines Added/Modified in Cases
 * Dates/Sections modified 8-22-14
 */
/*
trigger CaseLineItemsTrigger on Case_Line_Items__c (after insert, after update, after delete) {
    
    // Variables
    Map<Id,Id> mCLIdToCId=new Map<Id,Id>();
    Map<Id,Id> mCLIdOLId=new Map<Id,Id>();
    Map<Id,Id> mCLIdToPId=new Map<Id,Id>();
    
    Map<Id, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case_Line_Items__c.getRecordTypeInfosById();
    
    if (trigger.isAfter && trigger.isDelete) {
        List<Id> orderLineIds = new List<Id>();
        Set<Id> caseIds = new Set<Id>();
        for (Case_Line_Items__c cli :trigger.old) {
            if (rtMap.get(cli.RecordTypeId).getName() == 'Reorders' && cli.Line_Number__c != null) {
                 orderLineIds.add(cli.Line_Number__c);
                 caseIds.add(cli.Case_Number__c);
            }
        }
        if (!orderLineIds.isEmpty()) {
            List<Order_Line_Items__c> decOrderLineItems = [select Id, Reorder_Count__c from Order_Line_Items__c where Id in :orderLineIds];
            for (Order_Line_Items__c oli :decOrderLineItems) {
                if (oLI.Reorder_Count__c != null) {
                    oLI.Reorder_Count__c = oLI.Reorder_Count__c - 1;
                }
                if (oLI.Reorder_Count__c == null || oLI.Reorder_Count__c < 2) {
                    oLI.Reorder_Count__c = 0;
                }
            }
            
            try {
                update decOrderLineItems;
            } catch(exception e) {
                System.debug(e);
            }
        }
        
        if (!caseIds.isEmpty()) {
            Map<Id, Case> caseMap = new Map<Id, Case>([select Id, Reorder_Count__c from Case where Id in :caseIds]);
            List<Case_Line_Items__c> cliList = new List<Case_Line_Items__c>();
            cliList = [select Id, Case_Number__c, Reorder_Count__c from Case_Line_Items__c where Case_Number__c in :caseIds];
            for (Case c :caseMap.values()) {
                c.Reorder_Count__c = 0;
            }
            for (Case_Line_Items__c cli :cliList) {
                if (caseMap.containsKey(cli.Case_Number__c)) {
                    if (cli.Reorder_Count__c == null) {
                        cli.Reorder_Count__c = 0;
                    }
                    if (cli.Reorder_Count__c > caseMap.get(cli.Case_Number__c).Reorder_Count__c) {
                        caseMap.get(cli.Case_Number__c).Reorder_Count__c = cli.Reorder_Count__c;
                    }
                }
            }
            if (!caseMap.isEmpty()) {
                update caseMap.values();
            }
        }
    }
    
    if (trigger.isAfter && trigger.isInsert) {
        List<Id> orderLineIds = new List<Id>();
        Set<Id> caseIds = new Set<Id>();
        for (Case_Line_Items__c cli :trigger.new) {
            if (rtMap.get(cli.RecordTypeId).getName() == 'Reorders' && cli.Line_Number__c != null) {
                orderLineIds.add(cli.Line_Number__c);
                caseIds.add(cli.Case_Number__c);
            }
        }
        if (!orderLineIds.isEmpty()) {
            List<Order_Line_Items__c> incOrderLineItems = [select Id, Reorder_Count__c from Order_Line_Items__c where Id in :orderLineIds];
            for (Order_Line_Items__c oli :incOrderLineItems) {
                if (oli.Reorder_Count__c != null && oli.Reorder_Count__c > 1) {
                    oli.Reorder_Count__c++;
                } else {
                    oli.Reorder_Count__c = 2;
                }
            }
            
            try {
                update incOrderLineItems;
            } catch(exception e) {
                System.debug(e);
            }
        }
        
        if (!caseIds.isEmpty()) {
            Decimal cliReorders;
            Map<Id, Case> caseMap = new Map<Id, Case>([select Id, Interim_Update__c, Reorder_Count__c, Request_Category__c from Case where Id in :caseIds]);
            List<Case_Line_Items__c> cliList = new List<Case_Line_Items__c>();
            cliList = [select Id, Case_Number__c, Interim_Update__c, In_Warehouse_Date__c, Reorder_Count__c from Case_Line_Items__c where Case_Number__c in :caseIds];
            for (Case c :caseMap.values()) {
                c.Reorder_Count__c = 0;
            }
            for (Case_Line_Items__c cli :cliList) {
                if (caseMap.containsKey(cli.Case_Number__c)) {
                    if (cli.Reorder_Count__c == null) {
                        cliReorders = 0;
                    } else {
                        cliReorders = cli.Reorder_Count__c;
                    }
                    if (cliReorders > caseMap.get(cli.Case_Number__c).Reorder_Count__c) {
                        caseMap.get(cli.Case_Number__c).Reorder_Count__c = cliReorders;
                    }
                }
            }
            if (!caseMap.isEmpty()) {
                update caseMap.values();
            }
        }
        
        // Check for Case Id on case line item
        for (Case_Line_Items__c cli :trigger.new) {
            if (cli.Case_Number__c != null) {
                mCLIdToCId.put(cli.Id, cli.Case_Number__c);
            }
            
            // Check if line number is populated
            if (cli.Line_Number__c != null) {
                //Create a map of case Id and Order Id
                mCLIdOLId.put(cli.Id, cli.Line_Number__c);
            }
            
            // Check of the product look up is populated and order line number is null
            if (cli.CW_SKU_ID__c != null && cli.Line_Number__c == null) {
                mCLIdToPId.put(cli.Id,cli.CW_SKU_ID__c);
            }
        }
    }
    
    if (trigger.isAfter && trigger.isUpdate) {
        List<Id> incorderLineIds = new List<Id>();
        List<Id> decorderLineIds = new List<Id>();
        Set<Id> caseIds = new Set<Id>();
        for (Case_Line_Items__c cli :trigger.new) {
            if (rtMap.get(cli.RecordTypeId).getName() == 'Reorders' && ((Case_Line_Items__c)Trigger.OldMap.get(cli.Id)).Line_Number__c != cli.Line_Number__c){
                incorderLineIds.add(cli.Line_Number__c);
                decorderLineIds.add(((Case_Line_Items__c)Trigger.OldMap.get(cli.Id)).Line_Number__c);
            }
            
            if (rtMap.get(cli.RecordTypeId).getName() == 'Reorders' && cli.Line_Number__c != trigger.oldMap.get(cli.Id).Line_Number__c) {
                if (cli.Line_Number__c != null) {
                    incorderLineIds.add(cli.Line_Number__c);
                }
                if (trigger.oldMap.get(cli.Id).Line_Number__c != null) {
                    decorderLineIds.add(trigger.oldMap.get(cli.Id).Line_Number__c);
                }
            }
            
            if (rtMap.get(cli.RecordTypeId).getName() == 'Reorders' && cli.Reorder_Count__c != trigger.oldMap.get(cli.Id).Reorder_Count__c) {
                caseIds.add(cli.Case_Number__c);
            }
        }
        
        List<Order_Line_Items__c> decOrderLineItems = new List<Order_Line_Items__c>();
        List<Order_Line_Items__c> incOrderLineItems = new List<Order_Line_Items__c>();
        
        if (!decorderLineIds.isEmpty()) {
            decOrderLineItems = [select Id, Reorder_Count__c from Order_Line_Items__c where Id in :decorderLineIds];
            for (Order_Line_Items__c oli :decOrderLineItems) {
                if (oli.Reorder_Count__c != null) {
                    oli.Reorder_Count__c = oli.Reorder_Count__c - 1;
                }
                if (oli.Reorder_Count__c == null || oli.Reorder_Count__c < 2) {
                    oli.Reorder_Count__c = 0;
                }
            }
        }
        
        if (!incorderLineIds.isEmpty()) {
            incOrderLineItems = [select Id, Reorder_Count__c from Order_Line_Items__c where Id in :incorderLineIds];
            for (Order_Line_Items__c oli :incOrderLineItems) {
                if (oli.Reorder_Count__c != null && oli.Reorder_Count__c > 1) {
                    oli.Reorder_Count__c++;
                } else {
                    oli.Reorder_Count__c = 2;
                }
            }
        }
        
        try {
            if (!decOrderLineItems.isEmpty()) {
                update decOrderLineItems;
            }
            if(!incOrderLineItems.isEmpty()){
                update incOrderLineItems;
            }
        } catch(exception e) {
            System.debug(e);
        }
        
        if (!caseIds.isEmpty()) {
            Map<Id, Case> caseMap = new Map<Id, Case>([select Id, Reorder_Count__c from Case where Id in :caseIds]);
            List<Case_Line_Items__c> cliList = new List<Case_Line_Items__c>();
            cliList = [select Id, Case_Number__c, Reorder_Count__c from Case_Line_Items__c where Case_Number__c in :caseIds];
            for (Case c :caseMap.values()) {
                c.Reorder_Count__c = 0;
            }
            for (Case_Line_Items__c cli :cliList) {
                if (caseMap.containsKey(cli.Case_Number__c)) {
                    if (cli.Reorder_Count__c == null) {
                        cli.Reorder_Count__c = 0;
                    }
                    if (cli.Reorder_Count__c > caseMap.get(cli.Case_Number__c).Reorder_Count__c) {
                        caseMap.get(cli.Case_Number__c).Reorder_Count__c = cli.Reorder_Count__c;
                    }
                }
            }
            if (!caseMap.isEmpty()) {
                update caseMap.values();
            }
        }
        
        // Determine if Case, Order Line, or Product lookup fields have changed - if so, will process below
        for (Case_Line_Items__c cli :trigger.new) {
            Case_Line_Items__c oldCLI = trigger.oldMap.get(cli.Id);
            
            // Case lookup - not needed because of master/detail relationship and not reparentable, but doesn't hurt
            if (cli.Case_Number__c != null && oldCLI.Case_Number__c != cli.Case_Number__c) {
                mCLIdToCId.put(cli.Id,cli.Case_Number__c);
            }
            
            // Order Line lookup
            if (cli.Line_Number__c != null && oldCLI.Line_Number__c != cli.Line_Number__c) {
                mCLIdOLId.put(cli.Id, cli.Line_Number__c);
            }
            
            // Product lookup
            if (cli.CW_SKU_ID__c != null && oldCLI.CW_SKU_ID__c != cli.CW_SKU_ID__c && cli.Line_Number__c == null) {
                mCLIdToPId.put(cli.Id,cli.CW_SKU_ID__c);
            }
        }
    }
    
    // Calling method to default the case line record type based on the case record type
    if (!mCLIdToCId.isEmpty()) {
        UpdateCaseLineItemClass.defaultRecordType(mCLIdToCId);
    }
    
    // Calling method to default the order line information
    if (!mCLIdOLId.isEmpty()) {
        UpdateCaseLineItemClass.populateOrderLineInformation(mCLIdOLId);
    }
    
    // Calling method to populate the product information on the Case line item
    if (!mCLIdToPId.isEmpty()) {
        UpdateCaseLineItemClass.populateProductInfo(mCLIdToPId);
    }
}
*/