trigger CaseCommentTrigger on CaseComment (before delete, after insert, after update, after undelete) {

	list<id> casecommentids = new list<id>();
	
	if(trigger.isbefore)
		{
			if(trigger.isdelete && executioncontrol.beforedeletehasrun == false)
				{
					for(casecomment each:trigger.old)
						{casecommentids.add(each.id);}
						caseCommenthelper.updatecase(casecommentids, true,false);	
						executioncontrol.beforedeletehasrun = true;
				}	
		}
	
	if(trigger.isafter )
		{
			if(trigger.isinsert && executioncontrol.afternInserthasrun == false)
				{
					for(casecomment each:trigger.new)
						{casecommentids.add(each.id);}
						executioncontrol.afternInserthasrun = true;	
						caseCommenthelper.updatecase(casecommentids, false,false);	
									
				}
			if(trigger.isupdate && executioncontrol.afterupdatehasrun == false)
				{
					for(casecomment each:trigger.new)
						{casecommentids.add(each.id);}
						executioncontrol.afterupdatehasrun = true;
						caseCommenthelper.updatecase(casecommentids, false, true);	
										
				}
		}


}