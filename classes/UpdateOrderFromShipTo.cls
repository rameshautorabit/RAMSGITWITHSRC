/**
    Description: UpdateOrderFromShipTo class defaults the fields on the first Ship To record on a RH Order Header Record
    Author:vk@ff
    Trigger: ShipTo_Trigger
    Test Class:
    Change Log: 
        * V0.1- Initial
        * V1.0- 
**/

public without sharing class UpdateOrderFromShipTo {
	
	public static List<Id> generateUpdatedList(List<Ship_To__c> records, Map<Id, Ship_To__c> oldMap) {		
		List<Id> shipToIds = new List<Id>();
		for (Ship_To__c record : records) {			
			if (record.Name.equals('1')) {			
				if (oldMap == null) { 
					shipToIds.add(record.Order__c);
				} else {
					Ship_To__c existing = oldMap.get(record.id);
					if (record.Ship_to_Address__c != existing.Ship_to_Address__c 
						|| record.Ship_to_Email__c != existing.Ship_to_Email__c 
						|| record.Name__c != existing.Name__c 
						|| record.Ship_to_Day_Phone__c != existing.Ship_to_Day_Phone__c 
						|| record.Ship_to_Night_Phone__c != existing.Ship_to_Night_Phone__c) {
						shipToIds.add(record.Order__c);
					}	
				}
			}			
		}
		return shipToIds;
	}
	
    public static void updateOrderHeader(List<Id> lstOfRHOIds)
    {        
    	if (lstOfRHOIds == null || lstOfRHOIds.size() < 1) {
    		return;
    	}
    	
        List<RH_Order__c> lstOfOrders = [
        	SELECT Id, Ship_To_1_Order_Description__c, Sold_to_Name__c, Sold_to_Address__c,New_Sold_to_Day_Phone__c, New_Sold_to_Night_Phone__c, Sold_to_Email__c, (
        		SELECT Id,Name, Order_Description__c, Order__c, Name__c, Ship_to_Address__c, Ship_to_Day_Phone__c, Ship_to_Night_Phone__c, Ship_to_Email__c,Ship_to_Company__c,Ship_to_Address_1__c, Ship_to_Address_2__c , Ship_to_City__c , Ship_to_State__c , Ship_to_Zip__c ,Ship_to_Country__c,Ship_to_First_Name__c,Ship_to_Last_Name__c  
        		FROM Ship_Tos__r  
        		WHERE Name='1' LIMIT 1
    		) 
			FROM RH_Order__c 
			WHERE Id IN: lstOfRHOIds
		];
        
        for(RH_Order__c rho: lstOfOrders)
        {
            for(Ship_To__c st: rho.Ship_Tos__r)
            {            
                if(st.Order_Description__c != null){
                   rho.Ship_To_1_Order_Description__c = st.Order_Description__c;
                }         
                
                // Copy Ship To Name
                
                rho.ShipTo1_Name__c = '';
                if (String.isNotBlank(st.Ship_to_Last_Name__c)) {
                    rho.ShipTo1_Name__c = st.Ship_to_Last_Name__c;
                }
                if (String.isNotBlank(st.Ship_to_First_Name__c)) {
                    if (String.isNotBlank(rho.ShipTo1_Name__c)) {
                        rho.ShipTo1_Name__c += ', ';
                    }
                    rho.ShipTo1_Name__c += st.Ship_to_First_Name__c;
                }
                
                // Copy Ship To Address
                
                rho.ShipTo1_Address__c='';

                rho.ShipTo1_Address__c+='\r\n';
                if (String.isNotBlank(st.Ship_to_Address_1__c))
                {
                    rho.ShipTo1_Address__c += st.Ship_to_Address_1__c + '\r\n';
                }
                
                if (String.isNotBlank(st.Ship_to_Address_2__c))
                {
                    rho.ShipTo1_Address__c += st.Ship_to_Address_2__c+ '\r\n';
                }
                
                if(String.isNotBlank(st.Ship_to_Company__c))
                {
                    rho.ShipTo1_Address__c += st.Ship_to_Company__c;
                }
                
                else
                {
                    rho.ShipTo1_Address__c += '';
                }
                
                
                rho.ShipTo1_Address__c += '\r\n';
                if (String.isNotBlank(st.Ship_to_City__c))
                {
                    rho.ShipTo1_Address__c += st.Ship_to_City__c;
                }
                if (String.isNotBlank(st.Ship_to_State__c))
                {
                    rho.ShipTo1_Address__c += ' ' + st.Ship_to_State__c;
                }
                if (String.isNotBlank(st.Ship_to_Zip__c))
                {
                    rho.ShipTo1_Address__c += ', ' + st.Ship_to_Zip__c;
                }
                if (String.isNotBlank(st.Ship_to_Country__c))
                {
                    rho.ShipTo1_Address__c += '\r\n' + st.Ship_to_Country__c;
                }
                
                //Copy phone and email
                rho.ShipTo1_Day_Phone__c = st.Ship_to_Day_Phone__c;
                rho.ShipTo1_Night_Phone__c = st.Ship_to_Night_Phone__c;
                rho.ShipTo1_Email__c = st.Ship_to_Email__c;
            }
        }
        
        if (!lstOfOrders.isEmpty()) {
        	update lstOfOrders;
        }

   }
}