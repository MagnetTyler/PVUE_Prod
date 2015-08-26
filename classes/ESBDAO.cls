public virtual with sharing class ESBDAO {
    
   // private Web_Service_Setting__c wsConfig = Web_Service_Setting__c.getAll().get('ESB');
    public HttpResponse getResponse(String requestUri) {
        return getResponse(requestUri, null);
    }
    
    public HttpResponse getResponse(String requestUri, Map<String, String> headers) {
        return doRequest(requestUri, 'GET', null, headers);
    }
    
    public HttpResponse doPost(String requestUri, String body) {
        return doPost(requestUri, body, null);
    }

    public HttpResponse doPost(String requestUri, String body, Map<String, String> headers) {
        return doRequest(requestUri, 'POST', body, headers);
    }

    private HttpResponse doRequest(String requestUri, String method, String body, Map<String, String> headers) {
        
        System.debug('requestUri:' + requestUri);
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:ESB' + requestUri);
        req.setMethod(method);
        req.setTimeout(10000);
          /*    req.setEndpoint(this.wsConfig.Endpoint__c + requestUri);
       req.setClientCertificateName(this.wsConfig.Username__c);
        if ( this.wsConfig.Timeout__c != null ) {
          req.setTimeout(this.wsConfig.Timeout__c.intValue());
       }*/

        if ( body != null && body != '' ) {
            req.setHeader('Content-Type', 'application/json');
            req.setBody(body);
        }
        System.debug('req.Body:' + req.getBody());

        if ( headers != null && !headers.isEmpty() ) {
            for ( String hdrName : headers.keySet() ) {
                req.setHeader(hdrName, headers.get(hdrName));
            }
        }
        
        String casAccessToken = SessionUtility.getCASAccessToken();
        System.debug('casAccessToken: ' + casAccessToken);
        if ( casAccessToken != null ) {
            req.setHeader('Authorization', 'Bearer ' + SessionUtility.getCASAccessToken());
           // req.setHeader('Authorization', 'Bearer ' + SessionUtility.refreshCASAccessToken());
        }
        
        
        System.debug('req:' + req);
        
        System.debug('req heaers:' + req.getHeader('Authorization'));
        HttpResponse res = doCallout(h, req);
        //String resp = res.getBody();
        System.debug('resp: ' + res.getBody());

        return res;
    }

    public virtual HttpResponse doCallout(Http h, HttpRequest req) {
        return h.send(req);
    }

    public VTS_Candidate getCandidateByCandidateId(Long candidateId) {
        HttpResponse response = getResponse('/v1/Candidate/ID/' + candidateId);
        VTS_Candidate candidate;
        try {
            if ( response.getStatusCode() != 404 ) {
                candidate = (VTS_Candidate) JSON.deserialize(response.getBody(), VTS_Candidate.class);
                if ( candidate.candidateid == null ) {
                    throw processErrorResponse(response, null);
                }
            }
        } catch (Exception e) {
            throw processErrorResponse(response, e);
        }
        return candidate;
    }

    public VTS_TestCenter getTestCenterByTestCenterId(Long testCenterId){
        return getTestCenterByTestCenterId(testCenterId, null);
    }
    
    public VTS_TestCenter getTestCenterByTestCenterId(Long testCenterId, LIST<String> fields){

        String params = '';
        if ( fields != null ) {
            params += '?fields=';
            if(fields.size() > 0){
                for(String s : fields){
                    params += s + '::';
                }
            }
            params += 'id';
        }

        HttpResponse response = getResponse('/v1/TestCenter/ID/' + testCenterId + params);
        VTS_TestCenter testCenter;
        try {
            if ( response.getStatusCode() != 404 ) {
                testCenter = (VTS_TestCenter) JSON.deserialize(response.getBody(), VTS_TestCenter.class);
                if ( testCenter.id == null ) {
                    throw processErrorResponse(response, null);
                }
            }
        } catch (Exception e) {
            throw processErrorResponse(response, e);
        }
        return testCenter;
    }
    
    
    public String getcandidates_serialized(vts_candidate.searchCriteria criteria){
        
        HttpResponse response = doPost('/v1/Candidate/search', JSON.serialize(criteria));
        return response.getBody();
        
    }
    
    public List<VTS_Candidate> getCandidatesByCriteria(VTS_Candidate.SearchCriteria criteria) {
        //HttpResponse response = getcandidates_serialized(criteria);
        HttpResponse response = doPost('/v1/Candidate/search', JSON.serialize(criteria));
        
        List<VTS_Candidate> candidates;
        try {
            candidates = (List<VTS_Candidate>) JSON.deserialize(response.getBody(), List<VTS_Candidate>.class);
            if ( candidates.size() == 1 && candidates[0].id == null ) {
                throw processErrorResponse(response, null);
            }
        } catch (Exception e) {
            throw processErrorResponse(response, e);
        }
        
        return candidates;
    }


    public List<VTS_Candidate> getCandidatesByCriteria(Map<string,object> criteria) {
        //HttpResponse response = getcandidates_serialized(criteria);
        String queryString = '';
        for ( String paramName : criteria.keySet() ) {
            Object paramValue = criteria.get(paramName);
            queryString += paramName + '=' + paramValue + '&';
        }
        System.debug('queryString: ' + queryString);
        if ( queryString != '' ) {
            queryString = queryString.substring(0, queryString.length() - 1);
        }
        //getResponse('/v1/Candidate/search?' + queryString);
        HttpResponse response =  doPost('/v1/Candidate/search', JSON.serialize(criteria));
        system.debug('AZ:: ' + response );
        
        List<VTS_Candidate> candidates;
        try {
            candidates = (List<VTS_Candidate>) JSON.deserialize(response.getBody(), List<VTS_Candidate>.class);
            if ( candidates.size() == 1 && candidates[0].id == null ) {
                throw processErrorResponse(response, null);
            }
        } catch (Exception e) {
            throw processErrorResponse(response, e);
        }
        
        return candidates;
    }

    
    public VTS_Registration getRegistrationByRegistrationId(Long registrationId) {
        HttpResponse response = getResponse('/v1/ExamRegistrations/' + registrationId);
        VTS_Registration registration;
        try {
            if ( response.getStatusCode() != 404 ) {
                registration = (VTS_Registration) JSON.deserialize(response.getBody(), VTS_Registration.class);
                if ( registration.id == null ) {
                    throw processErrorResponse(response, null);
                }
            }
        } catch (Exception e) {
            throw processErrorResponse(response, e);
        }
        return registration;
    }
    
    public List<VTS_Registration> getRegistrationsByCandidateId(Long candidateId) {
        return getRegistrationsByCandidateId(candidateId, null, null);
    }
    
    public List<VTS_Registration> getRegistrationsByCandidateId(Long candidateId, Date startDate, Date endDate) {
        Map<String, Object> criteria = new Map<String, Object>{'CandidateID' => candidateId};
        if ( startDate != null ) {
            criteria.put('appointmentSearchStartDate', String.valueOf(startDate));
        }
        if ( endDate != null ) {
            criteria.put('appointmentSearchEndDate', String.valueOf(endDate));
        }
        return getRegistrationsByCriteria(criteria);
    }
    
    public List<VTS_Registration> getRegistrationsByClientIdAndSeletedFields( Map<String, Object> selectedFieldsMap) {
        return getRegistrationsByCriteria( selectedFieldsMap );
    }
    
    public List<VTS_Registration> getRegistrationsByClientIdAndClientCandidateId(Long clientId, String clientCandidateId) {
        return 
            getRegistrationsByCriteria(
                new Map<String, Object>{'ClientID' => clientId, 'ClientCandidateID' => clientCandidateId});
    }
    /*
    public List<VTS_Registration> getRegistrationsByClientIdAndPhoneNumber(Long clientId, String phoneNumber) {
        return 
            getRegistrationsByCriteria(
                new Map<String, Object>{'ClientID' => clientId, 'phone' => phoneNumber});
    }
    
    public List<VTS_Registration> getRegistrationsByClientIdAndEmailAddress(Long clientId, String emailAddress) {
        return 
            getRegistrationsByCriteria(
                new Map<String, Object>{'ClientID' => clientId, 'email' => emailAddress});
    }
    
    public List<VTS_Registration> getRegistrationsByClientIdAndName(Long clientId, String fName, String lName) {
        return 
            getRegistrationsByCriteria(
                new Map<String, Object>{'ClientID' => clientId, 'firstName' => fName, 'lastName' => lName});
    }
    */
    public List<VTS_Registration> getRegistrationsByTestCenterId(Long testcenterId) {
        return getRegistrationsByTestCenterId(testcenterId, null, null);
    }
    
    public List<VTS_Registration> getRegistrationsByTestCenterId(Long testcenterId, Date startDate, Date endDate) {
        Map<String, Object> criteria = new Map<String, Object>{'testCenterId' => testcenterId};
            if ( startDate != null ) {
                criteria.put('appointmentSearchStartDate', String.valueOf(startDate));
            }
        if ( endDate != null ) {
            criteria.put('appointmentSearchEndDate', String.valueOf(endDate));
        }
        return getRegistrationsByCriteria(criteria);
    }
    
    public List<VTS_Registration> getRegistrationsByCriteria(Map<String, Object> criteria) {

        String queryString = '';
        for ( String paramName : criteria.keySet() ) {
            Object paramValue = criteria.get(paramName);
            queryString += paramName + '=' + paramValue + '&';
        }
        System.debug('queryString: ' + queryString);
        if ( queryString != '' ) {
            queryString = queryString.substring(0, queryString.length() - 1);
        }
        
        HttpResponse response = getResponse('/v1/ExamRegistrations?' + queryString);
       
        List<VTS_Registration> registrations;
        try {
            System.debug('RK: response:'+response);
            registrations = (List<VTS_Registration>) JSON.deserialize(response.getBody(), List<VTS_Registration>.class);
        } catch (Exception e) {
             System.debug('RK: response:1'+response);
            throw processErrorResponse(response, e);
        }
        return registrations;
    }
    
    public VTS_Hold createIncidentResultHold(Long registrationId, String comment) {
        return createResultHold(registrationId, comment, 'IncidentHold', null);
    }

    


    public VTS_Hold createResultHold(Long registrationId, String comment, String holdTypeCode, long vssTechId) {

        VTS_Hold requestHold = new VTS_Hold();
        //requestHold.registrationID = registrationId;
        //requestHold.comment = comment;
        //requestHold.holdTypeCode = holdTypeCode;
        map<string,string> regobject = new map<string,string>{'id'=>string.valueof(registrationId)};

        map<string,object> criteria = new map<string,object>{'registration'=>regobject, 'holdTypeCode'=>holdTypeCode, 'comment'=>comment, 'vssTechId'=>vssTechId
                                                             };

        HttpResponse response = doPost('/v1/ExamResults/placehold', JSON.serialize(criteria));
        VTS_Hold hold;
        try {
            hold = (VTS_Hold) JSON.deserialize(response.getBody(), VTS_Hold.class);
            if ( hold.id == null ) {
                throw processErrorResponse(response, null);
            }
        } catch (Exception e) {
            throw processErrorResponse(response, e);
        }
        return hold;
    }

    //public VTS_Hold releaseResultHold(Long resultHoldId) {
    //}

    private ESBException processErrorResponse(HttpResponse resp, Exception e) {
        
        String response = resp.getBody();
        ESBException esbExcep;
        System.debug('AA:response: '+response);
        if ( response != null && response != '' ) {
            
            //Map<String, Object> vtsError;
            MAP<String, Object> esbError;
            
            esbError = (MAP<String, Object>)JSON.deserializeUntyped(response);
            
            System.debug('AA:esbError' + esbError);
            
            String faultCode;
            if(esbError.containsKey('faultCode')){
                faultCode = (String) esbError.get('faultCode');
            }
            String faultReason = (String) esbError.get('faultMessage');
            esbExcep = new ESBException(faultCode + '-' + faultReason, e);
            esbExcep.faultCode = faultCode;
            esbExcep.faultReason = faultReason;
            
        } else {
            esbExcep = new ESBException('Unexpected error', e);
        }
        return esbExcep;
    }
}