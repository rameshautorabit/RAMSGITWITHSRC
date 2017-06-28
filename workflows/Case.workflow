<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Cases_New_SFDC_Project_Request</fullName>
        <ccEmails>tgibson@rh.com</ccEmails>
        <description>Cases: New SFDC Project/Request</description>
        <protected>false</protected>
        <recipients>
            <recipient>Collaborator</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>jalbino@restorationhardware.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Case_Templates/Cases_New_SFDC_Project_Request</template>
    </alerts>
    <alerts>
        <fullName>CreditCardDecline</fullName>
        <description>CreditCardDecline</description>
        <protected>false</protected>
        <recipients>
            <field>To_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>webcs@rh.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/CreditCardDecline</template>
    </alerts>
    <alerts>
        <fullName>CreditCardDecline_Contract</fullName>
        <description>CreditCardDecline_Contract</description>
        <protected>false</protected>
        <recipients>
            <field>To_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>jwarner2@rh.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/CreditCardDecline</template>
    </alerts>
    <alerts>
        <fullName>DelayNotification_RH</fullName>
        <description>DelayNotification - RH</description>
        <protected>false</protected>
        <recipients>
            <field>To_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>webcs@rh.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/DelayNotification</template>
    </alerts>
    <alerts>
        <fullName>DelayNotification_RH_Baby_Child</fullName>
        <description>DelayNotification - RH Baby &amp; Child</description>
        <protected>false</protected>
        <recipients>
            <field>To_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>babyandchild@rh.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/DelayNotification</template>
    </alerts>
    <alerts>
        <fullName>DelayNotification_RH_Baby_Child_Internal</fullName>
        <description>DelayNotification - RH Baby &amp; Child - Internal</description>
        <protected>false</protected>
        <recipients>
            <field>Order_Notification_Visibility__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>babyandchild@rh.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/DelayNotification</template>
    </alerts>
    <alerts>
        <fullName>DelayNotification_RH_Contract</fullName>
        <description>DelayNotification - RH Contract</description>
        <protected>false</protected>
        <recipients>
            <field>To_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/DelayNotification</template>
    </alerts>
    <alerts>
        <fullName>DelayNotification_RH_Contract_Internal</fullName>
        <description>DelayNotification - RH Contract - Internal</description>
        <protected>false</protected>
        <recipients>
            <field>Order_Notification_Visibility__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/DelayNotification</template>
    </alerts>
    <alerts>
        <fullName>DelayNotification_RH_Internal</fullName>
        <description>DelayNotification - RH - Internal</description>
        <protected>false</protected>
        <recipients>
            <field>Order_Notification_Visibility__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>webcs@rh.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/DelayNotification</template>
    </alerts>
    <alerts>
        <fullName>DelayNotification_RH_Teen</fullName>
        <description>DelayNotification - RH Teen</description>
        <protected>false</protected>
        <recipients>
            <field>To_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>rhteen@rh.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/DelayNotification</template>
    </alerts>
    <alerts>
        <fullName>DelayNotification_RH_Teen_Internal</fullName>
        <description>DelayNotification - RH Teen - Internal</description>
        <protected>false</protected>
        <recipients>
            <field>Order_Notification_Visibility__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>rhteen@rh.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/DelayNotification</template>
    </alerts>
    <alerts>
        <fullName>Exch_Approval_Approved</fullName>
        <description>Exch Approval - Approved</description>
        <protected>false</protected>
        <recipients>
            <field>Gallery_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Exch_Approval_Approved</template>
    </alerts>
    <alerts>
        <fullName>Exch_Approval_Recalled</fullName>
        <description>Exch Approval - Recalled</description>
        <protected>false</protected>
        <recipients>
            <field>Gallery_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Exch_Approval_Recalled</template>
    </alerts>
    <alerts>
        <fullName>Exch_Approval_Rejected</fullName>
        <description>Exch Approval - Rejected</description>
        <protected>false</protected>
        <recipients>
            <field>Gallery_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Exch_Approval_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Exch_Approval_Submitted</fullName>
        <description>Exch Approval - Submitted</description>
        <protected>false</protected>
        <recipients>
            <field>Gallery_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Exch_Approval_Submitted</template>
    </alerts>
    <alerts>
        <fullName>New_Email_Received_Alert</fullName>
        <description>New Email Received Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Case_Templates/New_Customer_Reply_Received</template>
    </alerts>
    <alerts>
        <fullName>ReturnReceipt_RH</fullName>
        <description>ReturnReceipt - RH</description>
        <protected>false</protected>
        <recipients>
            <field>To_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>webcs@rh.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/ReturnReceipt</template>
    </alerts>
    <alerts>
        <fullName>ReturnReceipt_RH_Baby_Child</fullName>
        <description>ReturnReceipt - RH Baby &amp; Child</description>
        <protected>false</protected>
        <recipients>
            <field>To_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>babyandchild@rh.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/ReturnReceipt</template>
    </alerts>
    <alerts>
        <fullName>ReturnReceipt_RH_Teen</fullName>
        <description>ReturnReceipt - RH Teen</description>
        <protected>false</protected>
        <recipients>
            <field>To_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>rhteen@rh.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/ReturnReceipt</template>
    </alerts>
    <fieldUpdates>
        <fullName>Accommodation_Sub_Reason_Business</fullName>
        <field>Accommodation_Sub_Reason__c</field>
        <literalValue>Business</literalValue>
        <name>Accommodation Sub-Reason: Business</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Accommodation_Sub_Reason_Customer</fullName>
        <field>Accommodation_Sub_Reason__c</field>
        <literalValue>Customer</literalValue>
        <name>Accommodation Sub-Reason: Customer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ActionRequiredFalse</fullName>
        <description>Sets action required to false</description>
        <field>Action_Required__c</field>
        <literalValue>0</literalValue>
        <name>ActionRequiredFalse</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AttemptedContactCount</fullName>
        <description>Updates the field to add 1.</description>
        <field>Attempted_Contact__c</field>
        <formula>Attempted_Contact__c + 1</formula>
        <name>AttemptedContactCount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BlankFutureProcessingDate</fullName>
        <description>Blanks the future processing date if the future processing field is false.</description>
        <field>Future_Processing_Date__c</field>
        <name>BlankFutureProcessingDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BlankTo</fullName>
        <description>Blanks the To field</description>
        <field>To__c</field>
        <name>BlankTo</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCDAttemptedContact1</fullName>
        <description>Sets the future processing date to today + 2.</description>
        <field>Future_Processing_Date__c</field>
        <formula>TODAY()+2</formula>
        <name>CCDAttemptedContact1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCDAttemptedContact2</fullName>
        <description>Sets future processing date to Today + 2</description>
        <field>Future_Processing_Date__c</field>
        <formula>TODAY()+2</formula>
        <name>CCDAttemptedContact2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCDAttemptedContact3</fullName>
        <description>Sets the future processing date to today + 5.</description>
        <field>Future_Processing_Date__c</field>
        <formula>TODAY() + 5</formula>
        <name>CCDAttemptedContact3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSC_Transfer_Date</fullName>
        <field>CSC_Queue_Transfer__c</field>
        <formula>TODAY()</formula>
        <name>CSC Transfer Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ClearCaseAssignment</fullName>
        <field>CaseAssignment__c</field>
        <literalValue>0</literalValue>
        <name>ClearCaseAssignment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ClearInterimUpdate</fullName>
        <field>Interim_Update__c</field>
        <name>ClearInterimUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_AccommodationGreaterThanTotal</fullName>
        <field>Accommodation_Is_Greater_Than_Total__c</field>
        <literalValue>0</literalValue>
        <name>Clear AccommodationGreaterThanTotal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Email_Alert_Trigger</fullName>
        <field>Email_Alert_Trigger__c</field>
        <literalValue>0</literalValue>
        <name>Clear Email Alert Trigger</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Exchange_Approval_Required</fullName>
        <field>Exchange_Approval_Required__c</field>
        <literalValue>0</literalValue>
        <name>Clear Exchange Approval Required</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Rejection_Reason</fullName>
        <field>Exchange_Approval_Rejection_Reason__c</field>
        <name>Clear Rejection Reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ContactDateCommunicated</fullName>
        <field>Interim_Update__c</field>
        <literalValue>Contact Date Communicated</literalValue>
        <name>ContactDateCommunicated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Count_Case_Owners</fullName>
        <field>Count_of_Case_Owners__c</field>
        <formula>IF(
BEGINS(OwnerId, &quot;005&quot;),
Count_of_Case_Owners__c + 1,
Count_of_Case_Owners__c
)</formula>
        <name>Count Case Owners</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Count_Queue_Owners</fullName>
        <field>Count_of_Queue_Owners__c</field>
        <formula>IF( 
BEGINS(OwnerId, &quot;00G&quot;), 
Count_of_Queue_Owners__c + 1,
Count_of_Queue_Owners__c
)</formula>
        <name>Count Queue Owners</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CreditCardDeclineFutureProcessing</fullName>
        <description>Adds 2 days to the future processing date after the initial credit card decline email is sent out</description>
        <field>Future_Processing_Date__c</field>
        <formula>TODAY() + 2</formula>
        <name>CreditCardDeclineFutureProcessing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CreditCardDeclineStatus</fullName>
        <description>Update Status after auto-email sent.</description>
        <field>Status</field>
        <literalValue>Transfer</literalValue>
        <name>CreditCardDeclineStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CreditCardDeclineTo</fullName>
        <description>Updates To Field to Order Processing after the auto-email is sent.</description>
        <field>To__c</field>
        <literalValue>Order Processing</literalValue>
        <name>CreditCardDeclineTo</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Exch_Approved</fullName>
        <field>Exchange_Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Exch Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Exch_Pending</fullName>
        <field>Exchange_Approval_Status__c</field>
        <literalValue>Pending</literalValue>
        <name>Exch Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Exch_Recalled</fullName>
        <field>Exchange_Approval_Status__c</field>
        <literalValue>Recalled</literalValue>
        <name>Exch Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Exch_Rejected</fullName>
        <field>Exchange_Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Exch Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FutureProcessingFive</fullName>
        <description>Today + 5</description>
        <field>Future_Processing_Date__c</field>
        <formula>TODAY()+5</formula>
        <name>FutureProcessingFive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FutureProcessingTomorrow</fullName>
        <field>Future_Processing_Date__c</field>
        <formula>TODAY() +1</formula>
        <name>FutureProcessingTomorrow</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Future_Processing_Checkbox_Removal</fullName>
        <field>Future_Processing__c</field>
        <literalValue>0</literalValue>
        <name>Future Processing Checkbox Removal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Future_Processing_Checkbox_Update</fullName>
        <field>Future_Processing__c</field>
        <literalValue>1</literalValue>
        <name>Future Processing Checkbox Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>InProgressTeam</fullName>
        <description>Updates In Progress Team to the team that is working on the case while the status is in progress</description>
        <field>In_Progress_Team__c</field>
        <formula>IF(
OR(
ISPICKVAL(Status, &quot;Callout Team&quot;),
ISPICKVAL(Status, &quot;Tier 2&quot;)
),
TEXT(Status),
TEXT(To__c)
)</formula>
        <name>InProgressTeam</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OI_Record_Type_is_Department</fullName>
        <field>Queue_Type__c</field>
        <literalValue>Order Inquiries</literalValue>
        <name>OI - Record Type is Department</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Owner_Quality_Gatekeeper</fullName>
        <description>Change owner = quality gatekeeper</description>
        <field>OwnerId</field>
        <lookupValue>Quality_Gatekeeper</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Owner = Quality Gatekeeper</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Owner_Resto_Service</fullName>
        <field>OwnerId</field>
        <lookupValue>resto@restorationhardware.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Owner = Resto Service</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PriorityYes</fullName>
        <field>Priority</field>
        <literalValue>Yes</literalValue>
        <name>PriorityYes</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ReadyforCallout</fullName>
        <field>Interim_Update__c</field>
        <literalValue>Ready for Callout</literalValue>
        <name>ReadyforCallout</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Remove_Warning</fullName>
        <field>Warning__c</field>
        <literalValue>0</literalValue>
        <name>Remove Warning</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reorders_Status_Tier_2</fullName>
        <field>Status</field>
        <literalValue>Tier 2</literalValue>
        <name>Reorders Status Tier 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reorders_Status_Tier_3</fullName>
        <field>Status</field>
        <literalValue>Tier 3</literalValue>
        <name>Reorders Status Tier 3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ResetByPassValidationRuleField</fullName>
        <field>ByPassValidationRule__c</field>
        <literalValue>0</literalValue>
        <name>ResetByPassValidationRuleField</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ResetStopMilestone</fullName>
        <field>Stop_Milestone__c</field>
        <literalValue>0</literalValue>
        <name>ResetStopMilestone</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Send_To_Existing_Sold_To</fullName>
        <field>Send_To__c</field>
        <literalValue>Sold To</literalValue>
        <name>Send To Existing Sold To</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Send_To_New_Address</fullName>
        <field>Send_To__c</field>
        <literalValue>Send To Address</literalValue>
        <name>Send To New Address</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_AccommodationGreaterThanTotal</fullName>
        <field>Accommodation_Is_Greater_Than_Total__c</field>
        <literalValue>1</literalValue>
        <name>Set AccommodationGreaterThanTotal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Date_Time_Delight_Plan_in_Place</fullName>
        <field>Delight_Plan_in_Place_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Set Date/Time Delight Plan in Place</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_In_Progress_Time</fullName>
        <field>In_Progress_Start_Time__c</field>
        <formula>NOW()</formula>
        <name>Set In Progress Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Original_Owner</fullName>
        <field>Original_Owner__c</field>
        <formula>Owner:User.FirstName &amp;&apos; &apos;&amp; Owner:User.LastName</formula>
        <name>Set Original Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Pending_Customer_Reply_Date</fullName>
        <field>Date_in_Pending_Customer_Reply__c</field>
        <formula>TODAY()</formula>
        <name>Set Pending Customer Reply Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Ship_Via_Change_Checkbox</fullName>
        <field>Ship_Via_Change__c</field>
        <literalValue>1</literalValue>
        <name>Ship Via Change Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Ship_Via_Change_Checkbox_False</fullName>
        <field>Ship_Via_Change__c</field>
        <literalValue>0</literalValue>
        <name>Ship Via Change Checkbox False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Ship_Via_Change_Checkbox_True</fullName>
        <field>Ship_Via_Change__c</field>
        <literalValue>1</literalValue>
        <name>Ship Via Change Checkbox True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Ship_Via_Change_Code_Clear</fullName>
        <description>Clear field &apos;Enter Code for Ship Via Change&apos;</description>
        <field>Enter_Code_for_Ship_Via_Change__c</field>
        <name>Ship Via Change Code Clear</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>StatusTransfer</fullName>
        <description>Update Status after auto-email sent.</description>
        <field>Status</field>
        <literalValue>Transfer</literalValue>
        <name>StatusTransfer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>StopMilestone</fullName>
        <field>Stop_Milestone__c</field>
        <literalValue>1</literalValue>
        <name>StopMilestone</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sub_Status_Returns_CSC</fullName>
        <field>Sub_Status__c</field>
        <literalValue>In Progress - Returns - CSC</literalValue>
        <name>Sub Status Returns CSC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sub_Status_Returns_Gallery</fullName>
        <field>Sub_Status__c</field>
        <literalValue>In Progress - Returns - Gallery</literalValue>
        <name>Sub Status Returns Gallery</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Success_Update1</fullName>
        <field>Milestone_Status__c</field>
        <formula>IF(PRIORVALUE(Milestone_Status__c)=&quot;Open Violation&quot;, &quot;Closed Violation&quot;,&quot;Completed&quot;)</formula>
        <name>Success Update 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ToOrderProcessing</fullName>
        <description>Updates To Field to Order Processing after the auto-email is sent.</description>
        <field>To__c</field>
        <literalValue>Order Processing</literalValue>
        <name>ToOrderProcessing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Owner</fullName>
        <field>OwnerId</field>
        <lookupValue>RH_Email_Advocates</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update Case Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Milestone_Violated_Field</fullName>
        <field>Milestone_Violated__c</field>
        <literalValue>1</literalValue>
        <name>Update Milestone Violated Field 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Queue_to_Order_Processing</fullName>
        <description>Routes credit card declines with no Sold To email addresses to the Order Processing queue.</description>
        <field>To__c</field>
        <literalValue>Order Processing</literalValue>
        <name>Update Queue to Order Processing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status</fullName>
        <field>Status</field>
        <literalValue>In Progress</literalValue>
        <name>Update Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Transfer</fullName>
        <description>Updates the status of credit card declines with no Sold To email addresses to the Transfer.</description>
        <field>Status</field>
        <literalValue>Transfer</literalValue>
        <name>Update Status to Transfer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Violation_Update1</fullName>
        <field>Milestone_Status__c</field>
        <formula>&quot;Open Violation&quot;</formula>
        <name>Violation Update 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>WaitingforPlanning</fullName>
        <field>Interim_Update__c</field>
        <literalValue>Waiting for Planning</literalValue>
        <name>WaitingforPlanning</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Warning2</fullName>
        <field>Milestone_Status__c</field>
        <formula>&quot;Warning&quot;</formula>
        <name>Warning 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>Delayed_Order_Gift_Card</fullName>
        <apiVersion>36.0</apiVersion>
        <description>Message sent to CW via Mule to create a new Gift Card in CW for a specific Order.</description>
        <endpointUrl>https://services.restorationhardware.com:10000/lightning/soap/gcaccom</endpointUrl>
        <fields>Acc_Address_1__c</fields>
        <fields>Acc_Address_2__c</fields>
        <fields>Acc_Address_Type__c</fields>
        <fields>Acc_City__c</fields>
        <fields>Acc_Company__c</fields>
        <fields>Acc_Country_Code__c</fields>
        <fields>Acc_Email__c</fields>
        <fields>Acc_Expiration__c</fields>
        <fields>Acc_First_Name__c</fields>
        <fields>Acc_Last_Name__c</fields>
        <fields>Acc_Postal_Code__c</fields>
        <fields>Acc_Requesting_User__c</fields>
        <fields>Acc_State__c</fields>
        <fields>Acc_Type__c</fields>
        <fields>Actual_Gift_Card_Amount__c</fields>
        <fields>CaseNumber</fields>
        <fields>EXT_Order_Number__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>resto@restorationhardware.com</integrationUser>
        <name>Delayed Order Gift Card</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>OutboundMessage_OnChange_Of_Owner_Status</fullName>
        <apiVersion>36.0</apiVersion>
        <endpointUrl>https://services.restorationhardware.com:10000/sfnotifications/orderDelight</endpointUrl>
        <fields>CaseNumber</fields>
        <fields>Case_Order__c</fields>
        <fields>Id</fields>
        <fields>Number_of_Ship_Tos__c</fields>
        <fields>On_Fire_Indicator__c</fields>
        <fields>Owner__c</fields>
        <fields>Record_Type_Dev_Name__c</fields>
        <fields>Status</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>resto@restorationhardware.com</integrationUser>
        <name>OutboundMessage OnChange Of Owner/Status</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>RHOM_Delivering_on_Delight_On_Fire_Updat</fullName>
        <apiVersion>36.0</apiVersion>
        <endpointUrl>https://services.restorationhardware.com:10000/sfnotifications/orderDelight</endpointUrl>
        <fields>CaseNumber</fields>
        <fields>Case_Order__c</fields>
        <fields>Id</fields>
        <fields>Number_of_Ship_Tos__c</fields>
        <fields>On_Fire_Indicator__c</fields>
        <fields>Owner__c</fields>
        <fields>Record_Type_Dev_Name__c</fields>
        <fields>Status</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>resto@restorationhardware.com</integrationUser>
        <name>RHOM Delivering on Delight On Fire Upd</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>RHOM_ON_FIRE</fullName>
        <apiVersion>36.0</apiVersion>
        <description>This would send an outbound message to Mule</description>
        <endpointUrl>https://services.restorationhardware.com:10000/sfnotifications/orderDelight</endpointUrl>
        <fields>CaseNumber</fields>
        <fields>Case_Order__c</fields>
        <fields>Id</fields>
        <fields>Number_of_Ship_Tos__c</fields>
        <fields>On_Fire_Indicator__c</fields>
        <fields>Owner__c</fields>
        <fields>Record_Type_Dev_Name__c</fields>
        <fields>Status</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>resto@restorationhardware.com</integrationUser>
        <name>RHOM ON FIRE</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>RHOM_On_Fire_Outbound_Message</fullName>
        <apiVersion>36.0</apiVersion>
        <endpointUrl>https://services.restorationhardware.com:10000/sfnotifications/orderDelight</endpointUrl>
        <fields>CaseNumber</fields>
        <fields>Case_Order__c</fields>
        <fields>Id</fields>
        <fields>Number_of_Ship_Tos__c</fields>
        <fields>On_Fire_Indicator__c</fields>
        <fields>Owner__c</fields>
        <fields>Record_Type_Dev_Name__c</fields>
        <fields>Status</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>resto@restorationhardware.com</integrationUser>
        <name>RHOM On Fire Outbound Message</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>AccStopMilestone</fullName>
        <actions>
            <name>StopMilestone</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Transfer</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.To__c</field>
            <operation>equals</operation>
            <value>Accommodations</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Accommodations</value>
        </criteriaItems>
        <description>Stops a milestone if the status is changed back to &quot;Transfer&quot; to &quot;Accommodations.&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Accommodation Reason - Business Sub Reason</fullName>
        <actions>
            <name>Accommodation_Sub_Reason_Business</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 or 2 or 3</booleanFilter>
        <criteriaItems>
            <field>Case.Accommodation_Reason__c</field>
            <operation>equals</operation>
            <value>Freight - Canadian Adjustment/Refund,Freight - US Adjustment/Refund,Gift Box Fee Refund,Out Of Policy Return,Personalization Fee Refund,Pre-Bill Refund,Price Match – Sale/Promo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Accommodation_Reason__c</field>
            <operation>equals</operation>
            <value>Refund for GC/SC/Reward MOP,Reissue System Refund – Incorrect/Cancelled/Did Not Generate,Tax Refund</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Accommodation_Reason__c</field>
            <operation>equals</operation>
            <value>Balance Transfer,Gift Return,Manual Charge</value>
        </criteriaItems>
        <description>Have accommodation sub-reason default into a particular selection based on selection for reason.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Accommodation Reason - Customer Sub Reason</fullName>
        <actions>
            <name>Accommodation_Sub_Reason_Customer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Accommodation_Reason__c</field>
            <operation>equals</operation>
            <value>Carrier Caused - HDL,Carrier Caused - UPS,Customer Experience,Damaged/Defective Product,Delay - Backorder,Delay - DC,Delay - Vendor,Freight - Flat Rate Delivery Fee Refund</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Accommodations - Default Send To Based on Order%23</fullName>
        <actions>
            <name>Send_To_Existing_Sold_To</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(ISPICKVAL(Queue_Type__c, &quot;Accommodations&quot;), NOT(ISBLANK( RH_Order_Number__c )) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ActionRequiredPrioirtyYes</fullName>
        <actions>
            <name>PriorityYes</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Action_Required__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Case to RH Email</fullName>
        <actions>
            <name>Update_Case_Owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Mule API User</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Email and Web Inquiries</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BackordersFutureProcessing</fullName>
        <actions>
            <name>FutureProcessingTomorrow</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Backorders</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Call_Outcome__c</field>
            <operation>equals</operation>
            <value>Could Not Reach</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BackordersToOrderProcessing</fullName>
        <actions>
            <name>StatusTransfer</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ToOrderProcessing</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Backorders</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <description>NO LONGER NECESSARY - this must be handled with code.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BlankToIfNotTransfer</fullName>
        <actions>
            <name>BlankTo</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Transfer,Warm Transfer</value>
        </criteriaItems>
        <description>Blank the &quot;To&quot; field if the status is not transfer or warm transfer.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CCD Initialize - Sold To email missing</fullName>
        <actions>
            <name>Update_Queue_to_Order_Processing</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Status_to_Transfer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>CCD Cases are created from the API feed. Upon creation of a CCD case, if no Sold To email exists, the case gets routed to the Order Processing queue.</description>
        <formula>AND(RecordType.DeveloperName  = &quot;Credit_Card_Declines&quot;,  ISBLANK( Sold_to_Email__c) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CCDContact1FP</fullName>
        <actions>
            <name>CCDAttemptedContact1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Credit Card Declines</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Attempted_Contact__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Call_Outcome__c</field>
            <operation>equals</operation>
            <value>Could Not Reach,Left Voicemail,Sent Email</value>
        </criteriaItems>
        <description>Sets the future processing date to today + 2 for the first Attempted Contact.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCDContact2FP</fullName>
        <actions>
            <name>CCDAttemptedContact2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Credit Card Declines</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Attempted_Contact__c</field>
            <operation>equals</operation>
            <value>2</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Call_Outcome__c</field>
            <operation>equals</operation>
            <value>Could Not Reach,Left Voicemail,Sent Email</value>
        </criteriaItems>
        <description>Sets the future processing date to today + 2 for the second Attempted Contact.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCDContact3FP</fullName>
        <actions>
            <name>CCDAttemptedContact3</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Credit Card Declines</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Attempted_Contact__c</field>
            <operation>equals</operation>
            <value>3</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Call_Outcome__c</field>
            <operation>equals</operation>
            <value>Could Not Reach,Left Voicemail,Sent Email</value>
        </criteriaItems>
        <description>Sets the future processing date to today + 5 for the third Attempted Contact.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCDStopMilestone</fullName>
        <actions>
            <name>StopMilestone</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>3 and ((1 and 2) or 4)</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Transfer</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.To__c</field>
            <operation>equals</operation>
            <value>Order Processing</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Credit Card Declines</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Release Order</value>
        </criteriaItems>
        <description>Stops a milestone if the status is changed back to &quot;Transfer&quot; to &quot;Order Processing&quot; or &quot;Release Order.&quot;</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CSC Transfer Tracking</fullName>
        <actions>
            <name>CSC_Transfer_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Returns</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>RHD Returns Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CSC_Queue_Transfer__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Status to In Progress</fullName>
        <actions>
            <name>Set_In_Progress_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Original_Owner</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the case status to &quot;In Progress&quot; when advocates take ownership of cases with emails.</description>
        <formula>AND(  OR( BEGINS(TEXT( Origin ),&quot;Email:&quot;), BEGINS(TEXT( Origin ),&quot;Web:&quot;)),  ISPICKVAL( Status , &quot;New&quot;),  AND(  Owner__c  &lt;&gt; &quot;Resto Service&quot;, Owner__c  &lt;&gt; &quot;Mule API User&quot;),  NOT(BEGINS (OwnerId, &quot;00G&quot;)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cases%3A New SFDC Project%2FRequest</fullName>
        <actions>
            <name>Cases_New_SFDC_Project_Request</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Salesforce</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Check Ship Via Change</fullName>
        <actions>
            <name>Ship_Via_Change_Checkbox_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Primary_Request__c</field>
            <operation>equals</operation>
            <value>Address Change,Where is My Order,Ship Via Change,Other</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Queue_Type__c</field>
            <operation>contains</operation>
            <value>Order Inquiries</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Enter_Code_for_Ship_Via_Change__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>If Primary Request = Ship Via Change, then Check box &quot;Ship Via Change&quot;. If Primary Request changes, box should be unchecked</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Clear AccommodationGreaterThanTotal</fullName>
        <actions>
            <name>Clear_AccommodationGreaterThanTotal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.CaseLineAccommodationGreaterThanTotal__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <description>Clear the check box Accommodation Is Greater Then Total because CaseLineAccommodationGreaterThanTotal is equal to zero.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Clear Ship Via and Code</fullName>
        <actions>
            <name>Ship_Via_Change_Checkbox_False</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Ship_Via_Change_Code_Clear</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Primary_Request__c</field>
            <operation>equals</operation>
            <value>Cancellation,Tracking,Shipping Confirmation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Queue_Type__c</field>
            <operation>contains</operation>
            <value>Order Inquiries</value>
        </criteriaItems>
        <description>When field Primary Request = Cancellation, Shipping Confirmation, or Tracking, Clear Ship Via Change checkbox and Enter Code for Ship Via</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ClearCaseAssignment</fullName>
        <actions>
            <name>ClearCaseAssignment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Callout Team,Tier 2,Transfer,Re-open,Call for Pick,Release Order</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Based upon the Status field, clear field CaseAssignment.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ClearInterimUpdate</fullName>
        <actions>
            <name>ClearInterimUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clear the Interim Update field if there are one or more stale date Case Line records with an Interim Update field not equal to either Waiting for Planning, Ready for Callout, or Contact Date Communicated.</description>
        <formula>AND(   Stale_Date_Count__c &gt; 0,   Waiting_for_Planning_Count__c + Ready_for_Callout_Count__c + Contact_Date_Communicated_Count__c &lt; Stale_Date_Count__c  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ContactDateCommunicated</fullName>
        <actions>
            <name>ContactDateCommunicated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Interim Update to &quot;Contact Date Communicated&quot; if all stale date Case Lines have Interim Update equal to &quot;Contact Date Communicated&quot;.</description>
        <formula>AND(   Stale_Date_Count__c  &gt; 0,   Contact_Date_Communicated_Count__c  = Stale_Date_Count__c  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Count Case Owners</fullName>
        <actions>
            <name>Count_Case_Owners</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Count_Queue_Owners</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR( AND( ISCHANGED(OwnerId), BEGINS(OwnerId, &quot;005&quot;), Owner__c &lt;&gt; &quot;Resto Service&quot;, Owner__c &lt;&gt; &quot;Mule API User&quot;),  AND(  ISCHANGED(OwnerId),  BEGINS(OwnerId, &quot;00G&quot;)  ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Count Queue Owners</fullName>
        <actions>
            <name>Count_Queue_Owners</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND( ISCHANGED(OwnerId),  BEGINS(OwnerId, &quot;00G&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CreditCardDecline</fullName>
        <actions>
            <name>CreditCardDecline</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Clear_Email_Alert_Trigger</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Email_Alert_Trigger__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Notification_Type__c</field>
            <operation>equals</operation>
            <value>Credit Card Declines - 1st Notice,Credit Card Declines - 2nd Notice,Credit Card Declines - Final Notice</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Order_Type_Code__c</field>
            <operation>notEqual</operation>
            <value>Z</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CreditCardDecline_Contract</fullName>
        <actions>
            <name>CreditCardDecline_Contract</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Clear_Email_Alert_Trigger</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Email_Alert_Trigger__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Notification_Type__c</field>
            <operation>equals</operation>
            <value>Credit Card Declines - 1st Notice,Credit Card Declines - 2nd Notice,Credit Card Declines - Final Notice</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Order_Type_Code__c</field>
            <operation>equals</operation>
            <value>Z</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CreditCardDeclinesNoEmail</fullName>
        <actions>
            <name>CreditCardDeclineStatus</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CreditCardDeclineTo</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Credit Card Declines</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sold_to_Email__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Changes status to Transfer to Order Processing if no Sold to Email Address exists.
NO LONGER NECESSARY - this must be handled with code.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Default Send To Based on Address Change</fullName>
        <actions>
            <name>Send_To_New_Address</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Order Inquiries - Modify Order</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Primary_Request__c</field>
            <operation>equals</operation>
            <value>Address Change</value>
        </criteriaItems>
        <description>Defaults send to to New Address if the primary request is Address Change.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Default Send To Based on No Order</fullName>
        <actions>
            <name>Send_To_New_Address</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Defaults the Send To to the Send to Address when no order is present.</description>
        <formula>ISBLANK(RH_Order_Number__c )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DelayNotification - RH</fullName>
        <actions>
            <name>DelayNotification_RH</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>DelayNotification_RH_Internal</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Clear_Email_Alert_Trigger</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Email_Alert_Trigger__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Notification_Type__c</field>
            <operation>equals</operation>
            <value>Delay Notifications</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Order_Type_Code__c</field>
            <operation>notEqual</operation>
            <value>Z</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Email_Subject_Brand__c</field>
            <operation>equals</operation>
            <value>RH</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DelayNotification - RH Baby %26 Child</fullName>
        <actions>
            <name>DelayNotification_RH_Baby_Child</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>DelayNotification_RH_Baby_Child_Internal</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Clear_Email_Alert_Trigger</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Email_Alert_Trigger__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Notification_Type__c</field>
            <operation>equals</operation>
            <value>Delay Notifications</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Order_Type_Code__c</field>
            <operation>notEqual</operation>
            <value>Z</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Email_Subject_Brand__c</field>
            <operation>equals</operation>
            <value>RH Baby &amp; Child</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DelayNotification - RH Contract</fullName>
        <actions>
            <name>DelayNotification_RH_Contract</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>DelayNotification_RH_Contract_Internal</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Clear_Email_Alert_Trigger</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Email_Alert_Trigger__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Notification_Type__c</field>
            <operation>equals</operation>
            <value>Delay Notifications</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Order_Type_Code__c</field>
            <operation>equals</operation>
            <value>Z</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Email_Subject_Brand__c</field>
            <operation>equals</operation>
            <value>RH Contract</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DelayNotification - RH Teen</fullName>
        <actions>
            <name>DelayNotification_RH_Teen</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>DelayNotification_RH_Teen_Internal</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Clear_Email_Alert_Trigger</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Email_Alert_Trigger__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Notification_Type__c</field>
            <operation>equals</operation>
            <value>Delay Notifications</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Order_Type_Code__c</field>
            <operation>notEqual</operation>
            <value>Z</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Email_Subject_Brand__c</field>
            <operation>equals</operation>
            <value>RH Teen</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DelayNotificationsFutureProcessing</fullName>
        <actions>
            <name>FutureProcessingTomorrow</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Delay Notifications</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Call_Outcome__c</field>
            <operation>equals</operation>
            <value>Could Not Reach</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Delayed Order Gift Card</fullName>
        <actions>
            <name>Delayed_Order_Gift_Card</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Gift_Card_Status__c</field>
            <operation>equals</operation>
            <value>Pending</value>
        </criteriaItems>
        <description>Request gift card creation in CW if criteria met.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Alert When New Emails Received</fullName>
        <actions>
            <name>New_Email_Received_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(   OR(  BEGINS(TEXT( Origin ),&quot;Email:&quot;),  BEGINS(TEXT( Origin ),&quot;Web:&quot;)),   OR( ISPICKVAL( Status , &quot;Re-open&quot;),  ISPICKVAL( Sub_Status__c , &quot;Customer Reply Received&quot;)),  NOT(BEGINS (OwnerId, &quot;00G&quot;))  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Future Processing Checkbox Removal</fullName>
        <actions>
            <name>Future_Processing_Checkbox_Removal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Future_Processing_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Auto-check the future processing checkbox if a future processing date is input.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Future Processing Checkbox Update</fullName>
        <actions>
            <name>Future_Processing_Checkbox_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Future_Processing_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Auto-check the future processing checkbox if a future processing date is input.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>FutureProcessingFalseBlankDate</fullName>
        <actions>
            <name>BlankFutureProcessingDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Future_Processing__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>If the future processing checkbox is false, then the future processing date needs to be blanked out.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>InProgressTeam</fullName>
        <actions>
            <name>InProgressTeam</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 or (2 and 3)</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Callout Team,Tier 2</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Transfer</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.To__c</field>
            <operation>equals</operation>
            <value>Accommodations,CSC DC/HDL,Product Specialists,Order Processing</value>
        </criteriaItems>
        <description>Update this field on case so that milestone starts work off of In Progress</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>OIStopMilestone</fullName>
        <actions>
            <name>StopMilestone</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>(1 and 2 and 3)</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Transfer</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.To__c</field>
            <operation>equals</operation>
            <value>,CSC DC/HDL,DC,RH Ops</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Order Inquiries - Modify Order,Order Inquiries - Modify Gift Box,Order Inquiries - Modify Monogramming,Order Inquiries - Modify Gift Registry Cards</value>
        </criteriaItems>
        <description>Stops a milestone if the status is changed back to &quot;Transfer&quot; to &quot;CSC DC/HDL,&quot; &quot;Merch Ops,&quot; or &quot;DC.&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Order Inquiries - Record Type is Department</fullName>
        <actions>
            <name>OI_Record_Type_is_Department</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>startsWith</operation>
            <value>Order Inquiries</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Owner %3D Quality Gatekeeper</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Quality</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Ready for Review</value>
        </criteriaItems>
        <description>When status = ready for review, update the owner of quality cases to = quality gatekeeper queue</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PIStopMilestone</fullName>
        <actions>
            <name>StopMilestone</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>5 and ((1 and 2) or (3 and 4))</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Transfer</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.To__c</field>
            <operation>equals</operation>
            <value>,Product Specialists,RH Ops</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Warm Transfer</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.To__c</field>
            <operation>equals</operation>
            <value>Product Specialists</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Product Information</value>
        </criteriaItems>
        <description>Stops a milestone if the status changes back to &quot;Transfer&quot; to &quot;Merch Ops&quot; or &quot;Product Specialists,&quot; or if the status changes to &quot;Warm Transfer&quot; to &quot;Product Specialists.&quot;</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Product Issue Ready for Review</fullName>
        <actions>
            <name>Owner_Resto_Service</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Ready for Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Product Issue</value>
        </criteriaItems>
        <description>When Status = Ready for Review on Product Issue cases, change owner to Resto Service</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RHOM Assessment Field Update</fullName>
        <actions>
            <name>RHOM_On_Fire_Outbound_Message</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>AND(RecordType.Name=&quot;Delight HQ&quot;, ISPICKVAL(Assessment__c, &quot;On-Fire&quot;), NOT(ISBLANK(RH_Order_Number__r.Name)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RHOM FIRE FLAG Update</fullName>
        <actions>
            <name>RHOM_ON_FIRE</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>AND( NOT( ISBLANK(RH_Order_Number__r.Name) ), OR( RecordType.Name=&quot;Delight HQ&quot;, RecordType.Name=&quot;Reorders&quot;, RecordType.Name=&quot;Delivering on Delight&quot; ),  OR( ISPICKVAL( Assessment__c,&quot;&quot;), ISPICKVAL(Assessment__c,&quot;Not on Fire - Low Risk&quot;), ISPICKVAL(Assessment__c,&quot;Not on Fire - High Risk&quot;), NOT(ISPICKVAL(Assessment__c,&quot;On-Fire&quot;)) ),  OR(On_Fire_Client__c=false) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RHOM Fire Flag Update Delivering on Delight</fullName>
        <actions>
            <name>RHOM_Delivering_on_Delight_On_Fire_Updat</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>AND( OR(RecordType.Name=&quot;Delivering on Delight&quot;,  RecordType.Name=&quot;Reorders&quot;),  On_Fire_Client__c=true,      NOT(ISBLANK(RH_Order_Number__r.Name)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RHOM OutboundMessage CaseOwner%2FStatusChange</fullName>
        <actions>
            <name>OutboundMessage_OnChange_Of_Owner_Status</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>This workflow sends an outbound message when ever the case status or owner changes for the Assessment values of Not on Fire, On -Fire for a case</description>
        <formula>AND(NOT(  ISBLANK(RH_Order_Number__r.Name)), OR( ISCHANGED(Status),ISCHANGED(OwnerId) ), OR( RecordType.Name=&quot;Delight HQ&quot;, RecordType.Name=&quot;Reorders&quot;,RecordType.Name=&quot;Delivering on Delight&quot; ), AND( OR( ISPICKVAL(Assessment__c,&quot;&quot;), ISPICKVAL(Assessment__c,&quot;Not on Fire - Low Risk&quot;), ISPICKVAL(Assessment__c,&quot;Not on Fire - High Risk&quot;), NOT(ISPICKVAL(Assessment__c,&quot;On-Fire&quot;))), NOT(ISCHANGED(Assessment__c) ), NOT(ISCHANGED(On_Fire_Indicator__c)) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ROStopMilestone</fullName>
        <actions>
            <name>StopMilestone</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 and ((2 and 3) or 4)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Reorders</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Transfer</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.To__c</field>
            <operation>equals</operation>
            <value>CSC DC/HDL,DC,QA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Call for Pick,Release Partial</value>
        </criteriaItems>
        <description>Stops a milestone if the status is changed back to &quot;Transfer&quot; to &quot;CSC DC/HDL&quot;, &quot;DC&quot;, or &quot;QA&quot;, &quot;Call for Pick&quot;, &quot;Release Partial&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RPStopMilestone</fullName>
        <actions>
            <name>StopMilestone</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>5 and ((1 and 2) or (3 and 4))</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Transfer</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.To__c</field>
            <operation>equals</operation>
            <value>,DC,Product Specialists,RH Ops</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Warm Transfer</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.To__c</field>
            <operation>equals</operation>
            <value>Product Specialists</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Replacement Parts</value>
        </criteriaItems>
        <description>Stops a milestone if the status changes back to &quot;Transfer&quot; to &quot;DC,&quot; &quot;Product Specialists,&quot; or &quot;Merchants,&quot; or if the status changes to &quot;Warm Transfer&quot; to &quot;Product Specialists.&quot;</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ReadyforCallout</fullName>
        <actions>
            <name>ReadyforCallout</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Interim Update to Ready for Callout if all stale date Case Lines have Interim Update equal to either Contact Date Communicated or Ready for Callout.</description>
        <formula>AND(   Stale_Date_Count__c &gt; 0,   Waiting_for_Planning_Count__c = 0,   Ready_for_Callout_Count__c  &gt; 0,   Ready_for_Callout_Count__c + Contact_Date_Communicated_Count__c = Stale_Date_Count__c  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Reorders Status Tier 2</fullName>
        <actions>
            <name>Reorders_Status_Tier_2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Reorders</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Transfer</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.To__c</field>
            <operation>equals</operation>
            <value>CSC DC/HDL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reorder_Count__c</field>
            <operation>greaterOrEqual</operation>
            <value>3</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reorder_Count__c</field>
            <operation>lessOrEqual</operation>
            <value>5</value>
        </criteriaItems>
        <description>Set the Status field to Tier 2 if the Reorder Count on a Reorders Case is between 3 and 5.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Reorders Status Tier 3</fullName>
        <actions>
            <name>Reorders_Status_Tier_3</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Reorders</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Transfer</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.To__c</field>
            <operation>equals</operation>
            <value>CSC DC/HDL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reorder_Count__c</field>
            <operation>greaterThan</operation>
            <value>5</value>
        </criteriaItems>
        <description>Set the Status field to Tier 3 if the Reorder Count on a Reorders Case is greater than 5.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ReserveDatesAllPopulated</fullName>
        <actions>
            <name>BlankFutureProcessingDate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Future_Processing_Checkbox_Removal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If all the reserve dates are populated, the case type is reorders and the future processing flag is true, then the future processing flag will be set to false.</description>
        <formula>AND( RecordType.Name = &quot;Reorders&quot;,  Number_of_Populated_Reserve_Dates__c =  Number_of_Case_Lines__c,  Future_Processing__c = TRUE)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ResetActionRequired</fullName>
        <actions>
            <name>ActionRequiredFalse</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed - Successful,Closed - Invalid,Closed - Unsuccessful,Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Action_Required__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>If a case status is set to closed, reset action required flag so that a case can be re-open in case comments.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ResetByPassValidationRule</fullName>
        <actions>
            <name>ResetByPassValidationRuleField</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.ByPassValidationRule__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This workflow is used to set the ByPassValidationRule field to false</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ResetStopMilestone</fullName>
        <actions>
            <name>ResetStopMilestone</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Stop_Milestone__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Reset the Stop Milestone field to false</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ReturnReceipt - RH</fullName>
        <actions>
            <name>ReturnReceipt_RH</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Clear_Email_Alert_Trigger</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Email_Alert_Trigger__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Email_Subject_Brand__c</field>
            <operation>equals</operation>
            <value>RH</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ReturnReceipt - RH Baby %26 Child</fullName>
        <actions>
            <name>ReturnReceipt_RH_Baby_Child</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Clear_Email_Alert_Trigger</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Email_Alert_Trigger__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Email_Subject_Brand__c</field>
            <operation>equals</operation>
            <value>RH Baby &amp; Child</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ReturnReceipt - RH Teen</fullName>
        <actions>
            <name>ReturnReceipt_RH_Teen</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Clear_Email_Alert_Trigger</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Email_Alert_Trigger__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Email_Subject_Brand__c</field>
            <operation>equals</operation>
            <value>RH Teen</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set AccommodationGreaterThanTotal</fullName>
        <actions>
            <name>Set_AccommodationGreaterThanTotal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.CaseLineAccommodationGreaterThanTotal__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <description>Set the check box Accommodation Is Greater Then Total because CaseLineAccommodationGreaterThanTotal is greater than zero.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Date%2FTIme Delight Plan in Place</fullName>
        <actions>
            <name>Set_Date_Time_Delight_Plan_in_Place</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Delight_Plan_In_Place__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Pending Customer Reply Date</fullName>
        <actions>
            <name>Set_Pending_Customer_Reply_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( ISCHANGED(Sub_Status__c), ISPICKVAL(Sub_Status__c, &quot;Pending Customer Reply&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>StandardStopMilestone</fullName>
        <actions>
            <name>StopMilestone</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Callout Team,Closed - Successful,Closed - Invalid,Cancelled,Closed - Unsuccessful</value>
        </criteriaItems>
        <description>Includes the standard statuses/fields of all NCCAT workflows that stop a milestone.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Sub Status Returns CSC</fullName>
        <actions>
            <name>Sub_Status_Returns_CSC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Returns</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>RHD Returns Queue</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Sub Status Returns Gallery</fullName>
        <actions>
            <name>Sub_Status_Returns_Gallery</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND ((2 AND 3) OR 4)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Returns</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Case_Creator_Gallery__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Gallery Returns Queue</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WaitingforPlanning</fullName>
        <actions>
            <name>WaitingforPlanning</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Interim Update to Waiting for Planning if all the stale date Case Line records have Interim Update equal to either Waiting for Planning, Ready for Callout, or Contact Date Communicated.</description>
        <formula>AND(   Stale_Date_Count__c  &gt; 0,   Waiting_for_Planning_Count__c &gt; 0,   Waiting_for_Planning_Count__c + Ready_for_Callout_Count__c + Contact_Date_Communicated_Count__c = Stale_Date_Count__c  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Credit_Card_Email</fullName>
        <assignedToType>creator</assignedToType>
        <description>Auto-sent Credit Card Decline case to the sold to email address for the first contact. This is for cases with sold to emails.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>User.CreatedDate</offsetFromField>
        <priority>Medium</priority>
        <protected>false</protected>
        <status>Complete</status>
        <subject>Credit Card Email</subject>
    </tasks>
</Workflow>
