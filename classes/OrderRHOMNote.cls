global class OrderRHOMNote{

	public String OrderNumber {get;set;}
	public String ShipmentNumber {get;set;}
	public String HDLId {get;set;}
	public String ActionUser {get; set;}
	public String ActionDateTime {get;set;}
	public String NoteBody {get;set;}
	
	public List<OrderRHOMNote> OrderRHOMNote(Dom.XMLNode OrderRHOMNote){
   		
   		List<OrderRHOMNote> orderRHOMNotes = new List<OrderRHOMNote>();
   		
   			/*
	   		Dom.XMLNode OrderRHOMNoteItem = OrderRHOMNote.getChildElements();
	   		System.debug('RHOM Items: '+ OrderRHOMNoteItem);
	   		*/
	   		
	   		System.debug('RHOM Items: '+ OrderRHOMNote);
	   		System.debug('RHOM Items Element: '+ OrderRHOMNote.getChildElements());
	   		
	   		for(Dom.XMLNode OrderNoteElement : OrderRHOMNote.getChildElements()){
	   			if(OrderNoteElement.getName() =='RHOMNote'){
	   				OrderRHOMNote orn = new OrderRHOMNote();
				
					orn.OrderNumber = OrderNoteElement.getChildElement('OrderNumber',null).getText();
					System.debug('Order Number: ' + orn.OrderNumber);
					orn.ShipmentNumber = OrderNoteElement.getChildElement('ShipmentNumber', null).getText();
					System.debug('Shipment Number: ' + orn.ShipmentNumber);
					orn.HDLId = OrderNoteElement.getChildElement('HDLId', null).getText();
					System.debug('HDL Id: ' + orn.HDLId);
					orn.ActionDateTime = OrderNoteElement.getChildElement('ActionDateTime', null).getText();
					System.debug('Action Date Time: ' + orn.ActionDateTime);
					orn.ActionUser = OrderNoteElement.getChildElement('ActionUser', null).getText();
					System.debug('Action User: ' + orn.ActionUser);
					orn.NoteBody = OrderNoteElement.getChildElement('Note', null).getText();
					System.debug('Note Body: ' + orn.NoteBody);
					orderRHOMNotes.add(orn);
	   			}
			}
	return orderRHOMNotes;
	}
}