<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_to_notify_sales_Team_when_Implementation_Questionnaire_is_created</fullName>
        <description>Email to notify sales Team when Implementation Questionnaire is created</description>
        <protected>false</protected>
        <recipients>
            <recipient>abhilash.m@autorabit.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>abhinav.s@autorabit.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>bhargavi@39demo.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>brad.b@techsophy.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>navneeth@39demo.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>paul.d@39demo.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>simon.w@autorabit.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/AutoRABIT_Implementation_Questionnaire</template>
    </alerts>
    <rules>
        <fullName>AutoRABIT - Implementation Questionnaire record is created</fullName>
        <actions>
            <name>Email_to_notify_sales_Team_when_Implementation_Questionnaire_is_created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISNEW()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
