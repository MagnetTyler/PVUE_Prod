public without sharing class Utility {

	public static final map<string, Schema.SObjectType> schemamap = schema.getglobaldescribe();

public static string returnhex(decimal mynum){
	
	//****************************************************************************************************
	//
	// Class to convert a decimal to a HexCode
	// This class is used for Missing Results Case to translate the Id on a particular registration
	// @ Param Mynum which is a decimal
	// 
	// written by Brian Weers 11-2014
	//
	//***************************************************************************************************
	
	string hexcode = '';
	
	map<integer,string>hexmap = new map<integer,string>{
  		0=>'0', 8=>'8',
  		1=>'1', 9=>'9',
  		2=>'2', 10=>'A',
  		3=>'3', 11=>'B',
  		4=>'4', 12=>'C',
  		5=>'5', 13=>'D',
  		6=>'6', 14=>'E',
  		7=>'7', 15=>'F'};

	do{
		string t1 =(hexmap.get(math.mod(mynum.intvalue(),16)));
		string t2 = t1+hexcode;
		hexcode = t2;
			
		mynum = math.floor(mynum.divide(16,3));
		}
	While(mynum != 0);
		system.debug('hexcode='+hexcode);
	return hexcode;
	}

	public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName){
		
	// ****************************************************************************************************
	//
	// Utility to retrun a fieldset for any object 
	// This class is used for visualforce pages to build out the page 
	// based on an item recorded in Custom Settins CaseConfig__c
	// @Param String FieldsetName name of fieldset name
	// @Param string ObjectName name of object on which fieldset is found 
	// 
	// written by Brian Weers 12-2014
	//
	// ***************************************************************************************************
		
		Try{	
    	Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
    	Schema.SObjectType SOTypeToken = GlobalDescribeMap.get(ObjectName);
    	Schema.DescribeSObjectResult SODescribe = SOTypeToken.getDescribe();

	    Schema.FieldSet myfieldset = SODescribe.FieldSets.getMap().get(fieldSetName);	


    	return myfieldset.getFields(); 
		}  
		catch(exception e){return null;}
		}

	public static list<decoResult> CreateCases(case parent, map<Long,DecoResult> info, map<string,integer> positionmap){
	
	// ****************************************************************************************************
	//
	// Utility to aid in the import tool.  DecoResults are a class which contain the following
	// 		
	// 
	// @Param String FieldsetName name of fieldset name
	// @Param string ObjectName name of object on which fieldset is found 
	// 
	// written by Brian Weers 12-2014
	//
	// ***************************************************************************************************
	
	system.debug('BEGIN Utility.CreateCases(parent, info, positionmap)');
	
	list<case> casestocreate = new list<case>();
	list<id>successids = new list<id>();
	string newowner = '';
	
	
	
	//find the correct step__c to put on the newly created cases
	step__c currentstep = new step__c();	
	Step__c parentstep = [SELECT ID, routing__c, who_is_doing_the_work__c, step_number__c FROM Step__c WHERE id = :parent.step__c];
		if( parentstep != null)
			{
				if(parentstep.step_number__c != 2)
					{
						currentstep = [SELECT id, Who_is_doing_the_work__c FROM step__c WHERE Step_number__c = 2 AND routing__c = :parentstep.Routing__c];
					}
				else 
					{currentstep= parentstep;}
					
				
				//get the queue from the step record to identify owner
				try {
	 	 					if(currentstep.Who_is_doing_the_Work__c != 'Closed')
	 	 						{
	 	 							newowner = [Select Id, Name, DeveloperName, Type from Group where Type = 'Queue' AND developername = :currentstep.Who_is_doing_the_work__c].id;
	 	 							
	 	 						}	
	 	 				}
	 	 		catch(exception newownerexception)
	 	 				{
	 	 					system.debug('EXCEPTION Caught Utility.CreateCases  getOwner'+newownerexception);
	 	 				}			
						
			}

	for(DecoResult each:info.values()){
		if(each.selected == true && each.Created!=true){
		if(each.details=='No Case Created'){
			each.details= null;
			}
		case newcase = parent.clone(false, true);
		newcase.ParentId = parent.id;
		newcase.recordtypeid = parent.RecordTypeId;
		if(newowner != '' && newowner!= null)
			{newcase.OwnerId = newowner;}
		newcase.step__c = currentstep.id;	
		newcase.accountId = each.testcenter.id;
		newcase.Status__c = 'Awaiting pickup';
		Newcase.Test_Center_Name__c = each.TestCenter.id;
		system.debug('positionmap=='+positionmap);
		if(positionmap.get('Comments')!=null){
		newcase.description = each.fieldlist[positionmap.get('Comments')];}
		casestocreate.add(newcase);
		}
		if(each.selected == false){
			each.details='No Case Created';
		}
	}
	if(casestocreate.size()>0){
		try{
			list<string> createdlist = new list<string>(); 
			insert(casestocreate);
			for(case c:casestocreate){
				createdlist.add(c.id);
			}
		for(Case each:[select id, casenumber, account.VTS_Test_Center_ID__c from case where id in: createdlist]){
		
		decoresult mytemp = (info.get(each.account.VTS_Test_Center_ID__c.longValue()));
		mytemp.details=each.id;
	
		
		mytemp.created = true;
			}
		}	
		catch(exception e){
			string err = e.getmessage();
			for(decoResult d:info.values()){
				d.details=err;
			}
				}
	system.debug('END Utility.CreateCases(parent, info, positionmap)');
					
	return info.values();	 
		}
	else{return null;}
	}
	
	
	Public static void CaseAggregate(set<id> parentcases){
	
	
	// ****************************************************************************************************
	//
	// Method used by Case_Handler to Aggregate child cases to a parent
	//  
	// 
	// 
	// @Param ParentCases Set of Case Ids which represent the parent cases which need to have their children aggregated 
	// 
	// written by Brian Weers 12-2014
	//
	// ***************************************************************************************************
	
	system.debug('BEGIN CaseAggregate::'+parentcases);
	
	map<id, case> updateparents = new map<id,case>();
		List<aggregateResult> totalcases = [select ParentId, count(id) tot, isclosed from case where ParentId !=null GROUP by isClosed, ParentID];
		
		try{
			for(aggregateResult each:totalcases)
				{ 
					integer mytotal = 0;
					if(!updateparents.containskey(string.valueof(each.get('ParentId')))){
						
					case c = new case(id= string.valueof(each.get('ParentId')));
					if(each.get('IsClosed')==true)
						{
							c.Total_closed_cases__c = integer.valueof(each.get('tot'));
						}
					
					if(c.total_child_cases__c == null){c.total_child_cases__c =0;}
					c.Total_child_cases__c += integer.valueof(each.get('tot'));	
					
					if(c.Total_child_cases__c > c.total_closed_cases__c){
						c.status = 'Pending';
					}
					updateparents.put(c.id,c);
					
				}
				else{
					case c = updateparents.get(string.valueof(each.get('ParentId')));
					if(each.get('IsClosed')==true)
						{
							c.Total_closed_cases__c = integer.valueof(each.get('tot'));
						}
						
		
					c.Total_child_cases__c += integer.valueof(each.get('tot'));
					if(c.Total_child_cases__c > c.total_closed_cases__c){
						c.status = 'Pending';
					}						
						updateparents.put(c.id,c);						
				}
				
			}
		}
		catch (exception aggregate_exception)
			{
				system.debug('Utility.CaseAggregate Exception Thrown: ' + aggregate_exception);
			}
		Try
			{			
				update(updateparents.values());
			}
			
		catch(exception CaseAggregate_UpdateParentsException)
			{
				System.debug('CaseAggregate.UpdateParents Exception Thrown: ' + CaseAggregate_UpdateParentsException);
			}
		System.debug('END Utility.CaseAggregate');
	}	

	public static blob attachready (list<decoResult> decorecords, list<string> headers){
		
		//*******************************************************************************
		// Utility for the Import Tool for turning DecoResults into a BLOB
		// 		that is ready to be attched to a case
		// 
		// 
		// 
		//*******************************************************************************
		
		System.debug('BEGIN Utility.Attachready');
		list<string> myrows = new list<string>();
		
		for(decoResult each: decorecords)
			{
				string thisrow = each.selected+','+each.TestCenter.Name+',';
				thisrow += string.join(each.fieldlist, ',');
				thisrow += (',')+each.details + ',' + each.created;
			 
				myrows.add(thisrow);			
			}
		string headerrow = string.join(headers,',');
		myrows.add(0,headerrow);
		
		string blobready = string.join(myrows,'\n');
		System.debug('END Utility.Attachready');
		
		return( blob.valueof(blobready));
	}

	Public static String Editablefields (string Objectname)
		{
			//*****************************************************************************************************************************************
			//
			// reusable class to return all visible fields for a user from the specified object for display on a visaulforce page
			// item is written dynamically so the page can be edited without making changes to the controller
			// @param Objectname is the API name of the object you are requesting available fields for
			// written by Brian Weers Magnet360  December 2014
			// Originally used by DetailsPage controller which is the controller for the visualforce page of the same name(detailspage)
			//
			//*****************************************************************************************************************************************
			
			System.debug('BEGIN Utility.EditableFields:' + ObjectName);
			
				list<string> fieldnames = new list<string>();
				Schema.Sobjecttype mysObjectType = schemamap.get(Objectname);
				Schema.DescribeSobjectResult mysObjectDescribe = mysObjectType.getdescribe();
				map<string, Schema.sObjectField> dfr = mysObjectDescribe.fields.getmap();
				for( Schema.sObjectField eachdfr : dfr.values())
					{
						if(eachdfr.getdescribe().isAccessible())
							{
								fieldnames.add(eachdfr.getdescribe().getName());
							}
					}
				string queryset = string.join(fieldnames,',');
				System.debug('END Utility.EditableFields:' + ObjectName);
				
				return queryset;	
					
		}
	
	public static list<string> getpickvals (string fieldname, string objectname){
		
		list<string> picklistvals = new list<string>();
		
		try			
			{
				Schema.sObjecttype mysObjectType = Schemamap.get(objectname);
				map<string,schema.SObjectField> fieldsmap = mysObjectType.getdescribe().fields.getmap();
				Schema.sObjectfield myfieldtoken = fieldsmap.get(fieldname);
				Schema.Describefieldresult myfielddescribe = myfieldtoken.getdescribe();
				
				for( schema.Picklistentry eachentry:myfielddescribe.getPicklistValues())
					{picklistvals.add(eachentry.getvalue());}
				
				return picklistvals;
			}
		Catch (exception getpickvalsexception)
			{
				system.debug ('Utility.Getpickvals EXCEPTION CAUGHT:' + getpickvalsexception);
				string errmessage = 'Error Occured, not Picklist or field does not exist:'+
									'  Please contact your Salesforce Administrator';
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errmessage);
				ApexPages.addMessage(myMsg);		
				return null;
			}
	}	


Public static String Relationshipfields (string Objectname, string relatedobjectname)
		{
			//*****************************************************************************************************************************************
			//
			// reusable class to return a string of fields which represent the related object field names
			// 
			// @param Objectname is the API name of the object you are requesting available fields for
			// @param relatedobjectname is the string which is the relationshipprefix for the field
			//		i.e.  for a dynamic soql which is getting contact name and contact phone from case, the relatedobjectname would be 'contact'
			//				so the dynamic soql needs to render as SELECT contact.name, contact.phone
			// written by Brian Weers Magnet360  December 2014
			// Originally used by DetailsPage controller which is the controller for the visualforce page of the same name(detailspage)
			//
			//*****************************************************************************************************************************************
			
			System.debug('BEGIN Utility.EditableFields:' + ObjectName);
			
				list<string> fieldnames = new list<string>();
				Schema.Sobjecttype mysObjectType = schemamap.get(Objectname);
				Schema.DescribeSobjectResult mysObjectDescribe = mysObjectType.getdescribe();
				map<string, Schema.sObjectField> dfr = mysObjectDescribe.fields.getmap();
				for( Schema.sObjectField eachdfr : dfr.values())
					{
						if(eachdfr.getdescribe().isAccessible())
							{
								fieldnames.add(Objectname + '.' + eachdfr.getdescribe().getName());
							}
					}
				string queryset = string.join(fieldnames,',');
				System.debug('END Utility.EditableFields:' + ObjectName + 'and '+ relatedobjectname);
				
				return queryset;	
					
		}

public static void CommitRegistration(case mycase, VTS_Registration RegInput){
		
		 VTSPersistenceUtility p = new VTSPersistenceUtility();
                        
                        
        //insert records returned by API call to Reg endpoint.  keep ids for assignment to the case 
            Account mytestcenter = p.upsertTestCenter(RegInput.testCenter, true);
            
            Candidate__c RegCandidate = p.upsertCandidate(RegInput.Candidate, true);
            Exam__c relatedexam = p.upsertExam(RegInput.exam, RegInput.candidate.clientId,true);
            Registration__c relatedReg = p.upsertRegistration(RegInput, true);
            decimal myclientid = RegInput.candidate.clientId;
            string clientsearch = 'SELECT name, vts_client_id__c FROM Account where VTS_Client_id__c = :myclientid';
            string myid = relatedreg.id;
            string regsearch = 'SELECT ' + utility.Editablefields('Registration__c') + ' FROM Registration__c where id =: myid';
            Registration__c tempreg = database.query(regsearch);
            
            account myclient = database.query(clientsearch);
            mycase.Test_Center_Name__r = mytestcenter;
            mycase.test_center_Name__c = mytestcenter.id;
            mycase.Client_id__c = myclient.id;
            mycase.Client_id__r = myclient;
            mycase.Registration_id__r = tempreg;
            mycase.Registration_id__c = tempreg.id;
            system.debug(relatedReg);
            mycase.Exam_id__r = relatedexam;
            mycase.exam_id__c = relatedexam.id;
            mycase.Candidate_id__r = RegCandidate;
            mycase.candidate_id__c = regCandidate.id;
            

            //new section to write static fields
            mycase.Candidate_Address_Line_1__c = RegCandidate.Address_Line_1__c;
            mycase.Candidate_Address_Line_2__c = RegCandidate.Address_Line_2__c;
            mycase.Candidate_Address_Line_3__c = RegCandidate.Address_Line_3__c;
            mycase.Candidate_City__c = RegCandidate.City__c;
            mycase.Candidate_Country__c = RegCandidate.Country__c;
            mycase.Candidate_Country_Name__c = RegCandidate.Country_Name__c;
            mycase.Candidate_Email__c = RegCandidate.Email__c;
            mycase.Candidate_First_Name__c = RegCandidate.First_Name__c;
            mycase.Candidate_Last_Name__c = RegCandidate.Last_Name__c;
            mycase.Candidate_Middle_Name__c = RegCandidate.Middle_Name__c;
            mycase.Candidate_Phone_Country_Code__c = RegCandidate.Phone_Country_Code__c;
            mycase.Candidate_Phone_Extension__c = RegCandidate.Phone_Extension__c;
            mycase.Candidate_Phone_Number__c = RegCandidate.Phone_Number__c;
            mycase.Candidate_Postal_Code__c = RegCandidate.Postal_Code__c;
            mycase.Candidate_State__c = RegCandidate.State__c;
            mycase.Candidate_State_Name__c = RegCandidate.State_Name__c;
            mycase.Candidate_Student_ID__c = RegCandidate.Student_ID__c;
            mycase.candidate_CCID__c = RegCandidate.CCID__c;
            mycase.Exam_Authorization_ID__c = relatedexam.Authorization_ID__c;
            mycase.Exam_Category__c = relatedexam.Category__c;
            mycase.Exam_Delivery_Mode__c = relatedexam.Delivery_Mode__c;
            mycase.Exam_Name__c = relatedexam.Exam_Name__c;
            mycase.Exam_Series_Code__c = relatedexam.Exam_Series_Code__c;
            mycase.Registration_Date_and_Time_of_Exam__c = relatedReg.Date_and_Time_of_Exam__c;
            mycase.Registration_Disposition__c = relatedReg.Disposition__c;
            mycase.Registration_Process_State_Code__c = relatedReg.Process_State_Code__c;
            mycase.Registration_Test_Driver_Version__c = relatedReg.Test_Driver_Version__c;
            mycase.Site_name_static__c = mytestcenter.Name;
            mycase.site_type_static__c = mytestcenter.Channel_type__c;
			
			system.debug('attachcandidate' + mycase.Registration_id__c);
			
				
            
            
	}

public static void CommitCandidate(case mycase, VTS_Candidate mycandidate){

			VTSPersistenceUtility p = new VTSPersistenceUtility();
                                            Candidate__c newcandidate = p.upsertCandidate(mycandidate,true);
                                            if(newcandidate.id != null){
                                                mycase.candidate_id__c = newcandidate.id;
                                                mycase.Candidate_id__r = newcandidate;                                            

			mycase.Candidate_Address_Line_1__c = newcandidate.Address_Line_1__c;
            mycase.Candidate_Address_Line_2__c = newcandidate.Address_Line_2__c;
            mycase.Candidate_Address_Line_3__c = newcandidate.Address_Line_3__c;
            mycase.Candidate_City__c = newcandidate.City__c;
            mycase.Candidate_CCID__C = newcandidate.CCID__c;
            mycase.Candidate_Country__c = newcandidate.Country__c;
            mycase.Candidate_Country_Name__c = newcandidate.Country_Name__c;
            mycase.Candidate_Email__c = newcandidate.Email__c;
            mycase.Candidate_First_Name__c = newcandidate.First_Name__c;
            mycase.Candidate_Last_Name__c = newcandidate.Last_Name__c;
            mycase.Candidate_Middle_Name__c = newcandidate.Middle_Name__c;
            mycase.Candidate_Phone_Country_Code__c = newcandidate.Phone_Country_Code__c;
            mycase.Candidate_Phone_Extension__c = newcandidate.Phone_Extension__c;
            mycase.Candidate_Phone_Number__c = newcandidate.Phone_Number__c;
            mycase.Candidate_Postal_Code__c = newcandidate.Postal_Code__c;
            mycase.Candidate_State__c = newcandidate.State__c;
            mycase.Candidate_State_Name__c = newcandidate.State_Name__c;
            mycase.Candidate_Student_ID__c = newcandidate.Student_ID__c;

        	}
}



public static case Case_step_utility (case mycase, step__c mycurrentstep)
	{
                step__c nextstep = new step__c();
                routing_logic__c selectedlogic = new routing_logic__c();
                
		//consolidate the editconfig and mycaseconfig to a single token for the routing__c records
                


                step__c currentstep = mycurrentstep;
                string stepid = currentstep.id;
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
                                                    	AND Routing__c = :currentstep.routing__c]; 
                                        mycase.step__c = nextstep.id;	
                                  	}	  	
                                    
                                    
                                    
                                  else           
                                      {
                                        nextstep = [select id, Who_is_doing_the_work__c 
                                                    from Step__c 
                                                    where Step_number__c = :currentstep.Go_to_Step__c 
                                                    	AND Routing__c = :currentstep.routing__c]; 
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
                                    	AND Routing__c = :currentstep.routing__c]; 
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
                return mycase;
	}

	public static step__c getnextstep(case mycase, step__c mycurrentstep){
		
               step__c currentstep = mycurrentstep;
			   step__c nextstep = new step__c();
			   routing_logic__c selectedlogic = new routing_logic__c();
				
                string stepid = currentstep.id;
				system.debug('currentstep =' + stepid);
                if(currentstep.Has_forked_logic__c)
                            {              	//Try{
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
                                  		nextstep = [select id,Who_is_doing_the_work__c, Next_team_display__c 
                                                    from Step__c 
                                                    where Step_number__c = :selectedlogic.go_to_step__c 
                                                    	AND Routing__c = :currentstep.routing__c]; 
                                   //     mycase.step__c = nextstep.id;	
                                  		if(nextstep != null)
                                  			{
                                  				if(nextstep.id == currentstep.id)
                                  					{
                                  						mycase.notification_Message__c = selectedlogic.Error_message__c;
                                  					}
                                  			}
                                  			else
                                  				{
                                  					system.debug('Nextstep was null');
                                  				}		
                                  			
                                  	}	  	
                                    
                                    
                                    
                                  else           
                                      {
                                        nextstep = [select id, Who_is_doing_the_work__c, Next_team_display__c 
                                                    from Step__c 
                                                    where Step_number__c = :currentstep.Go_to_Step__c 
                                                    	AND Routing__c = :currentstep.routing__c]; 
                                       // mycase.step__c = nextstep.id;
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
                        nextstep = [select id, Who_is_doing_the_work__c, Next_team_display__c 
                                    from Step__c 
                                    where Step_number__c = :currentstep.Go_to_Step__c 
                                    	AND Routing__c = :currentstep.routing__c]; 
                      //  mycase.step__c = nextstep.id;
                  	  }

           return nextstep;       	  
	}

	public static string getQueryFromFieldset(list<schema.fieldsetMember> fieldsetmembers, string sObjectname, list<string> additionalfields)
		{
			String searchquery = 'SELECT ';
			integer i = 0;
			for (FieldsetMember each:fieldsetmembers)
				{
					searchquery += each.getfieldpath() + ', ';
					
				}
			if(additionalfields != null)
				{
					for (string addfield:additionalfields)
						{
							if(!searchquery.containsignorecase(addfield+','))
								{	
									searchquery += addfield + ', ';
								}
						}
				}	
			searchquery += 'ID FROM ' + sObjectName;
			return searchquery;	
		}

	public static list<Schema.fieldsetMember> getFieldsetmembers (string fieldsetname, string sObjectName)
		{
			Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
			Schema.sObjectType mytype = gd.get(sObjectName);
			schema.Describesobjectresult mysObjectDescribe = mytype.getDescribe();
			Map<String, Schema.FieldSet> FsMap = mysObjectDescribe.fieldSets.getMap();
			Schema.fieldset FS = FsMap.get(fieldsetname);
			return FS.getfields();
		}

	public static Routing__c getRoutingandFirstStep (string finalCategoryname)
		{
			system.debug('START GetRoutingAndFirstStep::' + finalcategoryname);	
			//string myfinalcat = 'Missing Results Escalation';
			string myfinalcat = finalCategoryname;
			string RoutingQuery = 'SELECT ' + utility.editableFields('Routing__c') + ', (SELECT ' + utility.editablefields('Step__c') +
					' FROM Steps__r) FROM Routing__c WHERE Final_Category_Name__c = :myfinalcat';
			
			system.debug('here is the query::' + routingQuery);
			
			Routing__c myrouting = database.query(RoutingQuery);

			system.debug('END GetRoutingAndFirstStep::' + myrouting);
			return myrouting;
		}
	public static void setowner(Step__c nextstep, case mycase, boolean manualroute){
		if(nextstep!=null)
				{   
                	mycase.step__c = nextstep.id;
                    try {
                            if(nextstep.Who_is_doing_the_Work__c != 'Closed' && nextstep.Who_is_doing_the_Work__c != 'Same owner' &&
                            	nextstep.Who_is_doing_the_Work__c != 'Any internal user' && manualroute != true)
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
                            else if(manualroute == true)
                            	{
                            		mycase.status__c = 'Awaiting pickup';
									mycase.status = 'Awaiting pickup'; 
									if(mycase.CaseMgt_delayed_routing__c == true)
										{
											mycase.ownerid = mycase.CaseMgt_delayed_routing_id__c;
										}
									 
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
	}	
}