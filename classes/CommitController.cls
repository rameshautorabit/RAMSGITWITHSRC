public with sharing class CommitController {
    @AuraEnabled
    public static List<Setup_VCS_branch__c> getRepoDetails(){
        List<Setup_VCS_branch__c> repoDetails = [select Branch_Name__c, setup_vcs__r.Repository_Name__c, setup_vcs__r.remoteurl__c, setup_vcs__r.Repo_Username__c, setup_vcs__r.Password__c, setup_vcs__r.SCMType__c  from Setup_VCS_branch__c]; 
        return repoDetails;   
        
    }
    
    @AuraEnabled
    public static List<CommitFetch__c> getUserChanges(){
        List<CommitFetch__c> userChanges = [select Action__c, Component__c, Manageble_State__c, Members__c, Modified_Date__c from CommitFetch__c]; 
        return userChanges;   
        
    }
    
    @AuraEnabled
    public static List<agf__ADM_Sprint__c> getAlmDetails(){
        return [select id, Name, (select agf__Subject__c from agf__Work__r where agf__Type__c = 'User Story' and agf__Scrum_Team_Name__c != 'Sample') from agf__ADM_Sprint__c];   
    }
    
    @AuraEnabled
    public static Object getSprintUserStories(String sprintId){
        return ([select id, Name, (select agf__Subject__c from agf__Work__r where agf__Type__c = 'User Story' and agf__Scrum_Team_Name__c != 'Sample') from agf__ADM_Sprint__c where id =: sprintId ]);
    }
    
    @AuraEnabled
    public static void upsertCommitHistoryAp(){
        Commit_History__c obj = new Commit_History__c();
        obj.Sprint__c = '2016.10bcde';
        obj.Name = 'f9fb186';
        obj.Work_Story__c = 'Version Control Enhancement';
        obj.Target_Repository__c = 'ACE';
        obj.Branch__c = 'UAT';
        insert obj;
    }
    
    @AuraEnabled
    public static String fetchUserChangesReq(){
        HttpRequest req = RabitUtils.buildWebServiceRequest();
        String orgName = 'lightning.com';
        String userName = '0054B000000pAeTQAU';
        String sfEle = EncodingUtil.base64Encode(Blob.valueOf('<sforg id="abcdef123456" userid="0054B000000pAeTQAU" authtype = "Standard" url="https://test.salesforce.com" username="naresh@autorabit.com.lightning" password = "Euphoria@7" stoken="qXRv9Q72ivNWdKkTWUlQPfaS0"></sforg>'));
        String repoEle = EncodingUtil.base64Encode(Blob.valueOf('<repository id="repoid"><branch id="123456788994322" createdby="0054B000000pAeTQAU" repourl="abcddefghij13435235r23" branchurl="http://github.com/abc.git" name="dev" password="hyd@345" username="naresh.a" scmtype="git"/></repository>'));
        String reqBody = '<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ws=\"http://ws.service.rabit.com/\"><soapenv:Header/><soapenv:Body>'
            +'<ws:fetchSfUserChangesLightningWrapper>'
            +'<orgname>'+orgName+'</orgname>'
            +'<userslist>'+userName+'</userslist>'
            +'<sfele>'+sfEle+'</sfele>'
            +'<repoele>'+repoEle+'</repoele>'
            +'</ws:fetchSfUserChangesLightningWrapper>'
            +'</soapenv:Body></soapenv:Envelope>';
        System.debug(reqBody);
        req.setBody(reqBody);
        Http http = new Http();
        String response = RabitUtils.invokeWebService(http,req).getBody();
        System.debug(response);
        /* response = response.replace('"metadata":{', '"metadata":[{');
response = response.replace('},"name"', '}],"name"');
String regex = '\"metadata\":\\[(\"\\d{2,}\",|\"\\d{2,}\")*\\],';
Pattern regexPattern = Pattern.compile(regex); 
Matcher regexMatcher = regexPattern.matcher(response);
if(regexMatcher.find()) {
System.debug(loggingLevel.Error, '*** Regex match found');
response = response.replaceAll(regex, '');
}

JSONParser parser = JSON.createParser(response);
// Get question data from quiz_data
while (parser.nextToken() != null) {
if (parser.getText() == 'quiz_data') {
while (parser.nextToken() != null) {
// Advance to the start object marker to
//  find next quiz submission object.
if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
// Read entire quiz_data object, including its array of event data.
sub = (List<changes>)parser.readValueAs(List<changes>.class);

// Skip the child start array and start object markers.
parser.skipChildren();
}
}
}
}*/
        return response;
    }
    @AuraEnabled
    public static String tempFetchUserChangesReq(String branchName){
        HttpRequest req = RabitUtils.buildWebServiceRequest();
        String orgName = 'lightning.com';
        String userName = 'testuser@lightning.com';
        String sfEle = getSFElement();
        System.debug('sfEle' + sfEle);
        String repoEle = getRepoElement(branchName);
        System.debug('repoEle' + repoEle);
        String reqBody = '<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ws=\"http://ws.service.rabit.com/\"><soapenv:Header/><soapenv:Body>'
            +'<ws:fetchSfUserChangesLightningWrapper>'
            +'<orgname>'+orgName+'</orgname>'
            +'<userslist>'+userName+'</userslist>'
            +'<sfele>'+sfEle+'</sfele>'
            +'<repoele>'+repoEle+'</repoele>'
            +'</ws:fetchSfUserChangesLightningWrapper>'
            +'</soapenv:Body></soapenv:Envelope>';
        System.debug('reqBody' + reqBody);
        req.setBody(reqBody);
        Http http = new Http();
        HttpResponse res = RabitUtils.invokeWebService(http, req);
        System.debug(res.getBody());
        return res.getBody();
    }
    
    public static String getSFElement(){
        Setup__c setupObject = [select id, Name, LastModifiedBy.Id, Username__c, Security_Token__c, Password__c from setup__c];
        String sfElementString = '<sforg id= "' + setupObject.Id +'"userid="' + UserInfo.getUserId() + '" authtype = "Standard" url="' + System.URL.getSalesforceBaseUrl() + '" username="' + setupObject.Username__c + '" password = "' + setupObject.Password__c + '" stoken="' + setupObject.Security_Token__c + '"></sforg>';
        return EncodingUtil.base64Encode(Blob.valueOf(sfElementString));
    }
    
    public static String getRepoElement(String branchName){
        setup_vcs__c setupVcsObject = [select id, Repository_Name__c, password__c, remoteurl__c, Repo_Username__c from setup_vcs__c];
        String repoElementString = '<repository id="' + setupVcsObject.Id + '"><branch id="123456788994322" createdby="testuser@lightning.com" name="testbranch" repourl="abcddefghij13435235r23" branchurl="http://github.com/abc.git" name="dev" password="hyd@345" username="naresh.a" scmtype="git"/></repository>';
        
        String s = EncodingUtil.base64Encode(Blob.valueOf('as'));
        
        return '';
    }
}