<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>APPROVAL_Delayed_Order_Rule</fullName>
        <description>APPROVAL: Delayed Order Rule</description>
        <protected>false</protected>
        <recipients>
            <recipient>CSC_Business_Administrators</recipient>
            <type>group</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/APPROVAL_Delay_Order_Rule</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approval_Status_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Approval Status = Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_Pending</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Pending</literalValue>
        <name>Approval Status = Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Approval Status = Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Automatic_Emails</fullName>
        <field>Automatic_Emails__c</field>
        <formula>IF(
NOT(ISBLANK(New_Automatic_Emails__c)),
New_Automatic_Emails__c,
 Automatic_Emails__c )</formula>
        <name>Update Automatic Emails</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Days_Moved_Special_Attention</fullName>
        <field>Days_Moved_Special_Attention__c</field>
        <formula>IF(
NOT(ISBLANK(New_Days_Moved_Special_Attention__c)),
New_Days_Moved_Special_Attention__c,
  Days_Moved_Special_Attention__c  )</formula>
        <name>Update Days Moved Special Attention</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Days_Moved_Threshold_In</fullName>
        <field>Days_Moved_Threshold_In__c</field>
        <formula>IF(
NOT(ISBLANK(New_Days_Moved_Threshold_In__c)),
New_Days_Moved_Threshold_In__c,
Days_Moved_Threshold_In__c  )</formula>
        <name>Update Days Moved Threshold - In</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Days_Moved_Threshold_Out</fullName>
        <field>Days_Moved_Threshold_Out__c</field>
        <formula>IF(
NOT(ISBLANK(New_Days_Moved_Threshold_Out__c)),
New_Days_Moved_Threshold_Out__c,
Days_Moved_Threshold_Out__c  )</formula>
        <name>Update Days Moved Threshold - Out</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
