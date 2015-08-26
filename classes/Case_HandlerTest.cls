@isTest
public class Case_HandlerTest {

    static testMethod void BeforeInsertTest(){
        
        Exam__c e = TestUtil.createExam(true);
        Candidate__c candidate = TestUtil.createCandidate(true);
        
        Registration__c r = TestUtil.createdRegistration( false );
        r.Exam__c = e.Id;
        r.Candidate__c = candidate.Id;
        insert r;
        
        Case c = TestUtil.createCase(false, schema.SObjectType.Case.GetrecordtypeinfosbyName().get('Missing results').getRecordTypeId());
        c.Registration_id__c = r.Id;
        
        insert c;
        
        system.assert( [select Evt_folder_name__c from Case where Id = :c.Id].Evt_folder_name__c != null );
        
    }
    
    static testMethod void BeforeUpdateTest(){
        
        Exam__c e = TestUtil.createExam(true);
        Candidate__c candidate = TestUtil.createCandidate(true);
        
        Registration__c r = TestUtil.createdRegistration( false );
        r.Exam__c = e.Id;
        r.Candidate__c = candidate.Id;
        insert r;
        
        Registration__c r1 = TestUtil.createdRegistration( false );
        r1.Exam__c = e.Id;
        r1.Candidate__c = candidate.Id;
        insert r1;
        
        Case c = TestUtil.createCase(false, schema.SObjectType.Case.GetrecordtypeinfosbyName().get('Request to reschedule').getRecordTypeId());
        c.Registration_id__c = r.Id;
        c.Status = 'Closed';
        insert c;
		
		c.Original_Record_Type__c = 'Missing results';  
        c.Registration_id__c = r1.Id;
        update c;
        
        system.assert( [select Evt_folder_name__c from Case where Id = :c.Id].Evt_folder_name__c != null );
        
    }
    
    static testMethod void AfterUpdateTest(){
        
        Exam__c e = TestUtil.createExam(true);
        Candidate__c candidate = TestUtil.createCandidate(true);
        
        Registration__c r = TestUtil.createdRegistration( false );
        r.Exam__c = e.Id;
        r.Candidate__c = candidate.Id;
        insert r;
        
        Registration__c r1 = TestUtil.createdRegistration( false );
        r1.Exam__c = e.Id;
        r1.Candidate__c = candidate.Id;
        insert r1;
        
        Case parent = TestUtil.createCase(false, schema.SObjectType.Case.GetrecordtypeinfosbyName().get('Request to reschedule').getRecordTypeId());
        parent.Registration_id__c = r.Id;
        parent.Status = 'Closed';
        insert parent;
        
        executioncontrol.afternInserthasrun = false;
        
        Case c = TestUtil.createCase(false, schema.SObjectType.Case.GetrecordtypeinfosbyName().get('Request to reschedule').getRecordTypeId());
        c.Registration_id__c = r.Id;
        c.Status = 'Closed';
        insert c;
		
        executioncontrol.afternInserthasrun = false;
        
		c.Original_Record_Type__c = 'Missing results';  
        c.Registration_id__c = r1.Id;
        c.parentId = parent.Id;
        update c;
        
        system.assert( [select Evt_folder_name__c from Case where Id = :c.Id].Evt_folder_name__c != null );
        
    }
    
    static testMethod void AfterInsertTest(){
        Account a = TestUtil.createAccount();
        insert a;
        
        Contact cont = testUtil.createContact(false, a);
        cont.Status__c = 'Active';
        insert cont;
        
        Exam__c e = TestUtil.createExam(true);
        Candidate__c candidate = TestUtil.createCandidate(true);
        
        Registration__c r = TestUtil.createdRegistration( false );
        r.Exam__c = e.Id;
        r.Candidate__c = candidate.Id;
        insert r;
        
        Registration__c r1 = TestUtil.createdRegistration( false );
        r1.Exam__c = e.Id;
        r1.Candidate__c = candidate.Id;
        insert r1;
        
        Case parent = TestUtil.createCase(false, schema.SObjectType.Case.GetrecordtypeinfosbyName().get('Request to reschedule').getRecordTypeId());
        parent.Registration_id__c = r.Id;
        insert parent;
        
        executioncontrol.afternInserthasrun = false;
        
        Test.startTest();
        
        Case c = TestUtil.createCase(false, schema.SObjectType.Case.GetrecordtypeinfosbyName().get('Request to reschedule').getRecordTypeId());
        c.Registration_id__c = r.Id;
        c.parentId = parent.Id;
        c.Status = 'Closed';
        c.AccountId = a.Id;
        insert c;
		
        Test.stopTest();
        
    }
}