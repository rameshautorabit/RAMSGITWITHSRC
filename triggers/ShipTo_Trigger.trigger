/**
    Description: ShipTo Trigger to default the fields on the first Ship To record on a RH Order Header
    Class: UpdateOrderFromShipTo
    Author: vk@ff
**/

trigger ShipTo_Trigger on Ship_To__c (
        before insert,
        before update,
        before delete,
        after insert,
        after update,
        after delete,
        after undelete)
{

	TriggerManager__c orgVal = TriggerManager__c.getOrgDefaults();
	TriggerManager__c profileVal = TriggerManager__c.getInstance(UserInfo.getProfileId());
	    
	if(Test.isRunningTest() || orgVal.runMDMTriggers__c || (profileVal != null && profileVal.runMDMTriggers__c)) {    			
	    SObjectDomain.domainTriggerHandler(new Ship_Tos());	    
	}
	
	if (trigger.isBefore) {
		if (Trigger.isInsert) {
			ShiptoService.handleAddressChange(trigger.new, Trigger.oldMap);
		} else if (trigger.isUpdate) {
			ShiptoService.handleAddressChange(trigger.new, Trigger.oldMap);
			ShipToService.handleContactChange(trigger.new, Trigger.oldMap);
		}
	}
	
	if (trigger.isAfter) {
		if (Trigger.isInsert) {
			UpdateOrderFromShipTo.updateOrderHeader(UpdateOrderFromShipTo.generateUpdatedList(trigger.new, null));
		} else if(Trigger.isUpdate) {
			UpdateOrderFromShipTo.updateOrderHeader(UpdateOrderFromShipTo.generateUpdatedList(trigger.new, Trigger.oldMap));
		}
	}

}