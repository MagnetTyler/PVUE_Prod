public with sharing class AdvancedSearchController {

	public string criteria1{get
		{if(criteria1 ==null)
			{criteria1 = system.currentpagereference().getparameters().get('dataentry');} return criteria1;}set;}
	public string siteidfrompage{get
			{siteidfrompage = system.currentpagereference().getparameters().get('mysite'); return siteidfrompage;} set;}
	public string Sitecriteria1{get;set;}
    public string Sitecriteria2{get;set;}
   // public boolean showSiteIdError { get; set; }
	public string hiddenfield {get;set;}
    public string hiddenfieldforreg {get;set;}
	public string returnid{get;private set;}
	public string pagesource{get;set;}
	public string startdate{get;set;}
	public string enddate{get;set;}
	public string pagetype{get;set;}
	public string registrationid{get;set;}
    public string paramvalue{get; set;}
	public id examid{get;set;}
	public id candidateid {get;set;}
	public string searchtype {get;set;}
	public string Regcriteria1{get;set;}
	public string Regcriteria2{get;set;}
	public boolean hasCandidateresults {get;set;}
	public boolean searchhasrun{get;set;}
    public String selectedcountry { get; set; }
    public String selectedAddressOne { get; set; }
    public String selectedAddressTwo { get; set; }
    public String selectedCity { get; set; }
    public String selectedState { get; set;}
    public String fieldid {get; set;}
    public String field2Id {get;set;}
    public list<decoratedVTS_Registration> SiteAdvanced {get;set;}
    public list<VTS_Candidate> candidateReturns { get; set;}
    public list<SelectOption> countries { get{ 
        if( countries == null ){
            countries = new list<SelectOption>();
            
            map<string,string> countriesmap = ConstantUtil.getCountriesMap();
            
            //countriesStr.sort();
            for(string each:countriesmap.keyset())
            	{
            		countries.add( new SelectOption( each, countriesmap.get(each)) );
            	}		
        	}
        return countries;
    } set; }
    
   public void clearentries()
    {
        sitecriteria1 = null;
        Sitecriteria2 = null;
        regcriteria1 = null;
        regcriteria2 = null;
    } 
   public list<SelectOption> states { get{ 

        	map<string,list<selectOption>> statesmap = constantutil.getstates();
            list<selectOption> states = statesmap.get(selectedcountry);
            if(states== null)
            	{
            		states = new list<selectoption>();
            		states.add( new SelectOption( ''  , system.label.none ) );
            	}
            else{
            		states.add( 0,new SelectOption( ''  , system.label.none ) );
            	}
            
        return states;
    } set; }
    
    
    
    public Boolean isAdvancedOptions { get; set;}
    public void advancedOptions(){
        if( isAdvancedOptions == null || !isAdvancedOptions ){
            isAdvancedOptions = true;
        }else{
            isAdvancedOptions = false;
        }
    }
	public list <SelectOption> Clientlist{get
			{//if (this.Clientlist == null || this.Clientlist.size()<2)
					{
						this.Clientlist = new list<selectOption>();
						for(account eachclient:[select name, id, vts_client_id__c from account where VTS_Client_id__c != null and Recordtype.name = 'Client' Order by Name])
							{
								SelectOption so = new SelectOption (string.valueof(eachclient.VTS_Client_id__c),eachclient.name);
								clientlist.add(so);
							}
					}
			return clientlist;
			}
			set;
		}
    public String selectedAdvanceCriteria {get{
        if( selectedAdvanceCriteria == null ){
            selectedAdvanceCriteria = 'Phone number';
        }
        return selectedAdvanceCriteria;
    } set;}
    
    public map<String, String> clientMap {get{
        clientMap = new map<String , String>();
        for(account eachclient:[select name, id, vts_client_id__c from account where VTS_Client_id__c != null and Recordtype.name = 'Client' Order by Name])
        {
            clientMap.put( string.valueof(eachclient.VTS_Client_id__c),eachclient.name );
        }
        return clientMap;
    } set;}
    public list<SelectOption> advanceCriteriaOptions { get {
        if( advanceCriteriaOptions == null ){
            advanceCriteriaOptions = new list<SelectOption>();
            advanceCriteriaOptions.add( new SelectOption( 'Phone number'  , 'Phone number' ) );
            advanceCriteriaOptions.add( new SelectOption( 'Email address' , 'Email address' ) );
            advanceCriteriaOptions.add( new SelectOption( 'CCID'  , 'CCID' ) );
            advanceCriteriaOptions.add( new SelectOption( 'First and last name' , 'First and last name' ) );
        }
        
        return advanceCriteriaOptions;
    } set; }
	public list<decoratedVTS_Registration> RegistrationApiReturns{get;set;}
	public Boolean isBackToSearch { get{
        if( isBackToSearch == null ) isBackToSearch = false;
        return isBackToSearch;
    } set; }
	public static map<string, decoratedVTS_Registration> resultsmap = new map<string,decoratedVTS_Registration>();
	
	
	public string selectedregistration {get;set;}


		DAOFactory d = new DAOFactory();
		ESBDao dao = d.getESBDao();


    public void backToSearch(){
        isBackToSearch = false;
        RegistrationApiReturns = null;
        //candidateRows = null;
    }
	public pagereference  dosearch(){
		
		isBackToSearch = true;
		
		getRegistrationApiReturns();
        
		return null;
	}

	public void clearsearch(){
		regcriteria1 = null;
		regcriteria2 = null;
	}
	
	
	
	
	
	public AdvancedSearchController(){
		system.debug(system.currentpageReference().getURL());
        fieldid = system.currentPageReference().getparameters().get('idfield');
   		field2id = system.currentPageReference().getparameters().get('searchfield');
   
   if(criteria1 ==null)
			{criteria1 = system.currentpagereference().getparameters().get('dataentry');}
		fieldid = system.currentPageReference().getparameters().get('idfield');
		hiddenfield = system.currentPageReference().getparameters().get('hiddenfield');
		getpagetype();
		getsearchtype();
		// if(pagetype == 'Community' )           	 
        //    		{
		//				getCandidateResults();
        //    		}
   hiddenfieldforreg = system.currentPageReference().getparameters().get('reg');
    
    
    }










    public List<AdvancedSearchController.CandidateRow> getCandidateRows() {

		searchhasrun = true;
        List<AdvancedSearchController.CandidateRow> candidateRows = new List<AdvancedSearchController.CandidateRow>();
        Map<Integer, List<AdvancedSearchController.decoratedVTS_Registration>> candidateIdToRegsMap = new Map<Integer, List<AdvancedSearchController.decoratedVTS_Registration>>();

		RegistrationApiReturns = new list<decoratedVTS_Registration>();
        candidateReturns = new list<VTS_Candidate>();
		list<VTS_Registration> myRegistrationApiReturns = new list<VTS_Registration>();
		if(pagetype != 'Community' && searchtype != 'Site ID')
		{
        if( Regcriteria1 !=null  && Regcriteria1 != '' && Regcriteria2 !=null && Regcriteria2 != ''){
            Try{
                
                map<String, Object> advancedFieldMap = new map<String, Object>{'clientID' => decimal.ValueOf(Regcriteria2).longValue()};//decimal.ValueOf(Regcriteria2).longValue()};
                
                if( selectedAdvanceCriteria == 'Phone number' ){
                    advancedFieldMap.put( 'phone' , Regcriteria1 );
                }else if( selectedAdvanceCriteria == 'Email address' ){
                    advancedFieldMap.put( 'email' , Regcriteria1 );
                }else if( selectedAdvanceCriteria == 'CCID' ){
                    advancedFieldMap.put( 'clientCandidateID' , Regcriteria1 );
                }else if( selectedAdvanceCriteria == 'First and last name' ){
                    list<String> firstAndLastName = Regcriteria1.split(' ');
                    
                    if( firstAndLastName.size() > 1 ){
                        advancedFieldMap.put( 'firstName' , firstAndLastName[0] );
                        advancedFieldMap.put( 'lastName'  , firstAndLastName[1] );
                    }else if( firstAndLastName.size() == 1 ){
                        advancedFieldMap.put( 'lastName'  , firstAndLastName[0]);
                    }
                }
                
                if(isAdvancedOptions != null && isAdvancedOptions){
                    if( selectedcountry != null && selectedcountry != '' ){
                        advancedFieldMap.put( 'country' , selectedcountry );
                    }
                    if( selectedState != null && selectedState != '' ){
                        advancedFieldMap.put( 'state' , selectedState );
                    }
                    if( selectedCity != null && selectedCity != '' ){
                        advancedFieldMap.put( 'city' , selectedCity );
                    }
                    if( selectedAddressOne != null && selectedAddressOne != '' ){
                        advancedFieldMap.put( 'addressLine1' , selectedAddressOne );
                    }
                    if( selectedAddressTwo != null && selectedAddressTwo != '' ){
                        advancedFieldMap.put( 'addressLine1' , selectedAddressTwo );
                    }
                }
                //myRegistrationApiReturns = dao.getRegistrationsByClientIdAndSeletedFields( advancedFieldMap );
                candidateReturns = dao.getCandidatesByCriteria( advancedFieldMap );
                if ( !candidateReturns.isEmpty() ) {
					
					hasCandidateresults = true;	
                    for ( VTS_Candidate candidate : candidateReturns ) {

                        system.debug('candidate: ' + candidate);
                        AdvancedSearchController.CandidateRow candRow = new AdvancedSearchController.CandidateRow(candidate);
                        candidateRows.add(candRow);

                        List<VTS_Registration> candidateRegs = dao.getRegistrationsByCandidateId( Decimal.valueOf(candidate.id).longValue() );
                        for ( VTS_Registration reg : candidateRegs ) {
                            candRow.addRegistration(new decoratedVTS_Registration(reg));
                        }
                    }
                }
                else {
                    setErrorMessage('Error executing search.');
                }
        	}Catch(Exception DAO_Call){System.debug('DAOCall Exception Thrown' + DAO_Call.getCause()+' ' +DAO_Call.getMessage()+' '+DAO_Call.getLineNumber()+' '+DAO_Call.getStackTraceString());string errmessage = 'Error executing search.'+ DAO_Call.getmessage(); setErrorMessage(errmessage);}
		
		}else{
            string errmessage = 'Error Incomplete form.' + '  Please include both CC ID and Client ID or contact your Salesforce Administrator';setErrorMessage(errmessage);		
        }	
		}

        //
		//for( VTS_Registration eachrecord:myregistrationApiReturns)
		//		{
		//			decoratedVTS_Registration myrecord = new decoratedVTS_Registration(eachrecord);
		//			resultsmap.put(string.valueof(myrecord.registration.id), myrecord);
		//		}
				
		//RegistrationApiReturns = resultsmap.values();
		//return RegistrationApiReturns;
		
        return candidateRows;
	}

    public list<decoratedVTS_Registration> getSiteAdvanced(){
        System.debug('START getSiteAdvanced');
        //list<decoratedVTS_Registration> SiteAdvanced = new list<decoratedVTS_Registration>();
        if(SiteSearchtype == system.label.Client_Candidate_ID_Adv)
            {
                Regcriteria1 = SiteCriteria1;
                regcriteria2 = Sitecriteria2;
                selectedAdvanceCriteria = system.label.ccid;
                SiteAdvanced = getRegistrationApiReturns();
            }
        if(sitesearchtype == system.label.RegId)
            {
                vts_registration returnreg = SingleReg(SiteCriteria1);
                if(returnreg != null)
                    {
                        SiteAdvanced = new list<decoratedVTS_Registration>();
                        decoratedVTS_Registration myreg = new DecoratedVTS_REgistration(returnreg);
                        SiteAdvanced.add(myreg);
                    }
                
            }
        system.debug('END getSiteAdvanced' + SiteAdvanced);
        return SiteAdvanced;    
    }

    public list<decoratedVTS_Registration> getRegistrationApiReturns(){
		
		RegistrationApiReturns = new list<decoratedVTS_Registration>();
        candidateReturns = new list<VTS_Candidate>();
		list<VTS_Registration> myRegistrationApiReturns = new list<VTS_Registration>();
		
        if( Regcriteria1 !=null  && Regcriteria1 != '' && Regcriteria2 !=null && Regcriteria2 != ''){
            Try{
                
                map<String, Object> advancedFieldMap = new map<String, Object>{'clientID' => decimal.ValueOf(Regcriteria2).longValue()};//decimal.ValueOf(Regcriteria2).longValue()};
                
                if( selectedAdvanceCriteria == 'Phone number' ){
                    advancedFieldMap.put( 'phone' , Regcriteria1 );
                }else if( selectedAdvanceCriteria == 'Email address' ){
                    advancedFieldMap.put( 'email' , Regcriteria1 );
                }else if( selectedAdvanceCriteria == system.label.ccid ){
                    advancedFieldMap.put( 'clientCandidateID' , Regcriteria1 );
                }else if( selectedAdvanceCriteria == 'First and last name' ){
                    list<String> firstAndLastName = Regcriteria1.split(' ');
                    
                    if( firstAndLastName.size() > 1 ){
                        advancedFieldMap.put( 'firstName' , firstAndLastName[0] );
                        advancedFieldMap.put( 'lastName'  , firstAndLastName[1] );
                    }else if( firstAndLastName.size() == 1 ){
                        advancedFieldMap.put( 'lastName'  , firstAndLastName[0]);
                    }
                }
                
                if(isAdvancedOptions != null && isAdvancedOptions){
                    if( selectedcountry != null && selectedcountry != '' ){
                        advancedFieldMap.put( 'country' , selectedcountry );
                    }
                    if( selectedState != null && selectedState != '' ){
                        advancedFieldMap.put( 'state' , selectedState );
                    }
                    if( selectedCity != null && selectedCity != '' ){
                        advancedFieldMap.put( 'city' , selectedCity );
                    }
                    if( selectedAddressOne != null && selectedAddressOne != '' ){
                        advancedFieldMap.put( 'addressLine1' , selectedAddressOne );
                    }
                    if( selectedAddressTwo != null && selectedAddressTwo != '' ){
                        advancedFieldMap.put( 'addressLine1' , selectedAddressTwo );
                    }
                }
                //myRegistrationApiReturns = dao.getRegistrationsByClientIdAndSeletedFields( advancedFieldMap );
                candidateReturns = dao.getCandidatesByCriteria( advancedFieldMap );
                system.debug('SCS:: ' + myRegistrationApiReturns );
                if( candidateReturns.size() > 0 ){
                    myregistrationApiReturns = dao.getRegistrationsByCandidateId( decimal.ValueOf( candidateReturns[0].id ).longValue() );
                }
                if(candidateReturns.size() == 0 || myregistrationApiReturns.size() == 0 ){
                    string errmessage = 'Error executing search.'; setErrorMessage(errmessage);
                }
        	}Catch(Exception DAO_Call){System.debug('DAOCall Exception Thrown' + DAO_Call.getCause()+' ' +DAO_Call.getMessage()+' '+DAO_Call.getLineNumber()+' '+DAO_Call.getStackTraceString());string errmessage = 'Error executing search.'+ DAO_Call.getmessage(); setErrorMessage(errmessage);}
		
		}else{
            string errmessage = 'Error Incomplete form.' + '  Please include both CC ID and Client ID or contact your Salesforce Administrator';setErrorMessage(errmessage);		
        }	
    
		
		for( VTS_Registration eachrecord:myregistrationApiReturns)
				{
					decoratedVTS_Registration myrecord = new decoratedVTS_Registration(eachrecord);
					resultsmap.put(string.valueof(myrecord.registration.id), myrecord);
				}
				
		RegistrationApiReturns = resultsmap.values();
		return RegistrationApiReturns;
	}

    public class CandidateRow {

        public VTS_Candidate candidate {get; set;}
        public List<decoratedVTS_Registration> registrations {get; set;}
        
        public CandidateRow(VTS_Candidate cand) {
            this.candidate = cand;
        }

        public void addRegistration(decoratedVTS_Registration reg) {
            if ( this.registrations == null ) {
                this.registrations = new List<decoratedVTS_Registration>();
            }
            this.registrations.add(reg);
        }
    }

public class decoratedVTS_Registration{

	public VTS_Registration Registration{get;set;}
	public string commontime {get;set;}
    public datetime sorttime{get;set;}
	

	public decoratedVTS_Registration(VTS_Registration Registration){
		this.Registration = registration;		
		long mytime = Registration.appointmentTime.TimestampinUTC ; // + Registration.appointmentTime.displayTimeZoneUTCOffset;
//															  			above line removed BW as the new timestampInUTC is actually UTC not local
		this.commontime =  DateTime.newInstance(mytime).format();		
        this.sorttime = DateTime.newInstance(mytime);
		
	}
	
	}

    private void setErrorMessage(String msg){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,msg);
	    ApexPages.addMessage(myMsg);
    }
    



	public string getsearchtype()
		{
			string mytype = system.currentPageReference().getParameters().get('mytype');
			if ((searchtype == null || searchtype == '') && mytype != null) {searchtype = mytype;}
			else{searchtype = searchtype;}
			return searchtype;
		}
	public void	setearchtype(string searchtype){
			this.searchtype = searchtype;
		}

	public string Sitesearchtype {get;set;}
	public string Registrationsearchtype {get;set;}
	public list<account>TestCenters{get;set;}

	public list<VTS_Registration> dRegistrationApiReturns{get;set;}
//	public list<decoratedVTS_Registration> OldRegistrationApiReturns{get;set;}
	public list<decoratedVTS_Registration> CandidateResults{get;set;}
	
//	public static map<string, decoratedVTS_Registration> resultsmap = new map<string,decoratedVTS_Registration>();
	
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
	
//	public string selectedregistration {get;set;}


//		DAOFactory d = new DAOFactory();
//		ESBDao dao = d.getESBDao();


	public pagereference  do_oldsearch(){
		
		
		system.debug('pagetype==' + pagetype);
        system.debug('searchtype==' + searchtype);
			
			if(searchtype == system.label.Site_id)
			{
				SiteAdvanced = getSiteAdvanced();
			}
			else if(searchtype == System.label.Registration_ID)
				{
					getRegistrationApiReturns();
				}
			if( pagetype == 'Community' || siteidfrompage != null)
				{
					system.debug('startdate'+startdate + 'AND ENDDATE'+ endDate);
					getCandidateResults();	
				}	
			return null;
		}

	public void Old_clearsearch(){
		regcriteria1 = null;
		regcriteria2 = null;
		sitecriteria1 = null;
		if(RegistrationApiReturns!=null)
				{RegistrationApiReturns = null;}
		if(testcenters!=null)
			{
				testcenters = null;
			}
	}



public list<account> getTestCenters(){
			
			if(RegistrationApiReturns!=null){RegistrationApiReturns = null;}


		testcenters = new list<account>();

			if(searchtype == 'Site ID')
				{ if(Sitecriteria1!=null && SiteCriteria1!='')
					{
                    
						string myquery = 'FIND \' '+sitecriteria1+'\' IN PHONE FIELDS returning Account(' + utility.Editablefields('Account')+ ')';			
						List<list<sObject>> dynamicreturns = search.query(myquery);			
						account[] myreturns = ((list<account>)dynamicreturns[0]);
						testCenters = myreturns;
						
						
						return testCenters;
					}
				else 
			    	{
			    		string errmessage = 'Error Incomplete form.'+ '  Please value in phone number field before clicking "search".';
                        setErrorMessage(errmessage);
								//ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errmessage);
								//ApexPages.addMessage(myMsg);
								return null;
			    	}
				}	
			else return null;
}

public void settestcenters(list<account> testcenters){
		this.testcenters = testcenters;
}

public list<decoratedVTS_Registration> getCandidateResults(){

		CandidateResults = new list<decoratedVTS_Registration>();
		
		try{
			
		Boolean defaultsearch = false;
		//if(endDate == null){ endDate =  date.today().format();
							//startdate = date.newinstance(2001,6,1).format();
		//					 startdate = (date.today()-1).format();
		//					}		 
			
		if(enddate.contains('/') || startdate.contains('/')){defaultsearch = true;}	
			
		date mystart;
		date myend;
							
		if(defaultsearch)
			{ mystart = date.parse(startdate);
			  myend = date.parse(enddate);
			}
		else{								
			mystart = date.valueof(startdate);
			myend = date.valueof(enddate);
			}
	
		
		user myuser = [select name, id, contactid, contact.account.VTS_Test_Center_id__c from User where id = :userinfo.getUserId()];
		system.debug('startdate'+startdate + 'AND ENDDATE'+ endDate);
		system.debug('dateformat mystart' + mystart + 'and'+ myend);
		decimal tcid;
		if(siteidfrompage != 'null' && siteidfrompage != null)
			{
				tcid = decimal.valueof(siteidfrompage);	
			}
		else{tcid	 = myuser.contact.account.vts_test_center_id__c;}
    	System.debug('RK tceneter id:'+tcid);
		
			list<vts_registration> myreturns = new list<vts_registration>();
			system.debug('dateformat mystart' + mystart + 'and'+ myend);
			myreturns = dao.getRegistrationsByTestCenterId(tcid.longvalue(),mystart, myend);
			myreturns.sort();
			
			for(VTS_Registration each: myreturns)
				{
					decoratedVTS_Registration decoratedreg = new decoratedVTS_Registration(each);
					CandidateResults.add(decoratedreg);
				}
			}	
		catch (exception candidateresultsException)
			{
				system.debug('getCandidate Resulsts Exception Caught:' + candidateResultsException);		
			}	
			return CandidateResults;	
}

//utility to insert the selected registration record
	public VTS_Registration singleReg(string dataentry)
        //data entry is assumed to be a Registration Id
    {
        System.debug('START SingleReg method::' + dataentry);
            DAOFactory d = new DAOFactory();
            ESBDao dao = d.getEsbDao();
            VTS_Registration RegistrationDao = new VTS_Registration();
            Try {

                    RegistrationDao = dao.getRegistrationByRegistrationId(decimal.ValueOf(dataentry).longValue());
                }
            Catch (Exception calloutException)
                {
                    system.debug('Callout Failure::' + calloutException);
                }
                     
        System.debug('END SingleReg Method::' + RegistrationDAO);
            return RegistrationDAO;
    }


    public string dosave(){
				
				string selectid = Apexpages.currentPage().getParameters().get('myParam');
				system.debug('selectid ='+selectid+ 'controllervalue='+registrationid);
				DAOFactory d = new DAOFactory();
				ESBDao dao = d.getEsbDao();
				
				VTS_Registration RegistrationDao = dao.getRegistrationByRegistrationId(decimal.ValueOf(selectid).longValue());
				VTSPersistenceUtility p = new VTSPersistenceUtility();
								
						try{
							//insert records returned by API call to Reg endpoint.  keep ids for assignment to the case	
								Account mytestcenter = p.upsertTestCenter(registrationDao.testCenter, true);
								Candidate__c RegCandidate = p.upsertCandidate(RegistrationDao.Candidate, true);
                        		Exam__c relatedexam = p.upsertExam(RegistrationDao.exam, RegistrationDao.candidate.clientId, true);
                        		Registration__c relatedReg = p.upsertRegistration(RegistrationDao, true);
								
								return relatedReg.id;
							}
						catch (exception a)
							{
                                return a.getmessage();
                            	
                            }		
	}
	
	   public void setValueToVariable(){
        searchtype = EncodingUtil.urlDecode( searchtype , 'UTF-8');
        //hiddenfieldforreg=EncodingUtil.urlDecode( searchtype , 'UTF-8');
    }
}