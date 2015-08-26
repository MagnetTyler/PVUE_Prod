<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Queue_name</fullName>
        <field>Previous_Owners_Profile__c</field>
        <formula>CASE(Owner:Queue.QueueName, 
&quot;Accomodations&quot;,&quot;AS&quot;, 
&quot;Channel Quality&quot;,&quot;CQ&quot;, 
&quot;Channel Security&quot;,&quot;CS&quot;, 
&quot;Fulfillment&quot;,&quot;Fulfillment&quot;, 
&quot;Program Coordinator&quot;,&quot;PC&quot;, 
&quot;Program Manager&quot;,&quot;PM&quot;, 
&quot;Results Processing&quot;,&quot;RP&quot;, 
&quot;Test Center&quot;,&quot;TA&quot;, 
&quot;Test Publishing&quot;,&quot;TP&quot;, 
&quot;VSS Level 1&quot;,&quot;L1&quot;, 
&quot;VSS Level 2&quot;,&quot;L2&quot;, 
&quot;Channel Sales&quot;,&quot;Sales&quot;, 
&quot;NOT WORKING&quot;)</formula>
        <name>Update Queue name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_secondary_contact</fullName>
        <field>Secondary_contact__c</field>
        <formula>Contact.FirstName +&quot; &quot;+Contact.LastName</formula>
        <name>Update secondary contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Move Primary contact to Secondary contact</fullName>
        <actions>
            <name>Update_secondary_contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISBLANK( Primary_contact__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Previous Queue</fullName>
        <actions>
            <name>Update_Queue_name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Current_Owners_Profile__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Fills in the name of the previous Queue</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
