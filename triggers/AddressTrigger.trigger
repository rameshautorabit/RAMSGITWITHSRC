trigger AddressTrigger on Address__c (
		before insert, 
		before update, 
		before delete, 
		after insert, 
		after update, 
		after delete, 
		after undelete) {
	SObjectDomain.domainTriggerHandler(new Addresses());
}