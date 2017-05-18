<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ar_qa_emailalert1</fullName>
        <description>ar qa emailalert1</description>
        <protected>false</protected>
        <recipients>
            <recipient>saikumar.demo3@autorabit.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/CommunityChangePasswordEmailTemplate</template>
    </alerts>
    <fieldUpdates>
        <fullName>ar_fieldupdate1</fullName>
        <field>pp_arsf_field2__c</field>
        <name>ar fieldupdate1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ar-qa-rule1</fullName>
        <active>false</active>
        <criteriaItems>
            <field>ar_qa_accobj__c.pp_arsf_Field1__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
