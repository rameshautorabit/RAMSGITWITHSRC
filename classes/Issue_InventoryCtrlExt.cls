public with sharing class Issue_InventoryCtrlExt {
    
    private final Issue__c rhIssue;
    Product2 thisIssueProduct = new Product2(); 
                   
    public Issue_InventoryCtrlExt(ApexPages.StandardController stdController){
    	rhIssue = (Issue__c)stdController.getRecord();
    }
    
    public List<InventoryInfo> inventoryInfoList{
     	get{
    		if(inventoryInfoList == null){
    			
    			System.debug('CWSKUID: ' + rhIssue.CW_SKU_ID__c);
    			                  
            	thisIssueProduct = [SELECT Inventory__c FROM Product2 where Id = :rhIssue.CW_SKU_ID__c];            
                
                System.debug('This Issue Product: ' + thisIssueProduct);
                
                if(thisIssueProduct.Inventory__c != null){
                	
                	inventoryInfoList = (List<InventoryInfo>)JSON.deserialize(thisIssueProduct.Inventory__c, List<InventoryInfo>.class); 
                
                	}                                                                                               
    			} 
    		System.debug('Inventory Info List: ' + inventoryInfoList);
    			        		
			return inventoryInfoList;
			}
		private set;    
	}
}