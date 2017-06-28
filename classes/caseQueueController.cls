/***************************************************************************************
    CLIENT
        Restoration Hardware
            
    PURPOSE
        Controller for page caseQueue

    TEST CLASS
        caseQueueController_Test
        
    ENTRY POINTS
        caseQueue VF Page                 
    
    CHANGE LOG
        [[Version; Date; Author; Description]]
        v0.1; 2014/06/30; Carl Weiss/Forefront;
        
        v0.2;04/25/2016;Raghu Cheruvu;Commented out line 26, code pertaining to Skill Set, as part of CSC code Refactoring
***************************************************************************************/
public with sharing class caseQueueController {
 	Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}

    Public caseQueueController()
    {
    /*	Skill_Set__c skillSet = new Skill_Set__c(); */
    }

    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                size = 10;
                string queryString = 'Select id, IsEscalated,Description,CaseNumber from Case';
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
            }
            return setCon;
        }set;
    }
     
    Public List<Case> getCases(){
        List<Case> caseList = new List<Case>();
        for(Case c : (List<Case>)setCon.getRecords())
            caseList.add(c);
        return caseList;
    }
     
    public pageReference refresh() {
        setCon = null;
        getCases();
        setCon.setPageNumber(1);
        return null;
    }
     
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
  
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }
  
    public void first() {
        setCon.first();
    }
  
    public void last() {
        setCon.last();
    }
  
    public void previous() {
        setCon.previous();
    }
  
    public void next() {
        setCon.next();
    }
}