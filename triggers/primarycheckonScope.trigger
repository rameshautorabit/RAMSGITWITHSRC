trigger primarycheckonScope on Scope_Poc_Information__c (before insert,before update) {

    list<Scope_Poc_Information__c> updateList=new list<Scope_Poc_Information__c >();
    List<id> scopeIDList = new List<id>();
    set<String> selectedVal =  new set<String>();
    set<String> availableVal =  new set<String>();
    List<String> availableVal1 =  new List<String>();
    Schema.DescribeFieldResult fieldResult = Scope_Poc_Information__c.Scope__c.getDescribe();
    List<Schema.PicklistEntry> pleList = fieldResult.getPicklistValues();
    
    for(Schema.PicklistEntry pleVar :pleList)
    {
        availableVal.add(pleVar.getLabel());
    }
    system.debug('@@@'+availableVal);
    
    if(trigger.isbefore)
    {
        for(Scope_Poc_Information__c add:Trigger.new)
        {
           if(add.Is_primary__c)
            {
               selectedVal.addAll(add.Scope__c.split(';'));
                scopeIDList.add(add.Id);
                system.debug('@@@@'+selectedVal);
            }
            for(String s: availableVal)
            {
              if(!selectedVal.contains(s))
              {
              availableVal1.add(s);
              add.Out_ofScope__c = string.join(availableVal1,',');
              }  
            }
        }
    
   }
    system.debug('@@'+availableVal1);
    list<Scope_Poc_Information__c> updatenewList = [select id,name,Is_primary__c from Scope_Poc_Information__c where id not in : scopeIDList];
    for(Scope_Poc_Information__c aa:updatenewList )
    {
        aa.Is_primary__c=false;
        updateList.add(aa);

    }
    //update updateList;
}