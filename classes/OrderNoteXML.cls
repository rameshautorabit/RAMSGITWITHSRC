public with sharing class OrderNoteXML {
	
	public static String createOrderNoteXML(Map<Id, List<Order_Line_Items__c>> oOLIMap) {
		
		// Create the Order Note XML message.  There will be one Note per order/order line.
		// Each note will include the date a Delay Notification email was sent and the 
		// new available date (miracle date) of the order line communicated in the email.
		String xmlString = null;
		String quotedDate;
		List<String> extList = new List<String>();
		
		if (!oOLIMap.isEmpty()) {
			XmlStreamWriter xml = new XmlStreamWriter();
			
			xml.writeStartElement(null,'BackOrderNotes', null);
			
			for (Id oId : oOLIMap.keySet()) {
				extList = oOLIMap.get(oId)[0].EXT_OrderShipToLine_Number__c.split('-');
				
				//system.debug('*****OrderNoteXML Order extList = ' + extList);
				
				xml.writeStartElement(null,'BackOrderNote', null);
				
				xml.writeStartElement(null,'OrderNumber', null);
				xml.writeCharacters(extList[0]);
				xml.writeEndElement();
				
				for (Order_Line_Items__c oli :oOLIMap.get(oId)) {
					extList = oli.EXT_OrderShipToLine_Number__c.split('-');
					
					//system.debug('*****OrderNoteXML Order Line extList = ' + extList);
					
					quotedDate = Utility.usDate(oli.Current_Delay_Date__c, '/');
					
					xml.writeStartElement(null,'Note', null);
					
					xml.writeStartElement(null,'ShipToNumber', null);
					xml.writeCharacters(extList[1]);
					xml.writeEndElement();
					
					xml.writeStartElement(null,'OrderLineNumber', null);
					xml.writeCharacters(extList[2]);
					xml.writeEndElement();
					
					xml.writeStartElement(null,'EmailDate', null);
					xml.writeCharacters(String.valueOf(Date.Today()));
					xml.writeEndElement();
					
					xml.writeStartElement(null,'Message', null);
					xml.writeCharacters('DELAY NOTICE SENT - NEW QUOTED DATE: ' + quotedDate);
					xml.writeEndElement();
					
					xml.writeEndElement();
				}
				
				xml.writeEndElement();
			}
			
			xml.writeEndElement();
			
			xmlString = xml.getXMLString();
			xml.close();
		}
		
		//system.debug('*****OrderNoteXML xmlString = ' + xmlString);
		
		return xmlString;
	}
}