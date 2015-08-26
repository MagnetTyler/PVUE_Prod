@isTest
private class REST_WS_CaseTest {

    static testMethod void testdoPost()
    {
        DataFactory.createSettings();
        DataFactory.createWebServiceSettings();

        Routing__c routing = DataFactory.createRouting('Missing results');
        System.debug('routing:'+routing);
        List<Step__c> routingSteps = DataFactory.createMissingResultsRoutingSteps(routing.Id);
        System.debug('routingSteps: ' + routingSteps);
        List<Routing_logic__c> routingLogics = DataFactory.createMissingResultsRoutingLogics(routingSteps);

        //Inserting VTSClient, TestCenter
        Account client=TestUtil.createClientAccount(true);
        Account testCenter = TestUtil.createTestCenterAccount(true, 33010); 
        
        String reqbody='{"caseType":"Missing results","registrations":[{"id":428527,"appointmentTime":{"timestampInUTC":933870600000,"displayTimeZone":"America/Chicago","displayTimeZoneUTCOffset":-18000000,"displayTimeZoneSource":"testCenter"},"processStateCode":"Canceled","disposition":"Canceled","status":"CANCELED","exam":{"id":108,"code":"070-059","name":"Internetworking with Microsoft TCP/IP on Microsoft Windows NT 4.0"},"testCenter":{"id":33010,"name":"Knowledge Alliance, Inc."},"candidate":{"id":579659,"clientId":72,"clientCandidateId":"1539075","firstName":"Larry","lastName":"Philbrick"},"deliveryMode":{"id":2,"name":"IBT at VUE Test Center","primaryAddress":{"address1":"PLOT NO 28","address2":"RAJIV NAGAR COLONY","address3":null,"city":"HYDERABAD","state":null,"postalCode":"500045","country":"IND","phone":"91 407802084","extension":null,"phoneCountryCode":null,"addressType":"Work"},"remoteMonitoring":{"id":1,"name":"None"}}},{"id":428526,"appointmentTime":{"timestampInUTC":933870600000,"displayTimeZone":"America/Chicago","displayTimeZoneUTCOffset":-18000000,"displayTimeZoneSource":"testCenter"},"processStateCode":"Canceled","disposition":"Canceled","status":"CANCELED","exam":{"id":168,"code":"070-069","name":"Networking with Microsoft TCP/IP on Microsoft Windows NT 4.0"},"testCenter":{"id":33010,"name":"Knowledge Alliance, Inc."},"candidate":{"id":579669,"clientId":72,"clientCandidateId":"1539675","firstName":"Jason","lastName":"Blinx"},"deliveryMode":{"id":2,"name":"IBT at VUE Test Center","remoteMonitoring":{"id":1,"name":"None"}}}]}';
        RestRequest req =new RestRequest();
        req.requestURI='https://pearsonvuetest--CaseMgtDev.cs3.my.salesforce.com:8443/services/apexrest/Case/v1';
        req.requestBody= blob.valueOf(reqbody);
        req.httpMethod='Post';

        RestResponse resp=new RestResponse();
        RestContext.request = req;
        RestContext.response = resp;
        REST_WS_Case.Response wcase = REST_WS_Case.doPost();
        System.assertEquals(wcase.success, true);
        System.assertEquals(resp.statusCode,201);

        //Test RoutingService
        Case cs = Database.query('select ' + utility.Editablefields('Case') + ' from Case where Id = \'' + wcase.caseId + '\'');
        System.debug('cs.Step__c: ' + cs.Step__c);

        RoutingService rs = new RoutingService();
        cs.Follow_up_with__c = 'Program_Coordinator';
        rs.routeCase(cs); // Move to Step 2
        update cs;

        rs.routeCase(cs); // Move to Step 3
        update cs;

        rs.routeCase(cs); // Move to Step 4
        update cs;

        rs.routeCase(cs); // Move to Step 5
        update cs;

        rs.routeCase(cs); // Move to Step 6
        update cs;
    }
   
    static testMethod void testDoGetByCaseId()
    {
        createTestData();
        testutil.createCaseApiField(true, 'id');
        case cs = [select id, subject from case limit 1];
        RestRequest reqget = new RestRequest();
        String url = 'https://pearsonvuetest--CaseMgtDev.cs3.my.salesforce.com:8443/services/apexrest/Case/v1/' + cs.Id;
        callDoGet(url, reqget);
        
    }
    
    
    static testMethod void testDoGetByRegId()
    {
        createTestData();
        RestRequest reqget = new RestRequest();
        String url = 'https://pearsonvuetest--CaseMgtDev.cs3.my.salesforce.com:8443/services/apexrest/Case/v1/search';
        reqget.addParameter('registrationId', String.valueOf(registration.VTS_Registration_ID__c));
        reqget.params.put('registrationId', String.valueOf(registration.VTS_Registration_ID__c));
        callDoGet(url, reqget);
        
    }
    
 	static testMethod void testdoPut() {
        createTestData();
        RestRequest reqget =new RestRequest();
        reqget.requestURI='https://pearsonvuetest--CaseMgtDev.cs3.my.salesforce.com:8443/services/apexrest/Case/v1/'+cs.Id;

        reqget.requestBody = blob.valueOf('{"ID":"'+cs.id+'","status":"Closed","subject":"Missing results"}');
        reqget.httpMethod = 'PUT';
        RestResponse getresp = new RestResponse();
        RestContext.request = reqget;
        RestContext.response = getresp;
        REST_WS_Case.Response respWS = REST_WS_Case.doPut();
        
        cs =[ select Id, status from case where Id = :cs.Id limit 1];
        system.assertEquals('Closed', cs.Status);
        
    } 
 
    static testMethod void testdoDelete() {	
        createTestData();
        
        RestRequest reqget =new RestRequest();
        reqget.requestURI='https://pearsonvuetest--CaseMgtDev.cs3.my.salesforce.com:8443/services/apexrest/Case/v1/'+cs.Id;
        
        reqget.httpMethod = 'PUT';
        RestResponse getresp = new RestResponse();
        RestContext.request = reqget;
        RestContext.response = getresp;
        REST_WS_Case.Response wsCase = REST_WS_Case.doDelete();
        System.assert(wsCase.success == true);
     	System.assertEquals(getresp.statusCode,200);
        
    } 
    
    private static void callDoGet(String url, RestRequest reqget) {
        
        reqget.requestURI = url;
        reqget.httpMethod = 'GET';
        RestResponse getresp = new RestResponse(); 
        RestContext.request = reqget;
        RestContext.response = getresp; 
        REST_WS_Case.doGet(); 
        System.assert(RestContext.response.responseBody.toString() != null);
        System.assertEquals(getresp.statusCode, 200);
    }
    
    private static testMethod void callDoGet() {

        createTestData();
        
        RestRequest reqget =new RestRequest();
        reqget.requestURI='https://pearsonvuetest--CaseMgtDev.cs3.my.salesforce.com:8443/services/apexrest/Case/v1/search?registrationId='+ registration.VTS_Registration_ID__c;
        reqget.httpMethod = 'GET';
        RestResponse getresp = new RestResponse();
        RestContext.request = reqget;
        RestContext.response = getresp;
        
        RestContext.request.params.put('registrationId', String.valueOf(registration.VTS_Registration_ID__c));
        REST_WS_Case.doGet();
        System.assertEquals(RestContext.response.statusCode, 200);
    }
    
    private static testMethod void callDoGetWithCaseId() {

        createTestData();
        testutil.createcaseApiField(true, 'id');
        RestRequest reqget =new RestRequest();
        reqget.requestURI='https://pearsonvuetest--CaseMgtDev.cs3.my.salesforce.com:8443/services/apexrest/Case/v1/'+ cs.Id;
        reqget.httpMethod = 'GET';
        RestResponse getresp = new RestResponse();
        RestContext.request = reqget;
        RestContext.response = getresp;
        
        REST_WS_Case.doGet();
        System.assertEquals(RestContext.response.statusCode, 200);
    }
    
    //Case with no registration id
    private static testMethod void callDoGetNoRegId() {

        createTestData();
		//testutil.createcaseApiField(true, 'id');
        RestRequest reqget =new RestRequest();
        reqget.requestURI='https://pearsonvuetest--CaseMgtDev.cs3.my.salesforce.com:8443/services/apexrest/Case/v1/';
        reqget.httpMethod = 'GET';
        RestResponse getresp = new RestResponse();
        RestContext.request = reqget;
        RestContext.response = getresp;
        
        RestContext.request.params.put('registrationId', '');
        REST_WS_Case.doGet();
        
        System.assertEquals(RestContext.response.statusCode, 404);
        
    }
   
    private static Registration__c registration;
    private static Case cs;
    private static void createTestData() {
       // DataFactory.createCaseAPIFieldSettings();
        //Inserting VTSClient, TestCenter
        Account client=TestUtil.createClientAccount(true);
        Account testCenter = TestUtil.createTestCenterAccount(true, 33010);

        Exam__c exam = new Exam__c();
        exam.VTS_Exam_ID__c = Math.random() * 10000;
        exam.Exam_Name__c = 'Test Exam ' + exam.VTS_Exam_ID__c;
        exam.Exam_Series_Code__c = 'Exam Code - ' + exam.VTS_Exam_ID__c;
        exam.Client__c = client.Id;
        insert exam;

        Candidate__c candidate = new Candidate__c();
        candidate.VTS_Candidate_ID__c = Math.random() * 10000;
        candidate.CCID__c = 'CCID' + String.valueOf(Math.random() * 10000);
        candidate.First_Name__c = 'John';
        candidate.Last_Name__c = 'Doe ' + candidate.VTS_Candidate_ID__c;
        candidate.Client__c = client.Id;
        insert candidate;

        registration = new Registration__c();
        registration.VTS_Registration_ID__c = Math.random() * 10000;
        registration.Candidate__c = candidate.Id;
        registration.Exam__c = exam.id;
        registration.Test_Center__c = testCenter.id;
        insert registration;

        cs = new Case(Subject = 'Missing results', Status__c = 'Being Created', Topic__c = 'Created by VTS', Status = 'Being Created');
        cs.Candidate_id__c = candidate.Id;
        cs.Registration_id__c = registration.Id;
        cs.Exam_id__c = exam.Id;
        cs.AccountId = testCenter.Id;
        cs.Test_Center_Name__c = testCenter.Id;
        insert cs;
        
       // testutil.createCaseApiField(true,'id');
    }
    
    
    static private String getdata()
    {
        return '{"caseType":"Missing results","registrations":[{"id":428527,"appointmentTime":{"timestampInUTC":933870600000,"displayTimeZone":"America/Chicago","displayTimeZoneUTCOffset":-18000000,"displayTimeZoneSource":"testCenter"},"processStateCode":"Canceled","disposition":"Canceled","status":"CANCELED","exam":{"id":108,"code":"070-059","name":"Internetworking with Microsoft TCP/IP on Microsoft Windows NT 4.0"},"testCenter":{"id":33010,"name":"Knowledge Alliance, Inc."},"candidate":{"id":579659,"clientId":72,"clientCandidateId":"1539075","primaryAddress":{"address1":"PLOT NO 28","address2":"RAJIV NAGAR COLONY","address3":null,"city":"HYDERABAD","state":null,"postalCode":"500045","country":"IND","phone":"91 407802084","extension":null,"phoneCountryCode":null,"addressType":"Work"},"firstName":"Larry","lastName":"Philbrick"},"deliveryMode":{"id":2,"name":"IBT at VUE Test Center","remoteMonitoring":{"id":1,"name":"None"}}},{"id":428526,"appointmentTime":{"timestampInUTC":933870600000,"displayTimeZone":"America/Chicago","displayTimeZoneUTCOffset":-18000000,"displayTimeZoneSource":"testCenter"},"processStateCode":"Canceled","disposition":"Canceled","status":"CANCELED","exam":{"id":168,"code":"070-069","name":"Networking with Microsoft TCP/IP on Microsoft Windows NT 4.0"},"testCenter":{"id":33010,"name":"Knowledge Alliance, Inc."},"candidate":{"id":579669,"clientId":72,"clientCandidateId":"1539675","firstName":"Jason","lastName":"Blinx"},"deliveryMode":{"id":2,"name":"IBT at VUE Test Center","remoteMonitoring":{"id":1,"name":"None"}}}]}';
        
    }
    static private void createCase()
    {
        String reqbody=getdata();
        RestRequest req =new RestRequest();
        req.requestURI='https://pearsonvuetest--CaseMgtDev.cs3.my.salesforce.com:8443/services/apexrest/Case/v1';
        req.requestBody = blob.valueOf(reqbody);
        req.httpMethod='Post';
        RestResponse resp = new RestResponse();
        RestContext.request = req;
        RestContext.response = resp;
        REST_WS_Case.Response wcase = REST_WS_Case.doPost();
        System.debug('wcase::'+ wcase);
    }
 
    static testMethod void negTestDoPost()
    {
        String reqbody=+'{  {}}'+getdata();
        RestRequest req =new RestRequest();
        req.requestURI='https://pearsonvuetest--CaseMgtDev.cs3.my.salesforce.com:8443/services/apexrest/Case/v1';
        req.requestBody= blob.valueOf(reqbody);
        req.httpMethod='Post';
        RestResponse resp=new RestResponse();
        RestContext.request = req;
        RestContext.response = resp;
        REST_WS_Case.Response wcase=REST_WS_Case.doPost();
        System.assertEquals(wcase.success, false);
        System.assertEquals(resp.statusCode,400);
       
    }
    
    static testMethod void negTestDoGet()
    {
       
        RestRequest reqget =new RestRequest();
        reqget.requestURI='https://pearsonvuetest--CaseMgtDev.cs3.my.salesforce.com:8443/services/apexrest/Case/v1/552547755';
        reqget.httpMethod='GET';
        RestResponse getresp=new RestResponse();
        RestContext.request = reqget;
        RestContext.response = getresp;
        REST_WS_Case.doGet();
        
        //System.assertEquals(getresp.statusCode, 404);
        
    }
    static testMethod void secNegTestDoGet()
    {
       
        RestRequest reqget =new RestRequest();
        //reqget.requestURI='https://pearsonvuetest--CaseMgtDev.cs3.my.salesforce.com:8443/services/apexrest/Case/v1/552547755';
        reqget.httpMethod='GET';
        RestResponse getresp=new RestResponse();
        RestContext.request = reqget;
        RestContext.response = getresp;
        REST_WS_Case.doGet();
     
    }
     static testMethod void thirdNegTestDoGet()
    {
       
        RestRequest reqget =new RestRequest();
        reqget.requestURI='https://pearsonvuetest--CaseMgtDev.cs3.my.salesforce.com:8443/services/apexrest/Case/v1/jkjj255';
        reqget.httpMethod='GET';
        RestResponse getresp=new RestResponse();
        RestContext.request = reqget;
        RestContext.response = getresp;
        REST_WS_Case.doGet();
        
        //System.assertEquals(getresp.statusCode, 404);
        
    }
    
    
      static testMethod void NegtestdoPut()
    {
        //Inserting Client, Test Center
        //Account client=TestUtil.createClientAccount(true);
        //Account testCenter = TestUtil.createTestCenterAccount(true, 33010);
        createTestData();
        createCase();
        List<case> caseid=[Select Id from case];
        RestRequest reqget =new RestRequest();
        reqget.requestURI='https://pearsonvuetest--CaseMgtDev.cs3.my.salesforce.com:8443/services/apexrest/Case/v1/'+caseid[0].Id;
        REST_WS_Case.WSCase wsCase = new REST_WS_Case.WSCase();
        wsCase.status = 'tncmcxnkvbcxnbxkbcvkkkkj';
        reqget.requestBody= blob.valueOf('{caseid:54556,{');
        reqget.httpMethod='PUT';
        RestResponse getresp=new RestResponse();
        RestContext.request = reqget;
        RestContext.response = getresp;
        REST_WS_Case.Response respWS=REST_WS_Case.doPut();
        //system.assertEquals(getresp.statusCode, 400);
    }
    

     static testMethod void negTestDoDelete()
    {	createCase();
        List<case> caseid=[Select Id from case];
        RestRequest reqget =new RestRequest();
        reqget.requestURI='https://pearsonvuetest--CaseMgtDev.cs3.my.salesforce.com:8443/services/apexrest/Case/v1/'+caseid;
        REST_WS_Case.Response wsCase = new REST_WS_Case.Response();
        
        reqget.httpMethod='PUT';
        RestResponse getresp=new RestResponse();
        RestContext.request = reqget;
        RestContext.response = getresp;
        wsCase=REST_WS_Case.doDelete();
       
     	//System.assertEquals(getresp.statusCode,404);
    } 
    
    static testMethod void secNegTestDoDelete()
    {	createCase();
        List<case> caseid=[Select Id from case];
        RestRequest reqget =new RestRequest();
        //reqget.requestURI='https://pearsonvuetest--CaseMgtDev.cs3.my.salesforce.com:8443/services/apexrest/Case/v1/'+caseid;
        REST_WS_Case.Response wsCase = new REST_WS_Case.Response();
       
        reqget.httpMethod='PUT';
        RestResponse getresp=new RestResponse();
        RestContext.request = reqget;
        RestContext.response = getresp;
        wsCase=REST_WS_Case.doDelete();
        
    }
	
}