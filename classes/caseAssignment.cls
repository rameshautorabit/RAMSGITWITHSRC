/***************************************************************************************
    CLASS IS DEPRECATED. ALL LOGIC MOVED INTO THE CLASSASSIGNMENTCLASS
    CLIENT
        Restoration Hardware
            
    PURPOSE
        Select a case based on selection criteria and assign to a new owner
        Filter on Queue Type, Priority Flag, last modification date 
        (idealy to be stored as a custom Setting where the user can select the order and filters)
        Cases can only be selected when the user has the Skill_Set__c required by the case

        allows the admin to create custom settings to control how the case is returned via filter by and order by queries

    TEST CLASS
        caseAssignment_Test
        
    ENTRY POINTS
                        
    
    CHANGE LOG
        [[Version; Date; Author; Description]]
        v0.1; 2014/06/1; Carl Weiss/Forefront;
***************************************************************************************/

global without sharing class caseAssignment {

    /*webService static Id Assign(string queueType, Id userId) 
    {
        Set<String> skillSetList = new Set<String>();
        queueType = 'Accommodations';
        List<Skill_Set__c> ssList = [SELECT User__c, Request_category__c, Level__C FROM Skill_Set__c WHERE Active__C = true AND Queue_Type__c = :queueType AND User__c =:userid];
        
        for (Skill_Set__c ss : ssList){
            skillSetList.add(ss.Request_category__c);
        }
        
        String query = 'SELECT OwnerId, Id FROM Case WHERE Queue_Type__c =: queueType AND Request_Category__c IN: skillSetList AND Future_Processing__c = false AND OwnerId=' + '\'00GR00000018H2X\'' +  'Order by Priority DESC, Client_Type__c DESC, LastModifiedDate ASC';
        
        /*List<CaseAssignmentCritera__c> caseCriteriaList = [SELECT Case_Field__c, Value__c FROM CaseAssignmentCritera__c WHERE isSortField__c = false ORDER BY Order__c];
        
        for(CaseAssignmentCritera__c c: caseCriteriaList){
            query += ' AND ' + c.Case_Field__c + '=' + c.Value__c;
        }
        
        caseCriteriaList = [SELECT Case_Field__c FROM CaseAssignmentCritera__c WHERE isSortField__c = true ORDER BY Order__c];
        
        for(CaseAssignmentCritera__c c: caseCriteriaList){
            query += ' ORDER BY ' + c.Case_Field__c + ', ';
        }
        
        query = query.removeEnd(', ');
        query += ' LIMIT 1';
        
        System.debug(query);
        
        Case c = null;
        
        try{
            c = Database.query(query);
        }catch(QueryException qe){
            return null;
        }
        
        c.OwnerId = userId;
        
        try{
            update c;
        }catch(DmlException de){
            System.debug(de.getDMLMessage(0));
            return null;
        }
        
        return c.Id;
    }*/
}