@isTest(SeeAlldata=true)
private class ShipToTrigger_Test 
{
    static testMethod void myUnitTest() 
    {
        Test.startTest();
        
        //Create RHOrder
        RH_Order__c rho=new RH_Order__c();
        rho.Name='ORDER 123';
        
        insert rho;
        
        //Create Ship To
        Ship_To__c st=new Ship_To__c();
        st.Name='1';
        st.Ship_to_Address_1__c='123 Test Street';
        st.Ship_to_Address_2__c='Suite 1';
        st.Ship_to_Company__c='Near RH Building';
        st.Ship_to_State__c='NJ';
        st.Ship_to_City__c='Test City';
        st.Ship_to_Zip__c='07704';
        st.Ship_to_Country__c='US';
        st.Ship_to_Day_Phone__c='1112223344';
        st.Ship_to_Night_Phone__c='2223334455';
        st.Ship_to_Email__c='test@testrh.com';
        st.Ship_to_Last_Name__c='Guo';
        st.Ship_to_First_Name__c='Alex';
        st.Order__c=rho.Id;
        
        insert st;
        
        
    }
}