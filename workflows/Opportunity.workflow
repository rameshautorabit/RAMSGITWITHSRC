<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Acctchangeofownership</fullName>
        <ccEmails>lalopez@restorationhardware.com</ccEmails>
        <description>Acct - change of ownership</description>
        <protected>false</protected>
        <recipients>
            <recipient>cboone@restorationhardware.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Contract_Misc_Templaters/Opptychangeofownership</template>
    </alerts>
    <alerts>
        <fullName>Client_Appreciation_Alert</fullName>
        <description>Client Appreciation Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Ops_Contact__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Opportunity_Templates/Client_Appreciation</template>
    </alerts>
    <alerts>
        <fullName>Opps_Notify_AS_and_Owner_to_Process_CC_Info</fullName>
        <description>Opps: Notify AS and Owner to Process CC Info</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Ops_Contact__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>TL__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Opportunity_Templates/Notification_of_CC_Info_Needing_Processing</template>
    </alerts>
    <alerts>
        <fullName>Opps_Warn_AS_and_Owner_to_Remove_CC_Info</fullName>
        <description>Opps: Warn AS and Owner to Remove CC Info</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Ops_Contact__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>TL__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Opportunity_Templates/Warning_of_CC_Info_Needing_Removal_24_Hrs</template>
    </alerts>
    <alerts>
        <fullName>OpptyChangeofOwnership</fullName>
        <description>Oppty - Change of Ownership</description>
        <protected>false</protected>
        <recipients>
            <recipient>cboone@restorationhardware.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Contract_Misc_Templaters/Opptychangeofownership</template>
    </alerts>
    <fieldUpdates>
        <fullName>Closed_Lost_Opps_Update_Amount</fullName>
        <field>Amount</field>
        <formula>DA_Forecast_Rollup__c</formula>
        <name>Closed Lost Opps: Update Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Closed_Won_Opps_Update_Amount</fullName>
        <field>Amount</field>
        <formula>IF(ISBLANK(Total_Order_Amount__c),0, Total_Order_Amount__c)</formula>
        <name>Closed Won Opps: Update Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Open_Opps_Update_Amount</fullName>
        <field>Amount</field>
        <formula>DA_Forecast_Rollup__c + IF(ISBLANK(Total_Order_Amount__c),0, Total_Order_Amount__c)</formula>
        <name>Open Opps: Update Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opps_Closed_Won_Date_Update</fullName>
        <field>CloseDate</field>
        <formula>TODAY()</formula>
        <name>Opps: Closed/Won Date Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opps_Mark_Closer_Team_Pod</fullName>
        <field>Closer_Team_Pod__c</field>
        <formula>TEXT( $User.Contract_Team_Pod__c )</formula>
        <name>Opps: Mark Closer Team/Pod</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opps_Mark_Opp_Closer</fullName>
        <field>Opp_Closer__c</field>
        <formula>$User.FirstName  &amp; &quot; &quot; &amp;  $User.LastName</formula>
        <name>Opps: Mark Opp Closer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Amount_Field</fullName>
        <field>Amount</field>
        <formula>DA_Forecast_Rollup__c + Total_Order_Amount__c</formula>
        <name>Update Amount Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Balance_Due_Date_with_Instal_30</fullName>
        <description>Updates Balance Due date with Install/Ship date + 30 days</description>
        <field>Balance_Due_Date__c</field>
        <formula>IF(ISPICKVAL( Credit_Terms__c , &quot;30 days&quot;), Installation_Deadline_Date__c  + 30,
IF(ISPICKVAL( Credit_Terms__c , &quot;45 days&quot;), Installation_Deadline_Date__c  + 45,
IF(ISPICKVAL( Credit_Terms__c , &quot;60 days&quot;), Installation_Deadline_Date__c  + 60,

IF
(
OR
(
ISPICKVAL( Credit_Terms__c , &quot;Pre-Pay&quot;) , 
ISPICKVAL( Credit_Terms__c , &quot;50/50 deposit/pre-ship&quot;) ), 
CloseDate, Installation_Deadline_Date__c)
)))</formula>
        <name>Update Balance Due Date with Instal +30</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Automate Balance Due Date to be Install%2FShip Date %2B30</fullName>
        <actions>
            <name>Update_Balance_Due_Date_with_Instal_30</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Automate Balance Due Date to be Install/Ship Date +30 on save as default. This allows for user to overwrite the value but maintains a standard date for reporting.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Client Appreciation</fullName>
        <actions>
            <name>Client_Appreciation_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>&quot;USD 50,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <description>When Contract client closes Oppty &gt; 50K, PM alerted to send a gift</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DAOpptyFollowUp</fullName>
        <actions>
            <name>Send_Thank_You_Card</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Follow Up</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Record_Type_Developer_Name__c</field>
            <operation>equals</operation>
            <value>Design_Atelier</value>
        </criteriaItems>
        <description>Create Thank You card task when Opportunity moves to Follow Up stage</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opps%3A Closed%2FWon Date Update</fullName>
        <actions>
            <name>Opps_Closed_Won_Date_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opps%3A Mark Opp Closer</fullName>
        <actions>
            <name>Opps_Mark_Closer_Team_Pod</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Opps_Mark_Opp_Closer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.IsWon</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opps%3A Notify AS and Owner to Process CC</fullName>
        <actions>
            <name>Opps_Notify_AS_and_Owner_to_Process_CC_Info</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 or 2 or 3 or 4</booleanFilter>
        <criteriaItems>
            <field>Opportunity.Card_Expiration_Month__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Card_Expiration_Year__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Second_Card_Expiration_Month__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Second_Card_Expiration_Year__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Notifies the AS and Owner on an Opportunity that CC Info has been submitted. Also alerts AS if it has been submitted more than 24 hours ago and not processed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Opps_Warn_AS_and_Owner_to_Remove_CC_Info</name>
                <type>Alert</type>
            </actions>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Opps%3A Notify AS and Owner to Process CC Info</fullName>
        <actions>
            <name>Opps_Notify_AS_and_Owner_to_Process_CC_Info</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 or 2 or 3 or 4</booleanFilter>
        <criteriaItems>
            <field>Opportunity.Card_Expiration_Month__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Card_Expiration_Year__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Second_Card_Expiration_Month__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Second_Card_Expiration_Year__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Notifies the AS and Owner on an Opportunity that CC Info has been submitted. Also alerts AS if it has been submitted more than 48 hours ago and not processed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Opps_Warn_AS_and_Owner_to_Remove_CC_Info</name>
                <type>Alert</type>
            </actions>
            <timeLength>48</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Oppty-change of ownership</fullName>
        <actions>
            <name>OpptyChangeofOwnership</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>ISCHANGED( OwnerId )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Closed Lost DA Opportunity Amount</fullName>
        <actions>
            <name>Closed_Lost_Opps_Update_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Record_Type_Developer_Name__c</field>
            <operation>equals</operation>
            <value>Design_Atelier</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ForecastCategoryName</field>
            <operation>equals</operation>
            <value>Omitted</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Closed Won DA Opportunity Amount</fullName>
        <actions>
            <name>Closed_Won_Opps_Update_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Record_Type_Developer_Name__c</field>
            <operation>equals</operation>
            <value>Design_Atelier</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ForecastCategoryName</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Open DA Opportunity Amount</fullName>
        <actions>
            <name>Open_Opps_Update_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>Opportunity.Record_Type_Developer_Name__c</field>
            <operation>equals</operation>
            <value>Design_Atelier</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ForecastCategoryName</field>
            <operation>equals</operation>
            <value>Pipeline</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ForecastCategoryName</field>
            <operation>equals</operation>
            <value>Best Case</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ForecastCategoryName</field>
            <operation>equals</operation>
            <value>Commit</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Use 7%25 Flat Rate</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND (4 or 5)</booleanFilter>
        <criteriaItems>
            <field>Quote.TotalPrice</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 5,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Quote.Total_Discount__c</field>
            <operation>greaterOrEqual</operation>
            <value>0.25</value>
        </criteriaItems>
        <criteriaItems>
            <field>Quote.Manual_Entry_of_S_H_fees__c</field>
            <operation>equals</operation>
            <value>No</value>
        </criteriaItems>
        <criteriaItems>
            <field>Quote.Country__c</field>
            <operation>equals</operation>
            <value>US</value>
        </criteriaItems>
        <criteriaItems>
            <field>Quote.Country__c</field>
            <operation>equals</operation>
            <value>Offshore</value>
        </criteriaItems>
        <description>to determine whether or not standard shipping and handling rates should be used or the 7% flat rate should be applied</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>Send_Thank_You_Card</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Send Thank You Card</subject>
    </tasks>
</Workflow>
