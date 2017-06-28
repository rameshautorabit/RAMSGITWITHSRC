/**
    Class: CloneCaseWithCaseLineController
    Description: This class is a controller extension for the visual force page CloneCaseWithCaseLines 
    Author: vk@ff
    Created Date: 08/26/2014
 **/


public with sharing class CloneCaseWithCaseLineController
{
    public Case ca;
    private Id cId;
    public SObject obj;
 
    public CloneCaseWithCaseLineController(ApexPages.StandardController controller)
    {
        ca = (Case)controller.getRecord();
        cId=ca.Id;
    }
    
    public PageReference cloneRecord()
    {
        Sobject clonesCase;
        Id cscQaAuditProfileId = '00e50000000jPgR';
        Id coachingCaseRecordTypeId = '012500000009tdz';
        
        //Describes SObject
        Schema.DescribeSObjectResult d =Case.sObjectType.getDescribe();
        
        String query='SELECT ' + getFieldsStr(d) + ' FROM Case WHERE Id=\'' + cId + '\'';
        obj=Database.query(query);
        
        // Users with profile CSC QA/Audit Associate are only allowed to clone coaching cases
        Case originalCase = (Case)obj;
        if (UserInfo.getProfileId() == cscQaAuditProfileId && originalCase.RecordTypeId != coachingCaseRecordTypeId) {
        	Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Insufficient Priviledges.\nYou do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.'));
        	return null;
        }
        
        obj=obj.clone();
        Case clonedCase = (Case)obj;
        clonedCase.Status = 'New';
        clonedCase.ParentId = cId;
        clonedCase.OwnerId = UserInfo.getUserId();
        List<Database.SaveResult> lstSRes=new List<Database.SaveResult>();
        lstSRes.add(Database.insert(obj,false));
        if(lstSRes.size()>0)
        {
            addErrorsToPage(lstSRes,'Case');
        }
        
        for(Schema.ChildRelationship cr:d.getChildRelationships())
        {
            if(String.valueOf(cr.getChildSObject())=='Case_Line_Items__c' || String.valueOf(cr.getChildSObject())=='Case_Comments__c')
            {
                Schema.DescribeSObjectResult c = Schema.getGlobalDescribe().get(string.valueOf(cr.getChildSObject())).getdescribe();
                if(c.isCreateable())
                {
                    cloneRelatedList(c,cr); 
                }
            }
        }
        if(ApexPages.hasMessages()) return null;
        
        return new Pagereference('/'+obj.Id);
    }
    
    
    
    public String getFieldsStr(Schema.DescribeSObjectResult d)
    {
        String str='';
        
        Map<String,Schema.SObjectField> mFields=d.fields.getMap();
        for(String fStr:mFields.keySet())
        {
            if(mFields.get(fStr).getDescribe().isCreateable() && (!mFields.get(fStr).getDescribe().isExternalID()))
            {
                str=str+','+mFields.get(fStr).getDescribe().getName();
            }
        }
        
        str=str.replaceFirst(',','');
        return str;
    }
    
    public void cloneRelatedList(Schema.DescribeSObjectResult c, Schema.ChildRelationship cr)
    {
        List<Sobject> clonedRLRec=new List<SObject>();
        String q='SELECT ' + getFieldsStr(c) + ' FROM ' + String.valueOf(cr.getChildSObject()) + ' WHERE ' + cr.getField() + '=\'' + cId + '\'';
        List<SObject> lstRLRecords=Database.query(q);
        if(!lstRLRecords.isEmpty())
        {
            for(SObject r: lstRLRecords)
            {
                SObject newRec=r.clone();
                newRec.put(cr.getField(),obj.Id);
                clonedRLRec.add(newRec);
            }
        
            Database.SaveResult[] lsr = database.insert(clonedRLRec,false);
            if(lsr.size()>0)
            addErrorsToPage(lsr,String.valueOf(cr.getChildSObject()));
        }       
    }
	

    public void addErrorsToPage(Database.SaveResult[] lsr,String objName)
    {
        for(Database.SaveResult res : lsr)
        {
           if (!res.isSuccess()){
               for(Database.Error err: res.getErrors())
               {
                    //system.debug('*****CloneCaseWithCaseLineController ERROR objName = ' + objName + 'errMessage = ' + err.getMessage());
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,objName+': '+  err.getMessage())); 
               }    
           }
        }
    }
}