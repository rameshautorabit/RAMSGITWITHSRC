public class LineItemRelatedListCtlExt {
	
	/*
     *  Line Item Related List controller extension - methods for displaying a custom OpportunityLineItem and
     *	QuoteLineItem related list on the parent Opportunity and Quote detail page.
     *
     */
    
	ApexPages.StandardController stdController;
	
	public Boolean fatalError {get; set;}
	public Id objId {get; set;}
	public Id deleteId {get; set;}
	
	private Boolean isOpportunity;
	private List<LineItemWrapper> lineItemList;
	
	// Constructor
	public LineItemRelatedListCtlExt(ApexPages.StandardController stdController) {
		String objName;
		
		fatalError = false;
		lineItemList = new List<LineItemWrapper>();
		objId = stdController.getRecord().Id;
		
		if (objId != null) {
			
	        // Determine if we are working with OpportunityLineItems or QuoteLineItems
	        objName = objId.getSObjectType().getDescribe().getName();
	        if (objName == 'Opportunity' || objName == 'Quote') {
	        	isOpportunity = (objName == 'Opportunity') ? true : false;
	        	
	        } else {
	        	fatalError = true;
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Parent record must be either an Opportunity or a Quote'));
	        }
	        
		} else {
			fatalError = true;
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Bad page parameters - missing parent record Id.'));
		}
	}
	
	public class LineItemWrapper {
		public OpportunityLineItem oli {get; set;}
		public QuoteLineItem qli {get; set;}
		
		public LineItemWrapper(OpportunityLineItem oli, QuoteLineItem qli) {
			this.oli = oli;
			this.qli = qli;
		}
	}
	
	// Return the list of line items
	public List<LineItemWrapper> getLineItems() {
		List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
		List<QuoteLineItem> qliList = new List<QuoteLineItem>();
		
		lineItemList.clear();
		
		if (isOpportunity) {
			
			oliList = [select Id, Name, OpportunityId, Sort_Order__c, Quantity, UnitPrice, 
					Actual_Product_Name__c, Delivery_Date__c, Fulfillment_Method__c, Notes__c, 
					Direct_Current_Price__c, Percent_Discounted__c, Product_Margin__c, Product2Id, Product2.Name 
					from OpportunityLineItem where OpportunityId = :objId order by Sort_Order__c asc nulls last];
			
			for (OpportunityLineItem oli :oliList) {
				lineItemList.add(new LineItemWrapper(oli, null));
			}
			
		} else {
			
			qliList = [select Id, LineNumber, QuoteId, Sort_Order__c, Quantity, UnitPrice, TotalPrice, 
					Discount_Percent__c, MMU__c, Product_Name__c, Delivery_Date__c, Fulfillment_Method__c, Notes__c, 
					Product2Id, Product2.Name,Customer_Location__c,Customer_Spec__c  
					from QuoteLineItem where QuoteId = :objId order by Sort_Order__c asc nulls last];
			
			for (QuoteLineItem qli :qliList) {
				lineItemList.add(new LineItemWrapper(null, qli));
			}
		}
		
		//system.debug('*****LineItemRelatedListCtlExt getLineItems lineItemList.size = ' + lineItemList.size());
		return lineItemList;
	}
	
	// Delete the line item indicated in deleteId
	public PageReference deleteLine() {
		
		//system.debug('*****LineItemRelatedListCtlExt deleteLine deleteId = ' + deleteId);
		
		try {
			for (LineItemWrapper li :lineItemList) {
				if (isOpportunity) {
					if (li.oli.Id == deleteId) {
						//system.debug('*****LineItemRelatedListCtlExt deleteLine delete oli = ' + li.oli);
						delete li.oli;
						break;
					}
				} else {
					if (li.qli.Id == deleteId) {
						//system.debug('*****LineItemRelatedListCtlExt deleteLine delete qli = ' + li.qli);
						delete li.qli;
						break;
					}
				}
			}
		} catch(Exception e) {
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Delete exception: ' + e.getMessage()));
		}
		
		return null;
	}
}