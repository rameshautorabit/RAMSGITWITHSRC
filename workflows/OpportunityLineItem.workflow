<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Requires_Handling_Fee</fullName>
        <field>Requires_Handling_Fee__c</field>
        <literalValue>1</literalValue>
        <name>Requires Handling Fee</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_ELC_field_in_Opp</fullName>
        <field>Update_ELC_total__c</field>
        <formula>ELC__c * Quantity</formula>
        <name>Update ELC field in Opp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opp_Product_Unit_Price</fullName>
        <description>copy the List price into this field so that the Opportunity Rollup Summary will work</description>
        <field>Unit_Price__c</field>
        <formula>PricebookEntry.UnitPrice</formula>
        <name>Update Opp Product Unit Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Needs Handling Fees</fullName>
        <actions>
            <name>Requires_Handling_Fee</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(Product2.SKU_Ship_Via__c  = &quot;5&quot;, Product2.SKU_Ship_Via__c =&quot;6&quot;,Product2.SKU_Ship_Via__c =&quot;10&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update ELC field in Opp</fullName>
        <actions>
            <name>Update_ELC_field_in_Opp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OpportunityLineItem.ELC__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Product Unit Price for Opp</fullName>
        <actions>
            <name>Update_Opp_Product_Unit_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OpportunityLineItem.UnitPrice</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>update this field so that the Opportunity Roll-up Summary will work</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
