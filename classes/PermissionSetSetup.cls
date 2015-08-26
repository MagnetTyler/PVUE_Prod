public without sharing class PermissionSetSetup {
    
                public map<string,VTS_Role_code__c> rolemap ; //constructed from the values in the VTS_Role_Code Custom setting
                public map<string,permissionset> permissions ;  // constructed from existing permissionSets.  Retrieve via values in rolemap
                public set<string> currentPermissionIds ;  //set of current permissionsets for a user
                public set<string> currentGroupIds;
                public list<PermissionSetAssignment>PSetAssignments ; //new set of permissionsets for creation
                public list<groupmember> newGroupAssignments;
                public list<list<string>> grants;  // this is the string that comes from the Auth provider which includes the permissions info
                public map<string,profile> profilemap;  
                            
    
     
           public permissionsetSetup()
                {
                
                    this.profilemap = new map<string,profile>();
                    for(Profile p:[SELECT Id,name FROM profile])
                        {
                            profilemap.put(p.name, p);
                        }
                    this.newGroupAssignments = new list<groupmember>();
                    this.rolemap = new map<string,VTS_Role_Code__c>();
                    this.permissions = new map<string,permissionset>();
                    this.currentPermissionIds = new set<string>();
                    this.PSetAssignments = new list<PermissionSetAssignment>(); 
    
      // Create the map of permissionsets for assigning to users            
                    for(PermissionSet eachperm: [select name, label, id from Permissionset where isownedbyprofile = false])
                        {
                            permissions.put(eachperm.Label, eachperm);  
                        }
                    system.debug('permissionset Map::' + permissions);
                            
      
      
      // build the translation map  to which will be used with the grant codes to retrieve permissionsets
                    for(VTS_Role_Code__c eachcode: VTS_Role_Code__c.getall().values())
                        {
                            rolemap.put(eachcode.Grant_Code__c,eachcode);
                        }                   
                }

    public static string setup_username(auth.userdata data, boolean iscommunity, integer SiteID)
        {
            string sandboxsuffix = '';
                string myusername = '';
                
                if(UserInfo.getOrganizationId() != System.Label.OrgId)
                    {
                        sandboxsuffix = [select username from user order by createddate limit 1].username;
                        integer ls = sandboxsuffix.lastindexOf('.');
                        sandboxsuffix = sandboxsuffix.substring(ls);
                    }
           //create or update user             
                if(isCommunity)
                    {
                        myusername = data.attributemap.get('preferredUserName') + '.' + siteID + '@pearson.com' + sandboxsuffix;                                          
                    }
                else
                    {
                        myusername = data.attributemap.get('preferredUserName') + '@pearson.com' + sandboxsuffix;                     
                    }
                  
               return myusername;
        }        
    @future
// class for adding permissionsetassignments to users.
// necessary due to Mixed-DML rules
// class splits the info from "Grant" in the attribute data
//                                    RoleCode(38)       Role Code(11)
//  SAMPLE GRANT Code  internal user   - grant=38:13:A&#124;11:14:A -  
//                                    RikeCode(24)
//  SAMPLE GRANT Code  external user  -  grant=24:12:A:I:1   -

public static void dopermissionsets(string username, string grants_string)
            {

                
                // setup the class for holding the info
                PermissionSetSetup myset = new permissionsetsetup();  
                myset.grants = new list<list<string>>();
                
                //break out the grant into the strings which represent a single set of grant infos
                for( String eachlist:grants_string.split(';'))
                    {
                        myset.grants.add(eachlist.split(':'));
                    }
                //get the user id        
                string userid = [select id from user where username = :username].id;
                
                //list of groups the user is currently a member of
                myset.currentGroupIds = new set<string>();
                set<id> newgroupmembership = new set<id>();
                
                list<groupmember> currentmembership = new list<groupmember>();
                For(groupmember eachgroup : [SELECT GroupId, UserOrGroupId FROM groupmember WHERE UserOrGroupId =: userid]){
                        currentmembership.add(eachgroup);
                        //ids for the current group membership
                        myset.currentGroupIds.add(eachgroup.GroupId);
                }
            

                boolean primaryRoleAssigned = false;
                //new set of permissions being added
                set <id> newPermissionSetAssignments = new set<id>();
                list<id> currentpermissionIds = new list<id>();
                
                
                //permissionsetassignments to delete
                list<permissionSetAssignment> todelete = new list<permissionSetAssignment>();
                list<permissionSetAssignment> currentPermissionSets = new list<permissionSetAssignment>();

                //list of groupmember to delete
                list<groupmember> deletegroups = new list<groupmember>();
                
                //building the list of current permissionsetAssignments
                for(PermissionSetAssignment curr:[select id, PermissionSetId, AssigneeId from PermissionSetAssignment where AssigneeId = :userid AND PermissionSet.isownedbyProfile = false])
                    {
                        myset.currentpermissionIds.add(curr.PermissionSetId);
                        currentPermissionSets.add(curr);
                    } 
            
            for(list<string> eachseries: myset.grants)
                {
                    string eachperm = eachseries[0];
                                            
                    system.debug('Begin Grant Split iteration' + eachperm);
                    
                    Try{
                    
                    string PermissionSetName = myset.rolemap.get(eachperm).Permission_set_Name__c;
                    permissionset selectedperm = myset.permissions.get(PermissionSetName);
                    //build a new groupmember record
                    groupmember newmember = new groupmember(groupid = myset.rolemap.get(eachperm).GroupID__c, UserOrGroupId = userid);
                    
                    
                    newgroupmembership.add(newmember.groupid);
                    
                    
                    if(selectedperm != null)
                        {
                            newPermissionSetAssignments.add(selectedperm.id);
                        }
                    if(selectedperm != null && !myset.currentpermissionIds.contains(selectedperm.id))
                        {
                            PermissionSetAssignment PSA = new PermissionSetAssignment (AssigneeId = userid, PermissionSetId = selectedperm.id);
                            myset.PSetAssignments.add(PSA); 
                            newPermissionSetAssignments.add(PSA.PermissionSetId);
                            
                            
                            if(primaryRoleAssigned == false)
                                {   
                                    user u = new user(id = userid);
                                    u.Primary_team_persona__c =permissionSetName;
                                    primaryRoleAssigned = true;
                                }   
                        }
                    if(newmember.GroupId!= null && !myset.currentGroupIds.contains(newmember.groupId))
                        {
                            myset.newGroupAssignments.add(newmember);
                        }   
                        
                    system.debug('assignments::' + myset.PSetAssignments);              
                   } 
                    catch(exception troublewithtestmethod)
                        {
                            
                        }
                }
                
                for(groupmember eachmember:currentmembership)
                    {
                        if(!newgroupmembership.contains(eachmember.GroupId))
                            {
                                deletegroups.add(eachmember);
                            }
                    }
            
            insert(myset.PSetAssignments);  
            insert(myset.newgroupassignments);
        //remove permissions not included for the most recent update    
            for(PermissionSetAssignment each:currentPermissionSets)
                {
                    if (!newPermissionSetAssignments.contains(each.permissionsetId))
                        {
                            todelete.add(each);
                        }
                }   
            delete(todelete);
            delete(deletegroups);
            
            user u = new user(id=userid);
                update(u);
        }

         public static User Create_or_update_user(user myu, auth.userdata data, boolean iscommunity, integer SiteID, string myusername)
        {
           PermissionSetSetup myset = new permissionsetsetup();
           //get the unique ID for the contact and user
                
                if(iscommunity)
                    {
                         myu = ConnectRegHandler.CommunityUser(myu, data, myset, myusername) ;
                        
                    }
                 
                myu.username = myusername;                                  
                myu.email = data.email;
                myu.lastName = data.lastName;
                myu.firstName = data.firstName;
                String alias = myu.username;
                //Alias must be 8 characters or less
                if(alias.length() > 8) {
                    alias = alias.substring(0, 8);
                }
                myu.alias = alias;
                myu.languagelocalekey = UserInfo.getLocale();
                myu.localesidkey = UserInfo.getLocale();
                myu.emailEncodingKey = 'UTF-8';
                myu.timeZoneSidKey = 'America/Los_Angeles';    
        
            return myu;
        }
        //configure method for community users (takes a contact)            
        public static void configureuser(Id Portalid, user u, string profilename, auth.userdata data, contact c, permissionsetSetup myset, integer siteID, string myusername)
            {

                permissionsetsetup.Create_or_update_user(u, data, SiteId!=null, siteID, myusername);
                if(SiteId != null)
                {
                    contact temp_c = u.contact;
                    if(u.contactId == null && temp_c.id == null)
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
                            string contactId ='';
                            if(u.contactId != null)
                                { contactId = u.contactId;}
                            if(temp_c.id != null)
                                {contactId = temp_c.id;} 
                                   
                            temp_c = new contact(id = contactId);
                            temp_c.vts_agent_id__c = u.contact.vts_agent_id__c;
                            temp_c.firstname = data.firstname;
                            temp_c.lastname = data.lastname;
                            temp_c.email = data.email;
                            {
                                update(temp_c);
                            }
                            if(u.contactid == null)
                            {
                                u.contactId = temp_c.id;
                            }
                        }
                   } 
                u.profileId = myset.profilemap.get(profilename).id;  
                u.firstname = data.firstname;
                u.lastname = data.lastName;
                u.username = myusername;
                u.email = data.email;                
            }
}