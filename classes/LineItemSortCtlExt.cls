public class LineItemSortCtlExt {
	
	/*
     *  Line Item Sort controller extension - methods to support sorting OpportunityLineItem and QuoteLineItem records
     *
     */
    
	ApexPages.StandardController stdController;
	
	public Opportunity oppSort {get; set;}
	public Quote quoteSort {get; set;}
	public Boolean fatalError {get; set;}
	
	private Id objId;
	private String retURL;
	private Boolean isOpportunity;
	
	// Constructor
	public LineItemSortCtlExt(ApexPages.StandardController stdController) {
		String objName;
		
		fatalError = false;
		objId = ApexPages.currentPage().getParameters().get('id');
		retURL = ApexPages.currentPage().getParameters().get('retURL');
		
		if (objId != null && String.isNotBlank(retURL)) {
			
	        // Determine if we are working with OpportunityLineItems or QuoteLineItems
	        objName = objId.getSObjectType().getDescribe().getName();
	        if (objName == 'Opportunity' || objName == 'Quote') {
	        	if (objName == 'Opportunity') {
	        		isOpportunity = true;
	        		oppSort = new Opportunity();
					oppSort = [select Id, Name from Opportunity where Id = :objId limit 1];
	        	} else {
	        		isOpportunity = false;
	        		quoteSort = new Quote();
	        		quoteSort = [select Id, Name from Quote where Id = :objId limit 1];
	        	}
				initLineItemList();
	        } else {
	        	fatalError = true;
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Parent record must be either an Opportunity or a Quote'));
	        }
	        
		} else {
			fatalError = true;
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Bad page parameters - missing parent record Id.'));
		}
	}
	
	// Get the list of line items
	private void initLineItemList() {
		
		availableLineItems.clear();
		
		if (isOpportunity) {
			List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
			oliList = [select Id, Name, OpportunityId, Sort_Order__c, Quantity, TotalPrice, UnitPrice, 
					Actual_Product_Name__c, Delivery_Date__c, Fulfillment_Method__c, Notes__c, 
					Product2Id, Product2.Name 
					from OpportunityLineItem where OpportunityId = :objId order by Sort_Order__c asc nulls last];
			for (Integer i=0; i<oliList.size(); i++) {
				oliList[i].Sort_Order__c = i + 1;
				availableLineItems.add(new LineItemWrapper(false, oliList[i], null));
			}
		} else {
			List<QuoteLineItem> qliList = new List<QuoteLineItem>();
			qliList = [select Id, LineNumber, QuoteId, Sort_Order__c, Quantity, TotalPrice, UnitPrice, 
					Product_Name__c, Delivery_Date__c, Fulfillment_Method__c, Notes__c, 
					Product2Id, Product2.Name 
					from QuoteLineItem where QuoteId = :objId order by Sort_Order__c asc nulls last];
			
			for (Integer i=0; i<qliList.size(); i++) {
				qliList[i].Sort_Order__c = i + 1;
				availableLineItems.add(new LineItemWrapper(false, null, qliList[i]));
			}
		}
	}
	
	public class LineItemWrapper {
		public Boolean selected {get; set;}
		public OpportunityLineItem oli {get; set;}
		public QuoteLineItem qli {get; set;}
		
		public LineItemWrapper(Boolean selected, OpportunityLineItem oli, QuoteLineItem qli) {
			this.selected = selected;
			this.oli = oli;
			this.qli = qli;
		}
	}
	
	List<LineItemWrapper> availableLineItems = new List<LineItemWrapper>();
	List<LineItemWrapper> selectedLineItems = new List<LineItemWrapper>();
	
	// Return the list of selected and unselected order lines
	public List<LineItemWrapper> getLineItems() {
		
		return availableLineItems;
	}
	
	public PageReference getSelected() {
		
		selectedLineItems.clear();
		for (LineItemWrapper li :availableLineItems) {
			if (li.selected) {
				selectedLineItems.add(li);
			}
		}
		
		return null;
	}
	
	public List<LineItemWrapper> getselectedLineItems() {
        if(selectedLineItems.size() > 0) {
            return selectedLineItems;
        } else {
            return null;
        }
    }
    
    private Map<Id, LineItemWrapper> getmoveMap(String op) {
    	Map<Id, LineItemWrapper> moves = new Map<Id, LineItemWrapper>();
    	
    	for (LineItemWrapper li :availableLineItems) {
    		if (li.selected) {
    			if (isOpportunity) {
    				moves.put(li.oli.Id, li);
    			} else {
    				moves.put(li.qli.Id, li);
    			}
    		}
    	}
    	
    	if (!moves.isEmpty()) {
    		Decimal sortOrderLine;
    		Decimal sortOrder = 1;
    		if (op == 'Bottom') {
    			sortOrder = availableLineItems.size() - (moves.size() - 1);
    		}
    		
    		for (LineItemWrapper li :moves.values()) {
    			
    			if (op == 'Top' || op == 'Bottom') {
    				sortOrderLine = sortOrder;
    			} else {
    				if (isOpportunity) {
    					sortOrderLine = li.oli.Sort_Order__c;
    				} else {
    					sortOrderLine = li.qli.Sort_Order__c;
    				}
    				
    				if (op == 'Up') {
    					sortOrderLine--;
    					if (sortOrderLine < sortOrder) {
    						sortOrderLine = sortOrder;
    					}
    				}
    				
    				if (op == 'Down') {
    					sortOrderLine++;
    					if (sortOrderLine > (availableLineItems.size() - moves.size()) + sortOrder) {
    						sortOrderLine = (availableLineItems.size() - moves.size()) + sortOrder;
    					}
    				}
    			}
    			
    			if (isOpportunity) {
    				li.oli.Sort_Order__c = sortOrderLine;
    			} else {
    				li.qli.Sort_Order__c = sortOrderLine;
    			}
    			
    			sortOrder++;
    		}
    	}
    	
    	return moves;
    }
    
    private void reOrderAvailableList(String op) {
    	Map<Id, LineItemWrapper> mvMap = new Map<Id, LineItemWrapper>();
    	Map<Id, LineItemWrapper> lineMap = new Map<Id, LineItemWrapper>();
    	
    	mvMap = getmoveMap(op);
    	
    	system.debug('*****moveMap = ' + mvMap);
    	
    	if (!mvMap.isEmpty()) {
    		for (LineItemWrapper li :availableLineItems) {
    			if (!li.selected) {
    				if (isOpportunity) {
    					lineMap.put(li.oli.Id, li);
    				} else {
    					lineMap.put(li.qli.Id, li);
    				}
    			}
    		}
    		
    		List<LineItemWrapper> tmpList = new List<LineItemWrapper>();
    		tmpList.addAll(availableLineItems);
    		availableLineItems.clear();
    		
    		Id lineId;
    		OpportunityLineItem lineOLI;
    		QuoteLineItem lineQLI;
    		Decimal lineSortOrder;
    		Decimal sortOrder = 1;
    		for (LineItemWrapper li :tmpList) {
    			for (LineItemWrapper lim :mvMap.values()) {
    				if (isOpportunity) {
    					lineId = lim.oli.Id;
    					lineSortOrder = lim.oli.Sort_Order__c;
    					lineOLI = lim.oli;
    					lineQLI = null;
    				} else {
    					lineId = lim.qli.Id;
    					lineSortOrder = lim.qli.Sort_Order__c;
    					lineOLI = null;
    					lineQLI = lim.qli;
    				}
    				
    				if (lineSortOrder == sortOrder) {
    					availableLineItems.add(new LineItemWrapper(lim.selected, lineOLI, lineQLI));
    					mvMap.remove(lineId);
    					sortOrder++;
    				}
    			}
    			
    			if (isOpportunity) {
    				lineId = li.oli.Id;
    			} else {
    				lineId = li.qli.Id;
    			}
    			
    			if (lineMap.containsKey(lineId)) {
    				if (isOpportunity) {
    					li.oli.Sort_Order__c = sortOrder;
    					lineOLI = li.oli;
    					lineQLI = null;
    				} else {
    					li.qli.Sort_Order__c = sortOrder;
    					lineOLI = null;
    					lineQLI = li.qli;
    				}
    				availableLineItems.add(new LineItemWrapper(li.selected, lineOLI, lineQLI));
    				sortOrder++;
    			}
    		}
    		
    		for (LineItemWrapper li :mvMap.values()) {
    			if (isOpportunity) {
    				availableLineItems.add(new LineItemWrapper(li.selected, li.oli, null));
    			} else {
    				availableLineItems.add(new LineItemWrapper(li.selected, null, li.qli));
    			}
    		}
    	}
    }
    
    public PageReference top() {
    	
    	reOrderAvailableList('Top');
    	return null;
    }
    
    public PageReference up() {
    	
    	reOrderAvailableList('Up');
    	return null;
    }
    
    public PageReference down() {
    	
    	reOrderAvailableList('Down');
    	return null;
    }
    
    public PageReference bottom() {
    	
    	reOrderAvailableList('Bottom');
    	return null;
    }
    
    public PageReference saveSortedLines() {
    	PageReference pr = null;
    	
    	try {
    		if (isOpportunity) {
    			List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
    			for (LineItemWrapper li :availableLineItems) {
    				oliList.add(li.oli);
    			}
    			
    			if (!oliList.isEmpty()) {
    				update oliList;
    			}
    		} else {
    			List<QuoteLineItem> qliList = new List<QuoteLineItem>();
    			for (LineItemWrapper li :availableLineItems) {
    				qliList.add(li.qli);
    			}
    			
    			if (!qliList.isEmpty()) {
    				update qliList;
    			}
    		}
    		pr = new PageReference(retURL);
    	} catch(Exception e) {
    		ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Save exception: ' + e.getMessage()));
    	}
    	return pr;
    }
}