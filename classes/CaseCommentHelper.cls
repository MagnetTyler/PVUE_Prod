public with sharing class CaseCommentHelper {

	public static void updatecase(list<id> commentids, boolean deletecontext, boolean updatecontext)
		//
		//   variables:
		//			parentaseid = the list of ids of the cases to set or clear flags on
		//			deletecontext = boolean variable set by the trigger if it is delete
		//			for delete the flags are set to false
		//
		//	 This trigger is expected to always be a singleton but it written bulk safe.  purpose of this class
		//	 is to set and clear the New_internal_comment__c and the new_external_comment__c flags in order to update
		//	 icons in the listview to inform the user if a new comment has been added or deleted
		//
		
		{
			
			string usertype = userinfo.getusertype();
			list<case> updatecases = new list <case>();
			
			system.debug('context' + deletecontext +'ids::' + commentids);			
			
			for(casecomment each:[select createdbyid, id, ispublished, parentid, parent.new_internal_email__c, parent.new_internal_comment__c, parent.new_external_comment__c, parent.ownerid from casecomment where id in :commentids])
				
				{
					case mycase = new case(id = each.parentid);
					if(usertype == 'standard')
						{
							mycase.new_external_comment__c = (deletecontext == false && (each.parent.new_external_comment__c == true || each.ispublished == true));
 							mycase.new_internal_comment__c = (deletecontext == false && (each.parent.new_internal_comment__c == true || each.parent.ownerid != each.createdbyId));
 							if(updatecontext = true)
 								{
 									mycase.new_external_comment__c = each.ispublished;
 								}
							
							system.debug('the case::' + mycase);

						}
					else
						{	
							mycase.new_external_comment__c = false;
							mycase.new_internal_comment__c = deletecontext == false;
							system.debug('the case::' + mycase);
						}
					updatecases.add(mycase);		
				}
			update updatecases;
			
		}


}