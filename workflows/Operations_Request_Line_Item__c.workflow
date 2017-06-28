<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Square_Feet_with_Yardage_Formula</fullName>
        <field>Square_Feet__c</field>
        <formula>Yardage__c  *18</formula>
        <name>Update Square Feet with Yardage Formula</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Yardage_with_Square_Feet_Formula</fullName>
        <field>Yardage__c</field>
        <formula>Square_Feet__c* 0.1</formula>
        <name>Update Yardage with Square Feet Formula</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Square Feet is not blank</fullName>
        <actions>
            <name>Update_Yardage_with_Square_Feet_Formula</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Rule triggers if there is a value in the Square Feet field</description>
        <formula>NOT(ISBLANK( Square_Feet__c ))  &amp;&amp;  ISCHANGED( Square_Feet__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Yardage is not blank</fullName>
        <actions>
            <name>Update_Square_Feet_with_Yardage_Formula</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISBLANK( Yardage__c )) &amp;&amp;   ISCHANGED(Yardage__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
