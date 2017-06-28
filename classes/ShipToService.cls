public with sharing class ShipToService {
    
    private static @testVisible Set<Schema.SObjectField> addressFields = new Set<Schema.SObjectField> {
        Ship_To__c.Name__c,
        Ship_To__c.Ship_to_Company__c,
        Ship_To__c.Ship_to_Address_1__c,
        Ship_To__c.Ship_to_Address_2__c,
        Ship_To__c.Ship_to_City__c,
        Ship_To__c.Ship_to_State__c,
        Ship_To__c.Ship_to_Zip__c,
        Ship_To__c.Ship_to_Country__c
    };
    
    /*
     * IF an update to an existing order changes the existing Contact to a new Contact
     * Remove all references to the contact-address objects
     */
     
    public static void handleContactChange(List<Ship_To__c> shipTos, Map<Id, Ship_To__c> oldMap) {
    	system.debug('ShipToService -> handleContactChange -> ' + shipTos);
        if (oldMap != null) {
            for (Ship_To__c shipTo : shipTos) {
                if (oldMap.get(shipTo.id).Contact_Ship_To__c != null && shipTo.Contact_Ship_To__c != oldMap.get(shipTo.id).Contact_Ship_To__c) {                	
                    system.debug('ShipToService -> handleContactChange -> Contact_Ship_To__c changed -> ' + shipTo);                    
                    shipTo.Address_Ship_To__c = null;
                } else if (oldMap.get(shipTo.id).Contact_Sold_To__c != null && shipTo.Contact_Sold_To__c != oldMap.get(shipTo.id).Contact_Sold_To__c) {
                	system.debug('ShipToService -> handleContactChange -> Contact_Sold_To__c changed -> ' + shipTo);
                	shipTo.Address_Ship_To__c = null;
                }
            }
        }
    }
    
    public static void handleAddressChange(List<Ship_To__c> shipTos, Map<Id, Ship_To__c> oldMap) {
        for (Ship_To__c shipTo : shipTos) {
            if (oldMap == null || Utility.hasChanges(shipTo, oldMap.get(shipTo.id), addressFields)) {
                shipTo.Ship_To_Contact_Address__c = Utility.aggregateFields(shipTo, addressFields, ', ');  
            }                                                       
        }   
    }
            
}