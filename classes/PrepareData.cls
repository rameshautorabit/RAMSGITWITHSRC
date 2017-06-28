/**************************************************/
/*                                                */
/* This class prepares data as needed throughout  */
/* the application, and serves as a single point  */
/* of standard functionality rather than creating */
/* records using duplicate code in multiple       */
/* classes including test classes.                */
/*                                                */
/**************************************************/

public with sharing class PrepareData {
    
	// Create custom setting data
	public static List<CaseLineToOrderLineMapping__c> createCaseLineToOrderLineMappingList(){
        List<CaseLineToOrderLineMapping__c> CLToOLMapList = new List<CaseLineToOrderLineMapping__c>();
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Class', Case_Line_Item_field__c = 'Class__c', Order_Line_Item_field__c = 'Class__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Collection', Case_Line_Item_field__c = 'Collection__c', Order_Line_Item_field__c = 'Collection__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Color', Case_Line_Item_field__c = 'Color__c', Order_Line_Item_field__c = 'Color__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Contact Date', Case_Line_Item_field__c = 'Current_Available_Date__c', Order_Line_Item_field__c = 'Current_Delay_Date__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='CW SKU ID', Case_Line_Item_field__c = 'CW_SKU_ID__c', Order_Line_Item_field__c = 'CW_SKU_ID__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Department', Case_Line_Item_field__c = 'Department__c', Order_Line_Item_field__c = 'Department__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Division', Case_Line_Item_field__c = 'Division__c', Order_Line_Item_field__c = 'Division__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Index Price', Case_Line_Item_field__c = 'Index_Price__c', Order_Line_Item_field__c = 'Index_Price__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Item Description', Case_Line_Item_field__c = 'Item_Description__c', Order_Line_Item_field__c = 'Item_Description__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Item Number', Case_Line_Item_field__c = 'Item_Number__c', Order_Line_Item_field__c = 'Item_Number__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Line Number', Case_Line_Item_field__c = 'Line_Number__c', Order_Line_Item_field__c = 'Id'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Line Order Date', Case_Line_Item_field__c = 'Line_Order_Date__c', Order_Line_Item_field__c = 'Line_Order_Date__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Line Total', Case_Line_Item_field__c = 'Line_Total__c', Order_Line_Item_field__c = 'Line_Total__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Order Number', Case_Line_Item_field__c = 'Order__c', Order_Line_Item_field__c = 'RH_Order_Number__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Order Quantity', Case_Line_Item_field__c = 'Order_Quantity__c', Order_Line_Item_field__c = 'Order_Quantity__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Order Reserve Date', Case_Line_Item_field__c = 'Order_Reserve_Date__c', Order_Line_Item_field__c = 'Order_Reserve_Date__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Original Available Date', Case_Line_Item_field__c = 'Original_Available_Date__c', Order_Line_Item_field__c = 'Original_Available_Date__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Previous Available Date', Case_Line_Item_field__c = 'Previous_Available_Date__c', Order_Line_Item_field__c = 'Current_Available_Date__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Reorder Count', Case_Line_Item_field__c = 'Reorder_Count__c', Order_Line_Item_field__c = 'Reorder_Count__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Ship To', Case_Line_Item_field__c = 'Ship_To__c', Order_Line_Item_field__c = 'Ship_To__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Ship To Address', Case_Line_Item_field__c = 'ST_Address__c', Order_Line_Item_field__c = 'Ship_to_Address__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Ship To Day Phone', Case_Line_Item_field__c = 'ST_Day_Phone__c', Order_Line_Item_field__c = 'Ship_to_Day_Phone__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Ship To Email', Case_Line_Item_field__c = 'ST_Email__c', Order_Line_Item_field__c = 'Ship_to_Email__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Ship To Name', Case_Line_Item_field__c = 'ST_Name__c', Order_Line_Item_field__c = 'Ship_to_Name__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Ship To Night Phone', Case_Line_Item_field__c = 'ST_Night_Phone__c', Order_Line_Item_field__c = 'Ship_to_Night_Phone__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Size', Case_Line_Item_field__c = 'Size__c', Order_Line_Item_field__c = 'Size__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Sub-Department', Case_Line_Item_field__c = 'Sub_Department__c', Order_Line_Item_field__c = 'Sub_Department__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Unit Price', Case_Line_Item_field__c = 'Unit_Price__c', Order_Line_Item_field__c = 'Unit_Price__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Vendor Name', Case_Line_Item_field__c = 'Vendor_Name__c', Order_Line_Item_field__c = 'Vendor_Name__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Vendor Number', Case_Line_Item_field__c = 'Vendor_Number__c', Order_Line_Item_field__c = 'Vendor_Number__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Vendor Style Number', Case_Line_Item_field__c = 'Vendor_Style_Number__c', Order_Line_Item_field__c = 'Vendor_Style_Number__c'));
        CLToOLMapList.add(new CaseLineToOrderLineMapping__c(Name='Web Item Description', Case_Line_Item_field__c = 'Web_Item_Description__c', Order_Line_Item_field__c = 'Web_Item_Description__c'));
        return CLToOLMapList;
    }
    
    public static List<CasetoOrderFieldMapping__c> createCaseToOrderMappingList() {
		List<CasetoOrderFieldMapping__c> ctoList = new List<CasetoOrderFieldMapping__c>();
		ctoList.add(new CasetoOrderFieldMapping__c(Name = 'Callout Contacts', Case_Field__c = 'Callout_Contacts__c', Order_Field__c = 'Callout_Contacts__c'));
		ctoList.add(new CasetoOrderFieldMapping__c(Name = 'Client Type', Case_Field__c = 'Client_Type__c', Order_Field__c = 'Client_Type__c'));
		ctoList.add(new CasetoOrderFieldMapping__c(Name = 'Designer', Case_Field__c = 'Designer__c', Order_Field__c = 'Designer__c'));
		ctoList.add(new CasetoOrderFieldMapping__c(Name = 'Email Contacts', Case_Field__c = 'Email_Contacts__c', Order_Field__c = 'Email_Contacts__c'));
		ctoList.add(new CasetoOrderFieldMapping__c(Name = 'External Order Number', Case_Field__c = 'EXT_Order_Number__c', Order_Field__c = 'EXT_Order_Number__c'));
		ctoList.add(new CasetoOrderFieldMapping__c(Name = 'Gallery Number', Case_Field__c = 'Gallery_Number__c', Order_Field__c = 'Gallery_Number__c'));
		ctoList.add(new CasetoOrderFieldMapping__c(Name = 'Membership ID', Case_Field__c = 'Membership_ID__c', Order_Field__c = 'Membership_ID__c'));
		ctoList.add(new CasetoOrderFieldMapping__c(Name = 'Merchandise Subtotal', Case_Field__c = 'Merchandise_Subtotal__c', Order_Field__c = 'Merchandise_Subtotal__c'));
		ctoList.add(new CasetoOrderFieldMapping__c(Name = 'Opportunity', Case_Field__c = 'Opportunity_del__c', Order_Field__c = 'Opportunity__c'));
		ctoList.add(new CasetoOrderFieldMapping__c(Name = 'Order Date', Case_Field__c = 'Order_Date__c', Order_Field__c = 'Order_Date__c'));
		ctoList.add(new CasetoOrderFieldMapping__c(Name = 'Order Type Code', Case_Field__c = 'Order_Type_Code__c', Order_Field__c = 'Order_Type_Code__c'));
		ctoList.add(new CasetoOrderFieldMapping__c(Name = 'Order Type Description', Case_Field__c = 'Order_Type_Description__c', Order_Field__c = 'Order_Type_Description__c'));
		ctoList.add(new CasetoOrderFieldMapping__c(Name = 'ShipTo1 Address', Case_Field__c = 'ShipTo1_Address__c', Order_Field__c = 'ShipTo1_Address__c'));
		ctoList.add(new CasetoOrderFieldMapping__c(Name = 'ShipTo1 Day Phone', Case_Field__c = 'ShipTo1_Day_Phone__c', Order_Field__c = 'ShipTo1_Day_Phone__c'));
		ctoList.add(new CasetoOrderFieldMapping__c(Name = 'ShipTo1 Email', Case_Field__c = 'ShipTo1_Email__c', Order_Field__c = 'ShipTo1_Email__c'));
		ctoList.add(new CasetoOrderFieldMapping__c(Name = 'ShipTo1 Name', Case_Field__c = 'ShipTo1_Name__c', Order_Field__c = 'ShipTo1_Name__c'));
		ctoList.add(new CasetoOrderFieldMapping__c(Name = 'ShipTo1 Night Phone', Case_Field__c = 'ShipTo1_Night_Phone__c', Order_Field__c = 'ShipTo1_Night_Phone__c'));
		ctoList.add(new CasetoOrderFieldMapping__c(Name = 'Sold to Address Concatenated', Case_Field__c = 'Sold_to_Address__c', Order_Field__c = 'Sold_to_Address__c'));
		ctoList.add(new CasetoOrderFieldMapping__c(Name = 'Sold to Day Phone', Case_Field__c = 'Sold_to_Day_Phone__c', Order_Field__c = 'Sold_to_Day_Phone__c'));
		ctoList.add(new CasetoOrderFieldMapping__c(Name = 'Sold to Email', Case_Field__c = 'Sold_to_Email__c', Order_Field__c = 'Sold_to_Email__c'));
		ctoList.add(new CasetoOrderFieldMapping__c(Name = 'Sold to First Name', Case_Field__c = 'Sold_to_First_Name__c', Order_Field__c = 'Sold_to_First_Name__c'));
		ctoList.add(new CasetoOrderFieldMapping__c(Name = 'Sold to Last Name', Case_Field__c = 'Sold_to_Last_Name__c', Order_Field__c = 'Sold_to_Last_Name__c'));
		ctoList.add(new CasetoOrderFieldMapping__c(Name = 'Sold to Name Concatenated', Case_Field__c = 'Sold_to_Name__c', Order_Field__c = 'Sold_to_Name__c'));
		ctoList.add(new CasetoOrderFieldMapping__c(Name = 'Sold to Night Phone', Case_Field__c = 'Sold_to_Night_Phone__c', Order_Field__c = 'Sold_to_Night_Phone__c'));
		ctoList.add(new CasetoOrderFieldMapping__c(Name = 'Total Order Amount', Case_Field__c = 'Total_Order_Amount__c', Order_Field__c = 'Total_Order_Amount__c'));
		return ctoList;
    }
    
    public static List<Application_Settings__c> createApplicationSettings() {
    	List<Application_Settings__c> appSettings = new List<Application_Settings__c>();  
        appSettings.add(new Application_Settings__c(Name='QuoteCloneStatusToCreatePortalUser', Value_Text__c = 'Quote finalized - Payment Link Sent'));
        appSettings.add(new Application_Settings__c(Name='EnableCustomLogging', Value_Text__c = 'True'));
        appSettings.add(new Application_Settings__c(Name='ProductImageNotAvailableURL', Value_Text__c = 'http://media.restorationhardware.com/is/image/rhis/noimage?wid=500&hei=500&fmt=gif&qlt=85,1&op_sharpen=0&quantize=adaptive,diffuse,255,&resMode=bilin&op_usm=0,0,0,0&iccEmbed=1'));
        appSettings.add(new Application_Settings__c(Name='Production Concierge BC & Teen', Value_Text__c = 'https://store.rhbabyandchild.com'));
        appSettings.add(new Application_Settings__c(Name='Production Concierge RH & Modern', Value_Text__c = 'https://store.restorationhardware.com'));
        appSettings.add(new Application_Settings__c(Name='UAT Concierge BC & Teen', Value_Text__c = 'https://stg3-store.rhbabyandchild.com'));
        appSettings.add(new Application_Settings__c(Name='UAT Concierge RH & Modern', Value_Text__c = 'https://stg3-store.restorationhardware.com'));
        appSettings.add(new Application_Settings__c(Name='DelayedOrderLineMaxRecords', Value_Numeric__c = 5));
        appSettings.add(new Application_Settings__c(Name='CCD System Hold Codes', Value_Text__c = 'AT,AU,AV,AW,UT,UU,UV,UW'));
        appSettings.add(new Application_Settings__c(Name='Exch Greater Cost Amount Threshold', Value_Numeric__c = 0));
        appSettings.add(new Application_Settings__c(Name='Exch Greater Cost Percent Threshold', Value_Numeric__c = 0));
        appSettings.add(new Application_Settings__c(Name='Exch Lessor Cost Amount Threshold', Value_Numeric__c = 0));
        appSettings.add(new Application_Settings__c(Name='Exch Lessor Cost Percent Threshold', Value_Numeric__c = 0));
        appSettings.add(new Application_Settings__c(Name='Return Policy', Value_Numeric__c = 45));
        return appSettings;
    }
    
    public static List<RH_Web_Services__c> createRHWebServices() {
    	List<RH_Web_Services__c> rhWebServices = new List<RH_Web_Services__c>();
    	rhWebServices.add(new RH_Web_Services__c(Name = 'Backorder Notes Callout', Service_URL__c = 'https://servicesuat.restorationhardware.com:10000/storeBONotes'));
    	rhWebServices.add(new RH_Web_Services__c(Name = 'External Data Source - Billing', Service_URL__c = 'https://servicesuat.restorationhardware.com:10000/lightning/billing/xml?OrderNumber='));
    	rhWebServices.add(new RH_Web_Services__c(Name = 'External Data Source - Order Note', Service_URL__c = 'https://servicesuat.restorationhardware.com:10000/lightning/ordernotes?OrderNumber='));
    	rhWebServices.add(new RH_Web_Services__c(Name = 'Order Line History', Service_URL__c = 'https://servicesuat.restorationhardware.com:10000/lightning/olh?OrderNumber='));
    	rhWebServices.add(new RH_Web_Services__c(Name = 'Order RHOM Notes', Service_URL__c = 'https://servicesuat.restorationhardware.com:10000/lightning/rhomnotes?OrderNumber='));
    	rhWebServices.add(new RH_Web_Services__c(Name = 'Quote>CW', Service_URL__c = 'https://servicesuat.restorationhardware.com:10000/QuoteToCW/'));
    	rhWebServices.add(new RH_Web_Services__c(Name = 'Release Order Hold Callout', Service_URL__c = 'https://servicesuat.restorationhardware.com:10000/ReleaseOrderHold'));
    	rhWebServices.add(new RH_Web_Services__c(Name = 'getPaymentDetail', Service_URL__c = 'https://servicesuat.restorationhardware.com:10000/getPaymentDetail'));
    	return rhWebServices;
    }
    
    public static List<Groups__c> createGroups() {
    	List<Group> queueList = new List<Group>();
        queueList = [select Id, Name, Type from Group where Type = 'Queue'];
        List<Groups__c> grpSettings = new List<Groups__c>();
        for (Group q :queueList) {
        	if (q.Name.length() < 35) {
        		grpSettings.add(new Groups__c(Name = q.Name, GroupId__c = q.Id, Queue_Name__c = q.Name, Queue_Type__c = q.Type));
        	}
        }
        return grpSettings;
    }
    
    public static List<RH_Brand__c> createRHBrand() {
    	List<RH_Brand__c> rhbList = new List<RH_Brand__c>();
    	rhbList.add(new RH_Brand__c(
    		Name = '999', Brand_Logo__c = 'RH & RH MODERN', Brand_Logo_Height__c = '41', Brand_Logo_Width__c = '62', Delay_Notification_Email__c = 'webcs@rh.com', 
    		Delay_Notification_Phone__c = '800-318-4893', Description__c = 'DUMMY ENTITY', Email_Subject_Brand__c = 'RH', 
    		Brand_Home_Page_URL__c = 'https://www.restorationhardware.com',
    		Brand_Logo_URL__c = 'http://media.restorationhardware.com/is/image/rhis/rh_logo_transemail_2x_20160511?wid=126&fmt=png-alpha&qlt=85,1&op_sharpen=0&resMode=sharp2&op_usm=1,1,6,0&iccEmbed=1', 
    		ContactUsURL__c = 'https://www.restorationhardware.com/customer-service/contact-us.jsp', 
    		CustomerServiceURL__c = 'https://www.restorationhardware.com/customer-service/index.jsp', 
    		FrequentlyAskedQuestionsURL__c = 'https://www.restorationhardware.com/customer-service/frequently-asked-questions.jsp', 
    		GalleryNearestYouURL__c = 'https://www.restorationhardware.com/store-locations/index.jsp', 
    		PrivacyPolicyURL__c = 'https://www.restorationhardware.com/customer-service/privacy-policy.jsp', 
    		RH_Members_Program_Profile_URL__c = 'https://www.restorationhardware.com/my-account/membership.jsp', 
    		TermsAndConditionsURL__c = 'https://www.restorationhardware.com/content/page.jsp?id=rhmembers-terms')
    	);
    	rhbList.add(new RH_Brand__c(
    		Name = 'RH Contract', Brand_Logo__c = 'RH CONTRACT', Brand_Logo_Height__c = '41', Brand_Logo_Width__c = '62', Delay_Notification_Email__c = 'contractprojects@rh.com', 
    		Delay_Notification_Phone__c = '800-318-4893', Description__c = 'RH CONTRACT', Email_Subject_Brand__c = 'RH Contract', 
    		Brand_Home_Page_URL__c = 'https://www.restorationhardware.com/contract-sales/index.jsp', 
    		Brand_Logo_URL__c = 'http://media.restorationhardware.com/is/image/rhis/rh_logo_transemail_2x_20160511?wid=126&fmt=png-alpha&qlt=85,1&op_sharpen=0&resMode=sharp2&op_usm=1,1,6,0&iccEmbed=1', 
    		ContactUsURL__c = 'https://www.restorationhardware.com/customer-service/contact-us.jsp',
    		CustomerServiceURL__c = 'https://www.restorationhardware.com/customer-service/index.jsp', 
    		FrequentlyAskedQuestionsURL__c = 'https://www.restorationhardware.com/contract-sales/frequently-asked-questions.jsp', 
    		GalleryNearestYouURL__c = 'https://www.restorationhardware.com/store-locations/index.jsp', 
    		PrivacyPolicyURL__c = 'https://www.restorationhardware.com/customer-service/privacy-policy.jsp', 
    		RH_Members_Program_Profile_URL__c = 'https://www.restorationhardware.com/store-locations/index.jsp', 
    		TermsAndConditionsURL__c = 'https://www.restorationhardware.com/content/page.jsp?id=rhmembers-terms')
    	);
    	return rhbList;
    }
    
    public static List<CaseToCaseLineRecordTypes__c> createCaseToCaseLineRecordTypes() {
    	List<CaseToCaseLineRecordTypes__c> ctclList = new List<CaseToCaseLineRecordTypes__c>();
    	ctclList.add(new CaseToCaseLineRecordTypes__c(Name = 'Accommodations - Order Header', CaseComment_Record_Type__c = 'Standard', CaseLine_Record_Type__c = '', Case_Line_Required__c = false, Case_Line_Required_Fields__c = false, Case_Required_Fields__c = true, Limit_To_1__c = false, Task_Record_Type__c = 'Standard', NoCaseLineAtCreate__c = false));
    	ctclList.add(new CaseToCaseLineRecordTypes__c(Name = 'Accommodations - Order Line', CaseComment_Record_Type__c = 'Standard', CaseLine_Record_Type__c = 'Accommodations', Case_Line_Required__c = true, Case_Line_Required_Fields__c = true, Case_Required_Fields__c = true, Limit_To_1__c = false, Task_Record_Type__c = 'Standard', NoCaseLineAtCreate__c = false));
    	ctclList.add(new CaseToCaseLineRecordTypes__c(Name = 'BO Date Validation', CaseComment_Record_Type__c = 'BO Date Validation', CaseLine_Record_Type__c = 'BO Date Validation', Case_Line_Required__c = true, Case_Line_Required_Fields__c = false, Case_Required_Fields__c = false, Limit_To_1__c = false, Task_Record_Type__c = 'BO Date Validation', NoCaseLineAtCreate__c = false));
    	ctclList.add(new CaseToCaseLineRecordTypes__c(Name = 'Contract', CaseComment_Record_Type__c = 'Standard', CaseLine_Record_Type__c = 'Contract', Case_Line_Required__c = false, Case_Line_Required_Fields__c = false, Case_Required_Fields__c = true, Limit_To_1__c = false, Task_Record_Type__c = 'Contract Tasks', NoCaseLineAtCreate__c = true));
    	ctclList.add(new CaseToCaseLineRecordTypes__c(Name = 'Credit Card Declines', CaseComment_Record_Type__c = 'Standard', CaseLine_Record_Type__c = '', Case_Line_Required__c = false, Case_Line_Required_Fields__c = false, Case_Required_Fields__c = false, Limit_To_1__c = false, Task_Record_Type__c = 'Standard', NoCaseLineAtCreate__c = false));
    	ctclList.add(new CaseToCaseLineRecordTypes__c(Name = 'Delay Notifications', CaseComment_Record_Type__c = 'Delay Notifications', CaseLine_Record_Type__c = 'Delay Notifications', Case_Line_Required__c = true, Case_Line_Required_Fields__c = false, Case_Required_Fields__c = false, Limit_To_1__c = false, Task_Record_Type__c = 'Standard', NoCaseLineAtCreate__c = false));
    	ctclList.add(new CaseToCaseLineRecordTypes__c(Name = 'Delight HQ', CaseComment_Record_Type__c = 'Standard', CaseLine_Record_Type__c = 'Delight HQ', Case_Line_Required__c = false, Case_Line_Required_Fields__c = false, Case_Required_Fields__c = true, Limit_To_1__c = false, Task_Record_Type__c = 'Delight HQ', NoCaseLineAtCreate__c = false));
    	ctclList.add(new CaseToCaseLineRecordTypes__c(Name = 'Delivery & Return Support', CaseComment_Record_Type__c = 'Delivery & Return Support', CaseLine_Record_Type__c = 'Delivery & Return Support', Case_Line_Required__c = false, Case_Line_Required_Fields__c = true, Case_Required_Fields__c = false, Limit_To_1__c = false, Task_Record_Type__c = 'DRS', NoCaseLineAtCreate__c = false));
    	ctclList.add(new CaseToCaseLineRecordTypes__c(Name = 'Email and Web Inquiries', CaseComment_Record_Type__c = 'Standard', CaseLine_Record_Type__c = '', Case_Line_Required__c = false, Case_Line_Required_Fields__c = false, Case_Required_Fields__c = false, Limit_To_1__c = false, Task_Record_Type__c = 'Standard', NoCaseLineAtCreate__c = false));
    	ctclList.add(new CaseToCaseLineRecordTypes__c(Name = 'Furniture Repair Request', CaseComment_Record_Type__c = 'Standard', CaseLine_Record_Type__c = '', Case_Line_Required__c = false, Case_Line_Required_Fields__c = false, Case_Required_Fields__c = true, Limit_To_1__c = false, Task_Record_Type__c = 'Standard', NoCaseLineAtCreate__c = false));
    	ctclList.add(new CaseToCaseLineRecordTypes__c(Name = 'HDL Claims', CaseComment_Record_Type__c = 'Standard', CaseLine_Record_Type__c = 'HDL Claims', Case_Line_Required__c = true, Case_Line_Required_Fields__c = true, Case_Required_Fields__c = true, Limit_To_1__c = false, Task_Record_Type__c = 'Standard', NoCaseLineAtCreate__c = false));
    	ctclList.add(new CaseToCaseLineRecordTypes__c(Name = 'Product Information', CaseComment_Record_Type__c = 'Standard', CaseLine_Record_Type__c = 'Product Information', Case_Line_Required__c = false, Case_Line_Required_Fields__c = false, Case_Required_Fields__c = false, Limit_To_1__c = true, Task_Record_Type__c = 'Standard', NoCaseLineAtCreate__c = false));
    	ctclList.add(new CaseToCaseLineRecordTypes__c(Name = 'Product Issue', CaseComment_Record_Type__c = 'Standard', CaseLine_Record_Type__c = 'Standard', Case_Line_Required__c = true, Case_Line_Required_Fields__c = false, Case_Required_Fields__c = true, Limit_To_1__c = false, Task_Record_Type__c = 'Product Issue', NoCaseLineAtCreate__c = false));
    	ctclList.add(new CaseToCaseLineRecordTypes__c(Name = 'Reorders', CaseComment_Record_Type__c = 'Reorders', CaseLine_Record_Type__c = 'Reorders', Case_Line_Required__c = true, Case_Line_Required_Fields__c = true, Case_Required_Fields__c = true, Limit_To_1__c = true, Task_Record_Type__c = 'Reorders', NoCaseLineAtCreate__c = false));
    	ctclList.add(new CaseToCaseLineRecordTypes__c(Name = 'Replacement Parts', CaseComment_Record_Type__c = 'Replacement Parts', CaseLine_Record_Type__c = 'Standard', Case_Line_Required__c = true, Case_Line_Required_Fields__c = false, Case_Required_Fields__c = true, Limit_To_1__c = true, Task_Record_Type__c = 'Replacement Parts', NoCaseLineAtCreate__c = false));
    	ctclList.add(new CaseToCaseLineRecordTypes__c(Name = 'Returns', CaseComment_Record_Type__c = 'Standard', CaseLine_Record_Type__c = 'Returns', Case_Line_Required__c = true, Case_Line_Required_Fields__c = false, Case_Required_Fields__c = true, Limit_To_1__c = false, Task_Record_Type__c = 'Standard', NoCaseLineAtCreate__c = false));
    	ctclList.add(new CaseToCaseLineRecordTypes__c(Name = 'SPO Date Validation', CaseComment_Record_Type__c = 'Standard', CaseLine_Record_Type__c = 'SPO Date Validation', Case_Line_Required__c = true, Case_Line_Required_Fields__c = false, Case_Required_Fields__c = false, Limit_To_1__c = false, Task_Record_Type__c = 'SPO Date Validation', NoCaseLineAtCreate__c = false));
    	ctclList.add(new CaseToCaseLineRecordTypes__c(Name = 'Standard', CaseComment_Record_Type__c = 'Standard', CaseLine_Record_Type__c = 'Standard', Case_Line_Required__c = false, Case_Line_Required_Fields__c = false, Case_Required_Fields__c = true, Limit_To_1__c = false, Task_Record_Type__c = 'Standard', NoCaseLineAtCreate__c = false));
    	return ctclList;
    }
    
    public static List<IssueToInvestmentRecordTypes__c> createIssueToInvestmentRecordTypes() {
    	List<IssueToInvestmentRecordTypes__c> itiList = new List<IssueToInvestmentRecordTypes__c>();
    	itiList.add(new IssueToInvestmentRecordTypes__c(Name = 'Billing Issue - Contract', Investment_RT_List_1__c = 'Accommodations;Provide Billing Statement;Reauthorize credit card;Recollect payment;Refund'));
    	itiList.add(new IssueToInvestmentRecordTypes__c(Name = 'Customer Delivery Issue - Contract', Investment_RT_List_1__c = 'Accommodations;Exchange Product;Freight Discount;Loaner Product;Product Discount;Repair Customer Property;Repair Product/Furniture Medic;Replacement Parts;Reschedule Delivery;Return Product;Substitue Product'));
    	itiList.add(new IssueToInvestmentRecordTypes__c(Name = 'Delay Issue - Contract', Investment_RT_List_1__c = 'Accommodations;Freight Discount;Loaner Product;Product Discount;Replacement Parts;Reschedule Delivery;Substitue Product'));
    	itiList.add(new IssueToInvestmentRecordTypes__c(Name = 'Product Issue - Contract', Investment_RT_List_1__c = 'Accommodations;Exchange Product;Freight Discount;Loaner Product;Product Discount;Repair Product/Furniture Medic;Replacement Parts;Return Product;Substitue Product'));
    	itiList.add(new IssueToInvestmentRecordTypes__c(Name = 'Service Issue - Contract', Investment_RT_List_1__c = 'Accommodations;Freight Discount;Product Discount;Repair Customer Property'));
    	return itiList;
    }
    
    public static List<SyncOliQliCustomFields__c> createSyncOliQliCustomFields() {
    	List<SyncOliQliCustomFields__c> soqList = new List<SyncOliQliCustomFields__c>();
    	soqList.add(new SyncOliQliCustomFields__c(Name = 'Est. Delivery Date', OLI_Field__c = 'Est_Delivery_Date__c', QLI_Field__c = 'Est_Delivery_Date__c'));
    	soqList.add(new SyncOliQliCustomFields__c(Name = 'Expected Customer Delivery Date', OLI_Field__c = 'Expected_Customer_Delivery_Date__c', QLI_Field__c = 'Expected_Customer_Delivery_Date__c'));
    	soqList.add(new SyncOliQliCustomFields__c(Name = 'Expected Delivery Date', OLI_Field__c = 'Delivery_Date__c', QLI_Field__c = 'Delivery_Date__c'));
    	soqList.add(new SyncOliQliCustomFields__c(Name = 'Fulfillment Method', OLI_Field__c = 'Fulfillment_Method__c', QLI_Field__c = 'Fulfillment_Method__c'));
    	soqList.add(new SyncOliQliCustomFields__c(Name = 'Notes', OLI_Field__c = 'Notes__c', QLI_Field__c = 'Notes__c'));
    	soqList.add(new SyncOliQliCustomFields__c(Name = 'Quantity', OLI_Field__c = 'Quantity', QLI_Field__c = 'Quantity'));
    	soqList.add(new SyncOliQliCustomFields__c(Name = 'UnitPrice', OLI_Field__c = 'UnitPrice', QLI_Field__c = 'UnitPrice'));
    	return soqList;
    }
    
    public static List<FieldIdLookup__c> createFieldIdLookup() {
    	List<FieldIdLookup__c> fieldIdList = new List<FieldIdLookup__c>();
    	fieldIdList.add(new FieldIdLookup__c(Name = 'Opp.BalanceDueDate', FieldId__c = '00N50000002ceQQ'));
    	fieldIdList.add(new FieldIdLookup__c(Name = 'Opp.ClonedFrom', FieldId__c = '00N5B000000at1p'));
    	fieldIdList.add(new FieldIdLookup__c(Name = 'Opp.CollectionsEfforts', FieldId__c = '00N50000001xchq'));
    	fieldIdList.add(new FieldIdLookup__c(Name = 'Opp.FinalInvoiceAmount', FieldId__c = '00N50000001RqLB'));
    	fieldIdList.add(new FieldIdLookup__c(Name = 'Opp.PaidInFull', FieldId__c = '00N50000001gYXm'));
    	fieldIdList.add(new FieldIdLookup__c(Name = 'Opp.PMT1Amount', FieldId__c = '00N50000001gmrf'));
    	fieldIdList.add(new FieldIdLookup__c(Name = 'Opp.PMT2Amount', FieldId__c = '00N50000001iUiO'));
    	fieldIdList.add(new FieldIdLookup__c(Name = 'Opp.PMT3Amount', FieldId__c = '00N50000001iUiT'));
    	fieldIdList.add(new FieldIdLookup__c(Name = 'Opp.PriceBidContact', FieldId__c = '00N500000037zFd'));
    	fieldIdList.add(new FieldIdLookup__c(Name = 'Opp.TermsCustomerNotesPrintsonInvoice', FieldId__c = '00N50000002cePh'));
    	fieldIdList.add(new FieldIdLookup__c(Name = 'Opp.TERMSNOTES', FieldId__c = '00N50000001iUid'));
    	return fieldIdList;
    }
    
    public static List<CreditCardDeclineEmail__c> createCreditCardDeclineEmail() {
    	List<CreditCardDeclineEmail__c> ccdEmailList = new List<CreditCardDeclineEmail__c>();
    	ccdEmailList.add(new CreditCardDeclineEmail__c(Name = '1st Notice - Contract', Include_Order_Number__c = true, Preview_Text__c = 'PLEASE CONTACT US REGARDING YOUR ORDER', Subject__c = 'Urgent Message Regarding Your Restoration Hardware Order #'));
    	ccdEmailList.add(new CreditCardDeclineEmail__c(Name = '2nd Notice - Contract', Include_Order_Number__c = true, Preview_Text__c = 'PLEASE CONTACT US REGARDING YOUR ORDER', Subject__c = 'Urgent Message Regarding Your Restoration Hardware Order #'));
    	ccdEmailList.add(new CreditCardDeclineEmail__c(Name = 'Final Notice - Contract', Include_Order_Number__c = true, Preview_Text__c = 'PLEASE CONTACT US REGARDING YOUR ORDER', Subject__c = 'Urgent Message Regarding Your Restoration Hardware Order #'));
    	ccdEmailList.add(new CreditCardDeclineEmail__c(Name = '1st Notice - Regular', Include_Order_Number__c = true, Preview_Text__c = 'PLEASE CONTACT US REGARDING YOUR ORDER', Subject__c = 'Urgent Message Regarding Your Restoration Hardware Order #'));
    	ccdEmailList.add(new CreditCardDeclineEmail__c(Name = '2nd Notice - Regular', Include_Order_Number__c = true, Preview_Text__c = 'PLEASE CONTACT US REGARDING YOUR ORDER', Subject__c = 'Urgent Message Regarding Your Restoration Hardware Order #'));
    	ccdEmailList.add(new CreditCardDeclineEmail__c(Name = 'Final Notice - Regular', Include_Order_Number__c = true, Preview_Text__c = 'PLEASE CONTACT US REGARDING YOUR ORDER', Subject__c = 'Urgent Message Regarding Your Restoration Hardware Order #'));
    	ccdEmailList.add(new CreditCardDeclineEmail__c(Name = '1st Notice - Membership', Include_Order_Number__c = false, Preview_Text__c = 'Call Us Today to Continue Your Benefits.', Subject__c = 'Your RH Members Program Benefits Will Expire Soon.'));
    	ccdEmailList.add(new CreditCardDeclineEmail__c(Name = '2nd Notice - Membership', Include_Order_Number__c = false, Preview_Text__c = 'Call Us Now to Extend Your Membership.', Subject__c = 'Your RH Members Program Benefits Are About to Expire. Act Today.'));
    	ccdEmailList.add(new CreditCardDeclineEmail__c(Name = 'Final Notice - Membership', Include_Order_Number__c = false, Preview_Text__c = 'Call Us Today to Extend Your Membership.', Subject__c = 'Your RH Members Benefits Expire in Just 1 Day. Act Immediately.'));
    	return ccdEmailList;
    }
    
    public static List<MembershipAutoRenewalSKUs__c> createMembershipAutoRenewalSKUs() {
    	List<MembershipAutoRenewalSKUs__c> marsList = new List<MembershipAutoRenewalSKUs__c>();
    	marsList.add(new MembershipAutoRenewalSKUs__c(Name = '91020003BC30'));
    	marsList.add(new MembershipAutoRenewalSKUs__c(Name = '91020005RH30'));
    	marsList.add(new MembershipAutoRenewalSKUs__c(Name = '91020008RH1Y'));
    	marsList.add(new MembershipAutoRenewalSKUs__c(Name = '91020009BC1Y'));
    	return marsList;
    }
    
    public static List<GalleryRtnToCWRtn__c> createGalleryRtnToCWRtn() {
    	List<GalleryRtnToCWRtn__c> grtcwList = new List<GalleryRtnToCWRtn__c>();
    	grtcwList.add(new GalleryRtnToCWRtn__c(Name = 'Arrived Too Late', CW_Return_Code__c = '18'));
    	grtcwList.add(new GalleryRtnToCWRtn__c(Name = 'Client Pref - No Qlty Issue', CW_Return_Code__c = '19'));
    	grtcwList.add(new GalleryRtnToCWRtn__c(Name = 'Coordinating Items Not Avail', CW_Return_Code__c = '17'));
    	grtcwList.add(new GalleryRtnToCWRtn__c(Name = 'Damaged', CW_Return_Code__c = '11'));
    	grtcwList.add(new GalleryRtnToCWRtn__c(Name = 'Damaged - MOS', CW_Return_Code__c = '11'));
    	grtcwList.add(new GalleryRtnToCWRtn__c(Name = 'Defective', CW_Return_Code__c = '13'));
    	grtcwList.add(new GalleryRtnToCWRtn__c(Name = 'Defective - MOS', CW_Return_Code__c = '13'));
    	grtcwList.add(new GalleryRtnToCWRtn__c(Name = 'Gift', CW_Return_Code__c = '21'));
    	grtcwList.add(new GalleryRtnToCWRtn__c(Name = 'Not As Shown', CW_Return_Code__c = '10'));
    	grtcwList.add(new GalleryRtnToCWRtn__c(Name = 'Parts/Assembly Issue', CW_Return_Code__c = '24'));
    	grtcwList.add(new GalleryRtnToCWRtn__c(Name = 'Personalization Qlty Issue', CW_Return_Code__c = '23'));
    	grtcwList.add(new GalleryRtnToCWRtn__c(Name = 'Qlty Not As Expected', CW_Return_Code__c = '20'));
    	grtcwList.add(new GalleryRtnToCWRtn__c(Name = 'Swatch Return', CW_Return_Code__c = '31'));
    	grtcwList.add(new GalleryRtnToCWRtn__c(Name = 'Wrong Item/Qty Ordered', CW_Return_Code__c = '16'));
    	grtcwList.add(new GalleryRtnToCWRtn__c(Name = 'Wrong Item/Qty Rec\'d', CW_Return_Code__c = '14'));
    	return grtcwList;
    }
    
    public static List<MembershipCancellationTypes__c> createMembershipCancellationTypes() {
    	List<MembershipCancellationTypes__c> memCancelList = new List<MembershipCancellationTypes__c>();
    	memCancelList.add(new MembershipCancellationTypes__c(Name = 'Member Cancelled', Cancellation_Reasons__c = 'Does not use it;Unhappy with membership;None given by customer;Customer does not want it;Renewal failed;Quebec;', nonAdmin__c = true, Reasons_non_Admin__c = 'Does not use it;Unhappy with membership;None given by customer;Customer does not want it;'));
    	memCancelList.add(new MembershipCancellationTypes__c(Name = 'Member Terminated', Cancellation_Reasons__c = 'Does not use it;Unhappy with membership;None given by customer;Customer does not want it;', nonAdmin__c = true, Reasons_non_Admin__c = 'Does not use it;Unhappy with membership;None given by customer;Customer does not want it;'));
    	memCancelList.add(new MembershipCancellationTypes__c(Name = 'Pending', Cancellation_Reasons__c = 'Credit card decline;', nonAdmin__c = false, Reasons_non_Admin__c = ''));
    	memCancelList.add(new MembershipCancellationTypes__c(Name = 'RH Terminated', Cancellation_Reasons__c = 'Fraud;Credit card decline;Created in error;Duplicate membership;', nonAdmin__c = true, Reasons_non_Admin__c = 'Fraud;Credit card decline;Created in error;Duplicate membership;'));
    	return memCancelList;
    }
    
    public static List<MembershipExpiration__c> createMembershipExpiration() {
    	List<MembershipExpiration__c> memExpireList = new List<MembershipExpiration__c>();
    	memExpireList.add(new MembershipExpiration__c(Name = 'Default', Cancellation_Type__c = 'Member_Cancelled', Cancellation_Reason__c = 'Renewal Failed', ExpireAfterDays__c = 1, NumberOfDaysGrace__c = 0));
    	return memExpireList;
    }
    
    public static Quebecois__c createQuebecois() {
    	Quebecois__c que = new Quebecois__c(
    		SetupOwnerId = UserInfo.getOrganizationId(),
    		CountryValue__c = 'CA:C.A.:CAN:C.A.N.:CANADA Options',
    		ProvinceValue__c = 'QC:QC.:Q.C.:QUE.:QUEBEC:QUÉBEC'
    	);
    	return que;
    }
    
    public static MembershipNumber__c createMembershipNumber() {
    	MembershipNumber__c memNum = new MembershipNumber__c(
    		SetupOwnerId = UserInfo.getOrganizationId(),
    		Adjustor__c = 100033119
    	);
    	return memNum;
    }
    
    public static void populateCustomSettings()
    {
        List<Application_Settings__c> appSettings = createApplicationSettings(); 
        insert appSettings;
        
        List<RH_Web_Services__c> rhWebServices = createRHWebServices();
        insert rhWebServices;
        
        List<Groups__c> grpSettings = createGroups();
        insert grpSettings;
        
        List<RH_Brand__c> rhbList = createRHBrand();
        insert rhbList;
        
        List<CasetoOrderFieldMapping__c> ctoList = createCaseToOrderMappingList();
        insert ctoList;
        
        List<CaseLineToOrderLineMapping__c> cliTOoliList = createCaseLineToOrderLineMappingList();
        insert cliTOoliList;
        
        List<CaseToCaseLineRecordTypes__c> ctclList = createCaseToCaseLineRecordTypes();
        insert ctclList;
        
        List<IssueToInvestmentRecordTypes__c> itilList = createIssueToInvestmentRecordTypes();
        insert itilList;
        
        List<SyncOliQliCustomFields__c> soqList = createSyncOliQliCustomFields();
        insert soqList;
        
        List<FieldIdLookup__c> fieldIdList = createFieldIdLookup();
        insert fieldIdList;
        
        List<CreditCardDeclineEmail__c> ccdEmailList = createCreditCardDeclineEmail();
        insert ccdEmailList;
        
        List<MembershipAutoRenewalSKUs__c> marsList = createMembershipAutoRenewalSKUs();
        insert marsList;
        
        List<GalleryRtnToCWRtn__c> grtcwList = createGalleryRtnToCWRtn();
        insert grtcwList;
        
        List<MembershipCancellationTypes__c> memCancelList = createMembershipCancellationTypes();
        insert memCancelList;
        
        List<MembershipExpiration__c> memExpireList = createMembershipExpiration();
        insert memExpireList;
        
        Quebecois__c que = createQuebecois();
        insert que;
        
        MembershipNumber__c memNum = createMembershipNumber();
        insert memNum;
    }
    
    // Declare local variables
    public static Id getPortalProfile()
    {
        String  Id; // The return value
        
        try
        {
            Id = [SELECT Id FROM Profile WHERE Name = 'RH Overage Authenticated Website' LIMIT 1].Id;
            return Id;
        } catch (Exception e) {
            return UserInfo.getUserId(); // Since we must return something, we return a non-Profile Id as an error code
        }
    }
    
    public static void createGenericRHData(){
        Account a = createAccount();
        a.RecordTypeId = Utility.getRecordTypeId(Account.sObjectType, 'Internal');
        a.Name = 'Restoration Hardware';
        a.Type = 'Internal';
        insert a;
        Contact c = createContact(a.Id);
        c.Phone = '1111111112';
        c.OtherPhone = '1111111111';
        c.Alternate_Email__c = 'none2@none.tcom'; 
        insert c;
    }
    
    public static Case createCase(String recordType){
        Case c = new Case();
        c.RecordTypeId = Utility.getRecordTypeId(Case.sObjectType, recordType);
        return c;
    }
    
    public static Case_Line_Items__c createCaseLineItem(Case c){
        Case_Line_Items__c cli = new Case_Line_Items__c();
        cli.Case_Number__c = c.Id;
        return cli;
    }
    
    public static Account createAccount()
    {
        Account a = new Account (Industry = 'Residential-Single', Member_Since__c = System.today(),
            Name = 'Acme', Segment__c = 'Architect');
            
        return a;
    }
    
    public static Attachment createAttachment(Id parentId)
    {
        Attachment a = new Attachment (Body = Blob.valueOf('VGVzdA=='), ContentType = 'text/plain', IsPrivate = false, Name = 'Text.txt', ParentId = parentId);
        return a;
    }
    
    public static Contact createContact(Id accountId)
    {
        Contact c = new Contact (AccountId = accountId, Email = 'none@none.tcom', LastName = 'Smith');
        return c;
    }
    
    public static OpportunityContactRole createContactRole(Id contactId, Id opportunityId, String role)
    {
        OpportunityContactRole ocr = new OpportunityContactRole (ContactId = contactId, OpportunityId = opportunityId, Role = role);
        return ocr;
    }
    
    public static OpportunityLineItem createOLI(Decimal discount, Id opportunityId, Decimal unitPrice, Id pricebookEntryId, Double quantity)
    {
        OpportunityLineItem oli = new OpportunityLineItem(Discount = discount, OpportunityId = opportunityId, PricebookEntryId = pricebookEntryId, Quantity = quantity, UnitPrice = unitPrice);
        return oli;
    } 
    
    public static Opportunity createOpportunity(Id aId)
    {
        //Opportunity o = new Opportunity (AccountId = accountId, CloseDate = System.today().addDays(1),
            //LeadSource = 'Store', Name = 'Test Opportunity', Ops_Contact__c = UserInfo.getUserId(), StageName = 'Project Pricing');
        Contact c = [select Id from Contact where AccountId = :aId limit 1];
        Opportunity o = new Opportunity (AccountId = aId, CloseDate = System.today().addDays(1),
            LeadSource = 'Store', Name = 'Test Opportunity', StageName = 'Project Inquiry', Price_Bid_Contact__c = c.Id);
        return o;
    }
    
    public static OpportunityTeamMember createOpportunityTeamMember(Id opportunityId, Id userId)
    {
        OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId = opportunityId, TeamMemberRole = 'Specifying Rep', UserId = userId);
        return otm;
    }
    
    public static User createPortalUser(string alias, id ContactId, string firstName, string lastName, string username)
    {
        Id profileId = getPortalProfile();
        User u = new User (Alias = alias, CommunityNickname = alias, ContactId = contactId, CurrencyIsoCode = 'USD', DefaultCurrencyIsoCode = 'USD', Email = username, EmailEncodingKey = 'ISO-8859-1', FirstName = firstName, isActive = true, LastName = lastName, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = profileId, TimeZoneSidKey = 'America/Los_Angeles', Username = username);
        return u;
    }
    
    public static PricebookEntry createPBE(Decimal price, Id pricebookId, Id productId)
    {
        PricebookEntry pbe = new PricebookEntry(IsActive = true, Pricebook2Id = pricebookId, Product2Id = productId, UnitPrice = price);
        return pbe;
    }
    
    public static productClass createProduct(String code, Decimal elc, String name, Decimal price)
    {
        Product2 p = new Product2(Actual_Product_Name__c = name, Direct_Current_Price__c = price, DMMSSku__c = code, ELC__c = elc, IsActive = true, Name = name, ProductCode = code, SKU_Ship_Via__c = 'Ship');
        insert p;
        System.debug('Inserted Product: ' + p);
        
        // Set the Price in the Standard Pricebook
        //Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        //PricebookEntry pbe = createPBE(price, pb.Id, p.Id);
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = createPBE(price, pricebookId, p.Id);
        insert pbe;
        
        return new productClass(pbe, p);
    }
    
    public static Quote createQuote(Id bDLUserId, Id contactId, Id opportunityId, Id preparedById, String recordType)
    {
        // Declare local variables
        Id                                      quoteRecordTypeId; // The ID of the Quote Record Type
        Map<String, Schema.RecordTypeInfo>      quoteRecordTypes = new Map<String, Schema.RecordTypeInfo>(); // A Map of Quote Record Types
        
        // Get the Quote Record Type Ids
        quoteRecordTypes = Schema.SObjectType.Quote.getRecordTypeInfosByName();
        quoteRecordTypeId = quoteRecordTypes.get(recordType).getRecordTypeId();
        
        Quote q = new Quote (
        	BDL_Name__c = bDLUserId, 
        	BillingCity = 'San Francisco', 
        	BillingCountry = 'USA', 
        	BillingName = 'Pat Smith', 
        	BillingPostalCode = '94105',
        	BillingState = 'CA', 
        	BillingStreet = '123 Main', 
        	Bill_To_Last_Name__c = 'Smith',
        	ContactId = contactId, 
        	Country__c = 'US', 
        	Description = 'Test Description', 
        	ExpirationDate = System.today().addDays(1), 
        	Freight_Fees__c = 90, 
        	Handling_Fees_Y_N__c = 'Yes', 
        	Install_Date__c = String.valueOf(System.today().addDays(1)), 
        	Manual_Entry_of_S_H_fees__c = 'Yes', 
        	Name = 'Test Quote', 
        	OpportunityId = opportunityId, 
        	Prepared_By__c = preparedById, 
        	Quoted_On__c = System.today(), 
        	Range_for_Handling_Fees__c = 'Local', 
        	RecordTypeId = quoteRecordTypeId, 
        	Shipping_Contact__c = 'Klaudia Herger', 
        	Shipping_Fees__c = 100, 
        	ShippingName = 'Kanae Morimoto', 
        	Shipping_Phone__c = '415-555-1212', 
        	Ship_City__c = 'San Ramon', 
        	Ship_State__c = 'AZ', 
        	Tax_Code__c = 'T - Standard Tax', 
        	Ship_Street_1__c = '987 Central Blvd.', 
        	Ship_Street_2__c = 'Fourth Floor', 
        	Ship_to_State__c = 'CA', 
        	Ship_Zip__c = '94957', 
        	Tax_Rate__c = .08
        );
        
        return q;
    }
    
    public static QuoteLineItem createQLI(Id quoteId, Decimal price, Id pricebookEntryId, Integer quantity)
    {
        QuoteLineItem oli = new QuoteLineItem(Delivery_Date__c = 'Two weeks', ELC_Update__c = 100,
            Fulfillment_Method__c = 'Drop Ship', Notes__c = 'Test Notes',
            PricebookEntryId = pricebookEntryId, Products_w_Shipping_Fees__c = 75.50, 
            Quantity = quantity, QuoteId = quoteId, UnitPrice = price);
        return oli;
    }
    
    public static Task createTask(Date activityDate, String status, String subject, Id whatId, Id rtId)
    {
        Task t = new Task(ActivityDate = activityDate, Priority = 'Normal', Status = status, Subject = subject, WhatId = whatId, RecordTypeId = rtId);
        return t;
    }
    
    public class productClass
    {
        // Declare Class variables
        public PricebookEntry pbe;
        public Product2 p;
        
        productClass(PricebookEntry pbe, Product2 p)
        {
            this.pbe = pbe;
            this.p = p;
        }
    }
    
    // Read the indicated Delayed Order Rule record - create it if it doesn't exist
	public static Delayed_Order_Rule__c rcDelayedOrderRule(String dorType) {
		
		List<Delayed_Order_Rule__c> dorList = new List<Delayed_Order_Rule__c>();
		dorList = [select Id, Name, Order_Type_Category__c, Automatic_Emails__c, Days_Moved_Special_Attention__c, 
				Days_Moved_Last__c, Days_Moved_Original__c, 
				Days_Moved_In_Tier_1__c, Days_Moved_In_Tier_2__c, Days_Moved_Out_Tier_1__c, Days_Moved_Out_Tier_2__c, 
				Days_Moved_Line_Item_Value_Gift_Card__c, 
				Lines_Moved_Amount_Tier_1__c, Lines_Moved_Amount_Tier_2__c, Maximum_Regular_Notifications__c, 
				No_Auto_Email_After_Callout__c, Order_Amount_Tier_1__c
				from Delayed_Order_Rule__c where Order_Type_Category__c = :dorType limit 1];
		if (dorList.isEmpty()) {
			dorList.add(new Delayed_Order_Rule__c());
		}
		
		dorList[0].Order_Type_Category__c = dorType;
		dorList[0].Automatic_Emails__c = 1;
		dorList[0].Days_Moved_Special_Attention__c = 180;
		dorList[0].Days_Moved_Last__c = 7;
		dorList[0].Days_Moved_Original__c = 21;
		dorList[0].Days_Moved_Line_Item_Value_Gift_Card__c = 49;
		dorList[0].Lines_Moved_Amount_Tier_1__c = 10000;
		dorList[0].Lines_Moved_Amount_Tier_2__c = 10000;
		dorList[0].Maximum_Regular_Notifications__c = 1;
		dorList[0].No_Auto_Email_After_Callout__c = true;
		dorList[0].Order_Amount_Tier_1__c = 10000;
		/*
		dorList[0].Order_Type_Category__c = dorType;
		dorList[0].Automatic_Emails__c = 1;
		dorList[0].Days_Moved_Special_Attention__c = 180;
		dorList[0].Days_Moved_In_Tier_1__c = 7;
		dorList[0].Days_Moved_In_Tier_2__c = 21;
		dorList[0].Days_Moved_Out_Tier_1__c = 7;
		dorList[0].Days_Moved_Out_Tier_2__c = 21;
		dorList[0].Days_Moved_Line_Item_Value_Gift_Card__c = 49;
		dorList[0].Lines_Moved_Amount_Tier_1__c = 10000;
		dorList[0].Lines_Moved_Amount_Tier_2__c = 10000;
		dorList[0].Maximum_Regular_Notifications__c = 1;
		dorList[0].No_Auto_Email_After_Callout__c = true;
		dorList[0].Order_Amount_Tier_1__c = 10000;
		*/
		
		upsert dorList;
		
		return dorList[0];
	}
    
    public static RH_Order__c createOrder(String orderNumber) {
        
        RH_Order__c order = new RH_Order__c(
                Name = orderNumber,
                EXT_Order_Number__c = orderNumber,
                Order_Type_Description__c = 'PHONE',
                Order_Type_Code__c = 'P',
                Sold_to_Customer_Number__c = orderNumber,
                Sold_To_Address_1__c = '1234 Main Street',
                Sold_to_Address_2__c = 'Suite 2',
                Sold_to_Company__c = 'Acme, Inc.',
                Sold_to_City__c = 'San Francisco',
                Sold_to_State__c = 'CA',
                Sold_to_Zip__c = '94107',
                Sold_to_Day_Phone__c = '555-555-5555',
                Sold_to_Email__c = 'billybob-example@rh.com',
                Sold_to_First_Name__c = 'Billy', 
                Sold_to_Last_Name__c = 'Bob',
                Sold_to_Country_Code__c = 'US',
                Status__c = 'Open'
        );
        return order;
    }
    
    public static Ship_To__c createShipTo(Id orderNumber, String shipToNumber) {
        
        Ship_To__c st = new Ship_To__c(
                Name = shipToNumber,
                Order__c = orderNumber,
                Ship_to_Company__c = 'Acme, Inc.',
                Ship_to_Address_1__c = '1234 Main Street',
                Ship_to_Address_2__c = 'Suite 2',
                Ship_to_City__c = 'San Francisco',
                Ship_to_State__c = 'CA',
                Ship_to_Zip__c = '94107',
                Ship_to_Day_Phone__c = '555-555-5555',
                Ship_to_Email__c = 'billybob-example@rh.com',
                Ship_to_First_Name__c = 'Billy',
                Ship_to_Last_Name__c = 'Bob',
                Ship_to_Country_Code__c = 'US'
        );
        return st;
    }
    
    public static Order_Line_Items__c createOrderLine(Id orderNumber, Id shipToNumber, String lineNumber, Id sku) {
        
        RH_Order__c order = [select Id, Name from RH_Order__c where Id = :orderNumber];
        Ship_To__c shipTo = [select Id, Name from Ship_To__c where Id = :shipToNumber];
        Order_Line_Items__c oli = new Order_Line_Items__c(
                Name = lineNumber,
                RH_Order_Number__c = orderNumber,
                Coordinate_Group__c = '0',
                Order_Quantity__c = 1,
                Unit_Price__c = 100,
                Line_Total__c = 100,
                Ship_To__c = shipToNumber,
                Line_Status_Description__c = 'Open',
                EXT_OrderShipToLine_Number__c = order.Name + '-' + shipTo.Name + '-' + lineNumber,
                CW_SKU_ID__c = sku
        );
        return oli;
    }
    
    public static Design_Atelier_Quote__c createDAQuote(Opportunity testDAOppty, String quoteId) {
        
        Design_Atelier_Quote__c daq = new Design_Atelier_Quote__c(
                Name = 'testDAQuote',
                DA_Opportunity__c = testDAOppty.Id,
                DA_Opportunity_Number__c = testDAOppty.Final_Opportunity_Number__c,
                Quote_Id__c = quoteId,
               	Order_Subtotal__c = 33.33,
               	EXT_Oppty_Quote_Number__c = testDAOppty.Final_Opportunity_Number__c + '-' + quoteId
        );
        return daq;
    }
}