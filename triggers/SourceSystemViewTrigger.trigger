trigger SourceSystemViewTrigger on Source_System_View__c (
    before insert, 
    after insert,
    before update, 
    after update) {
    SSVDomain.triggerHandler();
}