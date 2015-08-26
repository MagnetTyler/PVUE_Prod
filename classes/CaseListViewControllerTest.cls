@isTest
private class CaseListViewControllerTest {
    static Routing__c routing;
    static List<Step__c> routingSteps;
    static List<Routing_logic__c> routingLogics;
    static List<Step__c> routingSteps2;
    static List<Routing_logic__c> routingLogics2;
    static Org_Settings__c settings;
    
    static void setupData() {
        settings = DataFactory.createSettings();
        
        List<Case_Topic_And_Category__c> caseAndTopics = DataFactory.createCaseAndTopicCategories();
        routing = DataFactory.createPowerOutageRouting();
        routingSteps = DataFactory.createPowerOutageRoutingSteps(routing.Id);
        System.debug('routingSteps: ' + routingSteps);
        routingLogics = DataFactory.createPowerOutageRoutingLogics(routingSteps);
        
        insert
            new Account(
                Name = 'Test Client', VTS_Client_ID__c = 72,
                RecordTypeId = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId());
    }
    

    static testMethod void testEditRegistrationCase() {
        
       
        user u = testutil.createUser(); 
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Internal common settings profile' LIMIT 1].id;
        insert u;
        
        setupData();
        System.runas(u)
        {
            
            Case cs = 
                new Case(
                    Did_the_candidate_comment_complain__c = 'Yes', 
                    What_Time_did_the_Power_Outage_Start__c = System.now().addHours(-10),
                    What_Time_did_the_Power_Outage_Stop__c = System.now().addHours(-8), 
                    Topic__c = 'Exam or delivery issues',
                    Final_Category__c = 'Power outage', Step__c = routingSteps[0].Id,
                    RecordTypeId = Schema.SobjectType.Case.getRecordTypeInfosByName().get('Exam delivery issue').getRecordTypeId());
            insert cs;
        
        case ncase = [ select id, Did_the_candidate_comment_complain__c , What_Time_did_the_Power_Outage_Start__c,
                  What_Time_did_the_Power_Outage_Stop__c ,  Topic__c, Final_Category__c , Step__c 
                  from case where  RecordTypeId =: Schema.SobjectType.Case.getRecordTypeInfosByName().get('Exam delivery issue').getRecordTypeId()
                   limit 1];
            Test.startTest();
            Test.setCurrentPage(Page.CaseListView);
            List<CaseListViewController.CaseAccess> caseAccess = CaseListViewController.getUserCaseAccess(ncase.Id);
            CaseListViewController.reassignCases(ncase.Id, UserInfo.getUserId());
            CaseListViewController controller = new CaseListViewController();
            controller.updateableCaseId = ncase.Id;
            controller.acceptCase();
            controller.closeCase();
            
            ApexPages.StandardSetController stdSetCntrlr 
                = new ApexPages.StandardSetController(new List<Case>{ncase});
            CaseListViewController c = new CaseListViewController(stdSetCntrlr);
            
            Test.stopTest();
            
            System.assertEquals(1, caseAccess.size());
            /*System.assert(caseAccess[0].canEdit);
            System.assert(caseAccess[0].canClose);
            System.assert(caseAccess[0].canAccept);*/
            //need to add new user with mgmt profile and update method************
            system.assert(c.showAssignButton == null);
            }
            settings.Case_Mass_Assign_Profiles__c = [select Name from Profile where Id != :UserInfo.getProfileId() limit 1].Name;
          //  update settings;
       
    }
   
    static testMethod void testEditRegistrationCaseOne() {
        
        user u = testutil.createUser(); 
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Internal common settings profile' LIMIT 1].id;
        u.Primary_team_persona__c = 'Share Accounts,VSS L1,Mgmt,CS,CQ,Sales,PM,PC,Fulfillment,RP,AS,TP,CSR,HotList Admin,Knowledge';
        insert u;
    
        
        
          setupData();
        System.runas(u)
        { 
          
            settings.Case_Mass_Assign_Profiles__c = [select Name from Profile where Id != :UserInfo.getProfileId() limit 1].Name;
           // update settings;
            
            Case cs = 
                new Case(
                    Did_the_candidate_comment_complain__c = 'Yes', 
                    What_Time_did_the_Power_Outage_Start__c = System.now().addHours(-10),
                    What_Time_did_the_Power_Outage_Stop__c = System.now().addHours(-8), 
                    Topic__c = 'Exam or delivery issues',
                    Final_Category__c = 'Power outage', Step__c = routingSteps[0].Id,
                    RecordTypeId = Schema.SobjectType.Case.getRecordTypeInfosByName().get('Exam delivery issue').getRecordTypeId());
            insert cs;
        
        
        case ncase = [ select id, Did_the_candidate_comment_complain__c , What_Time_did_the_Power_Outage_Start__c,
                      What_Time_did_the_Power_Outage_Stop__c ,  Topic__c, Final_Category__c , Step__c 
                      from case limit 1];
        
            Test.startTest();
            Test.setCurrentPage(Page.CaseListView);
            List<CaseListViewController.CaseAccess> caseAccess = CaseListViewController.getUserCaseAccess(ncase.Id);
            CaseListViewController.reassignCases(ncase.Id, UserInfo.getUserId());
            CaseListViewController controller = new CaseListViewController();
            controller.updateableCaseId = ncase.Id;
            controller.acceptCase();
            controller.closeCase();
            
            ApexPages.StandardSetController stdSetCntrlr 
                = new ApexPages.StandardSetController(new List<Case>{ncase});
            CaseListViewController c = new CaseListViewController(stdSetCntrlr);
            
            Test.stopTest();
            
            System.assertEquals(1, caseAccess.size());
            System.assert(caseAccess[0].canEdit);
            //System.assert(caseAccess[0].canClose);
            //System.assert(caseAccess[0].canAccept);
            //system.assert(c.showAssignButton != null);
        } 
        }
        
    }