<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Activate_License_for_Lead</fullName>
        <description>Activate License for Lead</description>
        <protected>false</protected>
        <recipients>
            <recipient>simon.w@autorabit.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>vijay@39demo.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>sales@autorabit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/AutoRABIT_Trial_Initated</template>
    </alerts>
    <alerts>
        <fullName>Email_to_Notify_PreSales_when_Trial_is_Expired</fullName>
        <description>Email to Notify PreSales when Trial is Expired</description>
        <protected>false</protected>
        <recipients>
            <recipient>bhargavi@39demo.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>brad.b@techsophy.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>navneeth@39demo.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>niranjan.g@39demo.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>paul.d@39demo.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>simon.w@autorabit.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>vijay@39demo.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>vishnu@39demo.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>sales@autorabit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Final_Activation</template>
    </alerts>
    <alerts>
        <fullName>Final_Week_of_Trial</fullName>
        <description>Final Week of Trial</description>
        <protected>false</protected>
        <recipients>
            <field>Contact_Name__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Final_Activation</template>
    </alerts>
    <alerts>
        <fullName>First_Week_of_Trial</fullName>
        <description>First Week of Trial</description>
        <protected>false</protected>
        <recipients>
            <field>Contact_Name__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Second_Activation_Email</template>
    </alerts>
    <alerts>
        <fullName>Trial_Activation_Mail_to_client</fullName>
        <description>Trial Activation Mail to client</description>
        <protected>false</protected>
        <recipients>
            <recipient>bhargavi@39demo.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Trial_Activation</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Status_Field</fullName>
        <field>StageName</field>
        <literalValue>Trial Expired</literalValue>
        <name>Update Status Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>When_Trial_End_Date_is_Reached</fullName>
        <field>StageName</field>
        <literalValue>Trial Expired</literalValue>
        <name>When Trial End Date is Reached</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AutoRABIT - Trial Expiry</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Trial_End_Date__c</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Email_to_Notify_PreSales_when_Trial_is_Expired</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Opportunity.Trial_End_Date__c</offsetFromField>
            <timeLength>-2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>AutoRABIT -Trial Initiated</fullName>
        <actions>
            <name>Activate_License_for_Lead</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Trial Initiated</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AutoRABIT- First Week of Trial</fullName>
        <actions>
            <name>First_Week_of_Trial</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>Trial_Start_Date__c  + 7=TODAY()</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Trial Started</fullName>
        <actions>
            <name>Trial_Activation_Mail_to_client</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Trial_Start_Date__c</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
