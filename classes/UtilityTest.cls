@isTest
public class UtilityTest {
    
    public static testMethod void UtilityUnitTest(){
        
        system.assert( Utility.returnhex( 1234567890 ) != null );
        system.assert( Utility.Editablefields('Account') != null  );
        system.assert( Utility.getpickvals('Status' , 'Case') != null  );
        system.assert( Utility.Relationshipfields('Contact' , 'Account') != null  );
        
        Account a = TestUtil.createAccount();
        a.RecordTypeId=[select id from recordtype where name='Client' limit 1].id;
        a.VTS_Client_id__c = 12345;
        insert a;
        
        Exam__c e = TestUtil.createExam(true);
        Candidate__c candidate = TestUtil.createCandidate(true);
        
        Registration__c r = TestUtil.createdRegistration( false );
        r.Exam__c = e.Id;
        
        r.Candidate__c = candidate.Id;
        insert r;
        
        Case c = TestUtil.createCase(false, schema.SObjectType.Case.GetrecordtypeinfosbyName().get('Request to reschedule').getRecordTypeId());
        c.Registration_id__c = r.Id;
        insert c;
        VTS_Candidate cand=  new VTS_Candidate();
        cand.id=2233; 
        VTS_Registration vts_r = new VTS_Registration();
        vts_r.candidate =cand; //new VTS_Candidate();
        // vts_r.candidate.Id=12345;
        vts_r.exam=new VTS_Exam();
        vts_r.exam.id=12345;
        vts_r.candidate.clientId = 12345;
        vts_r.id=758588;
        VTS_TestCenter tc=new VTS_TestCenter();
        tc.id=12345;
        tc.name='test center';
        vts_r.testCenter=tc;
        vts_r.appointmentTime=new VTS_Registration.VTS_Time();
        vts_r.appointmentTime.timestampInUTC=System.now().getTime();
        
        Utility.CommitRegistration(c, vts_r);
        
        System.assert( Utility.readFieldSet('detailspage', 'Registration__c')!=null) ;
        Routing__c rout=new Routing__c();
        rout.Case_Record_Type__c=[select id from RecordType where Name='Backup biometric missing' limit 1].id;
        insert rout;
        Step__c s = new Step__c();
        s.Routing__c=rout.id;
        s.Has_forked_logic__c=true;
        insert s;
        c.Step__c=s.Id;
        
        update c;
        Case c1 = TestUtil.createCase(false, schema.SObjectType.Case.GetrecordtypeinfosbyName().get('Request to reschedule').getRecordTypeId());
        c1.Registration_id__c = r.Id;
        c1.ParentId=c.id;
        c1.Completed__c=true;
        Case c3 = TestUtil.createCase(false, schema.SObjectType.Case.GetrecordtypeinfosbyName().get('Request to reschedule').getRecordTypeId());
        c3.Registration_id__c = r.Id;
        c3.ParentId=c.Id;
        insert new List<case>{ c1,c3};
            Routing_logic__c rlogic= new Routing_logic__c();
        rlogic.RecordTypeId=[select id from recordtype where name ='Dynamic Routing Logic' limit 1].id;
        rlogic.Step__c=s.id;
        
        
        Utility.CaseAggregate(new Set<id>{c1.Id,c.Id,c3.Id});
        
    }
    public static testmethod void createStepUtilityTest()
    {
        User u= testutil.createUser();
        u.ProfileId=[select id from profile where name='System Administrator' limit 1].id;
   		   insert  u;
        System.runAs(u){
            
            System.debug('RK: user type:'+userinfo.getUserType());
            Routing__c routing = DataFactory.createRouting('Missing Results');
            List<Step__c> routingSteps = DataFactory.createMissingResultsRoutingSteps(routing.Id);
            System.debug('routingSteps: ' + routingSteps);
            List<Routing_logic__c> routingLogics = DataFactory.createMissingResultsRoutingLogics(routingSteps);
            
        }
        
       
             List<Step__c> routingSteps =Database.query('select ' + utility.Editablefields('Step__c') + '  from Step__c ');// 
            system.debug('RK: routingSteps:'+routingSteps);
            
            Case parentCase = 
                new Case(
                    Subject = 'Missing Results', Status__c = 'Being Created', Status = 'Being Created',
                    Step__c=routingSteps[0].id,
                    Topic__c = 'Created by VTS', Final_Category__c ='Missing Results');//,createddate=system.now()
            
            insert parentcase;
            
            system.debug('RK: case created date:'+[select createddate from case]);
            parentCase=[select id, createddate,subject,status__c,status,step__c, topic__c, final_category__c,LastModifiedDate from case limit 1];
            Step__c s= Database.query('select ' + utility.Editablefields('Step__c') + ' from Step__c where Id = \'' + parentcase.Step__c + '\'');
            system.debug('RK: Step__c:'+routingSteps);
            utility.Case_step_utility(parentCase, s);
            parentCase.Follow_up_with__c = 'Program_Coordinator';
            
            update parentCase;// Move to Step 2
            
            parentCase=[select id, createddate,subject,status__c,status,step__c, topic__c, final_category__c,LastModifiedDate from case limit 1];
            
            s=  Database.query('select ' + utility.Editablefields('Step__c') + ' from Step__c where Id = \'' + parentcase.Step__c + '\'');
            utility.Case_step_utility(parentCase, s);// Move to Step 3
            update parentCase;
            
            parentCase=[select id, createddate,subject,status__c,status,step__c, topic__c, final_category__c,LastModifiedDate from case limit 1];
            s=  Database.query('select ' + utility.Editablefields('Step__c') + ' from Step__c where Id = \'' + parentcase.Step__c + '\'');
            utility.Case_step_utility(parentCase, s); // Move to Step 4
            update parentCase;
            
            
            parentCase=[select id, createddate,subject,status__c,status,step__c, topic__c, final_category__c,LastModifiedDate from case limit 1];
            s=  Database.query('select ' + utility.Editablefields('Step__c') + ' from Step__c where Id = \'' + parentcase.Step__c + '\'');
            utility.Case_step_utility(parentCase, s); // Move to Step 5
            update parentCase;
            
            
            parentCase=[select id, createddate,subject,status__c,status,step__c, topic__c, final_category__c,LastModifiedDate from case limit 1];
            s= Database.query('select ' + utility.Editablefields('Step__c') + ' from Step__c where Id = \'' + parentcase.Step__c + '\'');
            utility.Case_step_utility(parentCase, s); // Move to Step 6
            update parentCase;

         	 parentCase=[select id, createddate,subject,status__c,status,step__c, topic__c, final_category__c,LastModifiedDate from case limit 1];
            s= Database.query('select ' + utility.Editablefields('Step__c') + ' from Step__c where Id = \'' + parentcase.Step__c + '\'');
            utility.Case_step_utility(parentCase, s); // Move to Step 6
            update parentCase;
        
          parentCase=[select id, createddate,subject,status__c,status,step__c, topic__c, final_category__c,LastModifiedDate from case limit 1];
            s= Database.query('select ' + utility.Editablefields('Step__c') + ' from Step__c where Id = \'' + parentcase.Step__c + '\'');
            utility.Case_step_utility(parentCase, s); // Move to Step 6
            update parentCase;
        
    }
}