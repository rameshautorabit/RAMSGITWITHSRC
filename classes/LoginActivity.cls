public with sharing class LoginActivity {
	
	static String completeURL = '';
	
	@AuraEnabled
	public static Object loginValidate(String url, String userEmail, String userPassword){

		//System.debug(url + '->' + userEmail + '->' + userPassword);
		//return url + '->' + userEmail + '->' + userPassword;
		//userEmail = 'sampath.c@autorabit.com';
		//userPassword = 'Rabit@345';

        LoginActivity loginActivity = new LoginActivity();

	/*	String randomUUID = ArAppSingleTon.randomStringGenerator();
		System.debug('Random ' + randomUUID);*/

		Blob userPasswordBlob = Blob.valueOf(userPassword);
		String tempEncodedPassword = EncodingUtil.base64Encode(userPasswordBlob);

// 		String encodedPassword = randomUUID.substring(0, 5) + tempEncodedPassword + randomUUID.substring(randomUUID.length() - 6, randomUUID.length() - 1);
// 		System.debug(' Username-> ' + userEmail +'encodedPassword-> ' + encodedPassword);
		completeURL = 'https://' + url + '/rabitservices?wsdl';
		HttpRequest req = RabitServiceUtils.buildWebServiceRequest(url);
		String reqBody = '<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:web=\"http://ws.service.rabit.com/\"><soapenv:Body><web:userLogin><usermail>'+userEmail+'</usermail><password></password><seccode>  </seccode></web:userLogin></soapenv:Body></soapenv:Envelope>';
		req.setBody(reqBody);
		Http http = new Http();
		
			HttpResponse res = loginActivity.invokeWebService(http, req);
			System.debug('Login String: ' + res.toString());
			System.debug('Login StatusCode: ' + res.getStatusCode());
			System.debug('Login Status: ' + res.getStatus());
			System.debug('Login Body: ' + res.getBody());

			System.debug('Login Soap Body -?  ' + reqBody);
			return res.getBody();
		
	}
	
	@AuraEnabled
	public static object getAgentsCallout(String url){
	    LoginActivity loginActivity = new LoginActivity();
	    completeURL = 'https://' + url + '/rabitservices?wsdl';
	    HttpRequest req = loginActivity.buildWebServiceRequest();
	    
	    String getAgentsReq = '<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ws=\"http://ws.service.rabit.com/\"><soapenv:Header/><soapenv:Body><ws:getAgents><orgname>autorabit.com</orgname></ws:getAgents></soapenv:Body></soapenv:Envelope>';
	    req.setBody(getAgentsReq);
		Http http = new Http();
		HttpResponse res = loginActivity.invokeWebService(http, req);
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
    
    @AuraEnabled
    public static String stringToDecode(String decoderString){
        System.debug(decoderString);
        String temp =  decoderString.substring(5, decoderString.length() - 5);
        Blob decoderBlobString = EncodingUtil.base64Decode(temp);
        return decoderBlobString.toString();
    }
}