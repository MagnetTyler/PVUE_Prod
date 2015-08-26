@isTest
public with sharing class TestUtil {

  public static User createUser(){    
        User testUser = new User();
        Long randomValue = Math.roundToLong(Math.random() * Double.valueOf('10000000000000000.0'));
        
      //  Double randomValue = Math.random();
        testUser.Username= 'testUser1'+ randomValue +'@company.com';
        testUser.Email = 'testUser1'+ randomValue +'@company.com'; 
        testUser.Lastname = 'user' + randomValue; 
        testUser.Firstname = 'test';
        testUser.Alias = 'test';
        testUser.CommunityNickname = '12346'+ randomValue;
        testUser.ProfileId = UserInfo.getProfileId();
        testuser.Primary_team_persona__c = 'VSSL1;VSSL2;Mgmt';
        testUser.TimeZoneSidKey = 'GMT';
        testUser.LocaleSidKey = UserInfo.getLocale();
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.IsActive = true;
        
        return testUser;
    }
    
    public static User createCommunityUser(Boolean doInsert) {
        return createCommunityUser(doInsert, null);
    }
    public static User createCommunityUser(Boolean doInsert, Contact testContact) {
        return createCommunityUser( doInsert,  testContact , 'Test Center Admin - Community' );
    }
    public static User createCommunityUser(Boolean doInsert, Contact testContact, string profileName ) {
      User testUser = createUser();
        if(testContact==Null)
        { testContact = createContact(true);}
      Profile p = [SELECT Id FROM Profile WHERE Name =: profileName  LIMIT 1];
      testUser.ProfileId = p.Id;
      testUser.ContactId = testContact.Id;
      
      if(doInsert) {
        try{
        insert testuser;
            }
        catch( system.dmlException concurrencyerror)
            {
                testuser = [select id from user where username = : testuser.username];
                if(testuser == null)
                {
                insert testuser;
                }
            }    
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
    
           PermissionSetassignment PSA = new PermissionSetAssignment(AssigneeId = testuser.id, PermissionSetId =  [SELECT id, label from PermissionSet where Label = 'TA' limit 1].id);
            insert psa;
            }    
      }
      
      return testUser;
    }
    
  
    public static Contact createContact(Boolean doInsert) {
        return createContact(doInsert, null);
    }

    public static Contact createContact(Boolean doInsert, Account testAccount) {
        Contact testContact = new Contact();
        if (testAccount == null) {
            testAccount = createAccount();
            insert testAccount;
        }
      
      String randomStr = Datetime.now().format();
      randomStr = randomStr.replace(' ', '').replace('/', '').replace(':', '');
      
      testContact.LastName = 'Tester ' + randomStr;
      testContact.Email = randomStr + '@pearson.com.testing';
      testContact.AccountId = testAccount.Id;
      
      if(doInsert) {
        insert testContact;
      }
      return testContact;
    }
    
    public static Account createAccount() {
      Account testAccount = new Account( Name = 'Test Account' );
      return testAccount;
    }

    public static Account createTestCenterAccount(Boolean doInsert, Long vtsSiteId) {
      Account testAccount = new Account( Name = 'Test Account' );
        testAccount.RecordTypeId=[Select Id from RecordType where name='Site' limit 1].Id;
        testAccount.VTS_Test_Center_ID__c = vtsSiteId != null ? vtsSiteId : Math.mod(Math.abs(Crypto.getRandomInteger()), 62);            
        if( doInsert ) {
            insert testAccount;
        }
      return testAccount;
    }
    
    public static Account createClientAccount(Boolean doInsert) {
        return createClientAccount(doInsert, 72);
    }
    public static Account createClientAccount(Boolean doInsert, Long vtsClientId) {
      Account testAccount = new Account( Name = 'Test Client count' );
        testAccount.RecordTypeId=[Select Id from RecordType where name='Client' limit 1].Id;
        testAccount.VTS_Client_ID__c = vtsClientId;
        if(doInsert)
        {insert testAccount;}
      return testAccount;
    }

    public static Case createCase( Boolean doInsert, ID recordTypeId ){
        Case c = new Case();
        c.RecordTypeId = recordTypeId;
        
        if( doInsert )
            insert c;
        
        return c;
    }
    public static Case_API_Field__c createCaseApiField( Boolean doInsert, string apiField ){
        Case_API_Field__c c = new Case_API_Field__c();
        c.Case_Field__c = apiField;
        c.name = 'CaseAPIField';
        
        if( doInsert )
            insert c;
        
        return c;
    }

    public static Registration__c createdRegistration( Boolean doInsert ){
        Registration__c r = new Registration__c();
        r.VTS_Registration_ID__c = Math.random();
        
        if( doInsert ) 
            insert r;
        
        return r;
    }
    
    public static Exam__c createExam( Boolean doInsert ){
        
        Exam__c e = new Exam__c();
        
        if( doInsert ) 
            insert e;
        
        return e;
    }
    
    public static Candidate__c createCandidate( Boolean doInsert ){
        Candidate__c c = new Candidate__c();
        
        if( doInsert ) 
            insert c;
        
        return c;
    }
    
    public static Step__c createStep( Boolean doInsert ){
        
        Step__c s = new Step__c();
        
        if( doInsert ) 
            insert s;
        
        return s;
    }
}