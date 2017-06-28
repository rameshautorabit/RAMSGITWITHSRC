global class MockOLHHttpResponseGenerator implements HttpCalloutMock {

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
        bod += '<Order_Line_Activities>';
        bod += '	<Order_Number>353868</Order_Number>';
        bod += '	<Ship_Tos>';
        bod += '		<Ship_To>';
        bod += '			<Ship_To_Number>1</Ship_To_Number>';
        bod += '			<Order_Lines>';
        bod += '				<Order_Line>';
        bod += '					<Order_Line_Number>1</Order_Line_Number>';
        bod += ' 					<Order_Line_Activity>';
        bod += ' 						<Transaction_TimeStamp>2016-03-03 23.59.59</Transaction_TimeStamp>';
        bod += '						<Activity_Description>Change</Activity_Description>';
        bod += '						<Activity_Detail></Activity_Detail>';
        bod += '						<Activity_Quantity>0</Activity_Quantity>';
        bod += ' 					</Order_Line_Activity>';
        bod += ' 				</Order_Line>';
        bod += ' 			</Order_Lines>';
        bod += '		</Ship_To>';			
        bod += '	</Ship_Tos>';
        bod += '</Order_Line_Activities>';

        res.setBody(bod);
        res.setStatusCode(200);
        return res;
    }
    
}