public with sharing class DetailsPage {

public Registration__c myreg {get;set;}
public Exam__c myexam {get;set;}

    public PageReference initData() {
        //refreshVtsData(false);
        new VTSPersistenceUtility().refreshVtsData(false, this.myreg, this.mycandidate, this.mytestCenter);
        this.myreg = null;
        this.mycandidate = null;
        this.mytestCenter = null;
        return null;
    }

    /*
    private void refreshVtsData(Boolean doForceRefresh) {

        //EsbDao dao = new DaoFactory().getEsbDao();
        VTSPersistenceUtility persistence = new VTSPersistenceUtility();
        VTS_Registration vtsReg;
        VTS_Candidate vtsCandidate;
        VTS_TestCenter vtsTestCenter;

        Decimal freshLife = Org_Settings__c.getInstance().VTS_Reg_Data_Fresh_Life__c;
        // If data is stale, fetch fresh data from VTS
        if ( doForceRefresh || (freshLife != null && this.myreg.LastModifiedDate.addMinutes(freshLife.intValue()) < System.now()) ) {
            try {
            	vtsReg = dao.getRegistrationByRegistrationId(this.myreg.VTS_Registration_ID__c.longValue());
            } catch(Exception e) {
                //Ignore b/c this is not a showstopper
                System.debug('ERROR getting registration data: ' + e);
            }
        }

        // If data is stale, fetch fresh data from VTS
        if ( doForceRefresh || (freshLife != null && this.mycandidate.LastModifiedDate.addMinutes(freshLife.intValue()) < System.now()) ) {
            try {
                vtsCandidate = dao.getCandidateByCandidateId(this.mycandidate.VTS_Candidate_ID__c.longValue());
            } catch(Exception e) {
                //Ignore b/c this is not a showstopper
                System.debug('ERROR getting Candidate data: ' + e);
            }
        }

        // If data is stale, fetch fresh data from VTS
        if ( doForceRefresh || (freshLife != null && this.MytestCenter.LastModifiedDate.addMinutes(freshLife.intValue()) < System.now()) ) {
            try {
                vtsTestCenter = dao.getTestCenterByTestCenterId(this.mytestCenter.VTS_Test_Center_ID__c.longValue());
            } catch(Exception e) {
                //Ignore b/c this is not a showstopper
                System.debug('ERROR getting Test Center data: ' + e);
            }
        }

        if ( vtsReg != null ) {
            // Update data returned from VTS
            persistence.upsertExam(vtsReg.exam, vtsReg.candidate.clientId);
            persistence.upsertRegistration(vtsReg);
            this.myreg = null;
        }
        
        if ( vtsCandidate != null ) {
            // Update data returned from VTS
            persistence.upsertCandidate(vtsCandidate);
            this.mycandidate = null;
        }
        
        if ( vtsTestCenter != null ) {
            // Update data returned from VTS
            persistence.upsertTestCenter(vtsTestCenter);
            this.mycandidate = null;
        }

    }
	*/

    public PageReference refreshVtsData() {

        /*
        EsbDao dao = new DaoFactory().getEsbDao();
        VTSPersistenceUtility persistence = new VTSPersistenceUtility();
        VTS_Registration vtsReg;
        VTS_Candidate vtsCandidate;
        VTS_TestCenter vtsTestCenter;

        try {
            vtsReg = dao.getRegistrationByRegistrationId(this.myreg.VTS_Registration_ID__c.longValue());
        } catch(Exception e) {
            //Ignore b/c this is not a showstopper
            System.debug('ERROR getting registration data: ' + e);
        }

        try {
            vtsCandidate = dao.getCandidateByCandidateId(this.mycandidate.VTS_Candidate_ID__c.longValue());
        } catch(Exception e) {
            //Ignore b/c this is not a showstopper
            System.debug('ERROR getting Candidate data: ' + e);
        }

        try {
            vtsTestCenter = dao.getTestCenterByTestCenterId(this.mytestCenter.VTS_Test_Center_ID__c.longValue());
        } catch(Exception e) {
            //Ignore b/c this is not a showstopper
            System.debug('ERROR getting Test Center data: ' + e);
        }

        if ( vtsReg != null ) {
            // Update data returned from VTS
            persistence.upsertExam(vtsReg.exam, vtsReg.candidate.clientId);
            persistence.upsertRegistration(vtsReg);
            this.myreg = null;
        }
        
        if ( vtsCandidate != null ) {
            // Update data returned from VTS
            persistence.upsertCandidate(vtsCandidate);
            this.mycandidate = null;
        }
        
        if ( vtsTestCenter != null ) {
            // Update data returned from VTS
            persistence.upsertTestCenter(vtsTestCenter);
            this.mycandidate = null;
        }
		*/

        new VTSPersistenceUtility().refreshVtsData(true, this.myreg, this.mycandidate, this.mytestCenter);
        this.myreg = null;
        this.mycandidate = null;
        this.mytestCenter = null;
        return null;
    }

public Candidate__c mycandidate {get
	{  mycandidate = new candidate__c();
		string candkey = '';
			if(myreg==null)
			{getmyreg();}
				if(myreg!=null)
					{candkey = string.valueof(myreg.get('Candidate__c'));}
					else { candkey = system.currentpagereference().getparameters().get('mycandidate');}	
					
				if(candkey != null && candkey != '')
					{
						string querystring = utility.Editablefields('Candidate__c');	
						string myquery = 'SELECT ' + querystring + ' FROM Candidate__c WHERE id = :candkey';
						try
							{
								mycandidate = database.query(myquery);
							}
						catch(system.queryexception candqe)
							{
								
							}	
					}
				return mycandidate;}					
				set;}



public Account MytestCenter {get
	{ 	mytestcenter = new account();
		string tckey = '';
			if(myreg==null)
			{getmyreg();}
				if(myreg!=null)
					{tckey = string.valueof(myreg.get('Test_Center__c'));}
				if(tckey=='' || tckey == null){tckey = system.currentpagereference().getparameters().get('mysite');}	
				system.debug('tckey'+tckey);
				if(tckey != null && tckey != '')
					{
						string querystring = utility.Editablefields('Account');	
                        if ( querystring.contains('BillingAddress') ) {
                            querystring = utility.Editablefields('Account');
                        }
						string myquery = 'SELECT ' + querystring + ' FROM Account WHERE id = :tckey';
				
						mytestCenter = database.query(myquery);
					}
					system.debug('mytestCenter=' + mytestcenter);
				return mytestCenter;}					
				set;}


public Account myclient{get
	{   myclient = new account();
		string clientkey = '';
			if(myexam==null)
			{getmyexam();}
				if(myexam!=null)
					{ clientkey = string.valueof(myexam.get('Client__c'));//--- invalid field
                    }
					else { clientkey = system.currentpagereference().getparameters().get('myclient');}	
						// { clientkey = system.currentpagereference().getparameters().get('myclient');}	
				if(clientkey != null && clientkey != '')
					{
						string querystring = utility.Editablefields('Account');	
						string myquery = 'SELECT ' + querystring + ' FROM Account WHERE id = :clientkey';
					
						try
							{
								myclient = database.query(myquery);
							}
						catch(system.queryexception clientqe)
							{
								
							}	
					}
				return myclient;}					
				set;}




public DetailsPage(){
	getmyreg();
}

public Registration__c getmyreg()
	{
	if (myreg==null && system.currentpagereference().getparameters().get('myreg')!=null)
		{	myreg = new registration__c();
			try{
                /*
				myreg = [SELECT Candidate__c, candidate__r.first_name__c, candidate__r.last_name__c, Candidate_name__c, Date_and_time_of_Exam__c, Exam__c,Exam__r.name, Process_state_code__c, Test_center__c, Test_center__r.name,VTS_Registration_id__c, id 
					  FROM Registration__c where Id = :system.currentpageReference().getparameters().get('myreg')];
				*/
                String regId = system.currentpageReference().getparameters().get('myreg');
                string querystring = utility.Editablefields('Registration__c');	
                string myquery = 'SELECT ' + querystring + ' FROM Registration__c WHERE id = :regId';
                myreg = Database.query(myquery);

				}
			catch(system.queryexception regqueryexception)
				{
					
				}	
		}
		else{myreg = myreg;}
		return myreg;
	}

Public Void setMyReg(Registration__c myreg)
	{
		this.myreg = myreg;
	}
		
public Exam__c getmyexam()
	{ myexam = new exam__c();
		string examkey = '';
	if(myreg==null)
	{getmyreg();}
		if(myreg!=null)
			{examkey = string.valueof(myreg.get('Exam__c'));}
			else { examkey = system.currentpagereference().getparameters().get('myexam');}	
		if(examkey != null && examkey != '')
		{
			string querystring = utility.Editablefields('Exam__c');	
			string myquery = 'SELECT ' + querystring + ' FROM Exam__c WHERE id = :examkey';
			try
				{
					myexam = database.query(myquery);	
				}
			catch( system.Queryexception examqe)
				{
					
				}
			
		}
		return myexam;
	}					

public void setmyexam(exam__c myexam){
		this.myexam = myexam;}


}