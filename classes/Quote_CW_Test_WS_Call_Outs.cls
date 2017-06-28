public with sharing class Quote_CW_Test_WS_Call_Outs {
	
	
	
	private String url='https://servicesuat.restorationhardware.com:10000/QuoteToCW/';
	
	public HTTPResponse invokeWS(){
		
		HTTPRequest req=new HTTPRequest();
		
		req.setEndpoint(url);
		
		req.setMethod('GET');
		
		Http h=new HTTP();
		
		HttpResponse resp=h.send(req);
		
		system.debug(resp.getBody());
		
		return resp;
		
		
	}
	 
}