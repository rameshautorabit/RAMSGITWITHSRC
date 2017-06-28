/**
	Class: CreateOrderFromCase
	Description: Creates an Order from the Case
	Test Class: 
	Author: vk@ff on 09/03/2014
**/

public without sharing class CreateOrderFromCase
{
	public RH_Order__c rho{get;Set;}
	private Id caseId;
	public Case c{get;Set;}
	public String cNum{get;Set;}
	public CreateOrderFromCase(ApexPages.StandardController controller)
	{
		c=(Case)controller.getRecord();
		caseId=c.Id;
		c=[SELECT Id, CaseNumber,RH_Order_Number__c FROM Case WHERE Id=:caseId];
		if(c!=null && c.CaseNumber!=null)
		{
			cNum=c.CaseNumber;
		}
		rho=new RH_Order__c();
	}
	
	public PageReference createOrder()
	{
		//Create the order and attach it to the case
		rho.Case__c=caseId;
		try
		{
			insert rho;	
		}
		catch(DmlException e)
		{
			System.debug(e.getMessage());
			ApexPages.addMessages(e);
			return null;
		}
		
		//Update the Order Number on the Case
		c.RH_Order_Number__c=rho.Id;
		try
		{
			update c;	
		}
		catch(DmlException e)
		{
			System.debug(e.getMessage());
			ApexPages.addMessages(e);
			return null;
		}
		return new PageReference('/'+caseId);	
	}
	
	public PageReference cancel()
	{
		return new PageReference('/'+caseId);
	}

}