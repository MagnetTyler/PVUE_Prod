@isTest
public class importDataFromCSVTestController {
    static testMethod void ImportCSVtest()
    {
        Case c=new Case();
        c.Subject='test subject';
        insert c;
       
        createclients();
        String csvstring='Id, Name \n465566,testcenter1 \n45565,testcenter2 \n456552,testcenter3 \n585452,testcenter4 \n255646,testcenter5';
        Blob csvblob=Blob.valueOf(csvstring);
        importDataFromCSVController csvcont=new importDataFromCSVController();
        
        
        PageReference pageref=new PageReference('/apex/importTool');
        
        Test.setCurrentPage(pageref);
        ApexPages.currentPage().getParameters().put('Id', c.Id);
     
        csvcont.csvFileBody=csvblob;
        csvcont.importCSVFile();
        //csvcont.attachtocase();
        
    }
    private static void createclients()
    {
        Account testc1=new Account();
        testc1.Name='test client1';
        testc1.VTS_Test_Center_ID__c=465566;
        
        Account testc2=new Account();
        testc2.Name='test client2';
        testc2.VTS_Test_Center_ID__c=45565;
        
        Account testc3=new Account();
        testc3.Name='test client3';
        testc3.VTS_Test_Center_ID__c=456552;
        
        Account testc4=new Account();
        testc4.Name='test client4';
        testc4.VTS_Test_Center_ID__c=585452;
        
        Account testc5=new Account();
        testc5.Name='test client5';
        testc5.VTS_Test_Center_ID__c=255646;
        
        insert new List<Account>{ testc1,testc2,testc3,testc4,testc5 };
            }
    static testMethod void testcreatecase()
    {	
        Routing__c r=new Routing__c();
        r.Name='testrouting';
        insert r;
        
        Step__c st=new Step__c();
        st.Name='initial step';
        st.Step_Number__c=2;
        st.Routing__c=r.Id;
        insert st;
       
        Case c=new Case();
        c.Subject='test subject';
        c.Step__c=st.Id;
        insert c;
       
        String cases='Id,subject\n5456585, mental health case\n55255, physically disabled people case\n585585, etc etc case';
        Blob csvblob=Blob.valueOf(cases);
       
        importDataFromCSVController csvcont=new importDataFromCSVController();
        
        PageReference pageref=new PageReference('/apex/importTool');
 		Test.setCurrentPage(pageref);
        ApexPages.currentPage().getParameters().put('Id', c.Id);
        
        csvcont.csvFileBody=csvblob;
        csvcont.importCSVFile();
        
        PageReference ref= csvcont.createcases();
       
      
        PageReference dref= csvcont.done();
         System.assert(dref!=Null);
        
        
        
    }
    static testMethod void testcreatecancelcase()
    {	
        Routing__c r=new Routing__c();
        r.Name='testrouting';
        insert r;
       
        Step__c st=new Step__c();
        st.Name='initial step';
        st.Step_Number__c=2;
        st.Routing__c=r.Id;
        insert st;
       
        Case c=new Case();
        c.Subject='test subject';
        c.Step__c=st.Id;
        insert c;
      
        String cases='Id,subject\n5456585, mental health case\n55255, physically disabled people case\n585585, etc etc case';
        Blob csvblob=Blob.valueOf(cases);
        importDataFromCSVController csvcont=new importDataFromCSVController();
        PageReference pageref=new PageReference('/apex/importTool');
        
        Test.setCurrentPage(pageref);
        ApexPages.currentPage().getParameters().put('Id', c.Id);
        
        csvcont.csvFileBody=csvblob;
        csvcont.importCSVFile();
        PageReference ref= csvcont.createcases();
        System.assert(ref==null);
        PageReference dref= csvcont.cancel();
        System.assert(dref==pageref);
        
        
        
    }
    
}