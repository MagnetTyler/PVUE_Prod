@istest(seealldata=false)

public with sharing class DataFactory {

    private static final String ROUTING_LOGIC_ROUTING_REC_TYPE_ID;
    private static final String ROUTING_LOGIC_SECTION_REC_TYPE_ID;
    static {
        Map<String, Schema.RecordTypeInfo> rectTypes = Schema.SobjectType.Routing_Logic__c.getRecordTypeInfosByName();
        ROUTING_LOGIC_ROUTING_REC_TYPE_ID = rectTypes.get('Dynamic Routing Logic').getRecordTypeId();
        ROUTING_LOGIC_SECTION_REC_TYPE_ID = rectTypes.get('Dynamic Section Logic').getRecordTypeId();
    }

    public static String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    public static string charnum = '0123456789';

	public static User createUser(){     
        User test_user = new User();
        
        Long randomValue = Math.roundToLong(Math.random() * Double.valueOf('10000000000000000.0'));
        test_user.Username= 'test_user1'+ randomValue +'@company.com';
        test_user.Email = 'test_user1'+ randomValue +'@company.com'; 
        test_user.Lastname = 'user' + randomValue; 
        test_user.Firstname = 'test';
        test_user.Alias = 'test';
        test_user.Primary_team_persona__c = 'VSSL1';
        test_user.CommunityNickname = '12346'+ randomValue;
        test_user.ProfileId = UserInfo.getProfileId();
        test_user.TimeZoneSidKey = 'GMT';
        test_user.LocaleSidKey = UserInfo.getLocale();
        test_user.EmailEncodingKey = 'ISO-8859-1';
        test_user.LanguageLocaleKey = 'en_US';
        test_user.IsActive = true;
        try{
        insert(test_user);
            }
        catch (system.dmlException guardconcurrency)
            {
                insert (test_user);
            }    
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
        permissionset ps = [select id from permissionset where label = 'VSS L1'];
        permissionsetassignment pm = new permissionsetassignment(permissionsetid = ps.id, assigneeid = test_user.id);
        insert pm;
        }
        return test_user;
    }
    
        public static List<Account> createAccounts(Integer numberOfRecordsToCreate, Boolean insertRecords) {
            
        List<Account> accounts = new List<Account>();
        for (Integer i=0; i < numberOfRecordsToCreate; i++) {
        	Long randomValue = Math.roundToLong(Math.random() * Double.valueOf('10000000.0'));
             String randStr = '';
    			while (randStr.length() < 7) {
       			Integer myint = Math.mod(Math.abs(Crypto.getRandomInteger()), 52);
       			randStr += chars.substring(myint, myint+1);
    				} 
    		string randsuffix='-';
    			while (randsuffix.length() < 3) {
       			Integer myint = Math.mod(Math.abs(Crypto.getRandomInteger()), 10);
       			randsuffix += charnum.substring(myint, myint+1);
    				}

            Account a = new Account (
                Name = 'Unique Test Company'+string.valueof(randomvalue), VTS_Test_Center_ID__c = randomValue
            );
            accounts.add(a);
        }
        
        if(insertRecords) {
            insert accounts;
        }
        
        return accounts;
        
    }

        public static List<CustomListView__c> createlistviews(){
            list<CustomListView__c> newlistviews = new list<CustomListView__c>
                {
                    new CustomListView__c(
                        Custom_Buttons__c = 'Assign to myself',
                    Default__c = true,
                    FieldSet_Name__c = 'External_list_view',
                    
                    Is_Closed_View__c = false,
                    List_Order__c = 1,
                    List_Size_Options__c = '10;20;50',
                    List_view_name__c = 'Cases awaiting pickup',
                    Object__c = 'Case',
                    Order_by__c = 'new_external_comment__c desc',
                    
                    Search_Criteria__c = 'ISCLOSED = False AND Status__c = \'Awaiting pickup\' AND Test_Center_Name__c = :mytestCenter',
                    Then_by__c = 'Created__c asc',
                    Use_Fieldset__c = false),

                    new CustomListView__c(
                        
                    Default__c = false,
                    FieldSet_Name__c = 'External_list_view',
                    
                    Is_Closed_View__c = true,
                    List_Order__c = 2,
                    List_Size_Options__c = '10;20;50',
                    List_view_name__c = 'My closed cases',
                    Object__c = 'Case',
                    Order_by__c = 'new_external_comment__c desc',
                   
                    Search_Criteria__c = 'OwnerId = :me AND ISCLOSED = true',
                    Then_by__c = 'Created__c desc',
                    Use_Fieldset__c = false)

                };
                insert(newlistviews);
            return newlistviews;


        }

		public static blob loadfile(list<account> acclist){
			
				list<string> fieldlist = new list<string>();
				string headers = 'externalId,Comments';
				
					
				for(account a: acclist)
					{
					String randStr = '';
    			while (randStr.length() < 7) 
    				{
	       				Integer myint = Math.mod(Math.abs(Crypto.getRandomInteger()), 52);
    	   				randStr += chars.substring(myint, myint+1);
    				} 
    				fieldlist.add(a.VTS_Test_Center_ID__c+','+randstr);
				}
				fieldlist.add(0,headers);
				blob attachfile = blob.valueof(string.join(fieldlist,'\n'));
				return attachfile;
		}
		public static case createcase(string recordtypename, user u){
            return  createcase(recordtypename,u,null);
        }
		public static case createcase(string recordtypename, user u,Step__c st){
			case c = new case(ownerid = u.id, recordtypeid = schema.sObjecttype.case.getrecordtypeinfosbyname().get(recordtypename).getrecordtypeId(),
								subject = 'abc', description = 'abcdef' );
           	 if(st!=null)
            	{c.Step__c=st.Id;}
			insert(c);
			return c;					
		}
			
    public static Web_Service_Setting__c createWebServiceSettings() {
        Web_Service_Setting__c wsConfig = 
            new Web_Service_Setting__c(
                Name = 'ESB', Endpoint__c = 'https://esb.pearson.example.com', Username__c = 'pearson_vue', Timeout__c = 10000);
        insert wsConfig;
        return wsConfig;
    }

    public static Org_Settings__c createSettings() {

        Org_Settings__c settings = Org_Settings__c.getInstance();
        if ( settings == null ) {
            settings = new Org_Settings__c(); 
            }

        settings.Case_Mass_Assign_Profiles__c = [select Name from Profile where Id = :UserInfo.getProfileId()].Name;
        List<AuthProvider> authProviders = [select Id from AuthProvider where ProviderType = 'OpenIdConnect'];
        if ( !authProviders.isEmpty() ) {
        	settings.CAS_Auth_Provider_ID__c = String.valueOf(authProviders[0].Id).substring(0, 15);
        }
        try{
        upsert settings;
        }
        catch(system.dmlException concurrencyerror)
            {
                upsert settings;
            }
		return settings;
    }

    public static List<Case_Topic_And_Category__c> createCaseAndTopicCategories() {

        List<Case_Topic_And_Category__c> topicsAndCats = 
            new List<Case_Topic_And_Category__c>{
                new Case_Topic_And_Category__c(
                	Name = 'Client request to override-PC', 
                    Personas_that_work_the_case__c = 'CS, CSR, VSS L1, VSS L2, CQ, PM, PC',
                    Persona__c = 'PC',
                	Topic__c = 'Registration/appointment issues',
                	Category_Name__c = 'Client request to override',
                	subcategories__c = null,
                	Has_Sub_Category__c = false, 
                    Registration_Case__c = true),
                new Case_Topic_And_Category__c(
                	Name = 'Client admissions waiver-PC', 
                    Personas_that_work_the_case__c = 'TA',
                    Persona__c = 'PC',
                	Topic__c = 'Admissions/check-in',
                	Category_Name__c = 'Client admissions waiver',
                	subcategories__c = 'Biometric waivers,Id exceptions,Name discrepancy',
                	Has_Sub_Category__c = true, 
                    Registration_Case__c = true),    
                new Case_Topic_And_Category__c(
                	Name = 'Administrator error-PC', 
                    Personas_that_work_the_case__c = 'SA,CQ,VSS L1,PC,VSS Mgmt,TP',
                    Persona__c = 'PC',
                	Topic__c = 'Admissions/check-in',
                	Category_Name__c = 'Administrator error',
                	subcategories__c = null,
                	Has_Sub_Category__c = false, 
                    Registration_Case__c = true),
                new Case_Topic_And_Category__c(
                	Name = 'Exam delivery-Power outage-PC', 
                    Persona__c = 'PC',
                    Personas_that_work_the_case__c = 'CS, CSR, VSS L1, VSS L2, CQ, PM, PC',
                	Topic__c = 'Exam delivery',
                	Category_Name__c = 'Power outage',
                	subcategories__c = null,
                	Has_Sub_Category__c = false, 
                    Registration_Case__c = true),
                new Case_Topic_And_Category__c(
                	Name = 'Consent and waiver form-TA', 
                    Persona__c = 'TA',
                    Personas_that_work_the_case__c = 'PM',
                	Topic__c = 'Admissions/check-in',
                	Category_Name__c = 'Consent and waiver form',
                	Community__c = true,
                	Registration_case__c = true),
                new Case_Topic_And_Category__c(
                	Name = 'Administrator error-TA', 
                    Persona__c = 'TA',
                    Personas_that_work_the_case__c = 'CS, CSR, VSS L1, VSS L2, CQ, PM, PC',
                	Topic__c = 'Admissions/check-in',
                	Category_Name__c = 'Administrator error',
                	subcategories__c = null,
                	Has_Sub_Category__c = false,
                	Registration_Case__c = true, 
                    Community__c = true) ,
                new Case_Topic_And_Category__c(
                	Name = 'Exam - Exam error', 
                    Persona__c = 'VSS L1,VSS L1,PC',
                	Topic__c = 'Exam Delivery',
                	Category_Name__c = 'Exam error during test/launch',
                	Has_Sub_Category__c = false,
                	Site_case__c = true, 
                    Community__c = false) 
            };
		insert topicsAndCats;
        return topicsAndCats;
    }

    public static Routing__c createPowerOutageRouting() {
        return createRouting('Power outage');
    }

    public static Routing__c createRouting(String finalCategoryName) {


		Schema.DescribeFieldResult F = Routing__c.Related_lists__c.getDescribe();
		List<Schema.PicklistEntry> P = F.getPicklistValues();

        Routing__c routing = 
            new Routing__c(
        		Name = 'Power outage',
                //Case_config_Id__c = '',
                Case_Record_Type__c = 'Exam delivery issue',
                Business_process__c = 'PrimarySupportProcess',
                Final_Category_Name__c = finalCategoryName,
                Import_Cases_Button__c = 'System Administrator',
                Knowledge_search__c = '',
                Priority__c = 'High',
                Mass_Reschedule_Button__c = 'System Administrator; VSS Level 1;VSS L1' + [select id, primary_team_persona__c from user where id = :userinfo.getuserId()].primary_team_persona__c ,
                Missing_Results_Button__c = '',
                Related_Lists__c = P[0].getValue()+';' + P[1].getvalue() +';',
                Section_1_field_set__c = 'Description',
                Section_2_field_set__c = 'Case_standard_field3',
                Section_3_field_set__c = 'Power_outage',
                Section_4_field_set__c = 'Summarize_the_issue',
                Section_5_field_set__c = 'Ready_for_resolution',
                Section_6_field_set__c = 'Resolution');
        insert routing;

        return routing;
    }

public static Routing__c createAdministratorError() {


		Schema.DescribeFieldResult F = Routing__c.Related_lists__c.getDescribe();
		List<Schema.PicklistEntry> P = F.getPicklistValues();

        Routing__c routing = 
            new Routing__c(
        		Name = 'Administrator error',
                //Case_config_Id__c = '',
                Case_Record_Type__c = 'Exam delivery issue',
                Business_process__c = 'PrimarySupportProcess',
                Final_Category_Name__c = 'Administrator error',
                Import_Cases_Button__c = '',
                Knowledge_search__c = '',
                Mass_Reschedule_Button__c = 'PC' + [select id, primary_team_persona__c from user where id = :userinfo.getuserId()].primary_team_persona__c ,
                Missing_Results_Button__c = '',
                Related_Lists__c = P[0].getValue()+';' + P[1].getvalue() +';',
                Section_1_field_set__c = 'Description',
                Section_2_field_set__c = 'Case_standard_field3',
                Section_3_field_set__c = 'Administrator_error',
                Section_4_field_set__c = 'Ready_for_resolution',
                Section_5_field_set__c = 'Resolution',
                Section_6_field_set__c = 'Summarize_the_issue');
        insert routing;

        return routing;
    }



    public static List<Step__c> createPowerOutageRoutingSteps(ID routingId) {

        List<Step__c> steps =
            new List<Step__c>{
                new Step__c(
                    Routing__c = routingId, Name = 'Start', Step_Number__c = 1, Section_Visible__c = 'Section 3; Section 4',
                    Who_is_doing_the_Work__c = 'Any internal user', Next_Team__c = 'Program Coordinator', Go_to_step__c = 3, 
                    Has_forked_logic__c = true, Personas_Can_Edit__c = 'System Administrator', has_dynamic_sections__c = true,
                    Personas_Can_Accept__c = 'System Administrator', Personas_Can_Close__c = 'System Administrator'),
   //             new Step__c(
   //                 Routing__c = routingId, Name = 'Worked by Same User', Step_Number__c = 2, 
   //                 Section_Visible__c = 'Section 1; Section 2; Section 3; Section 4', Who_is_doing_the_Work__c = 'Same owner', 
   //                 Next_Team__c = 'Program Coordinator,Closed', Go_to_step__c = 7, Has_forked_logic__c = true, 
   //                 Personas_Can_Edit__c = 'System Administrator', Personas_Can_Accept__c = 'System Administrator', 
   //                 Personas_Can_Close__c = 'System Administrator'),
   //             new Step__c(
   //                 Routing__c = routingId, Name = 'Worked by Same User', Step_Number__c = 3, 
  //                  Section_Visible__c = 'Section 1; Section 2; Section 3; Section 5', Who_is_doing_the_Work__c = 'Same owner', 
  //                  Next_Team__c = 'Program Coordinator', Go_to_step__c = 3, Has_forked_logic__c = true, 
  //                  Personas_Can_Edit__c = 'System Administrator', Personas_Can_Accept__c = 'System Administrator', 
  //                  Personas_Can_Close__c = 'System Administrator'),
                new Step__c(
                    Routing__c = routingId, Name = 'Worked by Program Coordinator', Step_Number__c = 2, 
                    Section_Visible__c = 'Section 1; Section 2; Section 3; Section 5', 
                    Who_is_doing_the_Work__c = 'Any internal user', Next_Team__c = 'Closed', Go_to_step__c = 3, 
                    Has_forked_logic__c = false, has_dynamic_sections__c = true,
                    Personas_Can_Edit__c = 'System Administrator', Personas_Can_Accept__c = 'System Administrator', 
                    Personas_Can_Close__c = 'System Administrator'),
                new Step__c(
                    Routing__c = routingId, Name = 'Completed', Step_Number__c = 3, 
                    Section_Visible__c = 'Section 1; Section 2; Section 3; Section 6', Who_is_doing_the_Work__c = 'Closed', 
                    Next_Team__c = 'Closed',
                    has_dynamic_sections__c = true, 
                    Personas_Can_Edit__c = 'System Administrator', Personas_Can_Accept__c = 'System Administrator', 
                    Personas_Can_Close__c = 'System Administrator')
   //             new Step__c(
   //                 Routing__c = routingId, Name = 'Worked by Program Coordinator', Step_Number__c = 6, 
   //                 Section_Visible__c = 'Section 1; Section 2; Section 3; Section 4; Section 7', 
   //                 Who_is_doing_the_Work__c = 'Same owner', Next_Team__c = 'Closed', Go_to_step__c = 7, 
   //                 Personas_Can_Edit__c = 'System Administrator', Personas_Can_Accept__c = 'System Administrator', 
   //                 Personas_Can_Close__c = 'System Administrator'),
   //				new Step__c(
   //                 Routing__c = routingId, Name = 'Worked by Program Coordinator', Step_Number__c = 6, 
   //                 Section_Visible__c = 'Section 1; Section 2; Section 3', 
   //                 Who_is_doing_the_Work__c = 'Same owner', Next_Team__c = 'Closed', Go_to_step__c = 7, 
   //                 Personas_Can_Edit__c = 'System Administrator', Personas_Can_Accept__c = 'System Administrator', 
   //                 Personas_Can_Close__c = 'System Administrator'),
   //             new Step__c(
   //                 Routing__c = routingId, Name = 'Completed', Step_Number__c = 7, has_dynamic_sections__c = true,
   //                 Section_Visible__c = 'Section 1; Section 2; Section 3; Section 4; Section 7', 
   //                 Who_is_doing_the_Work__c = 'Closed', Personas_Can_Edit__c = 'System Administrator'),
   //             new Step__c(
   //                 Routing__c = routingId, Name = 'Worked by any internal team', Step_Number__c = 8, 
   //                 Section_Visible__c = 'Section 1; Section 2; Section 3', 
   //                 Who_is_doing_the_Work__c = 'Any internal user', Next_Team__c = 'Program Coordinator', 
   //                 Go_to_step__c = 4, Has_forked_logic__c = false, has_dynamic_sections__c = true,
    //                Personas_Can_Edit__c = 'System Administrator', Personas_Can_Accept__c = 'System Administrator', 
     //               Personas_Can_Close__c = 'System Administrator') /*,
   //            new Step__c(
    //                Routing__c = routingId, Name = 'Worked by Program Coordinator', Step_Number__c = 9, 
    //                Section_Visible__c = 'Section 1; Section 2; Section 3; Section 5; Section 6', 
    //                Who_is_doing_the_Work__c = 'Program_Coordinator', Next_Team__c = 'Any internal team', 
    //                Go_to_step__c = 9, 
     //               Personas_Can_Edit__c = 'System Administrator', Personas_Can_Accept__c = 'System Administrator', 
     //               Personas_Can_Close__c = 'System Administrator'),
     //           new Step__c(
     //               Routing__c = routingId, Name = 'Send Email to candiate', Step_Number__c = 10, 
     //               Section_Visible__c = 'Section 1; Section 2; Section 3; Section 5', 
     //               Who_is_doing_the_Work__c = 'Same owner', Next_Team__c = 'Program Coordinator', 
     //               Go_to_step__c = 11, 
     //               Personas_Can_Edit__c = 'System Administrator', Personas_Can_Accept__c = 'System Administrator', 
     //               Personas_Can_Close__c = 'System Administrator'),
     //           new Step__c(
     //               Routing__c = routingId, Name = 'Worked by Program Coordinator', Step_Number__c = 11, 
     //               Section_Visible__c = 'Section 1; Section 2; Section 3; Section 5; Section 7', 
     //               Who_is_doing_the_Work__c = 'Same owner', Next_Team__c = 'Closed', 
     //               Go_to_step__c = 12, 
     //               Personas_Can_Edit__c = 'System Administrator', Personas_Can_Accept__c = 'System Administrator', 
     //               Personas_Can_Close__c = 'System Administrator'),
     //           new Step__c(
     //               Routing__c = routingId, Name = 'Completed', Step_Number__c = 12, 
     //               Section_Visible__c = 'Section 1; Section 2; Section 3; Section 5; Section 7', 
     //               Who_is_doing_the_Work__c = 'Closed', Go_to_step__c = 13, Personas_Can_Edit__c = 'System Administrator'),
     //           new Step__c(
     //               Routing__c = routingId, Name = 'Worked by any internal team', Step_Number__c = 13, 
     //               Section_Visible__c = 'Section 1; Section 2; Section 3; Section 5', 
     //               Who_is_doing_the_Work__c = 'Any internal user', Next_Team__c = 'Program Coordinator', 
     //               Go_to_step__c = 9, Personas_Can_Edit__c = 'System Administrator', 
     //               Personas_Can_Accept__c = 'System Administrator', Personas_Can_Close__c = 'System Administrator') */ 
     				 };
		insert steps;
        return steps;
    }

 public static List<Step__c> createAdminErrorSteps(ID routingId) {

        List<Step__c> steps =
            new List<Step__c>{
                new Step__c(
                    Routing__c = routingId, Name = 'Start', Step_Number__c = 1, Section_Visible__c = 'Section 3; Section 6',
                    Who_is_doing_the_Work__c = 'Any internal user', Next_Team__c = 'Program Coordinator', Go_to_step__c = 2, 
                    Has_forked_logic__c = false, Personas_Can_Edit__c = 'System Administrator', has_dynamic_sections__c = true,
                    Personas_Can_Accept__c = 'System Administrator', Personas_Can_Close__c = 'System Administrator'),
                new Step__c(
                    Routing__c = routingId, Name = 'Worked by Program Coordinator', Step_Number__c = 2, 
                    Section_Visible__c = 'Section 1; Section 2; Section 3; Section 4', 
                    Who_is_doing_the_Work__c = 'Program_Coordinator', Next_Team__c = 'Channel Quality or Closed', Go_to_step__c = 3, 
                    Has_forked_logic__c = true, has_dynamic_sections__c = true,
                    Personas_Can_Edit__c = 'System Administrator', Personas_Can_Accept__c = 'System Administrator', 
                    Personas_Can_Close__c = 'System Administrator'),
                new Step__c(
                    Routing__c = routingId, Name = 'Completed', Step_Number__c = 3, 
                    Section_Visible__c = 'Section 1; Section 2; Section 3; Section 5', Who_is_doing_the_Work__c = 'Closed', 
                    Next_Team__c = 'Closed',
                    has_dynamic_sections__c = true, 
                    Personas_Can_Edit__c = 'System Administrator', Personas_Can_Accept__c = 'System Administrator', 
                    Personas_Can_Close__c = 'System Administrator'),
                    new Step__c(
                    Routing__c = routingId, Name = 'Worked by Channel Quality', Step_Number__c = 4, go_to_step__c = 3,
                    Section_Visible__c = 'Section 1; Section 2; Section 3; Section 5', Who_is_doing_the_Work__c = 'Channel_Quality', 
                    Next_Team__c = 'Closed',
                    has_dynamic_sections__c = true, 
                    Personas_Can_Edit__c = 'System Administrator', Personas_Can_Accept__c = 'System Administrator', 
                    Personas_Can_Close__c = 'System Administrator')
     				 };
		insert steps;
        return steps;
    }



    public static List<Routing_logic__c> createPowerOutageRoutingLogics(List<Step__c> steps) {

	    string dSectionrectypeid = Schema.Sobjecttype.Routing_Logic__c.getRecordtypeInfosbyname().get('Dynamic Section Logic').getrecordtypeid();
	    string routingfield = Schema.Sobjecttype.Routing_Field__c.getRecordtypeInfosbyname().get('Dynamic Routing Field').getrecordtypeid();
	    string sectionfield = Schema.Sobjecttype.Routing_field__c.getRecordtypeInfosbyname().get('Dynamic Sections Field').getrecordtypeid();
		

        List<Routing_logic__c> routingLogics = 
            new List<Routing_logic__c> {
                new Routing_logic__c(Name = 'Route to PC',  Step__c = steps[0].Id, Go_to_step__c = 2, RecordTypeId = ROUTING_LOGIC_ROUTING_REC_TYPE_ID),
                //added for dynamic sections
                new Routing_logic__c(Name = 'Start - Power Outage > 30 Min',  Step__c = steps[0].Id, RecordTypeId = ROUTING_LOGIC_SECTION_REC_TYPE_ID,
                					 Parent_section__c = 'Section 3', Re_Render_block__c = 'PBlock03', page_order__c = 2, sub_section_fieldset__c = 'Offer_reschedule'),
                new Routing_logic__c(Name = 'Start - Power Outage <= 30 Min',  Step__c = steps[0].Id, RecordTypeId = ROUTING_LOGIC_SECTION_REC_TYPE_ID,
                					 Parent_section__c = 'Section 3', Re_Render_block__c = 'PBlock03', page_order__c = 2, sub_section_fieldset__c = 'Allowed_to_test'),
                
                
                //new Routing_logic__c(Name = 'Candidate complained', Step__c = steps[1].Id, Go_to_step__c = 4, RecordTypeId = ROUTING_LOGIC_ROUTING_REC_TYPE_ID),
                
                //new Routing_logic__c(Name = 'Didn\'t offer reschedule',  Step__c = steps[1].Id, Go_to_step__c = 4, RecordTypeId = ROUTING_LOGIC_ROUTING_REC_TYPE_ID),
                //new Routing_logic__c(Name = 'Candidate Complained', Step__c = steps[2].Id, Go_to_step__c = 4, RecordTypeId = ROUTING_LOGIC_ROUTING_REC_TYPE_ID),
                //new Routing_logic__c(Name = 'Not allowed to test',  Step__c = steps[2].Id, Go_to_step__c = 4, RecordTypeId = ROUTING_LOGIC_ROUTING_REC_TYPE_ID),
                //new Routing_logic__c(Name = 'Follow up with candidate',  Step__c = steps[3].Id, Go_to_step__c = 5, RecordTypeId = ROUTING_LOGIC_ROUTING_REC_TYPE_ID),
                new Routing_logic__c(Name = 'Seat number', Step__c = steps[0].Id, page_order__c = 3, RecordTypeId = ROUTING_LOGIC_SECTION_REC_TYPE_ID,
                					 Parent_section__c = 'Section 3', Re_Render_block__c = 'PBlock03', sub_section_fieldset__c = 'seat_number')
              //  new Routing_logic__c(Name = 'More than 30 Minutes', Step__c = steps[1].Id, RecordTypeId = ROUTING_LOGIC_SECTION_REC_TYPE_ID,
            //    					 Parent_section__c = 'Section 3', Re_Render_block__c = 'PBlock03', sub_section_fieldset__c = 'Offer_reschedule'),
            //   new Routing_logic__c(Name = 'Less than 30 minutes', Step__c = steps[1].Id, RecordTypeId = ROUTING_LOGIC_SECTION_REC_TYPE_ID,
            //    					 Parent_section__c = 'Section 3', Re_Render_block__c = 'PBlock03',sub_section_fieldset__c = 'Allowed_to_test'),
            //   new Routing_logic__c(Name = 'More than 30 Minutes', Step__c = steps[3].Id,  RecordTypeId = ROUTING_LOGIC_SECTION_REC_TYPE_ID,
            //    					 Parent_section__c = 'Section 3', Re_Render_block__c = 'PBlock03', sub_section_fieldset__c = 'Offer_reschedule'),
            //    new Routing_logic__c(Name = 'Less than 30 minutes', Step__c = steps[3].Id,  RecordTypeId = ROUTING_LOGIC_SECTION_REC_TYPE_ID,
            //    					 Parent_section__c = 'Section 3', Re_Render_block__c = 'PBlock03',sub_section_fieldset__c = 'Allowed_to_test'),
            //    new Routing_logic__c(Name = 'More than 30 Minutes', Step__c = steps[4].Id,  RecordTypeId = ROUTING_LOGIC_SECTION_REC_TYPE_ID,
            //    					 Parent_section__c = 'Section 3', Re_Render_block__c = 'PBlock03', sub_section_fieldset__c = 'Offer_reschedule'),
            //    new Routing_logic__c(Name = 'Less than 30 minutes', Step__c = steps[4].Id,  RecordTypeId = ROUTING_LOGIC_SECTION_REC_TYPE_ID,
            //    					 Parent_section__c = 'Section 3', Re_Render_block__c = 'PBlock03',sub_section_fieldset__c = 'Allowed_to_test')
                
                
            };
		insert routingLogics;

        List<Routing_field__c> routingFields = 
			new List<Routing_field__c> {
                new Routing_field__c(
                    Routing_logic__c = routingLogics[0].Id, RecordTypeId = routingfield, name = 'Did_the_candidate_comment_complain__c' , 
                    Logic_type__c = 'OR', Operator__c = 'Equals', Value__c = 'Yes'),
               new Routing_field__c(
                    Routing_logic__c = routingLogics[0].Id, RecordTypeId = sectionfield, name = 'Were_they_allowed_to_test__c' , 
                    Logic_type__c = 'OR', Operator__c = 'Equals', Value__c = 'No'), 
               new Routing_field__c(
                    Routing_logic__c = routingLogics[0].Id, RecordTypeId = sectionfield, name = 'Did_you_offer_the_candidate_a_reschedule__c' , 
                    Logic_type__c = 'OR', Operator__c = 'Equals', Value__c = 'No'), 
               new Routing_field__c(
                    Routing_logic__c = routingLogics[1].Id, RecordTypeId = sectionfield, name = 'Please_enter_issue_end_time__c' , 
                    Logic_type__c = 'AND', Operator__c = 'Greater than', subtractionfield__c = 'Please_enter_issue_start_time__c', 
                    Value__c = '30'),  
               new Routing_field__c(
                    Routing_logic__c = routingLogics[1].Id, RecordTypeId = sectionfield, name = 'Please_enter_issue_end_time__c' , 
                    Logic_type__c = 'AND', Operator__c = 'Less than', subtractionfield__c = 'Please_enter_issue_start_time__c', 
                    Value__c = '30')  
                
 //               new Routing_field__c(
 //                   Routing_logic__c = routingLogics[0].Id, RecordTypeId = routingfield, name = 'What_Time_did_the_Power_Outage_Stop__c' , 
 //                   Logic_type__c = 'AND', Operator__c = 'Greater than', subtractionfield__c = 'What_Time_did_the_Power_Outage_Start__c', 
 //                   Value__c = '30'),
 //               new Routing_field__c(
//                    Routing_logic__c = routingLogics[1].Id, RecordTypeId = routingfield, name = 'Did_the_candidate_comment_complain__c' , 
 //                   Logic_type__c = 'AND', Operator__c = 'Equals', Value__c = 'Yes'),
 //               new Routing_field__c(
 //                   Routing_logic__c = routingLogics[2].Id, RecordTypeId = routingfield, name = 'Did_you_offer_the_candidate_a_reschedule__c' , 
 //                   Logic_type__c = 'AND', Operator__c = 'Equals', Value__c = 'No'),
 //               new Routing_field__c(
 //                   Routing_logic__c = routingLogics[3].Id, RecordTypeId = routingfield, name = 'Did_the_candidate_comment_complain__c' , 
 //                   Logic_type__c = 'AND', Operator__c = 'Equals', Value__c = 'Yes'),
 //               new Routing_field__c(
 //                   Routing_logic__c = routingLogics[4].Id, RecordTypeId = routingfield, name = 'Were_they_allowed_to_test__c' , 
 //                   Logic_type__c = 'AND', Operator__c = 'Equals', Value__c = 'No'),
 //               new Routing_field__c(
 //                   Routing_logic__c = routingLogics[5].Id, RecordTypeId = routingfield, name = 'Follow_up_with__c' , 
 //                   Logic_type__c = 'AND', Operator__c = 'Equals', Value__c = 'Candidate'),
 //               new Routing_field__c(
 //                   Routing_logic__c = routingLogics[2].Id, RecordTypeId = routingfield, name = 'Follow_up_with__c' , 
 //                   Logic_type__c = 'AND', Operator__c = 'Not equals', Value__c = 'null'),  
 //               new Routing_field__c(
  //                  Routing_logic__c = routingLogics[3].Id, RecordTypeId = sectionfield, name = 'Please_enter_issue_end_time__c' , 
 //                   Logic_type__c = 'AND', Operator__c = 'Greater than', subtractionfield__c = 'Please_enter_issue_start_time__c', 
 //                   Value__c = '30'),  
 //              new Routing_field__c(
 //                   Routing_logic__c = routingLogics[4].Id, RecordTypeId = sectionfield, name = 'Please_enter_issue_end_time__c' , 
 //                   Logic_type__c = 'AND', Operator__c = 'Less than', subtractionfield__c = 'Please_enter_issue_start_time__c', 
 //                   Value__c = '30'),    
 //              new Routing_field__c(
 //                   Routing_logic__c = routingLogics[5].Id, RecordTypeId = sectionfield, name = 'Please_enter_issue_end_time__c' , 
 //                   Logic_type__c = 'AND', Operator__c = 'Greater than', subtractionfield__c = 'Please_enter_issue_start_time__c', 
 //                   Value__c = '30'),  
 //              new Routing_field__c(
 //                   Routing_logic__c = routingLogics[6].Id, RecordTypeId = sectionfield, name = 'Please_enter_issue_end_time__c' , 
 //                   Logic_type__c = 'AND', Operator__c = 'Less than', subtractionfield__c = 'Please_enter_issue_start_time__c', 
 //                   Value__c = '30'), 
  //             new Routing_field__c(
 //                   Routing_logic__c = routingLogics[7].Id, RecordTypeId = sectionfield, name = 'Please_enter_issue_end_time__c' , 
 //                   Logic_type__c = 'AND', Operator__c = 'Greater than', subtractionfield__c = 'Please_enter_issue_start_time__c', 
 //                   Value__c = '30'),  
 //              new Routing_field__c(
 //                   Routing_logic__c = routingLogics[8].Id, RecordTypeId = sectionfield, name = 'Please_enter_issue_end_time__c' , 
 //                   Logic_type__c = 'AND', Operator__c = 'Less than', subtractionfield__c = 'Please_enter_issue_start_time__c', 
 //                   Value__c = '30')//,                                        
                    
                      
//                new Routing_field__c(
//                    Routing_logic__c = routingLogics[5].Id, RecordTypeId = routingfield, name = 'Follow_up_with__c' , 
//                    Logic_type__c = 'AND', Operator__c = 'Equals', Value__c = 'null')
            };
		insert routingFields;

        return routingLogics;
    }

 public static List<Routing_logic__c> createAdminErrorRoutingLogics(List<Step__c> steps) {

	    string dSectionrectypeid = Schema.Sobjecttype.Routing_Logic__c.getRecordtypeInfosbyname().get('Dynamic Section Logic').getrecordtypeid();
	    string routingfield = Schema.Sobjecttype.Routing_Field__c.getRecordtypeInfosbyname().get('Dynamic Routing Field').getrecordtypeid();
	    string sectionfield = Schema.Sobjecttype.Routing_field__c.getRecordtypeInfosbyname().get('Dynamic Sections Field').getrecordtypeid();
		

        List<Routing_logic__c> routingLogics = 
            new List<Routing_logic__c> {
            	new Routing_logic__c(Name = 'When was complaint made',  Step__c = steps[0].Id, RecordTypeId = ROUTING_LOGIC_SECTION_REC_TYPE_ID,
                					 Parent_section__c = 'Section 3', Re_Render_block__c = 'PBlock03', page_order__c = 1, sub_section_fieldset__c = 'when_was_complain_made'),
                new Routing_logic__c(Name = 'TA mistake',  Step__c = steps[1].Id, Go_to_step__c = 4, RecordTypeId = ROUTING_LOGIC_ROUTING_REC_TYPE_ID),
                //added for dynamic sections
                new Routing_logic__c(Name = 'When was complaint made	',  Step__c = steps[1].Id, RecordTypeId = ROUTING_LOGIC_SECTION_REC_TYPE_ID,
                					 Parent_section__c = 'Section 3', Re_Render_block__c = 'PBlock03', page_order__c = 2, sub_section_fieldset__c = 'when_was_complain_made'),
                new Routing_logic__c(Name = 'When was complaint made	',  Step__c = steps[2].Id, RecordTypeId = ROUTING_LOGIC_SECTION_REC_TYPE_ID,
                					 Parent_section__c = 'Section 3', Re_Render_block__c = 'PBlock03', page_order__c = 2, sub_section_fieldset__c = 'when_was_complain_made'),					 
                new Routing_logic__c(Name = 'Resolution',  Step__c = steps[1].Id, RecordTypeId = ROUTING_LOGIC_SECTION_REC_TYPE_ID,
                					 Parent_section__c = 'Section 3', Re_Render_block__c = 'PBlock03', page_order__c = 2, sub_section_fieldset__c = 'Resolution'),
                new Routing_logic__c(Name = 'When was complaint made	',  Step__c = steps[3].Id, RecordTypeId = ROUTING_LOGIC_SECTION_REC_TYPE_ID,
                					 Parent_section__c = 'Section 3', Re_Render_block__c = 'PBlock03', page_order__c = 2, sub_section_fieldset__c = 'when_was_complain_made')
            };
		insert routingLogics;

        List<Routing_field__c> routingFields = 
			new List<Routing_field__c> {
                new Routing_field__c(
                    Routing_logic__c = routingLogics[0].Id, RecordTypeId = sectionfield, name = 'Did_the_candidate_comment_complain__c' , 
                    Logic_type__c = 'AND', Operator__c = 'Equals', Value__c = 'Yes'),
               new Routing_field__c(
                    Routing_logic__c = routingLogics[1].Id, RecordTypeId = routingfield, name = 'TA_mistake__c' , 
                    Logic_type__c = 'AND', Operator__c = 'Equals', Value__c = 'Follow up requested'), 
               new Routing_field__c(
                    Routing_logic__c = routingLogics[1].Id, RecordTypeId = sectionfield, name = 'Did_you_offer_the_candidate_a_reschedule__c' , 
                    Logic_type__c = 'OR', Operator__c = 'Equals', Value__c = 'No'), 
               new Routing_field__c(
                    Routing_logic__c = routingLogics[2].Id, RecordTypeId = sectionfield, name = 'Did_the_candidate_comment_complain__c' , 
                    Logic_type__c = 'AND', Operator__c = 'Equals', Value__c = 'Yes'),  
               new Routing_field__c(
                    Routing_logic__c = routingLogics[3].Id, RecordTypeId = sectionfield, name = 'Did_the_candidate_comment_complain__c' , 
                    Logic_type__c = 'AND', Operator__c = 'Equals', Value__c = 'Yes') 
            };
		insert routingFields;

        return routingLogics;
    }

    public static List<Step__c> createMissingResultsRoutingSteps(ID routingId) {

        List<Step__c> steps =
            new List<Step__c>{
                new Step__c(
                    Routing__c = routingId, Name = 'Start', Step_Number__c = 1, Section_Visible__c = 'Section 2; Section 3',
                    Who_is_doing_the_Work__c = 'Worked by Same User', Next_Team__c = 'Program Coordinator', 
                    Has_forked_logic__c = true, Personas_Can_Edit__c = 'System Administrator', Go_to_Step__c = 2,
                    Personas_Can_Accept__c = 'System Administrator', Personas_Can_Close__c = 'System Administrator'),
                new Step__c(
                    Routing__c = routingId, Name = 'Any internal user', Step_Number__c = 2, Go_to_Step__c = 3,
                    Section_Visible__c = 'Section 1; Section 2; Section 3; Section 4', Who_is_doing_the_Work__c = 'Same owner', 
                    Next_Team__c = 'Program Coordinator', Has_forked_logic__c = true, 
                    Personas_Can_Edit__c = 'System Administrator', Personas_Can_Accept__c = 'System Administrator', 
                    Personas_Can_Close__c = 'System Administrator'),
                new Step__c(
                    Routing__c = routingId, Name = 'Program Coordinator', Step_Number__c = 3, Go_to_Step__c = 4,
                    Section_Visible__c = 'Section 1; Section 2; Section 3; Section 4', Who_is_doing_the_Work__c = 'Program_Coordinator', 
                    Next_Team__c = 'Program Coordinator', Has_forked_logic__c = true, 
                    Personas_Can_Edit__c = 'System Administrator', Personas_Can_Accept__c = 'System Administrator', 
                    Personas_Can_Close__c = 'System Administrator'),
                new Step__c(
                    Routing__c = routingId, Name = 'Program Coordinator', Step_Number__c = 4, Go_to_Step__c = 5,
                    Section_Visible__c = 'Section 1; Section 2; Section 3; Section 4', Who_is_doing_the_Work__c = 'Program_Coordinator', 
                    Next_Team__c = 'Program Coordinator', Has_forked_logic__c = true, 
                    Personas_Can_Edit__c = 'System Administrator', Personas_Can_Accept__c = 'System Administrator', 
                    Personas_Can_Close__c = 'System Administrator'),
                new Step__c(
                    Routing__c = routingId, Name = 'Program Coordinator', Step_Number__c = 5, Go_to_Step__c = 6,
                    Section_Visible__c = 'Section 1; Section 2; Section 3; Section 4', Who_is_doing_the_Work__c = 'Any internal user', 
                    Next_Team__c = 'Closed', Has_forked_logic__c = true, 
                    Personas_Can_Edit__c = 'System Administrator', Personas_Can_Accept__c = 'System Administrator', 
                    Personas_Can_Close__c = 'System Administrator'),
                new Step__c(
                    Routing__c = routingId, Name = 'Program Coordinator', Step_Number__c = 6, 
                    Section_Visible__c = 'Section 1; Section 2; Section 3; Section 4', Who_is_doing_the_Work__c = 'Any internal user', 
                    Next_Team__c = 'Closed', Has_forked_logic__c = true, Go_to_Step__c = 7,
                    Personas_Can_Edit__c = 'System Administrator', Personas_Can_Accept__c = 'System Administrator', 
                    Personas_Can_Close__c = 'System Administrator'),
                new Step__c(
                    Routing__c = routingId, Name = 'Completed', Step_Number__c = 7, Go_to_Step__c = 2,
                    Section_Visible__c = 'Section 1; Section 2; Section 3; Section 4; Section 7', 
                    Who_is_doing_the_Work__c = 'Closed', Personas_Can_Edit__c = 'System Administrator')};
		insert steps;
        return steps;
    }

    public static List<Routing_logic__c> createMissingResultsRoutingLogics(List<Step__c> steps) {

	    string dSectionrectypeid = Schema.Sobjecttype.Routing_Logic__c.getRecordtypeInfosbyname().get('Dynamic Section Logic').getrecordtypeid();
	    string routingfield = Schema.Sobjecttype.Routing_Field__c.getRecordtypeInfosbyname().get('Dynamic Routing Field').getrecordtypeid();
	    string sectionfield = Schema.Sobjecttype.Routing_field__c.getRecordtypeInfosbyname().get('Dynamic Sections Field').getrecordtypeid();
		

        List<Routing_logic__c> routingLogics = 
            new List<Routing_logic__c> {
                new Routing_logic__c(Name = 'Dummy Logic Step 1',  Step__c = steps[0].Id, Go_to_step__c = 2, RecordTypeId = ROUTING_LOGIC_ROUTING_REC_TYPE_ID),
                new Routing_logic__c(Name = 'Dummy Logic Step 2',  Step__c = steps[1].Id, Go_to_step__c = 3, RecordTypeId = ROUTING_LOGIC_ROUTING_REC_TYPE_ID),
                new Routing_logic__c(Name = 'Dummy Logic Step 3',  Step__c = steps[2].Id, Go_to_step__c = 4, RecordTypeId = ROUTING_LOGIC_ROUTING_REC_TYPE_ID),
                new Routing_logic__c(Name = 'Dummy Logic Step 4',  Step__c = steps[3].Id, Go_to_step__c = 5, RecordTypeId = ROUTING_LOGIC_ROUTING_REC_TYPE_ID),
                new Routing_logic__c(Name = 'Dummy Logic Step 5',  Step__c = steps[4].Id, Go_to_step__c = 6, RecordTypeId = ROUTING_LOGIC_ROUTING_REC_TYPE_ID),
                new Routing_logic__c(Name = 'Dummy Logic Step 6',  Step__c = steps[5].Id, Go_to_step__c = 7, RecordTypeId = ROUTING_LOGIC_ROUTING_REC_TYPE_ID),
                new Routing_logic__c(Name = 'Dummy Logic Step 7 - Completed',  Step__c = steps[6].Id, Go_to_step__c = 8, RecordTypeId = ROUTING_LOGIC_ROUTING_REC_TYPE_ID)
            };
		insert routingLogics;

        List<Routing_field__c> routingFields = 
			new List<Routing_field__c> {
                new Routing_field__c(
                    Routing_logic__c = routingLogics[0].Id, RecordTypeId = routingfield, name = 'Subject' , 
                    Logic_type__c = 'AND', Operator__c = 'Equals', Value__c = 'Missing results'),
                new Routing_field__c(
                    Routing_logic__c = routingLogics[0].Id, RecordTypeId = routingfield, name = 'Status' , 
                    Logic_type__c = 'AND', Operator__c = 'Equals', Value__c = 'Being created'),
                new Routing_field__c(
                    Routing_logic__c = routingLogics[1].Id, RecordTypeId = routingfield, name = 'Subject' , 
                    Logic_type__c = 'OR', Operator__c = 'Equals', Value__c = 'Missing results'),
                new Routing_field__c(
                    Routing_logic__c = routingLogics[1].Id, RecordTypeId = routingfield, name = 'Status' , 
                    Logic_type__c = 'OR', Operator__c = 'Not equals', Value__c = ''),
                new Routing_field__c(
                    Routing_logic__c = routingLogics[2].Id, RecordTypeId = routingfield, name = 'CreatedDate' , 
                    Logic_type__c = 'AND', Operator__c = 'Less than', subtractionfield__c = 'LastModifiedDate', 
                    Value__c = '30'),
                new Routing_field__c(
                    Routing_logic__c = routingLogics[3].Id, RecordTypeId = routingfield, name = 'CreatedDate' , 
                    Logic_type__c = 'AND', Operator__c = 'Greater than', subtractionfield__c = 'LastModifiedDate', 
                    Value__c = '-1'),
                new Routing_field__c(
                    Routing_logic__c = routingLogics[4].Id, RecordTypeId = routingfield, name = 'CreatedDate' , 
                    Logic_type__c = 'AND', Operator__c = 'Greater than', subtractionfield__c = 'LastModifiedDate', 
                    Value__c = '-1'),
                new Routing_field__c(
                    Routing_logic__c = routingLogics[5].Id, RecordTypeId = routingfield, name = 'CreatedDate' , 
                    Logic_type__c = 'AND', Operator__c = 'Greater than', subtractionfield__c = 'LastModifiedDate', 
                    Value__c = '10')
            };
                insert routingFields;

        return routingLogics;
    }

// new set of routing logics to support testing  biometrics

    public static Routing__c createBackupBiometricRouting() {


		Schema.DescribeFieldResult F = Routing__c.Related_lists__c.getDescribe();
		List<Schema.PicklistEntry> P = F.getPicklistValues();

        Routing__c routing = 
            new Routing__c(
        		Name = 'Backup Biometrics',
                //Case_config_Id__c = '',
                Case_Record_Type__c = 'Backup biometric missing',
                Final_Category_Name__c = '2003 Upload backup biometric',
                Knowledge_search__c = '',
                Mass_Reschedule_Button__c = 'System Administrator; VSS Level 1',
                Missing_Results_Button__c = 'System Administrator',
                Related_Lists__c = P[0].getValue(),
                Section_1_field_set__c = 'Description',
                Section_2_field_set__c = 'Case_standard_field3',
                Section_1_header__c = 'Summary',
                Section_2_header__c = 'Assignment');
        insert routing;

        return routing;
    }

    public static List<Step__c> createBackupBiometricSteps(ID routingId) {


		string rectypeid = Schema.Sobjecttype.Step__c.getRecordtypeInfosbyname().get('Routing Step').getrecordtypeid();
        List<Step__c> steps =
            new List<Step__c>{
                new Step__c(
                    Routing__c = routingId, Name = 'Start', Step_Number__c = 1, Section_Visible__c = 'Section 2',
                    Who_is_doing_the_Work__c = 'Test_Center', Next_Team__c = 'Program Coordinator', Go_to_step__c = 6, 
                    Has_forked_logic__c = true),
                new Step__c(
                    Routing__c = routingId, Name = 'Worked by Program Coordinator', Step_Number__c = 2, 
                    Section_Visible__c = 'Section 1; Section 2; Section 3', Who_is_doing_the_Work__c = 'Program_Coordinator', 
                    Next_Team__c = 'Results Processing, Channel Quality', Go_to_step__c = 4, Has_forked_logic__c = true),
                new Step__c(
                    Routing__c = routingId, Name = 'Worked by Results Processing', Step_Number__c = 3, 
                    Section_Visible__c = 'Section 1; Section 2; Section 3', Who_is_doing_the_Work__c = 'Results_Processing', 
                    Next_Team__c = 'Channel Quality, Closed', Go_to_step__c = 5, Has_forked_logic__c = true),
                new Step__c(
                    Routing__c = routingId, Name = 'Worked by Channel Quality', Step_Number__c = 4, 
                    Section_Visible__c = 'Section 1; Section 2; Section 3', 
                    Who_is_doing_the_Work__c = 'Channel_Quality', Next_Team__c = 'Closed', Go_to_step__c = 5, 
                    Has_forked_logic__c = false),
                new Step__c(
                    Routing__c = routingId, Name = 'Completed', Step_Number__c = 5, 
                    Section_Visible__c = 'Section 1; Section 2; Section 3', Who_is_doing_the_Work__c = 'Closed', 
                    Next_Team__c = '',Has_forked_logic__c = false),
                new Step__c(
                    Routing__c = routingId, Name = 'Worked by Test Center Admin - Add Attachment', Step_Number__c = 6, 
                    Section_Visible__c = 'Section 1; Section 2; Section 3', 
                    Who_is_doing_the_Work__c = 'Test_Center', Next_Team__c = 'Program Coordinator', Go_to_step__c = 6, Has_forked_logic__c = false)};
		insert steps;
        return steps;
    }

    public static List<Routing_logic__c> createBackupBiometricRoutingLogics(List<Step__c> steps) {

		string routingrectypeid = Schema.Sobjecttype.Routing_Logic__c.getRecordtypeInfosbyname().get('Dynamic Routing Logic').getrecordtypeid();
	    string dSectionrectypeid = Schema.Sobjecttype.Routing_Logic__c.getRecordtypeInfosbyname().get('Dynamic Section Logic').getrecordtypeid();
	    string routingfield = Schema.Sobjecttype.Routing_Field__c.getRecordtypeInfosbyname().get('Dynamic Routing Field').getrecordtypeid();
	    string sectionfield = Schema.Sobjecttype.Routing_field__c.getRecordtypeInfosbyname().get('Dynamic Sections Field').getrecordtypeid();


        List<Routing_logic__c> routingLogics = 
            new List<Routing_logic__c> {
                new Routing_logic__c(Name = 'Has_Attachment__c True', RecordTypeId = routingrectypeid, Step__c = steps[0].Id, Go_to_step__c = 2),
                new Routing_logic__c(Name = 'Has_Attachment__c False', RecordTypeId = routingrectypeid, Step__c = steps[0].Id, Go_to_step__c = 1),
                new Routing_logic__c(Name = 'Client_is_ARRT__c True', RecordTypeId = routingrectypeid, Step__c = steps[1].Id, Go_to_step__c = 3),
                new Routing_logic__c(Name = 'Reassign_to_Channel_Quality__c True', RecordTypeId = routingrectypeid, Step__c = steps[2].Id, Go_to_step__c = 4)
            };
		insert routingLogics;

        List<Routing_field__c> routingFields = 
			new List<Routing_field__c> {
                new Routing_field__c(
                    Routing_logic__c = routingLogics[0].Id, recordtypeid = routingfield, name = 'Has_Attachment__c' , 
                    Logic_type__c = 'AND', Operator__c = 'Not equals', Value__c = 'True'),
                new Routing_field__c(
                    Routing_logic__c = routingLogics[1].Id, recordtypeid = routingfield, name = 'Has_Attachment__c' , 
                    Logic_type__c = 'AND', Operator__c = 'Not Equals', Value__c = 'False'),
                new Routing_field__c(
                    Routing_logic__c = routingLogics[2].Id, recordtypeid = routingfield, name = 'Client_is_ARRT__c' , 
                    Logic_type__c = 'AND', Operator__c = 'Not equals', Value__c = 'True'),
                new Routing_field__c(
                    Routing_logic__c = routingLogics[3].Id, recordtypeid = routingfield, name = 'Reassign_to_Channel_Quality__c' , 
                    Logic_type__c = 'AND', Operator__c = 'Not equals', Value__c = 'True')
            };
		insert routingFields;

        return routingLogics;
    }


    public static Routing__c createExamErrorRouting() {


		Schema.DescribeFieldResult F = Routing__c.Related_lists__c.getDescribe();
		List<Schema.PicklistEntry> P = F.getPicklistValues();

        Routing__c routing = 
            new Routing__c(
        		Name = 'Exam error during test/launch',
                //Case_config_Id__c = '',
                Case_Record_Type__c = 'VSS Exam delivery issue',
                Final_Category_Name__c = 'Exam error during test/launch',               
                Knowledge_search__c = '',
                Related_Lists__c = P[0].getValue(),
                Section_1_field_set__c = 'Description',
                Section_2_field_set__c = 'Case_standard_field3',
                Section_3_field_set__c = 'VSS_delivery_issues',
                Section_4_field_set__c = 'Summarize_the_issue');
        insert routing;

        return routing;
    }

    public static List<Step__c> createExamErrorRoutingSteps(ID routingId) {
		
		string rectypeid = Schema.Sobjecttype.Step__c.getRecordtypeInfosbyname().get('Routing Step').getrecordtypeid();
        List<Step__c> steps =
            new List<Step__c>{
                new Step__c(
                    Routing__c = routingId, Name = 'Start', Step_Number__c = 1, Section_Visible__c = 'Section 2; Section 3;Section 4',
                    Who_is_doing_the_Work__c = 'VSS_Level_1', Next_Team__c = 'Same Owner, VSSL2', Go_to_step__c = 2, 
                    Has_forked_logic__c = true, Personas_Can_Edit__c = 'System Administrator', 
                    Personas_Can_Accept__c = 'System Administrator', Personas_Can_Close__c = 'System Administrator'),
                new Step__c(
                    Routing__c = routingId, Name = 'Worked by VSSL1 - Add attachment', Step_Number__c = 2, 
                    Section_Visible__c = 'Section 1; Section 2; Section 3', Who_is_doing_the_Work__c = 'Same owner', 
                    Next_Team__c = 'Closed', Go_to_step__c = 4, Has_forked_logic__c = false, 
                    Personas_Can_Edit__c = 'System Administrator', Personas_Can_Accept__c = 'System Administrator', 
                    Personas_Can_Close__c = 'System Administrator'),
                new Step__c(
                    Routing__c = routingId, Name = 'Worked by VSSL2', Step_Number__c = 3, 
                    Section_Visible__c = 'Section 1; Section 2; Section 3', Who_is_doing_the_Work__c = 'VSS_Level_2', 
                    Next_Team__c = 'Same Owner', Go_to_step__c = 2, Has_forked_logic__c = false, 
                    Personas_Can_Edit__c = 'System Administrator', Personas_Can_Accept__c = 'System Administrator', 
                    Personas_Can_Close__c = 'System Administrator'),
                new Step__c(
                    Routing__c = routingId, Name = 'Completed', Step_Number__c = 4, 
                    Section_Visible__c = 'Section 1; Section 2; Section 3', 
                    Who_is_doing_the_Work__c = 'Closed', Next_Team__c = '', Go_to_step__c = null, 
                    Has_forked_logic__c = false, 
                    Personas_Can_Edit__c = 'System Administrator', Personas_Can_Accept__c = 'System Administrator', 
                    Personas_Can_Close__c = 'System Administrator')};
		insert steps;
        return steps;
    }

    public static List<Routing_logic__c> createErrorRoutingLogics(List<Step__c> steps) {

		string routingrectypeid = Schema.Sobjecttype.Routing_Logic__c.getRecordtypeInfosbyname().get('Dynamic Routing Logic').getrecordtypeid();
	    string dSectionrectypeid = Schema.Sobjecttype.Routing_Logic__c.getRecordtypeInfosbyname().get('Dynamic Section Logic').getrecordtypeid();
	    string routingfield = Schema.Sobjecttype.Routing_Field__c.getRecordtypeInfosbyname().get('Dynamic Routing Field').getrecordtypeid();
	    string sectionfield = Schema.Sobjecttype.Routing_field__c.getRecordtypeInfosbyname().get('Dynamic Sections Field').getrecordtypeid();
	    
        List<Routing_logic__c> routingLogics = 
            new List<Routing_logic__c> {
                new Routing_logic__c(Name = 'Send_to_VSSL2__c True', Step__c = steps[0].Id, Go_to_step__c = 3,recordtypeid = schema.Sobjecttype.Routing_logic__c.getRecordtypeinfosbyname().get('Dynamic Routing Logic').getrecordtypeid())
            };
		insert routingLogics;

        List<Routing_field__c> routingFields = 
			new List<Routing_field__c> {                
                new Routing_field__c(
                    Routing_logic__c = routingLogics[0].Id, name = 'Send_to_VSSL2__c' , 
                    Logic_type__c = 'AND', Operator__c = 'Equals', Value__c = 'True', recordtypeid = schema.Sobjecttype.Routing_field__c.getRecordtypeinfosbyname().get('Dynamic Routing Field').getrecordtypeid())                
            };
		insert routingFields;

        return routingLogics;
    }
    /*
    public static List<Case_API_Field__c> createCaseAPIFieldSettings() {
        List<Case_API_Field__c> settings = new List<Case_API_Field__c>();
        
        settings.add(new Case_API_Field__c(Name = 'CaseId', Case_Field__c = 'Id'));
        settings.add(new Case_API_Field__c(Name = 'Status', Case_Field__c = 'Status'));
        
        insert settings;
        
        return settings;
    }

*/

}