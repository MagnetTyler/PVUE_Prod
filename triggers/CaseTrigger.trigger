trigger CaseTrigger on Case (after insert, after update, before insert, 
before update) {
	

	if( trigger.isbefore){

		if(trigger.isInsert && executioncontrol.beforeInsertHasrun == false){
			
			executionControl.beforeInsertHasrun = true;
			Case_Handler.BeforeInsert(trigger.new,Trigger.oldmap, trigger.newmap);
					
		}




		if(trigger.isUpdate && executioncontrol.beforeupdatehasrun == false){

		 	executioncontrol.beforeupdatehasrun = true;
		 	Case_Handler.BeforeUpdate(trigger.new, Trigger.oldmap, trigger.newmap);
			
			
			
		}
		
	}


	if(trigger.isafter){
		if(trigger.isupdate && executioncontrol.afterupdatehasrun == false)
			{	
				executioncontrol.afterupdatehasrun = true;
				case_handler.afterupdate(trigger.new, Trigger.oldmap, trigger.newmap);
				
				
			}
		if(trigger.isupdate && executioncontrol.afterupdatehasrun == true)
			{	
				set<id> finalupdates = new set<id>();
				for(case eachcase:trigger.new)
					if(eachcase.status== 'Closed' && trigger.oldmap.get(eachcase.id).status!='Closed')
							{finalupdates.add(eachcase.parentid);
							}
							if(finalupdates.size()>0)
								{utility.CaseAggregate(finalupdates);}
				
				
			}	
			

		if(trigger.isInsert && executioncontrol.afternInserthasrun == false){
			
			executioncontrol.afternInserthasrun = true;
			case_handler.afterinsert(trigger.new, trigger.newmap);
			
		}

				

						
	}

executionControl.beforeInsertHasrun = false;
executioncontrol.beforeupdatehasrun = false;
executioncontrol.afterupdatehasrun = false;
executioncontrol.afternInserthasrun = false;

}