public class CreateNewCase
{
    public List<SelectOption> recordTypeList {get; Set;}
    public List<RecordType> caseRecordType {get; Set;}
    public String selectedRecordTypeId {get; Set;}
    private String selectedRecordTypeName;
    private Map<Id,String> mapOfRtype=new Map<Id,String>();
    private ApexPages.StandardsetController stdCon;
    transient  Schema.DescribeSObjectResult d = Schema.SObjectType.Case;
    transient  Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
    
    
    public CreateNewCase(ApexPages.StandardController setCon)
    {
        this.stdCon = stdCon;
        recordTypeList = new List<SelectOption>();
        caseRecordType = [SELECT Id, Name, Description FROM RecordType WHERE SobjectType='Case' AND Name != 'MASTER' ORDER BY Name];    
        
        for(RecordType rt: caseRecordType){
          Schema.RecordTypeInfo rtInfo =  rtMapById.get(rt.id);
          
         if(rtInfo.isAvailable()){
            recordTypeList.add(new SelectOption(rt.Id, rt.Name));
            mapOfRtype.put(rt.Id, rt.Name);
          }
        }
        
        selectedRecordTypeId = String.valueOf(recordTypeList.get(0));
        selectedRecordTypeName=String.valueOf(recordTypeList.get(0).getLabel());
    }
    
      public PageReference CreateCase()
    {
        Case c=new Case();
        c.RecordTypeId=selectedRecordTypeId;
        //c.Queue_Type__c=selectedRecordTypeName;
        insert c;
        Schema.DescribeSObjectResult r = Case.sObjectType.getDescribe();
        String keyPrefix=r.getKeyPrefix();
        //return new PageReference('/' + c.Id+ '/e?retURL='+c.Id);
        //return new PageReference('/'+ keyPrefix +'/e?retURL=/' + keyPrefix + '/o&RecordType=' + selectedRecordTypeId+ '&nooverride=1');
        return new PageReference('/' + c.Id);
    }    
}