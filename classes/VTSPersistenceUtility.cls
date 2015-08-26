public with sharing class VTSPersistenceUtility {

    private static final ID CLIENT_ACCOUNT_RECTYPE_ID;
    private static final ID TEST_CENTER_ACCOUNT_RECTYPE_ID;

    static {
        Map<String, Schema.RecordTypeInfo> rectTypes = Schema.SobjectType.Account.getRecordTypeInfosByName();
        CLIENT_ACCOUNT_RECTYPE_ID = rectTypes.get('Client').getRecordTypeId();
        TEST_CENTER_ACCOUNT_RECTYPE_ID = rectTypes.get('Site').getRecordTypeId();
    }

    public Candidate__c upsertCandidate(VTS_Candidate vtsCandidate) {
        return upsertCandidate(vtsCandidate, true);
    }

    public Candidate__c upsertCandidate(VTS_Candidate vtsCandidate, Boolean doDml) {

        Candidate__c candidate;
        if ( vtsCandidate != null && (vtsCandidate.id != null || vtsCandidate.candidateId != null) )  {
            candidate = new Candidate__c();
			candidate.VTS_Candidate_ID__c = vtsCandidate.id != null ? vtsCandidate.id : vtsCandidate.candidateId;
                        

// try to eliminate null pointer exception in test method.  BW 8-17
        if(VTSCandidate.clientCandidates != null)
            {
            for(VTS_Candidate.ClientCandidate each:VTSCandidate.clientCandidates)
             	if(each.ClientID == VTSCandidate.clientId)
             	system.debug('candidate persistance iterator::' + each);
            		{
            			Candidate.CCID__c = VTSCandidate.clientCandidates[0].ClientCandidateID;
            			
            		}
            }        //    candidate.CCID__c = vtsCandidate.clientCandidateId;
            candidate.First_Name__c = vtsCandidate.firstName;
            candidate.Last_Name__c = vtsCandidate.lastName;
            candidate.Middle_Name__c = vtsCandidate.middleName;
            if(vtsCandidate.middleName != null)
            	{
            		candidate.Name = vtsCandidate.firstName + ' ' + vtsCandidate.middleName + ' ' + vtsCandidate.lastName;
            	}
            else
            	{
            		candidate.Name = vtsCandidate.firstName + ' ' + vtsCandidate.lastName;
            	}

            if ( vtsCandidate.email != null ) {
                candidate.Email__c = vtsCandidate.email;
            }
// BW 7-9 added line 3 and middle name to persistance utility
            if ( vtsCandidate.primaryAddress != null ) {
                candidate.Address_Line_1__c = vtsCandidate.primaryAddress.address1;
                candidate.Address_Line_2__c = vtsCandidate.primaryAddress.address2;
                candidate.Address_Line_3__c = vtsCandidate.primaryAddress.address3;
                candidate.City__c = vtsCandidate.primaryAddress.city;
                candidate.State__c = vtsCandidate.primaryAddress.state;
                candidate.State_name__c = vtsCandidate.primaryAddress.statename;
                candidate.country_name__c = vtsCandidate.primaryAddress.countryname;
                candidate.Postal_Code__c = vtsCandidate.primaryAddress.postalCode;
                candidate.Country__c = vtsCandidate.primaryAddress.country;
                candidate.Phone_Number__c = vtsCandidate.primaryAddress.phone;
                candidate.Phone_Country_Code__c = vtsCandidate.primaryAddress.phoneCountryCode;
                candidate.Phone_Extension__c = vtsCandidate.primaryAddress.extension;
            }

            System.debug('candidate: ' + candidate);
            if ( vtsCandidate.clientId != null ) {
                candidate.Client__r = new Account(VTS_Client_ID__c = vtsCandidate.clientId);
            }
            if ( doDml ) {
	            //upsert candidate Candidate__c.VTS_Candidate_ID__c;
                WithoutSharingUtility.doUpsertWithExternalKey(candidate, Candidate__c.VTS_Candidate_ID__c);
            }
		}
		return candidate;
	}

	public Registration__c upsertRegistration(VTS_Registration vtsReg) {
        return upsertRegistration(vtsReg, true);
    }

    public Registration__c upsertRegistration(VTS_Registration vtsReg, Boolean doDml) {
        System.debug('RK: reg'+vtsreg);
		Registration__c registration;
		if ( vtsReg != null && vtsReg.id != null ) {
            registration = new Registration__c();
			registration.VTS_Registration_ID__c = vtsReg.id;
			registration.Process_State_Code__c = vtsReg.processStateCode;

            Long candidateId = vtsReg.candidate.id == null ? vtsReg.candidate.candidateId : vtsReg.candidate.id;
			registration.Candidate__r = new Candidate__c(VTS_Candidate_ID__c = candidateId);
			registration.Exam__r = new Exam__c(VTS_Exam_ID__c = vtsReg.exam.id);
			registration.Test_Center__r = new Account(VTS_Test_Center_ID__c = vtsReg.testCenter.id);
			
			// added BW for date and time of exam
			registration.Date_and_Time_of_Exam__c = dateTime.newInstance(vtsReg.appointmentTime.TimestampinUTC);
			
            if ( doDml ) {
                //upsert registration Registration__c.VTS_Registration_ID__c;
                WithoutSharingUtility.doUpsertWithExternalKey(registration, Registration__c.VTS_Registration_ID__c);
            }
		}
		return registration;
	}

	public Exam__c upsertExam(VTS_Exam vtsExam, Long clientId) {
        return upsertExam(vtsExam, clientId, true);
    }

    public Exam__c upsertExam(VTS_Exam vtsExam, Long clientId, Boolean doDml) {

		Exam__c exam;
		if ( vtsExam != null && vtsExam.id != null ) {
            exam = new Exam__c();
			exam.VTS_Exam_ID__c = vtsExam.id;
            //exam.Name = vtsExam.name;
            exam.Exam_Name__c = vtsExam.name;
            exam.Exam_Series_Code__c = vtsExam.code;

			exam.Client__r = new Account(VTS_Client_ID__c = clientId);

            if ( doDml ) {
                //upsert exam Exam__c.VTS_Exam_ID__c;
                WithoutSharingUtility.doUpsertWithExternalKey(exam, Exam__c.VTS_Exam_ID__c);
            }
		}
		return exam;
	}

	public Account upsertTestCenter(VTS_TestCenter vtsTestCenter) {
        return upsertTestCenter(vtsTestCenter, true);
    }

    public Account upsertTestCenter(VTS_TestCenter vtsTestCenter, Boolean doDml) {

		Account testCenter;
		if ( vtsTestCenter != null && vtsTestCenter.id != null ) {
            testCenter = new Account();
            testCenter.RecordTypeId = TEST_CENTER_ACCOUNT_RECTYPE_ID;
			testCenter.VTS_Test_Center_ID__c = vtsTestCenter.id;
            testCenter.Name = vtsTestCenter.name;

            if ( doDml ) {
                //upsert testCenter Account.VTS_Test_Center_ID__c;
                WithoutSharingUtility.doUpsertWithExternalKey(testCenter, Account.VTS_Test_Center_ID__c);
            }
		}
		return testCenter;
	}
    
    //New methods for multiple records
    public MAP<Long, Exam__c> upsertExams(LIST<VTS_Exam> vtsExam, MAP<Long, Long> examIdtoCandidateIdMap) {
        return upsertExams(vtsExam, examIdtoCandidateIdMap, true);
    }

    public MAP<Long, Exam__c> upsertExams(LIST<VTS_Exam> vtsExam, MAP<Long, Long> examIdtoCandidateIdMap, Boolean doDml) {

		MAP<Long, Exam__c> exams = new MAP<Long, Exam__c>();
        
		if ( vtsExam.size() > 0 ) {
            for(VTS_Exam e : vtsExam){
                Exam__c exam = new Exam__c();
                exam.VTS_Exam_ID__c = e.id;
                //exam.Name = vtsExam.name;
                exam.Exam_Name__c = e.name;
                exam.Exam_Series_Code__c = e.code;
    
                exam.Client__r = new Account(VTS_Client_ID__c = examIdtoCandidateIdMap.get(e.Id));
                exams.put(e.Id,exam);
            }
		}
        
        if ( doDml && exams.size() > 0 ) {
            //upsert exam Exam__c.VTS_Exam_ID__c;
            WithoutSharingUtility.doMultipleUpsertWithExternalKey(exams.values(), Exam__c.VTS_Exam_ID__c);
            
        }
		return exams;
	}
    
    public MAP<Long, Registration__c> upsertRegistrations(LIST<VTS_Registration> vtsReg) {
        return upsertRegistrations(vtsReg, true);
    }

    public MAP<Long, Registration__c> upsertRegistrations(LIST<VTS_Registration> vtsRegs, Boolean doDml) {

		MAP<Long, Registration__c> registrations = new MAP<Long, Registration__c>();
        
		if ( vtsRegs != null && vtsRegs.size() > 0 ) {
            for(VTS_Registration vtsReg : vtsRegs){
                Registration__c registration = new Registration__c();
                registration.VTS_Registration_ID__c = vtsReg.id;
    
                registration.Candidate__r = new Candidate__c(VTS_Candidate_ID__c = vtsReg.candidate.id);
                registration.Exam__r = new Exam__c(VTS_Exam_ID__c = vtsReg.exam.id);
                registration.Test_Center__r = new Account(VTS_Test_Center_ID__c = vtsReg.testCenter.id);
                
                // added BW for date and time of exam
                registration.Date_and_Time_of_Exam__c = dateTime.newInstance(vtsReg.appointmentTime.TimestampinUTC);
				registrations.put(vtsReg.Id, registration);                
            }
			
            if ( doDml && registrations.size() > 0 ) {
                //upsert registration Registration__c.VTS_Registration_ID__c;
                WithoutSharingUtility.doMultipleUpsertWithExternalKey(registrations.values(), Registration__c.VTS_Registration_ID__c);
            }
		}
		return registrations;
	}
    
    public MAP<Long, Candidate__c> upsertCandidates(LIST<VTS_Candidate> vtsCandidates) {
        return upsertCandidates(vtsCandidates, true);
    }

    public MAP<Long,Candidate__c> upsertCandidates(LIST<VTS_Candidate> vtsCandidates, Boolean doDml) {
		MAP<Long,Candidate__c> candidates = new MAP<Long,Candidate__c>();
		if ( vtsCandidates.size() > 0 ) {
            for(VTS_Candidate vtsCandidate : vtsCandidates){
                Candidate__c candidate = new Candidate__c();
                candidate.VTS_Candidate_ID__c = vtsCandidate.id != null ? vtsCandidate.id : vtsCandidate.candidateId;
                candidate.CCID__c = vtsCandidate.clientCandidateId;
                candidate.First_Name__c = vtsCandidate.firstName;
                candidate.Last_Name__c = vtsCandidate.lastName;
				//new line here  BW 6-5 to set value for Candidate name
                candidate.name = vtsCandidate.firstName + ' ' + vtsCandidate.lastName;
                
                
                if ( vtsCandidate.primaryAddress != null ) {
                    candidate.Address_Line_1__c = vtsCandidate.primaryAddress.address1;
                    candidate.Address_Line_2__c = vtsCandidate.primaryAddress.address2;
                    candidate.City__c = vtsCandidate.primaryAddress.city;
                    candidate.State__c = vtsCandidate.primaryAddress.state;
                    candidate.Postal_Code__c = vtsCandidate.primaryAddress.postalCode;
                    candidate.Country__c = vtsCandidate.primaryAddress.country;
                    candidate.Phone_Number__c = vtsCandidate.primaryAddress.phone;
                    candidate.Phone_Country_Code__c = vtsCandidate.primaryAddress.phoneCountryCode;
                    candidate.Phone_Extension__c = vtsCandidate.primaryAddress.extension;
                }

                if ( vtsCandidate.clientId != null ) {
                    candidate.Client__r = new Account(VTS_Client_ID__c = vtsCandidate.clientId);
                }
                candidates.put(vtsCandidate.id, candidate);
            }
            if ( doDml &&  candidates.size() > 0) {
	            //upsert candidate Candidate__c.VTS_Candidate_ID__c;
                WithoutSharingUtility.doMultipleUpsertWithExternalKey(candidates.values(), Candidate__c.VTS_Candidate_ID__c);
            }
		}
		return candidates;
	}

    public void refreshVtsData(Boolean doForceRefresh, Registration__c registration, Candidate__c candidate, Account testCenter) {

        EsbDao dao = new DaoFactory().getEsbDao();
        //VTSPersistenceUtility persistence = new VTSPersistenceUtility();
        VTS_Registration vtsReg;
        VTS_Candidate vtsCandidate;
        VTS_TestCenter vtsTestCenter;

        Decimal freshLife = Org_Settings__c.getInstance().VTS_Reg_Data_Fresh_Life__c;
        // If data is stale, fetch fresh data from VTS
        if ( registration != null && 
            	(doForceRefresh || (freshLife != null && registration.LastModifiedDate.addMinutes(freshLife.intValue()) < System.now())) ) {
            try {
            	vtsReg = dao.getRegistrationByRegistrationId(registration.VTS_Registration_ID__c.longValue());
            } catch(Exception e) {
                //Ignore b/c this is not a showstopper
                System.debug('ERROR getting registration data: ' + e);
            }
        }

        // If data is stale, fetch fresh data from VTS
        if ( candidate != null && 
            	(doForceRefresh || (freshLife != null && candidate.LastModifiedDate.addMinutes(freshLife.intValue()) < System.now())) ) {
            try {
                vtsCandidate = dao.getCandidateByCandidateId(candidate.VTS_Candidate_ID__c.longValue());
            } catch(Exception e) {
                //Ignore b/c this is not a showstopper
                System.debug('ERROR getting Candidate data: ' + e);
            }
        }

        // If data is stale, fetch fresh data from VTS
        if ( testCenter != null && 
            	(doForceRefresh || (freshLife != null && testCenter.LastModifiedDate.addMinutes(freshLife.intValue()) < System.now())) ) {
            try {
                vtsTestCenter = dao.getTestCenterByTestCenterId(testCenter.VTS_Test_Center_ID__c.longValue());
            } catch(Exception e) {
                //Ignore b/c this is not a showstopper
                System.debug('ERROR getting Test Center data: ' + e);
            }
        }

        if ( vtsReg != null ) {
            // Update data returned from VTS
            upsertExam(vtsReg.exam, vtsReg.candidate.clientId);
            upsertRegistration(vtsReg);
        }
        
        if ( vtsCandidate != null ) {
            // Update data returned from VTS
            upsertCandidate(vtsCandidate);
        }
        
        if ( vtsTestCenter != null ) {
            // Update data returned from VTS
            upsertTestCenter(vtsTestCenter);
        }

    }

}