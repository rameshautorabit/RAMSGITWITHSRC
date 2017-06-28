<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ManualReservation_RH</fullName>
        <description>ManualReservation - RH</description>
        <protected>false</protected>
        <recipients>
            <field>Email_To_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>webcs@rh.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/ManualReservation</template>
    </alerts>
    <alerts>
        <fullName>ManualReservation_RH_Baby_Child</fullName>
        <description>ManualReservation - RH Baby &amp; Child</description>
        <protected>false</protected>
        <recipients>
            <field>Email_To_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>babyandchild@rh.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/ManualReservation</template>
    </alerts>
    <alerts>
        <fullName>ManualReservation_RH_Contract</fullName>
        <description>ManualReservation - RH Contract</description>
        <protected>false</protected>
        <recipients>
            <field>Email_To_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/ManualReservation</template>
    </alerts>
    <alerts>
        <fullName>ManualReservation_RH_Teen</fullName>
        <description>ManualReservation - RH Teen</description>
        <protected>false</protected>
        <recipients>
            <field>Email_To_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>rhteen@rh.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/ManualReservation</template>
    </alerts>
    <fieldUpdates>
        <fullName>Clear_Send_Email</fullName>
        <field>Send_Email__c</field>
        <literalValue>0</literalValue>
        <name>Clear Send Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ManualReservation - RH</fullName>
        <actions>
            <name>ManualReservation_RH</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Clear_Send_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Manual_Reservation__c.Email_Subject_Brand__c</field>
            <operation>equals</operation>
            <value>RH</value>
        </criteriaItems>
        <criteriaItems>
            <field>Manual_Reservation__c.Send_Email__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ManualReservation - RH Baby %26 Child</fullName>
        <actions>
            <name>ManualReservation_RH_Baby_Child</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Clear_Send_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Manual_Reservation__c.Email_Subject_Brand__c</field>
            <operation>equals</operation>
            <value>RH Baby &amp; Child</value>
        </criteriaItems>
        <criteriaItems>
            <field>Manual_Reservation__c.Send_Email__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ManualReservation - RH Contract</fullName>
        <actions>
            <name>ManualReservation_RH_Contract</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Clear_Send_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Manual_Reservation__c.Email_Subject_Brand__c</field>
            <operation>equals</operation>
            <value>RH Contract</value>
        </criteriaItems>
        <criteriaItems>
            <field>Manual_Reservation__c.Send_Email__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ManualReservation - RH Teen</fullName>
        <actions>
            <name>ManualReservation_RH_Teen</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Clear_Send_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Manual_Reservation__c.Email_Subject_Brand__c</field>
            <operation>equals</operation>
            <value>RH Teen</value>
        </criteriaItems>
        <criteriaItems>
            <field>Manual_Reservation__c.Send_Email__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
