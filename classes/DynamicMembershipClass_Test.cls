@isTest
private class DynamicMembershipClass_Test 
{
   /* static testMethod void testDynamicMem() 
    {
        //Create Dynamic groups
        List<DynamicGroup__c> lstOfDM=new List<DynamicGroup__c>();
        
        DynamicGroup__c d1=new DynamicGroup__c();
        d1.Profile__c='CSC Backend Associate';
        d1.Department__c='Accommodations';
        d1.Request_Category__c='Gift Card';
        d1.Queue_Name__c='Accommodations Queue;';
        d1.Group_Name__c='Accommodations;';
        lstOfDM.add(d1);
        
        
        DynamicGroup__c d2=new DynamicGroup__c();
        d2.Profile__c='CSC Frontline Associate';
        d2.Department__c='Order Inquiries';
        d2.Request_Category__c='Order Inquiries';
        d2.Queue_Name__c='DC;';
        d2.Group_Name__c='Order Inquiries - All;';
        lstOfDM.add(d2);
        
        insert lstOfDM;
        
        DynamicMembershipClass dm=new DynamicMembershipClass();
        
        //View Memberships
        dm.getdgList();
        System.debug('LIST OF MEMBERSHIPS' + dm.getdgList());
        dm.next();
        dm.previous();
        dm.first();
        dm.last();
        
        
        //Testing "New Memberships"
        dm.newMembership();
                
        //Select values
        for(DynamicMembershipClass.groupQueueName item: dm.neweditdgList)
        {
            item.dg.Profile__c='CSC Backend Associate';
            item.ss.Queue_Type__c='Accommodations';
            item.ss.Request_Category__c='Cash Accommodation';
            item.selectedQueue='Accommodations Queue;';
            item.selectedGroup='Accommodation-All;';
        }   
        
        dm.saveandMore();
        dm.cancel();
        
        //Testing "Edit Memberships" functionality      
        DynamicMembershipClass dm2=new DynamicMembershipClass();
                
        for(DynamicMembershipClass.selectDynamicGroup d:(List<DynamicMembershipClass.selectDynamicGroup>)dm2.getdgList())
        {
            d.selected=true;
            System.debug('DYNAMIC Group' + d);
        }
        
        dm2.editMembership();
        
    }*/
}