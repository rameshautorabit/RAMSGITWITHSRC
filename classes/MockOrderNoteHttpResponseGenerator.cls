global class MockOrderNoteHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('https://servicesuat.restorationhardware.com:10000/lightning/billing', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        // Make body Static Resource
        res.setBody('{ "viewNotesResponse" : { "transactionId" : "32565311", "order_nbr" : "424021", "sold_to_customer_info" : { "sold_to_nbr" : "2598320", "sold_to_company" : null, "sold_to_fname" : "T.", "sold_to_initial" : null, "sold_to_lname" : "TEST" }, "ship_to_customer_info" : { "ship_to_nbr" : "1", "ship_to_company" : null, "ship_to_fname" : "T.", "ship_to_initial" : null, "ship_to_lname" : "TEST", "ship_to_addr1" : "15 KOCH RD", "ship_to_addr2" : "K", "ship_to_city" : "CORTE MADERA", "ship_to_state" : "CA", "ship_to_state_name" : null, "ship_to_postal" : null, "ship_to_country" : "USA", "ship_to_country_name" : "UNITED STATES", "ship_to_day_phone_number" : null, "ship_to_eve_phone_number" : null, "ship_to_apartment_number" : null }, "Notes_list" : { "total_notes" : "1", "note" : { "SequenceNbr" : "1", "detail" : { "Message" : "Ord Conf to tlu@rh.com.", "MsgType" : "H", "User" : "COMMWARE", "Date" : "09/01/2016" } } }, "response" : { "responseType" : "SUCCESS", "errorCode" : null, "errorDetail" : null } } }');
        res.setStatusCode(200);
        return res;
    }
}