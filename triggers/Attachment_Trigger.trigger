trigger Attachment_Trigger on Attachment (after insert) {

	if(trigger.isbefore){
	
		if(trigger.isinsert){
			
			
		}
	}


	if(trigger.isafter ){
		if(trigger.isinsert && attachment_handler.Attach_after_insert_hasrun==false){
			attachment_handler.Attach_after_insert_hasrun= true;
			//map out relationship info for trigger to determine SObject that attachment is attached to
			list<attachment> caseattachments = new list<attachment>();
			for(attachment each:trigger.new){
				if(string.valueof(each.parentid).startsWith('500')){
					caseattachments.add(each);
				}

			}
			
				if(caseattachments.size()>0){
					attachment_handler.CaseAttachmentAfterInsert(caseattachments);
				}	
			
		}
		
	}



}