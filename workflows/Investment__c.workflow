<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>Investment Task to POD Leader</fullName>
        <actions>
            <name>Approve_Resolution</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Investment__c.RecordTypeId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <tasks>
        <fullName>Approve_Resolution</fullName>
        <assignedToType>owner</assignedToType>
        <description>Please Approve Resolution</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Please Approve Resolution</subject>
    </tasks>
</Workflow>
