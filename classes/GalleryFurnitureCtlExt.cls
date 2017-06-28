public with sharing class GalleryFurnitureCtlExt {
	
	/*
	 *	Gallery Furniture controller extension - methods to support the gallery Furniture Status Form.
	 *
	 */
	
	ApexPages.StandardController stdController;
	
	public Gallery_Furniture__c rhFurniture {get; set;}
	public RH_Brand__c rhBrand {get; set;}
	public String productImageURL {get; set;}
	public String productDescription {get; set;}
	public String clientName {get; set;}
	public String clientStreetAddress {get; set;}
	public String productCode {get; set;}
	public Boolean validUPC {get; set;}
	public Boolean fatalError {get; set;}
	
	private String galleryFurnitureId;
	private String productId;
	private String accountId;
	private String retURL;
	
	// Constructor
	public GalleryFurnitureCtlExt(ApexPages.StandardController stdController) {
		
		fatalError = false;
		
		galleryFurnitureId = ApexPages.currentPage().getParameters().get('galleryFurnitureId');
		productId = ApexPages.currentPage().getParameters().get('productId');
		accountId = ApexPages.currentPage().getParameters().get('accountId');
		retURL = ApexPages.currentPage().getParameters().get('retURL');
		
	}
	
	// Get all the data for the Furniture Status Form
	public PageReference initFurnitureStatusForm() {
		
		rhFurniture = new Gallery_Furniture__c();
		
		if (String.isNotBlank(galleryFurnitureId)) {
			
			rhFurniture = [select Id, Name, Gallery_Account__c, Gallery_Associate__c, Product__c, 
					Register__c, Sold__c, Sold_To_Address_1__c, Sold_To_Address_2__c, Sold_To_Address_3__c, 
					Sold_To_Alternate_Phone__c, Sold_To_City__c, Sold_To_Email__c, Sold_To_First_Name__c, 
					Sold_To_Last_Name__c, Sold_To_Phone__c, Sold_To_Postal_Code__c, Sold_To_State_Province__c, 
					Sold_Date__c, Transaction__c, UPC__c, HDL_Checklist__c, Piece__c, Total_Pieces__c, 
					Product__r.Name, Product__r.UPC__c, Product__r.CW_Item_Description__c, 
					Product__r.ECommerce_Display_Name__c, Product__r.Product_Image_URL__c, Product__r.STSSku__c, 
					Gallery_Associate__r.Name, Gallery_Associate__r.Gallery__c, 
					Gallery_Account__r.Name, Gallery_Account__r.Gallery__c 
					from Gallery_Furniture__c where Id = :galleryFurnitureId];
			
			// Verify we have a valid UPC number
			validUPC = false;
			if (String.isNotBlank(rhFurniture.UPC__c)) {
				productCode = rhFurniture.UPC__c;
			} else {
				productcode = rhFurniture.Product__r.UPC__c;
			}
			if (String.isNotBlank(productCode) && productCode.isNumeric() &&  productCode.length() == 12) {
				validUPC = true;
			}
			
			// Verify required information (required for Furniture Status Form but not required for page layout)
			if (validUPC) {
				
				rhBrand = RH_Brand__c.getInstance('999');
				
				productImageURL = rhFurniture.Product__r.Product_Image_URL__c;
				if (String.isBlank(productImageURL)) {
					productImageURL = Application_Settings__c.getInstance('ProductImageNotAvailableURL').Value_Text__c;
				}
				
				productDescription = rhFurniture.Product__r.ECommerce_Display_Name__c;
				if (String.isBlank(productDescription) || productDescription == 'PRODUCT NOT AVAILABLE') {
					productDescription = rhFurniture.Product__r.CW_Item_Description__c;
					if (String.isBlank(productDescription)) {
						productDescription = ' ';
					}
				}
				
				clientName = '';
				if (String.isNotBlank(rhFurniture.Sold_To_First_Name__c)) {
					clientName += rhFurniture.Sold_To_First_Name__c + ' ';
				}
				if (String.isNotBlank(rhFurniture.Sold_To_Last_Name__c)) {
					clientName += rhFurniture.Sold_To_Last_Name__c;
				}
				if (String.isBlank(clientName)) {
					clientName = ' ';
				}
				
				clientStreetAddress = '';
				if (String.isNotBlank(rhFurniture.Sold_To_Address_1__c)) {
					clientStreetAddress += rhFurniture.Sold_To_Address_1__c + ', ';
				}
				if (String.isNotBlank(rhFurniture.Sold_To_Address_2__c)) {
					clientStreetAddress += rhFurniture.Sold_To_Address_2__c + ', ';
				}
				if (String.isNotBlank(rhFurniture.Sold_To_Address_3__c)) {
					clientStreetAddress += rhFurniture.Sold_To_Address_3__c + ', ';
				}
				if (String.isBlank(clientStreetAddress)) {
					clientStreetAddress = ' ';
				} else {
					clientStreetAddress = clientStreetAddress.removeEnd(', ');
				}
				
			} else {
				fatalError = true;
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Gallery Furniture field UPC must not be blank and UPC must be a valid 12 digit UPC number.'));
			}
				
		} else {
			
			fatalError = true;
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Invalid Gallery Furniture Id.'));
			
		}
		
		return null;
	}
	
	// Get data to pre-populate new Gallery Furniture record
	public PageReference initGalleryFurniture() {
		PageReference pr = null;
		Product2 rhProduct = new Product2();
		List<Account> accList = new List<Account>();
		User rhUser = new User();
		Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
		
		try {
			rhUser = [select Id, Name, Gallery__c from User where Id = :UserInfo.getUserId()];
			
			if (String.isNotBlank(accountId)) {
				accList = [select Id, Name from Account where Id = :accountId];
			} else {
				if (String.isNotBlank(rhUser.Gallery__c)) {
					accList = [select Id, Name from Account where Name = :rhUser.Gallery__c and RecordTypeId = :rtMap.get('Internal').getRecordTypeId() limit 1];
				}
			}
			
			if (String.isNotBlank(productId)) {
				rhProduct = [select Id, Name, UPC__c from Product2 where Id = :productId];
			}
			
			// Take the user to the create new Gallery Furniture page
			FieldIdLookup__c fieldId;
			String encodedName;
			Schema.DescribeSObjectResult r = Gallery_Furniture__c.sObjectType.getDescribe();
			String grKeyPrefix = r.getKeyPrefix();
			String pageURL = '/' + grKeyPrefix + '/e?retURL=' + retURL;
			if (rhProduct.Id != null) {
				if (String.isNotBlank(rhProduct.UPC__c)) {
					fieldId = FieldIdLookup__c.getInstance('Gallery_Furniture.UPC');
					encodedName = EncodingUtil.urlEncode(rhProduct.UPC__c,'UTF-8');
					pageURL += '&' + fieldId.FieldId__c + '=' + encodedName;
				}
				fieldId = FieldIdLookup__c.getInstance('Gallery_Furniture.Product');
				encodedName = EncodingUtil.urlEncode(rhProduct.Name,'UTF-8');
				pageURL += '&CF' + fieldId.FieldId__c + '=' + encodedName + '&CF' + fieldId.FieldId__c + '_lkid=' + rhProduct.Id;
			}
			if (!accList.isEmpty()) {
				fieldId = FieldIdLookup__c.getInstance('Gallery_Furniture.Gallery_Account');
				encodedName = EncodingUtil.urlEncode(accList[0].Name,'UTF-8');
				pageURL += '&CF' + fieldId.FieldId__c + '=' + encodedName + '&CF' + fieldId.FieldId__c + '_lkid=' + accList[0].Id;
			}
			if (String.isNotBlank(rhUser.Gallery__c)) {
				fieldId = FieldIdLookup__c.getInstance('Gallery_Furniture.Gallery_Associate');
				encodedName = EncodingUtil.urlEncode(rhUser.Name,'UTF-8');
				pageURL += '&CF' + fieldId.FieldId__c + '=' + encodedName + '&CF' + fieldId.FieldId__c + '_lkid=' + rhUser.Id;
			}
			
			pr = new PageReference(pageURL);
			
		} catch(Exception e) {
			fatalError = true;
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Exception while reading User, Account, or Product data: ' + e.getMessage()));
		}
		
		return pr;
	}
}