<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_Customer_of_Order_Ready_for_Payment</fullName>
        <description>Notify Customer of Order Ready for Payment</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Trade_Contract/Quote_Ready_for_Payment</template>
    </alerts>
    <rules>
        <fullName>Notify Customer that Order is Ready</fullName>
        <actions>
            <name>Notify_Customer_of_Order_Ready_for_Payment</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Sent_Customer_Notification_of_Order_Ready_for_Payment</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote_Clone__c.Quote_Status__c</field>
            <operation>equals</operation>
            <value>Quote finalized - Payment Link Sent</value>
        </criteriaItems>
        <description>Sends an email notification to the customer that their order is ready for payment.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Sent_Customer_Notification_of_Order_Ready_for_Payment</fullName>
        <assignedTo>gallegard@restorationhardware.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Medium</priority>
        <protected>false</protected>
        <status>Complete - Successful</status>
        <subject>Sent Customer Notification of Order Ready for Payment</subject>
    </tasks>
</Workflow>
