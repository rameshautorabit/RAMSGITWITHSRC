/**
 * @description Domain class for Ship_To__c object. 
 *  Handles all functionality for its respective object,
 *  deferring complex implementations to helper classes.
 * @author John Rogers, Traction on Demand
 * @date 17-02-2016
 */
public class Ship_Tos extends SObjectDomain {

    public Ship_Tos() {
        super();
    }

    /**
     *  @description Constructor, casts given records to appropiate type
     *  @author      Ernesto Valdes, Traction on Demand.
     *  @date        2015-11-03
     *  @param       records       List of sObjects (should be of type Ship_To__c)
     */
    public Ship_Tos(List<Ship_To__c> records) {
        super();
        this.records = records;
    }

    public override void handleBeforeInsert() {
    	if (!UserHelper.isIntegrationUser()) {
        	setLookups(records);
    	}
    }

    public override void handleBeforeUpdate(Map<Id, SObject> oldRecordMap) {
    	if (!UserHelper.isIntegrationUser()) {
	        List<Ship_To__c> updateLookups = new List<Ship_To__c>();
	        for (Ship_To__c shipTo : (List<Ship_To__c>) records) {
	            Ship_To__c oldShipTo = (Ship_To__c) oldRecordMap.get(shipTo.Id);
	            // If Ship_To_Customer_Number__c changes
	            if (oldShipTo.Ship_To_Customer_Number__c != shipTo.Ship_To_Customer_Number__c) {
	                // Update lookups
	                updateLookups.add(shipTo);
	            }
	        }
	        setLookups(updateLookups);
    	}
    }   

    /**
     * @description Given a list of ship to records set the SSV lookup and related lookup values
     * @author John Rogers, Traction on Demand
     * @date 2016-02-18
     * @param shipTos : The ship to records to update the lookups for 
     */
    private void setLookups(List<Ship_To__c> shipTos) {
        // If Ship_To_Customer_Number__c is zero set CW_Customer_Ship_To__c to parent order lookup (ship to = sold to)
        List<Ship_To__c> shipToOrder = new List<Ship_To__c>();

        /* 
           If Ship_To_Customer_Number__c is non-zero set lookups by Ship_To_Customer_Number__c
           If Ship_To_Customer_Number__c is null AND the CW_Customer_Ship_To__c is non null set lookups by CW_Customer_Ship_To__c
           (ship to != sold to)
        */
        List<Ship_To__c> shipToSsv = new List<Ship_To__c>();

        // Sort the shipTo records
        for (Ship_To__c shipTo : (List<Ship_To__c>) shipTos) {
            if (shipTo.Ship_To_Customer_Number__c == '0') {
                shipToOrder.add(shipTo);
            } else if (shipTo.Ship_To_Customer_Number__c != '0' && shipTo.Ship_To_Customer_Number__c != null) {
                shipToSsv.add(shipTo);
            }
        }

        // Set the CW_Customer_Ship_To__c and other lookups appropriately
        setLookupsByOrder(shipToOrder);
        setLookupsBySSV(shipToSsv);
    }

    /**
     * @description Given a list of shipTos, sets the lookups to the parent
     *              order's lookup values
     * @author John Rogers, Traction on Demand
     * @date        2016-02-18
     * @param       shipTos : shipTo records to set the lookups on
     */
    private void setLookupsByOrder(List<Ship_To__c> shipTos) {
        if (shipTos.isEmpty()) {
            return;
        }

        Set<Id> orderIds = ListUtils.collectIds(shipTos, Ship_To__c.Order__c);

        if (orderIds.isEmpty()) {
            return;
        }

        Map<Id, RH_Order__c> orders = new Map<Id, RH_Order__c>([
            SELECT Source_System_View_Sold_To__c,
                Account_Sold_To__c,
                Contact_Sold_To__c,
                Customer_Address_Sold_To__c
            FROM RH_Order__c
            WHERE Id IN :orderIds
        ]);

        for (Ship_To__c shipTo : shipTos) {
            RH_Order__c parent = orders.get(shipTo.Order__c);
            if (parent != null) {
                shipTo.CW_Customer_Ship_To__c = parent.Source_System_View_Sold_To__c;
                shipTo.Account_Ship_To__c = parent.Account_Sold_To__c;
                shipTo.Contact_Ship_To__c = parent.Contact_Sold_To__c;
                shipTo.Customer_Address_Ship_To__c = parent.Customer_Address_Sold_To__c;
            }
        }
    }

    /**
     * @description Given a list of shipTos, sets lookups by the SSV record 
     *              SSV.EXT_Source_System_Customer_ID__c = shipTo.Ship_To_Customer_Number__c or
     *              if Ship_To_Customer_Number__c is null, sets lookups by the SSV record
     *              SSV.Id = shipTo.CW_Customer_Ship_To__c
     * @author John Rogers, Traction on Demand
     * @date        2016-02-18
     * @param       shipTos : shipTo records to set the lookups on
     */
    private void setLookupsBySSV(List<Ship_To__c> shipTos) {
        // Collect Ship_To_Customer_Number__c values
        Set<String> custNums = new Set<String>();
        for (Ship_To__c shipTo : shipTos) {
            if (!String.isBlank(shipTo.Ship_To_Customer_Number__c)) {
                custNums.add(shipTo.Ship_To_Customer_Number__c);
            }
        }

        if (custNums.isEmpty()) {
            return;
        }

        // Get related SSV records
        List<Source_System_View__c> ssvs = [
            SELECT EXT_Source_System_Customer_ID__c,
                Account__c,
                Contact__c,
                Customer_Address__c
            FROM Source_System_View__c
            WHERE EXT_Source_System_Customer_ID__c IN :custNums
        ];

        setShipToLookupsFromSSV(shipTos, ssvs);
    }

    public static void setShipToLookupsFromSSV(List<Ship_To__c> shipTos,
                                                List<Source_System_View__c> ssvs) {

        Map<String, Source_System_View__c> custNumToSSV = new Map<String, Source_System_View__c>();
        MapUtils.mapByField(custNumToSSV, ssvs, Source_System_View__c.EXT_Source_System_Customer_ID__c);

        for (Ship_To__c shipTo : shipTos) {
            Source_System_View__c ssv = custNumToSSV.get(shipTo.Ship_To_Customer_Number__c);

            if (ssv != null) {
                shipTo.CW_Customer_Ship_To__c = ssv.Id;
                shipTo.Account_Ship_To__c = ssv.Account__c;
                shipTo.Contact_Ship_To__c = ssv.Contact__c;
                shipTo.Customer_Address_Ship_To__c = ssv.Customer_Address__c;
            }
        }
    }
}