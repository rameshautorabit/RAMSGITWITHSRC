public without sharing class DynamicMembershipClass{
    
   /* private Apexpages.StandardSetController setCon;
    public String pbSectionTitle {get; set;}
    public List<groupQueueName> neweditdgList {get;set;}
    public DynamicGroup__c dg {get; set;}
    //private final String query = 'SELECT Name, Profile__c, Department__c, Group_Name__c, Queue_Name__c, Skill_Set__c FROM DynamicGroup__c';
    private final String query = 'SELECT Name, Profile__c, Group_Name__c, Department__c, Request_Category__c, Queue_Name__c FROM DynamicGroup__c';
    private List<SelectOption> groupList = new List<SelectOption>();
    private List<SelectOption> queueList = new List<SelectOption>();
    private List<SelectOption> profileList = new List<SelectOption>();
    private List<selectDynamicGroup> d;
    private Map<String, Id> groupNametoIdMap = new Map<String, Id>();
    private Set<String> isDuplicateList = new Set<String>();
       
    //Constructor
    public DynamicMembershipClass(){
        //Tell the VF page what section to display
        pbSectionTitle = 'View Membership';
        if(ApexPages.currentPage().getParameters().get('Id') != null){
           pbSectionTitle = 'Edit Membership';
           try{
               dg = Database.query(query + ' WHERE Id =: ApexPages.currentPage().getParameters().get(\'Id\')');
           }catch(QueryException qe){
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error retrieving record information. Please contact your system administrator with this error message: ' + qe.getMessage()));
               return;
           } 
        }
        neweditdgList = new List<groupQueueName>();
        queueList.add(new SelectOption('', '--None--'));
        profileList.add(new SelectOption('', '--None--'));
        List<DynamicGroup__c> dgList = Database.query(query);
        for(DynamicGroup__c dg: dgList){
            isDuplicateList.add(dg.Profile__c + ' ' + dg.Department__c + ' ' + dg.Request_Category__c);
        }
        
        setCon = new Apexpages.StandardSetController(Database.query(query));
        
        setCon.setPageSize(25);
    }
    
    //Get a list of Dynamic Groups to display
    public List<selectDynamicGroup> getdgList(){
        d = new List<selectDynamicGroup>();
        if(setCon != null){
            for(DynamicGroup__c dg: (List<DynamicGroup__c>) setCon.getRecords()){
                d.add(new selectDynamicGroup(dg));
            }
        }
        System.debug('RETURNING RECORDS' +d);
        return d;
    }
    
    //Add New Membership 
    //Display New Membership section 
    public void newMembership(){
       setCon = null; 
       pbSectionTitle = 'New Membership'; 
       findGroupandProfile();
       
       for(Integer i=0; i<5; i++){
           neweditdgList.add(new groupQueueName(new DynamicGroup__c(), groupList, queueList, profileList, new List<SelectOption>(), '', '', '', 
            new List<SelectOption>(), ''));
       }
    }
    
    //Save or update Memberships
    public PageReference saveEditMembership(){
        List<DynamicGroup__c> dynamicGroup = new List<DynamicGroup__c>();
        System.debug(isDuplicateList);
        for(groupQueueName g: neweditdgList){
            System.debug('Howard ' + g.dg.Department__c + ' ' + g.dg.Group_Name__c + ' ' + 
                    g.dg.Profile__c + ' ' + g.dg.Queue_Name__c + ' ' + g.dg.Request_Category__c);
            //if(String.isNotBlank(g.dg.Department__c) && String.isNotBlank(g.dg.Skill_Set__c) && String.isNotBlank(g.dg.Profile__c) && String.isNotBlank(g.selectedGroup)){
            if((String.isNotBlank(g.ss.Queue_Type__c) && String.isNotBlank(g.ss.Request_Category__c) && String.isNotBlank(g.dg.Profile__c) 
                && String.isNotBlank(g.selectedGroup) && String.isNotBlank(g.selectedQueue)) || pbSectionTitle.equals('Edit Membership')){
                g.dg.Group_Name__c = g.selectedGroup;
                g.dg.Queue_Name__c = g.selectedQueue;
                g.dg.Department__c = g.ss.Queue_Type__c;
                g.dg.Request_Category__c = g.ss.Request_Category__c;
                g.dg.Name = g.dg.Profile__c + ' ' + g.dg.Department__c + ' ' + g.dg.Request_Category__c;
                
                if(isDuplicateList.contains(g.dg.Profile__c + ' ' + g.dg.Department__c + ' ' + g.dg.Request_Category__c)){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Membership already exist. Please edit and try again.'));
                    return null;
                }else{
                    dynamicGroup.add(g.dg);
                }
            }
        }
        
        if(!dynamicGroup.isEmpty()){
            try{
                upsert dynamicGroup;
                for (DynamicGroup__c dg: dynamicGroup) {
                    isDuplicateList.add(dg.Profile__c + ' ' + dg.Department__c + ' ' + dg.Request_Category__c);
                }
            }catch(DMLException de){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, de.getDmlMessage(0)));
                return null;
            }
        }
        
        return cancel();
    }
    
    //Save the current list of new Memberships and display 5 more lines of new Membership to add
    public void saveandMore()
    {
        saveEditMembership();
        neweditdgList.clear();
        newMembership();
    }
    
    //Edit Membership
    public void editMembership(){
       setCon = null; 
       pbSectionTitle = 'Edit Membership'; 
       neweditdgList.clear();
       findGroupandProfile();
       System.debug('D IS' +d);
       for(selectDynamicGroup s: d){
            if(s.selected){
                List<SelectOption> selectedGroupList = new List<SelectOption>(); //List of selected groups 
                List<SelectOption> innerGroupList = new List<SelectOption>(); //List of available groups minus the selected groups 
                List<SelectOption> selectedQueueList = new List<SelectOption>(); //List of selected queues
                List<SelectOption> innerQueueList = new List<SelectOption>(); //List of available queues minus the selected queues

                if(String.isNotBlank(s.dg.Group_Name__c)){
                    parseMultiselect(s.dg.Group_Name__c, selectedGroupList, groupList, innerGroupList);
                }

                if(String.isNotBlank(s.dg.Queue_Name__c)){
                    parseMultiselect(s.dg.Queue_Name__c, selectedQueueList, queueList, innerQueueList);
                }

                neweditdgList.add(new groupQueueName(s.dg, innerGroupList, innerQueueList, profileList, selectedGroupList, 
                    s.dg.Group_Name__c, s.dg.Department__c, s.dg.Request_Category__c, selectedQueueList, s.dg.Queue_Name__c));
                
                isDuplicateList.remove(s.dg.Profile__c + ' ' + s.dg.Department__c + ' ' + s.dg.Request_Category__c);
            }
       }
    }
    
    public PageReference deleteMembership(){
        List<DynamicGroup__c> dgList = new List<DynamicGroup__c>();
        for(selectDynamicGroup s: d){
            if(s.selected){
                dgList.add(s.dg);
            }
        }
        try{
            delete dgList;
        }catch(DMLException de){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, de.getDmlMessage(0)));
            return null;
        }       
        
        PageReference pageRef = Page.dynamicmembershippage;
        pageRef.setRedirect(true);
        return pageRef;
    }

    private void parseMultiselect(String strSelectedName, List<SelectOption> selectedOptionList, List<SelectOption> availableOptionList, 
        List<SelectOption> innerAvailableOptionList){

        Set<String> selectedNameSet = new Set<String>();
        //Parse the multiselect picklist
        List<String> strselectedGroupList = strSelectedName.split(';', strSelectedName.countMatches(';') + 1);
        //Add to a set and we can use the contains method
        selectedNameSet.addAll(strselectedGroupList);

        //Create a picklist of the selectedoptions
        for(String str: selectedNameSet){
            if(String.isNotBlank(str)){ 
                selectedOptionList.add(new SelectOption(str,str));
            }
        }


        for(SelectOption so: availableOptionList){
            if(!selectedNameSet.contains(so.getValue())){
                innerAvailableOptionList.add(so);
            }
        }
    }
    
    private void findGroupandProfile(){
       //Query for groups and queues
       List<Group> groups = [SELECT Name, Type FROM Group WHERE Type='Regular' OR Type='Queue'];
       
       for(Group g: groups){
           if(g.Type.equals('Regular')){
               groupList.add(new SelectOption(g.Name, g.Name));   
           }else if(g.Type.equals('Queue')){
               queueList.add(new SelectOption(g.Name, g.Name));
           }
           groupNametoIdMap.put(g.Name, g.Id);
       }
       
       //Query for profile
       List<Profile> profiles = [SELECT Name FROM Profile];
       
       for(Profile p: profiles){
           profileList.add(new SelectOption(p.Name, p.Name));
       }
       
       profileList.sort();
    }
    
    public PageReference cancel(){
        PageReference pageRef = Page.DynamicMembershipPage;
        pageRef.setRedirect(true);
        return pageRef;
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
    
    //Get First set of records
    public void first()
    {
        if(setCon!=null)
        {
            setCon.first();
        }
    }

    //Get the previous set of records
    public void previous()
    {
        if(setCon!=null)
        {
            setCon.previous();  
        }
    }   
    
    //Get the next set of records
    public void next(){
        if(setCon!=null)
        {
            setCon.next();  
        }
    }
    
    //Get the last Set of records
    public void last(){
        if(setCon!=null)
        {
            setCon.last();  
        }
    }
    
    /****************************************************INNER CLASSES**********************************************************/
    
   /* public class groupQueueName{
        
        public DynamicGroup__c dg {get; set;}
        public List<SelectOption> groupList {get; set;}
        public List<SelectOption> selectedGroupList {get; set;}
        public String selectedGroup {get; set;} //String input of the selected groups
        public List<SelectOption> queueList {get; set;}
        public List<SelectOption> selectedQueueList {get; set;}
        public String selectedQueue {get; set;}
        public List<SelectOption> profileList {get; set;}
        public Skill_Set__c ss {get; set;}
        
        public groupQueueName(DynamicGroup__c dg, List<SelectOption> groupList, List<SelectOption> queueList, 
            List<SelectOption> profileList, List<SelectOption> selectedGroupList, String selectedGroup, 
            String dept, String reqtCat, List<SelectOption> selectedQueueList, String selectedQueue){

            this.dg = dg;
            this.groupList = groupList;
            this.queueList = queueList;
            this.selectedGroupList = selectedGroupList;
            this.profileList = profileList;
            this.selectedGroup = selectedGroup;
            this.selectedQueueList = selectedQueueList;
            this.selectedQueue = selectedQueue;
            ss = new Skill_Set__c();
            ss.Queue_Type__c = dept;
            ss.Request_Category__c = reqtCat;
        }
    }
    
    public class selectDynamicGroup{
        public Boolean selected {get;set;}
        public DynamicGroup__c dg {get;set;}
        
        public selectDynamicGroup(DynamicGroup__c dg){
            this.dg = dg;
            selected = false;
        }
    }*/
}