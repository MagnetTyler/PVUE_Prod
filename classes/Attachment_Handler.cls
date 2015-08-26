public with sharing class Attachment_Handler {
	
	// this trigger updates the case when an attachment is added to a case.
	
	public static boolean Attach_after_insert_hasrun = false;
	
	public static void CaseAttachmentAfterInsert(list<attachment> newattaches){
		system.debug('Begin Attach_after_insert_handler');
		
		list<case> relatedcases = new list<case>();
		Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.assignmentRuleHeader.useDefaultRule= true;
		set<string>caseids = new set<string>();
			
		for(attachment each:newattaches){
			caseids.add(each.parentid);
		
		}
		
		//adjust the trigger 3/6 to allow the case to be evaluated to move it forward when it updates the has attachment field.
		integer totalsoql = Limits.getLimitQueries();
	
		database.setSavepoint();
		
		for(case c: [select casenumber, id, step__c, step__r.name, step__r.routing__c, step__r.has_forked_logic__c, step__r.go_to_step__c, has_attachment__c from case where id in :caseids])
			{			
				step__c mystep = new step__c(id = c.step__c, name = c.step__r.name, has_forked_logic__c = c.step__r.has_forked_logic__c, go_to_step__c = c.step__r.go_to_step__c,
										  routing__c = c.step__r.routing__c);

									c.has_attachment__c = true;
									c.Does_the_Attachment_Pass__c = null;
									if(userinfo.getusertype()=='Standard')
									{
										c.New_Internal_Comment__c = false;
										c.New_Internal_Email__c = false;
									}
									else if (userinfo.getusertype() != 'Standard')
										{
											c.new_external_comment__c = false;
											relatedcases.add(c);
										}
							
			//check to see if soql queries are available
			//check to make sure the step is an add attachment phase
                			if ( mystep != null ) {
								string namevalue = string.valueof(mystep.name);
                                system.debug(' namevalue :: ' + namevalue);
								if(limits.getqueries()+5 < totalsoql && namevalue != null)
									{
										if(namevalue.containsIgnoreCase('- Add Attachment'))
										{									
	                                        c= utility.Case_step_utility(c, mystep);														
	                                        c.SetOptions(dmo);	
	                                        relatedcases.add(c);
	                                    }
									}
                //TODO throw error to prevent soql problems			
                                else						
                                    {
                                        
                                    }
                            }
						
		try{
			
			update(relatedcases);
		}
		Catch(Exception e){
			
		}
	}
	system.debug('Begin Attach_after_insert_handler');

	}
}