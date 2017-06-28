public with sharing class MyTasks_CSC {
	
	/*
	 *	Methods for the display of a user specific list of Task records on the CSC home page.
	 *
	 */
	
	ApexPages.StandardController stdController;
	
	private List<SelectOption> displayOptions;
	private String displaySelected = '';
	private String defaultDisplay = 'All Open';
	private List<Task> tasks;
	private List<Task> taskList;
	
    // Constructor - read in the current user's task records
    public MyTasks_CSC(ApexPages.StandardController stdController) {
    	
    	tasks = new List<Task>();
    	taskList = new List<Task>();
    	tasks = [select Id, ActivityDate, Interim_Update__c, IsClosed, Client_Name__c, Order_Number__c, 
    				Priority, Status, Subject, WhatId, What.Name, Order_Number_Lookup__c, Order_Number_Lookup__r.Name 
    				from Task where OwnerId = :UserInfo.getUserId() order by ActivityDate desc limit 10000];
    	
    	displayOptions = new List<SelectOption>();
		displayOptions.add(new SelectOption('All Open', 'All Open'));
		displayOptions.add(new SelectOption('Overdue', 'Overdue'));
		displayOptions.add(new SelectOption('Due Today', 'Due Today'));
		displayOptions.add(new SelectOption('Overdue + Due Today', 'Overdue + Due Today'));
		displayOptions.add(new SelectOption('Tomorrow', 'Tomorrow'));
		displayOptions.add(new SelectOption('Next 7 Days', 'Next 7 Days'));
		displayOptions.add(new SelectOption('This Month', 'This Month'));
		displayOptions.add(new SelectOption('All Completed', 'All Completed'));
    }
    
    public List<Task> gettaskList() {
    	
    	taskList.clear();
    	if (String.isBlank(displaySelected)) {
    		displaySelected = defaultDisplay;
    	}
    	for (Task t :tasks) {
    		
    		if (taskList.size() >= 1000) {
    			break;
    		}
    		
    		if (displaySelected == 'All Open') {
    			if (!t.IsClosed) {
    				taskList.add(t);
    			}
    		}
    		if (displaySelected == 'Overdue' || displaySelected == 'Overdue + Due Today') {
    			if (t.ActivityDate < system.today() && !t.IsClosed) {
    				taskList.add(t);
    			}
    		}
    		if (displaySelected == 'Due Today' || displaySelected == 'Overdue + Due Today') {
    			if (t.ActivityDate == system.today()) {
    				taskList.add(t);
    			}
    		}
    		if (displaySelected == 'Tomorrow') {
    			if (t.ActivityDate == system.today() + 1) {
    				taskList.add(t);
    			}
    		}
    		if (displaySelected == 'Next 7 Days') {
    			if (t.ActivityDate >= system.today() && t.ActivityDate < system.today() + 7) {
    				taskList.add(t);
    			}
    		}
    		if (displaySelected == 'This Month') {
    			if (t.ActivityDate != null && t.ActivityDate.month() == system.today().month()) {
    				taskList.add(t);
    			}
    		}
    		if (displaySelected == 'All Completed') {
    			if (t.IsClosed) {
    				taskList.add(t);
    			}
    		}
    	}
    	return taskList;
    }
	
	public List<SelectOption> getdisplayOptions() {
		return displayOptions;
	}
	
	public String getdisplaySelected() {
		if (String.isBlank(displaySelected)) {
			displaySelected = defaultDisplay;
		}
		return displaySelected;
	}
	
	public void setdisplaySelected(String ds) {
		displaySelected = ds;
	}
}