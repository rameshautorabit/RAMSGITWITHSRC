<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CW_N_C_Flag</fullName>
        <field>CW_N_C_Flag__c</field>
        <literalValue>Y</literalValue>
        <name>CW N/C Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Prod_subtotal_to</fullName>
        <field>Products_w_Shipping_Fees__c</field>
        <formula>UnitPrice * Quantity</formula>
        <name>Change Prod subtotal to #</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Empty_Shipping_Fees_Field</fullName>
        <description>to replace the fees with a Zero (since products with the Ship Via of 5, 6, or 10 do not have shipping fees)</description>
        <field>Products_w_Shipping_Fees__c</field>
        <formula>0.00</formula>
        <name>Empty Shipping Fees Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Ovr_Code</fullName>
        <field>Ovr_Code__c</field>
        <literalValue>M</literalValue>
        <name>Ovr Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Quote_Item_Requires_Handling_Fees</fullName>
        <field>Requires_Handling_Fees__c</field>
        <literalValue>1</literalValue>
        <name>Quote Item Requires Handling Fees</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Quote_Line_Items_Update_Surcharge_Amount</fullName>
        <field>Surcharge_Amount__c</field>
        <formula>Surcharges__c</formula>
        <name>Quote Line Items Update Surcharge Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_DA_Total_c</fullName>
        <field>DA_Total__c</field>
        <formula>DA_Total_Formula__c</formula>
        <name>Update DA_Total__c</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Unit_Price</fullName>
        <field>Unit_Price__c</field>
        <formula>PricebookEntry.UnitPrice</formula>
        <name>Update Unit Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>enter_ELC_amount_x_quantity_in_QLI</fullName>
        <field>ELC_Update__c</field>
        <formula>ELC__c* Quantity</formula>
        <name>enter ELC * Quantity in Quote Line Item</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CW N%2FC Flag</fullName>
        <actions>
            <name>CW_N_C_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Ovr_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>QuoteLineItem.UnitPrice</field>
            <operation>lessOrEqual</operation>
            <value>USD 0</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Convert Subtotal to Number</fullName>
        <actions>
            <name>Change_Prod_subtotal_to</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>QuoteLineItem.Ship_Via__c</field>
            <operation>notEqual</operation>
            <value>5,6,10</value>
        </criteriaItems>
        <description>in order to use a rollup summary field on the Quote, the subtotal needs to be converted to a number field, not a currency field. This formula excludes items with Ship Via = 5,6, or 10</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DA - Pricing based on Membership</fullName>
        <actions>
            <name>Update_DA_Total_c</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote.Record_Type_DeveloperName__c</field>
            <operation>equals</operation>
            <value>Design_Atelier</value>
        </criteriaItems>
        <criteriaItems>
            <field>QuoteLineItem.DA_Total__c</field>
            <operation>equals</operation>
            <value>,USD 0</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Empty Shipping Fees field</fullName>
        <actions>
            <name>Empty_Shipping_Fees_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>QuoteLineItem.Ship_Via__c</field>
            <operation>equals</operation>
            <value>10</value>
        </criteriaItems>
        <description>checks to see if the Product Ship Via equals 10. These products do not have shipping fees.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Quote Line Items Add Surcharges</fullName>
        <actions>
            <name>Quote_Line_Items_Update_Surcharge_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>QuoteLineItem.Surcharges__c</field>
            <operation>notEqual</operation>
            <value>,USD 0</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Requires Handling Fees</fullName>
        <actions>
            <name>Quote_Item_Requires_Handling_Fees</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR( Product2.SKU_Ship_Via__c = &quot;5&quot;, Product2.SKU_Ship_Via__c =&quot;6&quot;,Product2.SKU_Ship_Via__c=&quot;10&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Unit Price</fullName>
        <actions>
            <name>Update_Unit_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>QuoteLineItem.UnitPrice</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>update ELC field in Quote</fullName>
        <actions>
            <name>enter_ELC_amount_x_quantity_in_QLI</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>QuoteLineItem.ELC__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>in order to use a Roll-up summary on the Quote, we need to do this workaround</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>update with delivery date</fullName>
        <active>false</active>
        <formula>ISPICKVAL( Expected_Customer_Delivery_Date__c , &quot; &quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
