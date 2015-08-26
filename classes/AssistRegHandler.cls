public class AssistRegHandler implements Auth.RegistrationHandler {
    
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
        string VTS_AgentId = data.attributemap.get('realm') + '-' + data.attributemap.get('sub') ;
        system.debug('realm::' + data.attributemap.get('realm'));
        //Set up permissions
        PermissionSetSetup myset = new permissionsetsetup(); 
         
        
/* this section removed for Assist only Reghandler
      if(data.attributeMap.containsKey('sfdc_networkid'))  
        {   
            list<string> mygrants = data.attributemap.get('grant').split(':');
            SiteID = integer.valueOf(mygrants[4]);
            system.debug('data::' + data);
            system.debug('realm::' + data.attributemap.get('realm'));
            user u = new user();
            string myusername = do_username(data, true, siteID);
            
            u = CommunityUser(u, data, myset, myusername);
            //We have a community id, so create a user with community access 
            configureUser(PortalId, u, 'Test Center Admin - Community', data, null, myset, SiteID, myusername);
            system.debug('new community user::' + u);
            if(u.id == null)
                {
                    insert (u);
                }
            else{update u;}    
            dopermissionsets(u.username, data.attributemap.get('grant'));  
            system.debug('Handler.CreateUser Finished updated external user::'+u);     
            return u;
        } 
     else */
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
    string VTS_AgentId = data.attributemap.get('realm') + data.attributemap.get('sub') ; 
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
                    u = new user (VTS_Agent_ID__c = VTS_AgentID, username = myusername, firstname = data.attributemap.get('firsname'));
                    //fields to update
                    
                    
                    needsinsert = true ;
                }
        }    
 /* remove this section for Assist Reghandler.  Internal users only provisioned   
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
             
            
             configureUser(PortalId, u, 'Test Center Admin - Community', data, c, myset, siteID, myusername);
        }

    else{  */
            permissionsetsetup.configureuser(PortalId, u, 'Internal common settings profile', data, null, myset, null, myusername);
            u.UserPermissionsSupportUser = true;
        //}
       //build a set of current permissionsetAssignments so as to avoid duplicates
     
     u.VTS_Agent_id__c = VTS_AgentId;
     u.firstname = data.firstname;
     u.lastname = data.lastname;
     u.email = data.email;
     u.username = myusername;
     
     //TODO:  look at using configureuser method from Permissionsetup
     
     if(u.id != null)
         {
            update(u);
            system.debug('user '+ u + ' ::updated');
         }
     else
         {
         insert(u);
         system.debug('User ' + u + ' ::created');
         }   
    permissionsetsetup.dopermissionsets(u.username, data.attributemap.get('grant'));  
    system.debug('END Handler.UpdateUser');  
    
    }
}