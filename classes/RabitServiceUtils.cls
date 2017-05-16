global class RabitServiceUtils {
    public static HttpRequest buildWebServiceRequest(String baseURL){
        String completeURL = 'https://' + baseURL + '/rabitservices?wsdl';
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
	    req.setHeader('Content-Type', 'text/xml; charset=utf-8');   
       // req.setEndpoint(completeURL); 
        return req;
    }

    public static HttpResponse invokeWebService(Http h, HttpRequest req){
         HttpResponse res = h.send(req);
         return res;
    }
}