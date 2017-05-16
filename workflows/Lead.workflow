<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Lead_is_Converted</fullName>
        <description>Lead is Converted</description>
        <protected>false</protected>
        <recipients>
            <recipient>abhilash.m@autorabit.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>brad.b@techsophy.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>niranjan.g@39demo.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>simon.w@autorabit.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>sales@autorabit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Test_Convert</template>
    </alerts>
    <alerts>
        <fullName>New_Lead_Notification</fullName>
        <ccEmails>prashanth.s@autorabit.com</ccEmails>
        <description>New Lead Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>brad.b@techsophy.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>navneeth@39demo.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>niranjan.g@39demo.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/New_Lead_Notification</template>
    </alerts>
    <rules>
        <fullName>AutoRABIT - Lead Conversion Notification</fullName>
        <actions>
            <name>Lead_is_Converted</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.IsConverted</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.RecordTypeId</field>
            <operation>equals</operation>
            <value>AutoRABIT RecordType</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AutoRABIT - New Lead Notification</fullName>
        <actions>
            <name>New_Lead_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This Sends an email when New lead is created</description>
        <formula>AND(ISNEW(), RecordType.DeveloperName = &apos;AutoRABIT_RecordType&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
