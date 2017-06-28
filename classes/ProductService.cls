public class ProductService {
	
	/*
	 *	Service methods for ProductTrigger.trigger.
	 *
	 */
	
	// Calculate total quantity on hand from JSON string data in Inventory field.
	// - before insert, before update
	public static void totalQuantityOnHand(List<Product2> newList, Map<Id, Product2> oldMap, Boolean isInsert) {
		List<InventoryInfo> inventoryInfoList = new List<InventoryInfo>();
		Decimal qty;
		
		for (Product2 p :newList) {
			inventoryInfoList.clear();
			
			if (String.isNotBlank(p.Inventory__c)) {
				if (isInsert) {
					inventoryInfoList = (List<InventoryInfo>)JSON.deserialize(p.Inventory__c, List<InventoryInfo>.class);
				}
				
				if (!isInsert) {
					if (p.Inventory__c != oldMap.get(p.Id).Inventory__c) {
						inventoryInfoList = (List<InventoryInfo>)JSON.deserialize(p.Inventory__c, List<InventoryInfo>.class);
					}
				}
				
				if (!inventoryInfoList.isEmpty()) {
					qty = 0;
					for (InventoryInfo inv :inventoryInfoList) {
						if (String.isNotBlank(inv.skuQty)) {
							qty += Decimal.valueOf(inv.skuQty);
						}
					}
					p.Total_Quantity_On_Hand__c = qty;
				}
			}
		}
	}
	
	// Update contract only product records with data from their non-contract product record
	// - before insert, after insert, after update
	public static void contractOnlySKU(List<Product2> newList, Map<Id, Product2> oldMap, Boolean isBefore, Boolean isInsert) {
		String skuNames;
		List<Product2> skuList = new List<Product2>();
		Map<String, Product2> skuMap = new Map<String, Product2>();
		
		Map<String, ContractOnlySkuFields__c> fieldMap = ContractOnlySkuFields__c.getAll();
		String queryFields = 'Id,Name,Core_Cross_Reference_SKU__c,ContractOnlySKU__c,';
		for (ContractOnlySkuFields__c cosf :fieldMap.values()) {
			queryFields += cosf.API_Name__c + ',';
		}
		queryFields = queryFields.removeEnd(',');
		
		if (isBefore && isInsert) {
			
			// For all contract SKUs (any SKU with non-blank Core_Cross_Reference_SKU) being inserted, get the corresponding core SKU
			skuNames = '(';
			for (Product2 p :newList) {
				if (String.isNotBlank(p.Core_Cross_Reference_SKU__c)) {
					skuNames += '\'' + p.Core_Cross_Reference_SKU__c + '\',';
				}
			}
			skuNames = skuNames.removeEnd(',');
			skuNames += ')';
			
			if (skuNames != '()') {
				skuList = Database.query('SELECT ' + queryFields + ' FROM Product2 WHERE Name IN ' + skuNames);
				for (Product2 p :skuList) {
					skuMap.put(p.Name, p);
				}
				
				// Copy data from the core SKU to the corresponding contract SKU
				for (Product2 p :newList) {
					if (skuMap.containsKey(p.Core_Cross_Reference_SKU__c)) {
						for (ContractOnlySkuFields__c cosf :fieldMap.values()) {
							p.put(cosf.API_Name__c, skuMap.get(p.Core_Cross_Reference_SKU__c).get(cosf.API_Name__c));
						}
					}
				}
			}
		}
		
		if (!isBefore) {
			
			// For all core SKUs being inserted or updated get the corresponding contract SKU
			Boolean copySkuData;
			skuNames = '(';
			for (Product2 p :newList) {
				if (String.isNotBlank(p.ContractOnlySKU__c)) {
					copySkuData = false;
					
					if (isInsert) {
						copySkuData = true;
					} else {
						if (p.ContractOnlySKU__c != oldMap.get(p.Id).ContractOnlySKU__c) {
							copySkuData = true;
						}
						for (ContractOnlySkuFields__c cosf :fieldMap.values()) {
							if (p.get(cosf.API_Name__c) != oldMap.get(p.Id).get(cosf.API_Name__c)) {
								copySkuData = true;
							}
						}
					}
					
					if (copySkuData) {
						skuNames += '\'' + p.ContractOnlySKU__c + '\',';
						skuMap.put(p.Name, p);
					}
				}
			}
			skuNames = skuNames.removeEnd(',');
			skuNames += ')';
			
			if (skuNames != '()') {
				skuList = Database.query('SELECT ' + queryFields + ' FROM Product2 WHERE Name IN ' + skuNames);
				
				// Copy data from the core SKU to the corresponding contract SKU
				for (Product2 p :skuList) {
					if (skuMap.containsKey(p.Core_Cross_Reference_SKU__c)) {
						for (ContractOnlySkuFields__c cosf :fieldMap.values()) {
							p.put(cosf.API_Name__c, skuMap.get(p.Core_Cross_Reference_SKU__c).get(cosf.API_Name__c));
						}
					}
				}
				
				if (!skuList.isEmpty()) {
					update skuList;
				}
			}
		}
	}
}