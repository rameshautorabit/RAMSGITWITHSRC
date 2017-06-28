<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Membership_Renewal_Expiring_CC_Email</fullName>
        <description>Membership Reminder Email</description>
        <protected>false</protected>
        <recipients>
            <field>Member_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>webcs@rh.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Membership_Reminder</template>
    </alerts>
    <alerts>
        <fullName>Send_Membership_Welcome_Email</fullName>
        <description>Send Membership Welcome Email</description>
        <protected>false</protected>
        <recipients>
            <field>Additional_Email1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Additional_Email2__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Additional_Email3__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Additional_Email4__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Additional_Email5__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Send_To_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>webcs@rh.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/RHMembershipWelcomeEmailTemplate</template>
    </alerts>
    <fieldUpdates>
        <fullName>Member_Card_Status_Card_Sent</fullName>
        <field>Member_Card_Status__c</field>
        <literalValue>Card Sent</literalValue>
        <name>Member Card Status = Card Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Member_Card_Status_Not_Scheduled</fullName>
        <field>Member_Card_Status__c</field>
        <literalValue>Not Scheduled</literalValue>
        <name>Member Card Status = Not Scheduled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Member_Card_Status_Request_Sent</fullName>
        <field>Member_Card_Status__c</field>
        <literalValue>Request Sent</literalValue>
        <name>Member Card Status = Request Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Member_Card_Status_Scheduled</fullName>
        <field>Member_Card_Status__c</field>
        <literalValue>Scheduled</literalValue>
        <name>Member Card Status = Scheduled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RRD_Status_Null</fullName>
        <field>RRD_Membership_Status__c</field>
        <name>RRD Status = Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Cancel Member Card Request</fullName>
        <actions>
            <name>Member_Card_Status_Not_Scheduled</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>RRD_Status_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Membership__c.Member_Card_Scheduled_Request_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Updates the RRD Status to null and resets the Member Card Status to &quot;Not Scheduled&quot;, when the scheduled date is cleared.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Member Card Status to Card Sent</fullName>
        <actions>
            <name>Member_Card_Status_Card_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 AND 2) OR (3 AND 4)</booleanFilter>
        <criteriaItems>
            <field>Membership__c.Member_Card_Scheduled_Request_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Membership__c.RRD_Membership_Status__c</field>
            <operation>equals</operation>
            <value>MS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Membership__c.Member_Card_Scheduled_Request_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Membership__c.Membership_Card_Ship_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Updates the Member Card Status when Mule updates the RRD Status to MS and/or the Member Card Ship Date.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Member Card Status to Request Sent</fullName>
        <actions>
            <name>Member_Card_Status_Request_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 AND 2) OR (3 AND 4)</booleanFilter>
        <criteriaItems>
            <field>Membership__c.Member_Card_Scheduled_Request_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Membership__c.RRD_Membership_Status__c</field>
            <operation>equals</operation>
            <value>MR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Membership__c.Member_Card_Scheduled_Request_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Membership__c.Member_Card_Request_Sent_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Updates the Member Card Status when Mule updates the RRD Status to MR and/or the Member Card Request Sent Date.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Member Card Status to Scheduled</fullName>
        <actions>
            <name>Member_Card_Status_Scheduled</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Member Card Status when a user updates the Member Card Scheduled Request Date.</description>
        <formula>AND(  LastModifiedBy.Username  &lt;&gt; 	&quot;mule@restorationhardware.com.pmembershi&quot;,   Member_Card_Scheduled_Request_Date__c  &gt; TODAY())</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Request Welcome Email</fullName>
        <actions>
            <name>Send_Membership_Welcome_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Welcome_Email_Requested_Datetime__c Changes</description>
        <formula>OR( ISCHANGED(Welcome_Email_Requested_Datetime__c), AND(ISNEW(), NULLVALUE(TEXT(Welcome_Email_Requested_Datetime__c),&apos;&apos;) != &apos;&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reset RRD Card Status to Null</fullName>
        <actions>
            <name>RRD_Status_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Resets the RRD Card Status to null when the status is set to MC and the Scheduled date is updated to be a future date.</description>
        <formula>AND( ISPICKVAL ( RRD_Membership_Status__c , &quot;MC&quot;), Member_Card_Scheduled_Request_Date__c &gt; TODAY())</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Membership Reminder</fullName>
        <actions>
            <name>Membership_Renewal_Expiring_CC_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>OR( ISCHANGED( Renewal_Reminder_Email_Sent_Date__c ), ISCHANGED(  Renewal_Email_Notification__c ), AND(ISNEW(), NULLVALUE(TEXT(Renewal_Reminder_Email_Sent_Date__c ),&apos;&apos;) != &apos;&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Membership Renewal Exp CC Email</fullName>
        <actions>
            <name>Membership_Renewal_Expiring_CC_Email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>OR( ISCHANGED( Renewal_Reminder_Email_Sent_Date__c ), ISCHANGED(  Renewal_Email_Notification__c ), AND(ISNEW(), NULLVALUE(TEXT(Renewal_Reminder_Email_Sent_Date__c ),&apos;&apos;) != &apos;&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
