public class TestApexClass {
	
    static String completeURL = '';
    
    @AuraEnabled
    public static Object sampleTestCallout(){
        
        TestApexClass testApexClass = new TestApexClass();
	    completeURL = 'http://183.82.4.69:8954/rabit/rabitservices?wsdl';
	    HttpRequest req = testApexClass.buildWebServiceRequest();
	    
	    String getAgentsReq = '<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ws=\"http://ws.service.rabit.com/\"><soapenv:Header/><soapenv:Body><ws:getAgents><orgname>autorabit.com</orgname></ws:getAgents></soapenv:Body></soapenv:Envelope>';
	    req.setBody(getAgentsReq);
		Http http = new Http();
		HttpResponse res = testApexClass.invokeWebService(http, req);
        System.debug('GetAgents String: ' + res.toString());
        System.debug('GetAgents StatusCode: ' + res.getStatusCode());
        System.debug('GetAgents Status: ' + res.getStatus());
        System.debug('GetAgents Body: ' + res.getBody());
        System.debug('GetAgents Soap Body -?  ' + getAgentsReq);
        return res.getBody();
        
    }
    
    public HttpRequest buildWebServiceRequest(){
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
	    req.setHeader('Content-Type', 'text/xml; charset=utf-8');   
        req.setEndpoint(completeURL); 
        return req;
    }

    public HttpResponse invokeWebService(Http h, HttpRequest req){
         HttpResponse res = h.send(req);
         return res;
    }
    
}