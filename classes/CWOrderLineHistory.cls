global class CWOrderLineHistory {
	
	public Integer OrderNumber {get;set;}
	public Integer ShipToNumber {get;set;}
	public Integer OrderLineNumber {get;set;}
	public String PONumber {get; set;}
	public String TransactionTimeStamp {get;set;}
	public String ActivityDescription {get;set;}
	public String ActivityDetail {get;set;}
	public Integer ActivityQuantity {get;set;}

	public List<CWOrderLineHistory> CWOrderLineHistory(Dom.XMLNode OrderLineActivities){
   		
   		List<CWOrderLineHistory> orderLineHistories = new List<CWOrderLineHistory>();
   		
   		if(OrderLineActivities.getChildElement('Message', null) == null){

	   		Dom.XMLNode OrderLineElements = OrderLineActivities.getChildElement('Ship_Tos', null).getChildElement('Ship_To', null).getChildElement('Order_Lines', null).getChildElement('Order_Line', null);
	   		
	   		for(Dom.XMLNode OrderLineElement : OrderLineElements.getChildElements()){
	   			if(OrderLineElement.getName() =='Order_Line_Activity'){
	   				CWOrderLineHistory olh = new CWOrderLineHistory();
				
					olh.OrderNumber = Integer.valueOf(OrderLineActivities.getChildElement('Order_Number',null).getText());
					System.debug('Order Number: ' + olh.OrderNumber);
					olh.ShipToNumber = Integer.valueOf(OrderLineActivities.getChildElement('Ship_Tos', null).getChildElement('Ship_To', null).getChildElement('Ship_To_Number', null).getText());
					System.debug('Ship To Number: ' + olh.ShipToNumber);
					olh.OrderLineNumber = Integer.valueOf(OrderLineActivities.getChildElement('Ship_Tos', null).getChildElement('Ship_To', null).getChildElement('Order_Lines', null).getChildElement('Order_Line', null).getChildElement('Order_Line_Number',null).getText());
					System.debug('Order Line Number: ' + olh.OrderLineNumber);
					if(OrderLineActivities.getChildElement('Ship_Tos', null).getChildElement('Ship_To', null).getChildElement('Order_Lines', null).getChildElement('Order_Line', null).getChildElement('Order_Line_PO_Information', null)!= null){
						olh.PONumber = OrderLineActivities.getChildElement('Ship_Tos', null).getChildElement('Ship_To', null).getChildElement('Order_Lines', null).getChildElement('Order_Line', null).getChildElement('Order_Line_PO_Information',null).getChildElement('Order_Line_PO_Number',null).getText();
					}else{
						olh.PONumber = 'N/A';
						
					}
					System.debug('PO Number: ' + olh.PONumber);
					olh.TransactionTimeStamp = OrderLineElement.getChildElement('Transaction_TimeStamp', null).getText();
					System.debug('Transaction TimeStamp: ' + olh.TransactionTimeStamp);
					olh.ActivityDescription = OrderLineElement.getChildElement('Activity_Description', null).getText();
					System.debug('Activity Description: ' + olh.ActivityDescription);
					olh.ActivityDetail = OrderLineElement.getChildElement('Activity_Detail', null).getText();
					System.debug('Activity Detail: ' + olh.ActivityDetail);
					olh.ActivityQuantity = Integer.valueOf(OrderLineElement.getChildElement('Activity_Quantity', null).getText());
					System.debug('Activity Quantity: ' + olh.ActivityQuantity);
					orderLineHistories.add(olh);
	   			}
			}
   		}
	return orderLineHistories;
	}
}