<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Close_Case</fullName>
        <field>Status</field>
        <literalValue>Closed</literalValue>
        <name>Close Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Count_Inbound_Email_Messages</fullName>
        <field>Count_of_Inbound_Messages__c</field>
        <formula>IF(ISBLANK ( Parent.Count_of_Inbound_Messages__c ), 1, Parent.Count_of_Inbound_Messages__c + 1)</formula>
        <name>Count Inbound Email Messages</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Count_Outbound_Email_Messages</fullName>
        <field>Count_of_Outbound_Messages__c</field>
        <formula>IF(ISBLANK( Parent.Count_of_Outbound_Messages__c ), 1, Parent.Count_of_Outbound_Messages__c + 1)</formula>
        <name>Count Outbound Email Messages</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Owner_Corporate_CS_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Corporate_CS</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Owner = Corporate CS Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Owner_Custom_Product_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Custom_Products</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Owner = Custom Product Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Re_Open_Email_and_Web_Cases</fullName>
        <field>Status</field>
        <literalValue>Re-open</literalValue>
        <name>Re-Open Email and Web Cases</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Remove_Sub_Status</fullName>
        <field>Sub_Status__c</field>
        <name>Remove Sub Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Action_Required</fullName>
        <description>Setting the Action Required field to true will cause the Case to be re-opened.</description>
        <field>Action_Required__c</field>
        <literalValue>1</literalValue>
        <name>Set Action Required</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Reopen_Time</fullName>
        <field>Reopen_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Set Reopen Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sub_Status_to_30_Day_No_Reply</fullName>
        <field>Sub_Status__c</field>
        <literalValue>30 Days No Reply</literalValue>
        <name>Sub Status to 30 Day No Reply</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sub_Status</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Customer Reply Received</literalValue>
        <name>Update Sub Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Count Inbound Email Messages</fullName>
        <actions>
            <name>Count_Inbound_Email_Messages</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EmailMessage.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Count Outbound Email Messages</fullName>
        <actions>
            <name>Count_Outbound_Email_Messages</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EmailMessage.Status</field>
            <operation>equals</operation>
            <value>Sent</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>New Customer Email Received</fullName>
        <actions>
            <name>Update_Sub_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sub_Status__c</field>
            <operation>equals</operation>
            <value>Pending Customer Reply</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>EmailMessage.CreatedDate</offsetFromField>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Re-Open Corporate CS Cases</fullName>
        <actions>
            <name>Owner_Corporate_CS_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Re_Open_Email_and_Web_Cases</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Remove_Sub_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Action_Required</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Reopen_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule will re-open Corporate CS cases and assign them to their queue.</description>
        <formula>AND(   Incoming = TRUE,   Parent.IsClosed = TRUE,   OR(  ISPICKVAL( Parent.Origin, &quot;Email: RH Claims&quot;),  ISPICKVAL( Parent.Origin, &quot;Email: CSC PR&quot;),  ISPICKVAL( Parent.Origin, &quot;Email: ECR&quot;) ,   Parent.Contact.Corporate_Owned_Customer__c = TRUE) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Re-Open Custom Product Cases</fullName>
        <actions>
            <name>Owner_Custom_Product_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Re_Open_Email_and_Web_Cases</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Remove_Sub_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Action_Required</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Reopen_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email: Custom Shades,Email: Custom Windows</value>
        </criteriaItems>
        <description>This rule will re-open Custom Product cases and assign them to their queue.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Re-Open Email and Web Cases</fullName>
        <actions>
            <name>Re_Open_Email_and_Web_Cases</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Remove_Sub_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Action_Required</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Reopen_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(   Incoming = TRUE,   OR( Parent.Contact.Corporate_Owned_Customer__c = FALSE, ISBLANK(Parent.ContactId )), Parent.IsClosed = TRUE,   NOT(ISPICKVAL( Parent.Origin , &quot;Email: RH Claims&quot;)),  NOT(ISPICKVAL( Parent.Origin, &quot;Email: CSC PR&quot;)),  NOT(ISPICKVAL( Parent.Origin, &quot;Email: ECR&quot;)),   NOT(ISPICKVAL( Parent.Origin, &quot;Email: Custom Shades&quot;)),  NOT(ISPICKVAL( Parent.Origin, &quot;Email: Custom Windows&quot;)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
