public with sharing class RoutingService {

    public Routing__c getCaseRoutingByFinalCategory(String finalCategory) {
        return getCaseRoutingByFinalCategory(null, null, finalCategory);
    }

    public Routing__c getCaseRoutingByFinalCategory(ID routingId, ID currentStepId, String finalCategory) {

        String query = 'SELECT ' + utility.Editablefields('Routing__c');
        query += ', (Select ' + utility.Editablefields('Step__c') + ' FROM steps__r ';

        if ( currentStepId != null ) {
            query += 'where Id = :currentStepId )';
        } else {
        	query += 'Order By Step_number__c ASC LIMIT 1 )';
        }

        if ( routingId != null ) {
        	query += 'FROM Routing__c WHERE Id = :routingId';
        } else {
        	query += 'FROM Routing__c WHERE Final_Category_Name__c = :finalCategory';
        }
        System.debug('query: ' + query);
        List<Routing__c> routing = Database.query(query);
        return !routing.isEmpty() ? routing[0] : null;
    }

    // NOT bulk-safe
    public Case routeCase(Case mycase) {
        return routeCase(mycase, getCaseRoutingByFinalCategory(mycase.Routing__c, mycase.Step__c, mycase.Final_Category__c));
    }

    // NOT bulk-safe
    public Case routeCase(Case mycase, String finalCategory) {
        return routeCase(mycase, getCaseRoutingByFinalCategory(finalCategory));
    }

    // NOT bulk-safe
    public Case routeCase(Case mycase, Routing__c mycaseconfig) {

        System.debug('mycaseconfig: ' + mycaseconfig);
        System.debug('mycaseconfig.steps: ' + mycaseconfig.Steps__r);
        Savepoint presave =  Database.setSavepoint();
      	Case preRoutingCase =  mycase.clone(true, true, true, true);

//------------------------------------------------------------------------------------------------------
//  BEGIN Assign next step to CASE logic
//  This section uses the instantiated Routing__c and step__c record to see what the next step should be and if there is a decision point
//      in the logic (Has_forked_logic__c) it evaluates the field on mycase to see if it matches the value for the fork logic to determine
//      what the next step for this record is
// 
//  @param mycaseconfig(Routing__c and step__c for cases being created)
//  @param editconfig(routing__c and Step__c for existing cases)
//  implement assignment of the next step to the case
//
//  EDIT CONFIG ROUTING LOGIC   
//
//-------------------------------------------------------------------------------------------------------
        mycase.Routing__c = mycaseconfig.Id;
        //if(mycase.status__c == 'Being Created' || mycase.status__c == 'Move to next step')
        //    {
            	step__c currentstep = new step__c();
                step__c nextstep = new step__c();
                routing_logic__c selectedlogic = new routing_logic__c();
                
		//consolidate the editconfig and mycaseconfig to a single token for the routing__c records
                currentstep = mycaseconfig.steps__r[0];
                string stepid = mycaseconfig.steps__r[0].id;
                string configid = mycaseconfig.id;
				system.debug('currentstep =' + stepid);
                if(currentstep.Has_forked_logic__c)
                            {
                            	//Try{
                                    	//new forklogic section
                                    	 	
                                    	 		
                                    	 string routinglogicquery = 'SELECT ' + utility.Editablefields('Routing_logic__c') +
                                    	 							', (SELECT ' + utility.Editablefields('Routing_field__c') + ' FROM Routing_Fields__r)' +
                                    	 							' FROM Routing_logic__c WHERE Step__c = :stepid and recordtype.name = \'Dynamic Routing Logic\' '; 
                                    	 
                                    	 //set up booleans for evaluation in the do while loop
                                    	 
                                    	 
                                    	list<routing_logic__c> myroutes = database.query(routinglogicquery);
                                        
                                         for(routing_logic__c possibleroute :myroutes)
                                         {
                                            boolean checkvalue = false;
                                            boolean orboolean = false;
                                         	boolean andboolean = true;
                                            
                                            integer i=0;
                                         while((andboolean == true && i< possibleroute.routing_fields__r.size()) || (orboolean == false  && i< possibleroute.routing_fields__r.size()))
                                            {   
                                                System.debug('operator__c : ' + possibleroute.routing_fields__r[i].operator__c );
                                                if(possibleroute.routing_fields__r[i].operator__c == 'Equals')
                                                    {
                                                        checkvalue = string.valueof(mycase.get(possibleroute.routing_fields__r[i].name)) == 
                                                            possibleroute.routing_fields__r[i].value__c;    
                                                    }
                                                else if(possibleroute.routing_fields__r[i].operator__c == 'Not equals')
                                                    {
                                                        checkvalue = string.valueof(mycase.get(possibleroute.routing_fields__r[i].name)) != 
                                                            possibleroute.routing_fields__r[i].value__c;
                                                    }   
                                                else if(possibleroute.routing_fields__r[i].operator__c == 'Greater than')
                                                    {
                                                        long value1 =datetime.valueof(mycase.get(possibleroute.routing_fields__r[i].name)).gettime();
                                                        long value2 = datetime.valueof(mycase.get(possibleroute.routing_fields__r[i].subtractionfield__c)).gettime();
                                                        decimal calcvalue = (value1 - value2)/60000;
                                                        checkvalue =  calcvalue> 
                                                            
                                                            decimal.valueof(possibleroute.routing_fields__r[i].value__c);
                                                            system.debug('calcvalue' + calcvalue);
                                                            
                                                    }
                                                else if(possibleroute.routing_fields__r[i].operator__c == 'Less than')
                                                    {
                                                        long value1 =datetime.valueof(mycase.get(possibleroute.routing_fields__r[i].name)).gettime();
                                                        long value2 = datetime.valueof(mycase.get(possibleroute.routing_fields__r[i].subtractionfield__c)).gettime();
                                                        decimal calcvalue = (value1 - value2)/60000;
                                                        checkvalue =  calcvalue< 
                                                            
                                                            decimal.valueof(possibleroute.routing_fields__r[i].value__c);
                                                            system.debug('calcvalue' + calcvalue);
                                                    }   
                                                    if(possibleroute.routing_fields__r[i].logic_type__c == 'AND')
                                                        {
                                                        	if(andboolean == true)
                                                        		{
                                                            		andboolean = (checkvalue);
                                                        		}	
                                                        }
                                                    else{   orboolean = checkvalue;}
                                                   
                                                    
                                                    system.debug('field='+ possibleroute.routing_fields__r[i].name +' value=' + possibleroute.routing_fields__r[i].value__c + ' or boolean' + orboolean + ' andboolean ' + andboolean);
                                           			 i++;
                                            }
                                    			
                                    			if(andboolean == true || orboolean == true)
                                    				{
                                    					selectedlogic = possibleroute;
                                    					system.debug('selectedlogic'+selectedlogic);
                                    					break;
                                    				}
                                    			else{selectedlogic = null;}	
                                    }
                                    	
                                  if(selectedlogic != null)
                                  	{
                                  		system.debug('selectedlogic'+selectedlogic);
                                  		nextstep = [select id,Who_is_doing_the_work__c 
                                                    from Step__c 
                                                    where Step_number__c = :selectedlogic.go_to_step__c 
                                                    	AND Routing__c = :configid]; 
                                        mycase.step__c = nextstep.id;	
                                  	}	  	
                                    
                                    
                                    
                                  else           
                                      {
                                        nextstep = [select id, Who_is_doing_the_work__c 
                                                    from Step__c 
                                                    where Step_number__c = :currentstep.Go_to_Step__c 
                                                    	AND Routing__c = :configid]; 
                                        mycase.step__c = nextstep.id;
                                  	  }
                                    
               //         }       
                 //       catch(Exception mycaseconfigRoutingException)
                   //         {
                     //           //TODO   make nice sounding exception message
                     //           system.debug('EXCEPTION CAUGHT Editconfig Routing Logic'+ mycaseconfigRoutingException);
                     //           string errmessage = 'An error occured selecting the next step for your case.'+
                     //                       'Please check fields and contact your Salesforce Administrator';
                     //           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errmessage);
                     //           ApexPages.addMessage(myMsg);        
                     //       }           
                            
                            
                            }  
                            
                   else           
                      {
                          nextstep = [select id, Who_is_doing_the_work__c 
                                    	from Step__c 
                                    	where Step_number__c = :currentstep.Go_to_Step__c 
                                    		AND Routing__c = :configid]; 
                          mycase.step__c = nextstep.id;
                  	  }         
                            
                            
                                                                           
            if(nextstep!=null)
                {   
                    try {
                            if(nextstep.Who_is_doing_the_Work__c != 'Closed' && nextstep.Who_is_doing_the_Work__c != 'Same owner' &&
                            	nextstep.Who_is_doing_the_Work__c != 'Any internal user')
                                {
                                    string newowner = [Select Id, Name, DeveloperName, Type from Group where Type = 'Queue' AND developername = :nextstep.Who_is_doing_the_work__c].id;
                                    mycase.ownerid = newowner;
                                    mycase.status__c = 'Awaiting pickup';
                            		mycase.status = 'Awaiting pickup';
                                }
                            else if (nextstep.Who_is_doing_the_Work__c == 'Same owner')
                            	{
                            		mycase.status__c = 'Working';
                            		mycase.status = 'Working';
                            	}
                            else if (nextstep.Who_is_doing_the_Work__c == 'Closed')
                            	{
                            		mycase.status__c = 'Closed';
                            		mycase.status = 'Closed';
                            	}
                            else if (nextstep.Who_is_doing_the_Work__c == 'Any internal user' && mycase.follow_up_with__c != null && mycase.follow_up_with__c != '')
                            	{
                            		string newowner = [Select Id, Name, DeveloperName, Type from Group where Type = 'Queue' AND developername = :mycase.follow_up_with__c].id;
									mycase.OwnerId = newowner;
									mycase.status__c = 'Awaiting pickup';
									mycase.status = 'Awaiting pickup';                            		
                            	}	
                        }
                    catch(exception newownerexception)
                        {
                            system.debug('EXCEPTION Caught AssignNew Owner'+newownerexception); 
                            string errmessage = 'Error Processing:'+ newownerexception.getmessage() +
                                            '  Please try again, if you continue to receive this message, Please contact your Salesforce Administrator';
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errmessage);
                                ApexPages.addMessage(myMsg); 
                            
                        }    
                }
            
            //}

//END Step Assignment and routing setup
// --------------------------------------------------------------------------------------------------       
        return mycase;
    }

}