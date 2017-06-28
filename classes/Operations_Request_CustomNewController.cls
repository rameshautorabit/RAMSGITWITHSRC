/**
 * Description: Controller for the custom visual force page Operations_Request_CustomNew
 * Author: Eashan Parlewar
 * Created Date : 21-04-2017
*/
public with sharing class Operations_Request_CustomNewController 
{
   			public string ProductID;
   			public string ProductName;
            public string SkuID;
            public string SkuLookupID;
            
            //Get the product id from javascript button
            //query on product for product name in the controller of the class
   			public Operations_Request_CustomNewController(Apexpages.StandardController stdCon)
        	{
	        		ProductID=stdCon.getId();
	        		list<Product2> productList=[select id,Name from Product2 where id =:ProductID];
	        		ProductName=productList[0].Name;
        	} 
        	
        	//method to redirect the control to standard edit page of operation request
        	public Pagereference RedirectUrl()
        	{
	        		String prefix = Schema.getGlobalDescribe().get('Operations_Request__c').getDescribe().getKeyPrefix();
	        		
	        		//get the record type id of Operation Request type 'Product Information'
					Id devRecordTypeId = Schema.SObjectType.Operations_Request__c.getRecordTypeInfosByName().get('Product Information').getRecordTypeId();
					
					//get the salesforce field ids of the fields in the standard edit page of operation request 
					PageReference pr = new PageReference('/' + prefix + '/e?nooverride=1&RecordType='+devRecordTypeId);
					String html;
					Blob pageContent;
					
					if(Test.isRunningTest())
						pageContent = blob.valueof('Test');
					else
						pageContent = pr.getContent();
					
					if (pageContent != null) 
					    html = pageContent.toString();
					
					Matcher macher = Pattern.compile('<label for="(.*?)">(<span class="requiredMark">\\*</span>)?(.*?)</label>').matcher(html);
					while ( macher.find() ) 
					{
						    String label = macher.group(3); String fldId = macher.group(1);
						    if(label=='SKU#')
						       SkuID=fldId; SkuLookupID=fldId+'_lkid';
					}
					
					//generate the redirect url 
					PageReference NewOperationRequest = new PageReference('/' + prefix + '/e?nooverride=1&RecordType='+devRecordTypeId+'&'+SkuID+'='+ProductName+'&'+SkuLookupID+'='+ProductID);
					NewOperationRequest.setRedirect(true);
					return NewOperationRequest;
        	}    
}