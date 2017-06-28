<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PO_Followup_Midwest</fullName>
        <description>PO Followup - Midwest</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MidWest_Pilot_Templates/MW_PO_Follow_Up</template>
    </alerts>
    <fieldUpdates>
        <fullName>Calculate_Tax_on_Freight</fullName>
        <field>Tax_on_Freight__c</field>
        <formula>IF(OR(Freight_Override__c, DC_Pickup__c ) , 0,
  IF(
    OR(
      ISPICKVAL(Ship_State__c , &quot;AR&quot;),
      ISPICKVAL(Ship_State__c , &quot;CO&quot;),
      ISPICKVAL(Ship_State__c , &quot;CT&quot;),
      ISPICKVAL(Ship_State__c , &quot;DC&quot;),
      ISPICKVAL(Ship_State__c , &quot;FL&quot;),
      ISPICKVAL(Ship_State__c , &quot;GA&quot;),
      ISPICKVAL(Ship_State__c , &quot;IL&quot;),
      ISPICKVAL(Ship_State__c , &quot;IN&quot;),
      ISPICKVAL(Ship_State__c , &quot;KS&quot;),
      ISPICKVAL(Ship_State__c , &quot;LA&quot;),
      ISPICKVAL(Ship_State__c , &quot;MI&quot;),
      ISPICKVAL(Ship_State__c , &quot;MN&quot;),
      ISPICKVAL(Ship_State__c , &quot;MO&quot;),
      ISPICKVAL(Ship_State__c , &quot;NJ&quot;),
      ISPICKVAL(Ship_State__c , &quot;NY&quot;),
      ISPICKVAL(Ship_State__c , &quot;NC&quot;),
      ISPICKVAL(Ship_State__c , &quot;OH&quot;),
      ISPICKVAL(Ship_State__c , &quot;PA&quot;),
      ISPICKVAL(Ship_State__c , &quot;RI&quot;),
      ISPICKVAL(Ship_State__c , &quot;SC&quot;),
      ISPICKVAL(Ship_State__c , &quot;TN&quot;),
      ISPICKVAL(Ship_State__c , &quot;TX&quot;),
      ISPICKVAL(Ship_State__c , &quot;WA&quot;),
      ISPICKVAL(Ship_State__c , &quot;WI&quot;),
      ISPICKVAL( Shipping_Country_2__c , &quot;Canada&quot;)
    ), CW_Freight_Total_2__c * Tax_Rate__c, 0
  )
)</formula>
        <name>Calculate Tax on Freight</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_from_Tax_Exempt_language</fullName>
        <description>to apply standard tax language to the field if the project is NOT Tax Exempt</description>
        <field>Tax_Application_Language__c</field>
        <formula>&quot;Sales tax is applied according to local regulations of delivery address&quot;</formula>
        <name>Change from Tax Exempt language</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Calculated_Shipping</fullName>
        <field>Calculated_Shipping__c</field>
        <formula>0</formula>
        <name>Clear Calculated Shipping</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Furniture_Delivery_Fee</fullName>
        <field>Furniture_Delivery_Rate__c</field>
        <formula>0</formula>
        <name>Clear Furniture Delivery Fee</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Project_Freight_Request</fullName>
        <field>Freight_Fees__c</field>
        <formula>0</formula>
        <name>Clear Project Freight Request</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Empty_Shipping_Fees</fullName>
        <field>Shipping_Fees__c</field>
        <formula>0.00</formula>
        <name>Empty Shipping Fees</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Empty_Tax_Rate_field</fullName>
        <field>Tax_Rate__c</field>
        <formula>0</formula>
        <name>Empty Tax Rate field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Ship_to_Country</fullName>
        <description>automates the population of this hidden field to prevent errors. Also reduces the size of the overall formula</description>
        <field>Shipping_Country__c</field>
        <formula>CASE(Ship_State__c , 
&quot;AB&quot;, &quot;CAN&quot;,
&quot;BC&quot;, &quot;CAN&quot;,
&quot;MB&quot;, &quot;CAN&quot;,
&quot;NB&quot;, &quot;CAN&quot;,
&quot;NT&quot;, &quot;CAN&quot;,
&quot;NL&quot;, &quot;CAN&quot;,
&quot;NU&quot;, &quot;CAN&quot;,
&quot;YT&quot;, &quot;CAN&quot;,
&quot;ON&quot;, &quot;CAN&quot;,
&quot;QC&quot;, &quot;CAN&quot;,
&quot;SK&quot;, &quot;CAN&quot;,
&quot;US&quot;)</formula>
        <name>Ship to Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Shipping_Fees_Update2</fullName>
        <field>Shipping_Fees__c</field>
        <formula>CASE(  New_Shipping_Fees_Update__c , 
1,80.00,
2,64.00,
3,50.00,
4,48.00,
5,40.00,
6,34.00,
7,30.00,
8,27.20,
9,25.00,
10,22.40,
11,21.00,
12,17.60,
13,17.00,
14,14.00,
15,12.80,
16,11.00,
17,9.50,
18,8.00,
19,7.95,
20,6.00,
21,4.95,
50, TotalPrice *0.2,
51, Products_with_Shipping_Fees__c *0.17,
22,  Products_with_Shipping_Fees__c  *0.07,
0.00)</formula>
        <name>Shipping Fees Update2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Shipping_Fees_Update_Freight_Quote</fullName>
        <field>Calculated_Shipping__c</field>
        <formula>0</formula>
        <name>Shipping Fees Update - Freight Quote</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Tax_Application_Language</fullName>
        <description>to include language on quote related to Tax application</description>
        <field>Tax_Application_Language__c</field>
        <formula>&quot;Sales tax exemption is on file&quot;</formula>
        <name>Tax Application Language</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Tax_Exempt</fullName>
        <field>Tax_Exempt__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Tax-Exempt</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Bill_To_Address_1</fullName>
        <field>Bill_To_Address_1__c</field>
        <formula>BillingStreet</formula>
        <name>Update Bill To Address 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Bill_To_City</fullName>
        <field>Bill_To_City__c</field>
        <formula>BillingCity</formula>
        <name>Update Bill To City</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Bill_To_Company</fullName>
        <field>Bill_To_Company__c</field>
        <formula>BillingName</formula>
        <name>Update Bill To Company</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Bill_To_Country_Code</fullName>
        <field>Bill_To_Country_Code__c</field>
        <formula>CASE( Opportunity.Account.BillingCountry , &quot;US&quot;, &quot;USA&quot;, &quot;CA&quot;, &quot;CAN&quot;, LEFT (Opportunity.Account.BillingCountry, 3) )</formula>
        <name>Update Bill To Country Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Bill_To_First_Name</fullName>
        <field>Bill_To_First_Name__c</field>
        <formula>Sold_To_First_Name__c</formula>
        <name>Update Bill To First Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Bill_To_Last_Name</fullName>
        <field>Bill_To_Last_Name__c</field>
        <formula>Sold_To_Last_Name__c</formula>
        <name>Update Bill To Last Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Bill_To_Postal_Code</fullName>
        <field>Bill_To_Postal_Code__c</field>
        <formula>BillingPostalCode</formula>
        <name>Update Bill To Postal Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Bill_To_State</fullName>
        <field>Bill_To_State__c</field>
        <formula>BillingState</formula>
        <name>Update Bill To State</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Calc_Handling_VF_Field</fullName>
        <field>Calculated_Handling_VF__c</field>
        <formula>Calculated_Handling__c</formula>
        <name>Update Calc Handling VF Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Expedited_Shipping_to_Standard</fullName>
        <description>When Project Freight Request &gt; 0 change Expedited SHipping to Standard</description>
        <field>Expedited_Shipping__c</field>
        <literalValue>1 - Parcel Ground</literalValue>
        <name>Update Expedited Shipping to Standard</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Expiration_Date_with_Expires_On</fullName>
        <description>This inserts a value in Expiration Date with value from Expires On (Custom)</description>
        <field>ExpirationDate</field>
        <formula>Expires_On_Custom__c</formula>
        <name>Update Expiration Date with Expires On</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Furniture_Delivery_Rate</fullName>
        <field>Furniture_Delivery_Rate__c</field>
        <formula>IF(Final_Ship_To_Country_Formula__c =&quot;Canada&quot;|| Freight_Fees__c &gt;0 || Freight_Override__c = True ||   Use_7_Contract_Model__c  = &quot;Yes&quot;,0,CASE(Range_for_Handling_Fees__c, &quot;Local&quot;, 199,&quot;Extended&quot;,329,&quot;National&quot;,449,&quot;HI/AK&quot;,1199,0))</formula>
        <name>Update Furniture Delivery Rate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Quote_Name_from_Oppty_Name</fullName>
        <field>Name</field>
        <formula>If(RecordType.DeveloperName = &apos;Design_Atelier&apos;, Opportunity.Name&amp;&quot;_&quot;&amp; Opportunity.DA_Opportunity_Number__c&amp;&quot;_&quot;&amp; QuoteNumber,
Opportunity.Name&amp;&quot;_&quot;&amp;Opportunity.Oppty_Number__c)</formula>
        <name>Update Quote Name from Oppty Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Quote_Tax_Exempt</fullName>
        <field>Tax_Exempt__c</field>
        <literalValue>1</literalValue>
        <name>Update Quote Tax Exempt</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Ship_to_First_Name</fullName>
        <field>Ship_To_First_Name__c</field>
        <formula>Sold_To_First_Name__c</formula>
        <name>Update Ship to First Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Ship_to_Last_Name</fullName>
        <field>Ship_To_Last_Name__c</field>
        <formula>Sold_To_Last_Name__c</formula>
        <name>Update Ship to Last Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Shipping_City</fullName>
        <field>Ship_City__c</field>
        <formula>BillingCity</formula>
        <name>Update Shipping City</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Shipping_Rate_Table</fullName>
        <field>Shipping_Rate_Table__c</field>
        <formula>IF( Final_Ship_To_Country_Formula__c = &quot;Canada&quot;   || Freight_Fees__c &gt;0 || Freight_Override__c = True ||   Use_7_Contract_Model__c  = &quot;Yes&quot;,0, 
IF(Products_with_Shipping_Fees__c&gt;750.00,75, 
IF(Products_with_Shipping_Fees__c&gt;600.00,70, 
IF(Products_with_Shipping_Fees__c&gt;500.00,60, 
IF(Products_with_Shipping_Fees__c&gt;400.00,50,  
IF(Products_with_Shipping_Fees__c&gt;300.00,40, 
IF(Products_with_Shipping_Fees__c&gt;200.00,30,  
IF(Products_with_Shipping_Fees__c&gt;125.00,25, 
IF(Products_with_Shipping_Fees__c&gt;90.00,21, 
IF(Products_with_Shipping_Fees__c&gt;65.00,17, 
IF(Products_with_Shipping_Fees__c&gt;45.00,13, 
IF(Products_with_Shipping_Fees__c&gt;25.00,9.5, 
IF(Products_with_Shipping_Fees__c&gt;15.00,7, 
IF(Products_with_Shipping_Fees__c&gt;0.00,4.95, 
0.00))))))))))))))</formula>
        <name>Update Shipping Rate Table</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Shipping_Street1</fullName>
        <field>Ship_Street_1__c</field>
        <formula>BillingStreet</formula>
        <name>Update Shipping Street 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Shipping_Zip</fullName>
        <field>Ship_Zip__c</field>
        <formula>BillingPostalCode</formula>
        <name>Update Shipping Zip</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Tax_on_Merch</fullName>
        <field>Tax_on_Merchandise_2__c</field>
        <formula>IF 
( 
OR 
( 
ISPICKVAL(Ship_State__c , &quot;HI&quot;), 
ISPICKVAL(Ship_State__c , &quot;ID&quot;), 
ISPICKVAL(Ship_State__c , &quot;IA&quot;), 
ISPICKVAL(Ship_State__c , &quot;KY&quot;), 
ISPICKVAL(Ship_State__c , &quot;ME&quot;), 
ISPICKVAL(Ship_State__c , &quot;MS&quot;), 
ISPICKVAL(Ship_State__c , &quot;NE&quot;), 
ISPICKVAL(Ship_State__c , &quot;NM&quot;), 
ISPICKVAL(Ship_State__c , &quot;ND&quot;), 
ISPICKVAL(Ship_State__c , &quot;SD&quot;), 
ISPICKVAL(Ship_State__c , &quot;VT&quot;), 
ISPICKVAL(Ship_State__c , &quot;WV&quot;), 
ISPICKVAL(Ship_State__c , &quot;WY&quot;)
), 
0, Merchandise_Total__c *  Tax_Rate__c )</formula>
        <name>Update Tax on Merch</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_UPS_Delivery_Rate</fullName>
        <field>UPS_Delivery_Rate__c</field>
        <formula>IF(Final_Ship_To_Country_Formula__c = &quot;Canada&quot; || Freight_Fees__c &gt;0 || Freight_Override__c = True  ||  Use_7_Contract_Model__c = &quot;Yes&quot;,0,Shipping_Rate_Table__c +  Rush_Delivery__c)</formula>
        <name>Update UPS Delivery Rate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Updated_Calculated_Shipping</fullName>
        <field>Calculated_Shipping__c</field>
        <formula>CASE( Shipping_Rate_Code__c , 
1,80.00, 
2,64.00, 
3,50.00, 
4,48.00, 
5,40.00, 
6,34.00, 
7,30.00, 
8,27.20, 
9,25.00, 
10,22.40, 
11,21.00, 
12,17.60, 
13,17.00, 
14,14.00, 
15,12.80, 
16,11.00, 
17,9.50, 
18,8.00, 
19,7.95, 
20,6.00, 
21,4.95, 
50, Products_with_Shipping_Fees__c * IF(ISPICKVAL(Country__c,&quot;CAN&quot;),0.17,0.2), 
22, Products_with_Shipping_Fees__c *0.07, 
0.00) +  Expedited_Shipping_Fee__c</formula>
        <name>Updated Calculated Shipping</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Auto Create new PO Follow up Task - North Eastern</fullName>
        <actions>
            <name>PO_Follow_Up</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>A pilot program to auto-remind customers to send payment for invoices we have quoted.</description>
        <formula>Opportunity.Account.Owner.LastName = &quot;Driscoll&quot; &amp;&amp;  NOT(ISBLANK(Opportunity.PO__c)) &amp;&amp; NOT( ISPICKVAL(Opportunity.StageName , &apos;Closed Won&apos;)) &amp;&amp; NOT( ISPICKVAL(Opportunity.StageName , &apos;Closed Won/TO Hold&apos;)) &amp;&amp; NOT( ISPICKVAL(Opportunity.StageName , &apos;Closed/Lost&apos;)) &amp;&amp; NOT( ISPICKVAL(Opportunity.StageName , &apos;Quote finalized - Payment Link Sent&apos;)) &amp;&amp; TODAY()- Quoted_On__c  &gt;= 14</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change Tax Exempt Language</fullName>
        <actions>
            <name>Change_from_Tax_Exempt_language</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Tax_Exempt__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>to display correct Tax Application language for US and CA projects</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Empty Shipping Fees due to Freight Fees</fullName>
        <actions>
            <name>Empty_Shipping_Fees</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Quote.Freight_Fees__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Quote.Manual_Entry_of_S_H_fees__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Empty Tax Rate field</fullName>
        <actions>
            <name>Empty_Tax_Rate_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 or 2</booleanFilter>
        <criteriaItems>
            <field>Quote.Country__c</field>
            <operation>equals</operation>
            <value>Offshore</value>
        </criteriaItems>
        <criteriaItems>
            <field>Quote.Tax_Exempt__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Enter Tax Application Language</fullName>
        <actions>
            <name>Tax_Application_Language</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Tax_Exempt__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Expires On has a Value</fullName>
        <actions>
            <name>Update_Expiration_Date_with_Expires_On</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote.Expires_On_Custom__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow checks to see if Expires On (Custom) contains a values</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PO Followup - Midwest</fullName>
        <active>false</active>
        <description>Remind customers to send payment for invoices we have quoted.</description>
        <formula>AND(   IsSyncing,   Opportunity.Account.Owner.FirstName = &quot;Todd&quot;,   Opportunity.Account.Owner.LastName = &quot;Hilt&quot;,   NOT(ISBLANK(Opportunity.PO__c)),   NOT(     OR(       ISPICKVAL(Opportunity.StageName, &quot;Closed Won&quot;),       ISPICKVAL(Opportunity.StageName, &quot;Closed/Lost&quot;),       ISPICKVAL(Opportunity.StageName, &quot;Quote finalized - Payment Link Sent&quot;)     )   ),   NOT(ISPICKVAL(Opportunity.Account.Contract_Customer_Segmentation__c, &quot;A&quot;)),   NOT(ISBLANK(Quoted_On__c)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>PO_Followup_Midwest</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Quote.Quoted_On__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Populate Bill To and Ship To with Sold To</fullName>
        <actions>
            <name>Update_Bill_To_Address_1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Bill_To_City</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Bill_To_Country_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Bill_To_Postal_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Bill_To_State</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Ship_to_First_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Ship_to_Last_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Shipping_City</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Shipping_Street1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Shipping_Zip</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote.Addresses__c</field>
            <operation>equals</operation>
            <value>Both same as Sold To</value>
        </criteriaItems>
        <criteriaItems>
            <field>Quote.RecordTypeId</field>
            <operation>equals</operation>
            <value>Admin,Standard</value>
        </criteriaItems>
        <description>Populates the Bill To address fields, Ship To address fields, and the Ship To First and Last Name with the info from the Sold To address if all three addresses are the same.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Bill To with Sold To</fullName>
        <actions>
            <name>Update_Bill_To_Address_1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Bill_To_City</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Bill_To_Company</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Bill_To_Country_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Bill_To_First_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Bill_To_Last_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Bill_To_Postal_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Bill_To_State</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote.Addresses__c</field>
            <operation>equals</operation>
            <value>Bill To same as Sold To</value>
        </criteriaItems>
        <criteriaItems>
            <field>Quote.RecordTypeId</field>
            <operation>equals</operation>
            <value>Admin,Standard</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Ship To with Sold To1</fullName>
        <actions>
            <name>Update_Ship_to_First_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Ship_to_Last_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Shipping_City</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Shipping_Street1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Shipping_Zip</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote.Addresses__c</field>
            <operation>equals</operation>
            <value>Ship To same as Sold To</value>
        </criteriaItems>
        <criteriaItems>
            <field>Quote.RecordTypeId</field>
            <operation>equals</operation>
            <value>Admin,Standard</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Products with Delivery Fees %3D 0</fullName>
        <actions>
            <name>Clear_Furniture_Delivery_Fee</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Products_with_Handling_Fees__c =  0</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Products with Delivery Fees %3E 0</fullName>
        <actions>
            <name>Update_Furniture_Delivery_Rate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Products_with_Handling_Fees__c &gt;  0</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Products with Shipping Fee %3E 0</fullName>
        <actions>
            <name>Update_Shipping_Rate_Table</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Products_with_Shipping_Fees__c &gt; 0</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Project is Tax-Exempt</fullName>
        <actions>
            <name>Update_Quote_Tax_Exempt</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Tax_Exempt__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Project is not Tax-Exempt</fullName>
        <actions>
            <name>Uncheck_Tax_Exempt</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Tax_Exempt__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Ship to Country</fullName>
        <actions>
            <name>Ship_to_Country</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>forces the field update to run</description>
        <formula>Contract_Total__c &gt;0</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Shipping Fees Update</fullName>
        <actions>
            <name>Shipping_Fees_Update2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote.Manual_Entry_of_S_H_fees__c</field>
            <operation>equals</operation>
            <value>No</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Shipping Fees Update - Calculated</fullName>
        <actions>
            <name>Updated_Calculated_Shipping</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote.Freight_Fees__c</field>
            <operation>equals</operation>
            <value>,USD 0</value>
        </criteriaItems>
        <description>Determines Calculated Shipping if a Project Freight Quote will not be used.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Shipping Fees Update - Freight Quote</fullName>
        <actions>
            <name>Shipping_Fees_Update_Freight_Quote</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Expedited_Shipping_to_Standard</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Quote.Freight_Fees__c</field>
            <operation>greaterThan</operation>
            <value>USD 0</value>
        </criteriaItems>
        <description>Sets Calculated Shipping to 0 if a Project Freight Quote will be used instead.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Shipping Override</fullName>
        <actions>
            <name>Clear_Calculated_Shipping</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Project_Freight_Request</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote.Freight_Override__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This Checkbox changes the following fields should = 0 
Calculated Shipping
Project Freight Request</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Shipping Rate Table or Rush Delivery %3E 0</fullName>
        <actions>
            <name>Update_UPS_Delivery_Rate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Shipping_Rate_Table__c &gt; 0  ||  Rush_Delivery__c &gt;0</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Tax on Freight</fullName>
        <actions>
            <name>Calculate_Tax_on_Freight</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(ISNEW(),ISCHANGED(CW_Freight_Total_2__c),   ISCHANGED(Tax_Rate__c),ISCHANGED(Freight_Override__c),ISCHANGED( Ship_State__c  ), ISCHANGED( DC_Pickup__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Tax on Merch</fullName>
        <actions>
            <name>Update_Tax_on_Merch</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote.Merchandise_Total__c</field>
            <operation>greaterThan</operation>
            <value>USD 0</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Calc Handling VF Field</fullName>
        <actions>
            <name>Update_Calc_Handling_VF_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote.Calculated_Handling__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Quote Name from Oppty Name</fullName>
        <actions>
            <name>Update_Quote_Name_from_Oppty_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote.Opportunity_Name__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Updates the Quote name from the Oppty Name</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <tasks>
        <fullName>PO_Follow_Up</fullName>
        <assignedToType>owner</assignedToType>
        <description>RH Invoice is pending payment. Please reach out to customer.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>PO Follow Up</subject>
    </tasks>
</Workflow>
