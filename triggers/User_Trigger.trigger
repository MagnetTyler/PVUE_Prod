trigger User_Trigger on User (before insert, after insert, after update, before update) {

    if(trigger.isbefore){
        
        if(trigger.isupdate){
        	
        	for(user u:trigger.new)
                {	
                	string permissionstring ;
                	for(permissionsetassignment each:[select assigneeid, PermissionSetId, PermissionSet.LABEL from permissionsetassignment where assigneeid = :u.id])
                		{
                			if(permissionstring != NULL)
                				{	if(permissionstring !='')
                					{permissionstring += ',';}
                				 	permissionstring += each.permissionset.label;
                				}
                			else
                				{	
                					
                						permissionstring = '';
                					
                					//permissionstring = each.permissionset.label;
                				}
                		}
                		permissionstring.replace(userinfo.getprofileId() + ',', '');
                	u.Primary_team_persona__c = permissionstring;
        	
            if([select name, id from profile where id = :userinfo.getProfileId()].name != 'System Administrator')
            {
                	
                		
                    u.adderror('Only System Administrators May Edit Profile Data');
                }
            
            }
        }
    }




    if(trigger.isafter){
        
        
    }
}