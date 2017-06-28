public with sharing class Product_InventoryCtrlExt{
	    
    private final Product2 rhProduct;
    Product2 thisProduct = new Product2(); 
      
              
    public Product_InventoryCtrlExt(ApexPages.StandardController stdController){
    	this.rhProduct = (Product2)stdController.getRecord();
    	}
    
    public List<InventoryInfo> inventoryInfoList{
     	get{
    		if(inventoryInfoList == null){
    			                  
            	thisProduct = [SELECT Inventory__c FROM Product2 where Id = :this.rhProduct.Id];            
                
                if(thisProduct.Inventory__c != null){
                	
                	inventoryInfoList = (List<InventoryInfo>)JSON.deserialize(thisProduct.Inventory__c, List<InventoryInfo>.class); 
                	}                                                                                               
    			}         		
			return inventoryInfoList;
			}
		set;        
	}
}