public class OrderLineItemService{

    public static void checkLinesForMembershipSKU(List<Order_Line_Items__c> oLines){
        Set<Id> ordersToCheck = new Set<Id>();
        Map<String, MembershipSKU__c> skus = MembershipSKU__c.getAll();
        Map<String, Order_Line_Items__c> orderLineMap = new Map<String, Order_Line_Items__c>();

        for(Order_Line_Items__c ol:oLines){
            // Custom setting may involve annual v. monthly, and more SKUs, once we work out the details
            if(ol.CW_SKU_ID__c != null && skus.ContainsKey(ol.CW_SKU_ID__c)){
                ordersToCheck.add(ol.RH_Order_Number__c);
                orderLineMap.put(ol.RH_Order_Number__c, ol); //Current requirement states ONLY one Membership Line per order!
            }
        }
        if(!ordersToCheck.isEmpty()){
            MembershipService.UpdateDates(ordersToCheck);
            MembershipService.UpdateOrderLineLevelInfo(orderLineMap);
        }
    }

    public static void checkLinesForMembershipRenewalSKU(List<Order_Line_Items__c> oLines){
        // SMR-87
        Member_Renewal_SKU__c renewalSKUs = Member_Renewal_SKU__c.getOrgDefaults();

        if (renewalSKUs == null || renewalSKUs.SKU_Names__c == null) {
            return;
        }

        Map<String, MembershipSKU__c> membershipInitialPurchaseSku = MembershipSKU__c.getAll();
        set<String> allMembershipInitialPurchaseSkus = new set<String>();
        for(String sku:membershipInitialPurchaseSku.keySet()){
            allMembershipInitialPurchaseSkus.add(membershipInitialPurchaseSku.get(sku).SKU__c);
        }

        Set<Id> ordersToCheck = new Set<Id>();
        Map<String, Order_Line_Items__c> orderLineMap = new Map<String, Order_Line_Items__c>();

        for (Order_Line_Items__c ol:oLines) {
            if (String.isNotBlank(ol.CW_SKU_Name__c)) {
                System.debug('SKU NAME===: ' + ol.CW_SKU_Name__c);
                if(renewalSKUs.SKU_Names__c.Contains(ol.CW_SKU_Name__c) && !allMembershipInitialPurchaseSkus.Contains(ol.CW_SKU_Name__c)){
                    ordersToCheck.add(ol.RH_Order_Number__c);
                    orderLineMap.put(ol.RH_Order_Number__c, ol);
                }
            }
        }
        if(!ordersToCheck.isEmpty()){
            MembershipService.ManageRenewal(ordersToCheck);
        }
    }

    // Set field MembershipAutoRenewalSKU if order line references one of the membership auto-renewal SKUs
    // - before insert, before update
    public static void membershipAutoRenewalSKU(List<Order_Line_Items__c> newList) {
        Map<String, MembershipAutoRenewalSKUs__c> marSKUMap = MembershipAutoRenewalSKUs__c.getAll();

        for (Order_Line_Items__c oli :newList) {
            oli.MembershipAutoRenewalSKU__c = false;
            if (String.isNotBlank(oli.CW_SKU_Name__c)) {
                if (marSKUMap.containsKey(oli.CW_SKU_Name__c)) {
                    oli.MembershipAutoRenewalSKU__c = true;
                }
            }
        }
    }

	/*
	   	Description : Update checkBox in Order to satisfy the criteria based sharing rule used to share Order records with HDL user.   
	    Author: Eashan Parlewar
	    Date: 22-5-2017
	*/
	public static void UpdateOrderForSharingWithHDL(List<Order_Line_Items__c> OrderLineList,String Process,map<id,Order_Line_Items__c>OrderLineOldMap)
	{
		    
		    set<String> ShowOrderIdSet=new set<String>();
		    set<String> HideOrderIdSet=new set<String>();
		    set<String> shipViaHDLSet=new set<String>{'5','6','77'}; //Criteria required to set the order flag.
		    map<id,RH_Order__c> collectionOrderMap;
		    map<id,RH_Order__c> ShowOrderMap=new map<id,RH_Order__c>();
		     
		    for(Order_Line_Items__c Orln:OrderLineList)
		    {
			    	//This part of code will only run when a new order line item is inserted in the system.
			    	if(Process=='isInsert')
			    	{
				    		if(Orln.Ship_Via__c  != null && shipViaHDLSet.contains(Orln.Ship_Via__c))
					    	{
					    		ShowOrderIdSet.add(Orln.RH_Order_Number__c);
					    	}
			    	}
			    	
			    	//This part of code will only run when ship via field of order line item is updated in the system.
			    	if(Process=='isUpdate' && OrderLineOldMap.containskey(Orln.id) && OrderLineOldMap.get(Orln.id).Ship_Via__c!=Orln.Ship_Via__c && Orln.Ship_Via__c != null)
			    	{
					    	if(shipViaHDLSet.contains(Orln.Ship_Via__c))
					    	{
					    		ShowOrderIdSet.add(Orln.RH_Order_Number__c);
					    	}
					    	else 
					    	{
					    		HideOrderIdSet.add(Orln.RH_Order_Number__c);
					    	}
			    	}
		    }
		    
		    collectionOrderMap=new map<id,RH_Order__c>([select id,Show_HDL__c from RH_Order__c where id in: ShowOrderIdSet or id in: HideOrderIdSet]);
		    
		    // If Order line ship via field has 5 or 6 or 77 then mark the checkbox to true.
	        for(String OrdIds:ShowOrderIdSet)
	        {
		        	if(collectionOrderMap.containsKey(OrdIds) && collectionOrderMap.get(OrdIds).Show_HDL__c==false)
		        	{
		        		collectionOrderMap.get(OrdIds).Show_HDL__c=true;
		        		ShowOrderMap.put(OrdIds,collectionOrderMap.get(OrdIds));
		        	}
	        }
		    
		    // If Order line does not contain 5 or 6 or 77 then check if other order line item exist for the order.
		    // If there are other order line items which falls under the criteria of sharing then set the checkbox to true else set if to false.
		    if(HideOrderIdSet.size()>0 && Process=='isUpdate') 
		    {                                        
			        map<string,list<Order_Line_Items__c>> OrderWithOrdelineMap=new map<string,list<Order_Line_Items__c>>();
			        
			        //Create map of order id with order line item with ship via set to 5,6,77.
		        	for(Order_Line_Items__c Ordline:[select id,Ship_Via__c,RH_Order_Number__c from Order_Line_Items__c 
	                                                 where RH_Order_Number__c in:HideOrderIdSet and Ship_Via__c in:shipViaHDLSet])
		        	{
			        		if(OrderWithOrdelineMap.containskey(Ordline.RH_Order_Number__c))
			        		{
			        			OrderWithOrdelineMap.get(Ordline.RH_Order_Number__c).add(Ordline);
			        		}
			        		else
			        		{
			        			OrderWithOrdelineMap.put(Ordline.RH_Order_Number__c,new list<Order_Line_Items__c>{Ordline});
			        		}
		        	}
			        
			        for(String OrderIds:HideOrderIdSet)
			        {
				        	
				        	if(OrderWithOrdelineMap.containskey(OrderIds) 
				        	   && !OrderWithOrdelineMap.get(OrderIds).isempty())
				        	{
						        	//Update Only if flag is set to false.
						        	if(collectionOrderMap.get(OrderIds).Show_HDL__c==false)
						        	{
							        	collectionOrderMap.get(OrderIds).Show_HDL__c=true;
						        	    ShowOrderMap.put(OrderIds,collectionOrderMap.get(OrderIds));
						        	}
				        	}
				        	else
				        	{
				        			collectionOrderMap.get(OrderIds).Show_HDL__c=false;
					        	    ShowOrderMap.put(OrderIds,collectionOrderMap.get(OrderIds));
				        	}
				        	
			        }
		    }
		    
		    //DML to set the flag of Order in order to manage the sharing of order records with HDL Users.
		    if(!ShowOrderMap.isempty() && ShowOrderMap.size()>0)
		    { 
		    	update ShowOrderMap.values();
		    }
	}

	/*
	// Update Cases associated with the related Order based upon the SKU associated with the Order Line.
	// Set case field Membership_Auto_Renewal_Order__c true if the Order only has Membership Auto Renewal SKUs.
	// - after insert, after update, after delete
	public static void membershipAutoRenewalOrder(List<Order_Line_Items__c> newList, Map<Id, Order_Line_Items__c> oldMap, Boolean isInsert, Boolean isUpdate, Boolean isDelete) {
		Set<Id> oIds = new Set<Id>();

		if (isDelete) {
			for (Order_Line_Items__c oli :oldMap.values()) {
				oIds.add(oli.RH_Order_Number__c);
			}
		} else {
			for (Order_Line_Items__c oli :newList) {
				if (isInsert) {
					oIds.add(oli.RH_Order_Number__c);
				} else {
					if (oli.CW_SKU_Name__c != oldMap.get(oli.Id).CW_SKU_Name__c) {
						oIds.add(oli.RH_Order_Number__c);
					}
				}
			}
		}

		// Determine which orders only contain Membership Auto Renewal SKUs
		Map<Id, Boolean> marOrderMap = new Map<Id, Boolean>();
		if (!oIds.isEmpty()) {
			List<Case> cList = new List<Case>();
			cList = [select Id, CaseNumber, CCD_Status__c, Future_Processing__c, Membership_Auto_Renewal_Order__c, RH_Order_Number__c from Case where RH_Order_Number__c in :oIds and IsClosed = false];

			if (!cList.isEmpty()) {
				Map<String, MembershipAutoRenewalSKUs__c> marSKUMap = MembershipAutoRenewalSKUs__c.getAll();
				List<Order_Line_Items__c> oliList = new List<Order_Line_Items__c>();
				oliList = [select Id, Name, RH_Order_Number__c, CW_SKU_Name__c from Order_Line_Items__c where RH_Order_Number__c in :oIds];

				Boolean marSKU;
				for (Order_Line_Items__c oli :oliList) {

					marSKU = false;
					if (marOrderMap.containsKey(oli.RH_Order_Number__c)) {
						if (marSKUMap.containsKey(oli.CW_SKU_Name__c)) {
							if (marOrderMap.get(oli.RH_Order_Number__c)) {
								marSKU = true;
							}
						}
					} else {
						if (marSKUMap.containsKey(oli.CW_SKU_Name__c)) {
							marSKU = true;
						}
					}

					marOrderMap.put(oli.RH_Order_Number__c, marSKU);
				}

				Set<Id> ccdIds = new Set<Id>();
				for (Case c :cList) {
					c.Membership_Auto_Renewal_Order__c = (marOrderMap.containsKey(c.RH_Order_Number__c)) ? marOrderMap.get(c.RH_Order_Number__c) : false;
					if (isInsert && c.CCD_Status__c == 'Pending') {
						ccdIds.add(c.Id);
						c.Future_Processing__c = false;
					}
				}

				update cList;

				if (!ccdIds.isEmpty()) {
					CreditCardDeclineNotifications.ccDeclineNotifications(ccdIds);
				}
			}
		}
	}
	*/
}