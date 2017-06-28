@RestResource(urlMapping='/AutoMIRV/*')
global with sharing class AutoMIRV {
	
	/*
	 *	Methods for receiving, parsing, and storing the AutoMIRV message from CW. The AutoMIRV
	 *	message is an indication that certain Order Line Items that have been on backorder
	 *	have been located at another warehouse and they are available earlier than what the
	 *	customer was quoted.
	 *
	 */
	
	private static String getNodeText(Dom.XmlNode rootNode, String elementName) {
		Dom.XmlNode childElement = rootNode.getChildElement(elementName, null);
		return childElement == null ? null : childElement.getText();
	}
	
	// Method called by MULE to provide Salesforce with the AutoMIRV message
	@HttpPost
    global static String autoMIRVMessage(String amMessage) {
    	String response;
    	String company;
    	String orderNumber;
    	String shipToNumber;
    	String earlyDelivery;
    	String lateDelivery;
    	Set<String> lineExtIds = new Set<String>();
    	
    	system.debug('*****autoMIRVMessage XML = ' + amMessage);
    	
    	try {
    		// Parse the AutoMIRV XML message
    		Dom.Document doc = new Dom.Document();
			doc.load(amMessage);
			
			Dom.XMLNode rootNode = doc.getRootElement();
			company = getNodeText(rootNode, 'Company');
			orderNumber = getNodeText(rootNode, 'Order_Number');
			shipToNumber = getNodeText(rootNode, 'ShipTo_Number');
			earlyDelivery = getNodeText(rootNode, 'Early_Delivery_Date');
			lateDelivery = getNodeText(rootNode, 'Late_Delivery_Date');
			
			Dom.XMLNode orderDetails = rootNode.getChildElement('Order_Details', null);
			for (Dom.XMLNode child :orderDetails.getChildElements()) {
				if (child != null) {
					lineExtIds.add(orderNumber + '-' + shipToNumber + '-' + child.getText());
				}
			}
    		
    		// Validate the AutoMIRV message
    		String responseDescription;
    		List<RH_Order__c> orderList = new List<RH_Order__c>();
    		orderList = [select Id, Name, Division__c, Order_Type_Code__c, Sold_to_Email__c from RH_Order__c where Name = :orderNumber limit 1];
    		if (orderList.isEmpty()) {
    			responseDescription = 'FAILURE - order number not found, order number = ' + orderNumber;
    		}
    		
    		List<Ship_To__c> shipToList  = new List<Ship_To__c>();
    		if (String.isBlank(responseDescription)) {
    			shipToList = [select Id, Name from Ship_To__c where Name = :shipToNumber and Order__c = :orderList[0].Id limit 1];
    			if (shipToList.isEmpty()) {
    				responseDescription = 'FAILURE - order/ship to number not found, order/ship to number = ' + orderNumber + '/' + shipToNumber;
    			}
    		}
    		
    		List<Order_Line_Items__c> oliList = new List<Order_Line_Items__c>();
    		List<String> oliExtIds = new List<String>();
    		if (String.isBlank(responseDescription)) {
    			oliList = [select Id, Name, EXT_OrderShipToLine_Number__c from Order_Line_Items__c where EXT_OrderShipToLine_Number__c in :lineExtIds and RH_Order_Number__c = :orderList[0].Id and Ship_To__c = :shipToList[0].Id];
    			for (Order_Line_Items__c oli :oliList) {
    				oliExtIds.add(oli.EXT_OrderShipToLine_Number__c);
    			}
    			
    			if (oliList.isEmpty() || oliList.size() != lineExtIds.size()) {
    				responseDescription = 'FAILURE - line sequence numbers provided do not match order lines found in salesforce. Provided = ' + lineExtIds + ' - Found = ' + oliExtIds;
    			}
    		}
    		
    		if (String.isNotBlank(responseDescription)) {
    			
    			// There was a problem with some of the data in the message.
    			response = responseMessage(orderNumber, 'ERRDATA', responseDescription);
    		
    		} else {
    			
    			// Message looks good, create a new Manual Reservation record to persist the data and trigger the email send
    			RH_Brand__c rhb = null;
				if (orderList[0].Order_Type_Code__c == 'Z') {
					rhb = RH_Brand__c.getInstance('RH Contract');
				} else {
					if (String.isNotBlank(orderList[0].Division__c)) {
						rhb = RH_Brand__c.getInstance(orderList[0].Division__c);
					}
				}
				if (rhb == null) {
					rhb = RH_Brand__c.getInstance('999');
				}
				
				Boolean sendEmail = Utility.isValidDomain(orderList[0].Sold_to_Email__c);
				
    			Manual_Reservation__c rhMR = new Manual_Reservation__c(
    				Company__c = company,
    				Order_Number__c = orderList[0].Id,
    				Ship_To__c = shipToList[0].Id,
    				Early_Delivery_Date__c = date.valueOf(earlyDelivery + ' 00:00:00'),
    				Late_Delivery_Date__c = date.valueOf(lateDelivery + ' 00:00:00'),
    				Order_Lines__c = JSON.serialize(oliExtIds),
    				Email_Subject_Brand__c = rhb.Email_Subject_Brand__c,
    				Email_To_Address__c = orderList[0].Sold_to_Email__c,
    				Send_Email__c = sendEmail
    			);
    			insert rhMR;
    			
    			// Record the success/failure of sending the email and make an attachment of the email if sent
    			rhMR = [select Id, Name, Email_To_Address__c, Auto_MIRV_Response__c, Send_Email__c from Manual_Reservation__c where Id = :rhMR.Id];
    			String emailSentMsg;
    			if (sendEmail) {
    				if (rhMR.Send_Email__c) {
    					emailSentMsg = 'attempted send failed';
    				} else {
    					emailSentMsg = 'attempted send success';
    					emailAttachment(rhMR.Id);
    				}
    			} else {
    				emailSentMsg = 'invalid/missing email address';
    			}
    			
    			response = responseMessage(orderNumber, 'SUCCESS', 'SUCCESS - autoMIRV message received - email recipient = ' + rhMR.Email_To_Address__c + ' - ' + emailSentMsg);
    			rhMR.Auto_MIRV_Response__c = response;
    			update rhMR;
    		}
    	} catch(Exception e) {
    		response = responseMessage(orderNumber, 'ERRPROCESS', 'FAILURE - exception = ' + e.getMessage());
    	}
    	
    	return response;
    }
    
    // Create an attachment of the sent email - @future so that by the time this executes, the Manual Reservation record is available for use
    @future (callout=true)
    public static void emailAttachment(Id mrId) {
    	Manual_Reservation__c rhMR = new Manual_Reservation__c();
    	Blob pageContent;
    	
    	rhMR = [select Id, Name, Email_To_Address__c, Auto_MIRV_Response__c from Manual_Reservation__c where Id = :mrId];
		if (!Test.isRunningTest()) {
			pageContent = new PageReference('/apex/ManualReservationHTML?mrId=' + rhMR.Id).getContent();
		} else {
			pageContent = Blob.valueOf('Test Class');
		}
		
		Attachment mrAttachment = new Attachment(
			ParentId = rhMR.Id,
			Name = 'Manual Reservation ' + rhMR.Name + ': automatic.html',
			ContentType = 'html',
			Body = pageContent,
			Description = 'System Generated Attachment'
				+ '\nManual Reservation Notification sent automatically: ' + rhMR.Name 
				+ '\nToAddress = ' + rhMR.Email_To_Address__c
				+ '\nSend Date/Time = ' + String.valueOf(system.now())
		);
		insert mrAttachment;
    }
    
	public static String responseMessage(String orderNumber, String responseCode, String responseDescription) {
		String responseXML;
		
		XmlStreamWriter xml = new XmlStreamWriter();
		xml.writeStartElement(null,'MirvEmailResponse', null);
		
		xml.writeStartElement(null,'Order_Number', null);
		xml.writeCharacters(orderNumber);
		xml.writeEndElement();
		
		xml.writeStartElement(null,'ResponseCode', null);
		xml.writeCharacters(responseCode);
		xml.writeEndElement();
		
		xml.writeStartElement(null,'ResponseDescription', null);
		xml.writeCharacters(responseDescription);
		xml.writeEndElement();
		
		xml.writeEndElement();
		
		responseXML = xml.getXMLString();
		xml.close();
		
		return responseXML;
	}
}