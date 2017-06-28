public with sharing class Order_WelcomeCtlExt {
	
	/*
	 *	Order controller extension - methods to support welcome RH membership email.
	 *
	 */
	
	ApexPages.StandardController stdController;
	public RH_Order__c rhOrder {get; set;}
	public Boolean orderDataError {get; set;}
	List<Order_Line_Items__c> oliList;
	Map<Id, Product2> pMap;
	
	// Constructor
    public Order_WelcomeCtlExt(ApexPages.StandardController stdController) {
        
        orderDataError = false;
        
        rhOrder = new RH_Order__c();
        this.rhOrder = (RH_Order__c)stdController.getRecord();
        rhOrder = [select Id, Name, Membership_ID__c, Membership_Enrollment_Date__c, Membership_Expiration_Date__c, 
        		To_Email_Address__c, Additional_To_Email_Addresses__c, Sold_to_Email__c, Sold_to_First_Name__c, 
        		Sold_to_Last_Name__c, Sold_To_Address_1__c, Sold_To_Address_2__c, Sold_to_City__c, 
				Sold_to_State__c, Sold_to_Zip__c, Sold_to_Day_Phone__c, Sold_to_Country__c, Membership_Welcome_Email_Sent__c 
				from RH_Order__c where Id = :this.rhOrder.Id];
        
        // Set the default To email address
        rhOrder.To_Email_Address__c = rhOrder.Sold_to_Email__c;
        rhOrder.Additional_To_Email_Addresses__c = '';
        
		// Get the order line data
		oliList = new List<Order_Line_Items__c>();
		oliList = [select Id, Name, CW_SKU_ID__c from Order_Line_Items__c where RH_Order_Number__c = :rhOrder.Id];
		//oliList = RH_OrderLine.getOrderRelatedOrderLines(rhOrder.Name);
		Set<Id> pIds = new Set<Id>();
		for (Order_Line_Items__c oli :oliList) {
			if (oli.CW_SKU_ID__c != null) {
				pIds.add(oli.CW_SKU_ID__c);
			}
		}
		pMap = new Map<Id, Product2>([select Id, Name from Product2 where Id in :pIds]);
    }
    
    public PageReference validateOrderData() {
    	PageReference pr = null;
		String missingOrderData = '';
		String RHModernSKU = '91020001RH';
		
		// Validate Order information for the email
		Map<String,Schema.SObjectField> FieldMap = Schema.SObjectType.RH_Order__c.fields.getMap();
		if (String.isBlank(rhOrder.Membership_ID__c)) {
			missingOrderData += FieldMap.get('Membership_ID__c').getDescribe().getLabel() + ', ';
		}
		if (rhOrder.Membership_Enrollment_Date__c == null) {
			missingOrderData += FieldMap.get('Membership_Enrollment_Date__c').getDescribe().getLabel() + ', ';
		}
		if (rhOrder.Membership_Expiration_Date__c == null) {
			missingOrderData += FieldMap.get('Membership_Expiration_Date__c').getDescribe().getLabel() + ', ';
		}
		if (String.isBlank(rhOrder.Sold_to_Email__c)) {
			missingOrderData += FieldMap.get('Sold_to_Email__c').getDescribe().getLabel() + ', ';
		}
		
		Boolean welcomeSKU = false;
		for (Order_Line_Items__c oli :oliList) {
			if (pMap.containsKey(oli.CW_SKU_ID__c)) {
				if (pMap.get(oli.CW_SKU_ID__c).Name == RHModernSKU) {
					welcomeSKU = true;
				}
			}
		}
		if (!welcomeSKU) {
			missingOrderData += 'at least one order line with product SKU ' + RHModernSKU + ', ';
		}
		
		if (String.isNotBlank(missingOrderData)) {
			missingOrderData = missingOrderData.removeEnd(', ');
			orderDataError = true;
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Welcome email cannot be sent until the following Order data is provided: ' + missingOrderData));
		}
		return pr;
    }
	
	public PageReference cancelWecomeEmail() {
		PageReference pr = new PageReference('/' + rhOrder.Id);
		return pr;
	}
	
	public PageReference sendWelcomeEmail() {
		PageReference pr = null;
		
		// Save the selected/entered email addresses and send the Billing Summary email
		try {
			update rhOrder;
			
			NotificationsOrder.sendSingleOrderNotification(rhOrder.Id, 'RH Membership Welcome');
			
			pr = new PageReference('/' + rhOrder.Id);
		} catch(Exception e) {
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'RH Membership Welcome email - Order update exception: ' + e.getMessage()));
		}

		return pr;
	}
}