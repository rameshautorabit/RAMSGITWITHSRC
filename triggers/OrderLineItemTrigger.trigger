trigger OrderLineItemTrigger on Order_Line_Items__c (after insert, before insert, before update, after update) {
    
    
    /*
     *  After Insert
     *      - For each Order Line associated with an RH Membership SKU, kick off RH Membership Welcome
     *      email processing for the related Ordwer.
     *
     */
     
     /*
     if(trigger.isInsert && trigger.isBefore){
        UpdateCaseLineItemClass.populateOrderLineWithOrderAccountInformation(Trigger.new);
     }
      
    TriggerManager__c orgVal = TriggerManager__c.getOrgDefaults();
    TriggerManager__c profileVal = TriggerManager__c.getInstance(UserInfo.getProfileId());
    
    if (trigger.isInsert && trigger.isAfter) {
        OrderLineItemService.checkLinesForMembershipSKU(Trigger.New);
        OrderLineItemService.checkLinesForMembershipRenewalSKU(Trigger.New); //SMR-87
        String RHModernSKU = '91020001RH';
        Set<Id> oIds = new Set<Id>();
        for (Order_Line_Items__c oli :trigger.new) {
            if(Test.isRunningTest() || !orgVal.runMembershipTriggers__c || (profileVal != null && !profileVal.runMembershipTriggers__c)){
               if (oli.CW_SKU_Name__c == RHModernSKU) {
                   oIds.add(oli.RH_Order_Number__c);
               }
            }
        }
        
        if (!oIds.isEmpty()) {
            NotificationsOrder.sendWelcomeNotifications(oIds);
        }
    }
    */
    
    if (trigger.isBefore) {
    	if (trigger.isInsert) {
    		UpdateCaseLineItemClass.populateOrderLineWithOrderAccountInformation(Trigger.new);
    		OrderLineItemService.membershipAutoRenewalSKU(trigger.new);
    	}
    	
    	if (trigger.isUpdate) {
    		OrderLineItemService.membershipAutoRenewalSKU(trigger.new);
    	}
    }
    
    if (trigger.isAfter) {
    	if (trigger.isInsert) {
    		TriggerManager__c orgVal = TriggerManager__c.getOrgDefaults();
			TriggerManager__c profileVal = TriggerManager__c.getInstance(UserInfo.getProfileId());
			
			OrderLineItemService.checkLinesForMembershipSKU(Trigger.New);
			OrderLineItemService.checkLinesForMembershipRenewalSKU(Trigger.New); //SMR-87
			String RHModernSKU = '91020001RH';
			Set<Id> oIds = new Set<Id>();
			for (Order_Line_Items__c oli :trigger.new) {
				if(Test.isRunningTest() || !orgVal.runMembershipTriggers__c || (profileVal != null && !profileVal.runMembershipTriggers__c)){
					if (oli.CW_SKU_Name__c == RHModernSKU) {
						oIds.add(oli.RH_Order_Number__c);
					}
				}
			}
			
			if (!oIds.isEmpty()) {
				NotificationsOrder.sendWelcomeNotifications(oIds);
			}
			
    		//OrderLineItemService.membershipAutoRenewalOrder(trigger.new, null, trigger.isInsert, trigger.isUpdate, trigger.isDelete);
    	}
    	
    	/*
		   	Description : Update checkBox in Order to satisfy the criteria based sharing rule used to share Order records with HDL user.   
		    Author: Eashan Parlewar
		    Date: 22-5-2017
	    */
	    if(trigger.isInsert)
	    {
    		OrderLineItemService.UpdateOrderForSharingWithHDL(Trigger.New,'isInsert',null);
	    }
	    if(trigger.isUpdate)
	    {
	    	OrderLineItemService.UpdateOrderForSharingWithHDL(Trigger.New,'isUpdate',Trigger.OldMap);
	    }
	    
	    
    	/*
    	if (trigger.isUpdate) {
    		OrderLineItemService.membershipAutoRenewalOrder(trigger.new, trigger.oldMap, trigger.isInsert, trigger.isUpdate, trigger.isDelete);
    	}
    	
    	if (trigger.isDelete) {
    		OrderLineItemService.membershipAutoRenewalOrder(null, trigger.oldMap, trigger.isInsert, trigger.isUpdate, trigger.isDelete);
    	}
    	*/
    }
}