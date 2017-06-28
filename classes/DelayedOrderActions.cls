public class DelayedOrderActions {
	
	/*
	 *	Methods to determine appropriate delayed order action to take.
	 *
	 */
	
	// Process each order line with stale In Warehouse Date and/or new Delay Feed data 
	// Note - this method is used both synchronously and asynchronously
	public static void takeAction(List<Order_Line_Items__c> doOliList) {
		
		DelayRulesResult drr;
		
		// Get all of the related product, order, ship to, order line, case, and case line data
		Set<Id> oIds = new Set<Id>();
		for (Order_Line_Items__c oli :doOliList) {
			oIds.add(oli.RH_Order_Number__c);
		}
		
		Map<Id, RH_Order__c> oMap = new Map<Id, RH_Order__c>([select Id, Name, Order_Type_Code__c, Email_Contacts__c, Fraud_Warning__c, Status__c, 
				Callout_Contacts__c, Total_Contacts__c, Total_Order_Amount__c, Merchandise_Subtotal__c, Sold_To_Address_1__c, Sold_to_Address_2__c, 
				Sold_to_City__c, Sold_to_State__c, Sold_to_Zip__c, Sold_to_Email__c, Sold_to_First_Name__c, Sold_to_Last_Name__c 
				from RH_Order__c where Id in :oIds]);
		
		Map<Id, Order_Line_Items__c> oliMap = new Map<Id, Order_Line_Items__c>([select Id, Delay_Feed_History__c, Backorder_Quantity__c, Coordinate_Group__c, 
				Current_Available_Date__c, Current_Delay_Date__c, Available_Date__c, Original_Available_Date__c, In_Warehouse_Date__c, 
				Days_Since_Original_Available_Date__c, DelayFeed__c, StaleDate__c, CW_SKU_ID__c, Line_Total__c, Line_Status_Description__c, 
				RH_Order_Number__c, RH_Order_Number__r.Order_Type_Code__c 
				from Order_Line_Items__c where RH_Order_Number__c in :oMap.keySet()]);
		
		Set<Id> pIds = new Set<Id>();
		for (Order_Line_Items__c oli :oliMap.values()) {
			if (oli.CW_SKU_ID__c != null) {
				pIds.add(oli.CW_SKU_ID__c);
			}
		}
		Map<Id, Product2> pMap = new Map<Id, Product2>([select Id, SKU_Type__c, Sku_Status__c from Product2 where Id in :pIds]);
		
		// Remove Orders from our map that are marked fraudulent or are not being processed
		for (RH_Order__c o :oMap.values()) {
			if (o.Fraud_Warning__c || (o.Status__c != 'Open' && o.Status__c != 'In Process' && o.Status__c != 'Held')) {
				oMap.remove(o.Id);
			}
		}
		
		Set<Id> dfoIds = new Set<Id>();
		Map<Id, Order_Line_Items__c> delayFeedMap = new Map<Id, Order_Line_Items__c>();
		for (Order_Line_Items__c oli :doOliList) {
			if (oMap.containsKey(oli.RH_Order_Number__c) && pMap.containsKey(oli.CW_SKU_ID__c) && String.isBlank(pMap.get(oli.CW_SKU_ID__c).SKU_Type__c)) {
				if (oli.DelayFeed__c) {
					
					// Only interested in order lines that are actually back ordered
					if (oli.Backorder_Quantity__c > 0 && (oli.Line_Status_Description__c == 'Open' || oli.Line_Status_Description__c == 'Held')) {
						delayFeedMap.put(oli.Id, oli);
						dfoIds.add(oli.RH_Order_Number__c);
					}
				}
			} 
		}
		
		system.debug('***** size of oMap = ' + oMap.size() + ' size of delayFeedMap = ' + delayFeedMap.size());
				
		List<Ship_To__c> shipTo1List = new List<Ship_To__c>();
		shipTo1List = [select Id, Name, Order__c, Ship_to_First_Name__c, Ship_to_Last_Name__c, Ship_to_Address_1__c, 
					Ship_to_Address_2__c, Ship_to_City__c, Ship_to_State__c, Ship_to_Zip__c 
					from Ship_To__c where Order__c in :oMap.keySet() and Name = '1'];
		Map<Id, Ship_To__c> oShipTo1Map = new Map<Id, Ship_To__c>();
		for (Ship_To__c st :shipTo1List) {
			oShipTo1Map.put(st.Order__c, st);
		}
		
		Map<String, Schema.RecordTypeInfo> cRTMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
		Map<String, Schema.RecordTypeInfo> cliRTMap = Schema.SObjectType.Case_Line_Items__c.getRecordTypeInfosByName();
		
		Map<Id, Case> cMap = new Map<Id, Case>([select Id, Status, RecordTypeId, IsClosed, RH_Order_Number__c, Request_Category__c, 
				Delay_Notification_Reason__c, Calculated_Gift_Card_Amount__c, Actual_Gift_Card_Amount__c, OwnerId 
				from Case where IsClosed = false and WasReopened__c = false and Gift_Card_Status__c = null and 
				RecordTypeId = :cRTMap.get('Delay Notifications').getRecordTypeId() and RH_Order_Number__c in :oMap.keySet()]);
		List<Case_Line_Items__c> cliList = new List<Case_Line_Items__c>();
		cliList = [select Id, Case_Number__c, Line_Number__c, Order__c, Delay_Notice_Number__c, RecordTypeId, Interim_Update__c, IsStaleDate__c, Line_Total__c, Delay_Notification_Type__c, Delay_Notification_Reason__c 
				from Case_Line_Items__c where Case_Number__c in :cMap.keySet() and RecordTypeId = :cliRTMap.get('Delay Notifications').getRecordTypeId()];
		Map<Id, Case> oCaseMap = new Map<Id, Case>();
		for (Case c :cMap.values()) {
			oCaseMap.put(c.RH_Order_Number__c, c);
		}

		Map<Id, Case_Line_Items__c> oliCaseLineMap = new Map<Id, Case_Line_Items__c>();
		for (Case_Line_Items__c cli :cliList) {
			if (cli.Line_Number__c != null) {
				oliCaseLineMap.put(cli.Line_Number__c, cli);
			}
		}
		
		// Prepare two lists of order lines - those that are associated with open delay notifications cases and
		// the list of coordinate grouped order lines that are in the same coordinate group
		// as the current set of delayed order lines that are being processed. Also build a map that records which
		// delayed order lines are part of an order where all order lines are swatches
		Set<String> cgSet = new Set<String>();
		for (Order_Line_Items__c oli :delayFeedMap.values()) {
			if (String.isNotBlank(oli.Coordinate_Group__c) && oli.Coordinate_Group__c != '0') {
				cgSet.add(oli.Coordinate_Group__c);
			}
		}
		Map<Id, Order_Line_Items__c> dnCaseOliMap = new Map<Id, Order_Line_Items__c>();
		List<Order_Line_Items__c> cgDoOrderLines = new List<Order_Line_Items__c>();
		Map<Id, Boolean> oSwatchMap = new Map<Id, Boolean>();
		for (Order_Line_Items__c oli :oliMap.values()) {
			if (dfoIds.contains(oli.RH_Order_Number__c) && oliCaseLineMap.containsKey(oli.Id)) {
				dnCaseOliMap.put(oli.Id, oli);
			}
			
			if (dfoIds.contains(oli.RH_Order_Number__c) && cgSet.contains(oli.Coordinate_Group__c) && (!delayFeedMap.containsKey(oli.Id))) {
				cgDoOrderLines.add(oli);
			}
			
			if (!oSwatchMap.containsKey(oli.RH_Order_Number__c)) {
				oSwatchMap.put(oli.RH_Order_Number__c, true);
			}
			if (!pMap.containsKey(oli.CW_SKU_ID__c) || (pMap.get(oli.CW_SKU_ID__c).Sku_Status__c != 'S' && String.isBlank(pMap.get(oli.CW_SKU_ID__c).SKU_Type__c))) {
				oSwatchMap.put(oli.RH_Order_Number__c, false);
			}
		}
		
		system.debug('*****DelayedOrderActions.takeAction dnCaseOliMap size = ' + dnCaseOliMap.size() + ' cgDoOrderLines size = ' + cgDoOrderLines.size() + ' oSwatchMap size = ' + oSwatchMap.size());
		system.debug('*****DelayedOrderActions.takeAction oSwatchMap = ' + oSwatchMap);
		
		// Process the new delay feed order lines - first, get the rest of the related data needed
		// Get the delayed order rules data
		List<Delayed_Order_Rule__c> drList = new List<Delayed_Order_Rule__c>();
		Map<String, Delayed_Order_Rule__c> drMap = new Map<String, Delayed_Order_Rule__c>();
		drList = [select Id, Name, Order_Type_Category__c, Automatic_Emails__c, No_Auto_Email_After_Callout__c, 
				Days_Moved_Last__c, Days_Moved_Original__c, 
				Days_Moved_Special_Attention__c, Days_Moved_Line_Item_Value_Gift_Card__c, Maximum_Regular_Notifications__c, 
				Order_Amount_Tier_1__c, Lines_Moved_Amount_Tier_1__c, Lines_Moved_Amount_Tier_2__c 
				from Delayed_Order_Rule__c];
		for (Delayed_Order_Rule__c dr :drList) {
			drMap.put(dr.Order_Type_Category__c, dr);
		}
				
		// Create a single map of all delayed order order lines by order number and by coordinate group
		Map<String, List<Order_Line_Items__c>> cgMap = new Map<String, List<Order_Line_Items__c>>();
		for (Order_Line_Items__c oli :cgDoOrderLines) {
			if (oli.Original_Available_Date__c != null || oli.Available_Date__c != null) {
				if (oli.Original_Available_Date__c == null) {
					oli.Original_Available_Date__c = oli.Available_Date__c;
				}
				
				if (!cgMap.containsKey(oli.RH_Order_Number__c + '-' + oli.Coordinate_Group__c)) {
					cgMap.put(oli.RH_Order_Number__c + '-' + oli.Coordinate_Group__c, new List<Order_Line_Items__c>());
				}
				cgMap.get(oli.RH_Order_Number__c + '-' + oli.Coordinate_Group__c).add(oli);
			}
		}
		
		String coordinateGroup;
		for (Order_Line_Items__c oli :delayFeedMap.values()) {
			coordinateGroup = '0';
			if (String.isNotBlank(oli.Coordinate_Group__c)) {
				coordinateGroup = oli.Coordinate_Group__c;
			}
			if (!cgMap.containsKey(oli.RH_Order_Number__c + '-' + coordinateGroup)) {
				cgMap.put(oli.RH_Order_Number__c + '-' + coordinateGroup, new List<Order_Line_Items__c>());
			}
			cgMap.get(oli.RH_Order_Number__c + '-' + coordinateGroup).add(oli);
		}
		
		// Determine which Order Lines meet one or more of the delayed order rules and create Case and Case Line records.
		Case delayCase;
		Case_Line_Items__c delayCaseLine;
		Order_Line_Items__c cgOli;
		Map<Id, Case> newOCaseMap = new Map<Id, Case>();
		Map<Id, Case_Line_Items__c> newOliCaseLineMap = new Map<Id, Case_Line_Items__c>();
		drr = new DelayRulesResult();
		Date lineCommunicatedDate;
		Date lineDelayDate;
		Date communicatedDate;
		Date delayDate;
		String skuStatus;
		Boolean swatchOrder;
		for (String key :cgMap.keySet()) {
			
			coordinateGroup = key.substring(key.indexOf('-') + 1);
			
			if (String.isNotBlank(coordinateGroup) && coordinateGroup != '0') {
				
				// Determine coordinate group delayed order action - find the current and new dates driving the coordinate 
				// group availability.
				cgOli = null;
				communicatedDate = null;
				delayDate = null;
				for (Order_Line_Items__c oli :cgMap.get(key)) {
					
					lineCommunicatedDate = null;
					lineDelayDate = null;
					if (oli.DelayFeed__c) {
						if (oli.Current_Available_Date__c != null) {
							lineCommunicatedDate = oli.Current_Available_Date__c;
						}
						if (oli.Current_Delay_Date__c != null) {
							lineDelayDate = oli.Current_Delay_Date__c;
						}
					} else {
						if (oli.Available_Date__c != null) {
							lineCommunicatedDate = oli.Available_Date__c;
							lineDelayDate = oli.Available_Date__c;
						}
						if (oli.Current_Available_Date__c != null) {
							lineCommunicatedDate = oli.Current_Available_Date__c;
						}
						if (oli.Current_Delay_Date__c != null) {
							lineDelayDate = oli.Current_Delay_Date__c;
						}
					}
					
					if (lineCommunicatedDate != null && lineDelayDate != null) {
						if (communicatedDate == null || communicatedDate < lineCommunicatedDate) {
							communicatedDate = lineCommunicatedDate;
						}
						if (delayDate == null || delayDate < lineDelayDate) {
							delayDate = lineDelayDate;
							cgOli = oli;
						}
					}
				}
				
				// Determine if a case needs to be created/updated
				drr = new DelayRulesResult();
				if (cgOli != null && oMap.containsKey(cgOli.RH_Order_Number__c)) {
					skuStatus = '';
					if (pMap.containsKey(cgOli.CW_SKU_ID__c)) {
						skuStatus = pMap.get(cgOli.CW_SKU_ID__c).Sku_Status__c;
					}
					swatchOrder = false;
					if (oSwatchMap.containsKey(cgOli.RH_Order_Number__c)) {
						swatchOrder = oSwatchMap.get(cgOli.RH_Order_Number__c);
					}
					drr = evaluateDelayRules(oMap.get(cgOli.RH_Order_Number__c), oShipTo1Map.get(cgOli.RH_Order_Number__c), cgOli, drMap, dnCaseOliMap, communicatedDate, delayDate, skuStatus, swatchOrder);
				}
				
				system.debug('*****DelayedOrderActions.takeAction coordinateGroup = ' + coordinateGroup + ' requestCategory = ' + drr.drrRequestCategory + ' communicatedDate = ' + communicatedDate + ' delayDate = ' + delayDate);
				
				if (String.isNotBlank(drr.drrRequestCategory)) {
					delayCase = createDelayedOrderCase(cgOli, drr, oCaseMap);
					if (delayCase != null) {
						oCaseMap.put(delayCase.RH_Order_Number__c, delayCase);
						newOCaseMap.put(delayCase.RH_Order_Number__c, delayCase);
					}
					
					delayCaseLine = createDelayedOrderCaseLines(cgOli, drr, oliCaseLineMap);
					if (delayCaseLine != null) {
						oliCaseLineMap.put(delayCaseLine.Line_Number__c, delayCaseLine);
						newOliCaseLineMap.put(delayCaseLine.Line_Number__c, delayCaseLine);
						dnCaseOliMap.put(cgOli.Id, cgOli);
					}
				}
				
			} else {
				
				// Determine non-coordinate group delayed order action
				for (Order_Line_Items__c oli :cgMap.get(key)) {
					drr = new DelayRulesResult();
					if (oMap.containsKey(oli.RH_Order_Number__c)) {
						skuStatus = '';
						if (pMap.containsKey(oli.CW_SKU_ID__c)) {
							skuStatus = pMap.get(oli.CW_SKU_ID__c).Sku_Status__c;
						}
						swatchOrder = false;
						if (oSwatchMap.containsKey(oli.RH_Order_Number__c)) {
							swatchOrder = oSwatchMap.get(oli.RH_Order_Number__c);
						}
						drr = evaluateDelayRules(oMap.get(oli.RH_Order_Number__c), oShipTo1Map.get(oli.RH_Order_Number__c), oli, drMap, dnCaseOliMap, oli.Current_Available_Date__c, oli.Current_Delay_Date__c, skuStatus, swatchOrder);
					}
					
					system.debug('*****DelayedOrderActions.takeAction coordinateGroup = ' + coordinateGroup + ' requestCategory = ' + drr.drrRequestCategory + ' communicatedDate = ' + oli.Current_Available_Date__c + ' delayDate = ' + oli.Current_Delay_Date__c);
					
					if (String.isNotBlank(drr.drrRequestCategory)) {
						delayCase = createDelayedOrderCase(oli, drr, oCaseMap);
						if (delayCase != null) {
							oCaseMap.put(delayCase.RH_Order_Number__c, delayCase);
							newOCaseMap.put(delayCase.RH_Order_Number__c, delayCase);
						}
						
						delayCaseLine = createDelayedOrderCaseLines(oli, drr, oliCaseLineMap);
						if (delayCaseLine != null) {
							oliCaseLineMap.put(delayCaseLine.Line_Number__c, delayCaseLine);
							newOliCaseLineMap.put(delayCaseLine.Line_Number__c, delayCaseLine);
							dnCaseOliMap.put(oli.Id, oli);
						}
					}
				}
			}
		}
		
		if (!newOCaseMap.isEmpty()) {
			upsert newOCaseMap.values();
		}
		
		for (Case_Line_Items__c cli :newOliCaseLineMap.values()) {
			if (cli.Case_Number__c == null) {
				cli.Case_Number__c = oCaseMap.get(cli.Order__c).Id;
			}
		}
		if (!newOliCaseLineMap.isEmpty()) {
			upsert newOliCaseLineMap.values();
		}
		
		// Close all Delay Notifications case just created/updated with Request Category = 'Days Moved In'
		List<Case> closeList = new List<Case>();
		for (Case c :newOCaseMap.values()) {
			if (c.Request_Category__c == 'Days Moved In') {
				c.Status = 'Closed - Invalid';
				closeList.add(c);
			}
		}
		if (!closeList.isEmpty()) {
			TriggerStopper.stopCase = false;	// Make sure second case update is processed
			update closeList;
		}
	}
	
	private class DelayRulesResult {
		String drrRequestCategory {get; set;}
		Boolean drrCWGiftCard {get; set;}
		Decimal drrGiftCardAmount {get; set;}
		String drrReason {get; set;}
		
		private DelayRulesResult() {
			drrRequestCategory = '';
			drrCWGiftCard = false;
			drrGiftCardAmount = 0;
			drrReason = '';
		}
	}
	
	// Evaluate the Delayed Order Rules against days moved, order amount, lines moving amount, and SKU Status
	private static DelayRulesResult evaluateDelayRules(RH_Order__c order, Ship_To__c shipTo, Order_Line_Items__c orderLine, Map<String, Delayed_Order_Rule__c> drMap, Map<Id, Order_Line_Items__c> dnCaseOliMap, Date communicatedDate, Date delayDate, String skuStatus, Boolean swatchOrder) {
		String orderTypeCategory;
		Decimal emailAlerts;
		Decimal callouts;
		Decimal daysMovedLast;
		Decimal daysMovedOriginal;
		Decimal daysMovedSinceLast;
		Decimal daysMovedSinceOriginal;
		Decimal linesMovedTotal;
		Decimal lineMoving;
		Decimal giftCardAmount;
		String requestCategory = '';
		String dnType = '';
		String drrReason = '';
		DelayRulesResult drr = new DelayRulesResult();
		
		// Determine the total amount of all lines that are moving
		if (dnCaseOliMap.containsKey(orderLine.Id) || orderLine.Line_Total__c == null) {
			lineMoving = 0;
		} else {
			lineMoving = orderLine.Line_Total__c;
		}
		linesMovedTotal = lineMoving;
		for (Order_Line_Items__c oli :dnCaseOliMap.values()) {
			if (oli.RH_Order_Number__c == orderLine.RH_Order_Number__c && oli.Line_Total__c != null) {
				linesMovedTotal += oli.Line_Total__c;
			}
		}
		
		if (delayDate != null && communicatedDate != null) {
			orderTypeCategory = getOrderTypeCategory(order.Order_Type_Code__c);
			if (String.isBlank(orderTypeCategory) || (!drMap.containsKey(orderTypeCategory))) {
				orderTypeCategory = 'Standard';
			}
			
			daysMovedSinceLast = math.abs(communicatedDate.daysBetween(delayDate));
			daysMovedSinceOriginal = math.abs(orderLine.Original_Available_Date__c.daysBetween(delayDate));
			daysMovedLast = drMap.get(orderTypeCategory).Days_Moved_Last__c;
			daysMovedOriginal = drMap.get(orderTypeCategory).Days_Moved_Original__c;
			
			if (daysMovedSinceLast >= daysMovedLast) {
				if (delayDate < communicatedDate) {
					drrReason = 'Days Moved In;';
				} else {
					drrReason = 'Days Moved Out;';
				}
				if (order.Order_Type_Code__c == 'E') {
					dnType = 'Tier 1';
					drrReason += 'Employee;';
				} else {
					if (daysMovedSinceOriginal >= daysMovedOriginal || order.Total_Contacts__c >= drMap.get(orderTypeCategory).Maximum_Regular_Notifications__c || order.Merchandise_Subtotal__c >= drMap.get(orderTypeCategory).Order_Amount_Tier_1__c || linesMovedTotal >= drMap.get(orderTypeCategory).Lines_Moved_Amount_Tier_2__c) {
						dnType = 'Tier 3';
						if (order.Total_Contacts__c >= drMap.get(orderTypeCategory).Maximum_Regular_Notifications__c) {
							drrReason += 'Total Contacts;';
						}
						if (order.Merchandise_Subtotal__c >= drMap.get(orderTypeCategory).Order_Amount_Tier_1__c) {
							drrReason += 'Merchandise Subtotal;';
						}
						if (linesMovedTotal >= drMap.get(orderTypeCategory).Lines_Moved_Amount_Tier_2__c) {
							drrReason += 'Lines Moved Total;';
						}
					} else {
						if (linesMovedTotal >= drMap.get(orderTypeCategory).Lines_Moved_Amount_Tier_1__c) {
							dnType = 'Tier 2';
							drrReason += 'Lines Moved Total;';
						} else {
							dnType = 'Tier 1';
						}
					}
				}
			}
			
			// Determine request category based upon delayed order rules and special exceptions
			if (String.isNotBlank(dnType)) {
				requestCategory = 'Automatic Email';
				
				if (drrReason.contains('Days Moved In')) {
					requestCategory = 'Days Moved In';
				} else {
					
					if (order.Email_Contacts__c != null) {
						emailAlerts = order.Email_Contacts__c;
					} else {
						emailAlerts = 0;
					}
					if (order.Callout_Contacts__c != null) {
						callouts = order.Callout_Contacts__c;
					} else {
						callouts = 0;
					}
					if (callouts > 0 && drMap.get(orderTypeCategory).No_Auto_Email_After_Callout__c) {
						requestCategory = 'Callout';
					}
					if (dnType == 'Tier 3' || emailAlerts >= drMap.get(orderTypeCategory).Automatic_Emails__c || String.isBlank(order.Sold_to_Email__c)) {
						requestCategory = 'Callout';
					}
				
					if (daysMovedSinceOriginal >= drMap.get(orderTypeCategory).Days_Moved_Special_Attention__c) {
						requestCategory = 'Special Attention';
						drrReason += 'Special Attention;';
					}
				}
				
				// Set the Gift Card amount
				if (dnType != 'Tier 1' && requestCategory != 'Days Moved In' && requestCategory != 'Special Attention') {
					
					// Determine recommended Gift Card amount
					List<DelayOrderGiftCards__c> gcList = DelayOrderGiftCards__c.getall().values();
					Boolean upToPurchaseValue = false;
					Boolean gcMaxUpToPurchaseValue = false;
					giftCardAmount = null;
					Decimal gcMaxAmount = 0;
					if (linesMovedTotal <= 0) {
						giftCardAmount = 0;
					} else {
						for (DelayOrderGiftCards__c gc :gcList) {
							if (linesMovedTotal > gc.Purchase_Value_Range_Low__c && linesMovedTotal <= gc.Purchase_Value_Range_High__c) {
								if (dnType == 'Tier 2') {
									giftCardAmount = gc.Gift_Card_Tier_1__c;
								} else {
									giftCardAmount = gc.Gift_Card_Tier_2__c;
								}
								upToPurchaseValue = gc.Up_To_Purchase_Value__c;
							}
							if (gcMaxAmount < gc.Gift_Card_Tier_2__c) {
								gcMaxAmount = gc.Gift_Card_Tier_2__c;
								gcMaxUpToPurchaseValue = gc.Up_To_Purchase_Value__c;
							}
						}
						
						if (giftCardAmount == null) {
							giftCardAmount = gcMaxAmount;
							upToPurchaseValue = gcMaxUpToPurchaseValue;
						}
						if (daysMovedSinceOriginal >= drMap.get(orderTypeCategory).Days_Moved_Line_Item_Value_Gift_Card__c && upToPurchaseValue) {
							giftCardAmount = linesMovedTotal;
						}
					}
					
					// Guard against missing/bad Order data
					if (order.Merchandise_Subtotal__c == null || giftCardAmount >= order.Merchandise_Subtotal__c) {
						giftCardAmount = 0;
					}
					
					if (dnType == 'Tier 2') {
						drr.drrCWGiftCard = true;
					}
					drr.drrGiftCardAmount = giftCardAmount;
				}
				
				// Special case zero linesMovedTotal and 'S' SKU Status
				if (skuStatus == 'S' || linesMovedTotal == 0) {
					drr.drrCWGiftCard = false;
					drr.drrGiftCardAmount = 0;
					if (linesMovedTotal == 0 && requestCategory != 'Days Moved In' && requestCategory != 'Special Attention') {
						requestCategory = 'Callout';
					}
				}
				
				// If Automatic Email and Sold To is different from Ship To, set as Manual Email
				if (requestCategory == 'Automatic Email') {
					if ( (order.Sold_to_First_Name__c != shipTo.Ship_to_First_Name__c) || 
						 (order.Sold_to_Last_Name__c != shipTo.Ship_to_Last_Name__c) || 
						 (order.Sold_To_Address_1__c != shipTo.Ship_to_Address_1__c) || 
						 (order.Sold_to_Address_2__c != shipTo.Ship_to_Address_2__c) || 
						 (order.Sold_to_City__c != shipTo.Ship_to_City__c) || 
						 (order.Sold_to_State__c != shipTo.Ship_to_State__c) || 
						 (order.Sold_to_Zip__c != shipTo.Ship_to_Zip__c) ) {
						requestCategory = 'Manual Email';
					}
				}
				
				// If all order lines on the order are swatches, set as 'Swatch"
				if (swatchOrder) {
					requestCategory = 'Swatch';
				}
				
				drr.drrRequestCategory = requestCategory;
				drr.drrReason = drrReason.removeEnd(';');
			}	
		}
		
		// If this is only a stale date order line (it is not also delayed), mark it Invalid
		if (orderLine.StaleDate__c && String.isBlank(drr.drrRequestCategory)) {
			drr.drrRequestCategory = 'Invalid';
		}
		
		system.debug('*****evaluateDelayRules drrRequestCategory = ' + drr.drrRequestCategory + ' swatchOrder = ' + swatchOrder);
		return drr;
	}
	
	private static Case createDelayedOrderCase(Order_Line_Items__c oli, DelayRulesResult drr, Map<Id, Case> oCaseMap) {
		
		// Either create new or update existing case for delayed order action
		String transferTo = Groups__c.getInstance('Order Processing Queue').GroupId__c;
		if (getOrderTypeCategory(oli.RH_Order_Number__r.Order_Type_Code__c) == 'Contract') {
			transferTo = Groups__c.getInstance('Contract Case Queue').GroupId__c;
		}
		
		Case doCase = null;
		Map<String, DelayNotificationTypes__c> rcMap = DelayNotificationTypes__c.getAll();
		String requestCategory = drr.drrRequestCategory;
		if (oli.StaleDate__c) {
			if (rcMap.get('Stale Date').Rank__c > rcMap.get(requestCategory).Rank__c) {
				requestCategory = 'Stale Date';
			}
		}
		Map<String, Schema.RecordTypeInfo> cRTMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
		if (!oCaseMap.containsKey(oli.RH_Order_Number__c)) {
			doCase = new Case(
				OwnerId = transferTo,
				Request_Category__c = requestCategory,
				RecordTypeId = cRTMap.get('Delay Notifications').getRecordTypeId(),
				Delay_Notification_Reason__c = drr.drrReason,
				Calculated_Gift_Card_Amount__c = drr.drrGiftCardAmount,
				Actual_Gift_Card_Amount__c = drr.drrGiftCardAmount,
				RH_Order_Number__c = oli.RH_Order_Number__c
			);
			
		} else {
			
			// There is already an open Delay Notification case, determine if we need to update the Request Category
			if (rcMap.containsKey(oCaseMap.get(oli.RH_Order_Number__c).Request_Category__c)) {
				if (rcMap.get(oCaseMap.get(oli.RH_Order_Number__c).Request_Category__c).Rank__c > rcMap.get(requestCategory).Rank__c) {
					requestCategory = oCaseMap.get(oli.RH_Order_Number__c).Request_Category__c;
				}
			}
			
			// Determine if we should update the gift card amount
			Decimal giftCardAmount = oCaseMap.get(oli.RH_Order_Number__c).Calculated_Gift_Card_Amount__c;
			if (giftCardAmount < drr.drrGiftCardAmount) {
				giftCardAmount = drr.drrGiftCardAmount;
			}
			
			// Combine the current delay notification reason with the new delay notification reason
			Set<String> dnrSet = new Set<String>();
			List<String> dnrCurrent = new List<String>();
			if (String.isNotBlank(oCaseMap.get(oli.RH_Order_Number__c).Delay_Notification_Reason__c)) {
				dnrCurrent = oCaseMap.get(oli.RH_Order_Number__c).Delay_Notification_Reason__c.split(';', 0);
			}
			for (String dnr :dnrCurrent) {
				dnrSet.add(dnr);
			}
			List<String> dnrNew = new List<String>();
			if (String.isNotBlank(drr.drrReason)) {
				dnrNew = drr.drrReason.split(';', 0);
			}
			for (String dnr :dnrNew) {
				dnrSet.add(dnr);
			}
			String dnReason = '';
			for (String dnr :dnrSet) {
				dnReason += dnr + ';';
			}
			if (String.isNotBlank(dnReason)) {
				dnReason = dnReason.removeEnd(';');
			}
			
			// Update the existing case with latest information
			oCaseMap.get(oli.RH_Order_Number__c).Request_Category__c = requestCategory;
			oCaseMap.get(oli.RH_Order_Number__c).Delay_Notification_Reason__c = dnReason;
			oCaseMap.get(oli.RH_Order_Number__c).Calculated_Gift_Card_Amount__c = giftCardAmount;
			oCaseMap.get(oli.RH_Order_Number__c).Actual_Gift_Card_Amount__c = giftCardAmount;
			doCase = oCaseMap.get(oli.RH_Order_Number__c);
		}
		return doCase;
	}
	
	private static Case_Line_Items__c createDelayedOrderCaseLines(Order_Line_Items__c oli, DelayRulesResult drr, Map<Id, Case_Line_Items__c> oliCaseLineMap) {
		
		// Either create new or update existing case line for delayed order action
		Case_Line_Items__c doCaseLineItem = null;
		Map<String, Schema.RecordTypeInfo> cliRTMap = Schema.SObjectType.Case_Line_Items__c.getRecordTypeInfosByName();
		List<DelayedOrderFeed.DelayedOrderFeedHistory> dofhList;
		Integer doNoticeNumber;
		String interimUpdate = '';
		if (drr.drrRequestCategory == 'Callout') {
			interimUpdate = 'Ready for Callout';
		}
		
		doNoticeNumber = null;
		if (oli.DelayFeed__c && String.isNotBlank(oli.Delay_Feed_History__c)) {
			dofhList = new List<DelayedOrderFeed.DelayedOrderFeedHistory>();
			dofhList = (List<DelayedOrderFeed.DelayedOrderFeedHistory>)JSON.deserialize(oli.Delay_Feed_History__c, List<DelayedOrderFeed.DelayedOrderFeedHistory>.class);
			doNoticeNumber = Integer.valueOf(dofhList[0].NN);
		}
		
		if (!oliCaseLineMap.containsKey(oli.Id)) {
			doCaseLineItem = new Case_Line_Items__c(
				RecordTypeId = cliRTMap.get('Delay Notifications').getRecordTypeId(),
				Line_Number__c = oli.Id,
				Delay_Notice_Number__c = doNoticeNumber,
				Interim_Update__c = interimUpdate,
				IsStaleDate__c = oli.StaleDate__c,
				Delay_Notification_Type__c = drr.drrRequestCategory,
				Delay_Notification_Reason__c = drr.drrReason,
				Order__c = oli.RH_Order_Number__c
			);
		} else {
			if (doNoticeNumber != null) {
				oliCaseLineMap.get(oli.Id).Delay_Notice_Number__c = doNoticeNumber;
			}
			oliCaseLineMap.get(oli.Id).Original_Available_Date__c = oli.Original_Available_Date__c;
			oliCaseLineMap.get(oli.Id).Previous_Available_Date__c = oli.Current_Available_Date__c;
			oliCaseLineMap.get(oli.Id).Current_Available_Date__c = oli.Current_Delay_Date__c;
			oliCaseLineMap.get(oli.Id).Delay_Notification_Type__c = drr.drrRequestCategory;
			oliCaseLineMap.get(oli.Id).Delay_Notification_Reason__c = drr.drrReason;
			oliCaseLineMap.get(oli.Id).IsStaleDate__c = oli.StaleDate__c;
			if (oli.StaleDate__c) {
				if (oli.In_Warehouse_Date__c < system.today()) {
					if (oliCaseLineMap.get(oli.Id).Interim_Update__c == 'Ready for Callout' || oliCaseLineMap.get(oli.Id).Interim_Update__c == 'Contact Date Communicated') {
						oliCaseLineMap.get(oli.Id).Interim_Update__c = '';
					}
				} else {
					if (oliCaseLineMap.get(oli.Id).Interim_Update__c != 'Contact Date Communicated') {
						oliCaseLineMap.get(oli.Id).Interim_Update__c = 'Ready for Callout';
					}
				}
			} else {
				oliCaseLineMap.get(oli.Id).Interim_Update__c = interimUpdate;
			}
			doCaseLineItem = oliCaseLineMap.get(oli.Id);
		}
		return doCaseLineItem;
	}
	
	public static Map<String, Boolean> getTodayHolds() {
		
		// Determine today's On Hold state for each order type category
		List<Delayed_Order_Rule__c> drList = new List<Delayed_Order_Rule__c>();
		Map<String, Delayed_Order_Rule__c> drMap = new Map<String, Delayed_Order_Rule__c>();
		drList = [select Id, Name, Order_Type_Category__c from Delayed_Order_Rule__c];
		for (Delayed_Order_Rule__c dr :drList) {
			drMap.put(dr.Order_Type_Category__c, dr);
		}
		List<Date_Range_Hold__c> drHoldList = new List<Date_Range_Hold__c>();
		drHoldList = [select Id, Delayed_Order_Rule__c, Start_Date__c, End_Date__c from Date_Range_Hold__c where Active__c = true];
		Map<String, Boolean> todayHoldsMap = new Map<String, Boolean>();
		for (String otc :drMap.keySet()) {
			todayHoldsMap.put(otc, false);
			for (Date_Range_Hold__c drh :drHoldList) {
				if (drh.Delayed_Order_Rule__c == drMap.get(otc).Id) {
					if (drh.Start_Date__c <= system.today() && drh.End_Date__c > system.today()) {
						todayHoldsMap.put(otc, true);
					}
				}
			}
		}
		return todayHoldsMap;
	}
	
	// Return the Order Type Category based upon the supplied Order Type Code
	public static String getOrderTypeCategory(String orderTypeCode) {
		String category = '';
		
		if (String.isNotBlank(orderTypeCode)) {
			try {
				category = OrderTypeCategory__c.getInstance(orderTypeCode).Category__c;
			} catch(Exception e) {
				system.debug('*****getOrderTypeCategory exception = ' + e.getMessage() + ' orderTypeCode = ' + orderTypeCode);
				category = '';
			}
		}
		return category;
	}
	
	// Update the status/type of Delay Notification case based upon latest order/order line data
	public static void updateDelayNotificationCases(List<SObject> recordsToupdate, Set<Id> oIds) {
		
		Map<Id, Case> cMap = null;
		Map<Id, Case_Line_Items__c> cliMap = null;
		Map<String, Schema.RecordTypeInfo> rtCaseMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
		
		// Get the open Delay Notification cases/case lines associated with the order Ids or order line Ids
		if (!oIds.isEmpty()) {
			cMap = new Map<Id, Case>([select Id, Status, Order_Status__c, Request_Category__c, RH_Order_Number__c 
					from Case where RH_Order_Number__c in :oIds and IsClosed = false and WasReopened__c = false 
					and Gift_Card_Status__c = null and RecordTypeId = :rtCaseMap.get('Delay Notifications').getRecordTypeId()]);
			
			if (!cMap.isEmpty()) {
				cliMap = new Map<Id, Case_Line_Items__c>([select Id, Case_Number__c, Backorder_Quantity__c, Delay_Notification_Type__c, 
						IsStaleDate__c, Line_Number__c, Line_Status_Description__c, In_Warehouse_Date__c 
						from Case_Line_Items__c where Case_Number__c in :cMap.keySet()]);
			}
			
		}
		
		// Update each of the open Delay Notification cases/case lines
		if (cMap != null && !cMap.isEmpty()) {
			
			String orderStatus;
			for (Case_Line_Items__c cli :cliMap.values()) {
					
				// Update delayed order state - set to invalid if no longer backordered
				if ( (!(cli.Backorder_Quantity__c > 0)) || String.isBlank(cli.Delay_Notification_Type__c) ||
					 (cli.Line_Status_Description__c != 'Open' && cli.Line_Status_Description__c != 'Held')) {
					cli.Delay_Notification_Type__c = 'Invalid';
					cli.IsStaleDate__c = false;
				} else {
					if (cli.In_Warehouse_Date__c == null || cli.In_Warehouse_Date__c >= system.today()) {
						cli.IsStaleDate__c = false;
					}
				}
				
				// Update delayed order state - set to invalid based upon order status
				if (cMap.containsKey(cli.Case_Number__c)) {
					orderStatus = cMap.get(cli.Case_Number__c).Order_Status__c;
					if (orderStatus != 'Open' && orderStatus != 'In Process' && orderStatus != 'Held') {
						cli.Delay_Notification_Type__c = 'Invalid';
					}
				}
			}
			
			// Update each case based upon their updated case lines
			for (Case c :cMap.values()) {
				c.Request_Category__c = 'Invalid';
			}
			
			Map<String, DelayNotificationTypes__c> dntMap = DelayNotificationTypes__c.getAll();
			String dnType;
			for (Case_Line_Items__c cli :cliMap.values()) {
				if (cMap.containsKey(cli.Case_Number__c)) {
					
					if (dntMap.containsKey(cli.Delay_Notification_Type__c)) {
						if (cli.IsStaleDate__c && dntMap.get('Stale Date').Rank__c > dntMap.get(cli.Delay_Notification_Type__c).Rank__c) {
							dnType = 'Stale Date';
						} else {
							dnType = cli.Delay_Notification_Type__c;
						}
						
						if (dntMap.get(dnType).Rank__c > dntMap.get(cMap.get(cli.Case_Number__c).Request_Category__c).Rank__c) {
							cMap.get(cli.Case_Number__c).Request_Category__c = dnType;
						}
					}
				}
			}
			
			// Mark all invalid cases for closure
			for (Case c :cMap.values()) {
				if (c.Request_Category__c == 'Invalid' || c.Request_Category__c == 'Days Moved In') {
					c.Status = 'Closed - Invalid';
				}
			}
			
			recordsToupdate.addAll((List<SObject>)cliMap.values());
			recordsToupdate.addAll((List<SObject>)cMap.values());
		}
	}
	
	/*
	public static void updateDelayNotificationCases(Map<Id, Case> cMap, Map<Id, Case_Line_Items__c> cliMap) {
		
		for (Case_Line_Items__c cli :cliMap.values()) {
			
			if (cli.IsStaleDate__c) {
				// Update stale date state - set to invalid if no longer stale
				if ((!(cli.Backorder_Quantity__c > 0)) || (cli.Line_Status_Description__c != 'Open' && cli.Line_Status_Description__c != 'Held')) {
					cli.IsStaleDate__c = false;
				} else {
					if (cli.In_Warehouse_Date__c == null || cli.In_Warehouse_Date__c >= system.today()) {
						cli.IsStaleDate__c = false;
					}
				}
				
			}
				
			// Update delayed order state - set to invalid if no longer backordered
			if (!(cli.Backorder_Quantity__c > 0) || String.isBlank(cli.Delay_Notification_Type__c)) {
				cli.Delay_Notification_Type__c = 'Invalid';
			}
		}
		
		// Update each case based upon their updated case lines
		for (Case c :cMap.values()) {
			c.Request_Category__c = 'Invalid';
		}
		Map<String, DelayNotificationTypes__c> dntMap = DelayNotificationTypes__c.getAll();
		String dnType;
		for (Case_Line_Items__c cli :cliMap.values()) {
			if (cMap.containsKey(cli.Case_Number__c)) {
				
				if (dntMap.containsKey(cli.Delay_Notification_Type__c)) {
					if (cli.IsStaleDate__c && dntMap.get('Stale Date').Rank__c > dntMap.get(cli.Delay_Notification_Type__c).Rank__c) {
						dnType = 'Stale Date';
					} else {
						dnType = cli.Delay_Notification_Type__c;
					}
					
					if (dntMap.get(dnType).Rank__c > dntMap.get(cMap.get(cli.Case_Number__c).Request_Category__c).Rank__c) {
						cMap.get(cli.Case_Number__c).Request_Category__c = dnType;
					}
				}
			}
		}
	}
	*/
}