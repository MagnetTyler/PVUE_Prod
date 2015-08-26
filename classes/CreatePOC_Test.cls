@isTest
private class CreatePOC_Test {

    static user communityuser;
    static user internalu = datafactory.createuser();
    static Routing__c routing;
    static List<Step__c> routingSteps;
    static List<Routing_logic__c> routingLogics;
    static Routing__c routing2;
    static List<Step__c> routingSteps2;
    static List<Routing_logic__c> routingLogics2;
    static Routing__c routing3;
    static List<Step__c> routingSteps3;
    static List<Routing_logic__c> routingLogics3;
    static user u2;
    static void setupData() {
        system.runAs(new user( id = userinfo.getuserid()))
        {
            DataFactory.createSettings();
            DataFactory.createWebServiceSettings();
            
            List<Case_Topic_And_Category__c> caseAndTopics = DataFactory.createCaseAndTopicCategories();
            routing = DataFactory.createPowerOutageRouting();
            routingSteps = DataFactory.createPowerOutageRoutingSteps(routing.Id);
            System.debug('routingSteps: ' + routingSteps);
            routingLogics = DataFactory.createPowerOutageRoutingLogics(routingSteps);
            
            routing2 = DataFactory.createBackupBiometricRouting();
            routingSteps2 = DataFactory.createBackupBiometricSteps(routing2.Id);
            System.debug('routingSteps: ' + routingSteps);
            routingLogics2 = DataFactory.createBackupBiometricRoutingLogics(routingSteps2);
            routing3 = DataFactory.createAdministratorError();
            routingSteps3 = DataFactory.createAdminErrorSteps(routing3.id);
            routingLogics3 = DataFactory.createAdminErrorRoutingLogics(routingsteps3);
            
            ID clientRecTypeId = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
            insert
                new List<Account>{
                    new Account(Name = 'Test Client 72', VTS_Client_ID__c = 72, RecordTypeId = clientRecTypeId, Result_hold_categories__c = 'Power outage'),
                        new Account(Name = 'Test Client 54', VTS_Client_ID__c = 54, RecordTypeId = clientRecTypeId, Result_hold_categories__c = 'Power outage')};
                            u2 = datafactory.createUser();    
            
            
            System.runAs( new User(Id = UserInfo.getUserId()) ) {
                communityUser = createcommunityUser();
            }
        }

    }
    
    static user createcommunityUser(){
         
             Account a = new Account(
                Name = 'Test Testing Center', VTS_Test_Center_ID__c = 1061,
                RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId());
        
        string myprofile = [select name, id from profile where name = 'Test Center Admin - Community'].id;
        
        Contact c = 
            new Contact( firstname = 'Testing Site', lastname = 'Administrator');   
            
        
        user myowner = testUtil.createUser();
        
        Schema.DescribeFieldResult F = User.PortalRole.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        myowner.Primary_team_persona__c = 'VSSL1;System Administrator';
        string myroleid = [select name, id from userrole where name = 'Administrator'].id;
        myowner.UserRoleId = myroleid;
        myowner.PortalRole = P[0].getvalue();
        insert myowner;
        
        
        User u = TestUtil.createUser();
            
        
        system.runAs(myowner){
        insert a;
        
        c.Accountid = a.id;     
        insert c;   
        
            u.contactid = c.id;
            u.ProfileId = myprofile;
            u.CommunityNickname = 'testcu';
            u.Primary_team_persona__c = 'TA';
            
        insert u;}
        
        permissionsetassignment psa = new permissionsetassignment(AssigneeId = u.id, PermissionSetId = [SELECT id, label from PermissionSet where Label = 'TA' limit 1].id);
        insert psa;
        update u;
        
        return u;   
    }
    
   //new method for delete case
static testMethod void testDeleteNewRegistrationCase() {

       
            setupData();
        
        system.runAs(internalu){
        Test.setCurrentPage(Page.CreateCasePOC);
        pagereference pr = system.currentpagereference();
       
        CreatePoc cntrlr = new CreatePoc(new ApexPages.StandardController(new Case()));
        
        cntrlr.getTopics();
        cntrlr.getcategories();
        cntrlr.getsubcategories();
        cntrlr.getpagetype();

        // Select an option in 'Create a case using' field
        cntrlr.CaseType = system.label.Registration_Id;
        cntrlr.clearfinalcat();
        cntrlr.getTopics();
        cntrlr.getcategories();
        cntrlr.getsubcategories();

        // Enter Reg ID
        cntrlr.EnteredId = '428527';
        system.assertequals(cntrlr.EnteredId, '428527');
        cntrlr.Retrieve_Reg_or_Site();
        System.assertNotEquals(null, cntrlr.caseRegistration);
        System.assertNotEquals(null, cntrlr.caseRegistration.Id);


        cntrlr.getTopics();
        cntrlr.getcategories();
        cntrlr.getsubcategories();

        // Select Topic
        cntrlr.setmyTopic('Registration/appointment issues');
        cntrlr.clearfinalcat();

        cntrlr.getTopics();
        cntrlr.getcategories();
        cntrlr.getsubcategories();

        // Select Category
        cntrlr.setmyCategory('Client request to override');
        cntrlr.clearsubcat();
        cntrlr.getTopics();
        cntrlr.getcategories();
        cntrlr.getsubcategories();

        // Select Sub-Category
        cntrlr.setmyTopic('Exam delivery');
        cntrlr.setmyCategory('Power outage');
        

        cntrlr.finalcat = 'Power outage';
        system.assertnotequals(null, cntrlr.mycaseconfig);
        system.assertequals('Power outage', cntrlr.finalcat);
        //cntrlr.clearfinalcat();
       // cntrlr.getTopics();
       // cntrlr.getcategories();
       // cntrlr.getsubcategories();

       //fixing bug deploying to prod

        string query = 'Select ';                   
        //string mytype = Schema.Sobjecttype.Case.getRecordTypeInfosById().get(mycase.recordtypeid).getname();
        query += utility.Editablefields('Routing__c');
        query += ', (Select ' + utility.Editablefields('Step__c');
        query += ' FROM steps__r '; //where RecordTypeId = \'' + STEP_REC_TYPE_ROUTING_STEP + '\' + 
        query += ' Order By Step_number__c ASC LIMIT 1 )';
        query += ' FROM Routing__c WHERE Final_Category_Name__c = \'Power outage\'';                                   
        routing__c c = database.query(query);
        cntrlr.mycaseconfig = c;

       //


        cntrlr.getSection1FS();
        cntrlr.getSection2FS();
        cntrlr.getSection3FS();
        cntrlr.getSection4FS();
        cntrlr.getSection5FS();
        cntrlr.getSection6FS();
        cntrlr.getSection7FS();
        cntrlr.getSection8FS();
        cntrlr.getSection9FS();
        cntrlr.getSection10FS();
        cntrlr.savecase();
        cntrlr.deleteCase();

    }
}
    //end delete case method


    static testMethod void testNewRegistrationCase() {

       
            setupData();
        
        system.runAs(internalu){
        Test.setCurrentPage(Page.CreateCasePOC);
        pagereference pr = system.currentpagereference();
        pr.getparameters().put('accountid',[select id from account limit 1].id );
        CreatePoc cntrlr = new CreatePoc(new ApexPages.StandardController(new Case()));
        
        cntrlr.getTopics();
        cntrlr.getcategories();
        cntrlr.getsubcategories();
        cntrlr.getpagetype();

        // Select an option in 'Create a case using' field
        cntrlr.CaseType = 'Registration ID';
        cntrlr.clearfinalcat();
        cntrlr.getTopics();
        cntrlr.getcategories();
        cntrlr.getsubcategories();

        // Enter Reg ID
        cntrlr.EnteredId = '428527';
        system.assertequals(cntrlr.EnteredId, '428527');
        cntrlr.Retrieve_Reg_or_Site();
        System.assertNotEquals(null, cntrlr.caseRegistration);
        System.assertNotEquals(null, cntrlr.caseRegistration.Id);

        cntrlr.getTopics();
        cntrlr.getcategories();
        cntrlr.getsubcategories();

        // Select Topic
        cntrlr.setmyTopic('Registration/appointment issues');
        cntrlr.clearfinalcat();

        cntrlr.getTopics();
        cntrlr.getcategories();
        cntrlr.getsubcategories();

        // Select Category
        cntrlr.setmyCategory('Client request to override');
        cntrlr.clearsubcat();
        cntrlr.getTopics();
        cntrlr.getcategories();
        cntrlr.getsubcategories();

        // Select Sub-Category
        cntrlr.setmyTopic('Exam delivery');
        cntrlr.setmyCategory('Power outage');
        

        cntrlr.finalcat = 'Power outage';
        //cntrlr.clearfinalcat();
       // cntrlr.getTopics();
       // cntrlr.getcategories();
       // cntrlr.getsubcategories();

        cntrlr.getSection1FS();
        cntrlr.getSection2FS();
        cntrlr.getSection3FS();
        cntrlr.getSection4FS();
        cntrlr.getSection5FS();
        cntrlr.getSection6FS();
        cntrlr.getSection7FS();
        cntrlr.getSection8FS();
        cntrlr.getSection9FS();
        cntrlr.getSection10FS();

        system.assertnotequals(null,cntrlr.myCaseConfig);
        
        System.assertNotEquals(null, cntrlr.sectionsWithSubSection);
        System.assertNotEquals(0, cntrlr.sectionsWithSubSection.size());
        system.assertNotEquals(null, cntrlr.buttonmap);
        system.debug(cntrlr.newbuttonmap);
        
        
        Map<String, List<Schema.FieldSetMember>> dynamicFieldsMap = cntrlr.getSectionToDynamicFieldsMap();
        System.assertNotEquals(null, dynamicFieldsMap);
        System.assertNotEquals(0, dynamicFieldsMap.size());

        cntrlr.mycase.What_Time_did_the_Power_Outage_Start__c = System.now().addHours(-10);
        cntrlr.mycase.What_Time_did_the_Power_Outage_Stop__c = System.now().addHours(-8);
        cntrlr.mycase.Did_the_candidate_comment_complain__c = 'Yes'; 
       cntrlr.getnumberofattachements();
       cntrlr.setnumberofattachments(cntrlr.numberofattachements);

        system.assertequals('Power outage', cntrlr.finalcat);
        system.assertequals(routingsteps[0].id, cntrlr.myCaseConfig.steps__r[0].id);
        cntrlr.submitcase();
        system.assertnotequals(null, cntrlr.mycase.Step__c);
        ID caseId = cntrlr.getCaseId();
      //  system.assertequals(true, cntrlr.newbuttonmap.get('Reschedulebutton'));
       attachment a = new attachment();
       a.ParentId = cntrlr.mycase.id;
       a.Description = 'abc';
       a.name = 'abesr';
       a.body = blob.valueof('12315lkjasldkf');
       insert a;
       createPOC.CaseAttachment ca = new CreatePOC.CaseAttachment(a);
       cntrlr.attachments.add(ca);
       
       system.assertequals(cntrlr.numberofattachements, 0);
       system.assertequals(cntrlr.attachmentadded, true);   
        System.assertNotEquals(null, caseId);
        
        Case dbCase = [select Status__c, Step__c from Case where Id = :caseId];
        System.assertEquals('Being Created', cntrlr.mycase.Status__c);
        System.assertEquals(routingSteps[1].Id, dbCase.Step__c);
    }
    }

    static testMethod void testEditRegistrationCase() {

        setupData();
        system.runas(internalu)
        {
        //create case and it starts on the route to PC step 
        Case cs = 
            new Case(
                Did_the_candidate_comment_complain__c = 'Yes', 
                What_Time_did_the_Power_Outage_Start__c = System.now().addHours(-10),
                What_Time_did_the_Power_Outage_Stop__c = System.now().addHours(-8), 
                Topic__c = 'Exam or delivery issues',
                Final_Category__c = 'Power outage', Step__c = routingSteps[0].Id,
                Routing__c = routing.id,
                Status__c = 'Awaiting Pickup',
                Status = 'Awaiting Pickup',
                RecordTypeId = Schema.SobjectType.Case.getRecordTypeInfosByName().get('Exam delivery issue').getRecordTypeId());
        insert cs;

        // Edit Case
        //Test.setCurrentPage(new PageReference('/' + cs.Id + '&retURL=/home/home.jsp'));
        
        Test.setCurrentPage(new PageReference('/apex/CreateCasePOC?id=' + cs.Id + '&retURL=/home/home.jsp'));
        pagereference pr = system.CurrentPageReference();
        pr.getparameters().put('feedback', 'savesuccess');
        
        

        CreatePoc cntrlr = new CreatePoc(new ApexPages.StandardController(cs));
        
        system.assertequals(cntrlr.comment, system.label.Case_Saved);
        cntrlr.getpagecontext();
        cntrlr.setpagecontext(cntrlr.pagecontext);
        cntrlr.redirect();
        cntrlr.getSection1FS();
        cntrlr.getSection2FS();
        cntrlr.getSection3FS();
        cntrlr.getSection4FS();
        cntrlr.getSection5FS();
        cntrlr.getSection6FS();
        cntrlr.getSection7FS();
        cntrlr.getSection8FS();
        cntrlr.getSection9FS();
        cntrlr.getSection10FS();
        cntrlr.emailadded = true;
        cntrlr.ownerchange = false;
        cntrlr.ownereturn = false;
        cntrlr.commentsaved = true;
        cntrlr.ownername = 'mytest';
        cntrlr.displayComment = false;
        system.assertequals(null, cntrlr.myagents);
        system.assertequals(cntrlr.feedback, true);
        pr.getparameters().put('feedback', 'submitsuccess');
        system.assertequals(cntrlr.comment, system.label.case_submitted);

        cntrlr.mycase.Were_they_allowed_to_test__c = 'No';
        cntrlr.mycase.Did_you_offer_the_candidate_a_reschedule__c = 'No'; 
        //BW change based on new fx.  using savecase and assert that status is not changed and owner is not changed
        //bb submitcase and assert status has moved and owner is changed
        //cntrlr.submitcase();
        //cntrlr.savecase();
        system.assertNotEquals(null, cntrlr.myCaseConfig);
        system.assertEquals(cs.status__c, [select id, status__c from Case where id = :cntrlr.mycase.id].status__c);
        system.assertEquals(Userinfo.getuserid(), [select id, ownerid from case where id = :cs.id].ownerid);

        //cs.Status__c = 'Move to next step';
        step__c current = [select id, step_number__c, Has_forked_logic__c, go_to_step__c, routing__c, who_is_doing_the_work__c from step__c where id =: cntrlr.mycase.step__c];
        step__c nextstep = utility.getnextstep(cntrlr.mycase, current);
        system.assertequals(1, current.step_number__c);
        system.assertequals(2, [select step_number__c, id from step__c where id =: nextstep.id].step_number__c);
        system.assertequals(true, current.Has_forked_logic__c);
        system.assertNotEquals(null, cntrlr.myCaseConfig);
        cntrlr.casecomment = new casecomment(ParentId = cntrlr.mycase.id, commentbody = 'test');
        cntrlr.submitCaseComment();
        system.assertNotEquals(cntrlr.CaseComments, null);
        cntrlr.casecomment = new casecomment(ParentId = cntrlr.mycase.id, commentbody = 'test2');
        cntrlr.cancelCaseComment();
        cntrlr.showAddComment();
        cntrlr.clearnotification();


        cntrlr.mycaseconfig = routing;
        cntrlr.getitems();
        cntrlr.submitcase();
        cntrlr.takeownership();
        cntrlr.cancelbutton();
        cntrlr.getnextstep();
        cntrlr.takeownership();
        cs.ownerid = [select id from user where isactive = true limit 1].id;
        user newuser = datafactory.createuser();
        cntrlr.mycase.ownerid = newuser.id;
        cntrlr.selectmanualrouting();
        update cs;
        cs = withoutsharingUtility.getPreviousvalue(cs);
       // system.assertequals(1, [select id, Step_number__c from Step__c where id = :cntrlr.mycase.Step__c].step_number__c);
       // cntrlr.redirect();
       // cntrlr.mycase.Did_the_candidate_comment_complain__c = 'Yes';
       // cntrlr.submitcase();
       // cntrlr.redirect();
       // case updated = [select casenumber, id, routing__c, step__c from case where id = :cs.id];
       // system.assertequals(2, [select id, Step_number__c from Step__c where id = :updated.Step__c].step_number__c);
       // system.assertEquals('Working' , [SELECT id, status__c from Case where id = :updated.id].status__c);
       // system.assertEquals(Userinfo.getuserid(), [select id, ownerid from case where id = :cs.id].ownerid);
        cntrlr.cancelbutton();

        //Case dbCase = [select Status__c, Step__c from Case where Id = :cs.Id];
//        System.assertEquals(routingSteps[1].Id, dbCase.Step__c);
//        System.assertEquals('Working', dbCase.Status__c);
        
        CreatePoc cntrlr2 = new CreatePoc(new ApexPages.StandardController(cntrlr.mycase));
        cntrlr2.redirect();
               // system.assertNotEquals(null, cntrlr2.getdefaultTeamId());
        }
        
    }

// new test method for lateral assign
/*
static testMethod void testEditRegistrationCase() {

        setupData();
        system.runas(internalu)
        {
        //create case and it starts on the route to PC step 
        Case cs = 
            new Case(
                Did_the_candidate_comment_complain__c = 'Yes', 
                What_Time_did_the_Power_Outage_Start__c = System.now().addHours(-10),
                What_Time_did_the_Power_Outage_Stop__c = System.now().addHours(-8), 
                Topic__c = 'Exam or delivery issues',
                Final_Category__c = 'Power outage', Step__c = routingSteps[0].Id,
                Routing__c = routing.id,
                Status__c = 'Awaiting Pickup',
                Status = 'Awaiting Pickup',
                RecordTypeId = Schema.SobjectType.Case.getRecordTypeInfosByName().get('Exam delivery issue').getRecordTypeId());
        insert cs;

        // Edit Case
        //Test.setCurrentPage(new PageReference('/' + cs.Id + '&retURL=/home/home.jsp'));
        
        Test.setCurrentPage(new PageReference('/apex/CreateCasePOC?id=' + cs.Id + '&retURL=/home/home.jsp'));
        pagereference pr = system.CurrentPageReference();
        pr.getparameters().put('feedback', 'savesuccess');
        
        

        CreatePoc cntrlr = new CreatePoc(new ApexPages.StandardController(cs));
        
        system.assertequals(cntrlr.comment, system.label.Case_Saved);
        cntrlr.redirect();
        cntrlr.getSection1FS();
        cntrlr.getSection2FS();
        cntrlr.getSection3FS();
        cntrlr.getSection4FS();
        cntrlr.getSection5FS();
        cntrlr.getSection6FS();
        cntrlr.getSection7FS();
        cntrlr.getSection8FS();
        cntrlr.getSection9FS();
        cntrlr.getSection10FS();
        cntrlr.emailadded = true;
        cntrlr.ownerchange = false;
        cntrlr.ownereturn = false;
        cntrlr.commentsaved = true;
        cntrlr.ownername = 'mytest';
        cntrlr.displayComment = false;
        system.assertequals(null, cntrlr.myagents);
        system.assertequals(cntrlr.feedback, true);
        pr.getparameters().put('feedback', 'submitsuccess');
        system.assertequals(cntrlr.comment, system.label.case_submitted);

        cntrlr.mycase.Were_they_allowed_to_test__c = 'No';
        cntrlr.mycase.Did_you_offer_the_candidate_a_reschedule__c = 'No'; 
        //BW change based on new fx.  using savecase and assert that status is not changed and owner is not changed
        //bb submitcase and assert status has moved and owner is changed
        //cntrlr.submitcase();
        //cntrlr.savecase();
        system.assertNotEquals(null, cntrlr.myCaseConfig);
        system.assertEquals(cs.status__c, [select id, status__c from Case where id = :cntrlr.mycase.id].status__c);
        system.assertEquals(Userinfo.getuserid(), [select id, ownerid from case where id = :cs.id].ownerid);

        //cs.Status__c = 'Move to next step';
        step__c current = [select id, step_number__c, Has_forked_logic__c, go_to_step__c, routing__c, who_is_doing_the_work__c from step__c where id =: cntrlr.mycase.step__c];
        step__c nextstep = utility.getnextstep(cntrlr.mycase, current);
        system.assertequals(1, current.step_number__c);
        system.assertequals(2, [select step_number__c, id from step__c where id =: nextstep.id].step_number__c);
        system.assertequals(true, current.Has_forked_logic__c);
        system.assertNotEquals(null, cntrlr.myCaseConfig);
        cntrlr.mycaseconfig = routing;
        cntrlr.submitcase();
        cntrlr.takeownership();
        cs.ownerid = [select id from user where isactive = true limit 1].id;
        update cs;
        cs = withoutsharingUtility.getPreviousvalue(cs);
       
        cntrlr.cancelbutton();

        
        
        CreatePoc cntrlr2 = new CreatePoc(new ApexPages.StandardController(cntrlr.mycase));
        cntrlr2.redirect();
               
        }
        
    }

    //end new test method

*/


    static testMethod void testCommunityUser_NewCandidateCase() {
        
        setupdata();
        system.runAs(communityUser){
        
        // cfeate Case
        Test.setCurrentPage(Page.CreateCasePOC);
        CreatePoc cntrlr = new CreatePoc(new ApexPages.StandardController(new Case()));
        
        pagereference pr = cntrlr.redirect();
        
        system.assertnotequals(null, pr);
        cntrlr.getpagetype();
        system.assertnotequals(null, cntrlr.myagents);
        system.assertnotequals(null, cntrlr.mytestcenterid);
        system.assertequals(cntrlr.getpagetype() , 'Community');
        
        cntrlr.getcategories();
        cntrlr.getTopics();
        
        system.assertnotequals(null, cntrlr.DM);
        
        cntrlr.mytopic = 'Admissions/check-in';
        cntrlr.getcategories();
        cntrlr.mycategory = 'Administrator error';
        
        system.assertequals('Administrator error', cntrlr.finalcat);
        cntrlr.getsubcategories();
        
        system.assertnotequals(null, cntrlr.typeahead);
        system.assertnotequals(null, cntrlr.mycaseconfig);
        system.assertnotequals(null, cntrlr.mycase.routing__c);
        // Select an option in 'Create a case using' field


        cntrlr.setcandidate(cntrlr.typeahead.get(1).getValue());
        system.assertNotEquals(null, cntrlr.selectedcandidate);
        system.assertEquals(cntrlr.selectedcandidate, cntrlr.getcandidate());
        cntrlr.attachCandidate();

        cntrlr.getSection1FS();
        cntrlr.getSection2FS();
        cntrlr.getSection3FS();
        cntrlr.getSection4FS();
        cntrlr.getSection5FS();
        cntrlr.getSection6FS();
        cntrlr.getSection7FS();
        cntrlr.getSection8FS();
        cntrlr.getSection9FS();
        cntrlr.getSection10FS();


        //system.assertnotequals(null, cntrlr.getdefaultteamId());
        cntrlr.submitcase();

        case mycase2 = [select casenumber, id, status__c from case where id =: cntrlr.mycase.id];
        
        CreatePoc cntrlr2 = new CreatePoc(new ApexPages.StandardController(cntrlr.mycase));
        system.assertequals(cntrlr.mycase.status__c, 'Awaiting pickup');
        system.assertequals(cntrlr2.mycase.status__c, 'Awaiting pickup');
        cntrlr2.redirect();
        cntrlr2.cancelbutton();
                
        cntrlr2.pagecontext = 'edit';
        cntrlr2.redirect();
        cntrlr2.submitcase();
        system.assertequals([select id, isclosed from case where id = :cntrlr2.mycase.id].isclosed, true);
        
                
        }
        
    }

    static testMethod void testNewSiteCase() {
        
        setupdata();

        
        system.runAs(communityUser){
        
        
            Test.setCurrentPage(Page.CreateCasePOC);
            CreatePoc cntrlr = new CreatePoc(new ApexPages.StandardController(new Case()));
            
            cntrlr.casetype = 'Site ID';
            cntrlr.enteredid = '1061';
            cntrlr.Retrieve_Reg_or_Site();
            system.assertequals(cntrlr.mycase.Test_center_Name__c, [select name, id from account where VTS_Test_Center_id__c = 1061].id);
            
        }
    
    }
            
        
    static testMethod void testEditRegistrationRollback() {

        setupData();
        //create case and it starts on the route to PC step 
        system.runas(datafactory.createuser())
        {
        string myowner = [SELECT name, id FROM group WHERE type = 'Queue' and  name = 'VSS Level 1'].id; 
        Case cs = 
            new Case(
                Did_the_candidate_comment_complain__c = 'Yes', 
                What_Time_did_the_Power_Outage_Start__c = System.now().addHours(-10),
                What_Time_did_the_Power_Outage_Stop__c = System.now().addHours(-8), 
                Topic__c = 'Exam or delivery issues',
                Final_Category__c = 'Power outage', Step__c = routingSteps[0].Id,
                ownerid = myowner,
                Routing__c = routing.id,
                Status__c = 'Being created',
                Status = 'Being created',
                RecordTypeId = Schema.SobjectType.Case.getRecordTypeInfosByName().get('Exam delivery issue').getRecordTypeId());
        insert cs;

        // Edit Case
        User prevOwner = [select Id from User where UserType = 'Standard' and IsActive = true and Id != :UserInfo.getUserId() limit 1];
        Test.setCurrentPage(new PageReference('/apex/CreateCasePOC?id=' + cs.Id + '&retURL=/home/home.jsp&prevown=' + prevOwner.Id+'&prevstat=Awaiting pickup'));
        //Test.setCurrentPage(new PageReference('/' + cs.Id + '&retURL=/home/home.jsp'));
        CreatePoc cntrlr = new CreatePoc(new ApexPages.StandardController(cs));
        
        cntrlr.redirect();

        cntrlr.mycase.Were_they_allowed_to_test__c = 'No';
        cntrlr.mycase.Did_you_offer_the_candidate_a_reschedule__c = 'No';
        cntrlr.mycase.Account = new Account(VTS_Client_ID__c = 9990999); //Induce error
        cntrlr.savecase();

        cntrlr.mycase.Were_they_allowed_to_test__c = 'No';
        cntrlr.mycase.Did_you_offer_the_candidate_a_reschedule__c = 'No';
        cntrlr.mycase.Account = new Account(VTS_Client_ID__c = 9990999); //Induce error
        cntrlr.submitcase();

        Case dbCase = [select Status__c, OwnerId from case where Id = :cs.Id];
        System.assertequals(1, [select id, Step_number__c from Step__c where id = :cs.Step__c].step_number__c);
        System.assertEquals('Working', dbCase.Status__c);
        System.assertEquals(Userinfo.getuserid(), dbCase.OwnerId);

        }
    }


   static testMethod void testEditCommunity() {

        setupData();
        //create case and it starts on the route to PC step 
        Case cs = 
            new Case(
                Did_the_candidate_comment_complain__c = 'Yes', 
                What_Time_did_the_Power_Outage_Start__c = System.now().addHours(-10),
                What_Time_did_the_Power_Outage_Stop__c = System.now().addHours(-8), 
                Topic__c = 'Exam or delivery issues',
                Final_Category__c = 'Power outage', Step__c = routingSteps[0].Id,
                Routing__c = routing.id,
                Status__c = 'Awaiting Pickup',
                RecordTypeId = Schema.SobjectType.Case.getRecordTypeInfosByName().get('Exam delivery issue').getRecordTypeId());
        insert cs;

        // Edit Case
        //Test.setCurrentPage(new PageReference('/' + cs.Id + '&retURL=/home/home.jsp'));
        
        system.runAs(communityUser){
        
        Test.setCurrentPage(new PageReference('/apex/CreateCasePOC?id=' + cs.Id + '&retURL=/home/home.jsp'));
        CreatePoc cntrlr = new CreatePoc(new ApexPages.StandardController(cs));
        
        cntrlr.redirect();
        cntrlr.takeownership();
        cntrlr.getSection1FS();
        cntrlr.getSection2FS();
        cntrlr.getSection3FS();
        cntrlr.getSection4FS();
        cntrlr.getSection5FS();
        cntrlr.getSection6FS();
        cntrlr.getSection7FS();
        cntrlr.getSection8FS();
        cntrlr.getSection9FS();
        cntrlr.getSection10FS();
        cntrlr.savecase();
        cntrlr.pagecontext = 'view';
        system.assertequals(cntrlr.communityRenderEditButton, true);
        

        cntrlr.mycase.Were_they_allowed_to_test__c = 'No';
        cntrlr.mycase.Did_you_offer_the_candidate_a_reschedule__c = 'No'; 
        //BW change based on new fx.  using savecase and assert that status is not changed and owner is not changed
        cntrlr.submitcase();
        cntrlr.submitcase();
        cntrlr.redirect();
        if(cntrlr.mycase.status__c == 'Closed')
            {
                cntrlr.redirect();   
            }
        
        }
   }





}