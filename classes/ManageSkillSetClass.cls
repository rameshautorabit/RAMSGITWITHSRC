public without sharing class ManageSkillSetClass
{   
    //Selected values
 /*   public String user{get;Set;}
    //public String selectedProfile{get;Set;}
    
    //Pagination variables
    public ApexPages.StandardSetController setCon;
    private List<Skill_Set__c> skillSetList = new List<Skill_Set__c>();
    
    public Skill_Set__c newSkillSet{get; set;}
    public Skill_Set__c querySkillSet{get; set;}
    public String newSSBtnLabel {get; set;}
    public Boolean displayNewSkillSet{get; set;}
    public String isActive {get; set;}
    public Id cloneskillSetId {get; set;}
    public List<SelectOption> profileList {get;set;}
    public String profile {get; set;}
    
    private String query = 'SELECT Id,Active__c, isDelete__c, Category_User_Workflow__c, Active_Date__c, Queue_Type__c, Request_Category__c, Level__c, User__c, User__r.Profile.Name FROM Skill_Set__c WHERE Id != null ';
    private String whereCondition = '';
    
    //Constructor
    public ManageSkillSetClass(){
        newSkillSet = new Skill_Set__c();
        newSkillSet.Active__c = true;
        newSSBtnLabel = 'New Skill Set';
        displayNewSkillSet = false;
        querySkillSet = new Skill_Set__c();
        user = '';
        profile = '';
        isActive = '';
        profileList = new List<SelectOption>();
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name LIKE 'CSC%'];
        profileList.add(new SelectOption('', '--None--'));
        for(Profile p: profiles){
            profileList.add(new SelectOption(p.Id, p.Name));
        }
        
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query + ' ORDER BY User__r.Name'));
        setCon.setPageSize(50);
        System.debug(setCon.getRecords());
    }
    
    public List<Skill_Set__c> getskillSetList(){
        if(setCon != null){
            skillSetList = (List<Skill_Set__c>)setCon.getRecords();
            return skillSetList;
        }
        return new List<Skill_Set__c>();
    }
    
    public void addNewSkillSet(){
        if(!displayNewSkillSet){
            displayNewSkillSet = true;
        }else{
            try{
                User skUser = [select Id, Name, Alias from User where Id = :newSkillSet.User__c];
                //newSkillSet.name = newSkillSet.User__c + ' - ' + newSkillSet.Queue_Type__c + ' - ' + newSkillSet.Request_Category__c;
                //newSkillSet.name = skUser.Name + ' - ' + skUser.Alias + ' - ' + newSkillSet.Queue_Type__c + ' - ' + newSkillSet.Request_Category__c;
                newSkillSet.Category_User_Workflow__c = newSkillSet.Request_Category__c + ' ' + newSkillSet.User__c + ' ' + newSkillSet.Queue_Type__c;
                insert newSkillSet;
            }catch(DmlException de){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, de.getDMLMessage(0)));
                return;
            }   
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Skill Set Added Successfully'));
            displayNewSkillSet=false;
            newSkillSet = new Skill_Set__C();
            Integer currPageNum = setCon.getPageNumber();
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query + whereCondition + ' ORDER BY Active__c DESC, User__r.Name'));
            setCon.setPageSize(20);
            setCon.setpageNumber(currPageNum);
        }
    }
    
    public void cancelNewSkillSet(){
        displayNewSkillSet=false;
        newSkillSet = new Skill_Set__C();
    }
    
    public void updateSkillSetList(){
        try{
            update skillSetList;
        }catch(DmlException de){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, de.getDMLMessage(0)));
            return;
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Skill Sets Updated Successfully'));
    }  
    
    public void cloneSkillSet(){
        if(cloneskillSetId != null){
            Skill_Set__c ss = [SELECT Active__c, User__c, Queue_Type__c, Request_Category__c, Active_Date__c 
                               FROM Skill_Set__c WHERE Id =: cloneskillSetId];
            newSkillSet = ss.clone(false, true, false, false);
            displayNewSkillSet = true;
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Empty/Wrong Skill Set Id. Please contact your System Administrator'));
        }
        
    }
    
    public void deleteSkillSet(){
        List<Skill_Set__c> deleteSSList = new List<Skill_Set__c>();
        
        for(Skill_Set__c ss: skillSetList){
            if(ss.isDelete__c){
                deleteSSList.add(ss);
            }
        }
        
        try{
            delete deleteSSList;
        }catch(DmlException de){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, de.getDMLMessage(0)));
            return;
        }
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Skill Sets Deleted Successfully'));
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query + whereCondition  + ' ORDER BY Active__c DESC, User__r.Name'));
        setCon.setPageSize(20);
        getskillSetList();
    }
    
    public void filterSkillSet(){
        whereCondition = '';
        
        if(String.isNotBlank(isActive)){
            whereCondition += ' AND Active__c ='+isActive;
        }
        
        if(String.isNotBlank(user) && user.length() >= 2){
            whereCondition += ' AND User__r.Name LIKE \'%' + user + '%\'';
        }

        if(String.isNotBlank(querySkillSet.Queue_Type__c)){
            whereCondition += ' AND Queue_Type__c = \'' + querySkillSet.Queue_Type__c + '\'';
        }
        
        if(String.isNotBlank(querySkillSet.Request_Category__c)){
             whereCondition += ' AND Request_Category__c = \'' + querySkillSet.Request_Category__c + '\'';
        }
        
        if(String.isNotBlank(profile)){
            whereCondition += ' AND User__r.ProfileId =: profile';
        }
        
        System.debug(whereCondition);
        System.debug(query + whereCondition  + ' ORDER BY Active__c DESC, User__r.Name');
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query + whereCondition  + ' ORDER BY Active__c DESC, User__r.Name'));
        setCon.setPageSize(20);
    }
    
    //Pagination Methods
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        private set;
    }
    
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        private set;
    }
    
    public Boolean hasFirst {
        get {
            if (setCon.getResultSize() > 20) {return true;}
            else {return false;}
        }
        private set;
    }
    
    public Boolean hasLast {
        get {
            
            if (setCon.getResultSize() > 20) {return true;}
            else {return false;}
        }
        private set;
    }
    
    /*public Integer pageNumber {
        get {
            if(setCon!=null){
                return setCon.getPageNumber();
            }else{
                return 1;
            }
        }
        private set;
    }*/
    
    /*public Integer getTotalPages()
    {
        return ((Integer) Math.Ceil (Double.valueOf(setCon.getResultSize()/pageSize)));
    }*/
    
    //Get First set of records
    /*public void first(){
        setCon.first(); 
    }
    
    //Get the previous set of records
    public void previous(){
        setCon.previous();  
    }
    
    //Get the next set of records
    public void next(){
        setCon.next();  
    }
    
    //Get the last Set of records
    public void last(){
        setCon.last();  
    } */

    /*public void toggleSort()
    {
    // Toggle the direction
    sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
    
    //queryString='SELECT Id, Name, SerialNumber, Product2Id, Status,Contract_Number__c, Service_Contract_Number__c,Lease_Contract_Number__c, BP_Number__c, Model_Name__c, Model_Name_v__c, Service_Base_Charge__c,Configuration_Number__c FROM Asset WHERE Id IN:sortAssetIds';
    //System.debug(queryString +'  ORDER BY  ' + sortField);
    List<Membership__c> lstOfmemShips=Database.query(qStr +' ORDER BY ' + sortField + '  ' + sortDir);
    setCon=new ApexPages.StandardSetController(lstOfmemShips);
    setCon.setPageSize(pageSize);
    }*/
}