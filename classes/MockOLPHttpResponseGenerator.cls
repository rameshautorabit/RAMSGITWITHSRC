global class MockOLPHttpResponseGenerator implements HttpCalloutMock {

	// Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('https://servicesuat.restorationhardware.com:10000/lightning/billing', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        String bod = '';
        bod += '<?xml version="1.0" encoding="iso-8859-1"?>';
        bod += '<PersonalizationDetail>';
        bod += '	<Order_Number>353868</Order_Number>';
        bod += '	<ShipToNumber>1</ShipToNumber>';
        bod += '	<SequenceNumber>1</SequenceNumber>';
        bod += '	<Personalizations>';
        bod += '		<Personalization>';
        bod += '			<SequenceNumber>1</SequenceNumber>';
        bod += '			<StandardText>LOCAL</StandardText>';
        bod += '			<PersonalizationType>DD</PersonalizationType>';
        bod += '			<PersonalizationText>Y</PersonalizationText>';
        bod += '		</Personalization>';
        bod += ' 	</Personalizations>';
        bod += '</PersonalizationDetail>';

        res.setBody(bod);
        res.setStatusCode(200);
        return res;
    }
    
}