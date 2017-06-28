<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Hazardous_Issue_Flag</fullName>
        <description>Updates Hazardous Issue Field when Possible Fire Issue Type field is selected</description>
        <field>Hazardous_Issue__c</field>
        <literalValue>1</literalValue>
        <name>Hazardous Issue Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Hazardous Issue Flag</fullName>
        <actions>
            <name>Hazardous_Issue_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Issue__c.Issue_Type__c</field>
            <operation>equals</operation>
            <value>Possible Fire</value>
        </criteriaItems>
        <description>Auto Updates the Hazardous Issue Flag after the record is saved, when &quot;Possible Fire&quot; is selected.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
