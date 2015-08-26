@isTest
public class User_TriggerTest {

    static testMethod void TriggerTest(){

        User u = TestUtil.createUser();
        u.profileId = [select Id from Profile where Name != 'System Administrator' limit 1].Id;
        insert u;
        
        User u_admin = TestUtil.createUser();
        u_admin.profileId = [select Id from Profile where Name = 'System Administrator' limit 1].Id;
        insert u_admin;
        
        system.runAs(u){
            u_admin.FirstName = 'test u';
            
            try{
            	update u_admin;
            }catch(DmlException e){
                system.assert( (e.getMessage()).indexOf('Only System Administrators May Edit Profile Data') != -1 );
            }
        }
    }
}