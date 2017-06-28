<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Delight_HQ_Email_Notification</fullName>
        <description>Delight HQ Email Notification</description>
        <protected>false</protected>
        <recipients>
            <field>CaseOwner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Case_Templates/Order_Status_Updated</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_order_owner_that_Order_Status_has_changed</fullName>
        <description>Notification to order owner that Order Status has changed.</description>
        <protected>false</protected>
        <recipients>
            <field>Status_Update_User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Case_Templates/Order_Status_Updated</template>
    </alerts>
    <fieldUpdates>
        <fullName>EmailUpdate</fullName>
        <field>CaseOwner_Email__c</field>
        <formula>Case_Owner__c</formula>
        <name>EmailUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OrderNumberEqualExternalID</fullName>
        <description>Sets the External ID to equal the order number.</description>
        <field>EXT_Order_Number__c</field>
        <formula>Name</formula>
        <name>OrderNumberEqualExternalID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Order_Shell_Record_Type_Change</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Master</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Order Shell Record Type Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Same_Day_Order_to_Order</fullName>
        <field>Name</field>
        <formula>Same_Day_Order_Number__c</formula>
        <name>Same Day Order# to Order#</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Held</fullName>
        <description>Status = Held</description>
        <field>Status__c</field>
        <literalValue>Held</literalValue>
        <name>Status = Held</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Delight HQ Email notification-Order</fullName>
        <actions>
            <name>Delight_HQ_Email_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>EmailUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( Case__r.RecordType.Name = &apos;Delight HQ&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>High Value Order Status Updated</fullName>
        <actions>
            <name>Notification_to_order_owner_that_Order_Status_has_changed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( NOT( ISBLANK( Status_Update_User__c ) ), NOT( ISPICKVAL( Status__c,&quot;Cancelled&quot;)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Order Shell Record Type Change</fullName>
        <actions>
            <name>Order_Shell_Record_Type_Change</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>RH_Order__c.CW_Upload_DateTime__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Once an Order Shell has been updated with information from CW, the record type will change from Order Shell to Order Master.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>OrderNumberEqualExternalID</fullName>
        <actions>
            <name>OrderNumberEqualExternalID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>RH_Order__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Order Shell</value>
        </criteriaItems>
        <criteriaItems>
            <field>RH_Order__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Sets the ExternalID to the Order Number in an Order Shell.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>User or System Hold %3D Held</fullName>
        <actions>
            <name>Status_Held</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>RH_Order__c.User_Hold_Description__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>RH_Order__c.System_Hold_Description__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>When the User or System hold fields on the order object are not = to blank the status field should = Held.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
