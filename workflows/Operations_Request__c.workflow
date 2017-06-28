<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CORT_Follow_up_with_vendor</fullName>
        <description>CORT Follow up with vendor</description>
        <protected>false</protected>
        <recipients>
            <recipient>kschwach@restorationhardware.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Trade_Contract/CORT_follow_up_w_vendor</template>
    </alerts>
    <alerts>
        <fullName>Operations_Request_Approved_By_Customer</fullName>
        <description>Operations Request Approved By Customer</description>
        <protected>false</protected>
        <recipients>
            <recipient>Contract_Operations</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Operations_Request_Approved_By_Customer</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approval_Status_to_Kesha</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Kesha Weldon</literalValue>
        <name>Approval Status to Kesha</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_to_Logistics</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Logistics Operations</literalValue>
        <name>Approval Status to Logistics</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_to_PM</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Back to PM</literalValue>
        <name>Approval Status to PM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_to_Planning</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Planning Operations</literalValue>
        <name>Approval Status to Planning</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_to_Executive</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Executive Approval</literalValue>
        <name>Approval to Executive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_to_Product</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Product Operations</literalValue>
        <name>Approval to Product</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_owner_to_KB</fullName>
        <field>OwnerId</field>
        <lookupValue>kbarry@restorationhardware.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Change owner to KB</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_owner_to_KS</fullName>
        <field>OwnerId</field>
        <lookupValue>kschwach@restorationhardware.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Change owner to KS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Request_Completed_Date</fullName>
        <field>Request_Completed_Date__c</field>
        <name>Clear Request Completed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Customer_Accepted</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Customer Accepted</literalValue>
        <name>Customer Accepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Customer_Declined</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Customer Declined</literalValue>
        <name>Customer Declined</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reassign_to_Logistics_Operations_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Logistics_Operations</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Reassign to Logistics Operations Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reassign_to_Planning_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Planning_Operations</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Reassign to Planning Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reassign_to_Product_Operations_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Product_Operations</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Reassign to Product Operations Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Submit_Back_to_No</fullName>
        <field>Submit__c</field>
        <literalValue>No</literalValue>
        <name>Set Submit Back to No</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_to_Closed</fullName>
        <field>Status__c</field>
        <literalValue>Closed</literalValue>
        <name>Status to Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_to_In_Progress</fullName>
        <field>Status__c</field>
        <literalValue>In Progress</literalValue>
        <name>Status to In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Time_Stamp_Completed_Date</fullName>
        <field>Request_Completed_Date__c</field>
        <formula>NOW()</formula>
        <name>Time Stamp Completed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status_to_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Customer Accepted</literalValue>
        <name>Update Approval Status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status_to_Denied</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Customer Declined</literalValue>
        <name>Update Approval Status to Denied</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status_to_Denied1</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Denied</literalValue>
        <name>Update Approval Status to Denied</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status_to_Recalled</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Recalled</literalValue>
        <name>Update Approval Status to Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status_to_Submitted</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Update Approval Status to Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Closed</fullName>
        <field>Status__c</field>
        <literalValue>Closed</literalValue>
        <name>Update Status to Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Customer_Accepted</fullName>
        <field>Status__c</field>
        <literalValue>Customer Accepted</literalValue>
        <name>Update Status to Customer Accepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Customer_Declined</fullName>
        <field>Status__c</field>
        <literalValue>Customer Declined</literalValue>
        <name>Update Status to Customer Declined</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Submit_to_Yes</fullName>
        <field>Submit__c</field>
        <literalValue>Yes</literalValue>
        <name>Update Submit to Yes</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Domestic Freight Quote Approved</fullName>
        <actions>
            <name>Change_owner_to_KB</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Operations_Request__c.Submit__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Operations_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Freight Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Operations_Request__c.Type__c</field>
            <operation>equals</operation>
            <value>Expedite Domestic</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Freight Quote Declined</fullName>
        <actions>
            <name>Status_to_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Operations_Request__c.Freight_Quote_Status__c</field>
            <operation>equals</operation>
            <value>Declined</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Is Operations Request tied to an Oppty</fullName>
        <actions>
            <name>Please_associate_this_record_with_an_Opportunity</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Operations_Request__c.Oppty_Number__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Model Room Sample Follow Up2</fullName>
        <actions>
            <name>Follow_up_with_factory</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Operations_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Custom Product</value>
        </criteriaItems>
        <criteriaItems>
            <field>Operations_Request__c.Type__c</field>
            <operation>equals</operation>
            <value>Model Room Sample</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Operations Request Approved By Customer</fullName>
        <actions>
            <name>Operations_Request_Approved_By_Customer</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Operations_Request__c.Notify_Ops__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Reassign to Logistics Operations Queue</fullName>
        <actions>
            <name>Reassign_to_Logistics_Operations_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Submit_Back_to_No</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Status_to_In_Progress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Operations_Request__c.Submit__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Operations_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>POD,Side Mark,DC Pickup,Vendor Air Freight</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Reassign to Planning Operations Queue</fullName>
        <actions>
            <name>Reassign_to_Planning_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Submit_Back_to_No</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Status_to_In_Progress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Operations_Request__c.Submit__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Operations_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>SKU Setup,Inventory Request,Margin Request,SPO Quote</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reassign to Product Operations Queue</fullName>
        <actions>
            <name>Reassign_to_Product_Operations_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Submit_Back_to_No</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Status_to_In_Progress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Operations_Request__c.Submit__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Operations_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Custom Product,COM/COL,Product Information,Spec Sheet,&quot;Swatches, Fabrics &amp; Finishes&quot;</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SPO Quote or SKU Setup Sample Follow Up</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Operations_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>SKU Setup,SPO Quote</value>
        </criteriaItems>
        <criteriaItems>
            <field>Operations_Request__c.Vendor_Request_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>CORT_Follow_up_with_vendor</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Follow_up_with_vendor</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Operations_Request__c.Vendor_Request_Date__c</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Time Stamp Ops Request Date%2FTime</fullName>
        <actions>
            <name>Time_Stamp_Completed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(Status__c) &amp;&amp;  ISPICKVAL(Status__c, &quot;Closed&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>Follow_up_with_factory</fullName>
        <assignedTo>yali1@restorationhardware.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>Click link on Operations Request link to see Project/Oppty Details.</description>
        <dueDateOffset>-28</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Operations_Request__c.Product_Handover_Date__c</offsetFromField>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Follow up with factory</subject>
    </tasks>
    <tasks>
        <fullName>Follow_up_with_vendor</fullName>
        <assignedTo>kschwach@restorationhardware.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>Click link on Operations Request link</description>
        <dueDateOffset>-2</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Operations_Request__c.Vendor_Request_Date__c</offsetFromField>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Follow up with vendor</subject>
    </tasks>
    <tasks>
        <fullName>Please_associate_this_record_with_an_Opportunity</fullName>
        <assignedToType>owner</assignedToType>
        <description>When this request was created it was not associated with an Opportunity. Please link this request by updating the Opportunity/Project field and mark this task as complete.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Please associate this record with an Opportunity</subject>
    </tasks>
</Workflow>
