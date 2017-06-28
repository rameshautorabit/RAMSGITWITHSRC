/**
    Class: UpdateCaseLineItemClass
    Entry Point: CaseLineItemsTrigger
    Test Class: CaselineItemsTrigger_Test
    
    Purpose:
    --------
    
    * Populates Product Information on a Case Line Item when the CW_SKU_ID__c (Product) is selected and not associated to a order line
    * Populates Order line information on a Case Line Item when a Case Line is associated to a Order line
    * Defaults the record type of Case line Item when it is created based on the Case Record Type
    
    Author: vk@ff 
    
    Change log:
    -----------
    
    Initial~ V0.1- Created on 09/04/2014
             V1.0- Created method: defaultRecordType
             V1.1- Created method: populateOrderLineInformation
             V1.2- Created method: populateProductInfo
             V2.0- Changed all methods to assume being called in a before trigger rather than an after trigger 9/22/2015
**/

public without sharing class UpdateCaseLineItemClass {
    
    // Method to update the Case Line Item with the Product Information
    public static void populateProductInfo(List<Case_Line_Items__c> cliList, Set<Id> p2Ids) {
        
        // Retrieve the fields to query from custom settings
        Map<String, ProductToCaseLine__c> fieldMap = new Map<String, ProductToCaseLine__c>();
        fieldMap = ProductToCaseLine__c.getAll();
        
        String prodQuery = 'SELECT Id,';
        for (ProductToCaseLine__c pclm :fieldMap.values()) {
            prodQuery += pclm.Product_field__c + ', ';
        }
        
        prodQuery = prodQuery.removeEnd(', ');
        prodQuery += ' FROM Product2 WHERE Id IN: p2Ids';
        Map<Id, Product2> pMap = new Map<Id, Product2>((List<Product2>) Database.query(prodQuery));
        
        for (Case_Line_Items__c cli :cliList) {
            for (ProductToCaseLine__c pclm :fieldMap.values()) {
                if (pMap.containsKey(cli.CW_SKU_ID__c)) {
                    cli.put(pclm.Case_Line_Item_field__c, pMap.get(cli.CW_SKU_ID__c).get(pclm.Product_field__c));
                }
            }
        }
    }
    
    /*
    public static void populateProductInfo(Map<Id,Id> mCLIdToPId)
    {
         //Retrieve the fields to query from custom settings
        List<ProductToCaseLine__c> prodToCaseLineMapping = [SELECT Case_Line_Item_field__c,Product_field__c FROM ProductToCaseLine__c];
        String prodQuery = 'SELECT Id,';
        String caseLineQuery = 'SELECT Id, CW_SKU_ID__c, ';
        
        for(ProductToCaseLine__c pclm: prodToCaseLineMapping){
            prodQuery += pclm.Product_field__c + ', ';
            caseLineQuery +=pclm.Case_Line_Item_field__c + ', ';
        }
        
        prodQuery = prodQuery.removeEnd(', ');
        caseLineQuery = caseLineQuery.removeEnd(', ');
        
        List<Id> lstOfCLIds=new List<Id>();
        lstOfCLIds.addAll(mCLIdToPId.keySet());
        List<Id> lstOfPIds=new List<Id>();
        lstOfPIds.addAll(mCLIdToPId.values());
        
        prodQuery += ' FROM Product2 WHERE Id IN: lstOfPIds';
        caseLineQuery += ' FROM Case_Line_Items__c WHERE Id IN: lstOfCLIds';
        
        System.debug('CASE QUERY' + caseLineQuery);
        System.debug('PRODUCT Query' + prodQuery);
        
        Map<Id,Product2> mapOfOLines=new Map<Id,Product2>((List<Product2>) Database.query(prodQuery));
        
        List<Case_Line_Items__c> lstOfCaseLines=Database.query(caseLineQuery);
        
        
        for(Case_Line_Items__c cl: lstOfCaseLines)
        {
            for(ProductToCaseLine__c pclm: prodToCaseLineMapping)
            {
                cl.put(pclm.Case_Line_Item_field__c, mapOfOLines.get(cl.CW_SKU_ID__c).get(pclm.Product_field__c));
            }
        }
        
        try
        {
            update lstOfCaseLines;
        }
        catch(DmlException e)
        {
            System.debug(e.getMessage());
        }
    }
    */

// method to populate Case Line Item with Order information

public static void populateOrderLineWithOrderInformation(List<Case_Line_Items__c> caseLineItemlist){
    Set<Id> CaseIds=new set<Id>();

for(Case_Line_Items__c c: caseLineItemlist){
    CaseIds.add(c.Case_Number__c);

}
    
    Set<String> cIds=new Set<String>();
    List<Case> CaseList=new List<Case>([Select Id,RH_Order_Number__c from Case where Id IN:CaseIds]);
    Map<String,String> CaseToOrderMap=new Map<String,String>();
    
    for(Case c:CaseList){
        CaseToOrderMap.put(c.Id,c.RH_Order_Number__c);
        //System.debug('Size is')
        }
    
    for(Case_Line_Items__c cl:caseLineItemlist){
        cl.Order__c=CaseToOrderMap.get(cl.Case_Number__c);
        System.debug('///////// value is'+cl.Order__c);
       // System.debug('*******'+CaseToOrderMap.get(cl.Case_Number__c));
        //insert c;
    }
   //return cll;
    
    
    
    
   /* List<Rh_Order__c> RHOrderList=new List<Rh_Order__c>([Select Id,Case__c from RH_Order__c where Case__c IN:CaseIds]);
    Map<String, CasetoOrderFieldMapping__c> fieldMap = new Map<String, CasetoOrderFieldMapping__c>();
    fieldMap = CasetoOrderFieldMapping__c.getAll();
    
    Map<Set<Id>,String> CaseToOrderMap=new Map<Set<Id>,String>();
    
    
    
    //Map<Set<Id>,String> OrderCaseMap=new Map<Set<Id>,String>();
    for(RH_Order__c rh: RHOrderList){
        CaseToOrderMap.put(new Set<Id>{rh.case__c},rh.Id);
        
    }
     List<Case_Line_Items__c> CaseList=new List<Case_Line_Items__c>();
     
     Map<Id,String> CaseToCaseLineMap=new Map<Id,String>();
     
     Set<Id> sIds=new Set<Id>();
         List<Case_Line_Items__c> cUpdate=new List<Case_Line_Items__c>();

      for(Case_Line_Items__c c: CaseList){
            sIds.add(c.Case_Number__c);
        
        c.put(c.Order__c,CaseToCaseLineMap.get(CaseToOrderMap.get(sIds)));
        cUpdate.add(c);
            
      }
    
                System.debug('Size is' +cUpdate.size());*/

    
    
    
}


    // Method to update the Case Line Item with the Order Line information
    public static void populateOrderLineInformation(List<Case_Line_Items__c> cliList, Set<Id> oliIds) {
        
        // Retrieve the fields to query from custom settings
        Map<String, CaseLineToOrderLineMapping__c> fieldMap = new Map<String, CaseLineToOrderLineMapping__c>();
        fieldMap = CaseLineToOrderLineMapping__c.getAll();
        
        String orderLineQuery = 'SELECT ';
        for (CaseLineToOrderLineMapping__c cofm :fieldMap.values()) {
            orderLineQuery += cofm.Order_Line_Item_field__c + ', ';
        }
        
        orderLineQuery = orderLineQuery.removeEnd(', ');
        orderLineQuery += ' FROM Order_Line_Items__c WHERE Id IN: oliIds';
        Map<Id, Order_Line_Items__c> oliMap = new Map<Id, Order_Line_Items__c>((List<Order_Line_Items__c>) Database.query(orderLineQuery));
        
        Map<Id, Schema.RecordTypeInfo> cliRTMap = Schema.SObjectType.Case_Line_Items__c.getRecordTypeInfosById();
        
        for (Case_Line_Items__c cli :cliList) {
            for (CaseLineToOrderLineMapping__c cofm :fieldMap.values()) {
                if (oliMap.containsKey(cli.Line_Number__c)) {
                    cli.put(cofm.Case_Line_Item_field__c, oliMap.get(cli.Line_Number__c).get(cofm.Order_Line_Item_field__c));
                    
                    
                    if (cofm.Order_Line_Item_field__c == 'Ship_to_Address__c') {
                        String str = String.valueOf(oliMap.get(cli.Line_Number__c).get(cofm.Order_Line_Item_field__c));
                        if (String.isNotBlank(str)) {
                            str = str.replaceAll('<br>','\n');
                        }
                        cli.put(cofm.Case_Line_Item_field__c, str);
                    } else {
                        if (cofm.Order_Line_Item_field__c == 'Reorder_Count__c') {
                            
                            Integer reorderCount = Integer.valueOf(oliMap.get(cli.Line_Number__c).get(cofm.Order_Line_Item_field__c));
                            if (cliRTMap.containsKey(cli.RecordTypeId) && cliRTMap.get(cli.RecordTypeId).getName() == 'Reorders') {
                                if (reorderCount == null || reorderCount < 2) {
                                    reorderCount = 2;
                                } else {
                                    reorderCount++;
                                }
                            }
                            
                            //system.debug('*****Reordercount = ' + reorderCount);
                            
                            cli.put(cofm.Case_Line_Item_field__c, reorderCount);
                        } else {
                            cli.put(cofm.Case_Line_Item_field__c, oliMap.get(cli.Line_Number__c).get(cofm.Order_Line_Item_field__c));
                        }
                    }
                }
            }
        }
    }
    
    /*
    //Added by vk@ff on 09/09/2014
    
    public static void populateOrderLineInformation(Map<Id,Id> mCLIdToOLId)
    {
        //Retrieve the fields to query from custom settings
        List<CaseLineToOrderLineMapping__c> caseLineToOLineMapping = [SELECT Case_Line_Item_field__c, Order_Line_Item_field__c FROM CaseLineToOrderLineMapping__c];
        String orderLineQuery = 'SELECT ';
        String caseLineQuery = 'SELECT Id, ';
        
        for(CaseLineToOrderLineMapping__c cofm: caseLineToOLineMapping){
            orderLineQuery += cofm.Order_Line_Item_field__c + ', ';
            caseLineQuery +=cofm.Case_Line_Item_field__c + ', ';
        }
        
        orderLineQuery = orderLineQuery.removeEnd(', ');
        caseLineQuery = caseLineQuery.removeEnd(', ');
        
        List<Id> lstOfCLIds=new List<Id>();
        lstOfCLIds.addAll(mCLIdToOLId.keySet());
        List<Id> lstOfOLIds=new List<Id>();
        lstOfOLIds.addAll(mCLIdToOLId.values());
        
        orderLineQuery += ' FROM Order_Line_Items__c WHERE Id IN: lstOfOLIds';
        caseLineQuery += ' FROM Case_Line_Items__c WHERE Id IN: lstOfCLIds';
        
        System.debug('CASE QUERY' + caseLineQuery);
        System.debug('ORDER Query' + orderLineQuery);
        
        Map<Id,Order_Line_Items__c> mapOfOLines=new Map<Id,Order_Line_Items__c>((List<Order_Line_Items__c>) Database.query(orderLineQuery));
        
    
        List<Case_Line_Items__c> lstOfCaseLines=Database.query(caseLineQuery);
        
        
        for(Case_Line_Items__c cl: lstOfCaseLines) {
            for (CaseLineToOrderLineMapping__c cofm: caseLineToOLineMapping) {
                if (cofm.Order_Line_Item_field__c == 'Ship_to_Address__c') {
                    String str = String.valueOf(mapOfOLines.get(cl.Line_Number__c).get(cofm.Order_Line_Item_field__c));
                    str = str.replaceAll('<br>','\n');
                    cl.put(cofm.Case_Line_Item_field__c, str);
                    system.debug('*****popOLI cofm.Order_Line_Item__c = ' + cofm.Order_Line_Item_field__c + ' mapOf =' + mapOfOLines.get(cl.Line_Number__c).get(cofm.Order_Line_Item_field__c) + ' str = ' + str);
                } else {
                    cl.put(cofm.Case_Line_Item_field__c, mapOfOLines.get(cl.Line_Number__c).get(cofm.Order_Line_Item_field__c));
                }
            }
        }
        
        try
        {
            update lstOfCaseLines;
        }
        catch(DmlException e)
        {
            System.debug(e.getMessage());
        }
    }
    */
    
    // Method to default the record type of the case line item based on case record type
    public static void defaultRecordType(List<Case_Line_Items__c> cliList, Set<Id> cIds) {
        
        // Build a map of Case record type to Case Line record type
        Map<Id, Schema.RecordTypeInfo> cliRTMap = Schema.SObjectType.Case_Line_Items__c.getRecordTypeInfosById();
        Map<Id, Schema.RecordTypeInfo> cRTMap = Schema.SObjectType.Case.getRecordTypeInfosById();
        
        Map<String, Id> cRTNameTocliRTId = new Map<String, Id>();
        for (Id cRTId :cRTMap.keySet()) {
            for (Id cliRTID :cliRTMap.keySet()) {
                if (cRTMap.get(cRTId).getName() == cliRTMap.get(cliRTId).getName()) {
                    cRTNameTocliRTId.put(cRTMap.get(cRTId).getName(), cliRTId);
                }
            }
        }
        
        Map<Id, Case> cMap = new Map<Id, Case>([select Id, RecordTypeId from Case where Id in :cIds]);
        for (Case_Line_Items__c cli :cliList) {
            if (cRTMap.containsKey(cMap.get(cli.Case_Number__c).RecordTypeId)) {
                if (cRTNameTocliRTId.containsKey(cRTMap.get(cMap.get(cli.Case_Number__c).RecordTypeId).getName())) {
                    cli.RecordTypeId = cRTNameTocliRTId.get(cRTMap.get(cMap.get(cli.Case_Number__c).RecordTypeId).getName());
                }
            }
        }
    }
    
    
    
public static void populateOrderLineWithOrderAccountInformation(List<Order_Line_Items__c> orderLineItemlist){
    Set<Id> orderIds=new set<Id>();

for(Order_Line_Items__c ol: orderLineItemlist){
    orderIds.add(ol.RH_Order_Number__c);

}
    
    Set<String> oIds=new Set<String>();
    List<RH_Order__c> OrderList=new List<RH_Order__c>([Select Id,Account__c from RH_Order__c where Id IN:orderIds]);
    Map<String,String> OrderLineToOrderMap=new Map<String,String>();
    
    for(RH_Order__c c:OrderList){
        OrderLineToOrderMap.put(c.Id,c.Account__c);
        //System.debug('Size is')
        }
    
    for( Order_Line_Items__c oli:orderLineItemlist){
        oli.Account__c=OrderLineToOrderMap.get(oli.Account__c);
        System.debug('///////// value is'+oli.Account__c);
       // System.debug('*******'+OrderLineToOrderMap.get(cl.Case_Number__c));
        //insert c;
    }
   //return cll;
    
    
    
    
   /* List<Rh_Order__c> RHOrderList=new List<Rh_Order__c>([Select Id,Case__c from RH_Order__c where Case__c IN:CaseIds]);
    Map<String, CasetoOrderFieldMapping__c> fieldMap = new Map<String, CasetoOrderFieldMapping__c>();
    fieldMap = CasetoOrderFieldMapping__c.getAll();
    
    Map<Set<Id>,String> OrderLineToOrderMap=new Map<Set<Id>,String>();
    
    
    
    //Map<Set<Id>,String> OrderCaseMap=new Map<Set<Id>,String>();
    for(RH_Order__c rh: RHOrderList){
        OrderLineToOrderMap.put(new Set<Id>{rh.case__c},rh.Id);
        
    }
     List<Case_Line_Items__c> CaseList=new List<Case_Line_Items__c>();
     
     Map<Id,String> CaseToCaseLineMap=new Map<Id,String>();
     
     Set<Id> sIds=new Set<Id>();
         List<Case_Line_Items__c> cUpdate=new List<Case_Line_Items__c>();

      for(Case_Line_Items__c c: CaseList){
            sIds.add(c.Case_Number__c);
        
        c.put(c.Order__c,CaseToCaseLineMap.get(OrderLineToOrderMap.get(sIds)));
        cUpdate.add(c);
            
      }
    
                System.debug('Size is' +cUpdate.size());*/

    
    
    
}
    
    
    
    
    
    /*
    //Method to default the record type of the case line item based on case record type
    
    public static void defaultRecordType(Map<Id,Id> mCLIdToCId)
    {
        List<Case_Line_Items__c> lstOfCLItems=new List<Case_Line_Items__c>();
        System.debug('CASE LINE IDS' + mCLIdToCId.keySet());
        lstOfCLItems=[SELECT Id, RecordTypeId,Case_Number__c FROM Case_Line_Items__c WHERE Id IN: mCLIdToCId.keySet()];
        
        System.debug('CASE IDS' + mCLIdToCId.values());
        List<Case> lstOfCases =[SELECT Id, RecordType.Name FROM Case WHERE Id IN: mCLIdToCId.values()];
        
        
        //Create a Map of Case Id to RecordTypeName
        Map<Id,String> mcIdToRT=new Map<Id,String>();
        for(Case c: lstOfCases)
        {
            mcIdToRT.put(c.Id,c.RecordType.Name);   
        }
        
        //Retrieve the Case-Caselinerecordtypes
        List<CaseToCaseLineRecordTypes__c> lstOfCRT=[SELECT Id, Name, Case_Record_Type__c, CaseLine_Record_Type__c FROM CaseToCaseLineRecordTypes__c];
        Map<String,String> mCRTyToCLIRtype=new Map<String,String>();
        
        for(CaseToCaseLineRecordTypes__c cr: lstOfCRT)
        {
            mCRTyToCLIRtype.put(cr.Case_Record_Type__c,cr.CaseLine_Record_Type__c);
        }
        
        //Retrieve RecordType Ids of Case line record types
        Map<String,Id> mRTNameToId=new Map<String,Id>();
        if(mCRTyToCLIRtype.size()>0)
        {
            List<RecordType> lstOfRtypes=[SELECT Id, Name FROM RecordType WHERE SObjectType='Case_Line_Items__c' AND Name IN: mCRTyToCLIRtype.values()];
                        
            if(lstOfRtypes.size()>0)
            {
                for(RecordType r: lstOfRtypes)
                {
                    mRTNameToId.put(r.Name,r.Id);   
                }
            }
        }
        
    
        
        for(Case_Line_Items__c cli: lstOfCLItems)
        {
                    
            if(mcIdToRT.containsKey(cli.Case_Number__c) && mcIdToRT.get(cli.Case_Number__c)!=null && mCRTyToCLIRtype.containsKey(mcIdToRT.get(cli.Case_Number__c)) &&
            mCRTyToCLIRtype.get(mcIdToRT.get(cli.Case_Number__c))!=null && mRTNameToId.containsKey(mCRTyToCLIRtype.get(mcIdToRT.get(cli.Case_Number__c))) &&
            mRTNameToId.get(mCRTyToCLIRtype.get(mcIdToRT.get(cli.Case_Number__c)))!=null)
            {
                cli.RecordTypeId=mRTNameToId.get(mCRTyToCLIRtype.get(mcIdToRT.get(cli.Case_Number__c)));
                System.debug(cli.RecordTypeId);
            }
            
        }
        
        //List<Case_Line_Items__c> lstToUpdate=new List<Case_Line_Items__c>();
        
        //lstToUpdate.addAll(lstOfCLItems);
        try
        {
            update lstOfCLItems;
        }
        catch(DmlException e)
        {
            System.debug(e.getMessage());   
        }
    }
    */
}