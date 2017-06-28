<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Automatically_update_Contact_Info_name</fullName>
        <description>Automatically update Contact Info name</description>
        <field>Name</field>
        <formula>IF( ISBLANK (Email__c), 
 IF (ISBLANK (Phone__c), Other_Contact_Information__c,
 Phone__c), Email__c

)</formula>
        <name>Automatically update Contact Info name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Automatically update record name based on Contact Information value</fullName>
        <actions>
            <name>Automatically_update_Contact_Info_name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Automatically update record name based on Contact Information value of Phone, Email or Other Contact Information</description>
        <formula>$User.Single_View_of_Customer_Process_User__c = FALSE &amp;&amp;  ( !ISBLANK (Phone__c) || !ISBLANK (Email__c) || !ISBLANK (Other_Contact_Information__c) || ISCHANGED (Phone__c) || ISCHANGED (Email__c) || ISCHANGED (Other_Contact_Information__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
