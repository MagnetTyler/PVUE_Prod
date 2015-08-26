@isTest
public class DetailPageTest {
    public static testmethod void detailPageTest()
    {
        Account a = TestUtil.createAccount();
        a.RecordTypeId=[select id from recordtype where name='Client' limit 1].id;
        a.VTS_Client_id__c = 12345;
        insert a;
        
        
        Account testc=TestUtil.createTestCenterAccount(true, 8484);
        Exam__c e = TestUtil.createExam(true);
        e.Client__c=a.id;
        update e;
        Candidate__c candidate = TestUtil.createCandidate(true);
        
        Registration__c r = TestUtil.createdRegistration( false );
        r.Exam__c = e.Id;
        r.Candidate__c = candidate.Id;
        r.Test_Center__c=testc.id;
        
        insert r;
        
        Case c = TestUtil.createCase(false, schema.SObjectType.Case.GetrecordtypeinfosbyName().get('Request to reschedule').getRecordTypeId());
        c.Registration_id__c = r.Id;
        insert c;

        DetailsPage dp=new DetailsPage();
        System.assertNotEquals(Null, dp.MytestCenter);
        System.assertNotEquals(Null, dp.myclient);
        
        PageReference detp=Page.DetailsPage;
        test.setCurrentPage(detp);
        ApexPages.currentPage().getParameters().put('mycandidate', candidate.id);
        ApexPages.currentPage().getParameters().put('mysite', testc.id);
        ApexPages.currentPage().getParameters().put('myreg', r.id);
        ApexPages.currentPage().getParameters().put('myclient', a.id);
        
       //dp.setmyexam(myexam)
        dp=new DetailsPage();
        System.assertNotEquals(Null, dp.MytestCenter);

        System.assertNotEquals(Null, dp.getmyexam());
        System.assertNotEquals(Null, dp.getmyreg());
        
        System.assertNotEquals(Null, dp.mycandidate);
        System.assertNotEquals(Null, dp.myclient);
        dp.setmyexam(e);
        dp.setMyReg(r);
        dp.initData();
        dp.refreshVtsData();
    }
  
      


}