<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Order_Line_status_update_notification_to_owner</fullName>
        <description>Order Line status update notification to owner</description>
        <protected>false</protected>
        <recipients>
            <field>Order_Line_Update_User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Case_Templates/Order_Line_Status_Updated</template>
    </alerts>
    <rules>
        <fullName>Delight HQ Email notification</fullName>
        <actions>
            <name>Order_Line_status_update_notification_to_owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(  NOT( ISBLANK( Order_Line_Update_User__c ) ),  ISCHANGED( Line_Status_Description__c ), NOT( ISNULL( Line_Status_Description__c ) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
