public with sharing class SetupController {
    
    @AuraEnabled
    public static Object getSalesForceInformation(){
        /*String[] fieldsToCheck = new String[] {
            'Id', 'Name', 'Username__c', 'Security_Token__c', 'Password__c', 'setup_vcs__r'
        };
                    
                    Map<String,Schema.SObjectField> fieldDescribeTokens = 
                    Schema.SObjectType.setup__c.fields.getMap();
        
        for(String field : fieldsToCheck) {
            if( ! fieldDescribeTokens.get(field).getDescribe().isAccessible()) {
                throw new System.NoAccessException();
                return null;
            }
        }*/
        
        System.debug('User Setup  -> ' + [select id, Name, Username__c, Security_Token__c, Password__c, (select id, Repository_Name__c, password__c, remoteurl__c, Repo_Username__c from setup_vcs__r) from setup__c]);
        System.debug('JSON Try ' + JSON.serialize([select id, Name, Username__c, Security_Token__c, Password__c, (select id, Repository_Name__c, password__c, remoteurl__c, Repo_Username__c from setup_vcs__r) from setup__c]));
        
        return JSON.serialize([select id, Name, Username__c,LastModifiedBy.Id, Security_Token__c, Password__c, (select id, Repository_Name__c, password__c, remoteurl__c, Repo_Username__c from setup_vcs__r) from setup__c]);
    }
    
    @AuraEnabled
    public static String getUserInfo(){
        return UserInfo.getUserName();
    }
    
}