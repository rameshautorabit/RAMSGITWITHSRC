@isTest
global class Quote_CW_Test_Hard_Coded_Response implements HTTPCalloutMock{
	
	private HTTPResponse resp;
	
	
	
	public Quote_CW_Test_Hard_Coded_Response(String testBody){
		
		resp = new HttpResponse();
        resp.setBody(testBody);
        resp.setStatusCode(200);
				
	}
	
	public HTTPResponse respond(HTTPRequest req) {
        return resp;
    }
	/*global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('http://api.salesforce.com/foo/bar', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"foo":"bar"}');
        res.setStatusCode(200);
        return res;
    } */
	
	public testmethod static void testWS() {
        
        String testBody='This is a test';
        
        HTTPCalloutMock mock=new Quote_CW_Test_Hard_Coded_Response(testBody);
        
        Test.setMock(HttpCalloutMock.class, mock);
        
        Quote_CW_Test_WS_Call_Outs q=new Quote_CW_Test_WS_Call_Outs();
        
        HTTPResponse resp=q.invokeWS();
        
        System.assertEquals(200,resp.getStatusCode());
        
        System.assertEquals(resp.getBody(),testBody);
       
    }
    
}