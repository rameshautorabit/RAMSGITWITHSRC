<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>User_Gallery</fullName>
        <description>Updates the field Gallery_TEXT based on the picklist field Gallery. Used for search functionality</description>
        <field>Gallery_TEXT__c</field>
        <formula>TEXT(Gallery__c)</formula>
        <name>User Gallery</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Searchable Gallery on User</fullName>
        <actions>
            <name>User_Gallery</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.Gallery__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Only text fields can be searched for on the User record. Since we don&apos;t want users to write in the Gallery, instead they will select from a picklist also called &apos;gallery&apos;, which will then update this hidden field.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
