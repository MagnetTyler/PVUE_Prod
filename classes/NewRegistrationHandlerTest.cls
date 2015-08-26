@isTest
private class NewRegistrationHandlerTest {
    static testMethod void testCreateAndUpdateUser() {
        
        user u2 = datafactory.createUser();
        
        system.runAs( new User( Id = UserInfo.getUserId() )){
        Contact c = new Contact();
        c.LastName = ' test last name';
        c.Email = 'testuser@example.org';
        insert c;
        
        VTS_Role_Code__c rc = new VTS_Role_Code__c();
        rc.Name = '38 - Assist Application Administrative';
        rc.Permission_Set_Name__c = 'VSS L1';
        rc.Grant_Code__c = '38';
        insert rc;
        
        VTS_Role_Code__c rc1 = new VTS_Role_Code__c();
        rc1.Name = '24-Test Center User';
        rc1.Permission_Set_Name__c = 'TA';
        rc1.Grant_Code__c = '24';
        insert rc1;     
        }
 
            
        
            AssistRegHandler handler = new AssistRegHandler();
           

            Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                'testFirst testLast', 'testuser@pearson.com', null, 'testuserlong@pearson.com', 'en_US', 'facebook',
                null, new map<string, string> {'grant'=>'38:13:A&#124;11:14:A','preferredUserName'=>'testuser', 'realm'=>'EMPLOYEE', 'sub'=>'427'});
            User u = handler.createUser(null, sampleData);
            
            system.runAs( new User( Id = UserInfo.getUserId() )){
            insert u; 


            system.debug(' u.id :: ' + u.id);
            System.assertEquals('testuser@pearson.com', u.email);
            System.assertEquals('testLast', u.lastName);
            System.assertEquals(u.userName.contains('testuser@pearson.com'),true);
        
            
            try{
            sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast',
                'testNewFirst testNewLast', 'testnewuser@pearson.com', null, 'testnewuserlong@pearson.com', 'en_US', 'facebook',
                null, new Map<String, String>{'grant'=>'38:13:A&#124;11:14:A','preferredUserName'=>'changeduser','username'=>'changeduser','realm'=>'EMPLOYEE', 'sub'=>'427'});
            handler.updateUser(u.id, null, sampleData);
            system.assertnotequals(null,u.id);
            update U2;
            
                    User updatedUser = [SELECT userName, email, firstName, lastName, alias FROM user WHERE id=:u.id];
                }
            catch(exception a){}    

           // System.assertEquals(u.userName,'changeduser@pearson.com');
           // System.assertEquals('testnewuser@pearson.com', updatedUser.email);
          //  System.assertEquals('testNewLast', updatedUser.lastName);
          //  System.assertEquals('testNewFirst', updatedUser.firstName);
          //  System.assertEquals('testuser', updatedUser.alias);
        }   
        
    }
    
    static testMethod void testCreateAndUpdateUserWithNetworkId() {
         //    user u2 = datafactory.createUser();
            string UserRoleId = [select id from UserRole where name = 'Administrator' or name = 'Technical Implementation Team' limit 1].id;
             user u2=[select username, id, userroleID from user where userRoleId = : UserRoleId and isactive = true limit 1];  
             
         //    update u2;
         system.runAs( new User( Id = UserInfo.getUserId() )){
        Account mytestcenter = new Account();
            mytestcenter.RecordTypeId = schema.sobjecttype.Account.getrecordtypeinfosbyname().get('Site').getrecordtypeid();
            mytestcenter.VTS_Test_Center_ID__c = 200080332;
            mytestcenter.Name = 'MytestCenter';
            mytestcenter.ownerid = u2.id;
            insert mytestcenter;

        /*
        Contact c = new Contact();
        c.LastName = ' test last name';
        c.Email = 'testuser@example.org';
        c.accountid = mytestcenter.id;
        insert c; */
        
        VTS_Role_Code__c rc = new VTS_Role_Code__c();
        rc.Name = 'sAdmin';
        rc.Permission_Set_Name__c = 'System Administrator';
        rc.Grant_Code__c = '11';
        insert rc;
        
       
        VTS_Role_Code__c rc1 = new VTS_Role_Code__c();
        rc1.Name = 'AA';
        rc1.Permission_Set_Name__c = 'Call_Center_Agent';
        rc1.Grant_Code__c = '15';
        insert rc1;
        
         VTS_Role_Code__c rc2 = new VTS_Role_Code__c();
        rc2.Name = 'TA';
        rc2.Permission_Set_Name__c = '24-Test Center User';
        rc2.Grant_Code__c = '24';
        rc2.GroupId__c = [select id from group where developername = 'Pearson_service_cloud_external_users'].id;
        insert rc2;
    }
        test.starttest();
        
            ConnectRegHandler handler = new ConnectRegHandler();
            
            Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                'testFirst testLast', 'testuser2@example.org', null, 'testuser2long@example.org', 'en_US', 'facebook',
                null, new Map<String, String>{'grant'=>'24:12:A:I:200080332', 'preferredUserName'=>'testuserlong2', 'realm'=>'TESTCENTER', 'sfdc_networkid'=>'0DBS00000008OTS', 'sub'=>'200734410','username'=>'testuserlong2'});
            
            system.runAs( new User( Id = UserInfo.getUserId() )){    
                User u = handler.createUser('0DBS00000008OTS', sampleData);
            
            u.TimeZoneSidKey = 'GMT';
            u.LocaleSidKey = UserInfo.getLocale();
            u.EmailEncodingKey = 'ISO-8859-1';
            u.LanguageLocaleKey = 'en_US';
            u.alias = 'mytester';
            
          //  insert u;
            System.assertEquals(u.userName.contains('testuserlong2'), true);
            //System.assertEquals('testuser@example.org', u.email);
            //System.assertEquals('testLast', u.lastName);
            //System.assertEquals('testFirst', u.firstName);
            //System.assertEquals('testuser', u.alias);
            //insert(u);
            system.debug(' u.id :: ' + u.id);
            String uid = u.id;
            
            
            sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                'testNewFirst testNewLast', 'testnewuser@pearson.com', null, 'testnewuserlong@pearson.com', 'en_US', 'facebook',
                null, new Map<String, String>{'grant'=>'24:12:A:I:200080332','username'=>'testuserlong2','preferredUserName'=>'testuserlong2','realm'=>'TESTCENTER', 'sub'=>'200734410', 'sfdc_networkid'=>'0DBS00000008OTS'});
            
            handler.updateUser(u.id, '0DBS00000008OTS', sampleData);
            
            User updatedUser = [SELECT userName, email, firstName, lastName, alias FROM user WHERE id=:uid];
            }
       //     System.assertEquals(updatedUser.userName.contains('testuserlong2.1@pearson.com'), true);
       //     System.assertEquals('testnewuser@pearson.com', updatedUser.email);
       //     System.assertEquals('testNewLast', updatedUser.lastName);
       //     System.assertEquals('testNewFirst', updatedUser.firstName);
       //     System.assertEquals('testuser', updatedUser.alias);
        
      test.stoptest();  
    }
}