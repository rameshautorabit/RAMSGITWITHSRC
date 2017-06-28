trigger TaskTrigger on Task (before insert, before update) {
    
    /*
     *  If Task record type is "CSC Follow Up", populate the order lookup and client contact
     *  information from the Case record.
     *
     *  If Task record type is "CSC InMoment Survey", populate InMoment Client First Name, 
     *  InMoment Client Last Name, and InMoment Client Email based on Contact information 
     *  entered.
     *
     */ 
    
    Map<Id, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Task.getRecordTypeInfosById();
    
    List<Id> cIds = new List<Id>();
    List<Id> conIds = new List<Id>();
    
    for (Task t :trigger.new) {
        if (t.WhatId != null && rtMap.containsKey(t.RecordTypeId)) {
            if (rtMap.get(t.RecordTypeId).getName() == 'CSC Follow Up' && String.valueOf(t.WhatId.getSObjectType()) == 'Case') {
                cIds.add(t.WhatId);
            }
        }
         
        if (trigger.isBefore) {
            if (trigger.isInsert) {
                if (t.WhoId != null && rtMap.containsKey(t.RecordTypeId)) {
                    if (rtMap.get(t.RecordTypeId).getName() == 'CSC InMoment Survey') {
                        conIds.add(t.WhoId);
                    }
                }
            }
        }
    }
    
    if (!cIds.isEmpty()) {
        Map<Id, Case> cMap = new Map<Id, Case>([select Id, CaseNumber, Sold_to_Name__c, Sold_to_Day_Phone__c, 
                Sold_to_Night_Phone__c, Sold_to_Email__c, ShipTo1_Name__c, ShipTo1_Day_Phone__c, ShipTo1_Night_Phone__c, 
                ShipTo1_Email__c, Send_to_First_Name__c, Send_to_Last_Name__c, Send_to_Day_Phone__c, Send_to_Night_Phone__c, 
                Send_to_Email__c, RH_Order_Number__c, RH_Order_Number__r.Name from Case where Id in :cIds]);
        
        for (Task t :trigger.new) {
            if (cMap.containsKey(t.WhatId)) {
                t.Order_Number__c = cMap.get(t.WhatId).RH_Order_Number__r.Name;
                t.Order_Number_Lookup__c = cMap.get(t.WhatId).RH_Order_Number__c;
                if (String.isNotBlank(t.Contact_Type__c) && t.Contact_Type__c != 'Other Contact') {
                    if (t.Contact_Type__c == 'Sold To') {
                        t.Client_Name__c = cMap.get(t.WhatId).Sold_to_Name__c;
                        t.Client_Primary_Phone__c = cMap.get(t.WhatId).Sold_to_Day_Phone__c;
                        t.Client_Secondary_Phone__c = cMap.get(t.WhatId).Sold_to_Night_Phone__c;
                        t.Primary_Email__c = cMap.get(t.WhatId).Sold_to_Email__c;
                    }
                    if (t.Contact_Type__c == 'Ship To 1') {
                        t.Client_Name__c = cMap.get(t.WhatId).ShipTo1_Name__c;
                        t.Client_Primary_Phone__c = cMap.get(t.WhatId).ShipTo1_Day_Phone__c;
                        t.Client_Secondary_Phone__c = cMap.get(t.WhatId).ShipTo1_Night_Phone__c;
                        t.Primary_Email__c = cMap.get(t.WhatId).ShipTo1_Email__c;
                    }
                    if (t.Contact_Type__c == 'Send To') {
                        t.Client_Name__c = cMap.get(t.WhatId).Send_to_Last_Name__c + ', ' + cMap.get(t.WhatId).Send_to_First_Name__c;
                        t.Client_Primary_Phone__c = cMap.get(t.WhatId).Send_to_Day_Phone__c;
                        t.Client_Secondary_Phone__c = cMap.get(t.WhatId).Send_to_Night_Phone__c;
                        t.Primary_Email__c = cMap.get(t.WhatId).Send_to_Email__c;
                    }
                }
            }
        }
    }
    
    if (!conIds.isEmpty()) {
        Map<Id, Contact> conMap = new Map<Id, Contact>([select Id, FirstName, LastName, Email from Contact where Id in :conIds]);
        
        for (Task t :trigger.new) {
            if (conMap.containsKey(t.WhoId)) {
                t.InMoment_Contact_Record_Id__c = conMap.get(t.WhoId).Id;
                t.InMoment_Contact_First_Name__c = conMap.get(t.WhoId).FirstName;
                t.InMoment_Contact_Last_Name__c = conMap.get(t.WhoId).LastName;
                t.InMoment_Contact_Email_Address__c = conMap.get(t.WhoId).Email;
            }
        }
    }
}