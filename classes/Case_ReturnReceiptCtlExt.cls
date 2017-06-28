public with sharing class Case_ReturnReceiptCtlExt {
    
    /*
     *  Case controller extension - methods to support return receipt preview, email, and print.
     *
     */
	
	// Order Line selection data
    public class SelectOrderLineClass {
        public Boolean selected {get; set;}
        public Decimal returnableQuantity {get; set;}
        public Order_Line_Items__c orderLine {get; set;}
        public Product2 sku {get; set;}
        public RtnClass returnItem {get; set;}
        public Boolean productSearch {get; set;}
		public String productSearchString {get; set;}
		public Boolean noProductSearchResults {get; set;}
		public List<ExchProductSearchResultsClass> searchResults {get; set;}
        public SelectOrderLineClass(Boolean selected, Decimal returnableQuantity, Order_Line_Items__c orderLine, Product2 sku, RtnClass returnItem) {
            this.selected = selected;
            this.returnableQuantity = returnableQuantity;
            this.orderLine = orderLine;
            this.sku = sku;
            this.returnItem = returnItem;
            this.productSearch = false;
            this.noProductSearchResults = true;
            this.productSearchString = '';
            this.searchResults = new List<ExchProductSearchResultsClass>();
        }
        
        public PageReference solcQuantityChanged() {
        	Decimal qty = (this.returnItem.rtnItem.Quantity_Returned__c == null) ? 0 : this.returnItem.rtnItem.Quantity_Returned__c;
        	Decimal up = (this.orderLine.Unit_Price__c == null) ? 0 : this.orderLine.Unit_Price__c;
        	this.returnItem.rtnItem.Return_Amount__c = qty * up;
        	
			if (!this.returnItem.rtnItem.Refund_Deposit__c && this.sku.Dropship__c) {
				this.returnItem.rtnItem.Return_Amount__c = this.returnItem.rtnItem.Return_Amount__c / 2;
        	}
        	
        	return null;
        }
        
        public PageReference solcDisplayProductSearch() {
        	
        	this.productSearch = true;
        	this.productSearchString = '';
        	
        	return this.solcExecuteProductSearch();
        }
        
        public PageReference solcExecuteProductSearch() {
        	
        	this.searchResults.clear();
        	
        	if (String.isNotBlank(this.productSearchString)) {
        		List<List<SObject>> searchList = [FIND :this.productSearchString IN ALL FIELDS RETURNING Product2 (Id, Name, IsActive, Actual_Product_Name__c, Category__c, Collection__c, Dropship__c, Ecommerce_Display_Name__c, Fulfilling_Warehouse__c, SKU_Ship_Via__c, Web_Description__c, Direct_Current_Price__c, Member_Price__c) LIMIT 200];
        		
        		for (SObject s :searchList[0]) {
        			if (((Product2)s).IsActive) {
        				this.searchResults.add(new ExchProductSearchResultsClass(null, this, (Product2)s));
        			}
        		}
        	}
        	
        	this.noProductSearchResults = (this.searchResults.isEmpty()) ? true : false;
        	
        	return null;
        }
    }
	
	// Exchange item product search data and methods
	public class ExchProductSearchResultsClass {
    	public ExchClass exch {get; set;}
    	public SelectOrderLineClass solc {get; set;}
    	public Product2 product {get; set;}
    	
    	public ExchProductSearchResultsClass(ExchClass exch, SelectOrderLineClass solc, Product2 p) {
    		this.exch = exch;
    		this.solc = solc;
    		this.product = p;
    	}
    	
    	public PageReference selectedProduct() {
    		
    		if (this.exch != null) {
    			this.exch.exchItem.Exch_Product__c = this.product.Id;
    			this.exch.productSearch = false;
    			this.exch.exchProductChanged();
    		} else {
    			this.solc.sku = [select Id, Name, Dropship__c, Fulfilling_Warehouse__c, SKU_Ship_Via__c, Actual_Product_Name__c, Direct_Current_Price__c, Member_Price__c from Product2 where Id = :this.product.Id];
    			this.solc.productSearch = false;
    			this.solc.selected = true;
    			this.solc.returnItem.thisCase_ReturnReceiptCtlExt.getSelected();
    		}
    		
    		return null;
    	}
    }
    
	// Order Line data and methods for not received items
	public class ExchNotReceivedClass {
		public ExchClass exch {get; set;}
		public Decimal returnableQuantity {get; set;}
		public Order_Line_Items__c oli {get; set;}
		
		public ExchNotReceivedClass(ExchClass exch, Decimal returnableQty, Order_Line_Items__c oli) {
			this.exch = exch;
			this.returnableQuantity = returnableQty;
			this.oli = oli;
		}
		
		public PageReference selectedNotReceived() {
    		
    		this.exch.exchItem.Exch_Order_Line_Number__c = this.oli.Id;
    		this.exch.exchItem.Exch_Product__c = this.oli.CW_SKU_ID__c;
    		this.exch.notReceived = false;
    		this.exch.notReceivedReturnableQty = this.returnableQuantity;
    		this.exch.exchProductChanged();
    		
    		return null;
    	}
	}
    
    // Exchange data and methods
    public class ExchClass {
		public RtnClass rtn {get; set;}
		public Case_Line_Items__c exchItem {get; set;}
		public Boolean noPriceOverride {get; set;}
		public String exchItemSkuDescription {get; set;}
		public Boolean productSearch {get; set;}
		public String productSearchString {get; set;}
		public Boolean noProductSearchResults {get; set;}
		public List<ExchProductSearchResultsClass> searchResults {get; set;}
		public Decimal notReceivedReturnableQty {get; set;}
		public Boolean notReceived {get; set;}
		public List<ExchNotReceivedClass> notReceivedList {get; set;}
		
		public ExchClass() {}
		
		public ExchClass(RtnClass rtn) {
			this.rtn = rtn;
			this.exchItem = rtn.rtnItem;
			this.exchItemSkuDescription = rtn.rtnItem.Exch_Product__r.Actual_Product_Name__c;
			this.productSearch = false;
			this.noProductSearchResults = true;
            this.productSearchString = '';
            this.searchResults = new List<ExchProductSearchResultsClass>();
            this.notReceivedReturnableQty = 0;
            this.notReceived = false;
            this.notReceivedList = new List<ExchNotReceivedClass>();
            this.noPriceOverride = false;
            if (this.rtn.rtnItem.Exch_Product__c != null) {
            	if (this.rtn.rtnItem.CW_SKU_ID__c == this.rtn.rtnItem.Exch_Product__c || this.rtn.rtnItem.Line_Number__c == null) {
            		this.noPriceOverride = true;
            	}
            }
		}
		
		// Clear out an exchange item
		public void clearExchItem(ExchClass exch) {
			
			system.debug('***** notReceivedReturnableQty (clearExchItem) = ' + exch.notReceivedReturnableQty);
			
			exch.rtn.showExchange = false;
			exch.productSearch = false;
			exch.noProductSearchResults = true;
			exch.productSearchString = '';
			exch.searchResults.clear();
			exch.notReceivedReturnableQty = 0;
			exch.notReceived = false;
			exch.notReceivedList.clear();
			exch.exchItem.No_Charge_Replacement__c = false;
			exch.exchItem.Exch_Amount__c = null;
			exch.exchItem.Exch_Cost__c = null;
			exch.exchItem.Exch_Price__c = null;
			exch.exchItem.Exch_Product__c = null;
			exch.exchItem.Exch_Quantity__c = null;
			exch.exchItem.Exch_Unit_Price__c = null;
			exch.exchItem.Exch_Order_Line_Number__c = null;
			exch.exchItem.Price_Override_Amount__c = null;
			exch.exchItem.Price_Override_Type__c = null;
			exch.exchItemSkuDescription = '';
			exch.noPriceOverride = false;
		}
		
        public PageReference exchProductChanged() {
        	
        	if (this.exchItem.Exch_Product__c != null) {
        		this.exchItem.Exch_Quantity__c = null;
        		this.exchItem.Exch_Price__c = null;
        		this.exchItem.Price_Override_Type__c = null;
        		this.exchItem.Price_Override_Amount__c = null;
        		this.noPriceOverride = false;
            	if (this.exchItem.CW_SKU_ID__c == this.exchItem.Exch_Product__c || this.exchItem.Line_Number__c == null) {
            		this.noPriceOverride = true;
            	}
        		
        		Product2 exchProd = [select Id, Actual_Product_Name__c from Product2 where Id = :this.exchItem.Exch_Product__c limit 1];
        		this.exchItemSkuDescription = exchProd.Actual_Product_Name__c;
        		
        		priceExchangeItem(this);
        	}
        	
        	return null;
        }
        
        public PageReference exchQuantityChanged() {
			
			if (String.isBlank(this.exchItem.Price_Override_Type__c)) {
				this.exchItem.Price_Override_Amount__c = null;
				this.exchItem.Price_Override_Reason__c = '';
			}
			priceExchangeItem(this);
			
			return null;
        }
        
		// Set the pricing for the exchange item
		public Boolean priceExchangeItem(ExchClass exch) {
			Boolean priceOk = true;
			Case_Line_Items__c exchItem = exch.exchItem;
			
			if (exchItem.Exch_Product__c != null) {
				
				// Set return quantity, unit price and totals
				exchItem.Quantity_Returned__c = (exchItem.Quantity_Returned__c == null) ? 1 : exchItem.Quantity_Returned__c;
				exchItem.Unit_Price__c = (exchItem.Unit_Price__c == null) ? 0 : exchItem.Unit_Price__c;
				exchItem.Return_Amount__c = exchItem.Quantity_Returned__c * exchItem.Unit_Price__c;
				
				// Set the exchange quantity, unit price - either product member or non-member price, or unit price from order line (MIS-SHIP return) and totals
				exchItem.Exch_Quantity__c = (exchItem.Exch_Quantity__c == null) ? 1 : exchItem.Exch_Quantity__c;
				Product2 exchProd = [select Id, Name, Direct_Current_Price__c, Member_Price__c from Product2 where Id = :exchItem.Exch_Product__c];
				exchItem.Exch_Unit_Price__c = (exch.rtn.thisCase_ReturnReceiptCtlExt.rhOrder.Contact_Sold_To__r.Has_Membership__c) ? exchProd.Member_Price__c : exchProd.Direct_Current_Price__c;
				if (exchItem.Line_Number__c == null && exchItem.Exch_Order_Line_Number__c != null) {
					Order_Line_Items__c exchOLI = [select Id, Unit_Price__c from Order_Line_Items__c where Id = :exchItem.Exch_Order_Line_Number__c];
					exchItem.Exch_Unit_Price__c = exchOLI.Unit_Price__c;
				}
				exchItem.Exch_Unit_Price__c = (exchItem.Unit_Price__c == null) ? 0 : exchItem.Exch_Unit_Price__c;
				exchItem.Exch_Price__c = exchItem.Exch_Unit_Price__c;
				exchItem.Exch_Amount__c = exchItem.Exch_Quantity__c * exchItem.Exch_Price__c;
				
				// Set the customer unit price of the exchange item - considers price override and exchange item SKU
				exchItem.No_Charge_Replacement__c = false;
				if (exch.noPriceOverride) {
					
					// If return SKU is a mis-ship
					if (exchItem.Line_Number__c == null) {
						
						exchItem.Exch_Cost__c = 0;
						
					} else {
						
						// Same SKU return/exchange
						if (exchItem.CW_SKU_ID__c == exchItem.Exch_Product__c) {
							exchItem.No_Charge_Replacement__c = true;
							exchItem.Exch_Price__c = (exchItem.Exch_Unit_Price__c < exchItem.Unit_Price__c) ? exchItem.Exch_Unit_Price__c : exchItem.Unit_Price__c;
							exchItem.Exch_Amount__c = exchItem.Exch_Price__c * exchItem.Exch_Quantity__c;
							
							if (exchItem.Unit_Price__c <= exchItem.Exch_Unit_Price__c) {
								exchItem.Exch_Cost__c = (exchItem.Return_Amount__c >= exchItem.Exch_Amount__c) ? 0 : exchItem.Exch_Amount__c - exchItem.Return_Amount__c;
							} else {
								if (exchItem.Quantity_Returned__c >= exchItem.Exch_Quantity__c) {
									exchItem.Exch_Cost__c = 0;
								} else {
									exchItem.Exch_Cost__c = (exchItem.Exch_Quantity__c - exchItem.Quantity_Returned__c) * exchItem.Exch_Price__c;
								}
							}
						}
					}
					
				} else {
					
					if (String.isNotBlank(exchItem.Price_Override_Type__c)) {
						if (exchItem.Price_Override_Amount__c == null) {
							priceOk = false;
						} else {
							if (exchItem.Price_Override_Amount__c < 0) {
								priceOk = false;
							}
							
							if (exchItem.Price_Override_Type__c == '% off') {
								if (exchItem.Price_Override_Amount__c > 100) {
									priceOk = false;
								} else {
									exchItem.Exch_Price__c = exchItem.Exch_Unit_Price__c * ((100 - exchItem.Price_Override_Amount__c) / 100);
								}
							}
							
							if (exchItem.Price_Override_Type__c == 'Amt off') {
								if (exchItem.Price_Override_Amount__c > exchItem.Exch_Unit_Price__c) {
									priceOk = false;
								} else {
									exchItem.Exch_Price__c = exchItem.Exch_Unit_Price__c  - exchItem.Price_Override_Amount__c;
								}
							}
							
							if (exchItem.Price_Override_Type__c == 'New Price') {
								if (exchItem.Price_Override_Amount__c > exchItem.Exch_Unit_Price__c) {
									priceOk = false;
								} else {
									exchItem.Exch_Price__c = exchItem.Price_Override_Amount__c;
								}
							}
						}
					
					} else {
						
						exchItem.Price_Override_Amount__c = null;
						exchItem.Price_Override_Reason__c = '';
					}
					
					exchItem.Exch_Amount__c = exchItem.Exch_Price__c * exchItem.Exch_Quantity__c;
					
					// Determine if all, some, or none of exchange is a no charge replacement
					if (exchItem.Unit_Price__c == exchItem.Exch_Price__c) {
						if (exchItem.Return_Amount__c > exchItem.Exch_Amount__c) {
							exchItem.Exch_Cost__c = 0;
						} else {
							exchItem.Exch_Cost__c = exchItem.Exch_Amount__c - exchItem.Return_Amount__c;
						}
						exchItem.No_Charge_Replacement__c = true;
					} else {
						exchItem.Exch_Cost__c = exchItem.Exch_Amount__c;
					}
				}
				
			} else {
				
				clearExchItem(exch);
				
			}
			
			return priceOk;
		}
    	
    	public PageReference displayProductSearch() {
        	
        	this.productSearch = true;
        	this.productSearchString = '';
        	this.noPriceOverride = true;
        	
        	return this.executeProductSearch();
        }
        
        public PageReference executeProductSearch() {
        	
        	this.searchResults.clear();
        	
        	if (String.isNotBlank(this.productSearchString)) {
        		List<List<SObject>> searchList = [FIND :this.productSearchString IN ALL FIELDS RETURNING Product2 (Id, Name, IsActive, Actual_Product_Name__c, Category__c, Collection__c, Dropship__c, Ecommerce_Display_Name__c, Fulfilling_Warehouse__c, SKU_Ship_Via__c, Web_Description__c, Direct_Current_Price__c, Member_Price__c) LIMIT 200];
        		
        		for (SObject s :searchList[0]) {
        			if (((Product2)s).IsActive) {
        				this.searchResults.add(new ExchProductSearchResultsClass(this, null, (Product2)s));
        			}
        		}
        	}
        	
        	this.noProductSearchResults = (this.searchResults.isEmpty()) ? true : false;
        	
        	return null;
        }
        
        public PageReference cancelProductSearch() {
        	
    		this.productSearch = false;
        	this.productSearchString = '';
        	this.noProductSearchResults = true;
        	this.searchResults.clear();
        	
        	this.noPriceOverride = false;
        	if (this.exchItem.Exch_Product__c == null) {
        		if (this.exchItem.Exchange__c) {
        			this.rtn.clearExchangeData();
        		}
        	} else {
        		if (this.exchItem.CW_SKU_ID__c == this.exchItem.Exch_Product__c || this.exchItem.Line_Number__c == null) {
            		this.noPriceOverride = true;
            	}
        	}
        	
    		return null;
    	}
    }
    
	// Return data and methods
	public class RtnClass {
		public Case_Line_Items__c rtnItem {get; set;}
		public List<ExchClass> exchList {get; set;}
		public Boolean showExchange {get; set;}
		private Case_ReturnReceiptCtlExt thisCase_ReturnReceiptCtlExt;
		
		public RtnClass(Case_Line_Items__c rtnItem, Case_ReturnReceiptCtlExt crr) {
			this.rtnItem = rtnItem;
            this.exchList = new List<ExchClass>();
			this.exchList.add(new ExchClass(this));
			this.thisCase_ReturnReceiptCtlExt = crr;
		}
		
		// Clear out an exchange item
		public void clearExchangeData() {
			
			system.debug('***** notReceivedReturnableQty (clearExchangeData) = ' + this.exchList[0].notReceivedReturnableQty);
			
			this.rtnItem.Exchange__c = false;
			this.rtnItem.No_Charge_Replacement__c = false;
			this.showExchange = false;
			this.exchList[0].noPriceOverride = false;
			this.exchList[0].productSearch = false;
			this.exchList[0].productSearchString = '';
			this.exchList[0].searchResults.clear();
			this.exchList[0].notReceivedReturnableQty = 0;
			this.exchList[0].notReceived = false;
			this.exchList[0].notReceivedList.clear();
			this.rtnItem.Exch_Amount__c = null;
			this.rtnItem.Exch_Cost__c = null;
			this.rtnItem.Exch_Price__c = null;
			this.rtnItem.Exch_Product__c = null;
			this.rtnItem.Exch_Quantity__c = null;
			this.rtnItem.Exch_Unit_Price__c = null;
			this.rtnItem.Exch_Order_Line_Number__c = null;
			this.rtnItem.Price_Override_Amount__c = null;
			this.rtnItem.Price_Override_Type__c = null;
		}
		
		// Toggle the display of the exchange data
		public PageReference toggleExchange() {
			
			if (this.rtnItem.Exchange__c) {
				this.showExchange = true;
				this.exchList[0].noPriceOverride = true;
				this.rtnItem.Complimentary_Credit__c = false;
				if (this.rtnItem.Line_Number__c != null) {
					this.exchList[0].productSearch = true;
				} else {
					this.exchList[0].notReceived = true;
					for (ExchNotReceivedClass nr :this.thisCase_ReturnReceiptCtlExt.returnableList) {
						this.exchList[0].notReceivedList.add(new ExchNotReceivedClass(this.exchList[0], nr.returnableQuantity, nr.oli));
					}
				}
			} else {
				this.clearExchangeData();
				if (this.rtnItem.Out_of_Policy_Return__c) {
					this.rtnItem.Complimentary_Credit__c = true;
				}
			}
			
			return null;
		}
		
		public PageReference quantityChanged() {
        	Decimal qty = (this.rtnItem.Quantity_Returned__c == null) ? 0 : this.rtnItem.Quantity_Returned__c;
        	Decimal up = (this.rtnItem.Unit_Price__c == null) ? 0 : this.rtnItem.Unit_Price__c;
        	this.rtnItem.Return_Amount__c = qty * up;
        	
        	if (!this.rtnItem.Refund_Deposit__c && this.rtnItem.CW_SKU_ID__r.Dropship__c) {
				this.rtnItem.Return_Amount__c = this.rtnItem.Return_Amount__c / 2;
        	}
        	return null;
        }
        
        public PageReference deleteReturnItem() {
            
            delete this.rtnItem;
            
            // Rebuild the list of return items
            this.thisCase_ReturnReceiptCtlExt.initCaseLineList();
            this.thisCase_ReturnReceiptCtlExt.initOrderLineList();
            this.thisCase_ReturnReceiptCtlExt.validateReturnReceiptData();
            
            return null;
        }
	}
	
	// Return wrapper class - helps spacing between the return rows in the return item table
	public class RtnWrapperClass {
		public List<RtnClass> rtns {get; set;}
		
		public RtnWrapperClass(RtnClass rtn) {
			this.rtns = new List<RtnClass>();
			this.rtns.add(rtn);
		}
	}
	
    ApexPages.StandardController stdController;
    public String caseId {get; set;}
    public Case rhCase {get; set;}
    public List<RtnWrapperClass> rwList {get; set;}
    public List<Case_Line_Items__c> rhCaseLineList {get; set;}
    public RH_Order__c rhOrder {get; set;}
    public Ship_To__c rhShipTo {get; set;}
    public Boolean noPreview {get; set;}
    public Boolean editMode {get; set;}
    public Boolean editReturnItemsMode {get; set;}
    public Boolean addCaseLines {get; set;}
    public Boolean noCaseLines {get; set;}
    public String missingReturnReceiptData {get; set;}
    public Boolean missingCaseData {get; set;}
    public Boolean missingCaseLineData {get; set;}
    public Boolean fatalError {get; set;}
    public Boolean dcNotSelected {get; set;}
    public Boolean isNewReturn {get; set;}
    public Boolean noOrderLines {get; set;}
    public Boolean approvalRequired {get; set;}
    public Boolean recordLocked {get; set;}
    public Boolean isApproved {get; set;}
    public Boolean isProcessed {get; set;}
    
    private String orderId;
    private List<Order_Line_Items__c> orderLineList;
    private List<ExchNotReceivedClass> returnableList;
    private Map<Id, Decimal> returnableQtyMap;
    private String galleryQueueId;
    private String cscQueueId;
    
    // Instance handle for executing base methods from within wrapper instances
    private Case_ReturnReceiptCtlExt thisCase_ReturnReceiptCtlExt;
    
    // Constructor
    public Case_ReturnReceiptCtlExt(ApexPages.StandardController stdController) {
        
        rwList = new List<RtnWrapperClass>();
        
        orderLineList = new List<Order_Line_Items__c>();
        returnableList = new List<ExchNotReceivedClass>();
        returnableQtyMap = new Map<Id, Decimal>();
        addCaseLines = false;
        noCaseLines = false;
        noOrderLines = false;
        noPreview = true;
        editMode = false;
        editReturnItemsMode = false;
        missingCaseData = false;
        missingCaseLineData = false;
        fatalError = false;
        dcNotSelected = true;
        isNewReturn = false;
        approvalRequired = false;
        isProcessed = false;
        recordLocked = false;
        isApproved = false;
        caseId = null;
        orderId = null;
        String shipToId = null;
        missingReturnReceiptData = '';
        
        this.rhCase = (Case) stdController.getRecord();
        this.thisCase_ReturnReceiptCtlExt = (Case_ReturnReceiptCtlExt) this;
        
        caseId = ApexPages.currentPage().getParameters().get('caseId');
        
        rhCase = new Case();
        rhOrder = new RH_Order__c();
        rhShipTo = new Ship_To__c();
        rhCaseLineList = new List<Case_Line_Items__c>();
        
        // Verify that we have a case, order, and ship to 1
        try {
            initCase();
            orderId = rhCase.RH_Order_Number__c;
            
            if (orderId != null) {
                rhOrder = [select Id, Name, Sold_To_Address_1__c, Sold_to_Address_2__c, Sold_to_Company__c, Sold_to_City__c, 
                    Sold_to_Country__c, Sold_to_Country_Code__c, Sold_to_Email__c, Sold_to_First_Name__c, Sold_to_Last_Name__c, 
                    Sold_to_State__c, Sold_to_Zip__c, Sold_to_Day_Phone__c, Order_Date__c, Division__c, 
                    Contact_Sold_To__c, Contact_Sold_To__r.Has_Membership__c 
                    from RH_Order__c where Id = :rhCase.RH_Order_Number__c];
                
                rhShipTo = [select Id, Name, Order__c, Ship_to_First_Name__c, Ship_to_Last_Name__c, Ship_to_Address_1__c, 
                    Ship_to_Address_2__c, Ship_to_City__c, Ship_to_State__c, Ship_to_Zip__c, Ship_to_Country__c 
                    from Ship_To__c where Order__c = :rhOrder.Id and Name = '1'];
                
                shipToId = rhShipTo.Id;
            }
        } catch(Exception e) {
            system.debug('*****Case_ReturnReceiptCtlExt - exception reading base data = ' + e.getMessage());
        }
        
        if (caseId == null || orderId == null || shipToId == null) {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'No Case, Order, and/or Ship To 1. This page must be associated with a Case that is associated with an Order with a Ship To 1.'));
            fatalError = true;
            
        } else {
            
            // Initialize the current case line list, set default values, and isNewReturn
            initCaseLineList();
            if ( rhCaseLineList.isEmpty() && rhCase.Return_Date__c == null && String.isBlank(rhCase.Return_Location__c) && 
                 String.isBlank(rhCase.Send_To__c) && rhCase.Status == 'New' && 
                 rhCase.CreatedById == UserInfo.getUserId() && rhCase.OwnerId == UserInfo.getUserId()) {
                isNewReturn = true;
            }
            if (rhCase.Return_Date__c == null) {
                rhCase.Return_Date__c = rhCase.CreatedDate;
            }
            if (String.isBlank(rhCase.Return_Location__c)) {
                User u = new User();
                u = [select Id, Gallery__c from User where Id = :rhCase.CreatedById];
                rhCase.Return_Location__c = u.Gallery__c;
            }
            if (String.isBlank(rhCase.Client_Type__c)) {
                rhCase.Client_Type__c = 'Standard';
            }
            
            // Initialize the gallery return DCs
            initReturnDCs();
            
            // Initialize the list of order lines available for selection
            initOrderLineList();
            
            // Set the default To email address
            rhCase.To_Email_Address__c = rhOrder.Sold_to_Email__c;
            //rhCase.Additional_To_Email_Addresses__c = '';
            
            // Verify that we have required case data and case line data to generate the return receipt
            validateReturnReceiptData();
            
            // Initialize approval process
            initApprovalProcess();
            
            system.debug('*****Case_ReturnReceipt constructor flags caseApprovalStatus = ' + rhCase.Exchange_Approval_Status__c + ' caseApprovalRequired = ' + rhCase.Exchange_Approval_Required__c + ' missingCaseData = ' + missingCaseData + ' noCaseLines = '+ noCaseLines + ' fatalError = ' + fatalError + ' noOrderLines = ' + noOrderLines + ' recordLocked = ' + recordLocked + ' isApproved = ' + isApproved);
        }
    }
    
    // Initialize Return DCs for the Return Location gallery
    String galleryFurnDC;
    String gallerySSDC;
    String galleryEmail;
    private void initReturnDCs() {
        
        galleryFurnDC = '';
        gallerySSDC = '';
        galleryEmail = '';
        
        if (String.isNotBlank(rhCase.Return_Location__c)) {
            Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
            List<Account> galleryAccount = new List<Account>();
            galleryAccount = [select Id, Name, Email__c, Furniture_Return_DC__c, Furniture_Return_DC__r.HDL_Code__c, 
                    Shelf_Stock_Return_DC__c, Shelf_Stock_Return_DC__r.HDL_Code__c 
                    from Account where Name = :rhCase.Return_Location__c and RecordTypeId = :rtMap.get('Internal').getRecordTypeId() limit 1];
            if (!galleryAccount.isEmpty()) {
                galleryFurnDC = galleryAccount[0].Furniture_Return_DC__r.HDL_Code__c;
                gallerySSDC = galleryAccount[0].Shelf_Stock_Return_DC__r.HDL_Code__c;
                galleryEmail = galleryAccount[0].Email__c;
            }
        }
    }
    
    // Initialize Case
    private void initCase() {
        
        if (caseId != null) {
            rhCase = [select Id, CaseNumber, Status, RH_Order_Number__c, Send_To__c, Send_to_Address_1__c, 
                    Send_to_Address_2__c, Send_to_Company__c, Send_to_City__c, Send_to_Email__c, NCR_Special_Processing__c, 
                    Send_to_Day_Phone__c, Send_to_Night_Phone__c, Gallery_Email__c, Return_Receipt_Processed__c, 
                    Send_to_First_Name__c, Send_to_Last_Name__c, Send_to_State__c, Send_to_Zip__c, Send_to_Country_Code__c, 
                    ShipTo1_Address__c, ShipTo1_Name__c, ShipTo1_Day_Phone__c, ShipTo1_Night_Phone__c, 
                    Sold_to_Address__c, Sold_to_Name__c, Sold_to_Day_Phone__c, Sold_to_Night_Phone__c, Sold_to_Email__c, 
                    Return_Date__c, Return_Location__c, Tracking_Number_1__c, Tracking_Number_2__c, Tracking_Number_3__c, 
                    Tracking_Number_4__c, Tracking_Number_5__c, Tracking_Number_6__c, 
                    Tracking_1__c, Tracking_2__c, Tracking_3__c, Tracking_4__c, Tracking_5__c, Tracking_6__c, 
                    To_Email_Address__c, Additional_To_Email_Addresses__c, Client_Type__c, CreatedDate, 
                    CreatedById, OwnerId, Email_Subject_Brand__c, Email_Alert_Trigger__c, 
                    Exchange_Approval_Rejection_Reason__c, Exchange_Approval_Status__c, Exchange_Approval_Required__c, Executive_Summary_Text__c 
                    from Case where Id = :caseId];
			
			isApproved = (rhCase.Exchange_Approval_Status__c == 'Approved') ? true : false;
			
			isProcessed = rhCase.Return_Receipt_Processed__c;
			if (isProcessed) {
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, 'This Return Receipt has been processed (transferred), only limited functionality is available.'));
			}
		}
	}
        
    // Initialize Case Line list
    private void initCaseLineList() {
        
        String cliQuery = 'SELECT Id, Name, Case_Number__c, Return_Reason__c, Quantity_Returned__c, Refund_Deposit__c, '
                    + 'Return_Reason_Description__c, Order_Quantity__c, Unit_Price__c, Return_DC__c, Return_Amount__c, '
                    + 'Return_Type__c, Out_of_Policy_Return__c, Exchange__c, No_Charge_Replacement__c, Exch_Amount__c, '
                    + 'Exch_Cost__c, Exch_Price__c, Exch_Quantity__c, Exch_Unit_Price__c, Exch_Order_Line_Number__c, '
                    + 'Exch_Product__c, Exch_Product__r.Name, Exch_Product__r.Actual_Product_Name__c, '
                    + 'Exch_Product__r.Ecommerce_Display_Name__c, Exch_Product__r.Web_Description__c, '
                    + 'Price_Override_Amount__c, Price_Override_Type__c, Price_Override_Reason__c, Complimentary_Credit__c, '
                    + 'Line_Number__c, Line_Number__r.Shipped_DC__c, Line_Number__r.Return_Quantity__c, '
                    + 'Line_Number__r.Shipped_Quantity__c, CW_SKU_ID__c, CW_SKU_ID__r.Name, CW_SKU_ID__r.SKU_Ship_Via__c, '
                    + 'CW_SKU_ID__r.Fulfilling_Warehouse__c, CW_SKU_ID__r.Dropship__c, CW_SKU_ID__r.Actual_Product_Name__c, '
                    + 'Order__c, Order__r.Contact_Sold_To__r.Has_Membership__c FROM Case_Line_Items__c';
        String cliWhere = ' WHERE Case_Number__c = \'' + caseId + '\'';
        
        rhCaseLineList.clear();
        rwList.clear();
        noCaseLines = true;
        
        rhCaseLineList = Database.query(cliQuery + cliWhere);
        
        rhCase.NCR_Special_Processing__c = false;
        Decimal priceDiff;
        if (!rhCaseLineList.isEmpty()) {
            noCaseLines = false;
            
            for (Case_Line_Items__c cli :rhCaseLineList) {
            	rwList.add(new RtnWrapperClass(new RtnClass(cli, thisCase_ReturnReceiptCtlExt)));
            	
            	// Determine if the no charge replacement requires special processing by CSC
				if (cli.No_Charge_Replacement__c) {
					if (cli.CW_SKU_ID__c != null && cli.Exch_Product__c != null && cli.CW_SKU_ID__c != cli.Exch_Product__c) {
						rhCase.NCR_Special_Processing__c = true;
					}
					
					if (cli.Unit_Price__c != null && cli.Exch_Price__c != null) {
						priceDiff = math.abs(cli.Unit_Price__c - cli.Exch_Price__c);
						if (pricediff > 5) {
							rhCase.NCR_Special_Processing__c = true;
						}
					}
				}
            }
        }
        
        recordLocked = Approval.isLocked(rhCase.Id);
        //noSubmit = recordLocked;
        approvalRequired = isApprovalRequired();
        if (approvalRequired) {
            String approvalWarning = 'Exchange approval';
            if (rhCase.Exchange_Approval_Status__c == 'Rejected') {
            	approvalWarning += ' rejected. Remove the discount and transfer the case for processing or adjust the discount and re-submit for approval.';
            } else {
            	approvalWarning += ' required.';
            }
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.WARNING, approvalWarning));
        }
    }
    
    // Determine if approval is required (exchange item Exch_Unit_Price__c is not the same as the exchange item Exch_Price__c)
    private Boolean isApprovalRequired() {
        Boolean approvalReq = false;
        String approvalSummary = '';
        Map<String, Application_Settings__c> appSettings = Application_Settings__c.getall();
        Decimal percentThreshold;
        Decimal amountThreshold;
        Decimal threshold;
        Decimal absDiff;
        String itemDescription;
        Decimal itemDiscount;
        Decimal itemDiscountPct;
        Decimal totalUnitPrice = 0;
        Decimal totalExchPrice = 0;
        Decimal totalDiscount;
        Decimal totalDiscountPct;
        Boolean isLeader;
        
        isLeader = false;
        Map<Id, UserRole> urMap = new Map<Id, UserRole>([select Id, Name from UserRole where Name = 'Gallery Field Leader' or Name = 'Gallery Leader']);
        if (rhCase.OwnerId == UserInfo.getUserId() && urMap.containsKey(UserInfo.getUserRoleId())) {
        	isLeader = true;
        }
        
        if (rhCase.Exchange_Approval_Status__c != 'Approved' && !rhCase.Return_Receipt_Processed__c && !isLeader) {
        	
        	RtnClass ri;
        	for (RtnWrapperClass rw :rwList) {
        		ri = rw.rtns[0];
        		
        		// Skip approval required check if price override not allowed
        		if (ri.exchList[0].noPriceOverride) {
        			continue;
        		}
        		
				if ( (ri.rtnItem.Exch_Unit_Price__c != ri.rtnItem.Exch_Price__c) && 
					 (ri.rtnItem.Exch_Unit_Price__c != null && ri.rtnItem.Exch_Price__c != null) ) {
					
					absDiff = math.abs(ri.rtnItem.Exch_Unit_Price__c - ri.rtnItem.Exch_Price__c);
                    
                    if (ri.rtnItem.Exch_Price__c > ri.rtnItem.Exch_Unit_Price__c) {
                        percentThreshold = ri.rtnItem.Exch_Unit_Price__c * (appSettings.get('Exch Greater Cost Percent Threshold').Value_Numeric__c / 100);
                        amountThreshold = appSettings.get('Exch Greater Cost Amount Threshold').Value_Numeric__c;
                        threshold = (percentThreshold < amountThreshold) ? percentThreshold : amountThreshold;
                    }
                    
                    if (ri.rtnItem.Exch_Price__c < ri.rtnItem.Exch_Unit_Price__c) {
                        percentThreshold = ri.rtnItem.Exch_Unit_Price__c * (appSettings.get('Exch Lessor Cost Percent Threshold').Value_Numeric__c / 100);
                        amountThreshold = appSettings.get('Exch Lessor Cost Amount Threshold').Value_Numeric__c;
                        threshold = (percentThreshold > amountThreshold) ? percentThreshold : amountThreshold;
                    }
                    
                    if (absDiff > threshold) {
                        approvalReq = true;
                        itemDescription = (String.isNotBlank(ri.rtnItem.Exch_Product__r.Ecommerce_Display_Name__c)) ? ri.rtnItem.Exch_Product__r.Ecommerce_Display_Name__c : ri.rtnItem.Exch_Product__r.Web_Description__c;
                        if (String.isBlank(itemDescription)) {
                        	itemDescription = 'item description not available';
                        }
                        
                        itemDiscount = ((ri.rtnItem.Exch_Unit_Price__c * ri.rtnItem.Exch_Quantity__c) - (ri.rtnItem.Exch_Price__c * ri.rtnItem.Exch_Quantity__c)).setScale(2);
                        itemDiscountPct = ((itemDiscount / (ri.rtnItem.Exch_Unit_Price__c * ri.rtnItem.Exch_Quantity__c)) * 100).setScale(2);
                        totalUnitPrice += ri.rtnItem.Exch_Unit_Price__c * ri.rtnItem.Exch_Quantity__c;
                        totalExchPrice += ri.rtnItem.Exch_Price__c * ri.rtnItem.Exch_Quantity__c;
                        
                        if (String.isBlank(approvalSummary)) {
                        	approvalSummary = 'PRICE OVERRIDE SUMMARY\n';
                        }
                        approvalSummary += 'Item: ' + ri.rtnItem.Exch_Product__r.Name + ' - ' + itemDescription + '\n';
                        approvalSummary += 'Pre-adjustment Price: $' + String.valueOf((ri.rtnItem.Exch_Unit_Price__c * ri.rtnItem.Exch_Quantity__c).setScale(2)) + '\n';
                        approvalSummary += 'Adjusted Price: $' + String.valueOf((ri.rtnItem.Exch_Price__c * ri.rtnItem.Exch_Quantity__c).setScale(2)) + '\n';
                        approvalSummary += 'Total Item Discount: -$' + String.valueOf(itemDiscount) + ', -' + String.valueOf(itemDiscountPct) + '%\n';
                        approvalSummary += 'Discount Reason: ' + ri.rtnItem.Price_Override_Reason__c + '\n\n';
                    }
				}
            }
            
            if (approvalReq) {
            	totalDiscount = (totalUnitPrice - totalExchPrice).setScale(2);
            	totalDiscountPct = ((totalDiscount / totalUnitPrice) * 100).setScale(2);
            	approvalSummary += 'Total Exchange Discount: -$' + String.valueOf(totalDiscount) + ', -' + String.valueOf(totalDiscountPct) + '%\n';
            	rhCase.Executive_Summary_Text__c = approvalSummary;
            }
        }
        
        rhCase.Exchange_Approval_Required__c = approvalReq;
        return approvalReq;
    }
    
    // Initialize list of Order Lines that are available for selection
    private void initOrderLineList() {
        
        RtnClass returnItem;
        Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case_Line_Items__c.getRecordTypeInfosByName();
        orderLineList.clear();
        returnableList.clear();
        returnableQtyMap.clear();
        availableOrderLines.clear();
        selectedOrderLines.clear();
        noOrderLines = true;
        
        orderLineList = [select Id, Name, CW_SKU_ID__c, CW_SKU_ID__r.Name, CW_SKU_ID__r.Fulfilling_Warehouse__c, 
                CW_SKU_ID__r.SKU_Ship_Via__c, CW_SKU_ID__r.Dropship__c, CW_SKU_ID__r.Actual_Product_Name__c, 
                CW_SKU_ID__r.No_Gallery_Return__c, Return_Quantity__c, Line_Number__c, Item_Description__c, 
                Order_Quantity__c, Unit_Price__c, Shipped_DC__c, Shipped_Quantity__c, Ship_Date__c 
                from Order_Line_Items__c 
                where RH_Order_Number__c = :orderId and CW_SKU_ID__r.No_Gallery_Return__c = false and CW_SKU_ID__r.BOM_Sku__c = false 
                order by Name];
		
		Set<Id> pIds = new Set<Id>();
		for (Order_Line_Items__c oli :orderLineList) {
			if (oli.CW_SKU_ID__c != null) {
				pIds.add(oli.CW_SKU_ID__c);
			}
		}
		
		Map<Id, Product2> prodMap = new Map<Id, Product2>([select Id, Name, Actual_Product_Name__c, Dropship__c, Fulfilling_Warehouse__c, SKU_Ship_Via__c 
				from Product2 where Id in :pIds]);
            
        Decimal shippedQty;
        Decimal prevRtnQty;
        Decimal returnableQty;
        Decimal cliReturnedQty;
        Product2 sku;
        for (Order_Line_Items__c oli :orderLineList) {
            if (oli.Shipped_Quantity__c == null) {
                shippedQty = 0;
            } else {
                shippedQty = oli.Shipped_Quantity__c;
            }
            if (oli.Return_Quantity__c == null) {
                prevRtnQty = 0;
            } else {
                prevRtnQty = oli.Return_Quantity__c;
            }
            
            cliReturnedQty = 0;
            for (RtnWrapperClass rw :rwList) {
                if (oli.Id == rw.rtns[0].rtnItem.Line_Number__c) {
                    if (rw.rtns[0].rtnItem.Quantity_Returned__c > 0) {
                        cliReturnedQty += rw.rtns[0].rtnItem.Quantity_Returned__c;
                    }
                }
                
                if (oli.Id == rw.rtns[0].rtnItem.Exch_Order_Line_Number__c) {
                    if (rw.rtns[0].rtnItem.Exch_Quantity__c > 0) {
                        cliReturnedQty += rw.rtns[0].rtnItem.Exch_Quantity__c;
                    }
                }
            }
            
            returnableQtyMap.put(oli.Id, shippedQty - prevRtnQty);
            
            returnableQty = shippedQty - prevRtnQty - cliReturnedQty;
            if (returnableQty > 0) {    
                returnItem = new RtnClass(new Case_Line_Items__c(), thisCase_ReturnReceiptCtlExt);
                returnItem.rtnItem.RecordTypeId = rtMap.get('Returns').getRecordTypeId();
                
                if (prodMap.containsKey(oli.CW_SKU_ID__c)) {
                	sku = prodMap.get(oli.CW_SKU_ID__c);
                } else {
                	sku = new Product2();
                }
                
                if (!oli.CW_SKU_ID__r.No_Gallery_Return__c) {
                	availableOrderLines.add(new SelectOrderLineClass(false, returnableQty, oli, sku, returnItem));
                }
                returnableList.add(new ExchNotReceivedClass(returnItem.exchList[0], returnableQty, oli));
            }
        }
        
        //system.debug('*****initOrderLines availableOrderLines.size = ' + availableOrderLines.size());
        
        if (!availableOrderLines.isEmpty()) {
            noOrderLines = false;
        }
    }
    
    // Validate return receipt data
    private void validateReturnReceiptData() {
        String missingFields = '';
        
        missingCaseData = false;
        missingCaseLineData = false;
        addCaseLines = false;
        noPreview = true;
        editMode = false;
        //editReturnItemsMode = false;
        
        // Verify that we have required order, order line, case, case line data to generate the return receipt
        if (noOrderLines && isNewReturn) {
            editMode = true;
            missingReturnReceiptData = 'Order ' + rhOrder.Name + ' does not have any returnable items.';
        } else {
            missingReturnReceiptData = 'Please provide missing return receipt data: ';
            missingFields = validateCaseData();
            if (String.isBlank(missingFields)) {
                if (rhCaseLineList.isEmpty()) {
                    //addCaseLines = true;
                    missingCaseLineData = true;
                    missingReturnReceiptData += 'select one or more order lines to return.';
                } else {
                	missingReturnReceiptData += 'one or more return items ';
                    missingFields = validateCaseLineData();
                    if (String.isBlank(missingFields)) {
                        noPreview = false;
                    } else {
                        missingCaseLineData = true;
                        missingReturnReceiptData += missingFields.removeEnd(', ') + '.';
                    }
                }
            } else {
                missingCaseData = true;
                if (isNewReturn) {
                    editMode = true;
                }
                missingReturnReceiptData += missingFields.removeEnd(', ') + '.';
            }
        }
    }
    
    // Validate case data
    private String validateCaseData() {
        
        // Validate case information for the email
        String missingCaseFields = '';
        Map<String,Schema.SObjectField> FieldMap = Schema.SObjectType.Case.fields.getMap();

        if (String.isBlank(rhCase.Client_Type__c)) {
            missingCaseFields += FieldMap.get('Client_Type__c').getDescribe().getLabel() + ', ';
        }
        if (String.isBlank(rhCase.Send_To__c)) {
            missingCaseFields += FieldMap.get('Send_To__c').getDescribe().getLabel() + ', ';
        }
        
        if (String.isBlank(rhCase.Return_Location__c)) {
            missingCaseFields += FieldMap.get('Return_Location__c').getDescribe().getLabel() + ', ';
        }
        
        if (rhCase.Return_Date__c == null) {
            missingCaseFields += FieldMap.get('Return_Date__c').getDescribe().getLabel() + ', ';
        }
        
        return missingCaseFields;
    }
    
    // Validate required case line data
    public String validateCaseLineData() {
        
        String missingCaseLineFields = '';
        Boolean outOfPolicy = false;
        
		Map<String,Schema.SObjectField> FieldMap = Schema.SObjectType.Case_Line_Items__c.fields.getMap();
		for (Case_Line_Items__c cli :rhCaseLineList) {
			if (cli.Quantity_Returned__c == null || cli.Quantity_Returned__c <= 0) {
				missingCaseLineFields += FieldMap.get('Quantity_Returned__c').getDescribe().getLabel() + ', ';
			}
			if (String.isBlank(cli.Return_Reason__c)) {
				missingCaseLineFields += FieldMap.get('Return_Reason__c').getDescribe().getLabel() + ', ';
			}
			if (cli.Out_of_Policy_Return__c && cli.Complimentary_Credit__c) {
				outOfPolicy = true;
			}
		}
		
		if (String.isNotBlank(missingCaseLineFields)) {
			missingCaseLineFields = 'have missing or bad data in fields ' + missingCaseLineFields;
		} else {
			if (outOfPolicy) {
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.WARNING, 'One or more return items exceeds our 30 day Return Policy. The refund will be issued in the form of a Complimentary Credit. If an exception is required, uncheck the Complimentary Credit box for the client to be refunded in their original method of payment. If the return is over 2 years old, the client will be issued a mail check. Verify the client\'s address for the shipment of the refund.'));
			}
		}
        
        return missingCaseLineFields;
    }
    
    List<SelectOrderLineClass> availableOrderLines = new List<SelectOrderLineClass>();
    List<SelectOrderLineClass> selectedOrderLines = new List<SelectOrderLineClass>();
    
    // Return the list of selected and unselected order lines
    public List<SelectOrderLineClass> getOrderLines() {
        
        return availableOrderLines;
    }
    
    public PageReference getSelected() {
        
        selectedOrderLines.clear();
        for (SelectOrderLineClass solc :availableOrderLines) {
            if (solc.selected) {
                selectedOrderLines.add(solc);
                solc.returnItem.rtnItem.CW_SKU_ID__c = solc.sku.Id;
                solc.returnItem.rtnItem.Line_Number__c = solc.orderLine.Id;
                solc.returnItem.rtnItem.Refund_Deposit__c = solc.sku.Dropship__c;
                solc.returnItem.rtnItem.Unit_Price__c = (solc.orderLine.Unit_Price__c == null) ? 0 : solc.orderLine.Unit_Price__c;
                solc.returnItem.rtnItem.Quantity_Returned__c = 1;
                if (solc.returnItem.rtnItem.Line_Number__c == null) {
                	solc.returnItem.rtnItem.Unit_Price__c = (solc.returnItem.thisCase_ReturnReceiptCtlExt.rhOrder.Contact_Sold_To__r.Has_Membership__c) ? solc.sku.Member_Price__c : solc.sku.Direct_Current_Price__c;
                }
            } else {
            	solc.returnItem.rtnItem.Exchange__c = false;
            }
        }
        
        return null;
    }
    
    public List<SelectOrderLineClass> getselectedOrderLines() {
        if(selectedOrderLines.size() > 0) {
            return selectedOrderLines;
        } else {
            return null;
        }
    }
    
	// Add one SKU to our availableOrderLines list - this is to enable return of items that are not on the order
	public PageReference misShip() {
		List<SelectOrderLineClass> tempList = new List<SelectOrderLineClass>();
		Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case_Line_Items__c.getRecordTypeInfosByName();
		RtnClass returnItem = new RtnClass(new Case_Line_Items__c(), thisCase_ReturnReceiptCtlExt);
		
		returnItem.rtnItem.RecordTypeId = rtMap.get('Returns').getRecordTypeId();
		
		tempList.addAll(availableOrderLines);
		availableOrderLines.clear();
		
		SelectOrderLineClass solc = new SelectOrderLineClass(false, null, new Order_Line_Items__c(), new Product2(), returnItem);
		solc.solcDisplayProductSearch();
		availableOrderLines.add(solc);
		
		availableOrderLines.addAll(tempList);
		
		return null;
	}
    
    // Methods to support selecting the DC for packing slip printing
    public List<SelectOption> getpackingSlipDCList() {
        List<SelectOption> options = new List<SelectOption>();

		Set<String> dcSet = new Set<String>();
		String rtnDC;
		options.add(new SelectOption('--None--', '--None--'));
		for (Case_Line_Items__c cli :rhCaseLineList) {
			if (cli.Return_Reason__c != 'Damaged - MOS' && cli.Return_Reason__c != 'Defective - MOS') {
				rtnDC = cli.Return_DC__c;
				if (String.isBlank(rtnDC)) {
					rtnDC = 'Blank';
				}
				if (!dcSet.contains(rtnDC)) {
					dcSet.add(rtnDC);
					options.add(new SelectOption(rtnDC, rtnDC));
				}
			}
		}

        return options;
    }
    
    String selectedPackingSlipDC;
    
    public String getselectedPackingSlipDC() {
        return selectedPackingSlipDC;
    }
    
    public void setselectedPackingSlipDC(String dc) {
        selectedPackingSlipDC = dc;
    }
    
    // Decide whether or not the packing slip Print button should be enabled
    public void psSelect() {
        
        if (String.isBlank(selectedPackingSlipDC)) {
            selectedPackingSlipDC = '--None--';
        }
        
        if (selectedPackingSlipDC == '--None--') {
            dcNotSelected = true;
        } else {
            dcNotSelected = false;
        }
    }
    
    public PageReference cancelReturnReceipt() {
        PageReference pr;
        String retURL = '/';
        
        if (isNewReturn) {
            if (rhCase.Id != null) {
            	delete rhCase;
            }
            if (String.isNotBlank(orderId)) {
            	retURL += orderId;
            }
        } else {
            if (String.isNotBlank(caseId)) {
            	retURL += caseId;
            }
            
        }
        
        pr = new PageReference(retURL);
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference editReturn() {
        editMode = true;
        noPreview = true;
        return null;
    }
    
    public PageReference editReturnItems() {
        editReturnItemsMode = true;
        noPreview = true;
        return null;
    }
    
    // Select additional order lines to add to case
    public PageReference selectOrderLines() {
        addCaseLines = true;
        noPreview = true;
        return null;
    }
	
	public String approvalComment {get; set;}
	public Boolean showApproveReject {get; set;}
	public Boolean showApproveRejectButton {get; set;}
	ProcessInstanceWorkItem piwi;
	
	// Initialize the approval process for returns - determine if we should show the approve/reject buttons
	public void initApprovalProcess() {
		List<ProcessInstanceWorkItem> workItemList = new List<ProcessInstanceWorkItem>();
		approvalComment = '';
		piwi = null;
		
		if (rhCase.Exchange_Approval_Status__c == 'Pending') {
			rhCase.Exchange_Approval_Rejection_Reason__c = '';
			workItemList = [select p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.OriginalActorId, p.Id, p.ActorId 
					from ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId = :rhCase.Id];
			if (!workItemList.isEmpty()) {
				piwi = workItemList[0];
				
				// Determine the list of users who can approve or reject
				Set<Id> uIds = new Set<Id>();
				Set<Id> gIds = new Set<Id>();
				Set<Id> rIds = new Set<Id>();
				Profile sysAdmin = [select Id from Profile where Name = 'System Administrator'];
				List<User> userList = new List<User>();
				List<Group> groupList = new List<Group>();
				List<GroupMember> groupMemberList = new List<GroupMember>();
				
				// Add all system administrators to our list of users
				userList = [select Id, ProfileId from User where ProfileId = :sysAdmin.Id];
				for (User u :userList) {
					uIds.add(u.Id);
				}
				
				// Add the delgated approver user
				if (piwi.ActorId.getSobjectType().getDescribe().getName() == 'User') {
					uIds.add(piwi.ActorId);
				}
				
				// Add the original approver users - this can also be a queue (group) that can contain users or roles
				if (piwi.OriginalActorId.getSobjectType().getDescribe().getName() == 'User') {
					uIds.add(piwi.OriginalActorId);
					
					system.debug('*****initApprovalProcess single user approver uId = ' + uIds);
					
				} else {
					if (piwi.OriginalActorId.getSobjectType().getDescribe().getName() == 'Group') {
						groupMemberList = [select Id, GroupId, UserOrGroupId from GroupMember where GroupId = :piwi.OriginalActorId];
						for (GroupMember gm :groupMemberList) {
							if (gm.UserOrGroupId.getSobjectType().getDescribe().getName() == 'User') {
								uIds.add(gm.UserOrGroupId);
							} else {
								gIds.add(gm.UserOrGroupId);
							}
						}
						
						if (!gIds.isEmpty()) {
							groupList = [select Id, RelatedId, Type from Group where Id in :gIds and Type = 'Role'];
							for (Group g :groupList) {
								rIds.add(g.RelatedId);
							}
							
							if (!rIds.isEmpty()) {
								userList = [select Id, UserRoleId from User where UserRoleId in :rIds];
								for (User u :userList) {
									uIds.add(u.Id);
								}
							}
						}
						
						system.debug('*****initApprovalProcess multi-user approvers gIds = ' + gIds + ' rIds = ' + rIds + ' uId = ' + uIds);
						
					}
				}
				
				showApproveRejectButton = false;
				if (uIds.contains(UserInfo.getUserId())) {
					showApproveRejectButton = true;
				}
				
				system.debug('*****initApprovalProcess getUserId = ' + UserInfo.getUserId() + ' showApproveRejectButton = ' + showApproveRejectButton);
			}
		}
	}
	
	public PageReference approveReject() {
		showApproveReject = true;
		return null;
	}
	
	public PageReference approveExch() {
		PageReference pr = null;
		
		try {
			Approval.Processworkitemrequest objReq = new Approval.Processworkitemrequest();
			objReq.setAction('Approve');
			objReq.setComments(approvalComment);
			objReq.setWorkitemId(piwi.Id);
			objReq.setNextApproverIds(new Id[] {UserInfo.getUserId()});
			Approval.ProcessResult result2 =  Approval.process(objReq);
			showApproveReject = false;
			showApproveRejectButton = false;
			pr = new PageReference('/apex/Case_ReturnReceipt?caseId=' + rhCase.Id);
			pr.setRedirect(true);
		} catch(Exception e) {
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Approval process approve exception: ' + e.getMessage()));
		}
		
		return pr;
	}
	
	public PageReference rejectExch() {
		PageReference pr = null;
		
		if (String.isNotBlank(rhCase.Exchange_Approval_Rejection_Reason__c)) {
			try {
				update rhCase;
				Approval.Processworkitemrequest objReq = new Approval.Processworkitemrequest();
				objReq.setAction('Reject');
				objReq.setComments(approvalComment);
				objReq.setWorkitemId(piwi.Id);
				objReq.setNextApproverIds(new Id[] {UserInfo.getUserId()});
				Approval.ProcessResult result2 =  Approval.process(objReq);
				showApproveReject = false;
				showApproveRejectButton = false;
				pr = new PageReference('/apex/Case_ReturnReceipt?caseId=' + rhCase.Id);
				pr.setRedirect(true);
			} catch(Exception e) {
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Approval process reject exception: ' + e.getMessage()));
			}
		} else {
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'You must enter a reason for rejection.'));
		}
		
		return pr;
	}
    
    public PageReference submitApproval() {
        PageReference pr = null;
        
        if (!recordLocked && !Approval.isLocked(rhCase.Id)) {
        	recordLocked = true;	// set to true to help avoid multiple clicks of the Submit for Approval button during case record update
        	try {
            	// First update the case to make sure it is ready for the approval process
            	update rhCase;
            	
            	// Create an approval request for the Case
            	Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            	req1.setObjectId(rhCase.Id);
            	
            	// Submit the approval request for the case and set us up for the approval/rejection
            	Approval.ProcessResult result = Approval.process(req1);
            	initApprovalProcess();
            	pr = new PageReference('/apex/Case_ReturnReceipt?caseId=' + rhCase.Id);
        		pr.setRedirect(true);
        	} catch(Exception e) {
            	if (!ApexPages.hasMessages()) {
            		ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Unable to Submit for Approval. The Returns case does not meet the entry criteria or initial submitters for any active approval process.'));
            	}
            	system.debug('*****Case_ReturnReceiptCtlExt approval process exception: ' + e.getMessage());
        	}
        } else {
        	ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Unable to Submit for Approval, the Returns case is locked.'));
        }
        
        recordLocked = Approval.isLocked(rhCase.Id);
        //noSubmit = recordLocked;
        
        return pr;
    }
    
    // Transfer case to the Gallery queue
    public PageReference transferGallery() {
        
        PageReference pr = null;
        
        try {
            Groups__c grp = Groups__c.getInstance('Gallery Returns Queue');
            Group galleryQueue = [select Id from Group where Name = :grp.Queue_Name__c and Type = 'Queue' limit 1];
            rhCase.OwnerId = galleryQueue.Id;
            rhCase.Return_Receipt_Processed__c = true;
            update rhCase;
            pr = new PageReference('/' + caseId);
            pr.setRedirect(true);
        } catch(Exception e) {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Return Receipt - Case transfer Gallery exception: ' + e.getMessage()));
        }
        
        return pr;
    }
    
    // Transfer case to the CSC queue
    public PageReference transferCSC() {
        
        PageReference pr = null;
        
        try {
            Groups__c grp = Groups__c.getInstance('RHD Returns Queue');
            Group cscQueue = [select Id from Group where Name = :grp.Queue_Name__c and Type = 'Queue' limit 1];
            rhCase.OwnerId = cscQueue.Id;
            rhCase.Return_Receipt_Processed__c = true;
            update rhCase;
            pr = new PageReference('/' + caseId);
            pr.setRedirect(true);
        } catch(Exception e) {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Return Receipt - Case transfer CSC exception: ' + e.getMessage()));
        }
        
        return pr;
    }
    
    private Boolean validateAdditionalEmailAddresses() {
        
        Boolean allGood = true;
        /*
        String badEmailAddrs = '';
        String goodEmailAddrs = '';
        String eAddrs = '';
        additionalEmailAddresses = '';
        
        List<String> addEmailAddrs = new List<String>();
        if (String.isNotBlank(rhCase.Additional_To_Email_Addresses__c)) {
            eAddrs = rhCase.Additional_To_Email_Addresses__c.remove(' ');
            addEmailAddrs.addAll(eAddrs.split(',', 0));
        }
        
        for (String emailAddr :addEmailAddrs) {
            if (String.isBlank(emailAddr)) {
                badEmailAddrs += ',,' + ',';
            } else {
                if (!Utility.validateEmail(emailAddr)) {
                    badEmailAddrs += emailAddr + ',';
                } else {
                    goodEmailAddrs += emailAddr + ',';
                }
            }
        }
        
        if (String.isNotBlank(badEmailAddrs)) {
            allGood = false;
            additionalEmailAddresses = badEmailAddrs;
        } else {
            allGood = true;
            additionalEmailAddresses = goodEmailAddrs;
        }
        
        if (String.isNotBlank(additionalEmailAddresses)) {
            additionalEmailAddresses = additionalEmailAddresses.removeEnd(',');
        }
        */
        return allGood;
    }
    
    // Determine if we are trying to return a greater quantity than is available for return
    private Map<Id, Boolean> validateReturnQuantity(List<Case_Line_Items__c> cliList) {
        Map<Id, Boolean> cliQtyMap = new Map<Id, Boolean>();
        Map<Id, Decimal> totalReturnMap = new Map<Id, Decimal>();
        Decimal totalReturn;
        Id oliId;
        
        // Add up total quantity indicated for returns and order line exchanges for each order line
        for (Case_Line_Items__c cli :cliList) {
        	totalReturn = 0;
        	oliId = null;
        	if (cli.Line_Number__c != null) {
        		if (cli.Quantity_Returned__c > 0) {
        			totalReturn = cli.Quantity_Returned__c;
        			oliId = cli.Line_Number__c;
        		}
        	} else {
        		if (cli.Exch_Quantity__c > 0) {
        			totalReturn = cli.Exch_Quantity__c;
        			oliId = cli.Exch_Order_Line_Number__c;
        		}
        	}
        	
        	if (oliId != null) {
        		if (!totalReturnMap.containsKey(oliId)) {
        			totalReturnMap.put(oliId, 0);
        		}
        		totalReturnMap.put(oliId, totalReturnMap.get(oliId) + totalReturn);
        	}
        }
        
        // Verify that total quantity on return receipt is not greater than total returnable quantity for each order line
        Id cliKey;
        for (Case_Line_Items__c cli :cliList) {
        	if (cli.Id != null) {
        		cliKey = cli.Id;
        	} else {
        		if (cli.Line_Number__c != null) {
        			cliKey = cli.Line_Number__c;
        		} else {
        			cliKey = cli.Exch_Order_Line_Number__c;
        		}
        	}
        	cliQtyMap.put(cliKey, true);
        	
        	if (cli.Line_Number__c != null) {
        		if (totalReturnMap.containsKey(cli.Line_Number__c)) {
        			if (totalReturnMap.get(cli.Line_Number__c) > returnableQtyMap.get(cli.Line_Number__c)) {
        				cliQtyMap.put(cliKey, false);
        			}
        		}
        	}
        	if (cli.Exch_Order_Line_Number__c != null) {
        		if (totalReturnMap.containsKey(cli.Exch_Order_Line_Number__c)) {
        			if (totalReturnMap.get(cli.Exch_Order_Line_Number__c) > returnableQtyMap.get(cli.Exch_Order_Line_Number__c)) {
        				cliQtyMap.put(cliKey, false);
        			}
        		}
        	}
        }
		
        return cliQtyMap;
    }
    
	public PageReference saveCaseandCaseLine() {
		String errMsg;
		Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case_Line_Items__c.getRecordTypeInfosByName();
		
		// Verify the integrity of the return/exchange data entered by the user
		List<Case_Line_Items__c> cliUpdateList = new List<Case_Line_Items__c>();
		Map<Id, Boolean> cliQtyOkMap = validateReturnQuantity(rhCaseLineList);
		Boolean saveOk = validateExchItems();
		Decimal up;
		for (Case_Line_Items__c cli :rhCaseLineList) {
			
			// Quantity Returned must be greater than zero
			if (cli.Quantity_Returned__c > 0) {
				up = (cli.Unit_Price__c == null) ? 0 : cli.Unit_Price__c;
				cli.Return_Amount__c = cli.Quantity_Returned__c * up;
				if (!cli.Refund_Deposit__c && cli.CW_SKU_ID__r.Dropship__c) {
					cli.Return_Amount__c = cli.Return_Amount__c / 2;
        		}
			} else {
				saveOk = false;
				cli.Quantity_Returned__c.addError('Return quantity must be greater than zero.');
			}
			
			// Quantities cannot be larger than returnable quantity on the order line
			if (cliQtyOkMap.containsKey(cli.Id)) {
				if (!cliQtyOkMap.get(cli.Id)) {
					saveOk = false;
					errMsg = 'Return quantity and/or exchange quantity larger than returnable quantity for the Order Line.';
					if (cli.Line_Number__c != null) {
						cli.Quantity_Returned__c.addError(errMsg);
					} else {
						cli.Exch_Quantity__c.addError(errMsg);
					}
				}
			}
			
			if (saveOk) {
				cliUpdateList.add(cli);
			}
		}
		
		if (saveOk) {
			
			if (rhCase.Status == 'New') {
				rhCase.Status = 'In Progress';
			}
			
			try {
				
				// If the return location has changed, set the gallery email and initialize the case line records with the return DCs
				Case oldCase = [select Id, Return_Location__c from Case where Id = :rhCase.Id];
				if (String.isNotBlank(rhCase.Return_Location__c) && rhCase.Return_Location__c != oldCase.Return_Location__c) {
					initReturnDCs();
					for (Case_Line_Items__c clitem :rhCaseLineList) {
						if (clitem.CW_SKU_ID__r.SKU_Ship_Via__c == '5' || clitem.CW_SKU_ID__r.SKU_Ship_Via__c == '6') {
							clitem.Return_DC__c = 'HDL';
						} else {
							if (clitem.CW_SKU_ID__r.Fulfilling_Warehouse__c == 'F') {
								clitem.Return_DC__c = galleryFurnDC;
							}
							if (clitem.CW_SKU_ID__r.Fulfilling_Warehouse__c == 'S') {
								clitem.Return_DC__c = gallerySSDC;
							}
						}
					}
				}
				
				rhCase.Gallery_Email__c = galleryEmail;
				
				update rhCase;
				isNewReturn = false;
				
				if (!cliUpdateList.isEmpty()) {
					update cliUpdateList;
				}
				
				editMode = false;
				editReturnItemsMode = false;
				
				initCase();
				initCaseLineList();
				initOrderLineList();
				
				// Verify that we have required case data and case line data to generate the return receipt
				validateReturnReceiptData();
				
				// Update the case one more time to set the approval required flag and executive summary
				update rhCase;
				
			} catch(Exception e) {
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Return Receipt - Case update exception: ' + e.getMessage()));
			}
		}
        
        return null;
    }
    
    private Boolean validateExchItems() {
    	List<RtnClass> rtnsList = new List<RtnClass>();
    	
    	for (RtnWrapperClass rw :rwList) {
    		rtnsList.add(rw.rtns[0]);
    	}
    	
    	return validateExchangeItems(rtnsList);
    }
    
    // Determine if the list of exchange items provided is Ok to be saved to the database
    private Boolean validateExchangeItems(List<RtnClass> rtnsList) {
        Boolean listOk = true;
        ExchClass exchangeClass = new ExchClass();
        
        // Make sure each exchange item has minimum valid data 
        for (RtnClass ri :rtnsList) {
			if (ri.rtnItem.Exchange__c) {
        		if (ri.rtnItem.Exch_Product__c == null) {
        			ri.exchList[0].exchItem.Exch_Product__c.addError('Product must have a value.');
                    listOk = false;
				} else {
					if (!(ri.rtnItem.Exch_Quantity__c > 0)) {
						ri.exchList[0].exchItem.Exch_Quantity__c.addError('Quantity must be greater than zero.');
						listOk = false;
					}
					
					if (!exchangeClass.priceExchangeItem(ri.exchList[0])) {
						listOk = false;
						
						if (String.isBlank(ri.exchList[0].exchItem.Price_Override_Type__c) && ri.exchList[0].exchItem.Price_Override_Amount__c != null) {
							ri.exchList[0].exchItem.Price_Override_Type__c.addError('Override Type must have a value if Override amount is not blank.');
						} else {
							ri.exchList[0].exchItem.Price_Override_Amount__c.addError('Override amount must be greater than or equal to zero, must be less than or equal to 100 (if % off), and must be less than or equal to Unit Price (if Amt off or Price).');
						}
					} else {
						
						if (String.isBlank(ri.exchList[0].exchItem.Price_Override_Type__c)) {
							ri.exchList[0].exchItem.Price_Override_Reason__c = '';
						} else {
							if (String.isBlank(ri.exchList[0].exchItem.Price_Override_Reason__c)) {
								ri.exchList[0].exchItem.Price_Override_Reason__c.addError('Override Reason must have a value.');
								listOk = false;
							}
						}
					}
				}
			}
        }
        
        return listOk;
    }
    
    // Create new return items from selected order lines
    public PageReference createCaseLines() {
        PageReference pr = null;
        List<Case_Line_Items__c> newCaseLines = new List<Case_Line_Items__c>();
        List<Case_Line_Items__c> rtnCaseLines = new List<Case_Line_Items__c>();
        List<RtnClass> rtnItemList = new List<RtnClass>();
        Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case_Line_Items__c.getRecordTypeInfosByName();
        Id qtyKey;
        
        if (!selectedOrderLines.isEmpty()) {
        	
        	for (RtnWrapperClass rw :rwList) {
        		rtnCaseLines.add(rw.rtns[0].rtnItem);
        	}
        	
        	for (SelectOrderLineClass solc :selectedOrderLines) {
        		rtnCaseLines.add(solc.returnItem.rtnItem);
        	}
        	
        	Map<Id, Boolean> cliQtyOkMap = validateReturnQuantity(rtnCaseLines);
            
            // Populate case lines from selected order lines, make sure we are not trying to return too many items for a single Order Line
            Boolean rtnOk = true;
            Decimal unitPrice;
            String errMsg;
            for (SelectOrderLineClass solc :selectedOrderLines) {
                
                if (solc.sku.Id == null) {
                	rtnOk = false;
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Each selected item to return must have a SKU.'));
                }
                
                // Validate Return Quantity entered by user
                if (!(solc.returnItem.rtnItem.Quantity_Returned__c > 0)) {
                    rtnOk = false;
                    solc.returnItem.rtnItem.Quantity_Returned__c.addError('Return quantity must be greater than zero.');
                } else {
                    
                    qtyKey = (solc.returnItem.rtnItem.Line_Number__c != null) ? solc.returnItem.rtnItem.Line_Number__c : solc.returnItem.rtnItem.Exch_Order_Line_Number__c;
                    if (cliQtyOkMap.containsKey(qtyKey)) {
						if (!cliQtyOkMap.get(qtyKey)) {
							rtnOk = false;
							errMsg = 'Return quantity and/or exchange quantity larger than returnable quantity for the Order Line.';
							if (solc.returnItem.rtnItem.Line_Number__c != null) {
								solc.returnItem.rtnItem.Quantity_Returned__c.addError(errMsg);
							} else {
								solc.returnItem.rtnItem.Exch_Quantity__c.addError(errMsg);
							}
						}
					}
                }
                
                // Validate that Return Reason is not blank
                if (String.isblank(solc.returnItem.rtnItem.Return_Reason__c)) {
                	solc.returnItem.rtnItem.Return_Reason__c.addError('Return Reason must have a value.');
                	rtnOk = false;
                }
                
                // Determine if return item is within RH policy
                Map<String, Application_Settings__c> appSettings = Application_Settings__c.getAll();
                solc.returnItem.rtnItem.Out_of_Policy_Return__c = false;
                solc.returnItem.rtnItem.Complimentary_Credit__c = false;
                if (solc.returnItem.rtnItem.Line_Number__c != null && solc.orderLine.Ship_Date__c != null && appSettings.containsKey('Return Policy')) {
                	if (solc.orderLine.Ship_Date__c.addDays(Integer.valueOf(appSettings.get('Return Policy').Value_Numeric__c)) < system.today()) {
                		solc.returnItem.rtnItem.Out_of_Policy_Return__c = true;
                		if (!solc.returnItem.rtnItem.Exchange__c) {
                			solc.returnItem.rtnItem.Complimentary_Credit__c = true;
                		}
                	}
                }
				
				solc.returnItem.rtnItem.RecordTypeId = rtMap.get('Returns').getRecordTypeId();
				solc.returnItem.rtnItem.CW_SKU_ID__c = solc.sku.Id;
				
				if (solc.sku.SKU_Ship_Via__c == '5' || solc.sku.SKU_Ship_Via__c == '6') {
                    solc.returnItem.rtnItem.Return_DC__c = 'HDL';
                } else {
                    if (solc.sku.Fulfilling_Warehouse__c == 'F') {
                        solc.returnItem.rtnItem.Return_DC__c = galleryFurnDC;
                    }
                    if (solc.sku.Fulfilling_Warehouse__c == 'S') {
                        solc.returnItem.rtnItem.Return_DC__c = gallerySSDC;
                    }
                }
                
                if (solc.orderLine.Id != null) {
                    solc.returnItem.rtnItem.Line_Number__c = solc.orderLine.Id;
                    unitPrice = solc.orderLine.Unit_Price__c;
                    solc.returnItem.rtnItem.Return_Type__c = 'Order Line';
                } else {
                    unitPrice = 0;
                    solc.returnItem.rtnItem.Return_Type__c = 'MIS-SHIP';
                }
                
                solc.returnItem.rtnItem.Return_Amount__c = 0;
                if (unitPrice != null && solc.returnItem.rtnItem.Quantity_Returned__c != null) {
                	solc.returnItem.rtnItem.Return_Amount__c = unitPrice * solc.returnItem.rtnItem.Quantity_Returned__c;
                }
                
				if (!solc.returnItem.rtnItem.Refund_Deposit__c && solc.sku.Dropship__c) {
					solc.returnItem.rtnItem.Return_Amount__c = solc.returnItem.rtnItem.Return_Amount__c / 2;
				}
                
                rtnItemList.add(solc.returnItem);
                solc.returnItem.rtnItem.Case_Number__c = rhCase.Id;
                newCaseLines.add(solc.returnItem.rtnItem);
            }
            
            Boolean exchOk = validateExchangeItems(rtnItemList);
            if (exchOk && rtnOk) {
                
                try {
                    // create the new case lines
                    insert newCaseLines;
                    
                    // Initialize the current case line list and list of order lines that are available for selection
                    initCaseLineList();
                    initOrderLineList();
                    
                    // Verify that we have required case data and case line data to generate the return receipt
                    validateReturnReceiptData();
                    
                    // Update the case to set the approval required flag and executive summary
                    update rhCase;
                    
                    // Prevent duplicate form submits on page reload after save
                    pr = new PageReference('/apex/Case_ReturnReceipt?caseId=' + rhCase.Id);
        			pr.setRedirect(true);
                    
                } catch(Exception e) {
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Return Receipt - Case Line creation exception: ' + e.getMessage()));
                }
            }
            
        } else {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.WARNING, 'No order lines selected. Please select at least one order line or cancel.'));
        }
        
        return pr;
    }
    
    public PageReference cancelEdit() {
		PageReference pr;
        String retURL = '/';
        
        if (isNewReturn) {
            if (rhCase.Id != null) {
            	delete rhCase;
            }
            if (String.isNotBlank(orderId)) {
            	retURL += orderId;
            }
        } else {
            if (String.isNotBlank(caseId)) {
            	retURL += 'apex/Case_ReturnReceipt?caseId=' + caseId;
            }
            
        }
        
        pr = new PageReference(retURL);
        pr.setRedirect(true);
        return pr;
    }
    
    // Attach Return Receipt PDF to Case record
    public PageReference attachPDF() {
        
        system.debug('*****Case_ReturnReceiptCtlExt attachPDF');
        
        RH_Brand__c rhb = null;
        if (String.isNotBlank(rhCase.Client_Type__c)) {
            rhb = RH_Brand__c.getInstance(rhCase.Client_Type__c);
        }
        if (rhb == null) {
            rhb = RH_Brand__c.getInstance('999');
        }
        
        String subject = rhb.Email_Subject_Brand__c + ' Return Receipt';
        
        Blob pageContent;
        if (!Test.isRunningTest()) {
            pageContent = new PageReference('/apex/ReturnReceiptPDF?caseId=' + caseId).getContent();
        } else {
            pageContent = Blob.valueOf('Test Class');
        }
        
        Attachment att = new Attachment(
            ParentId = caseId,
            Name = subject + '.pdf',
            ContentType = 'application/pdf',
            Body = pageContent,
            Description = 'System Generated Attachment'
                + '\nReturn Receipt' 
        );
        
        // Attach the Return Receipt PDF to the Case
        insert att;
        
        return null;
    }
    
    
    // Send Return Receipt as an email
    public PageReference sendReturnReceipt() {
        PageReference pr = null;
        
        if (!validateAdditionalEmailAddresses()) {
            //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Addtional To Email Addresses must be valid and separated by a single comma. The following email addresses entered are invalid: ' + additionalEmailAddresses));
        
        } else {
            
            // Send the Return Receipt email
            try {
                RH_Brand__c rhb = null;
                if (String.isNotBlank(rhOrder.Division__c)) {
                    rhb = RH_Brand__c.getInstance(rhOrder.Division__c);
                }
                if (rhb == null) {
                    rhb = RH_Brand__c.getInstance('999');
                }
                rhCase.Email_Subject_Brand__c = rhb.Email_Subject_Brand__c;
                //rhCase.Additional_To_Email_Addresses__c = additionalEmailAddresses;
                rhCase.Email_Alert_Trigger__c = true;
                update rhCase;
                //ReturnReceipt.sendEmail(rhCase.Id, rhOrder.Division__c);
                
                // Attach a copy of the email to the case
                Blob pageContent;
                if (!Test.isRunningTest()) {
                    pageContent = new PageReference('/apex/ReturnReceiptHTML?caseId=' + caseId).getContent();
                } else {
                    pageContent = Blob.valueOf('ReturnReceipt Test email content');
                }
                
                Attachment att = new Attachment(
                    ParentId = caseId,
                    Name = rhCase.Email_Subject_Brand__c + ' Return Receipt' + '.html',
                    ContentType = 'html',
                    Body = pageContent, 
                    Description = 'System Generated Attachment'
                        + '\nNotification sent ' + 'on-demand' + ': ' + 'Return Receipt' 
                        + '\nToAddress = ' + rhCase.To_Email_Address__c
                        + '\nSend Date/Time = ' + String.valueOf(system.now())
                );
                insert att;
            
            } catch(Exception e) {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Return Receipt send email exception: ' + e.getMessage()));
            }
        }

        return pr;
    }
}