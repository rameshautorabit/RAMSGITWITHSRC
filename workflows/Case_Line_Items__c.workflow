<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Order_line_status_update_notification_to_owner</fullName>
        <description>Order line status update notification to owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Case_Templates/Order_Line_Status_Updated</template>
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
        <fullName>CaseLineAccommodationGreaterThanTotal</fullName>
        <description>Set field to 1 or zero based upon value of check box Accommodation Is Greater Than Total.  This field is used to automatically set the Case check box Accommodation Is Greater Than Total.</description>
        <field>AccommodationGreaterThanTotal__c</field>
        <formula>IF( Accommodation_Is_Greater_Than_Total__c , 1, 0)</formula>
        <name>CaseLineAccommodationGreaterThanTotal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>External_Support_CSC_Vendor</fullName>
        <field>External_Support__c</field>
        <literalValue>CSC Vendor</literalValue>
        <name>External Support = CSC Vendor</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>External_Support_Flatworld</fullName>
        <field>External_Support__c</field>
        <literalValue>Flatworld</literalValue>
        <name>External Support = Flatworld</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>External_Support_Shanghai</fullName>
        <field>External_Support__c</field>
        <literalValue>Shanghai</literalValue>
        <name>External Support = Shanghai</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Accommodation Sub-Reason%3A Business %28LINE%29</fullName>
        <actions>
            <name>Accommodation_Sub_Reason_Business</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 or 2 or 3</booleanFilter>
        <criteriaItems>
            <field>Case_Line_Items__c.Accommodation_Reason__c</field>
            <operation>equals</operation>
            <value>Freight - Canadian Adjustment/Refund,Freight - US Adjustment/Refund,Gift Box Fee Refund,Out Of Policy Return,Personalization Fee Refund,Pre-Bill Refund,Price Match – Sale/Promo,Tax Refund</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case_Line_Items__c.Accommodation_Reason__c</field>
            <operation>equals</operation>
            <value>Refund for GC/SC/Reward MOP,Reissue System Refund – Incorrect/Cancelled/Did Not Generate,Delay - DC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case_Line_Items__c.Accommodation_Reason__c</field>
            <operation>equals</operation>
            <value>Balance Transfer,Gift Return,Manual Charge</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Accommodation Sub-Reason%3A Customer %28LINE%29</fullName>
        <actions>
            <name>Accommodation_Sub_Reason_Customer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case_Line_Items__c.Accommodation_Reason__c</field>
            <operation>equals</operation>
            <value>Carrier Caused - HDL,Carrier Caused - UPS,Customer Experience,Damaged/Defective Product,Delay - Backorder,Delay - DC,Delay - Vendor,Freight - Flat Rate Delivery Fee Refund</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case Line Email notification</fullName>
        <actions>
            <name>Order_line_status_update_notification_to_owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( ISCHANGED(Current_Available_Date__c), Line_Status_Description__c != null, RecordType.Name = &apos;Delight HQ&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CaseLineAccommodataionGreaterThanTotal</fullName>
        <actions>
            <name>CaseLineAccommodationGreaterThanTotal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set field AccommodationAmountGreaterThanTotal based upon the new value of check box Accommodation Is Greater Than Total.  This is one piece of the functionality to automatically set the Case field Accommodation Is Greater Than Total due to Case Line Items</description>
        <formula>OR(ISNEW(), ISCHANGED(Accommodation_Is_Greater_Than_Total__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update External Support %3D CSC Vendor</fullName>
        <actions>
            <name>External_Support_CSC_Vendor</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6</booleanFilter>
        <criteriaItems>
            <field>Case_Line_Items__c.Vendor_Number__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case_Line_Items__c.Vendor_Number__c</field>
            <operation>notEqual</operation>
            <value>7614,4923,7668,6180,4452,7446,7363,6485,7678,7648,7618,7616,4445,4848,6887,7641,7723,5080,7360,7563,6243,6431,6247,5955,6285,6287,7674,7194,4459,7093,6489,7220,7420,6971,7219,6899,7221,7698,7591,7161,7118,7250,1774</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case_Line_Items__c.Vendor_Number__c</field>
            <operation>notEqual</operation>
            <value>6858,6804,4466,7382,7423,7375,6234,7218,7499,6162,7032,6544,7153,7516,7690,6818,6286,5927,7226,4439,7485,5944,4478,6889,7732,4461,7002,6387,4508,7737,7103,6233,4441,7518,7167,6123,7231,7217,7083,7410,6888</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case_Line_Items__c.Vendor_Number__c</field>
            <operation>notEqual</operation>
            <value>7498,7613,5454,7751,7252,7520,6901,7642,7073,5073,7116,7457,7222,7575,7130,6521,4438,7372,4839,4842,6235,6139,5919,5072,6872,7646,7390,7323,7469,6324,7331,6273</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case_Line_Items__c.Vendor_Number__c</field>
            <operation>notEqual</operation>
            <value>6886,668,7385,6867,7359,6516,7193,6555,7659,7215,7470,700,6245,6290,7234,7872,7224,929,4456,6998,7225,7338,7965,7233,7095,7464,7228,7878,7147,6993,2151,7474,7628,7223,7214,7322,7880,7183,7108,7068,7493,7746</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case_Line_Items__c.Vendor_Number__c</field>
            <operation>notEqual</operation>
            <value>7005,7486,7146,7792,7484,7357,7475,7629,6492,7134,6439,7015,7586,7198,7958,7329,7472,6994,7077,7094,7721,7243,7251,7216,7630,7172,7139,6289,7489,6291,7361,7621,6536,8141,7131,7587,7232,6868,7145,6164,4451,6569</value>
        </criteriaItems>
        <description>If vendor number is filled in but not on the list, default to CSC vendor</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update External Support %3D Flatworld</fullName>
        <actions>
            <name>External_Support_Flatworld</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3</booleanFilter>
        <criteriaItems>
            <field>Case_Line_Items__c.Vendor_Number__c</field>
            <operation>equals</operation>
            <value>6886,668,7385,6867,7359,6516,7193,6555,7659,7215,7470,700,6245,6290,7234,7872,7224,929,4456,6998,7225,7338,7965,7233,7095,7464,7228,7878,7147,6993,2151,7474,7628,7223,7214,7322,7880,7183,7108,7068,7493,7746</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case_Line_Items__c.Vendor_Number__c</field>
            <operation>equals</operation>
            <value>7005,7486,7146,7792,7484,7357,7475,7629,6492,7134,6439,7015,7586,7198,7958,7329,7472,6994,7077,7094,7721,7243,7251,7216,7630,7172,7139,6289,7489,6291,7361,7621,6536,8141,7131,7587,7232,6868,7145,6164,4451,6569</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case_Line_Items__c.Vendor_Number__c</field>
            <operation>equals</operation>
            <value>7390,7323,7469,6324,7331,6273,1774</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update External Support %3D Shanghai</fullName>
        <actions>
            <name>External_Support_Shanghai</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3</booleanFilter>
        <criteriaItems>
            <field>Case_Line_Items__c.Vendor_Number__c</field>
            <operation>equals</operation>
            <value>7614,4923,7668,6180,4452,7446,7363,6485,7678,7648,7618,7616,4445,4848,6887,7641,7723,5080,7360,7563,6243,6431,6247,5955,6285,6287,7674,7194,4459,7093,6489,7220,7420,6971,7219,6899,7221,7698,7591,7161,7118,7250</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case_Line_Items__c.Vendor_Number__c</field>
            <operation>equals</operation>
            <value>6858,6804,4466,7382,7423,7375,6234,7218,7499,6162,7032,6544,7153,7516,7690,6818,6286,5927,7226,4439,7485,5944,4478,6889,7732,4461,7002,6387,4508,7737,7103,6233,4441,7518,7167,6123,7231,7217,7083,7410,6888</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case_Line_Items__c.Vendor_Number__c</field>
            <operation>equals</operation>
            <value>7498,7613,5454,7751,7252,7520,6901,7642,7073,5073,7116,7457,7222,7575,7130,6521,4438,7372,4839,4842,6235,6139,5919,5072,6872,7646</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
