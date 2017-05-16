global class RabitUtils {
    public static String rabitInstance = '183.82.4.69:8954/rabit';
    public static String endPointUrl = 'http://' + rabitInstance + '/rabitservices?wsdl';
    public static HttpRequest buildWebServiceRequest(){
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
	    req.setHeader('Content-Type', 'text/xml; charset=utf-8'); 
        req.setTimeout(120000);
        req.setEndpoint(endPointUrl); 
        return req;
    }
    public static HttpResponse invokeWebService(Http h, HttpRequest req){
         HttpResponse res = h.send(req);
         return res;
    }
}