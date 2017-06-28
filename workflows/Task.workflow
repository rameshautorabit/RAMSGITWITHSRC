<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Task_Status_Complete</fullName>
        <field>Status</field>
        <literalValue>Complete - Successful</literalValue>
        <name>Task Status Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Survey_Status</fullName>
        <field>InMoment_Survey_Status__c</field>
        <literalValue>Sent</literalValue>
        <name>Update Survey Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>SurveyRequest</fullName>
        <apiVersion>39.0</apiVersion>
        <endpointUrl>https://services.restorationhardware.com:10000/sfnotifications/inmoment</endpointUrl>
        <fields>Id</fields>
        <fields>InMoment_Associate_Email__c</fields>
        <fields>InMoment_Contact_Email_Address__c</fields>
        <fields>InMoment_Contact_First_Name__c</fields>
        <fields>InMoment_Contact_Last_Name__c</fields>
        <fields>InMoment_Contact_Record_Id__c</fields>
        <fields>InMoment_Interaction_Type__c</fields>
        <fields>InMoment_Reason__c</fields>
        <fields>InMoment_Survey_Status__c</fields>
        <fields>InMoment_Who__c</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>resto@restorationhardware.com</integrationUser>
        <name>SurveyRequest</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>SendSurvey</fullName>
        <actions>
            <name>Task_Status_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Survey_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SurveyRequest</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.RecordTypeId</field>
            <operation>equals</operation>
            <value>CSC InMoment Survey</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.InMoment_Who__c</field>
            <operation>equals</operation>
            <value>Customer,Trade Customer</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Log a Call Tasks to Complete</fullName>
        <actions>
            <name>Task_Status_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.RecordTypeId</field>
            <operation>equals</operation>
            <value>CSC InMoment Survey</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.InMoment_Who__c</field>
            <operation>notEqual</operation>
            <value>Customer</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
