global class MockORNHttpResponseGenerator implements HttpCalloutMock {

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
        bod += '<RHOMNotes>';
        bod += '	 <RHOMNote>';
        bod += '		<OrderNumber>325307</OrderNumber>';
        bod += '		<ShipmentNumber>1</ShipmentNumber>';
        bod += '		<HDLId>815999</HDLId>';
        bod += '		<ActionUser>abassett2</ActionUser>';
        bod += '		<ActionDateTime>2015-11-30 15:26:44.723</ActionDateTime>';
        bod += ' 		<Note>[abassett2:11/30/15] Testing notes</Note>';
        bod += '	 </RHOMNote>';
        bod += '</RHOMNotes>';

        res.setBody(bod);
        res.setStatusCode(200);
        return res;
    }
    
}