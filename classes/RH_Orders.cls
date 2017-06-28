/**
 * @description Domain class for RH_Order__c object. 
 *  Handles all functionality for its respective object,
 *  deferring complex implementations to helper classes.
 * @author John Rogers, Traction on Demand
 * @date 17-02-2016
 */
public class RH_Orders extends SObjectDomain {

	private @testVisible List<Order_SSV_Field_Mapping__c> orderMapSettings {
		get {
			if(orderMapSettings == null) {
				orderMapSettings = Order_SSV_Field_Mapping__c.getAll().values();
			}

			return orderMapSettings;
		} private set;
	}    

    public RH_Orders() {
        super();
    }

    public override void handleBeforeInsert() {
		if (!UserHelper.isIntegrationUser()) {
	        setLookups(records);
	        linkToExistingContact(records);
		}        
    }

    public override void handleBeforeUpdate(Map<Id, SObject> oldRecordMap) {
    	if (!UserHelper.isIntegrationUser()) {
	        handleSSVChanges(oldRecordMap);
		}        

    }

    public override void handleAfterUpdate(Map<Id, SObject> oldRecordMap) {
    	if (!UserHelper.isIntegrationUser()) {
    		// update ship-to
        	recordsToUpdate((List<SObject>) updateShipToChildren(oldRecordMap));
        	// handle creating SSV if one not already created
        	handleSSVCreation(oldRecordMap);
    	}
    }

    public override void handleAfterInsert() {
		if (!UserHelper.isIntegrationUser()) {
    		handleSSVCreation(null);
		}
    }
    
    /*
     * Link to any contacts that we know already exist
     * Company first (via trade-id)
     */
    
    private @testvisible void linkToExistingContact(List<RH_Order__c> orders) {
    	
    	// return if empty
    	if (orders == null || orders.size() < 1) {
    		system.debug('empty orders');
    		return;
    	}
    	    	    	
    	// build up a set of trade IDs
    	system.debug('build up a set of trade IDs');
    	Set<String> tradeIds = new Set<String>();
    	for(RH_Order__c triggerOrder : orders) {
    		if (triggerOrder.Trade_ID__c != null) {
    			tradeIds.add(triggerOrder.Trade_ID__c);
    		}
    	}
    	
    	// query all the accounts with those trade ids
    	system.debug('query all the accounts with those trade ids');
		List<Account> accounts = [
            SELECT ID, X12_Digit_Member__c, Name 
            FROM Account
            WHERE X12_Digit_Member__c IN :tradeIds
        ];    	
    	
    	// create a map based on trade ID
    	system.debug('create a map based on trade ID');
        Map<String, Account> existing = new Map<String, Account>();
        MapUtils.mapByField(existing, accounts, Account.X12_Digit_Member__c);   	
        
        // assign existing accounts to order matching on trade ID.  
        system.debug('loop through orders, linking to matching account by trade-id');  	
		for(RH_Order__c orderRecord : orders) {
			if (orderRecord.Trade_ID__c != null) {
				system.debug('order has a trade ID');
				if (existing.containsKey(orderRecord.Trade_ID__c)) {
					system.debug('account with that trade id is found');
					orderRecord.Account_Sold_To__c = existing.get(orderRecord.Trade_ID__c).ID;
			
			//source for this order value is CW, order values should not be updated programatically 		
			//		orderRecord.Sold_to_Company__c = existing.get(orderRecord.Trade_ID__c).Name;	
			
				} else {
					system.debug('no matching account - remove the trade id from the order');
				//should not overwrite value provided from CW
				//	orderRecord.Trade_ID__c = null; 
				}				
			} 
		}
		        
    }
    
    /**
     * Spawn SSV records when a new order is created/updated
     * An SSV is spawned if:
     * 1. This is an insert and the sold to customer number is already populated.
     * 2. This is an update adn the sold to customer number is being populated for the FIRST time (and no existing SSV is already attached to the order)
     */
     
    private @testvisible void handleSSVCreation(Map<Id, SObject> oldRecordMap) {
    	
    	Reporter.log('Checkpoint - Order SSV Creation Start: ' +  Datetime.now().getTime());
    	
		// handle records    	
		for(RH_Order__c orderRecord : (List<RH_Order__c>) records) {
			if (oldRecordMap == null) {
				if (orderRecord.Sold_To_Customer_Number__c != null) {
					Source_System_View__c newSSV = SSVLoader.createSSV(orderRecord, orderMapSettings); 
					// add the SSV
					system.debug('creating an ssv for record with id ' + orderRecord.Id + ' and customer number ' + orderRecord.Sold_To_Customer_Number__c);
					recordsToInsert.add(newSSV);
				}
			} else {
				RH_Order__c existingRecord = (RH_Order__c) oldRecordMap.get(orderRecord.Id);
				if (orderRecord.Sold_To_Customer_Number__c != null  && orderRecord.Source_System_View_Sold_To__c == null && (existingRecord == null || existingRecord.Sold_To_Customer_Number__c == null)) {
					Source_System_View__c newSSV = SSVLoader.createSSV(orderRecord, orderMapSettings);
					// add the SSV					
					system.debug('creating an ssv for record with id ' + orderRecord.Id + ' and customer number ' + orderRecord.Sold_To_Customer_Number__c);
					recordsToInsert.add(newSSV);					
				}				
			}
		}
		
		Reporter.log('Checkpoint - Order SSV Creation Stop: ' +  Datetime.now().getTime());
    } 
    

    /**
     * @description Handles updates to the Sold_To_Customer_Number__c and Source_System_View_Sold_To__c fields
     * @author John Rogers, Traction on Demand
     * @date 2016-02-19
     * @param oldRecordMap : The records prior to update
     */
    private void handleSSVChanges(Map<Id, SObject> oldRecordMap) {
        // If related ssv changes update lookups
        List<RH_Order__c> ssvChanged = new List<RH_Order__c>();
        for (RH_Order__c order : (List<RH_Order__c>) records) {
            RH_Order__c oldOrder = (RH_Order__c) oldRecordMap.get(order.Id);
            if (oldOrder.Sold_To_Customer_Number__c != order.Sold_To_Customer_Number__c) {
            	order.AuditLog__c += (oldOrder.Sold_To_Customer_Number__c + '->');
                ssvChanged.add(order);
            }
        }
        if (!ssvChanged.isEmpty()) {
        	Reporter.log('updated records contain changes to Sold_To_Customer_Number__c: ' + ssvChanged.size());
	        setLookups(ssvChanged);
        }
    }

    /**
     * @description Given a list of orders, sets the Source_System_View_Sold_To__c lookup to
     *              the SSV record SSV.EXT_Source_System_Customer_ID__c = order.Sold_To_Customer_Number__c 
     *              or if Sold_To_Customer_Number__c is null and Source_System_View_Sold_To__c is not,
     *              sets Source_System_View_Sold_To__c by SSV record SSV.Id = order.Source_System_View_Sold_To__c
     * @author John Rogers, Traction on Demand
     * @date        2016-02-18
     * @param       orders : orders to set the lookups on
     */
    private void setLookups(List<RH_Order__c> orders) {
        
        Set<String> custNums = new Set<String>();
        for (RH_Order__c order : orders) {
            if (!String.isBlank(order.Sold_To_Customer_Number__c)) {
                custNums.add(order.Sold_To_Customer_Number__c);
            }
        }

        if (custNums.isEmpty()) {
            return;
        }

        List<Source_System_View__c> ssvs = [
            SELECT EXT_Source_System_Customer_ID__c, 
                    Account__c, 
                    Contact__c, 
                    Customer_Address__c
            FROM Source_System_View__c
            WHERE EXT_Source_System_Customer_ID__c IN :custNums
        ];

        setOrderLookupsFromSSV(orders, ssvs);
    }

    /**
     *  @description Given a list of orders with Sold To customer numbers:
     *               Sets the order lookups to SSV, Account, Contact, and Address
     *               equal to the corresponding Customer Number SSV values
     *  @author      Ernesto Valdes, Traction on Demand.
     *  @date        2016-02-23
     *  @param       orders        The orders to link using customer number
     *  @param       custNumToSSV  The source sytem view records from which to get lookup values
     */
     
    public static void setOrderLookupsFromSSV(List<RH_Order__c> orders, 
                                        List<Source_System_View__c> ssvs) {
                                        	
        Map<String, Source_System_View__c> custNumToSSV = new Map<String, Source_System_View__c>();
        MapUtils.mapByField(custNumToSSV, ssvs, Source_System_View__c.EXT_Source_System_Customer_ID__c);

        for (RH_Order__c order : orders) {
        	if (custNumToSSV.containsKey(order.Sold_To_Customer_Number__c)) {
	            Source_System_View__c ssv = custNumToSSV.get(order.Sold_To_Customer_Number__c);	
	            if (order.Source_System_View_Sold_To__c != ssv.Id ||
	                order.Account_Sold_To__c != ssv.Account__c ||
	                order.Contact_Sold_To__c != ssv.Contact__c ||
	                order.Customer_Address_Sold_To__c != ssv.Customer_Address__c) {
	                	
				    order.Source_System_View_Sold_To__c = ssv.Id;
				    order.Account_Sold_To__c = ssv.Account__c;
				    order.Contact_Sold_To__c = ssv.Contact__c;
				    order.Customer_Address_Sold_To__c = ssv.Customer_Address__c;
	            }
        	}
        }
    }

    /**
     * @description Called within after update context will copy lookup field values to 
     *              children Ship_To__c records with Ship_To_Customer_Number__c = '0'
     * @author John Rogers, Traction on Demand
     * @date 2016-02-18
     * @param  oldRecordMap : The records prior to update
     * @return Children records to update
     */
     
    private List<Ship_To__c> updateShipToChildren(Map<Id, SObject> oldRecordMap) {
    	
        // If various lookups have changed, pass changes down to children
        
        List<RH_Order__c> changedOrders = new List<RH_Order__c>();
        for (RH_Order__c order : (List<RH_Order__c>) records) {
        	if (oldRecordMap.containsKey(order.Id)) {
	            RH_Order__c oldOrder = (RH_Order__c) oldRecordMap.get(order.Id);
	            if (oldOrder.Source_System_View_Sold_To__c != order.Source_System_View_Sold_To__c ||
	                    oldOrder.Account_Sold_To__c != order.Account_Sold_To__c ||
	                    oldOrder.Contact_Sold_To__c != order.Contact_Sold_To__c ||
	                    oldOrder.Customer_Address_Sold_To__c != order.Customer_Address_Sold_To__c) {
	                changedOrders.add(order);
	            }
        	}
        }

        if (changedOrders.isEmpty()) {
            return new List<Ship_To__c>();
        }

        return setShipToLookupsFromOrder(changedOrders);
    }

    /**
     *  @description For a given list of orders, gets the Ship_To__c records that
     *               share the same customer as the order, and update these Ship_To__c records
     *               to match the order's Account/Contact/CustomerAddress lookups
     *  @author      Ernesto Valdes, Traction on Demand.
     *  @date        2016-02-24
     *  @param       orders        The orders for which to set Ship_To__c lookups
     *  @return                    The updated Ship_To__c records
     */
     
    public static List<Ship_To__c> setShipToLookupsFromOrder(List<RH_Order__c> orders) {

        List<Ship_To__c> toUpdate = new List<Ship_To__c>();

        // Get map of orders to their shipTo children
        Map<Id, List<SObject>> orderToShipTos = MapUtils.mapByIdFieldToList([
            SELECT Order__c, CW_Customer_Ship_To__c, Account_Ship_To__c, 
                    Contact_Ship_To__c, Customer_Address_Ship_To__c
            FROM Ship_To__c
            WHERE Ship_To_Customer_Number__c = '0' AND
                Order__c IN :orders
        ], Ship_To__c.Order__c);

        // Copy order info over to shipTo children
        for (RH_Order__c order : orders) {

            if (orderToShipTos.containsKey(order.Id)) {
                for (Ship_To__c shipTo : (List<Ship_To__c>) orderToShipTos.get(order.Id)) {

                    if (shipTo.CW_Customer_Ship_To__c != order.Source_System_View_Sold_To__c ||
		                shipTo.Account_Ship_To__c != order.Account_Sold_To__c ||
		                shipTo.Contact_Ship_To__c != order.Contact_Sold_To__c ||
		                shipTo.Customer_Address_Ship_To__c != order.Customer_Address_Sold_To__c) {
                    	
				        shipTo.CW_Customer_Ship_To__c = order.Source_System_View_Sold_To__c;
				        shipTo.Account_Ship_To__c = order.Account_Sold_To__c; 
				        shipTo.Contact_Ship_To__c = order.Contact_Sold_To__c;
				        shipTo.Customer_Address_Ship_To__c = order.Customer_Address_Sold_To__c;                        
                        toUpdate.add(shipTo);
                    }
                }
            }
        }
        return toUpdate;
    }

}