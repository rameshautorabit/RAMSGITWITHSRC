<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Stewardship_Request_Closed_Successfully</fullName>
        <description>Stewardship Request Closed Successfully</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Stewardship_Messages/SR_Closed_Successful</template>
    </alerts>
    <alerts>
        <fullName>Stewardship_Request_Closed_Unsuccessfully</fullName>
        <description>Stewardship Request Closed Unsuccessfully</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Stewardship_Messages/SR_Closed_Unsuccessful</template>
    </alerts>
    <fieldUpdates>
        <fullName>Complete_time_stamp</fullName>
        <description>Complete time stamp</description>
        <field>Complete_Time_Stamp__c</field>
        <formula>NOW()</formula>
        <name>Complete time stamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>In_Review_time_stamp</fullName>
        <description>In Review time stamp</description>
        <field>In_Review_Time_Stamp__c</field>
        <formula>NOW()</formula>
        <name>In Review time stamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Owner_to_Stewardship_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Stewardship_Request_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update Owner to Stewardship Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_In_Review</fullName>
        <field>Status__c</field>
        <literalValue>In Review</literalValue>
        <name>Update Status to In Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Set Queue for New Request</fullName>
        <actions>
            <name>Update_Owner_to_Stewardship_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule assigns any new Stewardship requests to the stewardship queue</description>
        <formula>1=1</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Stewardship Request Closed Successfully</fullName>
        <actions>
            <name>Stewardship_Request_Closed_Successfully</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Stewardship_Request__c.CreatedById</field>
            <operation>notEqual</operation>
            <value>SSV Process User</value>
        </criteriaItems>
        <criteriaItems>
            <field>Stewardship_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed - Successful</value>
        </criteriaItems>
        <description>Will send an email to the request creator when requests are closed successfully.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Stewardship Request Closed Unsuccessfully</fullName>
        <actions>
            <name>Stewardship_Request_Closed_Unsuccessfully</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Stewardship_Request__c.CreatedById</field>
            <operation>notEqual</operation>
            <value>SSV Process User</value>
        </criteriaItems>
        <criteriaItems>
            <field>Stewardship_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed - Unsuccessful</value>
        </criteriaItems>
        <description>Will send an email to the request creator when requests are closed unsuccessfully.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Time stamp complete stewardship request</fullName>
        <actions>
            <name>Complete_time_stamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Stewardship_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed - Successful,Closed - Unsuccessful</value>
        </criteriaItems>
        <description>Updates the Complete Time Stamp field when Stewardship Requests are Closed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Time stamp in review stewardship request</fullName>
        <actions>
            <name>In_Review_time_stamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR (2 AND 3)</booleanFilter>
        <criteriaItems>
            <field>Stewardship_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>In Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Stewardship_Request__c.In_Review_Time_Stamp__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Stewardship_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed - Successful,Closed - Unsuccessful</value>
        </criteriaItems>
        <description>Updates the In Review Time Stamp when a request goes into the In Review status, or when the In Review Time Stamp is blank and the status is changed to Closed - Successful or Closed - Unsuccessful</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Status to In Review</fullName>
        <actions>
            <name>Update_Status_to_In_Review</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When a stewardship user accepts the request from the queue, change the Status to In Review</description>
        <formula>LEFT(PRIORVALUE(OwnerId), 3) = &quot;00G&quot; &amp;&amp; ISCHANGED(OwnerId)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
