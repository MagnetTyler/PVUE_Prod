global without sharing class CreatePoc { 
	/*
	***********************************************************************************************************
	//		Written by Brian Weers  Magnet360  
	//		Controller for over-ridden case pages.  Over-ridden are:
	//				Create
	//				Edit
	//				View
	//		It is utilized by 2 Visualforce pages
	//				-CreateCasePOC which is the visualforce page for the Service Cloud Console (internal users)
	//				-CreateCaseComm which is the visualforce page for the Service Cloud Console.
	//					-Action section of the page checks for  user type and routes from CreateCasePOC to CreateCaseComm
	//					-Both pages have versions for both view and edit and a test in the controller to determine the correct state
	//
	***********************************************************************************************************
	*/
	//variable for attachments
	public blob myfile {get;set;}
	public integer numberofemails = 0;
	public boolean emailadded{get;set;}
	public boolean interruptsave = false;
	public boolean haswarningmessage {get;set;}
	public string warningmessage{get;set;}
	public boolean ownerchange{get;set;}
	public string messagetype {get; private set;}
	public boolean ownereturn{get;set;}
	public boolean disablecasetype{get;set;}
	public boolean hasnotificationmessage{get;set;}
	public string notificationmessage{get;set;}
	public transient boolean commentsaved{get;set;}
    public string ownername{get;set;}
	public string actiontype {get;set;}
    public string sitelocation{get;set;}
   // public Map<String, List<Schema.FieldSetMember>> SectionToDynamicFieldsMap{get;set;}
    public boolean displayComment { get; set; }
    public CaseComment caseComment { get; set; }
	public list <string> myagents{
		get
			{if(myagents == null && userinfo.getusertype() != 'Standard')
				{	myagents = new list<string>();
					string myaccountid = [select contact.accountId from user where id = :userinfo.getUserId()].contact.accountId;
					for(user each:[select name, username, contact.accountId from user where contact.accountId = :myaccountid ])
						{
							myagents.add( each.name);
						}
				}
			return myagents;
			}
		set;	
	}

    public List<CaseComment> CaseComments{
        get{
            return [Select LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name, IsPublished, 
                            CreatedDate, CreatedBy.Id, CreatedBy.Name, CommentBody
                            From CaseComment c 
                            where ParentId = :mycase.id 
                            order by c.LastModifiedDate desc, c.CreatedDate desc limit 1];
        }
        set;
    }


    public string mytestcenterid {
    	get{
            if(userinfo.getusertype() != 'standard' && mytestcenterid == null)
    				{
    					this.mytestcenterid = [select contact.accountid from user where id = :userinfo.getUserId()].contact.accountid;
    				}
    	return this.mytestcenterid;
    	}
    	set;
    }
    public boolean Feedback {get
    	{
    		boolean feedback = system.currentPageReference().getParameters().get('feedback') != null;
    		return feedback;
    	}
    	set;
    }	
    public string comment
    	{
    		get
				{
					string comment = system.currentPageReference().getParameters().get('feedback');
					if(comment == 'savesuccess')
						{
							comment = System.label.Case_Saved;
						}
					if(comment == 'submitsuccess')
						{
							comment = System.label.Case_Submitted;
						}	
					return comment;
				}
    		set;
		}
  //  public string candidatename{get;set;}
    

    
    public step__c nextstep {get
    			{ if(mycase!=null && mycaseconfig!=null){
    				if(!mycase.isclosed && mycase.step__r.next_team__c != null)
    			{	//mycase.previous_step__c = mycase.step__c;
    				step__c nextstep = utility.getnextstep(mycase,mycaseconfig.steps__r[0] );
    			 	
			return nextstep;}
			else return null;
						}
			else{return null;}} set;}
	public integer numberofattachements {get;set;}
	
	public integer getnumberofattachements(){
		numberofattachements = attachments.size();
		return numberofattachements;			
	}		
	
	public void setnumberofattachments(integer numberofattachements)
		{
			this.numberofattachements = numberofattachements;
		}
	
	public string sitename{get;set;}
    public String myTopic {get;set;}
	public map<string,map<string,boolean>> buttonmap {get;set;}
	public string routingid{private get; private set;}
	public string pagecontext {get;set;}
	public string Attachedarticles{get;set;}
	public string responsestring{get;set;}
	public string selectedcandidate2{get;set;}
    public string RegistrationID{get; set;}
	public id previousowner {get;set;}
	boolean redirectinprogress = false;

	public string previousstatus{get;set;}
	public boolean manualroute {get;set;}
	boolean editconfigretrieve = false;						
	public string subsection_re_render {get
				{ if(subsection_re_render == '' || subsection_re_render == null)
						{ subsection_re_render = '';}
						return subsection_re_render;}
				  set;
				}
	public boolean mustReAquire = false;
    public string selKnowledgeArticleIds{get; set;}

	public map<string, boolean> newbuttonmap {get
		{
			if(newbuttonmap == null && mycaseconfig!=null)
				{
					newbuttonmap = new map<string, boolean>{'Importbutton'=>false,'Reschedulebutton'=>false,'Missingresultsbutton'=>false};					
					string usercode = [select name, id, Primary_team_persona__c from user where id = :userinfo.getuserid()].Primary_team_persona__c;
					system.debug('import_Cases_button:'+mycase.routing__c+mycase.routing__r.Import_cases_button__c);
					
					if(mycase.routing__r.Import_Cases_Button__c != null)
					{
						for(string eachcode:mycase.routing__r.Import_Cases_Button__c.split(';'))
							{
								if(usercode.contains(eachcode))
									{
										system.debug('eachcode' + eachcode);
										newbuttonmap.put('Importbutton', true);
										break;	
									}		
								
							}
					}	
					if(mycase.routing__r.mass_reschedule_button__c != null)
					{	
						for(string eachcode:mycase.routing__r.Mass_Reschedule_Button__c.split(';'))
							{
								if(usercode.contains(eachcode))
									{
										newbuttonmap.put('Reschedulebutton', true);
										break;	
									}		
								
							}	
					}
					if(mycase.routing__r.Missing_Results_Button__c != null)
					{	
						for(string eachcode:mycase.routing__r.Missing_Results_Button__c.split(';'))
							{
								if(usercode.contains(eachcode))
									{
										newbuttonmap.put('Missingresultsbutton', true);
										break;	
									}		
								
							}
					}	
				}
			return newbuttonmap;	
		}
		set;}
	
	//changed to instantiate the DAO items early for use in save and in the get for the typeahead feature
	DAOFactory d = new DAOFactory();
    ESBDao dao = d.getEsbDao();
	
	//  the button map handles the visibility for special buttons with limited access on the page
	//  currently there are three such buttons, 
	//  Mass Reschedule, CaseImport and MissingResultsTool
	//  the map initializes with all profiles in the system.
	public string selectedcandidate {get;set;}
	
	public string getcandidate(){
		if(selectedCandidate != null)
			{selectedCandidate = SelectedCandidate;}
		else{selectedCandidate = '';}
		return selectedCandidate;	
	}
	
	public void setcandidate(string SelectedCandidate)
		{this.selectedcandidate = SelectedCandidate;}
	
    //SK: Whether or not to show the Edit button to Community user
    public boolean communityRenderEditButton {
        get {
            if ( this.communityRenderEditButton == null ) {

                //Case cs = [select OnwerId, Owner.Type, Owner.Name from Case where Id = :mycase.Id];
                if ( pagecontext == 'view' && mycase.isclosed == false ) {
                    System.debug('mycase.Owner: ' + mycase.Owner);
                    // Show "Edit" button if Case is owned by Current User, OR owned by 'Test Center' Queue
                    this.communityRenderEditButton = 
                        mycase.OwnerId == UserInfo.getUserId() || 
                            (mycase.Owner.Type == 'Queue' && mycase.Owner.Name == 'Test Center');
    
                    System.debug('communityRenderEditButton: ' + communityRenderEditButton);
                    if ( !this.communityRenderEditButton && mycase.Owner.Type == 'User') {
                        // Show "Edit" button if Case is owned by another User form the current user's Test Center
                        ID ownerAcctId = [select Contact.AccountId from User where Id = :mycase.OwnerId].Contact.AccountId;
                        System.debug('ownerAcctId: ' + ownerAcctId);
                        System.debug('mytestcenterid: ' + mytestcenterid);
                        this.communityRenderEditButton = mytestcenterid == ownerAcctId;
                    }
                } else {
                    this.communityRenderEditButton = false;
                }
            }
            return this.communityRenderEditButton;
        }
        private set;
    }
    // variable for cancelation url 
    private string sortField { get; set; }
    private string sortDir { get; set; }
    private string pageNo { get; set; }
    
	public id getdefaultTeamId ()
		{
			string teamname = [select id, who_is_Doing_the_work__c from step__c where id = :mycase.step__c].Who_is_doing_the_Work__c;
			id defaultTeam = [Select Id, Name, DeveloperName, Type from Group where Type = 'Queue' AND developername = :teamname].id;
			return defaultTeam;
		}
	
	public pagereference ReturntoTeam()
		{
			mycase.ownerId = getdefaultTeamId();
			manualroute = true;
			mycase.CaseMgt_Lateral_Routing__c = false;
			
			pagereference mysave = Manual_route();
			return mysave;
		}
		
	public pagereference redirect (){
        
		//check to see if page has done the redirect and takeownership process. 
		//added a page redirect to the standard page to force the items to refresh to show the
		// change to owner
		PageReference mypageref;
		if(system.currentPageReference().getParameters().get('redir') != 'complete')
		{
		if(pagecontext == 'edit' && mycase.isclosed==false){
		previousowner = mycase.Owner_ID__c;
		previousstatus = mycase.status__c;
		takeownership();}
		
		
			if(userinfo.getUserType() != 'Standard')
				{
					
					
					
					mypageref = new pagereference('/apex/CreateCasecomm');
				
				
					if(mycase.id !=null)
						{
							mypageref.getParameters().put('id', mycase.id);
							mypageref.getParameters().put('prevown', previousowner);
							mypageref.getParameters().put('prevstat', previousstatus);
							
							mypageref.getParameters().put('ext_c', string.valueof(mycase.new_external_comment__c));
							mypageref.getParameters().put('int_c', string.valueof(mycase.New_Internal_Comment__c));
							mypageref.getParameters().put('int_e', string.valueof(mycase.New_Internal_Email__c));
							
							mypageref.getParameters().put('sourcepage',system.currentpagereference().getParameters().get('sourcepage'));
							mypageref.setRedirect(false);
		
        						IF(mycase.isclosed == true && pagecontext == 'edit')
        						{	
        							
        							mypageref = page.CreateCasecomm;
        							mypageref.getParameters().put('id', mycase.id);	
        							mypageref.getParameters().put('redir','complete');	
        							mypageref.getParameters().put('editclosed','true');			
									mypageref.getParameters().put('prevown', previousowner);
									mypageref.getParameters().put('prevstat', previousstatus);
									
									
									
									mypageref.setRedirect(true);
        							 
        						}
	
						}
				}		
				else if(pagecontext == 'edit'){
					if(mycase.isclosed)
						{
							mypageref = page.createcasePOC;
							mypageref.getParameters().put('id', mycase.id);	
							mypageref.getParameters().put('editclosed','true');	
							 
	                                mypageref.setRedirect(true);
						}
					else
						{
							mypageref = system.currentPageReference();
							mypageref.setRedirect(false);							
						}

					mypageref.getParameters().put('redir','complete');
					mypageref.getParameters().put('prevown', previousowner);
					mypageref.getParameters().put('prevstat', previousstatus);
					
					mypageref.getParameters().put('ext_c', String.valueof(mycase.new_external_comment__c));
					mypageref.getParameters().put('int_c', String.valueof(mycase.New_Internal_Comment__c));
					mypageref.getParameters().put('int_e', String.valueof(mycase.New_Internal_Email__c));
					
					
					}
							
				//return mypageref;			
	        }
	
	        if ( mypageref == null || mypageref.getRedirect() == false ) {
	
	            //Refresh VTS data if stale
	            new VTSPersistenceUtility().refreshVtsData(false, this.caseRegistration, this.caseRegistration.Candidate__r, this.caseSite);
	            this.caseRegistration = null;
	            this.caseSite = null;
                if(mycase.id == null && mycase.contactid != null )
                {
                    mycase.Primary_contact__c = mycase.contactid;
                }
                
	            //Delete temporary uploaded documents
	            redirectinprogress = true;
	            deleteTempDocuments();
	        }
		
		
	
        return mypageref;
	}
	
	public pagereference cancelbutton(){
		
		
		case tempcaseforsave = [select casenumber, ownerid from case where id = :mycase.id];
		if(mycase.OwnerId == userinfo.getuserid())
			{
				
				string preownerid = system.currentpagereference().getParameters().get('prevown');
				string prestatus = system.currentPageReference().getParameters().get('prevstat');
				
				tempcaseforsave.New_External_Comment__c = system.currentPageReference().getParameters().get('ext_c') =='true';
				tempcaseforsave.New_internal_comment__c = system.currentPageReference().getParameters().get('int_c') =='true';
				tempcaseforsave.new_internal_email__c = system.currentPageReference().getParameters().get('int_e') =='true';
				mycase.New_External_Comment__c = system.currentPageReference().getParameters().get('ext_c') =='true';
				mycase.New_internal_comment__c = system.currentPageReference().getParameters().get('int_c') =='true';
				mycase.new_internal_email__c = system.currentPageReference().getParameters().get('int_e') =='true';
			/*	if( preownerid != null && preownerid != '')
					{
						tempcaseforsave.OwnerId = preownerid;
						tempcaseforsave.status__c = prestatus;
                		tempcaseforsave.status = prestatus;
                	//	tempcaseforsave.New_External_Comment__c =
                	//	tempcaseforsave.New_Internal_Comment__c = 
                	//	tempcaseforsave.New_Internal_Comment__c = 
						update(tempcaseforsave);
					}
				else{*/
					tempcaseforsave = withoutsharingutility.getpreviousvalue(mycase);
					system.debug('without sharing utility used::' + tempcaseforsave);
					update tempcaseforsave;	
				//}	
			}	
		
		
		pagereference mypageref = page.createcasecomm;
		if(userinfo.getUserType() == 'Standard')
			{
				mypageref = page.CreateCasePOc;
			}
		
		if(system.currentpagereference().getParameters().get('sourcepage')!=null)
			{
				
				mypageref = page.Custom_case_listview;
                mypageref.getParameters().put('sourcepage', system.currentpagereference().getParameters().get('sourcepage'));
                mypageref.getParameters().put('sortField', sortField);
                mypageref.getParameters().put('sortDir', sortDir);
                mypageref.getParameters().put('pageNo', pageNo);
					if(tempcaseforsave.OwnerId != userinfo.getUserId())
						{
							mypageref.getParameters().put('ownername', [select owner.name from case where id =:tempcaseforsave.id].owner.name);
							mypageref.getParameters().put('prevown', system.currentpagereference().getParameters().get('prevown'));		
						}
					
					
					
			}
		else if(mycase.id !=null && mypageref != null)
					{
						mypageref.getParameters().put('id', mycase.id);
						if(tempcaseforsave.OwnerId != userinfo.getUserId())
							{
								mypageref.getParameters().put('ownername', [select owner.name from case where id =:tempcaseforsave.id].owner.name);
								mypageref.getParameters().put('prevown', system.currentpagereference().getParameters().get('prevown'));		
							}	
						mypageref.setredirect(true);										
					}
		if(tempcaseforsave.Ownerid != userinfo.getuserid())
			{
				mypageref.getParameters().put('prevown',tempcaseforsave.ownerid);
			}
						
		return mypageref;
	}
	
	public pagereference ReOpen(){
		mycase.Step__c = mycase.previous_step__c;
		mycase.ownerid = system.Userinfo.getUserId();
		mycase.status = 'Working';
		mycase.re_opened__c = true;
		mycase.status__c = 'Working';
		update mycase;
		
		pagereference mypageref = system.currentPageReference();
		mypageref.getParameters().put('feedback', 'reopensuccess');
		mypageref.setRedirect(true);
		return mypageref;
	}
	
	public list<selectoption> typeahead {get
		{	
			system.debug('Start Get Typeahead');	
		
			Org_settings__c myorgset = Org_settings__c.getInstance();
			if(typeahead==null)
				{	
					typeahead = new list<selectOption>();
				}
			if(typeahead!=null){	
			if(typeahead.size()<2){	
			//if(userinfo.getusertype() != 'Standard')
			//	{	
					date mystart;
					date mystop;
					string currentorg = userinfo.getOrganizationid();
					if(myorgset.Production_org_id__c != currentorg && myorgset.UAT_org_id__c != currentorg)
						{
							mystart = date.newinstance(2001,7,1);
							mystop =date.newinstance(2005,8,10);
						}
					else
						{
							if(myorgset.Production_org_id__c == currentorg)
								{
									mystart = date.TODAY() - 1;
									mystop = date.Today();
								}
							else
								{
									mystart = date.Today()-7;
									mystop = date.Today();
								}
						}
				
				user  myuser = new user();
				decimal tcid;
					if(Userinfo.getUsertype() != 'Standard')
						{
							
									myuser = [select name, id, contactid, contact.account.VTS_Test_Center_id__c from User where id = :userinfo.getUserId()];
									tcid = myuser.contact.account.vts_test_center_id__c;
								
						}				
					else
						{
							tcid = mycase.account.VTS_Test_Center_id__c;	
						}
			if(tcid != null)
				{		
					try{
						list<vts_registration> myreturns = new list<vts_registration>();
						myreturns = dao.getRegistrationsByTestCenterId(tcid.longvalue(),mystart, mystop);
						myreturns.sort();
						for(vts_registration eachreg:myreturns)
							{	
								long mytime = eachreg.appointmentTime.TimestampinUTC;
	//							mytime = mytime + eachreg.appointmentTime.displayTimeZoneUTCOffset;
	//				  			above line removed BW as the new timestampInUTC is actually UTC not local
								string examtime = DateTime.newInstance(mytime).format();
								string mylabel = eachreg.Candidate.firstname + ' ' + eachreg.Candidate.lastname;
								mylabel += ' - '  + examtime;
								SelectOption myoption = new Selectoption (string.valueof(eachreg.id), mylabel);
								typeahead.add(myoption);
							}
								
								selectoption myselect = new selectoption('',system.label.select_one);
								if(typeahead.size()>1) typeahead.add(0, myselect);
								else{typeahead.add(myselect);}
						}
						catch(exception a)
							{
								
								system.debug('EXCEPTION CAUGHT Editconfig Routing Logic'+ a);
	                                string errmessage = 'An ' + a + 'error occured connecting to VTS.'+
	                                            'Please contact your Salesforce Administrator';
	                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errmessage);
	                                ApexPages.addMessage(myMsg); 
								
								
							}
				}		
		//		}//finish usertype != 'Standard'
			}
		}		
				else typeahead = typeahead;
				return typeahead;
		}set;
	}
// new getter method to ascertain the next stop for a case	
	public step__c getnextstep(){
		
			nextstep = utility.getnextstep(mycase,mycaseconfig.steps__r[0] );
			return nextstep;
			}
	public void setnextstep( step__c nextstep){
		this.nextstep =nextstep;
	}
	public string getpagecontext(){
		string myurl = apexpages.currentpage().getURL();
		string pagecontext = 'create';

        System.debug('myurl: ' + myurl);

		if( myurl.contains('&id=') || myurl.contains('?id=') ){
			if(myurl.contains('&retURL'))
				{
					pagecontext = 'edit';
				}
			else pagecontext = 'view';	
			
		}
        System.debug('pagecontext: ' + pagecontext);
		return pagecontext;	
	}
	
	public void setpagecontext(string pagecontext){
		this.pagecontext = pagecontext;
	}
	
	public map<string,map<string,boolean>> getbuttonmap()
		{
			if (buttonmap == null )
				{
					buttonmap = new map<string,map<string,boolean>>();
					list<profile> myprofiles =  [select name from profile];
					
					map<string,boolean> importmap = new map<string,boolean>();
					map<string,boolean> massresched = new map<string,boolean>();
					map<string,boolean> misresultsmap = new map<string,boolean>();
						for(profile each:myprofiles)						
							{
								importmap.put(each.name,false);
								massresched.put(each.name,false);
								misresultsmap.put(each.name,false);
							}
						
					buttonmap.put('CaseImport',importmap);
					buttonmap.put('MassReschedule',massresched);
					buttonmap.put('MissingResults',misresultsmap);
						
				}
				
		//for edit cases, loop through the fields capturing persona access to the buttons and update the map
			if(editconfig!= null)
				{
							map<string,boolean> importbutton = new map<string,boolean>();
										 importbutton = buttonmap.get('CaseImport');
						    			if(editconfig.Import_Cases_Button__c!=null)
							    			{
								    			 for(string includelist:editconfig.Import_Cases_Button__c.split(';'))
								                    {
						                    	    	importbutton.put(includelist, true);
													}
								                        
								                        buttonmap.put('CaseImport',importbutton);
								                    }
							    			    
						                map<string,boolean> reschedbutton = buttonmap.get('MassReschedule');
						                
						                if(editconfig.Mass_Reschedule_Button__c!=null)
											{
								    			 for(string includelist:editconfig.Mass_Reschedule_Button__c.split(';'))
								                    {    	
							                        	reschedbutton.put(includelist, true);
													}
								                        
								                        buttonmap.put('MassReschedule',reschedbutton);
											}        
						                 map<string,boolean> misResultsbutton = buttonmap.get('MissingResults');    

										if(editconfig.Missing_Results_Button__c!=null)
											{
								                for(string includelist:editconfig.Missing_Results_Button__c.split(';'))
								                    {
						                        		misResultsbutton.put(includelist, true);
						                    		}
								                        buttonmap.put('MissingResults',misResultsbutton);
											}
					
				}	
				return buttonmap;}

    //map of strings and booleans to use for the rendered statements for sections and related lists
    //possible values for the list is gained from a schema-call to get the picklist values
    //the values are retrieved from the Routing__c.Related_lists__c
    
    public map<string,boolean> Rendermap 
    	{get
	            {
	            	if(Rendermap==null)
	            		{
	            			this.Rendermap = new map<string,boolean>();
	                		for(integer i = 0; i<11; i++)
	                            {
	                            	string mysection = 'Section ';
	                                mysection +=i;                                                              
	                                rendermap.put(mysection,false);
	                            }
	                            
	                		for(string field:Utility.getpickvals('Related_Lists__c', 'Routing__c'))
			                    {
			                        rendermap.put(field,false);
			                    }
                            // If Attachments are included, set to 'true' so that the related list appears upon Create
                            if ( rendermap.containsKey('Attachments') ) {
                                rendermap.put('Attachments', true);
                            }
	            		}
	        		//else this.Rendermap = Rendermap;
	            	return this.Rendermap;
	    		} 
        	set;}
                    
    
    // list of strings to add fields for the visualforce page
    private final list<string> casefields;

    //value to determine create, or view/edit for a case.
    //not sure I need this value.  Need to review
    public boolean notnew 
    	{get
    		{ if(notnew== null)
    			{
					if(mycase!=null)
	                	{
	                		notnew = mycase.id!=null;
	            		}
    			}		
	            return notnew;
            } 
        set;}
    
	public void selectmanualrouting(){
		
		system.debug('start of selectManualRouting::' + mycase.ownerid);
		mycase.CaseMgt_Lateral_Routing__c = true;
		mycase.follow_up_with__c = 'Any internal user';
		
		mycase.status__c = 'Awaiting pickup';
		mycase.status = 'Awaiting pickup';
		manualroute = true;
		
		string myname = '';
		if(mycase.Casemgt_Original_owner__c == '' || mycase.Casemgt_Original_owner__c == null)
        			{
        				mycase.Casemgt_Original_owner__c = system.userinfo.getuserID();
        			}


		if(string.valueof(mycase.ownerid).startswith('005'))
			{
				myname = [select name, id from user where id = :mycase.OwnerId].name;
			}
		else
			{
				myname = [SELECT name, id FROM group WHERE type = 'Queue' and  id = :mycase.OwnerId].name;
			}	
		mycase.CaseMgt_Delayed_Routing_Name__c = myname;
		system.debug('End select Manual routing::' + mycase.caseMgt_original_owner__c);
		
	}
	
	public string getroutingid(){
								if(routingid == null|| routingid == '')
									{
										routingid = [select id, routing__c from step__c where id= :mycase.step__c].routing__c;	
									}
								return routingid;}


    //routing record for use with edit and view 
    //editconfig is the routing__c record which is supplying the information for which fieldset to retrieve when the case is
	// a pre-existing case which is going to be edited.  the Routing__c record is selected based on the Step__c record which is recorded on
	// the case
    public Routing__c editconfig 
    	{get         
            {
            	system.debug('BEGIN geteditconfig');
                
                //SK: Adding a null-check to prevent repeated executions of the logic.
                //    Brian, please review this and let me know if you think it would cause issues.
                if ( editconfig == null ) {
                if(editconfig == null){editconfig = new routing__c();}
                    Try
                        {    
                            System.debug(mycase.step__c + ' --- ' + mycase.id + '---' + DM);
                            if(mycase.step__c!= null && mycase.id!=null && DM!=null)                                               
                                {
                                    if(routingid == null)
                                        {getroutingid();}
                                    
                                    string mystep = mycase.step__c;
                                    string query = 'Select ';                   
                                    string mytype = Schema.Sobjecttype.Case.getRecordTypeInfosById().get(mycase.recordtypeid).getname();
                                    query += utility.Editablefields('Routing__c');
                                    query += ', (SELECT ' + utility.Editablefields('Step__c');
                                    query += ' FROM steps__r where step__c.Id = :mystep)'; //' and RecordTypeId = \'' + STEP_REC_TYPE_ROUTING_STEP + '\')';
                                    query += ' FROM Routing__c WHERE id = :routingid LIMIT 1';                                  
                                    if(editconfigretrieve == false)
                                        {
                                            editconfig = database.query(query);
                                            mycase.routing__r = editconfig;
                                        }
                    
                        //populate the rendermap with booleans for section rendered= statements
                                        step__c currentstep = editconfig.steps__r[0];
                                        if(currentstep !=null)
                                            {
                                                mycase.step__r = currentstep;
                                                mycase.step__c = currentstep.id;
                                                editconfigretrieve = currentstep.id !=null ;
                                                if(currentstep.section_visible__c != null)
                                                    {
                                                        for(string mysection:currentstep.section_visible__c.split(';'))                                                     
                                                            {rendermap.put(mysection,true);}
                                                    }
                                            }       
                              
                        //add related lists to the rendermap
                                        if(editconfig.related_lists__c != null)
                                            {
                                                for(string includelist:editconfig.Related_Lists__c.split(';'))
                                                    {
                                                        rendermap.put(includelist, true);
                                                    }	 
                                            }
                                         
                    // add buttons to the buttonmap
                                    
                                    
                                                                                                       
                        			System.debug('Rendermap::' + rendermap);
                                    System.debug('END getEditconfig');  
                                    
                                }
                            //return editconfig;
                        }
                    
                
                Catch(exception editconfig_exception)
                    {
                        system.debug('EXCEPTION CAUGHT EditConfig.get'+editconfig_exception);
                        return null;
                    }
                }
                return this.editconfig;
            }   
                set;
        }                                                           
                
                
    // selected category                                            
    public String myCategory {get;set;}

    // Casetype selection applies to console but not to the community
    public string CaseType {get;set;}
    	/*	{get
	                {
	                	if(mycase.id !=null)
	                		{
	                			casetype = mycase.topic__c;
	                			
	                		}
	                	else
	                		{
	                			casetype = casetype;
	                		} 
	                		
                		return Casetype;
            		}
            set;} */
    
    // variable that allows the controller to know if the page using the controller is in the console or a standard vf page
    private String pagetype {get;set;}                      

    // value that the user enters to search for a registration or a site(test center)
    // also receives the value back from the advanced search and is then plugged into the correct field
    public string EnteredId
		{get
	            {
	            	
	            //BW adding section to populate enteredId when the 
	            	if(pagecontext == null) getpagecontext();
	            		
	            		//if(pagecontext == 'create')	
	            		//{
			            	if(mycase.accountid != null && enteredId == null)
			            		{ account myaccount = [select id, vts_test_center_id__c from Account where Id = :mycase.accountid];
			            			try{
			            				if(CaseType == null) CaseType = 'Site ID';
			            				enteredId = string.valueof(myaccount.vts_test_center_id__c);
			            				}
			            			catch(system.nullpointerException a){system.debug('EnteredId Exception Caught' + a);}	
			            		}
			            	if(mycase.Registration_id__c != null && enteredId == null)
			            	{	            		
			            			Registration__c myreg = [select id, vts_registration_id__c from Registration__c where id = :mycase.Registration_id__c];
			            			try{
			            				if(caseType == null) CaseType = 'Registration ID';
			            				enteredId = string.valueof(myreg.vts_registration_id__c);
			            				}
			            			catch(system.nullpointerException a){system.debug('EnteredId Exception Caught' + a);}
			            	}	
	            		
	            			//if(enteredId != null) Retrieve_Reg_or_Site();
	            		
	            	//	}
	            		
	                enteredId = enteredid;
	        		return enteredid;
	    		}
		set;}

    public Registration__c caseRegistration {
        get {
            // If registration is NULL, OR selected Registration changed
            if ( this.caseRegistration == null || this.caseRegistration.Id != mycase.Registration_Id__c ) {
                if ( mycase.Registration_id__c != null ) {
                    this.caseRegistration = 
                        [SELECT VTS_Registration_ID__c, Date_and_Time_of_Exam__c, LastModifiedDate, Exam__r.Exam_Name__c, Exam__r.Client__r.Result_hold_categories__c, exam__r.Client__r.Allow_Case_Related_Holds__c,
                         	Candidate__r.Email__c, Candidate__r.Address_Line_1__c, Candidate__r.CCID__c, Candidate__r.Phone_Country_Code__c, Candidate__r.Address_Line_3__c,Candidate__r.Address_Line_2__c,Candidate__r.VTS_Candidate_ID__c, candidate__r.phone_number__c,
                         	Candidate__r.Country__c, Candidate__r.State__c, Candidate__r.State_name__c, Candidate__r.Country_Name__c, Candidate__r.First_Name__c, Candidate__r.Last_Name__c, Candidate__r.Middle_Name__c,
                         	Candidate__r.City__c, Candidate__r.Postal_Code__c, Candidate__r.LastModifiedDate, Test_Center__r.Name, Exam__r.Client__r.name,
                         	Test_Center__r.VTS_Test_Center_ID__c, Test_Center__r.Channel_Type__c, Test_Center__r.LastModifiedDate
                         FROM Registration__c
                         WHERE Id = :mycase.Registration_Id__c
                         LIMIT 1];
                } else {
	                this.caseRegistration = null;
                }
            }
            return this.caseRegistration;
        }
        private set;
    }
    public Candidate__c CaseCandidate{
    	get{
			if(this.CaseCandidate == null || this.caseCandidate.id != mycase.candidate_id__c)
	    		{
		    		if(mycase.Candidate_id__c != null)
		    			{
		    				this.caseCandidate = 
		    					[SELECT First_Name__c, Last_name__c, email__c, address_line_1__c, CCID__c, Phone_Country_code__c, Address_Line_2__c, Address_Line_3__c, 
		    					 Country__c, State__c, City__c, State_name__c, Postal_code__c, Country_Name__c, phone_number__c, Middle_Name__c from Candidate__c where id =: mycase.candidate_id__c];
		    			}
	    		}
	    		return caseCandidate;
    		}
    	set;	
}
    public Account caseSite {
        get {
            // If registration is NULL, OR selected Registration changed
            if ( this.caseSite == null || this.caseRegistration.Test_Center__r.Id != caseSite.Id ) {
                if ( this.caseRegistration == null ) {
                    if ( mycase.AccountId != null ) {
                        this.caseSite = 
                            [SELECT Name, VTS_Test_Center_ID__c, Channel_Type__c, LastModifiedDate
                             FROM Account
                             WHERE Id = :mycase.AccountId
                             LIMIT 1];
                    }
                } else {
                    this.caseSite = this.caseRegistration.Test_Center__r;
                }
            }
            return this.caseSite;
        }
        private set;
    }

    public Set<String> sectionsWithSubSection {
        get {

            //System.debug('sectionsWithSubSection: ' + this.sectionsWithSubSection);
            if ( this.sectionsWithSubSection == null ) {
         
          		system.debug('SectionswithSubsection called');
                String stepId;
                if ( this.mycase != null && this.mycase.Step__c != null ) {
                    stepId = this.mycase.Step__c;
                } else if ( mycaseconfig != null && !mycaseconfig.steps__r.isEmpty() ) {
                    stepId = mycaseconfig.steps__r[0].Id;
                }
                System.debug('stepId: ' + stepId);
            
//switching to use the routing logic as the orginizational piece and not the step

                this.sectionsWithSubSection = null;
                if ( stepId != null ) {
                    this.sectionsWithSubSection = new Set<String>();
                    for ( Routing_Logic__c subsectionRoutingLogic : 
                         		[select Parent_Section__c, Re_Render_Block__c 
                                 from Routing_logic__c 
                                 where Step__c = :stepId and RecordType.Name = 'Dynamic Section Logic'] ) {

						this.sectionsWithSubSection.add(subsectionRoutingLogic.Parent_Section__c);
						subsection_re_render = '';
						if(subsectionRoutingLogic.Re_Render_Block__c!=null){
						if(!subsection_re_render.contains(subsectionRoutingLogic.Re_Render_Block__c))
                                	{
                                	if(subsection_re_render != ''){subsection_re_render += ',';}	
                               		subsection_re_render +=subsectionRoutingLogic.Re_Render_Block__c;
                                	}
						}
                    }
                    System.debug('sectionsWithSubSection: ' + this.sectionsWithSubSection);
                }
            }
            
            return this.sectionsWithSubSection;
        }
        private set;
    }


//construction of the collection of fieldset members to allow for re-render.  In this loop, routing_logic__c records of record type Dynamic_section_logic are
//evaluated.  If they resolve to true, the fieldset members from that routing logic's fieldset are added to the map <string, list<schema.FieldsetMember> and then
//evaluation continues until all records have been evaluated.  In this way, multiple field sets can be combined to be displayed.
   // public void setSectionToDynamicFieldsMap(map<string,list<schema.fieldsetMember>> sectiontoDynamicFieldsMap)
   // 	{
  //  		this.SectionToDynamicFieldsMap = SectiontoDynamicFieldsMap;
  //  	}
    public Map<String, List<Schema.FieldSetMember>> getSectionToDynamicFieldsMap() {
		
        System.debug('m in getSectionToDynamicFieldsMap()');
        Map<String, List<Schema.FieldSetMember>> sectionToDynamicFieldsMap = new Map<String, List<Schema.FieldSetMember>>();
        String stepId;
        if ( this.mycase != null && this.mycase.Step__c != null ) {
            stepId = this.mycase.Step__c;
        } else if ( mycaseconfig != null && !mycaseconfig.steps__r.isEmpty() ) {
            stepId = mycaseconfig.steps__r[0].Id;
        }
        System.debug('stepId: ' + stepId);
        
        if ( stepId != null ) {
            
            Step__c currentStep = [select Section_Visible__c, routing__c, Has_Dynamic_Sections__c from Step__c where Id = :stepId];
            if ( currentStep.Section_Visible__c != null ) {
                for ( String sectionName : currentStep.Section_Visible__c.split(';') ) {
                    sectionToDynamicFieldsMap.put(sectionName, new List<Schema.FieldSetMember>());
                }
            }

            if ( this.sectionsWithSubSection != null && !this.sectionsWithSubSection.isEmpty() && currentstep.Has_Dynamic_Sections__c == true) {

                String query = 'SELECT ' + utility.Editablefields('Routing_logic__c') +
                    ', (SELECT ' + utility.Editablefields('Routing_field__c') + ' FROM Routing_Fields__r)' +
                    ' FROM Routing_logic__c WHERE Step__c = :stepId and Recordtype.name = \'Dynamic Section Logic\' Order by Page_order__c'; 
                List<Routing_Logic__c> routes = database.query(query);
                System.debug('routes: ' + routes);


                Routing_Logic__c selectedLogic;

                        for ( Routing_Logic__c possibleRoute : Routes) {

                            boolean checkvalue = false;
                            boolean orboolean = false;
                            boolean andboolean = true;
                            Integer i=0;
      /*
      		This loop is almost exactly the same as the one used for the dynamic routing with one VERY IMPORTANT exception.  This loop does not have the break
      		command at line 568 (remarked out only to make difference obvious).  The reason is that on the routing logic for submit logics, once a true is found,
      		no other routing logics should be evaluated.  However, for dynamic re-renders, we continue to evaluate to make it possible to allow for progressive 
      		re-render on multiple fields.
      
      */                     
                           
                            while ( (andboolean && i < possibleroute.routing_fields__r.size()) || (!orboolean && i< possibleroute.routing_fields__r.size()) ) {

                                Routing_Field__c routingFld = possibleroute.routing_fields__r[i];
                                String comparableFldName = routingFld.name;
                                System.debug('comparableFldName: ' + comparableFldName);
                                if ( !String.isBlank(comparableFldName) ) {

                                    String comparableFldValue = String.valueOf(mycase.get(comparableFldName));
                                    System.debug('comparableFldValue: ' + comparableFldValue);
	                                System.debug('Did_candidate_lose_measured_exam_time__c: ' + mycase.Did_candidate_lose_measured_exam_time__c);
                                    if ( routingFld.operator__c == 'Equals' ) {
                                        checkvalue = comparableFldValue == routingFld.Value__c;
                                    }
                                    else if ( routingFld.operator__c == 'Not equals') {
                                        checkvalue = comparableFldValue != routingFld.Value__c;
                                    }
                                    //Greater/Less than Date comparison
                                    else if ( routingFld.operator__c == 'Greater than' || routingFld.operator__c == 'Less than' ) {
                                        
                                        String subtractionFldName = routingFld.SubtractionField__c;
                                        if ( !String.isBlank(subtractionFldName) ) {
                                            
                                            Object fld1Value = mycase.get(routingFld.name);
                                            Object fld2Value = mycase.get(subtractionFldName);
                                            if ( fld1Value != null && fld2Value != null ) {
                                                
                                                Long value1 = Datetime.valueof(fld1Value).gettime();
                                                Long value2 = Datetime.valueof(fld2Value).gettime();
                                                Decimal diff = (value1 - value2) / 60000;
                                                System.debug('diff: ' + diff);
                                                if ( routingFld.operator__c == 'Greater than' ) {
                                                    checkvalue =  diff > Decimal.valueof(routingFld.value__c);
                                                }
                                                else if ( routingFld.operator__c == 'Less than' ) {
                                                    checkvalue =  diff <= Decimal.valueof(routingFld.value__c);
                                                }
                                            }
                                        }
                                    } //END: Else If ( Greater/Less Than comparison)
                                } //END: If ( comparableFldName )

                                //System.debug('checkvalue: ' + checkvalue);
                                //System.debug('routingFld.logic_type__c: ' + routingFld.logic_type__c);
                                //System.debug('andboolean: ' + andboolean);
                                if ( routingFld.logic_type__c == 'AND' && andboolean ) {
                                    andboolean = (checkvalue);
                                }
                                else {
                                    orboolean = checkvalue;
                                }
                                i++;
                            } //END: While ( RoutingLogicFields )

                            if ( andboolean == true || orboolean == true) {
                                selectedlogic = possibleroute;
                                System.debug('selectedlogic: ' + selectedlogic);
                                //break;
                            }
                            else {
                                selectedlogic = null;
                            }

                            if ( selectedlogic != null) {
                                list<Schema.FieldSetMember> sectionFieldsetMembers = sectionToDynamicFieldsMap.get(selectedlogic.Parent_Section__c);
                                //BW 7-20
                                if(selectedLogic.Sub_Section_fieldset__c != null)
                            	{
	                                if ( sectionFieldsetMembers == null ) {
	                                    sectionFieldsetMembers = Utility.readFieldSet(selectedlogic.Sub_Section_Fieldset__c, 'Case');
	                                    sectionToDynamicFieldsMap.put(selectedlogic.Parent_Section__c, sectionFieldsetMembers);
	                                } else {
	                                    sectionFieldsetMembers.addAll(Utility.readFieldSet(selectedlogic.Sub_Section_Fieldset__c, 'Case'));
	                                    //sectionToDynamicFieldsMap.put(selectedlogic.Parent_Section__c, sectionFieldsetMembers);
	                                }
                            	}
                            }
                        } //END: For ( subsectionStep.RoutingLogics )
                        
                        if ( selectedlogic != null) {
                        if(selectedlogic.Move_Step_on_Render__c)
                        	{
                    			Step__c nextstep = [select name, id from Step__c where Routing__c = :currentstep.routing__c and Step_Number__c = :selectedlogic.Go_to_step__c];
                        		mycase.step__c = nextstep.id;
                        	}
                        	selectedlogic = null;
                        }
                //    } //END: If ( subsectionStep.Has_forked_logic__c )
            }	 //END: For ( SubsectionSteps )
   //         } //END: If ( this.sectionsWithSubSection )
        } //END: If ( stepId )

        // Reset sectionsWithSubSection so that it is repopulated when needed
        this.sectionsWithSubSection = null;

        System.debug('sectionToDynamicFieldsMap: ' + sectionToDynamicFieldsMap);
        return sectionToDynamicFieldsMap;
      
      
    }
	// subcategory from selection matrix
    public string mySubCategory{get;set;}

    //boolean to help determine when the fields should be shown on the page
    public boolean showcase{get;set;}


    //Class that holds the information for building out the topic/category/subcategory choice matrix for case type
    public Decisionmatrix2 DM 
    		{get
                {
                	if(DM==null)
                    	{
	                       // string persona = [select name, id from profile where id=:userinfo.getProfileId()].name;
	                        string persona = [select name, id, Primary_team_persona__c from user where id = :userinfo.getUserId()].Primary_team_persona__c;
	                        this.DM = new Decisionmatrix2(persona);
                    	}                           
                     return DM;
                }
            set;}   

    //the instantiated record
    public final case mycase;

    // set of string to allow the page to know if the subcategories list needs to be used
    public set<string> catwithsubcat = new set<string>();

    
   
    // possibly change from a get/set setup
    public map<string,Decisionmatrix2.categoryObject> CategoryObjectMap 
    			{get
	                {
	                	if(this.CategoryobjectMap==null)
	                    	{
	                    		this.CategoryobjectMap = new map<string,Decisionmatrix2.CategoryObject>();
	                    	}
                    	else this.CategoryObjectmap = categoryObjectMap;
	                    return this.CategoryObjectMap;
                    } 
                set;}



    // the finalcat string helps preserve the value for the case type which can exist either at the
    // category or subcategory level.   
     public string finalcat
     	{get            
            {
              system.debug('BEGIN Finalcat Get');
              if(myCategory!=null)
              	{              
	            	if(catwithsubcat.contains(myCategory)&& mySubCategory!=null)
	            	  	{
	            	  		finalcat = mySubcategory;//removed 38 char limit
	            	    	this.showcase=true;
	            	   	}
	              
	            	if(!catwithsubcat.contains(myCategory))
	            	  	{
	            	     finalcat = mycategory;//removed 38 char limit
	            	     this.showcase=true;
	            	   	}
					if(catwithsubcat.contains(myCategory)&& mySubCategory==null)
	            	   	{
	            		     finalcat = null;
	                 		this.showcase = false;    
	               		}
            	}

             else
             	{finalcat = null;}
             
             system.debug('END Finalcat Get: ' + finalcat);
             return finalcat;  
            }
        set;}
    

    public Routing__c myCaseConfig
    		{get
    			{ 
                // this is the selected Case config which the topic and category process is driving to.
                // This name of this caseconfig should correspond to the value of
                // either the category or subcategory on the case topic and setting object retrieved based on the user
                // selectsion

                //SK: Adding a null-check to prevent repeated executions of the logic.
                //BW: Added code to re-fire the mycaseconfig when the finalcategory changes
                //	  
					
				
				if(mycaseconfig != null)
					{
						if(mycaseconfig.Final_category_name__c != finalcat)
							{mustReAquire = true;}
					}
               
                if ( myCaseConfig == null || mustReAquire == true) {

                    system.debug('BEGIN MyCaseConfig GET');
                    if(finalcat!=null)
                        {
                            try{
                                    string query = 'Select ';                   
                                    //string mytype = Schema.Sobjecttype.Case.getRecordTypeInfosById().get(mycase.recordtypeid).getname();
                                    query += utility.Editablefields('Routing__c');
                                    query += ', (Select ' + utility.Editablefields('Step__c');
                                    query += ' FROM steps__r '; //where RecordTypeId = \'' + STEP_REC_TYPE_ROUTING_STEP + '\' + 
                                    query += ' Order By Step_number__c ASC LIMIT 1 )';
                                    query += ' FROM Routing__c WHERE Final_Category_Name__c = :finalcat';                                   
                                    routing__c c = database.query(query);
                                     //populate the rendermap values 
                                    step__c currentstep = c.steps__r[0];
                                        if(currentstep !=null)
                                            {	
                                            	mycase.routing__r = c;
                                                mycase.step__r = currentstep;
                                                mycase.step__c = currentstep.id;
                                                for(integer i = 0; i<11; i++)
                                                        {
                                                            string mysection = 'Section ';
                                                            mysection +=i;                                                              
                                                            rendermap.put(mysection,false);
                                                        }
                                                
                                                for(string mysection:currentstep.section_visible__c.split(';'))                                                     
                                                        {
                                                            rendermap.put(mysection,true);
                                                        }
                                            }       				                
                                      system.debug('END MyCaseConfig GET');
                                      mycase.routing__c = c.id;
                                      // Added 5-28 to support REOPEN function BW
                                      if(mycase.previous_step__c == null)
                                      
                                      		{mycase.previous_Step__c = c.steps__r[0].id;}
                                      //return c;
                                      this.mycaseconfig = c;
                                }
                            catch (exception a)
                                {
                                    system.debug('MyCaseConfig EXCEPTION THROWN' + a);
                                    return null;
                                }  
                        }
                    else if(notnew ==true && editconfig !=null)
                        {
                            mycaseconfig = editconfig;
                            mycase.routing__c = mycaseconfig.id;
                            //return mycaseconfig;
                        }
                    else
                        {
                            return null;
                        }
                mustReAquire = false;
                }
                return this.mycaseconfig;
                    
                    
                    
                    
                    
		    }				
		set;}
	public boolean attachmentadded {
		get {
			attachmentadded = numberofattachements < attachments.size();
			return attachmentadded;
			}
		private set;
		}	
	
    public List<CreatePoc.CaseAttachment> attachments {
        get {
        	if ( this.attachments == null) {

                this.attachments = new List<CreatePoc.CaseAttachment>();
                String query = 'SELECT Id, Name, BodyLength, LastModifiedDate, CreatedBy.Name ';
                System.debug('getpagecontext(): ' + getpagecontext());
                if (  getpagecontext() == 'create' ) {
                    query += 
                        'FROM Document ' +
                        'WHERE FolderId = \'' + UserInfo.getUserId() + '\' ' + 
                        	'AND Name LIKE \'CaseCreateTemp_%\'';
                } else {
                    query += 'FROM Attachment WHERE ParentId = \'' + mycase.Id + '\' order by LastModifiedDate desc ';
                }
                System.debug('query: ' + query);
                for ( SObject rec : Database.query(query) ) {
                    this.attachments.add(new CreatePoc.CaseAttachment(rec));
                }
	        }
	        
	        if(numberofattachements == null)
	        	{
	        		this.numberofattachements = attachments.size();
	        	}
	        else if(attachments.size() == 0){ numberofattachements = 0;}	
	        else if(numberofattachements > attachments.size())
	        		{	this.numberofattachements = 0;
	        			getnumberofattachements();}
    	    
    	    return this.attachments;
        }
        set;
    }

public Id deleteAttachmentId { get; set; }

/////////////////////////////////////////////////////////////////////////////////////////////////////////

//constructor
global CreatePOC(ApexPages.StandardController stdController){
    
    system.debug('CreatePOC Constructor Begins');
    caseComment = new CaseComment();
    if(casefields == null)
        {
            string fieldstosplit = utility.Editablefields('Case');
            casefields = fieldstosplit.split(',');
            casefields.add('owner.name');
            casefields.add('owner.type');
        
        }
     
    if(!Test.isRunningTest() && casefields!=null)
        {
            Stdcontroller.addfields(casefields);
        }
    getpagetype();        
    mycase = (Case)stdController.getRecord();    
    this.pagecontext = getpagecontext();
    
    if(pagecontext == 'create' && pagetype == 'Community')
    	{
    		mycase.accountid = [select contact.accountid from user where id = :userinfo.getUserId()].contact.accountid;
    	}
    
    if(pagecontext == 'edit' || pagecontext == 'view')
    	{
    		//BW bug fix 5-7
			string mystepid = mycase.step__c;
			string stepquery = 'Select ' + utility.Editablefields('Step__c') +' FROM Step__c Where id =: mystepid'; 			
			mycase.step__r = database.query(stepquery);
			
			//new function to set up email or comment notification

			
			string regid = mycase.Registration_id__c;
			string regquery = 'SELECT ' + utility.Editablefields('Registration__c')+' FROM Registration__c where id = :regid';
			
			if(regid!= null && regid != '')
				{
					mycase.Registration_id__r = database.query(regquery);
				}
			
    		string prevowner = system.currentpagereference().getParameters().get('prevown');
    		if(prevowner !=null)
    			{
		    		if((prevowner.startswith('005') || prevowner.startswith('00G'))&& prevowner != Userinfo.getUserid()&& mycase.ownerid == userinfo.getuserid())
								 {   
                                    if(prevowner.startswith('005'))
                                    {
                                    user prevuser = [select name, id from user where id = :prevowner];
                                    ownerchange = true;
                                    ownername = prevuser.name;
                                    }
                                    
                                    if(prevowner.startswith('00G'))
                                    {
                                    
                                    ownerchange = true;
                                    ownername = [Select Id, Name, DeveloperName, Type from Group where Type = 'Queue' AND id = :prevowner].developername;
                                    }
                                    ownername = ownername.replace('_', ' ');
                                    
									case casewithowner = [select ownerid, owner.name, id, owner.type from case where id= :mycase.id];
									// notificationmessage = label.Page_Ownership_change;
									// messagetype = 'warning';
									// string errmessage = label.Page_Ownership_change + ' ' ;//+ prevuser.name ;//'WARNING CASE OWNERSHIP was taken from: ' + prevuser.name;
		                             //   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.fatal,errmessage);
		                             //   if(apexPages.hasmessages() == false && userinfo.getusertype() == 'Standard')
		                             //  { ApexPages.addMessage(myMsg); }
								}
					if((prevowner.startswith('005') || prevowner.startswith('00G')) && prevowner != Userinfo.getUserid()&& mycase.ownerid == prevowner)
						{
									if(prevowner.startswith('005'))
                                    {
                                    user prevuser = [select name, id from user where id = :prevowner];
                                    ownereturn = true;
                                    ownername = prevuser.name;
                                    }
                                    
                                    if(prevowner.startswith('00G'))
                                    {
                                    
                                    ownereturn = true;
                                    ownername = [Select Id, Name, DeveloperName, Type from Group where Type = 'Queue' AND id = :prevowner].developername;
                                    
                                    ownername = ownername.replace('_', ' ');
                                    
                                    }
									
						}			
								
				}	
            
            sortField = system.currentpagereference().getParameters().get('sortField'); 
            sortDir = system.currentpagereference().getParameters().get('sortDir');
            pageNo = system.currentpagereference().getParameters().get('pageNo');
    	}
    	
    if(pagecontext == 'view')
    	{
    		string myusertype = userinfo.getusertype();
			if(myusertype == 'Standard')
				{
					if(mycase.New_Internal_Comment__c && mycase.New_Internal_Email__c)
						{
							notificationmessage = system.label.New_Comment_and_email_Message;
							hasnotificationmessage = true;
							messagetype = 'info';
						}
					else
						{
							if(mycase.New_Internal_Comment__c)
								{ 	notificationmessage = system.label.New_comment;
									messagetype = 'info';
									hasnotificationmessage = true;}
							if(mycase.New_Internal_Email__c)
								{notificationmessage = 	system.label.New_Email_Message;
									messagetype = 'info';
									hasnotificationmessage = true;
								}	
						}	
				}
			else
				{
					if(mycase.New_External_Comment__c)
						{
							notificationmessage = system.label.New_comment;
							messagetype = 'info';
							hasnotificationmessage = true;
						}
				}
    	string feedbackmessage = system.currentPageReference().getParameters().get('feedback');
    			if(feedbackmessage != null && feedbackmessage != '')
    				{
    					hasnotificationmessage = true;
    					
    					if(feedbackmessage == 'savesuccess')
    						{
    							notificationmessage = system.label.Case_Saved + mycase.caseNumber ;
    							messagetype = 'success';
    						}
    					if(feedbackMessage == 'submitsuccess')
    						{
    							notificationMessage = system.label.Case_Submitted + mycase.casenumber;
    							messagetype = 'success';
    						}
    					if(feedbackMessage == 'reopensuccess')
    						{
    							notificationMessage = system.label.Case_Reopened + mycase.casenumber;
    							messagetype = 'success';
    						}		
    				}

    	}        
    	
    if(pagecontext == 'create' && mycase.AccountId != null)
    	{CaseType = system.label.Site_ID;
    	 mycase.Test_Center_Name__c = mycase.Accountid;
    	 disablecasetype = DM.myCandObject.hasitems == false && DM.MyRegObject.hasitems == false;
    	}
    	
     if(pagecontext == 'create' && mycase.Registration_id__c != null)
    	{CaseType = System.Label.Registration_id;
    	 
    	 disablecasetype = DM.myCandObject.hasitems == false && DM.MySiteObject.hasitems == false;
    	}
    if(pagecontext == 'create' && mycase.Candidate_id__c != null)
    	{CaseType = system.label.Candidate_Name_pickval;
    	 
    	 disablecasetype = DM.MyRegObject.hasitems == false && DM.MySiteObject.hasitems == false;
    	}
    
    if(pagecontext == 'create' && casetype == null)
    	{
    		if(DM.MySiteObject.hasitems == true)
    			{
    				casetype = System.label.Site_ID;
    				disablecasetype = true;
    			}
    		if(DM.MyRegObject.hasitems == true)
    			{
    				if(casetype == system.label.Site_id)
    					{
    						casetype = system.label.Select_one;
    						disablecasetype = false;
    					}
    				else {
    						casetype = system.label.Registration_Id;
    						disablecasetype = DM.myCandObject.hasitems == false;	
    					}	
    			}	
    	}
    		
    system.debug('url2::'+apexpages.currentpage().getURL());
    system.debug('thiscontext::' + pagecontext);
    getbuttonmap();
    
    if(system.currentPageReference().getParameters().get('editclosed') == 'true')
    	{
	    	string errmessage = Label.Page_Error_Closed_Case;
	                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errmessage);
	                                ApexPages.addMessage(myMsg);
    	}
    
    }
    




    public void clearfinalcat(){
        mycategory= null;
        mycase.recordtypeid = null;	

    }

    public void casetypeCLear(){
        mycategory= null;	
        mycase.Registration_id__c = null;
        mycase.Candidate_id__c = null;
        mycase.Test_Center_Name__c = null;
        EnteredId = null;
      //  sectionToDynamicFieldsMap = new Map<String, List<Schema.FieldSetMember>>();
    }


    public void clearsubcat(){
        mysubcategory= null; 
        mycase.recordtypeid = null;
    }
    


    //SK: Commented out b/c this was not being covered by unit tests
	/*
    public void changemyAccount()
    	{
        
        //  quick POC test to allow a user to re-parent themselves to a new account (test Center) to 
        //  change the context of the community experience
        //  Added by Brian Weers 12-8-14
        
	        user myuser = [select contactid,accountid, id from user where id =: userinfo.getUserId()];
	        contact me = [select accountid, id from contact where id =: myuser.contactid];
	        if(string.valueof(me.accountid).left(15) =='001Q000000tSLmA'){
	        me.accountid = '001Q000000tpKdx';}
	        else
	        me.accountid = '001Q000000tSLmA';       
	        update me;
    	}
	*/


	// SK: We could probably use this one method to replace all getSectionXXFS() methods. If that's not
	//     possible b/c those methods need to be called from VF page, then the getSectionXXFS() methods
	//     could call this method, passing in XX as a parameter
    public List<schema.FieldSetMember> getSectionFS(Integer i) {

        List<schema.FieldSetMember> fsMembers;
        try {
            if ( mycaseconfig != null && mycase !=null ) {
                if ( mycase.id==null && mycase.RecordTypeId == null )  {
                    try {
                        mycase.recordtypeid = 
                            Schema.sObjecttype.Case.getRecordTypeInfosByName().get(
                                mycaseconfig.Case_Record_Type__c).getRecordTypeId();
                       
                    } catch  (Exception e) {
                        System.debug('CreatePOC.getSectionFS(' + i + ') Set Record Type Exception Thrown: ' + e);
                    }
 
					try{
			 				mycase.status = 'Being Created';
	                        if(userinfo.getUserType() == 'Standard')
	                        	{mycase.origin = 'Phone';}
	                        else
	                        	{mycase.origin = 'Service Direct';}
	
	                        mycase.ownerid = userinfo.getUserId();
	                        mycase.status__c = 'Being Created';
	                       // mycase.Priority = 'Medium';
			//  placeholder for setting from routing record   
			//				mycase.Priority = mycaseconfig.Default_Priority__c;
	                        mycase.subject = finalcat;               
						}
					catch  (Exception e) {
                        System.debug('CreatePOC.getsectionFS(' + i + ') Set Fields Exception Thrown: ' + e);
                    }	
                }
                fsMembers = utility.readFieldSet((String) mycaseconfig.get('Section_' + i + '_field_set__c'), 'Case');
            }
		} catch (Exception e) {
            System.debug('CreatePOC.getSectionFS(' + i + ') Exception Thrown: ' + e);
        }
		return fsMembers;
    }

    public List<schema.FieldSetMember> getSection1FS(){
		return getSectionFS(1);
    }

    public List<schema.FieldSetMember> getSection2FS(){
		return getSectionFS(2);
    }

    public List<schema.FieldSetMember> getSection3FS(){
		return getSectionFS(3);
    }

    public List<schema.FieldSetMember> getSection4FS(){
		return getSectionFS(4);
    }

    public List<schema.FieldSetMember> getSection5FS(){
		return getSectionFS(5);
    }

    public List<schema.FieldSetMember> getSection6FS(){
		return getSectionFS(6);
    }

    public List<schema.FieldSetMember> getSection7FS(){
		return getSectionFS(7);
    }

    public List<schema.FieldSetMember> getSection8FS(){
		return getSectionFS(8);
    }

    public List<schema.FieldSetMember> getSection9FS(){
		return getSectionFS(9);
    }

    public List<schema.FieldSetMember> getSection10FS(){
		return getSectionFS(10);
    }

//  which are stored on the Case_and_topic Custom Settings records which is resolved into the Decisionmatrix2 object 


//separate save method which saves the case without any other changes.
 	public pagereference savecase(){
 		
 		system.debug('Start of Savecase() function::');
 		pagereference mypr;
 	 	Case preRoutingCase =  mycase.clone(true, true, true, true);
		actiontype = 'save';
		mycase.status = 'Working';
		mycase.status__c = 'Working';
		if(mycase.AccountId == null && mycase.Test_Center_Name__c != null)
			{mycase.AccountId = mycase.Test_center_Name__c;}

//added BW 8-7 to allow framework to set priority
		if(mycase.priority == null || mycase.priority == '')
			{
				mycase.priority = 'Medium';
				mycase.priority = mycaseconfig.priority__c;
			}
        //add the topic and finalcat

        if(mycase.casemgt_lateral_routing__c == true || manualroute == true)
        	{
        		system.debug('Lateral Routing check::' + mycase.casemgt_lateral_routing__c +' and orign owner check::' + mycase.casemgt_original_owner__c);
    					if(mycase.casemgt_original_Owner__c != null && mycase.casemgt_original_Owner__c == mycase.ownerid)
    						{   							
    							mycase.casemgt_original_Owner__c = null;
    							mycase.casemgt_lateral_routing__c = false;
    							mycase.further_research_required__c = false;
    						}
        	}

	    system.debug('ownerstartswith 005::' + string.valueof(mycase.ownerid).startswith('005'));
        if(!string.valueof(mycase.ownerid).startswith('005'))
        		{
				if(mycase.Casemgt_lateral_routing__c == true && mycase.ownerid != userinfo.getuserid())
					{
						string newowner = [Select Id, Name, DeveloperName, Type from Group where Type = 'Queue' AND name = :mycase.CaseMgt_Delayed_Routing_Name__c].developername;
						string teamname = [select id, who_is_Doing_the_work__c from step__c where id = :mycase.step__c].Who_is_doing_the_Work__c;
						if(newowner == teamname)
							{
								mycase.caseMgt_lateral_routing__c = false;
							}
						if(mycase.step__r.Step_number__c == 1 && teamname.CONTAINS('VSS_') && newowner.contains('VSS_'))
							{
								mycase.Further_research_required__c = false;
								mycase.caseMgt_lateral_routing__c = false;
							}			
						mycase.status = 'Awaiting pickup';
						mycase.status__c = 'Awaiting pickup';
					
					}
        		}
        else{
        		
        		if(mycase.ownerId != userinfo.getuserid())	
	        		{
	        			mycase.status = 'Awaiting pickup';
						mycase.status__c = 'Awaiting pickup';			
	        		}
	        }
		

    	if(mycase.id == null)
        	{
            	mycase.topic__c = mytopic;
            	mycase.category__c = mycategory;
            	mycase.subcategory__c = mysubcategory;
            	
            	mycase.final_category__c = finalcat;
            	                mycase.subject = finalcat;
            	
        	}   
 		if(mycase.step__c == null)
 			{ 				
 				mycase.step__c = mycaseconfig.steps__r[0].id; 				
 			}
 		system.debug('savecase step='+mycase.step__c);
 		system.debug('savecase case='+mycase);
 		     
 		Savepoint presave;
        try{

    		if(caseRegistration != null)
    		{
				if(mycase.Hold_results_when_available__c == false && caseRegistration.exam__r.client__r.Allow_Case_Related_Holds__c == true)
					{
						markHoldFlag();
					}
            }
            processResultHold();

	 		presave =  Database.setSavepoint();
            mycase.Has_Attachment__c = !attachments.isEmpty();
			
			//check added for the delayed routing process.  when a save or submit happens, the case owner is updated to the selected value
			if(mycase.CaseMgt_Delayed_Routing__c == true){
				mycase.ownerid = mycase.CaseMgt_Delayed_Routing_Id__c;
				mycase.status = 'Awaiting pickup';
				mycase.status__c = 'Awaiting pickup';
				mycase.CaseMgt_delayed_routing__c = false;
				mycase.CaseMgt_Delayed_routing_id__c = null;
				mycase.casemgt_delayed_routing_name__c = null;
			}
			
			system.debug('copy of case='+mycase);
            upsert(mycase);

            attachKnowledgeArticles();
            convertDocAttachments();
            mypr = new pagereference('/'+mycase.id);
            mypr.getParameters().put('feedback', 'savesuccess');
        }
        Catch(exception submitcase_Exception)
        {   
            if ( presave != null ) {
            	Database.rollback(presave);
            }
            rollbackCaseRouting(mycase, preRoutingCase);

            system.debug('CreatePOC.submitcase() Exception:' + submitcase_exception);
            string errmessage = 'Error Processing: '+ submitcase_exception.getmessage() +
                                            '  Please try again, if you continue to receive this message, Please contact your Salesforce Administrator';
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errmessage);
                                ApexPages.addMessage(myMsg); 
        }
        system.debug('END Of SaveCase method::');
        return mypr;
    }
	public pageReference Manual_route(){		
		pagereference mypr;
		
 	 	Case preRoutingCase =  mycase.clone(true, true, true, true);
        //add the topic and finalcat
 		     
 		Savepoint presave;
        try{
			if(caseRegistration != null)
    		{
				if(mycase.Hold_results_when_available__c == false && caseRegistration.exam__r.client__r.Allow_Case_Related_Holds__c == true)
					{
						markHoldFlag();
					}
			}
            processResultHold();

	 		presave =  Database.setSavepoint();
            mycase.Has_Attachment__c = !attachments.isEmpty();

				string newowner = [Select Id, Name, DeveloperName, Type from Group where Type = 'Queue' AND name = :mycase.CaseMgt_Delayed_Routing_Name__c].developername;
				string teamname = [select id, who_is_Doing_the_work__c from step__c where id = :mycase.step__c].Who_is_doing_the_Work__c;
				if(newowner == teamname)
					{
						mycase.caseMgt_lateral_routing__c = false;
					}		
				mycase.status = 'Awaiting pickup';
				mycase.status__c = 'Awaiting pickup';
			
			system.debug('copy of case='+mycase);
            update(mycase);

            attachKnowledgeArticles();
            convertDocAttachments();
            mypr = new pagereference('/'+mycase.id);
        }
        Catch(exception submitcase_Exception)
        {   
            if ( presave != null ) {
            	Database.rollback(presave);
            }
            rollbackCaseRouting(mycase, preRoutingCase);

            system.debug('CreatePOC.submitcase() Exception:' + submitcase_exception);
            string errmessage = System.Label.Error_Processing + submitcase_exception.getmessage() ;
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errmessage);
                                ApexPages.addMessage(myMsg); 
        }

        return mypr;
	}


//separate save/update method in order to invoke the DMLOptions for the reocrd.
    public PageReference submitcase() {

    	interruptsave = false;
    	notificationmessage = null;
    	hasnotificationmessage = null;
    	messagetype = null;
        List<String> fieldsToRollback = new List<String>{'Is_Submitted__c', 'Step__c', '', ''};
      	Case preRoutingCase =  mycase.clone(true, true, true, true);
		actiontype = 'submit';
        //add the topic and finalcat
    	if(mycase.id == null)
        	{
            	mycase.topic__c = mytopic;
            	mycase.category__c = mycategory;
            	mycase.subcategory__c = mysubcategory;
            	mycase.subject = finalcat;
            	mycase.final_category__c = finalcat;
        	}
        if(mycase.AccountId == null && mycase.Test_Center_Name__c != null)
			{mycase.AccountId = mycase.Test_center_Name__c;}	   
        mycase.Has_Attachment__c = !attachments.isEmpty();
        mycase.Is_Submitted__c = true;
        
        		if(mycase.priority == null || mycase.priority == '')
			{
				mycase.priority = 'Medium';
				mycase.priority = mycaseconfig.priority__c;
			}

        
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
     	// code removed by Brian Weers 3-10-15.  New requirement one button for save, one automatically moves the case forward.
       // if(mycase.status__c == 'Being Created' || mycase.status__c == 'Move to next step')
         //   {
              //	step__c currentstep = new step__c();
              //  step__c nextstep = new step__c();
              //  routing_logic__c selectedlogic = new routing_logic__c();
                
		//consolidate the editconfig and mycaseconfig to a single token for the routing__c records
                


              //  currentstep = mycaseconfig.steps__r[0];
                
               
                
       /*      ************************************************************************************************************************************
       		   *************   SECTION ELIMINATED and replaced by utility class to get next step before the SUBMIT sequence begins  ***************
			   ************************************************************************************************************************************       		
       
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
                                    	//AND RecordTypeId = :STEP_REC_TYPE_ROUTING_STEP]; 
                        mycase.step__c = nextstep.id;
                  	  }      */   
            
            
           // nextstep = utility.getnextstep(mycase,currentstep) ;               
                           
		//	mycase.step__r = nextstep;
			nextstep = utility.getnextstep(mycase, mycaseconfig.steps__r[0]);
			
		    system.debug('next Step =' + nextstep); 
            if(nextstep!=null)
				{   
					if(nextstep.id == mycase.step__c)
						{
							interruptsave = true;
							notificationmessage = mycase.notification_message__c;
							mycase.notification_Message__c = null;
							messagetype = 'warning';
							hasnotificationmessage = true;
						}
					else
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
                            string errmessage = system.label.Error_Processing+ newownerexception.getmessage() ;
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errmessage);
                                ApexPages.addMessage(myMsg); 
                                mycase.step__c = preRoutingCase.step__c;
                            
                        }
                    }        
                }     
    // test for status removed by Brian Weers.  See above        
    //	} 

//END Step Assignment and routing setup
// --------------------------------------------------------------------------------------------------       
        
        
 
 
        Savepoint presave;
        pagereference mypr;
        	if(interruptsave != true)
        		{
		        try{
	        		if(caseRegistration != null)
    				{
						if(mycase.Hold_results_when_available__c == false && caseRegistration.exam__r.client__r.Allow_Case_Related_Holds__c == true)
							{
								markHoldFlag();
							}
					}
		            processResultHold();

		            presave =  Database.setSavepoint();
		            Database.DMLOptions dml = new Database.DMLOptions();
		            dml.assignmentRuleHeader.useDefaultRule = true;         
		            
		            mycase.setOptions(dml);


		            upsert(mycase);

		            system.debug('AZ:: mycase ' + mycase.Id);
		            attachKnowledgeArticles();
		            convertDocAttachments();
		            mypr = new pagereference('/'+mycase.id);
		            mypr.getparameters().put('feedback', 'submitsuccess');
		        }
		        Catch(exception submitcase_Exception)
		        {   
		            if ( presave != null ) {
		            	Database.rollback(presave);
		            }
		            rollbackCaseRouting(mycase, preRoutingCase);

		            system.debug('CreatePOC.submitcase() Exception:' + submitcase_exception);
		            system.debug(' CreatePOC.submitcase() getLineNumber ' + submitcase_exception.getLineNumber() );
		            system.debug(' CreatePOC.submitcase() getCause ' + submitcase_exception.getCause() );
		            //string errmessage = System.label.Error_processing+ submitcase_exception.getmessage() ;
		            //                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errmessage);
		            //                    ApexPages.addMessage(myMsg);
		            warningmessage = submitcase_Exception.getMessage();
		            warningmessage = warningmessage.substringafterlast(',');
		            warningmessage = warningmessage.Substringbefore(':');
		            messagetype = 'warning';
		            haswarningmessage = true; 
		        }
    		}
    	else
    		{
    			mypr = system.currentPageReference();
    		}	
        return mypr;
    }

	public pagereference cancelmodal(){
		string stepId =mycaseconfig.steps__r[0].id;
		//string previous_step_query = 'SELECT '+ utility.editablefields('Step__c') + ' FROM Step__c where id = :stepid';
		mycase.step__r = mycaseconfig.steps__r[0];
		mycase.ownerid = userinfo.getuserid();		
		mustreaquire=true;
		
		
		return null;
	}
	
	private void markHoldFlag(){
		Case_Related_Hold_Configuration__c casehold = new Case_Related_Hold_Configuration__c();
		
		if(mycase.Routing__r.All_clients_results_holds__c == 'No')
			{
				casehold = [SELECT Client__c, Case_Type__c, Client__r.Result_hold_categories__c
			    	FROM Case_related_hold_Configuration__c WHERE Case_type__c = :mycase.Routing__c AND Client__c = :mycase.Client_id__c AND Results_Hold__c = 'Yes'];
			    if(casehold.results_hold__c == 'Yes')
			    	{	
						mycase.Hold_results_when_available__c = true;
			    	}
			}
			
		if(mycase.Routing__r.All_clients_results_holds__c == 'Yes')
			{
				boolean holdresults = true;
				for(Case_related_hold_Configuration__c each:[SELECT Client__c, Case_Type__c, Client__r.Result_hold_categories__c
			    	FROM Case_related_hold_Configuration__c WHERE Case_type__c = :mycase.Routing__c AND Client__c = :mycase.Client_id__c AND Results_Hold__c = 'No'])
					{			
						holdresults = false;
					}
			
				mycase.Hold_results_when_available__c	= holdresults;
			
			}	
			    	
		
	}
	
	
	
    private void processResultHold() {
        //System.debug('Result_hold_categories__c: ' + caseRegistration.Exam__r.Client__r.Result_hold_categories__c);
        System.debug('finalcat: ' + finalcat);
        // Check if creation of this case should result in Result Hold creation in VTS
		user u = [select username, id, vts_Agent_id__c from user where id = :Userinfo.getUserId()];    
    	//BW change to match many to many configuration for holds
    	if(mycase.Client_id__c != null && mycase.Registration_id__c != null && mycase.VTS_Hold_ID__c==null)
    		{
    		try{	
			    if(mycase.Routing__r.All_clients_results_holds__c == 'No' && mycase.Registration_id__r.Process_state_Code__c != null) 
			    	{
			    		Case_Related_Hold_Configuration__c casehold = [SELECT Client__c, Case_Type__c, Client__r.Result_hold_categories__c
			    				FROM Case_related_hold_Configuration__c WHERE Case_type__c = :mycase.Routing__c AND Client__c = :mycase.Client_id__c AND Results_Hold__c = 'Yes'];
			    		if(casehold.client__r.Result_hold_categories__c.contains(mycase.Registration_id__r.Process_State_Code__c))
			    			{
			    				VTS_Hold hold = new DaoFactory().getEsbDao().createResultHold(caseRegistration.VTS_Registration_ID__c.longValue(), mycase.final_category__c,'IncidentHold', decimal.valueof(u.VTS_Agent_ID__c).longvalue());
			            mycase.VTS_Hold_ID__c = hold.id;
			    			}
			    
			    	}
			    system.debug('type::'+ mycase.Routing__r.Case_related_holds_type__c);
			    system.debug('process_state_code::' + mycase.Registration_id__r.Process_state_code__c);
			    if(mycase.Routing__r.All_clients_results_holds__c == 'Yes'  && mycase.Registration_id__r.Process_state_Code__c != null)
			    	{
			    		system.debug('ALL Clients ResultHold loop::' );
			    		account Case_client = new Account();
			    	try{
			    		Case_Client = [SELECT id, Allow_Case_Related_Holds__c, Result_hold_categories__c
							FROM Account WHERE Allow_case_related_holds__c = true AND Id = :mycase.Client_id__c];
						system.debug('Testvalue::' + Case_Client.Result_hold_categories__c.contains(mycase.Registration_id__r.Process_State_Code__c))	;
						
			    	}
			    	catch(system.queryexception a){ system.debug('no client found');}
						
							Case_Related_Hold_Configuration__c casehold = new case_related_hold_configuration__c();
							Try{
								casehold =[SELECT Client__c, Case_Type__c, Results_Hold__c
			    					FROM Case_related_hold_Configuration__c WHERE Case_type__c = :mycase.Routing__c AND Client__c = :mycase.Client_id__c AND Results_Hold__c = 'No'];
								}
							catch (System.queryexception a) 
								{
									system.debug ('no over-rides found::');
								}
							
							if(Case_Client.Result_hold_categories__c.contains(mycase.Registration_id__r.Process_State_Code__c) && casehold.Results_Hold__c != 'No')
			    				if(Case_Client.Result_hold_categories__c.contains(mycase.Registration_id__r.Process_State_Code__c) && casehold.Results_Hold__c != 'No')
				    				{
				    					system.debug('ready to try hold');
										VTS_Hold hold = new DaoFactory().getEsbDao().createResultHold(caseRegistration.VTS_Registration_ID__c.longValue(), mycase.final_category__c, 'IncidentHold', null);
					   	 				mycase.VTS_Hold_ID__c = hold.id;
				    				}		
			    			 		
			    	}
    			}
    		catch (exception Result_related_hold_exception) {system.debug('Process_Result_hold Exception Thrown::' + Result_related_hold_exception); }	
    			
    		}		
 /*   
        if ( mycase.Id == null && caseRegistration != null && caseRegistration.Exam__r.Client__r.Result_hold_categories__c != null && 
     	       caseRegistration.Exam__r.Client__r.Result_hold_categories__c.contains(finalcat) ) {
            VTS_Hold hold = 
                new DaoFactory().getEsbDao().createIncidentResultHold(caseRegistration.VTS_Registration_ID__c.longValue(), finalcat);
            mycase.VTS_Hold_ID__c = hold.id;
        }
*/        
    }
    private void rollbackCaseRouting(Case currentCase, Case presaveCase) {

        List<String> fieldsToRollback = new List<String>{'OwnerId', 'Step__c', 'Status', 'Status__c'};
		for ( String fldName : fieldsToRollback ) {
            currentCase.put(fldName, presaveCase.get(fldName));
        }
    }
	
    private void attachKnowledgeArticles() {

        System.debug('selKnowledgeArticleIds: ' + selKnowledgeArticleIds);
        if ( !String.isBlank(selKnowledgeArticleIds) ) {
            
            List<ID> articleIds = selKnowledgeArticleIds.removeEnd(',').split(',');
            if ( !articleIds.isEmpty() ) {
                List<CaseArticle> attachedArticles = new List<CaseArticle>();
                for ( ID articleId : articleIds ) {
                    attachedArticles.add(new CaseArticle(CaseId = mycase.Id, KnowledgeArticleId = articleId));
                }
                insert attachedArticles;
            }
        }

    }

    private void convertDocAttachments() {

        //if case is successfully inserted
        //Insert attachment on case
        if ( this.pagecontext == 'create' && mycase != null ) {
            
            List<ID> caseAttachmentDocIds = new List<ID>();
            for ( CreatePoc.CaseAttachment caseAtt : this.attachments ) {
                caseAttachmentDocIds.add(caseAtt.record.Id);
            }
            
            List<Document> attachmentDocs = 
                [SELECT Name, Body from Document where FolderId = :UserInfo.getUserId() AND Name LIKE 'CaseCreateTemp_%'];
            List<Attachment> caseAttachments = new List<Attachment>();
            for ( Document doc : attachmentDocs ) {
                Attachment att = new Attachment();
                att.Name = doc.Name.substring(15, doc.Name.length());
                att.ParentId = mycase.Id;
                att.Body = doc.Body;
                caseAttachments.add(att);
            }
            if(caseAttachments != null && caseAttachments.size() > 0){
                insert caseAttachments;
            }
            delete attachmentDocs;
        }

    }


// this action is called by actionsupport.  the search is executed for the user when they change the data in the "EnteredId" field
//      which is an <apex:inputText> field that ties to the EnteredId string in this controller
//      if the casetype is Reg, an API call is invoked to get additional data
//      if the casetype is Site, a search for test center is executed to retrieve the test center by VTS_Test_Center_ID__c
  	public boolean showSiteIdError { get; set; }
    public void Retrieve_Reg_or_Site() {
    
        System.debug('BEGIN CreatePOC.Retrieve_reg_or_Site Casetype = ' + Casetype);    
        //-----initialy set them to null to clear the previous searched data---//
        mycase.Registration_id__c = null;
        mycase.Test_Center_Name__c = null;
        mycase.AccountId = null;
        mycase.Candidate_id__c = null;
        
        
        showSiteIdError = false;
        if(Casetype !=null && EnteredId !=null && EnteredId!='')
        {
            
            
            if(Casetype == system.label.site_id)
                {
                        typeahead = null;
                        mycase.accountId = null;
                        mycase.Test_center_name__c = null;
                        mycase.registration_id__c = null;                       
                        mycase.Exam_id__c = null;
                        mycase.Candidate_id__c = null;
                    Try
                        { 
                            List<account> tempaccount = [SELECT id, name, test_Center_location__c, VTS_Test_Center_ID__c, Channel_Type__c FROM account 
                                            WHERE VTS_Test_Center_ID__c = :decimal.ValueOf(EnteredId)];
                            showSiteIdError = tempaccount.size() <= 0 ? true : false;
                            
                            if(tempaccount.size()>0)
                            {
                                mycase.test_center_name__r = tempaccount[0];
                                mycase.test_center_name__c = tempaccount[0].id;
                                mycase.AccountId = tempaccount[0].id;
                                mycase.Account = tempaccount[0]; 
                                mycase.test_center_name__c = tempaccount[0].id;             
                                sitelocation = tempaccount[0].test_center_location__c;  
                                    sitename = tempaccount[0].name;  
                                mycase.site_name_Static__c = tempaccount[0].name;
                                mycase.site_type_static__c = tempaccount[0].channel_type__c;      
                            }       
                        }
                    Catch (exception retrieveTestCenter)
                        {
                            system.debug('Retrieve AccountId exception thrown:' + retrieveTestCenter);
                           showSiteIdError = true;
            				 
                        }                       
                                    
                }
            
            if(casetype == system.label.Registration_ID || casetype == system.label.Candidate_Name_pickval)
                {   
                	
                	if(casetype == system.label.Registration_ID)
                		{
	                    Try{
	                        
	                        VTS_Registration RegistrationDao = dao.getRegistrationByRegistrationId(decimal.ValueOf(EnteredId).longValue());
	                       // VTSPersistenceUtility p = new VTSPersistenceUtility();
	                        
	                        //Backup Client ID to restore after it is overwritten by Get Candidate details call
	                        Long clientId = RegistrationDao.candidate.clientId;
	        
	                        //SK: [PSNVSC-2798] - Get the latest, complete details of the Candidate from VTS
	                        RegistrationDao.candidate = dao.getCandidateByCandidateId(RegistrationDao.candidate.id);
	                        //Restore Client ID from backup
	                        System.debug('Registration::' + RegistrationDao);
	                        RegistrationDao.candidate.clientId = clientId;
	        
	                        
	                    //insert records returned by API call to Reg endpoint.  keep ids for assignment to the case 
	
	                    utility.CommitRegistration(mycase,RegistrationDao);
	         
	                        }
	                    Catch(Exception DAO_Call)
	                    
	                        {
 	                            showSiteIdError = true;
	                            System.debug('DAOCallout Exception Thrown' + DAO_Call + DAO_Call.getLineNumber());
											
	                        }   
                		}
                	if(casetype == system.label.Candidate_Name_pickval)
                		{
                			Try{
		                			VTS_Candidate mycandidate = dao.getCandidateByCandidateId(decimal.valueof(enteredId).longvalue());
		                			
                				//call to utility class to save upsert the record and set the static fields for case
		                			if(mycandidate != null)
		                				{
                                            utility.CommitCandidate(mycase, mycandidate);
											system.debug('candidate added::' + mycase.candidate_id__r);
		                					system.debug('candidate with case::' + mycase.Candidate_id__c);	
		                				}
	                			}
                			Catch(Exception DAO_Call)
	                    
	                        {
	                            showSiteIdError = true;
	                            System.debug('DAOCallout Exception Thrown' + DAO_Call + DAO_Call.getLineNumber());
												
	                        }   
                		}	
                }
    
            
            
                
        }
      
      	else 
      		{
      			if( EnteredId == null || EnteredId == '' )
      				{
      					mycase.Registration_id__c = null;
      					mycase.Test_Center_Name__c = null;
      					mycase.AccountId = null;
      					mycase.Candidate_id__c = null;
      				}
      		}		
        System.debug('END CreatePOC.Retrieve_reg_or_Site Casetype=' + Casetype + ' and Case=' + mycase);                
    }
    public void AttachRegistration()
    {
        System.debug('BEGIN CreatePOC.AttachRegistration : id'+RegistrationID);    
        //if(casetype == 'Registration ID' || casetype == 'Candidate' || casetype == 'Software')
          //      {   
                    Try{
                        
                        VTS_Registration RegistrationDao = dao.getRegistrationByRegistrationId(decimal.ValueOf(RegistrationID).longValue());
                       // VTSPersistenceUtility p = new VTSPersistenceUtility();
                        
                        //Backup Client ID to restore after it is overwritten by Get Candidate details call
                        Long clientId = RegistrationDao.candidate.clientId;
        
                        //SK: [PSNVSC-2798] - Get the latest, complete details of the Candidate from VTS
                        RegistrationDao.candidate = dao.getCandidateByCandidateId(RegistrationDao.candidate.id);
                        //Restore Client ID from backup
                        RegistrationDao.candidate.clientId = clientId;
                        
                        
                        
                    //insert records returned by API call to Reg endpoint.  keep ids for assignment to the case 
                    utility.CommitRegistration(mycase,RegistrationDao);
                    
                    /*    Account mytestcenter = p.upsertTestCenter(registrationDao.testCenter);
                        Candidate__c RegCandidate = p.upsertCandidate(RegistrationDao.Candidate);
                        Exam__c relatedexam = p.upsertExam(RegistrationDao.exam, RegistrationDao.candidate.clientId);
                        Registration__c relatedReg = p.upsertRegistration(RegistrationDao);
                        mycase.Registration_id__c = relatedReg.id;
                        system.debug(relatedReg);
                        mycase.Exam_id__c = relatedexam.id;
                        mycase.Candidate_id__c = RegCandidate.id;
                        sitelocation = mytestcenter.test_center_location__c;  
                        sitename = mytestcenter.name; 
                        candidatename = regCandidate.First_Name__c + regCandidate.Last_name__c;
                    */    
                        }
                    Catch(Exception DAO_Call)
                    
                        {
                           
                            System.debug('DAOCall Exception Thrown' + DAO_Call);
											string errmessage = system.label.Search_error +
											DAO_Call.getmessage();
											ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errmessage);
											ApexPages.addMessage(myMsg);
                        }   
         System.debug('END CreatePOC.AttachRegistration  Case=' + mycase); 
        
    }

	public void AttachCandidate(){
			system.debug('Start AttachCandidate:: ' + selectedCandidate);
		Try{	
				if(selectedCandidate2!= null && selectedCandidate2 != '' &&(SelectedCandidate == null || selectedCandidate ==''))
					{SelectedCandidate = SelectedCandidate2;}

				VTS_Registration RegistrationDao = dao.getRegistrationByRegistrationId(decimal.ValueOf(selectedCandidate).longValue());

            	//Backup Client ID to restore after it is overwritten by Get Candidate details call
            	Long clientId = RegistrationDao.candidate.clientId;

            	//SK: [PSNVSC-2798] - Get the latest, complete details of the Candidate from VTS
				RegistrationDao.candidate = dao.getCandidateByCandidateId(RegistrationDao.candidate.id);
            	//Restore Client ID from backup
            	RegistrationDao.candidate.clientId = clientId;

            	System.debug('RegistrationDao.candidate: ' + RegistrationDao.candidate);
				  utility.CommitRegistration(mycase,RegistrationDao);
				  
				  //create a select option to assign to SelectedCandidate
				 selectedCandidate = string.valueof(RegistrationDao.id); 			
				  
				  
			}

		Catch(Exception DAO_Call)                   
            {
               
                System.debug('DAOCall Exception Thrown' + DAO_Call + DAO_Call.getLineNumber());
								string errmessage = System.label.Search_error+
								DAO_Call.getmessage();
								ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errmessage);
								ApexPages.addMessage(myMsg);
            }   
	
	
	}


	// new separated utility to commit a VTS_Registration to the database and attach to the case


// this section of code includes the getters which resolve the items from the Decisionmatrix2 object into dynamic
//picklists which are animated via the ajax toolkit


    public list<selectOption>getItems(){
        return null;
    }
    public list<selectOption>getTopics(){
        
        system.debug('BEGIN CreatePOC.getTopics()');
        
        if(DM==null)
            {
                // string persona = [select name, id from profile where id=:userinfo.getProfileId()].name;
                 string persona = [select name, id, Primary_team_persona__c from user where id = :userinfo.getUserId()].Primary_team_persona__c;	                       
                this.DM = new Decisionmatrix2(persona);
            }
        if(pagetype == null){
            getpagetype();
        }
        
        Set<selectOption> mytopics = new set<selectOption>();
        
	
	        if(casetype == System.label.Site_id || pagetype == 'Community')
	            { 
	                for(string eachtopic:DM.MySiteObject.sitemap.keyset())          
	                    {
	                        SelectOption thistopic = new SelectOption(eachtopic,eachtopic);
	                        mytopics.add(thistopic);
	                    }
	                
	            }
	        else 
	        if(casetype == system.label.registration_id || pagetype == 'Community')          
	            {
	                for(string eachtopic:DM.MyRegObject.Regmap.keyset())                
	                    {
	                        SelectOption thistopic = new SelectOption(eachtopic,eachtopic);
	                        mytopics.add(thistopic);
	                    }           
	            }
			else 
	        if(casetype == system.label.Candidate_Name_pickval)          
	            {
	                for(string eachtopic:DM.MyCandObject.Candmap.keyset())                
	                    {
	                        SelectOption thistopic = new SelectOption(eachtopic,eachtopic);
	                        mytopics.add(thistopic);
	                    }           
	            }
    		else if(casetype == '' || casetype == System.label.Select_one)
				{   
					 selectOption Pleaseselect = new selectoption('',System.label.Select_one);
					 mytopics.add(Pleaseselect);
				} 
	        	       
	        
	        list<selectOption> topics = new list<selectOption>();
	        topics.addall(mytopics);    
	        topics.sort();
	        try{
	        		topics.add(0,Decisionmatrix2.pleaseselect);
	        	}
	        catch(system.listexception topiclistexception)
	        	{
	        		string errmessage = System.label.Error_processing;
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errmessage);
                                ApexPages.addMessage(myMsg);
	        	}
	        system.debug('END CreatePOC.getTopics()'+pagetype+topics);
	        return topics;
	    }
    	

    
    public list<selectOption> getcategories(){
    
        system.debug('BEGIN CreatePOC.getCategories()');
    
        if(DM == null )
            {
               // string persona = [select name, id from profile where id=:userinfo.getProfileId()].name;
                 string persona = [select name, id, Primary_team_persona__c from user where id = :userinfo.getUserId()].Primary_team_persona__c;
	                       
                this.DM = new Decisionmatrix2(persona);
            }
        if(pagetype == null){
            getpagetype();
        }
        set<selectoption>mycategories = new set<selectoption>();        
        
        
		        if((Casetype == system.label.site_id || pagetype == 'Community') && notnew == false) 
		            {
		                Try{            
		                    for(Decisionmatrix2.CategoryObject eachCategoryObject: DM.MySiteObject.Sitemap.get(mytopic)) 
		                        {
		                            if(eachCategoryObject.sitecase || pagetype == 'Community')
		                                {
		                                    mycategories.add(eachCategoryObject.Categoryoption);
		                                    if(eachCategoryObject.has_subcategories)
		                                        {
		                                            catwithsubcat.add(eachCategoryObject.Categoryoption.getvalue());
		                                        }
		                                }
		                        CategoryObjectmap.put(eachCategoryObject.Categoryoption.getvalue(),eachCategoryObject);
		                        }
		                    
		                    }
		        
		                Catch(exception getCategoriesException)
		                    {
		                    system.debug('CreatePOC.getCategories() Site Case Exception Thrown:' + getCategoriesException);
		                    }   
		            }
		
		        else if((CaseType == system.label.registration_id || pagetype == 'Community') && notnew == false)
		            {
		                Try{
		                    {
		                    for(Decisionmatrix2.CategoryObject eachCategoryObject: DM.MyRegObject.Regmap.get(mytopic)) 
		                        {
		                            if(eachCategoryObject.Regcase || pagetype == 'Community')
		                                {
		                                    mycategories.add(eachCategoryObject.Categoryoption);
		                                    if(eachCategoryObject.has_subcategories)
		                                        {
		                                            catwithsubcat.add(eachCategoryObject.Categoryoption.getvalue());
		                                        }
		                                }
		                        CategoryObjectmap.put(eachCategoryObject.Categoryoption.getvalue(),eachCategoryObject);
		                        }
		                    }
		                }   
		                Catch(System.NullPointerException getCategoriesException)
		                {
		                    system.debug('CreatePOC.getCategories() Registration Case Exception Thrown:' + getCategoriesException);             
		                }   
		
		            }
		        else if((CaseType == system.label.Candidate_Name_pickval ) && notnew == false)
		            {
		                Try{
		                    {
		                    for(Decisionmatrix2.CategoryObject eachCategoryObject: DM.MyRegObject.Regmap.get(mytopic)) 
		                        {
		                            if(eachCategoryObject.Candcase || pagetype == 'Community')
		                                {
		                                    mycategories.add(eachCategoryObject.Categoryoption);
		                                    if(eachCategoryObject.has_subcategories)
		                                        {
		                                            catwithsubcat.add(eachCategoryObject.Categoryoption.getvalue());
		                                        }
		                                }
		                        CategoryObjectmap.put(eachCategoryObject.Categoryoption.getvalue(),eachCategoryObject);
		                        }
		                    }
		                }   
		                Catch(System.NullPointerException getCategoriesException)
		                {
		                    system.debug('CreatePOC.getCategories() Registration Case Exception Thrown:' + getCategoriesException);             
		                }   
		
		            }    
		        else if(casetype == '' || casetype == 'Select one')
        			{   
        				 selectOption Pleaseselect = new selectoption('','Select one');
        				 mycategories.add(Pleaseselect);
        			} 
		
		        list<SelectOption> categories = new list<SelectOption>();   
		        categories.addall(mycategories);
		        categories.sort();
		            //try catch loop because the list 0 is out of bounds before the user selects an option
		        try
		            {
		                categories.add(0,Decisionmatrix2.pleaseselect);
		            }
		        catch(system.listexception categoriesListexception)
		            {
		                categories.add(Decisionmatrix2.pleaseselect);
		            }   
		        system.debug('END CreatePOC.getCategories()'+pagetype+categories);      
		        return categories;
        }       




    public list<selectOption>getsubcategories(){

        system.debug('BEGIN CreatePOC.getsubCategories()');

        list<selectOption>subcategories = new list<selectOption>();
        if(mycategory!=null)
            {
                Decisionmatrix2.categoryObject SelectedCategoryObject = CategoryObjectMap.get(mycategory);
                if(SelectedCategoryObject!=null)
                    {
                        if(SelectedCategoryObject.has_subcategories==true)
                            { 
                                subcategories.addall(SelectedCategoryObject.subcategories);
                                subcategories.sort();
                                
                                //try catch loop because the list 0 is out of bounds before the user selects an option
                                        try
                                            {
                                                subcategories.add(0,Decisionmatrix2.pleaseselect);
                                            }
                                        catch(system.listexception categoriesListexception)
                                            {
                                                subcategories.add(Decisionmatrix2.pleaseselect);
                                                return null;
                                            }   
                                
                                system.debug('END CreatePOC.getsubCategories()');           
                                return subcategories;
                            }
                    }
            }                       
        else
            system.debug('CreatePOC.getCategories() myCategory == NULL');
            return null;
    }
    

    public List<EmailMessage> getEmailMessages() {

        List<EmailMessage> emails;
        if ( mycase.Id != null ) {
            String query = 
                'SELECT ' + utility.Editablefields('EmailMessage') +
                ' FROM EmailMessage ' +
                ' WHERE ParentId = \'' + mycase.Id + '\'' +
                ' ORDER BY MessageDate DESC';
            emails = Database.query(query);
        }
        if(emails != null)
        {
	        if(numberofemails == 0)
	        	{numberofemails = emails.size();}
	        
	        if(numberofemails < emails.size())
        		{emailadded = true;}
    	}	
        return emails;
    }

//this is the end of the section of code which builds out the picklists
//the next section has the getters and setters to capture the users selections from these picklists
//and parses the url string to determine what kind of page your dealing with

 public string getpagetype()
        {           
             if(userinfo.getUserType() =='Standard')           	 
            		{ pagetype = 'Console'; }
            else
	                {pagetype = 'Community';}                        
            
            return pagetype;                            
        }

    public void setpagetype(string pagetype){
            this.pagetype = pagetype;}  
//getters and setters for page selections for case topic and catergory and subcategory
    public string getmysubcategory(){
        return mysubcategory;
    }
    
    public void setmysubcategory(string subcategory){
        this.mysubcategory = subcategory;
    }

    public String getmyTopic() {
        return mytopic;
    }


	public void takeownership()
		{
			if(pagecontext == null)
				{getpagecontext();}
				system.debug('takeownership: ' + pagecontext);
			if(pagecontext == 'edit')
				{	
					case casewithowner = [select ownerid, status, status__c, owner.name, id, owner.type from case where id= :mycase.id];
					system.debug('casewithowner= ' + casewithowner);
					mycase.Previous_Step__c = mycase.Step__c;
					
			//		if(casewithowner.owner.type  == 'Queue')  //BW Removed test for owner type based on 3/16 meeting with Pearson
			
					if(mycase.ownerid != Userinfo.getUserId())
						{
							previousowner = casewithowner.ownerid;
							previousstatus = casewithowner.status__c;	
							mycase.ownerid = system.Userinfo.getUserId();
							mycase.status = 'Working';
							mycase.status__c = 'Working';
							
						}
					system.debug('previousowner::' + previousowner);
					system.debug('prestatus::' + previousstatus);	
					if(userinfo.getUserType()=='Standard')
						{
							mycase.new_internal_comment__c = false;
							mycase.new_internal_email__c = false;
							mycase.last_internal_edit__c = system.now();
						}	
					else
						{
							mycase.last_external_edit__c = system.now();	
							mycase.new_external_comment__c = false;
							mycase.new_external_email__c = false;	
						}	
					update(mycase);
				}
		}

	public pageReference communityToCases(){
		pagereference pr = page.custom_case_listview;
		pr.getParameters().put('sourcepage', system.currentpagereference().getParameters().get('sourcepage'));
		// possibly add parameter to add closed cases id to set listview
		
		return pr;
	}

    public PageReference deleteCase(){

        delete mycase;
        pagereference pr;
        
        if( Userinfo.getUserType() == 'Standard' ) {
			pr = new pagereference('/500');
        }else{
        	pr = page.custom_case_listview;
        }

        pr.getparameters().put('feedback' ,'caseDeleted');
        pr.getparameters().put('deletedCaseNo', mycase.caseNumber );

        //SK: Added 
        List<CustomListView__c> listView = [select Id from CustomListView__c where List_View_Name__c = 'My open cases'];
        if ( !listView.isEmpty() ) {
        	pr.getparameters().put('sourcepage', listView[0].Id);
        }

        return pr; //new PageReference('/500?caseDeleted=true');
    }

    public void setmyTopic(String mytopic) {
        this.mytopic = mytopic;
    }

    public string getmyCategory(){
        return myCategory;
    }

    public void setmyCategory(string mycategory){
        this.mycategory = mycategory;       
    }
//end of getters and setters for capturing the user input for topic, category, casetype etc.
	public void setValueToRegistrationID(){
       
       RegistrationID = EncodingUtil.urlDecode( RegistrationID , 'UTF-8');
        AttachRegistration();
    }

    public ID getCaseId() {
        return mycase.id;
    }
    /*
    @remoteAction
	global static string UpsertReg(string VTS_Reg_id)
	{
		 DAOFactory d = new DAOFactory();
    	 ESBDao dao = d.getEsbDao();
		 VTSPersistenceUtility p = new VTSPersistenceUtility();
         
         VTS_Registration RegistrationDao = dao.getRegistrationByRegistrationId(decimal.ValueOf(VTS_Reg_id).longValue());               
                        
        //insert records returned by API call to Reg endpoint.  keep ids for assignment to the case 
            Account mytestcenter = p.upsertTestCenter(RegistrationDao.testCenter);
            Candidate__c RegCandidate = p.upsertCandidate(RegistrationDao.Candidate);
            Exam__c relatedexam = p.upsertExam(RegistrationDao.exam, RegistrationDao.candidate.clientId);
            Registration__c relatedReg = p.upsertRegistration(RegistrationDao);
           
            string myreturn = '';
            
            myreturn = 'RegistrationId:'+relatedReg.id +';';
            
            system.debug(relatedReg);
            myreturn += 'ExamId:' + relatedexam.id + ';';
			myreturn += 'CandidateId:' + RegCandidate.id + ';';            
			myreturn += 'TestCenterId:' + mytestcenter.id + ';';
			
			return myreturn;		
		
	}
*/
    public void processNewAttachments(){
     	this.attachments = null;
     	System.debug('SCS: total attachments: ' + this.attachments.size());
    }

    public boolean hasAttachments  {
    	get {
    		hasAttachments = !this.attachments.isEmpty();
    		return hasAttachments;
    	} 
    	private set;
	}

    public void deleteAttachment(){
        System.debug('deleteAttachmentId: ' + this.deleteAttachmentId);
        if ( this.deleteAttachmentId != null ) {
            delete 
                Database.query(
                    'SELECT Id FROM ' + 
                    	(String.valueOf(deleteAttachmentId).startsWith('015') ? 'Document' : 'Attachment') + 
                     	' WHERE Id = :deleteAttachmentId');
            this.attachments = null;
        }
    }
    
    public void clearnotification()
    	{
    		if(userinfo.getusertype() == 'Standard')
    			{ 
    				mycase.New_Internal_Comment__c = false;
    			  	mycase.New_Internal_Email__c = false;	
    			  	mycase.Last_Internal_Edit__c = system.now();
    			  	hasnotificationmessage = false;
    			  	update mycase;
    			}
    		else
    			{
    				mycase.New_External_Comment__c = false;
    				mycase.Last_External_Edit__c = system.now();
    				hasnotificationmessage = false;
    				update mycase;
    			}	  
    		
    	}
    
    public void deleteTempDocuments()
    	{
        	delete [SELECT Id FROM Document WHERE FolderId = :UserInfo.getUserId() AND Name LIKE 'CaseCreateTemp_%'];
       
       		 if(redirectinprogress!=true)
       		 	{
			        if(system.currentPageReference().getParameters().get('prevown') != null && system.currentpageReference().getparameters().get('sourcepage') != null )
			        	{    
			        		if(mycase.ownerid != userinfo.getUserId())
        						{    		
				        			takeownership();
        						}	
				        		system.currentpagereference().getParameters().put('prevown', system.currentpagereference().getParameters().get('prevown'));
								system.currentpagereference().getParameters().put('prevstat', system.currentpagereference().getParameters().get('prevstat'));
								system.currentpagereference().getParameters().put('sourcepage',system.currentpagereference().getParameters().get('sourcepage'));
							// added url pieces for comment and flag notices	
								system.currentpagereference().getParameters().put('ext_c', system.currentpagereference().getParameters().get('ext_c'));
								system.currentpagereference().getParameters().put('int_c', system.currentpagereference().getParameters().get('int_c'));
								system.currentpagereference().getParameters().put('int_e', system.currentpagereference().getParameters().get('int_e'));
								
			        	}
       			}
    	}
    public void showAddComment()
    {
        displayComment = true ;
        System.debug('RK:displayComment:'+displayComment); 
    }
    public PageReference submitCaseComment()
    {
        PageReference pr;
        try{
            caseComment.ParentId = mycase.id;
            insert caseComment;
            caseComment = new CaseComment();
            this.commentsaved = true;
            this.hasnotificationmessage = false;

            //pr = new PageReference('/' + mycase.id);
           // pr.getParameters().put('feedback', 'commentsuccess');
        }catch(Exception e)
        {
            System.debug('Create Case comment exception:'+e.getMessage());
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR , e.getMessage()) );
            //return null;
        }

        //displayComment = false ;
        return null; //pr;
    }

    public void cancelCaseComment()
    {
        caseComment = new CaseComment();
        displayComment = false ;
    }
       //Since the Attachments related list could have either Documents (upon Create), or 
    public class CaseAttachment {
        public SObject record {get; set;}
        public CaseAttachment(SObject attachmentRec) {
            this.record = attachmentRec;
        }
    }
    
}