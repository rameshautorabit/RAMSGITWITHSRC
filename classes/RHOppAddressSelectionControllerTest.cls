@isTest
public class RHOppAddressSelectionControllerTest {       
    
    static testMethod void myTest() {
        PrepareData.createGenericRHData();
        
        Contact_Address__c con = new Contact_Address__c();
        con.Contact__c=[SELECT id FROM Contact][0].id;
        con.Address_1__c='s';
        con.Address_2__c='d';
        con.State__c='d';
        con.CITY__c='ds';
        con.Zip__c='g';
        insert con;
        system.assertNotEquals(con.id, null);
        
        List<Contact_Address__c> conList= new  List<Contact_Address__c>();
        conList.add(con);
        
        RHOpportunityAddressSelectionController selectController= new RHOpportunityAddressSelectionController();
        PageReference pr= new PageReference('/apex/OpportunityAddressSelectionPage');                
        selectController.selectedRecordType= 'Design Atelier';
        selectController.selectedContactId=con.id;
        selectController.contactAdressList=conList;
        selectController.doCancel();
        selectController.getcontactAdressList();
        selectController.fillUrlParamters(pr,'a','b','c','d','e','k',conList,'f');
        selectController.generateUrl();
        selectController.getSelectedContactAddress();
       
    }
}