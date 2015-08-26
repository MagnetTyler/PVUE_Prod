public class ConnectRegHandler implements Auth.RegistrationHandler {
    
    // **************************************************************************************************
//
//                          CREATE USER
//
//
// **************************************************************************************************
    public User createUser(Id portalId, Auth.UserData data){
    system.debug('Handler.CreateUser called'+portalid);
        
        //boolean helps in adding the name of the first permission set as the primary role for a user
        boolean primaryroleassigned = false;
        integer SiteID;
        string VTS_AgentId = data.attributemap.get('realm') + data.attributemap.get('sub') ;
        system.debug('realm::' + data.attributemap.get('realm'));
        //Set up permissions
        PermissionSetSetup myset = new permissionsetsetup(); 
         
        

      if(data.attributeMap.containsKey('sfdc_networkid'))  
        {   
             list<string> mygrants = data.attributemap.get('grant').split(':');
            SiteID = integer.valueOf(mygrants[4]);
            system.debug('data::' + data);
            system.debug('realm::' + data.attributemap.get('realm'));
            user u = new user();
            string myusername = permissionsetsetup.setup_username(data, true, siteID);
            
            u = CommunityUser(u, data, myset, myusername);
            //We have a community id, so create a user with community access 
            permissionsetsetup.configureUser(PortalId, u, 'Test Center Admin - Community', data, null, myset, SiteID, myusername);
            system.debug('new community user::' + u);
            if(u.id == null)
                {
                    insert (u);
                }
            else{update u;}    
            permissionsetsetup.dopermissionsets(u.username, data.attributemap.get('grant'));  
            system.debug('Handler.CreateUser Finished updated external user::'+u);     
            return u;
        } 
     else
        {
               
             string myusername = permissionsetsetup.setup_username(data, false, SiteID);
             User u = new User(VTS_Agent_id__c = VTS_AgentID);
             u.username = myusername;
          permissionsetsetup.configureuser(portalId, u, 'Internal common settings profile', data, null, myset, null, myusername);
             u.UserPermissionsSupportUser = true;
            //build a set of current permissionsetAssignments so as to avoid duplicates
             permissionsetsetup.dopermissionsets(u.username, data.attributemap.get('grant'));
                
             system.debug('Handler.CreateUser Finished New internal user::'+u);
             return u;
        
        }

}


// **************************************************************************************************
//
//                          UPDATE USER
//
//
// **************************************************************************************************

public void updateUser(Id userId, Id portalId, Auth.UserData data){
    system.debug('Handler.UpdateUser Called'+userid);
    boolean needsinsert = false;
    string VTS_AgentId = data.attributemap.get('realm') + '-' + data.attributemap.get('sub') ;
    system.debug('realm::' + data.attributemap.get('realm')); 

        boolean primaryroleassigned = false;
        //maps to get the grant code which is a number translated to the name of a permission set and get that permission set assigned ot the user
        
        PermissionSetSetup myset = new permissionsetsetup();
        //list of grants for this user from the data map        
          
    
    system.debug('data::' + data);
        string userquery = 'SELECT contact.VTS_Agent_ID__c, ' + utility.editablefields('User') + ' FROM USER WHERE VTS_AGENT_ID__C = :VTS_AgentID';
        string usersearch2 = 'SELECT contact.VTS_Agent_ID__c, ' + utility.Editablefields('User') + ' from User where Username = :myusername';  
        integer siteID;
        string myusername = '';
         if(data.attributeMap.containsKey('sfdc_networkid')) 
             {
             list<string> mygrants = data.attributemap.get('grant').split(':');
             siteID = integer.valueOf(mygrants[4]);
             myusername = permissionsetsetup.setup_username(data,true, siteID);
             }
        else
            {myusername = permissionsetsetup.setup_username(data,false, siteID);}
        user u = new user();
    
    Try{
            u = database.query(userquery);  
                 
        }
        
    catch (system.queryException qe)
        {   
            try
                {
                    u = database.query(usersearch2);
                }
            catch(system.queryexception usernamequery)
                {
                    System.debug('no user found with username');
                    System.debug('myusername::'+myusername);
                    u = new user (VTS_Agent_ID__c = VTS_AgentID, username = myusername);
                    needsinsert = true ;
                }
        }    
    
    if(data.attributeMap.containsKey('sfdc_networkid')) 
        {      
             contact c = new contact(id = u.contactid, firstname = data.firstname, lastname = data.lastName, email = data.email);
             if(u.contact.VTS_Agent_ID__C == null)
                 {
                     c.VTS_Agent_ID__c = VTS_AgentID;
                     c.lastName = data.lastName;
                     c.firstName = data.firstName;
                     c.email = data.email;
                 }
             
             u.VTS_Agent_id__c = VTS_AgentId; 
             
            
             permissionsetsetup.configureUser(PortalId, u, 'Test Center Admin - Community', data, c, myset, siteID, myusername);
        }

    else{  
            permissionsetsetup.configureuser(PortalId, u, 'Internal common settings profile', data, null, myset, null, myusername);
            u.UserPermissionsSupportUser = true;
        }
       //build a set of current permissionsetAssignments so as to avoid duplicates
 
    system.debug('new community user::' + u +'and contact::' + u.contact);
     
     //new code to update fields each time
     u.firstname = data.firstname;
     u.lastname = data.lastname;
     u.username = myusername;
     u.vts_agent_id__c = VTS_AgentID;
     u.email= data.email;
     
     if(u.id != null)
         {
            update(u);
         }
     else
         {
         insert(u);
         system.debug('User ' + u + 'created');
         }   
    permissionsetsetup.dopermissionsets(u.username, data.attributemap.get('grant'));  
    system.debug('END Handler.UpdateUser');  
    
    }




// **************************************************************************************************
//
//                          helper methods USER
//
//
// **************************************************************************************************



    public static contact createcontact(string VTS_AgentID, integer testcenterId, auth.userdata data)    
        {
            string contactsearch = 'SELECT ' + utility.editablefields('Contact') + ' from Contact where VTS_Agent_id__c =: VTS_AgentId AND VTS_Agent_Id__c != null'; 
            string accountsearch = 'SELECT ' + utility.editablefields('Account') + ' from Account where VTS_Test_Center_ID__c = :testcenterId';
    
            Account User_Test_center;
            User_test_center = database.query(accountsearch);
                    
            Contact c = new contact();
            try{
                c = database.query(contactsearch);
                }
            Catch (exception queryexception)
                {
                    system.debug('contact doesn\'t exist so create one and insert in VTS');
                    c = new contact( firstname = data.firstname, lastname = data.lastName, email = data.email, accountid = User_test_center.id, VTS_Agent_id__c = VTS_AgentID );
                    
                }
                return c;
        }
    

    //  class to set up the account and contact for a community user 
//  return's a user with a looked up contact or a newly creted contact, associated with an account which is retrieved from the 
//  grant info.


        public static user CommunityUser(user u, auth.userdata data, PermissionSetSetup myset, string myusername){
            
            list<string> mygrants = data.attributemap.get('grant').split(':');
            integer testcenterId = integer.valueOf(mygrants[4]); 
            
            string useremail = data.email; 
            string VTS_AgentId = data.attributemap.get('realm') + data.attributemap.get('sub') ;
            system.debug('realm::' + data.attributemap.get('realm'));
            
            
            contact c = createcontact(VTS_AgentId, testcenterID, data);
            u.contact = c;
            string contactid = c.id;
            
            
            string usersearch = 'SELECT contact.VTS_Agent_ID__c, ' + utility.Editablefields('User') + ' from User where VTS_Agent_id__c = :VTS_AgentID';          
            string usersearch2 = 'SELECT contact.VTS_Agent_ID__c,  ' + utility.Editablefields('User') + ' from User where username = :myusername';  
            
            //check to see if a user already exists
            try
                {
                    u = database.query(usersearch);
                 //   u.Contact = new contact(VTS_Agent_id__c = vts_agentID);
                    u.VTS_Agent_id__c = VTS_AgentID;
                }
            Catch (exception userqueryexception)
                {
                    system.debug('CommunityUser exception thrown::' + userqueryexception);
                    try{
                        u = database.query(usersearch2);
                       }
                    catch (system.queryexception Usersearch2query)
                        {
                            system.debug('User not found using username');
                            system.debug('myusername::'+myusername);
                           // insert c;
                           // u.contactid = c.id;
                        }   
                   // u.Contact = new contact(VTS_Agent_id__c = vts_agentID);
                    u.VTS_Agent_id__c = VTS_AgentID;
                    
                    
                }   
            
            if(u == null)
                {
                    u = new User(contactid = c.id, VTS_Agent_id__c = VTS_AgentID);
                }
    
            //TODO: Customize the username and profile. Also check that the username doesn't already exist and
            //possibly ensure there are enough org licenses to create a user. Must be 80 characters or less.
            
          //permissionsetsetup.configureuser(null, u, 'Test Center Admin - Community', data, c, myset, testcenterId,myusername);
            
            return u;
        }

     //configure method for community users (takes a contact)            
        public  void configureuser(Id Portalid, user u, string profilename, auth.userdata data, contact c, permissionsetSetup myset, integer siteID, string myusername)
            {

                permissionsetsetup.Create_or_update_user(u, data, SiteId!=null, siteID, myusername);
                if(SiteId != null)
                {
                    contact temp_c = u.contact;
                    if(u.contactId == null)
                        {   
                            temp_c.firstname = data.firstname;
                            temp_c.lastname = data.lastname;
                            temp_c.email = data.email;
                            Temp_c.VTS_Agent_id__c = u.contact.VTS_Agent_ID__C;
                            temp_c.AccountId = u.contact.AccountId;
                            insert temp_c;
                            u.contactId = temp_c.id;
                        }
                        else
                        {
                            temp_c = new contact(id = u.contactId);
                            temp_c.vts_agent_id__c = u.contact.vts_agent_id__c;
                            temp_c.firstname = data.firstname;
                            temp_c.lastname = data.lastname;
                            temp_c.email = data.email;
                            update(temp_c);
                        }
                   } 
                u.profileId = myset.profilemap.get(profilename).id;  
                u.firstname = data.firstname;
                u.lastname = data.lastName;
                u.username = myusername;
                u.email = data.email;                
            }                
}