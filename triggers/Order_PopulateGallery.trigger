/* Trigger to populate/update the Gallery lookup field on an Order based on the Gallery Number field */

trigger Order_PopulateGallery on RH_Order__c (before insert, before update){
    
    List<Account> accs = new List<Account>();
     
    for(RH_Order__c ord : Trigger.new){
        if(Trigger.isInsert){
            if(ord.Gallery_Number__c != null){
                accs = [Select Id from Account where Gallery__c = :ord.Gallery_Number__c limit 1];
                    if(accs.size() != 0){
                        ord.Gallery__c = accs[0].Id;
                    }
                    else{
                        ord.addError('  Please enter valid Gallery number.');
                    }
            }       
        }
        else{
            if(ord.Gallery_Number__c != null){
                RH_Order__c oldOrd = Trigger.oldMap.get(ord.Id);
                if(oldOrd.Gallery_Number__c != ord.Gallery_Number__c){
                    accs = [Select Id from Account where Gallery__c = :ord.Gallery_Number__c limit 1];
                    if(accs.size() != 0){
                        ord.Gallery__c = accs[0].Id;
                    }
                    else{
                        ord.addError(' Please enter valid Gallery number.');
                    }
                }       
            }
            else{
                ord.Gallery__c = null;
            }                
        }
    }
}