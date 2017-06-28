@isTest(SeeAllData=true)
private class UpdateCaseFromRHOrder_Test 
{
    public static testMethod void myUnitTest() 
    {
        Test.startTest();
        RH_Order__c rho=new RH_Order__c();
        rho.Name='ORDER 123';
        rho.Designer__c='Designer A';
        rho.Sold_To_Address_1__c='123 Test Street';
        rho.Sold_To_Address_2__c='456 Test Street';
        rho.Gallery_Number__c='5';
        rho.Total_Order_Amount__c=1500.00;
        insert rho;
        
        System.debug(rho);
         Case c=new Case();
        
        
        List<RecordType> caseRecordType = [SELECT Id, Name, Description FROM RecordType WHERE SobjectType='Case' AND Name = 'Accommodations - Order Header' LIMIT 1]; 

        if(caseRecordType.size()>0){
        	c.RecordTypeId=caseRecordType[0].Id;
        	
        }
        c.RH_Order_Number__c=rho.Id;
        c.Status='New';
       // c.Queue_Type__c='Accommodations';
        insert c;
        
        System.debug(c);
        
        //Update RHOrder
                
        rho.Name='ORDER 123';
        rho.Designer__c='Designer B';
        rho.Sold_To_Address_1__c='1234 Test Street';
        rho.Sold_To_Address_2__c='4567 Test Street';
        rho.Gallery_Number__c='5';
        rho.Total_Order_Amount__c=2500.00;
        update rho;
        
        System.debug(rho);
        Test.stopTest();
    }
}