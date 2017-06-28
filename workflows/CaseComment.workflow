<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Cases_New_Comment</fullName>
        <ccEmails>tgibson@rh.com</ccEmails>
        <description>Cases: New Comment</description>
        <protected>false</protected>
        <recipients>
            <recipient>Collaborator</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>jalbino@restorationhardware.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Case_Templates/Cases_New_Comment_Added</template>
    </alerts>
    <rules>
        <fullName>Cases%3A New Comment Added</fullName>
        <actions>
            <name>Cases_New_Comment</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Salesforce</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
