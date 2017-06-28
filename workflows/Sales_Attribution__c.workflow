<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Adjusted_Sales_Attribution</fullName>
        <description>Adjusted Sales Attribution</description>
        <protected>false</protected>
        <recipients>
            <field>Associate_Name__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Gallery_Templates/Adjusted_Sales_Attribution</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Associate_ID_from_Associate_Name</fullName>
        <field>Attribution_ID__c</field>
        <formula>Associate_Name__r.Associate_ID__c</formula>
        <name>Update Associate ID from Associate Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Adjusted Sales Attribution</fullName>
        <actions>
            <name>Adjusted_Sales_Attribution</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Triggers an email to the impacted associate</description>
        <formula>OR(ISCHANGED( Associate_Name__c ), ISCHANGED( Attribution_Percent__c ), ISCHANGED( Primary_Associate__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Associate ID from User Record</fullName>
        <actions>
            <name>Update_Associate_ID_from_Associate_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISBLANK(Associate_Name__c))  &amp;&amp;  (ISCHANGED( Associate_Name__c ) ||  ISNEW())</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
