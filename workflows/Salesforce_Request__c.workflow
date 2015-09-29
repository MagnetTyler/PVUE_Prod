<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_SF_Request_Confirmation_to_Creator</fullName>
        <description>Email SF Request Confirmation to Creator</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SF_Request_Confirmation_to_Creator</template>
    </alerts>
    <alerts>
        <fullName>Email_SF_Request_to_Admins</fullName>
        <description>Email SF Request to Admins</description>
        <protected>false</protected>
        <recipients>
            <recipient>david.gunn2@pearson.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>geri.caban@pearson.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SF_Request_New_Request</template>
    </alerts>
    <rules>
        <fullName>Salesforce Request Creation - Send Confirmation Email To Creator</fullName>
        <actions>
            <name>Email_SF_Request_Confirmation_to_Creator</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.LastName</field>
            <operation>notEqual</operation>
            <value>Gunn,Caban</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Salesforce Request Creation - Send Email To Admins</fullName>
        <actions>
            <name>Email_SF_Request_to_Admins</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.LastName</field>
            <operation>notEqual</operation>
            <value>Caban,Gunn</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
