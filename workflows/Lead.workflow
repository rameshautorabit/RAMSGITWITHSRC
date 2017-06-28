<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Auto_send_followup_email_to_primary_Lead_s_email_address</fullName>
        <description>Auto-send followup email to primary Lead&apos;s email address</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>contractprojects@restorationhardware.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Trade_Contract/Primary_Project_Follow_up</template>
    </alerts>
    <rules>
        <fullName>Auto-send followup email to primary Lead%27s email address</fullName>
        <actions>
            <name>Auto_send_followup_email_to_primary_Lead_s_email_address</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.LeadSource</field>
            <operation>equals</operation>
            <value>Cust Initiated</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Segment__c</field>
            <operation>notEqual</operation>
            <value>Custom Builder,Multi-Family Residential Developer</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Email</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
