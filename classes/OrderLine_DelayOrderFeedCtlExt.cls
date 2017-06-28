public with sharing class OrderLine_DelayOrderFeedCtlExt {
	
	/*
	 * Order Line controller extension methods for display and editing of delayed order data.
	 *
	 */
	
	ApexPages.StandardController stdController;
	private final Order_Line_Items__c orderLineItem;
	Order_Line_Items__c orderLine;
	List<Case_Line_Items__c> cliList;
	Map<String, Case_Line_Items__c> nnToCaseLineMap;
	
    // Constructor - read in the delayed order JSON data
    public OrderLine_DelayOrderFeedCtlExt(ApexPages.StandardController stdController) {
		
		this.orderLineItem = (Order_Line_Items__c)stdController.getRecord();
		
		orderLine = new Order_Line_Items__c();
		orderLine = [select Id, Delay_Feed_History__c, Current_Available_Date__c, Original_Available_Date__c from Order_Line_Items__c where Id = :this.orderLineItem.Id];
		
		cliList = new List<Case_Line_Items__c>();
		cliList = [select Id, Delay_Notice_Number__c, Case_Number__c, Case_Number__r.CaseNumber, Case_Number__r.Request_Category__c, Line_Number__c 
					from Case_Line_Items__c where Line_Number__c = :orderLine.Id];
		nnToCaseLineMap = new Map<String, Case_Line_Items__c>();
		for (Case_Line_Items__c cli :cliList) {
			if (cli.Delay_Notice_Number__c != null) {
				nnToCaseLineMap.put(String.valueOf(cli.Delay_Notice_Number__c), cli);
			}
		}
    }
	
	// Get the current delay order feed history data
    public List<DelayedOrderDataWrapper> getDelayOrderFeedData() {
		
		List<DelayedOrderFeed.DelayedOrderFeedHistory> dofhList = new List<DelayedOrderFeed.DelayedOrderFeedHistory>();
		if (String.isNotBlank(orderLine.Delay_Feed_History__c)) {
			dofhList = (List<DelayedOrderFeed.DelayedOrderFeedHistory>)JSON.deserialize(orderLine.Delay_Feed_History__c, List<DelayedOrderFeed.DelayedOrderFeedHistory>.class);
		}
		
		List<DelayedOrderDataWrapper> dodwList = new List<DelayedOrderDataWrapper>();
		String daysMoved = '-';
		for (Integer i=0; i<dofhList.size(); i++) {
			if (dofhList[i].NN == '1') {
				if (orderLine.Original_Available_Date__c == null) {
					daysMoved = '0';
				} else {
					daysMoved = String.valueOf(orderLine.Original_Available_Date__c.daysBetween(date.valueOf(dofhList[i].CD + ' 00:00:00')));
				}
			} else {
				if (i+1 < dofhList.size()) {
					daysMoved = String.valueOf(date.valueOf(dofhList[i+1].CD + ' 00:00:00').daysBetween(date.valueOf(dofhList[i].CD + ' 00:00:00')));
				}
			}
			
			if (nnToCaseLineMap.containsKey(dofhList[i].NN)) {
				dodwList.add(new DelayedOrderDataWrapper(dofhList[i], daysMoved, nnToCaseLineMap.get(dofhList[i].NN).Case_Number__r.Request_Category__c, nnToCaseLineMap.get(dofhList[i].NN).Case_Number__c, nnToCaseLineMap.get(dofhList[i].NN).Case_Number__r.CaseNumber));
			} else {
				dodwList.add(new DelayedOrderDataWrapper(dofhList[i], daysMoved, null, null, null));
			}
		}
		
		return dodwList;
	}
	
	public class DelayedOrderDataWrapper {
		public DelayedOrderFeed.DelayedOrderFeedHistory dofhData {get; set;}
		public String daysMoved {get; set;}
		public String actionType {get; set;}
		public Id caseId {get; set;}
		public String caseNumber {get; set;}
		
		public DelayedOrderDataWrapper() {
			dofhData = new DelayedOrderFeed.DelayedOrderFeedHistory();
			daysMoved = '0';
			actionType = null;
			caseId = null;
			caseNumber = null;
		}
		
		public DelayedOrderDataWrapper(DelayedOrderFeed.DelayedOrderFeedHistory dofh, String dm, String at, Id cId, String cn) {
			dofhData = dofh;
			daysMoved = dm;
			actionType = at;
			caseId = cId;
			caseNumber = cn;
		}
	}
}