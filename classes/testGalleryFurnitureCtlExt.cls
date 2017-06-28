@isTest
private class testGalleryFurnitureCtlExt {
	
	/*
	 *	Test methods for testing GalleryFurnitureCtlExt.cls.
	 *
	 */
	
	static testMethod void gfTest1() {
		
		// Create test data - User, Accounts, Product, FieldIdLookUp
		String galleryName = 'Gallery 006 - Corte Madera';
		User testUser = [select Id, Gallery__c from User where Id = :UserInfo.getUserId()];
		testUser.Gallery__c = galleryName;
		update testUser;
		
		Map<String,Schema.RecordTypeInfo> rtAccMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
		List<Account> accList = new List<Account>();
		accList.add(new Account(
			Name = 'Gallery 006 - Corte Madera',
			RecordTypeId = rtAccMap.get('Internal'). getRecordTypeId(),
			Type = 'Internal',
			Gallery__c = '6')
		);
		accList.add(new Account(
			Name = 'RH DC 97 (SoCal)',
			RecordTypeId = rtAccMap.get('Internal'). getRecordTypeId(),
			Type = 'Contract',
			HDL_Code__c = '97')
		);
		insert accList;
		accList[0].Furniture_Return_DC__c = accList[1].Id;
		update accList[0];
		
		Product2 prd = new Product2(Actual_Product_Name__c = '59140061BMCO', Direct_Current_Price__c = 4645.00, DMMSSku__c = '59140061BMCO', CW_External_Id__c = '59140061BMCO', ELC__c = 1901.79, IsActive = true, Name = '59140061BMCO', UPC__c = '461102030003', SKU_Ship_Via__c = 'Ship');
        insert prd;
		
		List<FieldIdLookup__c> fieldIdList = new List<FieldIdLookup__c>();
		fieldIdList.add(new FieldIdLookup__c(
			Name = 'Gallery_Furniture.Gallery_Account',
			FieldId__c = '00N2C000000G2uy',
			FieldName__c = 'Gallery_Account',
			ObjectName__c = 'Gallery_Furniture')
		);
		fieldIdList.add(new FieldIdLookup__c(
			Name = 'Gallery_Furniture.Gallery_Associate',
			FieldId__c = '00N2C000000G2vS',
			FieldName__c = 'Gallery_Associate',
			ObjectName__c = 'Gallery_Furniture')
		);
		
		fieldIdList.add(new FieldIdLookup__c(
			Name = 'Gallery_Furniture.Product',
			FieldId__c = '00N2C000000G2v8',
			FieldName__c = 'Product',
			ObjectName__c = 'Gallery_Furniture')
		);
		fieldIdList.add(new FieldIdLookup__c(
			Name = 'Gallery_Furniture.UPC',
			FieldId__c = '00N2C000000G4np',
			FieldName__c = 'UPC',
			ObjectName__c = 'Gallery_Furniture')
		);
		insert fieldIdList;
		
		Application_Settings__c appSetting = new Application_Settings__c(
			Name = 'ProductImageNotAvailableURL',
			Value_Text__c = 'http://media.restorationhardware.com/is/image/rhis/noimage?wid=500&hei=500&fmt=gif&qlt=85,1&op_sharpen=0&quantize=adaptive,diffuse,255,&resMode=bilin&op_usm=0,0,0,0&iccEmbed=1'
		);
		insert appSetting;
		
		// Start the test
		Gallery_Furniture__c galFurn = new Gallery_Furniture__c();
		ApexPages.StandardController std = new ApexPages.StandardController(galFurn);
		ApexPages.currentPage().getParameters().put('productId', prd.Id);
		GalleryFurnitureCtlExt ctl = new GalleryFurnitureCtlExt(std);
		
		ctl.initGalleryFurniture();
		system.assert(!ctl.fatalError);
		
		galFurn = new Gallery_Furniture__c(
			Gallery_Account__c = accList[0].Id,
			Gallery_Associate__c = UserInfo.getUserId(),
			Product__c = prd.Id,
			UPC__c = '459336340005',
			Sold__c = true,
			Sold_Date__c = system.today(),
			Register__c = '7',
			Transaction__c = '123-6B',
			HDL_Checklist__c = '56ABC',
			Piece__c = 1,
			Total_Pieces__c = 1,
			Sold_To_First_Name__c = 'Billy',
			Sold_To_Last_Name__c = 'Bob',
			Sold_To_Address_1__c = '123 Main Street',
			Sold_To_City__c = 'San Francisco',
			Sold_To_State_Province__c = 'CA',
			Sold_To_Postal_Code__c = '94107',
			Sold_To_Phone__c = '555-555-5555',
			Sold_To_Alternate_Phone__c = '123-456-7890',
			Sold_To_Email__c = 'billybob@rh.com'
		);
		insert galFurn;
		
		ApexPages.StandardController std1 = new ApexPages.StandardController(galFurn);
		ApexPages.currentPage().getParameters().put('galleryFurnitureId', galFurn.Id);
		GalleryFurnitureCtlExt ctl1 = new GalleryFurnitureCtlExt(std1);
		
		ctl1.initFurnitureStatusForm();
		system.assert(!ctl1.fatalError);
	}
}