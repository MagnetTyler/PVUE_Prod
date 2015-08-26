@isTest
public class AdvancedSearchControllerTest {
    /*
    static testMethod void dosearchtest()
    {
        Account acc= new Account();
        acc.name = 'test acc';
        acc.VTS_Client_ID__c = 234;
        acc.RecordTypeId = [select Id from RecordType where Name = 'Client' and sObjectType = 'Account'].Id;
        insert acc;
        
        PageReference adref=Page.Advanced_Search;
        test.setCurrentPage(adref);
        AdvancedSearchController ad = new AdvancedSearchController();
        ad.Regcriteria1 = 'test@test.com';
        ad.Regcriteria2 = '123';
        //ad.selectedAdvanceCriteria = 'Email Address';
        
        system.assert( ad.countries != null );
        system.assert( ad.Clientlist != null );
        system.assert( ad.states != null );
        system.assert( ad.selectedAdvanceCriteria != null);
        system.assert( ad.advanceCriteriaOptions != null);
        system.assert( ad.isBackToSearch != null);
        system.assert( ad.selectedAdvanceCriteria != null);
        system.assert( ad.clientMap != null);
        ad.advancedOptions();
        ad.backToSearch();
        ad.isAdvancedOptions = false;
        
        ad.dosearch();
        ad.isAdvancedOptions = true;
        
        ad.selectedAddressOne = 'address one';
        ad.selectedAddressTwo = 'address two';
        ad.selectedCity = 'NY';
        ad.selectedcountry = 'USA';
        ad.selectedState = 'NY';
        
        ad.selectedAdvanceCriteria = 'Email Address';
        ad.dosearch();
        
        ad.selectedAdvanceCriteria = 'CCID';
        ad.dosearch();
        
        ad.selectedAdvanceCriteria= 'First and Last Name';
        ad.dosearch();
        
        ad.Regcriteria1 = 'test test';
        ad.dosearch();
        
        ad.clearsearch();
        
    }*/
  
    static testMethod void getRegistrationApiReturnstest()
    {
        DataFactory.createSettings();
        DataFactory.createWebServiceSettings();
        PageReference adref=Page.Advanced_Search;
        test.setCurrentPage(adref);
        AdvancedSearchController ad=new AdvancedSearchController();
        //ad.searchtype='Registration ID';
       // ad.Registrationsearchtype='CC ID';
        ad.Regcriteria1='8909000';
        ad.Regcriteria2='2506925';
        ad.selectedAdvanceCriteria = 'Phone number';
        ad.isAdvancedOptions = true; 
        ad.selectedcountry = 'America';
        ad.selectedState = 'NY';
        ad.selectedCity = 'NY';
        ad.selectedAddressOne = 'test address one';
        ad.selectedAddressTwo = 'test address two';
        
        Test.startTest();
        ad.dosearch();
        system.assertequals(true, ad.isadvancedOptions);
        ad.advancedoptions();
        ad.getRegistrationApiReturns();
        system.assertnotequals(ad.clientlist, null);
        system.assertequals(ad.returnId, null);
        system.assertequals(ad.startdate, null);
        system.assertequals(ad.enddate, null);

        system.assertnotequals(ad.clientmap, null);
        system.assertnotequals(ad.advanceCriteriaOptions, null);
        
        
        Test.stopTest();
        System.assertNotEquals(0, ad.RegistrationApiReturns.size());
         ad.backtoSearch();
        ad.getCandidateRows();
        ad.getsiteAdvanced();
       
        ad.getTestCenters();
         ad.clearsearch();
         ad.clearentries();
          ad.Old_clearsearch();
        //System.assertEquals(Null, ad.RegistrationApiReturns);
        
        ad.Regcriteria1=null;
        ad.Regcriteria2=null;
        ad.dosearch();
        
    
        ad.Registrationsearchtype=null;   
        ad.dosearch();
        ad.Sitecriteria1 = '8909000';
        ad.Sitecriteria2 = '2506925';
        ad.do_oldsearch();
        system.assertequals(ad.SiteAdvanced, null);
        system.assertNotEquals(null, ad.countries);
        system.assertnotequals(null, ad.states);
    }

    
      /*
    static testMethod void getRegistrationApiReturnsVUEIDtest()
    {
        DataFactory.createSettings();
        DataFactory.createWebServiceSettings();
        PageReference adref=Page.Advanced_Search;
        test.setCurrentPage(adref);
        AdvancedSearchController ad=new AdvancedSearchController();
        ad.searchtype='Registration ID';
        ad.Registrationsearchtype='Student or VUE ID';
        ad.Regcriteria1='214302';
        //ad.Regcriteria2='54';
        
        Test.startTest();
        ad.dosearch();
        
        ad.getRegistrationApiReturns();
        Test.stopTest();
        System.debug('RK: vue resp:'+ ad.getRegistrationApiReturns());
        System.assertNotEquals(0, ad.RegistrationApiReturns.size());
    }
     
    static testMethod void savetest()
    {       
       createAccounts(); 
        DataFactory.createSettings();
        DataFactory.createWebServiceSettings();
        PageReference adref=Page.Advanced_Search;
        test.setCurrentPage(adref);
        ApexPages.currentPage().getParameters().put('myParam', '428527');
        AdvancedSearchController ad=new AdvancedSearchController();
        
        ad.setearchtype('test');
        ad.setpagetype('test');
        ad.settestcenters(new list<Account>());
        //ad.setRegistrationApiReturns(new list<decoratedVTS_Registration>());
        ad.setValueToVariable();
        
        Test.startTest();
       
       String s= ad.dosave();
      
        Test.stopTest();
        System.debug('RK: '+s);
        System.assertNotEquals(Null, s);
    }
      static testMethod void getcandidatestest()
    {
        Account ac=TestUtil.createTestCenterAccount(true, null);
        Contact c=TestUtil.createContact(true,ac);
        User u=TestUtil.createCommunityUser(true, c);
       
        System.runAs( u ){
        System.debug('RK: vys_ '+ac.VTS_Test_Center_ID__c);
        DataFactory.createSettings();
        DataFactory.createWebServiceSettings();
        PageReference adref=Page.Advanced_Search;
        test.setCurrentPage(adref);
        AdvancedSearchController ad=new AdvancedSearchController();
        ad.pagetype='Community';
        ad.startdate=String.valueOf(System.today() - 10);
        ad.enddate=String.valueOf(System.today());
        
        Test.startTest();
        ad.dosearch();
        Test.stopTest();
            System.assertNotEquals(0, ad.CandidateResults.size());
             ad.setRegistrationApiReturns(null);
             system.assert(ad.returnid == null);
             system.assert(ad.pagesource == null);
             system.assert(ad.paramvalue == null);
             system.assert(ad.examid == null);
             system.assert(ad.candidateid == null);
             system.assert(ad.Sitesearchtype == null);
             system.assert(ad.dRegistrationApiReturns == null);
        }
       
    }
    private static List<Account> createAccounts()
    {
        Account testc1=new Account();
        testc1.Name='test client1';
        testc1.Phone='52555';
        
        Account testc2=new Account();
        testc2.Name='test client2';
        testc2.Phone='52555';
        
        Account testc3=new Account();
        testc3.Name='test client3';
        testc3.Phone='52555';
        
        Account testc4=new Account();
        testc4.Name='test client4';
        testc4.Phone='52555';
        
        Account testc5=new Account();
        testc5.Name='test client5';
        testc5.RecordTypeId=[select Id from recordtype where name='Client' limit 1].Id;
        testc5.VTS_Client_ID__c=72;
        List<Account> acc=new List<Account>{ testc1,testc2,testc3,testc4,testc5 };
            insert acc;
        return acc;
    }
   */
}