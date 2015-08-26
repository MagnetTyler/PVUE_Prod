@RestResource(urlMapping='/Case/v1/*')
global with sharing class REST_WS_Case {

    /*
    private static final Map<String, String> VTS_TO_SF_CASE_TYPE_MAP = 
        new Map<String, String>{'MISSING_RESULTS' => 'Missing results'};
	*/

    @HttpGet
    //global static REST_WS_Case.WSCase doGet() {
    global static void doGet() {  

        //REST_WS_Case.WSCase respCase;
        String response;
        try {
            String uri = RestContext.request.requestURI;
            System.debug('uri: ' + uri);
            String lastPartOfUri = uri.substring(uri.lastIndexOf('/') + 1);
            System.debug('RestContext.request.params: ' + RestContext.request.params);
            System.debug('AA:lastPartOfUri ' + lastPartOfUri);

            if ( String.isBlank(lastPartOfUri) ) {
                RestContext.response.statusCode = 404;
            }  
            // Search
            else if ( lastPartOfUri.startsWith('search') && !RestContext.request.params.isEmpty() ) {

                String vtsRegId = RestContext.request.params.get('registrationId');
                
                System.debug('AA:vtsRegId ' + vtsRegId);
                
	            // Search on VTS Registration ID
	            if ( !String.isBlank(vtsRegId) ) {
                    List<Map<String, Object>> cases = getCasesByWhereClause('Registration_id__r.VTS_Registration_ID__c = ' + vtsRegId);
                    response = JSON.serialize(cases);
                    RestContext.response.statusCode = 200;
                } else {
                    RestContext.response.statusCode = 400; 
                }
            }
            // GET (using Case ID)
            else if ( StringUtility.isValidId(lastPartOfUri) ) {

                List<Map<String, Object>> cases = getCasesByWhereClause('Id = \'' + String.escapeSingleQuotes(lastPartOfUri) + '\'');
                System.debug('cases returned: ' + cases);
                if ( !cases.isEmpty() ) {
                    response = JSON.serialize(cases.get(0));
                    RestContext.response.statusCode = 200;
                } else {
                    RestContext.response.statusCode = 404;
                }
            }
        } catch (Exception e) {
            REST_WS_Case.Response resp = processException(RestContext.request, RestContext.response, e, 'REST_WS_Case.doget()');
            if ( resp != null ) {
                response = JSON.serialize(resp);
            }
        }

        if(response != null){
	        RestContext.response.responseBody = Blob.valueOf(response);            
        }
        RestContext.response.addHeader('Content-Type', 'application/json;charset=UTF-8');
        //return response;
    }

    @HttpPost
    global static REST_WS_Case.Response doPost(){

        //System.debug('RestContext.request: ' + RestContext.request);
        //System.debug('RestContext.request.requestBody: ' + RestContext.request.requestBody);
        REST_WS_Case.Response resp = new REST_WS_Case.Response();
        SavePoint sp;
        try {
            System.debug('M360: Request String :'+RestContext.request.requestBody.toString());
            // Parse JSON
        	VTS_Case vtsCase = (VTS_Case) JSON.deserialize(RestContext.request.requestBody.toString(), VTS_Case.class);
            
            System.debug('M360: vtsCase ' + vtsCase);

	        sp = Database.setSavepoint();
            
            MAP<Long, VTS_Exam> vtsIdToVtsExamMap = new MAP<Long, VTS_Exam>();
            MAP<Long, VTS_Candidate> vtsIdToVtsCandidateMap = new MAP<Long, VTS_Candidate>();
            MAP<Long, Long> vtsExamIdtoVtsClientIdMap = new MAP<Long, Long>();

            if ( vtsCase != null && vtsCase.registrations != null ) {

                for ( VTS_Registration reg : vtsCase.registrations ) {
                        vtsIdToVtsExamMap.put(reg.exam.Id, reg.exam);
                        vtsIdToVtsCandidateMap.put(reg.candidate.Id, reg.candidate);
                        vtsExamIdtoVtsClientIdMap.put(reg.exam.Id, reg.candidate.clientId);
                }
                System.debug('AA:vtsIdToVtsCandidateMap' + vtsIdToVtsCandidateMap.values());
                System.debug('AA:examIdtoCandidateIdMap ' + vtsExamIdtoVtsClientIdMap);

                // Upsert related data (Test Center, Exam, Candidate, and Registration)
                VTSPersistenceUtility vtsUtil = new VTSPersistenceUtility();
                Account testCenter = vtsUtil.upsertTestCenter(vtsCase.registrations[0].testCenter);
                MAP<Long, Candidate__c> vtsIdToCandidateMap = vtsUtil.upsertCandidates(vtsIdToVtsCandidateMap.values());            
                MAP<Long, Exam__c> vtsIdToExamMap = vtsUtil.upsertExams(vtsIdToVtsExamMap.values(), vtsExamIdtoVtsClientIdMap);
                MAP<Long, Registration__c> vtsIdToRegMap = vtsUtil.upsertRegistrations(vtsCase.registrations);

                /*
                String caseType = VTS_TO_SF_CASE_TYPE_MAP.get(vtsCase.caseType);
                if ( caseType == null ) {
                    caseType = 'Unknown';
                }
                */
                String caseType = vtsCase.caseType;

                routing__c caserouting = new routing__c();
				caserouting = utility.getRoutingandFirstStep(casetype);
				string myRecordtypeId = '';
				
				try
					{
						myRecordtypeId = Schema.SObjecttype.Case.GetRecordtypeinfosbyname().get(caserouting.Case_Record_Type__c).getrecordtypeid();
					}
					Catch (exception getrecordtype)
						{
							system.debug('error getting RecordType Id::' + getrecordtype);
						}
                //Inserting parent case
                Case parentCase = 
                    new Case(
                        Subject = caseType, Status__c = 'Being Created', Status = 'Being Created', routing__c = caserouting.id,
                        //Test_Center_Name__r = new Account(VTS_Test_Center_ID__c = vtsCase.registrations[0].testCenter.id),
                        Test_Center_Name__c = testCenter.Id, AccountId = testCenter.Id, step__c = caserouting.steps__r[0].id,
                        Topic__c = 'Created by VTS', Final_Category__c = caseType);
    			if (myrecordtypeId != ''){parentcase.recordtypeId = myrecordtypeid;}
                if ( vtsCase.registrations.size() == 1 ) {
                    parentCase.Candidate_id__c = vtsIdToCandidateMap.get(vtsCase.registrations[0].candidate.id).Id;
                    parentCase.Registration_id__c = vtsIdToRegMap.get(vtsCase.registrations[0].id).Id;
                }
    
                // Set Routing on Case
                try {
                    parentCase = new RoutingService().routeCase(parentCase, caseType);
                } catch(Exception ex) {
                    // Log error and continue
                    processRoutingError(RestContext.request, ex, 'REST_WS_Case.doPost() -> RoutingService.routeCase()');
                }
                insert parentCase;
    
                if ( vtsCase.registrations.size() > 1 ) {
                    // Creating child Cases
                    LIST<Case> cases = new LIST<Case>();
                    for ( VTS_Registration vtsReg : vtsCase.registrations ) {
                        Case c = parentCase.clone(false, true, false, false);
                        c.ParentId = parentCase.Id;
                        c.Candidate_id__c = vtsIdToCandidateMap.get(vtsReg.candidate.id).Id;
                        c.Registration_id__c = vtsIdToRegMap.get(vtsReg.id).Id;
                        c.Exam_id__c = vtsIdToExamMap.get(vtsReg.exam.Id).Id;
                        c.AccountId = testCenter.Id;
                        c.Test_Center_Name__c = testCenter.Id;
                        cases.add(c);
                    }
        
                    if ( cases.size() > 0 ) {
                        insert cases;
                    }
                }
                resp.caseId = parentCase.Id;
                resp.success = true;
    
                // 201 = CREATED
                RestContext.response.statusCode = 201;
            } //END: If ( case.registrations )
            else {
                // 400 = INVALID INPUT
                RestContext.response.statusCode = 400;

                // Prepare Error Response
                resp.success = false;
                resp.faultCode = 'INVALID_INPUT';
                resp.faultMessage = 'Invalid input';
            }
        } catch( Exception e ) {

            // Rollback database changes
            if ( sp != null ) {
            	Database.rollback(sp);
            }
            resp = processException(RestContext.request, RestContext.response, e, 'REST_WS_Case.doPost()');
        }
        System.debug('AA:Response' + resp);
        return resp;
    }

    @HttpPut
    global static REST_WS_Case.Response doPut() {

        System.debug('RestContext.request: ' + RestContext.request);
        System.debug('RestContext.request.requestBody: ' + RestContext.request.requestBody.toString());
        REST_WS_Case.Response resp;
        try {
            String uri = RestContext.request.requestURI;
            String caseId = uri.substring(uri.lastIndexOf('/') + 1);
            if ( caseId == null || caseId == '' || !StringUtility.isValidId(caseId) ) {
                RestContext.response.statusCode = 404;
            } else {

                // Parse JSON
                Map<String, Object> updateableCase = 
                    (Map<String, Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString());
                List<Case> cases = [select Id, Subject from Case where Id = :caseId];
                LIST<Case> childCases = new LIST<Case>();
                if ( !cases.isEmpty() ) {

                    // Set Case fields
                    if ( updateableCase.containsKey('status') ) {
                    	cases[0].Status = (String) updateableCase.get('status');
                    }
                    if ( updateableCase.containsKey('subject') ) {
                    	cases[0].Subject = (String) updateableCase.get('subject');
                    }
                    
                    update cases[0];
                    
                    //Update all child cases if status is closed
                    if(updateableCase.get('status') == 'Closed'){
						childCases = [SELECT Id, Status FROM Case WHERE parentId = :caseId];
                        System.debug('AA:childCases before update ' + childCases);
                        if(childCases.size() > 0){
                            for(Case c : childCases){
                                c.Status = 'Closed';
                            }
                            update childCases;
                        }
                        System.debug('AA:childCases after update ' + childCases);                        
                    }
                    
                    

                    resp = new REST_WS_Case.Response();
                    resp.caseId = caseId;
                    resp.success = true;

                    // 200 = OKAY
                    RestContext.response.statusCode = 200;
                } else {
                    RestContext.response.statusCode = 404;
                }
	        }
        } catch( Exception e ) {
            resp = processException(RestContext.request, RestContext.response, e, 'REST_WS_Case.doPut()');
        }

        return resp;
    }

    @HttpDelete
    global static REST_WS_Case.Response doDelete() {

        REST_WS_Case.Response resp;
        try {
            String uri = RestContext.request.requestURI;
            String caseId = uri.substring(uri.lastIndexOf('/') + 1);
            if ( caseId == null || caseId == '' || !StringUtility.isValidId(caseId) ) {
                RestContext.response.statusCode = 404;
            } else {

                resp = new REST_WS_Case.Response();
                resp.caseId = caseId;

                List<Case> cases = [select Id, Subject from Case where Id = :caseId];
                if ( !cases.isEmpty() ) {
                    delete cases;
                }
                resp.success = true;
                RestContext.response.statusCode = 200;
            }
        } catch (Exception e) {
            resp = processException(RestContext.request, RestContext.response, e, 'REST_WS_Case.doget()');
        }
        return resp;
    }

    private static REST_WS_Case.Response processException(
        	System.RestRequest req, System.RestResponse resp, Exception e, String processName) {

        REST_WS_Case.Response wsResp = new REST_WS_Case.Response();

        // Prepare Error Response
        wsResp.success = false;
        wsResp.faultCode = e.getTypeName();
        wsResp.faultMessage = e.getMessage();

        if ( resp != null) {
            if ( e.getTypeName() == 'System.JSONException' || e.getTypeName() == 'System.TypeException' ) {
                // 400 = BAD REQUEST
                resp.statusCode = 400;
            } else {
                resp.statusCode = 500;
            }
        }

        try {
            insert 
                new Error_Log__c (
                    Process_Type__c = 'Apex Web Service', Process_Function_Name__c = processName,
                    Error_Message__c = e.getStackTraceString() + '\n\n' + e.getMessage(),
                    Related_data__c = 
                    	'URI: ' + req.requestURI + '\n\nParams:' + req.params + '\n\nBody: ' + 
                    	(req.requestBody != null ? req.requestBody.toString() : ''));
        } catch (Exception ex) {
            //Not critical
            System.debug('Error saving error log: ' + ex);
        }

        return wsResp;
    }

    private static void processRoutingError(System.RestRequest req, Exception e, String processName) {

        try {
            insert 
                new Error_Log__c (
                    Process_Type__c = 'Apex Web Service - Routing', Process_Function_Name__c = processName,
                    Error_Message__c = e.getStackTraceString() + '\n\n' + e.getMessage(),
                    Related_data__c = 
                    	'URI: ' + req.requestURI + '\n\nParams:' + req.params + '\n\nBody: ' + req.requestBody.toString());
        } catch (Exception ex) {
            //Not critical
            System.debug('Error saving error log: ' + ex);
        }
    }

    
    private static List<Map<String, Object>> getCasesByWhereClause(String whereClause) {

        List<Map<String, Object>> restCases = new List<Map<String, Object>>();

        String fieldsList = '';
        List<Case_API_Field__c> apiReturnFields = [select Name, Case_Field__c from Case_API_Field__c];
		System.debug('AA:apiReturnFields ' +apiReturnFields);
        
        for ( Case_API_Field__c fld : apiReturnFields ) {
	            fieldsList += fld.Case_Field__c + ', ';                
        }
        //System.debug('fieldsList: ' + fieldsList);

        if ( !String.isBlank(fieldsList) ) {

            if ( fieldsList.contains('VTS_Hold_ID__c') ) {
            	fieldsList = fieldsList.substring(0, fieldsList.length() - 2);
            } else {
                fieldsList += 'VTS_Hold_ID__c';
            }
            
	        System.debug('fieldsList: ' + fieldsList);

            String caseQuery = 'SELECT ' + fieldsList + ' FROM Case WHERE ' + whereClause + ' ORDER BY CreatedDate DESC ' + ' LIMIT 50'; 
            System.debug('caseQuery: ' + caseQuery);
            for ( Case cs : Database.query(caseQuery) ) {
                Map<String, Object> restCase = new Map<String, Object>();
                for ( Case_API_Field__c fld : apiReturnFields ) {
                    if ( fld.Case_Field__c.contains('.') ) {
                        List<String> pieces = fld.Case_Field__c.split('\\.');
                        //System.debug('pieces: ' + pieces);
                        Sobject sobj = cs.getSobject(pieces.get(0));
                        //System.debug('sobj: ' + sobj);
                        if ( sobj != null ) {
                        	restCase.put(fld.Name, sobj.get(pieces.get(1)));
                        }
                    } else {
                        restCase.put(fld.Name, cs.get(fld.Case_Field__c));
                    }
                } //END: For (CaseAPIReturnFields)
                restCases.add(restCase);
            } //END: For (Cases)
        } //END: If (fieldsList)

        return restCases;
    }

    global class Response {
        public Boolean success {get; set;}
        public String caseId {get; set;}
        public String faultCode {get; set;}
        public String faultMessage {get; set;}
    }

    global class WSCase {
        public ID caseId {get; set;}
        public Long registrationId {get; set;}
        public Long candidateId {get; set;}
        public Long examId {get; set;}
        public Long testCenterId {get; set;}
        public String subject {get; set;}
        public String status {get; set;}
    }
}