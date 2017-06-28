global class MockROHCResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        // Make body Static Resource
        res.setBody('');
        res.setStatusCode(200);
        return res;
    }
}