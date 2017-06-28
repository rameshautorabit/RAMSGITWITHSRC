/**
    * Description: Class to update the fields on Case Line Item when an RH Order line Item is Updated
    * Test Class: 
    * Apex Trigger: OrderLineItem Trigger
**/

public without sharing class UpdateCaseLineFromOrderLine 
{
	public static void UpdateCaseLineItem(Map<Id,Order_Line_Items__c> triggerNewMap, Map<Id,Order_Line_Items__c> triggeroldMap)
	{
		Set<Id> OrderLineIdList = new Set<Id>();
        List<CaseLineToOrderLineMapping__c> cLineToOrderLineMapping = [SELECT Case_Line_Item_field__c, Order_Line_Item_field__c FROM CaseLineToOrderLineMapping__c];
        
        String caseLineQuery = 'SELECT Id, RH_Order_Number__c, ';
        
        for(CaseLineToOrderLineMapping__c cofm: cLineToOrderLineMapping){
            caseLineQuery += cofm.Case_Line_Item_field__c + ', ';
        }
        
        caseLineQuery = caseLineQuery.removeEnd(', ');
        
        for(Order_Line_Items__c ol: triggerNewMap.values())
		{
            for(CaseLineToOrderLineMapping__c colm: cLineToOrderLineMapping)
			{
                if(ol.get(colm.Order_Line_Item_field__c) != triggeroldMap.get(ol.Id).get(colm.Order_Line_Item_field__c))
				{
                    OrderLineIdList.add(ol.Id);
                    break;
                }
            }
        }
        System.debug(OrderLineIdList);
        caseLineQuery += ' FROM Case_Line_Items__c WHERE Line_Number__c IN: OrderLineIdList';
        List<Case_Line_Items__c> caseLineList = Database.query(caseLineQuery);
        
        for(Case_Line_Items__c c: caseLineList)
		{
            for(CaseLineToOrderLineMapping__c colm: cLineToOrderLineMapping)
			{
                 c.put(colm.Case_Line_Item_field__c, triggerNewMap.get(c.Line_Number__c).get(colm.Order_Line_Item_field__c));
            }
        }
        
        try
		{
            update caseLineList;
        }
		catch(DMLException de)
		{
            System.debug(de.getDMLMessage(0));
        } 
	}
}