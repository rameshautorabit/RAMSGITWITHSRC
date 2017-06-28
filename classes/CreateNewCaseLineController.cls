public without sharing class CreateNewCaseLineController
{
    /*
    private Id caseId;
    private String caseNum;
    private Id orderId;
    private String orderNum;
    private String objectName='Case_line_Items';
    private String orderfieldName='Order';
    private String casefieldName='Case';
    private String orderfieldId='';
    private String casefieldId='';
    private String keyPrefix='';
    Id selectedLineRecTypeId = null;
    
    public CreateNewCaseLineController()
    {
        System.debug('URL' + ApexPages.currentPage().getParameters());
        caseId=ApexPages.currentPage().getParameters().get('caseId');
        System.debug(caseId);
        caseNum=ApexPages.currentPage().getParameters().get('caseNum');
        System.debug(caseNum);
        if(ApexPages.currentPage().getParameters().get('orderId')!='')
        {
            orderId=String.valueOf(ApexPages.currentPage().getParameters().get('orderId'));
        }
        System.debug(orderId);
        if(ApexPages.currentPage().getParameters().get('orderNum')!=null)
        {
            orderNum=ApexPages.currentPage().getParameters().get('orderNum');
        }
        System.debug(orderNum);
        
        Schema.DescribeSObjectResult r = Case_line_Items__c.sObjectType.getDescribe();
        keyPrefix = r.getKeyPrefix();
        //getFieldIdValue(objectName,casefieldName);
        //getFieldIdValue(objectName,orderfieldName);
    }
    
    public PageReference navigateToURL()
    {
        //String newURL='/'+ keyPrefix+'/e?'+casefieldId+'=' + caseNum +'&'+ casefieldId+ '_lkid=' + caseId+ '&'+orderfieldId+'=' + orderNum +'&'+ orderfieldId+ '_lkid=' + orderId+ '&retURL='+ caseId;
        
        //String newURL='/'+ keyPrefix+'/e?'+casefieldId+'=' + caseNum +'&'+casefieldId+ '_lkid=' + caseId;
        
        //if(String.isNotBlank(orderId) && String.isNotBlank(orderNum))
        //{
            //newURL+='&'+orderfieldId+'=' + orderNum +'&'+ orderfieldId+ '_lkid=' + orderId;
        //}
        
        //newURL+='&retURL='+ caseId;
        //return new PageReference(newURL);
        
        Case c = [select Id, RecordTypeId from Case where Id = :caseId];
        
       String caseRecordType ;
        Map<Id, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById();
        if (rtMap.containsKey(c.RecordTypeId)) {
           caseRecordType = rtMap.get(c.RecordTypeId).getName();
         }
         
        CaseToCaseLineRecordTypes__c crt = null;
        Map<String, CaseToCaseLineRecordTypes__c> crtMap = CaseToCaseLineRecordTypes__c.getAll();
        Map<String, Schema.RecordTypeInfo> rtCaseLineMap = Schema.SObjectType.Case_Line_Items__c.getRecordTypeInfosByName();
        if (crtMap.containsKey(caseRecordType)) {
           crt = CaseToCaseLineRecordTypes__c.getInstance(caseRecordType);
        if (rtCaseLineMap.containsKey(crt.CaseLine_Record_Type__c)) {
            selectedLineRecTypeId = rtCaseLineMap.get(crt.CaseLine_Record_Type__c).getRecordTypeId();
        }
        }  
            
        //String RecordTypeId=[Select Id from RecordType where Name Like 'caseRecordType%' and SObjectType='Case_Line_Items__c' ].Id;
        
        
        
        String newURL='';
        Case_Line_Items__c cli=new Case_Line_Items__c();
        cli.Order__c=orderId;
        cli.Case_Number__c=caseId;
        cli.RecordTypeId=selectedLineRecTypeId ;
        try
        {
            insert cli;
        }
        catch(DmlException e)
        {
            System.debug(e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDMLMessage(0)));
            return null;
        }
        
         newURL = '/' + cli.Id + '/e?retURL=/' + cli.Id;
        
        //newURL='/'+cli.Id;
        return new PageReference(newURL);
    }
    */
    
   /* public void getFieldIdValue(String objectName, String fieldName)
    {
        System.debug(objectName);
        System.debug(fieldName);
        try
        {
        FieldIdLookup__c  fIdL = [SELECT FieldId__c FROM FieldIdLookup__c WHERE FieldName__c =: fieldName AND ObjectName__c =: objectName LIMIT 1];
        System.debug(fIdL);
        if(fieldName=='Order' && String.isNotEmpty(fIdL.FieldId__c))
        {
            orderfieldId= fIdL.FieldId__c;
        }
        
        else if(fieldName=='Case' && String.isNotEmpty(fIdL.FieldId__c))
        {
            casefieldId= fIdL.FieldId__c;
        }
        }
        catch(QueryException e)
        {
            System.debug(e.getMessage());   
        }
        
    }*/
}