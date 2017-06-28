/**
    * Description: Class to update the fields on Case when an RH Order is Updated
    * Test Class: UpdateCaseFromRHOrder_Test
    * Apex Trigger: RHOrderTrigger
**/

public without sharing class UpdateCaseFromRHOrder
{
    public static void updateCase(List<SObject> recordsToupdate, Map<Id, RH_Order__c> triggerNewMap, Map<Id, RH_Order__c> triggeroldMap){
        Set<Id> rhIdList = new Set<Id>();
        List<CasetoOrderFieldMapping__c> caseToRHOMapping = [SELECT Case_Field__c, Order_Field__c FROM CasetoOrderFieldMapping__c];
        Id muleAPIUserId = '00550000003kjUn';
        
        Map<String, Schema.RecordTypeInfo> rtNameMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
        Id caseCWIntegrationErrRT = rtNameMap.get('CW Integration Errors').getRecordTypeId();
        Id caseCCDRecordTypeId = rtNameMap.get('Credit Card Declines').getRecordTypeId();
        
        String caseQuery = 'SELECT Id, RH_Order_Number__c, RecordTypeId, LastModifiedById, ';
        
        for(CasetoOrderFieldMapping__c cofm: caseToRHOMapping){
            caseQuery += cofm.Case_Field__c + ', ';
        }
        
        caseQuery = caseQuery.removeEnd(', ');
        
        for(RH_Order__c rh: triggerNewMap.values()){
            for(CasetoOrderFieldMapping__c cofm: caseToRHOMapping){
                if(rh.get(cofm.Order_Field__c) != triggeroldMap.get(rh.Id).get(cofm.Order_Field__c)){
                    rhIdList.add(rh.Id);
                    break;
                }
            }
        }
        
        caseQuery += ' FROM Case WHERE RH_Order_Number__c IN: rhIdList AND IsClosed = FALSE AND RecordTypeId != \'' + caseCWIntegrationErrRT + '\'';
        List<Case> caseList=new List<Case>();
        if (rhIdList.size() > 0) {
			caseList = Database.query(caseQuery);
			
        	for (Case c :caseList) {
            		
				for (CasetoOrderFieldMapping__c cofm :caseToRHOMapping) {
					
					// Verify that the user has access to the Opportunity before copying the Opportunity Id
					if (cofm.Order_Field__c == 'Opportunity__c') {
						String oppId = (String)(triggerNewMap.get(c.RH_Order_Number__c).get(cofm.Order_Field__c));
						if (String.isNotBlank(oppId)) {
							Boolean hasOppRead = [select RecordId, HasReadAccess from UserRecordAccess where UserId = :UserInfo.getUserId() and RecordId = :oppId].HasReadAccess;
							if (!hasOppRead) {
								c.put(cofm.Case_Field__c, null);
								continue;
							}
						}
					}
					
					// We only copy all updated order information to Credit Card Decline cases where the LastModifiedById 
					// is the Mule API User - means the case has not been picked up yet by any user.
					if (c.RecordTypeId != caseCCDRecordTypeId || (c.RecordTypeId == caseCCDRecordTypeId && c.LastModifiedById == muleAPIUserId)) {
						
						// If case field is Sold to address, remove BR tags and replace with New line
						if (cofm.Order_Field__c == 'Sold_to_Address__c') {
							String str = String.valueOf(triggerNewMap.get(c.RH_Order_Number__c).get(cofm.Order_Field__c));
							if (String.isNotBlank(str)) {
								str = str.replaceAll('_BR_ENCODED_','\n');
							}
							c.put(cofm.Case_Field__c, str);
						} else {
							c.put(cofm.Case_Field__c, triggerNewMap.get(c.RH_Order_Number__c).get(cofm.Order_Field__c));
						}
					
					} else {
						
						// Credit Card Declines case - only copy select information
						if ( cofm.Order_Field__c == 'Callout_Contacts__c' || 
							 cofm.Order_Field__c == 'Email_Contacts__c' || 
							 cofm.Order_Field__c == 'Opportunity__c' || 
							 cofm.Order_Field__c == 'System_Hold_Description__c' || 
							 cofm.Order_Field__c == 'System_Hold_Code__c' || 
							 cofm.Order_Field__c == 'Membership_Auto_Renewal_Order__c' || 
							 cofm.Order_Field__c == 'Number_of_Order_Lines__c' || 
							 cofm.Order_Field__c == 'Order_Notification_Visibility__c' || 
							 cofm.Order_Field__c == 'Order_Type_Code__c') {
							c.put(cofm.Case_Field__c, triggerNewMap.get(c.RH_Order_Number__c).get(cofm.Order_Field__c));
						}
					}
            	}
        	}
        	
        	try {
            	// update caseList;
            	recordsToUpdate.addAll((List<SObject>)caseList);
            	System.debug(caseList);
        	} catch(DMLException de) {
            	System.debug('*****UpdateCaseFromRHOrder exception = ' + de.getDMLMessage(0));
        	}
    	}   
    }
}