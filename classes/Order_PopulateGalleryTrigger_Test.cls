@isTest(SeeAlldata=true)

public with sharing class Order_PopulateGalleryTrigger_Test {
	 static testMethod void unitTest() 
    	{
        Test.startTest();
        
        // Create RHOrder with null Gallery Number
        RH_Order__c rhoNullGall=new RH_Order__c();
        rhoNullGall.Name='nullGalleryIns';
        rhoNullGall.Gallery_Number__c = null;
        
        try{ 
        	insert rhoNullGall;
        }catch(Exception e){
        	System.Assert(e.getMessage().contains('  Please enter valid Gallery number.'));
        }
        
        // Create RHOrder with blank Gallery Number
        RH_Order__c rhoBlankGall=new RH_Order__c();
        rhoBlankGall.Name='blankGallIns';
        rhoBlankGall.Gallery_Number__c = '';
        
        insert rhoBlankGall;
        
        // Create RHOrder with invalid Gallery Number
        RH_Order__c rhoInvalidGall=new RH_Order__c();
        rhoInvalidGall.Name='invalidGallIns';
        rhoInvalidGall.Gallery_Number__c = '999';
        
        try{ 
        	insert rhoInvalidGall;
        }catch(Exception e){
        	System.Assert(e.getMessage().contains('  Please enter valid Gallery number.'));
        }    
        
        // Create RHOrder with valid Gallery Number
        RH_Order__c rhoValidGall=new RH_Order__c();
        rhoValidGall.Name='validGallIns';
        rhoValidGall.Gallery_Number__c = '5';
        
        insert rhoValidGall;
        
        // Update valid Gallery Number RHOrder with invalid Gallery Number
       	rhoValidGall.Gallery_Number__c = '999';
       	
       	try{ 
        	update rhoValidGall;
        }catch(Exception e){
        	System.Assert(e.getMessage().contains('  Please enter valid Gallery number.'));
        }    
        
        // Update null Gallery Number RHOrder with blank Gallery Number
        rhoValidGall.Gallery_Number__c = '';
        
        update rhoValidGall;
        
        // Update blank Gallery Number RHOrder with valid Gallery Number
        rhoValidGall.Gallery_Number__c = '5';
        
        update rhoValidGall;
        
        Test.stopTest();
    }
}