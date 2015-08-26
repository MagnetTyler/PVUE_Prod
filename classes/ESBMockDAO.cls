public with sharing class ESBMockDAO extends ESBDAO {
    
    public override HttpResponse doCallout(Http h, HttpRequest req) {
        String response = '';
        
        String uri = req.getEndpoint();
        System.debug('uri: ' + uri);
        // if ( uri.contains('/CandidateServices/') ) {
        //ESBDAO.getCandidateByCandidateId
        if(uri.contains('/v1/Candidate/ID/')) {// ---/Services/Professional/VTS/v1/Candidate/ID/
            
            //ESB Error
            if(uri.contains('/ID/0')) {//"id":1204452,
                response ='{"firstName":"Gopala Krishna","lastName":"P","middleInitial":null,"salutation":null,"suffix":null,"email":null,"dob":null,"primaryAddress":{"address1":"PLOT NO 28","address2":"RAJIV NAGAR COLONY","address3":null,"city":"HYDERABAD","state":null,"postalCode":"500045","country":"IND","phone":"91 407802084","extension":null,"phoneCountryCode":null,"addressType":"Work"},"alternateAddresses":[],"clientCandidates":[{"clientId":74,"clientCandidateId":"SP2110037"},{"clientId":109,"clientCandidateId":"SP2110037"},{"clientId":135,"clientCandidateId":"SP2110037"}]}';
                
            }
            else if(uri.contains('/ID/-1111')) {
                response = '{"faultCode":"UNSUPPORTED_METHOD","faultMessage":"HTTP Method POST not allowed. Please check the HTTP header for allowed methods."}';
            }
            else if(uri.contains('/ID/-9999')) {
                response = '{"faultCode":"invalid_token","faultMessage":"Invalid token"}';
            }
            //success case
            else if( uri.contains('/ID/') ) {
                response = '{"candidateId":972819,"firstName":"Gopala Krishna","lastName":"P","middleInitial":null,"salutation":null,"suffix":null,"email":null,"dob":null,"primaryAddress":{"address1":"PLOT NO 28","address2":"RAJIV NAGAR COLONY","address3":null,"city":"HYDERABAD","state":null,"postalCode":"500045","country":"IND","phone":"91 407802084","extension":null,"phoneCountryCode":null,"addressType":"Work"},"alternateAddresses":[],"clientCandidates":[{"clientId":74,"clientCandidateId":"SP2110037"},{"clientId":109,"clientCandidateId":"SP2110037"},{"clientId":135,"clientCandidateId":"SP2110037"}]}';
                // response ='{"id":1204452,"status":"unknown","disposition":"unknown","appointmentTime":{"timestampInUTC":961444800000,"displayTimeZone":"us","displayTimeZoneUTCOffset":65556545,"displayTimeZoneSource":"abc"},"processStateCode":"ResultAccepted","exam":{"id":561,"code":"051-651","name":"Tryout - Advanced NDS Tools and                        Diagnostics Practical Exam"},"testCenter":{"id":42190,"name":"CS Holdings Ltd. (Durban)","version":"0.767","updateTrack":"03 may 2015","lastRMACompleted":899898,"lastUpdate":7588,"updateStatus":"success","tedStatus":"unknown","activeWorkstations":"unknown","athenaVersion":"8"},"candidate":{"id":214302,"clientId":54,"clientCandidateId":"N714140","firstName":"Marcus","suffix":"unknown","salutation":"mr.","dob":"2011-03-22","email":"mar@scs.com","middleInitial":"mar","lastName":"Claus","primaryAddress":{"extension":"9888","city":"NY","phone":"78899","phoneCountryCode":"75778","postalCode":"798999","state":"washington","address1":"unknown","address2":"nknown","addressType":"residential","address3":"unkown","country":"USA"},"clientCandidates":[{"clientId":"8999","clientCandidateId":"8888"}],"alternateAddresses":[{"extension":"9888","city":"NY","phone":"78899","postalCode":"798999","state":"washington","address1":"unknown","address2":"nknown","addressType":"residential","address3":"unkown","country":"USA"}]},"deliveryMode":{"id":561,"name":"dev mode","remoteMonitoring":{"id":561,"name":"abc"}},"clientCandidates:":{"clientId":9788,"clientCandidateId":"78999"}}';
                
            }
            //else if(uri.contains('/v1/Candidate') ){
			//	response ='[{"id":1204452,"status":"unknown","disposition":"unknown","appointmentTime":{"timestampInUTC":961444800000,"displayTimeZone":"us","displayTimeZoneUTCOffset":65556545,"displayTimeZoneSource":"abc"},"processStateCode":"ResultAccepted","exam":{"id":561,"code":"051-651","name":"Tryout - Advanced NDS Tools and                        Diagnostics Practical Exam"},"testCenter":{"id":42190,"name":"CS Holdings Ltd. (Durban)","version":"0.767","updateTrack":"03 may 2015","lastRMACompleted":899898,"lastUpdate":7588,"updateStatus":"success","tedStatus":"unknown","activeWorkstations":"unknown","athenaVersion":"8"},"candidate":{"id":214302,"clientId":54,"clientCandidateId":"N714140","firstName":"Marcus","suffix":"unknown","salutation":"mr.","dob":"2011-03-22","email":"mar@scs.com","middleInitial":"mar","lastName":"Claus","primaryAddress":{"extension":"9888","city":"NY","phone":"78899","phoneCountryCode":"75778","postalCode":"798999","state":"washington","address1":"unknown","address2":"nknown","addressType":"residential","address3":"unkown","country":"USA"},"clientCandidates":[{"clientId":"8999","clientCandidateId":"8888"}],"alternateAddresses":[{"extension":"9888","city":"NY","phone":"78899","postalCode":"798999","state":"washington","address1":"unknown","address2":"nknown","addressType":"residential","address3":"unkown","country":"USA"}]},"deliveryMode":{"id":561,"name":"dev mode","remoteMonitoring":{"id":561,"name":"abc"}},"clientCandidates:":{"clientId":9788,"clientCandidateId":"78999"}}]';
			//		//'[{"id": 12345,"clientID":864,"firstName":"Marie"}]';
			//}
        }
        //EBSDAO.getCandidatesByCriteria
        else if(uri.contains('/v1/Candidate/search')) {
            //success case
            if(req.getBody().contains('2506925')) {
                System.debug('RK: req body:'+req.getBody());
                response = '[{"id":1204452,"status":"unknown","disposition":"unknown","appointmentTime":{"timestampInUTC":961444800000,"displayTimeZone":"us","displayTimeZoneUTCOffset":65556545,"displayTimeZoneSource":"abc"},"processStateCode":"ResultAccepted","exam":{"id":561,"code":"051-651","name":"Tryout - Advanced NDS Tools and                        Diagnostics Practical Exam"},"testCenter":{"id":42190,"name":"CS Holdings Ltd. (Durban)","version":"0.767","updateTrack":"03 may 2015","lastRMACompleted":899898,"lastUpdate":7588,"updateStatus":"success","tedStatus":"unknown","activeWorkstations":"unknown","athenaVersion":"8"},"candidate":{"id":214302,"clientId":54,"clientCandidateId":"N714140","firstName":"Marcus","suffix":"unknown","salutation":"mr.","dob":"2011-03-22","email":"mar@scs.com","middleInitial":"mar","lastName":"Claus","primaryAddress":{"extension":"9888","city":"NY","phone":"78899","phoneCountryCode":"75778","postalCode":"798999","state":"washington","address1":"unknown","address2":"nknown","addressType":"residential","address3":"unkown","country":"USA"},"clientCandidates":[{"clientId":"8999","clientCandidateId":"8888"}],"alternateAddresses":[{"extension":"9888","city":"NY","phone":"78899","postalCode":"798999","state":"washington","address1":"unknown","address2":"nknown","addressType":"residential","address3":"unkown","country":"USA"}]},"deliveryMode":{"id":561,"name":"dev mode","remoteMonitoring":{"id":561,"name":"abc"}},"clientCandidates:":{"clientId":9788,"clientCandidateId":"78999"}}]';
                
            }
            //ESB Error
            else if(req.getBody().contains('-1111')) {
                response = '{"faultCode":"UNSUPPORTED_METHOD","faultMessage":"HTTP Method GET not allowed. Please check the HTTP header for allowed methods."}';
            }
            else if(req.getBody().contains('-9999')) {
                response = '{"faultCode":"invalid_token","faultMessage":"Invalid token"}';
            }
        }
        
        // } else 
        else if ( uri.contains('/ExamRegistrations') ) {
            // ESBDAO.getRegistrationsByCandidateId()
            if ( uri.contains('/ID/') ) {//"id":428527,
                response ='{"id":428527,"status":"unknown","disposition":"unknown","appointmentTime":{"timestampInUTC":961444800000,"displayTimeZone":"us","displayTimeZoneUTCOffset":65556545,"displayTimeZoneSource":"abc"},"processStateCode":"ResultAccepted","exam":{"id":561,"code":"051-651","name":"Tryout - Advanced NDS Tools and                        Diagnostics Practical Exam"},"testCenter":{"id":42190,"name":"CS Holdings Ltd. (Durban)","version":"0.767","updateTrack":"03 may 2015","lastRMACompleted":899898,"lastUpdate":7588,"updateStatus":"success","tedStatus":"unknown","activeWorkstations":"unknown","athenaVersion":"8"},"candidate":{"id":214302,"clientId":54,"clientCandidateId":"N714140","firstName":"Marcus","suffix":"unknown","salutation":"mr.","dob":"2011-03-22","email":"mar@scs.com","middleInitial":"mar","lastName":"Claus","primaryAddress":{"extension":"9888","city":"NY","phone":"78899","phoneCountryCode":"75778","postalCode":"798999","state":"washington","address1":"unknown","address2":"nknown","addressType":"residential","address3":"unkown","country":"USA"},"clientCandidates":[{"clientId":"8999","clientCandidateId":"8888"}],"alternateAddresses":[{"extension":"9888","city":"NY","phone":"78899","postalCode":"798999","state":"washington","address1":"unknown","address2":"nknown","addressType":"residential","address3":"unkown","country":"USA"}]},"deliveryMode":{"id":561,"name":"dev mode","remoteMonitoring":{"id":561,"name":"abc"}},"clientCandidates:":{"clientId":9788,"clientCandidateId":"78999"}}';
                
            }
            if ( uri.contains('428527') ) {//"id":428527,
                response ='{"id":428527,"status":"unknown","disposition":"unknown","appointmentTime":{"timestampInUTC":961444800000,"displayTimeZone":"us","displayTimeZoneUTCOffset":65556545,"displayTimeZoneSource":"abc"},"processStateCode":"ResultAccepted","exam":{"id":561,"code":"051-651","name":"Tryout - Advanced NDS Tools and                        Diagnostics Practical Exam"},"testCenter":{"id":42190,"name":"CS Holdings Ltd. (Durban)","version":"0.767","updateTrack":"03 may 2015","lastRMACompleted":899898,"lastUpdate":7588,"updateStatus":"success","tedStatus":"unknown","activeWorkstations":"unknown","athenaVersion":"8"},"candidate":{"id":214302,"clientId":54,"clientCandidateId":"N714140","firstName":"Marcus","suffix":"unknown","salutation":"mr.","dob":"2011-03-22","email":"mar@scs.com","middleInitial":"mar","lastName":"Claus","primaryAddress":{"extension":"9888","city":"NY","phone":"78899","phoneCountryCode":"75778","postalCode":"798999","state":"washington","address1":"unknown","address2":"nknown","addressType":"residential","address3":"unkown","country":"USA"},"clientCandidates":[{"clientId":"8999","clientCandidateId":"8888"}],"alternateAddresses":[{"extension":"9888","city":"NY","phone":"78899","postalCode":"798999","state":"washington","address1":"unknown","address2":"nknown","addressType":"residential","address3":"unkown","country":"USA"}]},"deliveryMode":{"id":561,"name":"dev mode","remoteMonitoring":{"id":561,"name":"abc"}},"clientCandidates:":{"clientId":9788,"clientCandidateId":"78999"}}';
            }
            // ESBDAO.getRegistrationsByClientIdAndClientCandidateId()
            //else 
            if ( uri.contains('/-1111') ) {
                response = '{"faultCode":"invalid_token","faultMessage":"Invalid token"}';
            } else if ( uri.contains('/-9999') ) {
                response = '{"faultCode":"Server","faultMessage":"An error occurred whilst performing an SSL socket operation; connect; java.net.ConnectException: Connection refused"}';
            }
            else if ( uri.contains('ClientCandidateID=') && uri.contains('ClientID=') ) {
                System.debug('RK: uri:'+uri);
                response ='[{"id":1204452,"status":"unknown","disposition":"unknown","appointmentTime":{"timestampInUTC":961444800000,"displayTimeZone":"us","displayTimeZoneUTCOffset":65556545,"displayTimeZoneSource":"abc"},"processStateCode":"ResultAccepted","exam":{"id":561,"code":"051-651","name":"Tryout - Advanced NDS Tools and                        Diagnostics Practical Exam"},"testCenter":{"id":42190,"name":"CS Holdings Ltd. (Durban)","version":"0.767","updateTrack":"03 may 2015","lastRMACompleted":899898,"lastUpdate":7588,"updateStatus":"success","tedStatus":"unknown","activeWorkstations":"unknown","athenaVersion":"8"},"candidate":{"id":214302,"clientId":54,"clientCandidateId":"N714140","firstName":"Marcus","suffix":"unknown","salutation":"mr.","dob":"2011-03-22","email":"mar@scs.com","middleInitial":"mar","lastName":"Claus","primaryAddress":{"extension":"9888","city":"NY","phone":"78899","phoneCountryCode":"75778","postalCode":"798999","state":"washington","address1":"unknown","address2":"nknown","addressType":"residential","address3":"unkown","country":"USA"},"clientCandidates":[{"clientId":"8999","clientCandidateId":"8888"}],"alternateAddresses":[{"extension":"9888","city":"NY","phone":"78899","postalCode":"798999","state":"washington","address1":"unknown","address2":"nknown","addressType":"residential","address3":"unkown","country":"USA"}]},"deliveryMode":{"id":561,"name":"dev mode","remoteMonitoring":{"id":561,"name":"abc"}},"clientCandidates:":{"clientId":9788,"clientCandidateId":"78999"}}]';
                
                
            }else if ( uri.contains('appointmentSearchStartDate=') && uri.contains('appointmentSearchEndDate=') ) {
                System.debug('RK: uri:'+uri);
                response ='[{"id":1204452,"status":"unknown","disposition":"unknown","appointmentTime":{"timestampInUTC":961444800000,"displayTimeZone":"us","displayTimeZoneUTCOffset":65556545,"displayTimeZoneSource":"abc"},"processStateCode":"ResultAccepted","exam":{"id":561,"code":"051-651","name":"Tryout - Advanced NDS Tools and                        Diagnostics Practical Exam"},"testCenter":{"id":42190,"name":"CS Holdings Ltd. (Durban)","version":"0.767","updateTrack":"03 may 2015","lastRMACompleted":899898,"lastUpdate":7588,"updateStatus":"success","tedStatus":"unknown","activeWorkstations":"unknown","athenaVersion":"8"},"candidate":{"id":214302,"clientId":54,"clientCandidateId":"N714140","firstName":"Marcus","suffix":"unknown","salutation":"mr.","dob":"2011-03-22","email":"mar@scs.com","middleInitial":"mar","lastName":"Claus","primaryAddress":{"extension":"9888","city":"NY","phone":"78899","phoneCountryCode":"75778","postalCode":"798999","state":"washington","address1":"unknown","address2":"nknown","addressType":"residential","address3":"unkown","country":"USA"},"clientCandidates":[{"clientId":"8999","clientCandidateId":"8888"}],"alternateAddresses":[{"extension":"9888","city":"NY","phone":"78899","postalCode":"798999","state":"washington","address1":"unknown","address2":"nknown","addressType":"residential","address3":"unkown","country":"USA"}]},"deliveryMode":{"id":561,"name":"dev mode","remoteMonitoring":{"id":561,"name":"abc"}},"clientCandidates:":{"clientId":9788,"clientCandidateId":"78999"}}]';
                
            }
            // ESBDAO.getRegistrationsByClientIdAndClientCandidateId()
            else if ( uri.contains('CandidateID=') ) {
                System.debug('RK: i am here');
                response =  '[{"id":1204452,"status":"unknown","disposition":"unknown","appointmentTime":{"timestampInUTC":961444800000,"displayTimeZone":"us","displayTimeZoneUTCOffset":65556545,"displayTimeZoneSource":"abc"},"processStateCode":"ResultAccepted","exam":{"id":561,"code":"051-651","name":"Tryout - Advanced NDS Tools and                        Diagnostics Practical Exam"},"testCenter":{"id":42190,"name":"CS Holdings Ltd. (Durban)","version":"0.767","updateTrack":"03 may 2015","lastRMACompleted":899898,"lastUpdate":7588,"updateStatus":"success","tedStatus":"unknown","activeWorkstations":"unknown","athenaVersion":"8"},"candidate":{"id":214302,"clientId":54,"clientCandidateId":"N714140","firstName":"Marcus","suffix":"unknown","salutation":"mr.","dob":"2011-03-22","email":"mar@scs.com","middleInitial":"mar","lastName":"Claus","primaryAddress":{"extension":"9888","city":"NY","phone":"78899","phoneCountryCode":"75778","postalCode":"798999","state":"washington","address1":"unknown","address2":"nknown","addressType":"residential","address3":"unkown","country":"USA"},"clientCandidates":[{"clientId":"8999","clientCandidateId":"8888"}],"alternateAddresses":[{"extension":"9888","city":"NY","phone":"78899","postalCode":"798999","state":"washington","address1":"unknown","address2":"nknown","addressType":"residential","address3":"unkown","country":"USA"}]},"deliveryMode":{"id":561,"name":"dev mode","remoteMonitoring":{"id":561,"name":"abc"}},"clientCandidates:":{"clientId":9788,"clientCandidateId":"78999"}}]';
                /*'[{'+
'"id": 1204452,'+
'  "appointmentTime": { '+
'   "timestampInUTC": 961444800000,'+
'  "displayTimeZone": "us",'+
' "displayTimeZoneUTCOffset": 65556545,'+
' "displayTimeZoneSource": "abc" '+ 
'    },'+
'   "processStateCode": "ResultAccepted", '+
'  "exam": {'+
'   "id": 561, '+
' "code": "051-651", '+
' "name": "Tryout - Advanced NDS Tools and Diagnostics Practical Exam" '+
'},'+
' "testCenter": {'+
' "id": 42190,'+
' "name": "CS Holdings Ltd. (Durban)" '+
'},'+
'  "candidate": {'+
' "id": 214302,'+
' "clientId": 54,'+
' "clientCandidateId": "N714140",'+
'"firstName": "Marcus",'+
'"lastName": "Claus" }} ]';*/ //'[{"id":1326554,"appointmentTime":{"timestampInUTC":961444800000,"displayTimeZone":"","displayTimeZoneUTCOffset":"","displayTimeZoneSource":""},"processStateCode":"ResultAccepted","exam":{"id":179,"code":"TDFT4","name":"Test Driver Functionality Test - Basic Configuration"},"testCenter":{"id":43311,"name":"Mastercare Service and Distribution"},"candidate":{"id":675161,"clientId":67,"clientCandidateId":"VUE10560","firstName":"Mark","lastName":"Savage"}},{"id":1326553,"appointmentTime":964105200000,"processStateCode":"ResultAccepted","exam":{"id":179,"code":"TDFT4","name":"Test Driver Functionality Test - Basic Configuration"},"testCenter":{"id":43311,"name":"Mastercare Service and Distribution"},"candidate":{"id":675161,"clientId":67,"clientCandidateId":"VUE10560","firstName":"Mark","lastName":"Savage"}},{"id":1326552,"appointmentTime":{"timestampInUTC":961444800000,"displayTimeZone":"","displayTimeZoneUTCOffset":"","displayTimeZoneSource":""},"processStateCode":"ResultAccepted","exam":{"id":179,"code":"TDFT4","name":"Test Driver Functionality Test - Basic Configuration"},"testCenter":{"id":43311,"name":"Mastercare Service and Distribution"},"candidate":{"id":675161,"clientId":67,"clientCandidateId":"VUE10560","firstName":"Mark","lastName":"Savage"}},{"id":796504,"appointmentTime":950304600000,"processStateCode":"ResultAccepted","exam":{"id":179,"code":"TDFT4","name":"Test Driver Functionality Test - Basic Configuration"},"testCenter":{"id":43311,"name":"Mastercare Service and Distribution"},"candidate":{"id":675161,"clientId":67,"clientCandidateId":"VUE10560","firstName":"Mark","lastName":"Savage"}},{"id":796505,"appointmentTime":{"timestampInUTC":961444800000,"displayTimeZone":"","displayTimeZoneUTCOffset":"","displayTimeZoneSource":""},"processStateCode":"ResultAccepted","exam":{"id":179,"code":"TDFT4","name":"Test Driver Functionality Test - Basic Configuration"},"testCenter":{"id":43311,"name":"Mastercare Service and Distribution"},"candidate":{"id":675161,"clientId":67,"clientCandidateId":"VUE10560","firstName":"Mark","lastName":"Savage"}},{"id":796503,"appointmentTime":{"timestampInUTC":961444800000,"displayTimeZone":"","displayTimeZoneUTCOffset":"","displayTimeZoneSource":""},"processStateCode":"ResultAccepted","exam":{"id":179,"code":"TDFT4","name":"Test Driver Functionality Test - Basic Configuration"},"testCenter":{"id":43311,"name":"Mastercare Service and Distribution"},"candidate":{"id":675161,"clientId":67,"clientCandidateId":"VUE10560","firstName":"Mark","lastName":"Savage"}}]';
            }
            // ESBDAO.getRegistrationsByTestCenterId()
            else if ( uri.contains('testCenterId=') ) {
                response ='[{"id":1204452,"status":"unknown","disposition":"unknown","appointmentTime":{"timestampInUTC":961444800000,"displayTimeZone":"us","displayTimeZoneUTCOffset":65556545,"displayTimeZoneSource":"abc"},"processStateCode":"ResultAccepted","exam":{"id":561,"code":"051-651","name":"Tryout - Advanced NDS Tools and                        Diagnostics Practical Exam"},"testCenter":{"id":42190,"name":"CS Holdings Ltd. (Durban)","version":"0.767","updateTrack":"03 may 2015","lastRMACompleted":899898,"lastUpdate":7588,"updateStatus":"success","tedStatus":"unknown","activeWorkstations":"unknown","athenaVersion":"8"},"candidate":{"id":214302,"clientId":54,"clientCandidateId":"N714140","firstName":"Marcus","suffix":"unknown","salutation":"mr.","dob":"2011-03-22","email":"mar@scs.com","middleInitial":"mar","lastName":"Claus","primaryAddress":{"extension":"9888","city":"NY","phone":"78899","phoneCountryCode":"75778","postalCode":"798999","state":"washington","address1":"unknown","address2":"nknown","addressType":"residential","address3":"unkown","country":"USA"},"clientCandidates":[{"clientId":"8999","clientCandidateId":"8888"}],"alternateAddresses":[{"extension":"9888","city":"NY","phone":"78899","postalCode":"798999","state":"washington","address1":"unknown","address2":"nknown","addressType":"residential","address3":"unkown","country":"USA"}]},"deliveryMode":{"id":561,"name":"dev mode","remoteMonitoring":{"id":561,"name":"abc"}},"clientCandidates:":{"clientId":9788,"clientCandidateId":"78999"}}]';
                
            }
            else {
                // Error
                if ( uri.contains('/-1111') ) {
                    response = '{"faultCode":"invalid_token","faultMessage":"Invalid token"}';
                } else if ( uri.contains('/-9999') ) {
                    response = '{"faultCode":"Server","faultMessage":"An error occurred whilst performing an SSL socket operation; connect; java.net.ConnectException: Connection refused"}';
                }
            }
        } else if ( uri.contains('/Site') ) {
            response = '{}';
        }
        else if(uri.contains('/v1/ExamResultServices/resulthold/placehold')) {
            response ='{"registration":{"id":1204452,"status":"unknown","disposition":"unknown","appointmentTime":{"timestampInUTC":961444800000,"displayTimeZone":"us","displayTimeZoneUTCOffset":65556545,"displayTimeZoneSource":"abc"},"processStateCode":"ResultAccepted","exam":{"id":561,"code":"051-651","name":"Tryout - Advanced NDS Tools and                        Diagnostics Practical Exam"},"testCenter":{"id":42190,"name":"CS Holdings Ltd. (Durban)","version":"0.767","updateTrack":"03 may 2015","lastRMACompleted":899898,"lastUpdate":7588,"updateStatus":"success","tedStatus":"unknown","activeWorkstations":"unknown","athenaVersion":"8"},"candidate":{"id":214302,"clientId":54,"clientCandidateId":"N714140","firstName":"Marcus","suffix":"unknown","salutation":"mr.","dob":"2011-03-22","email":"mar@scs.com","middleInitial":"mar","lastName":"Claus","primaryAddress":{"extension":"9888","city":"NY","phone":"78899","phoneCountryCode":"75778","postalCode":"798999","state":"washington","address1":"unknown","address2":"nknown","addressType":"residential","address3":"unkown","country":"USA"},"alternateAddresses":[{"extension":"9888","city":"NY","phone":"78899","postalCode":"798999","state":"washington","address1":"unknown","address2":"nknown","addressType":"residential","address3":"unkown","country":"USA"}]},"deliveryMode":{"id":561,"name":"dev mode","remoteMonitoring":{"id":561,"name":"abc"}}},"id":6600,"registrationID":1204452,"holdTypeCode":300,"comment":"testing ","vssTechID":9000,"isActive":true,"createDate":20110322}';
            
        }else if(uri.contains('/TestCenter')){
            // Error
            if ( uri.contains('/-1111') ) {
                response = '{"faultCode":"invalid_token","faultMessage":"Invalid token"}';
            } else if ( uri.contains('/-9999') ) {
                response = '{"faultCode":"Server","faultMessage":"An error occurred whilst performing an SSL socket operation; connect; java.net.ConnectException: Connection refused"}';
            } else {
                if(uri.contains('?fields=')){
                    response = 
                        '{"id": 48509, "name": "zTest Lab - Config 57 - Summer Smith"}';                
                } else{
                    response = 
                        '{"id": 48509, "name": "zTest Lab - Config 57 - Summer Smith", "lastRMACompleted": 1068566491753, "lastUpdate": 1068566031973, "updateStatus": "SUCCESS", "tedStatus": "Excluded","activeWorkstations": "0", "athenaVersion": ""}';
                }
            }
        }  //EBSDAO.getCandidatesByCriteria
        else if(uri.contains('/Candidate/search')) {
            //success case
            if(req.getBody().contains('2506925')) {
                System.debug('RK: req body:'+req.getBody());
                response ='[{"id":1204452,"status":"unknown","disposition":"unknown","appointmentTime":{"timestampInUTC":961444800000,"displayTimeZone":"us","displayTimeZoneUTCOffset":65556545,"displayTimeZoneSource":"abc"},"processStateCode":"ResultAccepted","exam":{"id":561,"code":"051-651","name":"Tryout - Advanced NDS Tools and                        Diagnostics Practical Exam"},"testCenter":{"id":42190,"name":"CS Holdings Ltd. (Durban)","version":"0.767","updateTrack":"03 may 2015","lastRMACompleted":899898,"lastUpdate":7588,"updateStatus":"success","tedStatus":"unknown","activeWorkstations":"unknown","athenaVersion":"8"},"candidate":{"id":214302,"clientId":54,"clientCandidateId":"N714140","firstName":"Marcus","suffix":"unknown","salutation":"mr.","dob":"2011-03-22","email":"mar@scs.com","middleInitial":"mar","lastName":"Claus","primaryAddress":{"extension":"9888","city":"NY","phone":"78899","phoneCountryCode":"75778","postalCode":"798999","state":"washington","address1":"unknown","address2":"nknown","addressType":"residential","address3":"unkown","country":"USA"},"clientCandidates":[{"clientId":"8999","clientCandidateId":"8888"}],"alternateAddresses":[{"extension":"9888","city":"NY","phone":"78899","postalCode":"798999","state":"washington","address1":"unknown","address2":"nknown","addressType":"residential","address3":"unkown","country":"USA"}]},"deliveryMode":{"id":561,"name":"dev mode","remoteMonitoring":{"id":561,"name":"abc"}},"clientCandidates:":{"clientId":9788,"clientCandidateId":"78999"}}]';
                
            }
        }
        else if(uri.contains('/v1/ExamResults/placehold')) {
            response ='{"id":6600, "registrationID":34234, "holdTypeCode":13123, "comment":"Test", "vssTechID":23423, "isActive":true, "createDate":1068566031973}';
            
        }
        
        /*
else if(uri.contains('/Candidate')){
System.debug('RK: req uri:'+uri);
response = '{"candidateId":972819,"firstName":"Gopala Krishna","lastName":"P","middleInitial":null,"salutation":null,"suffix":null,"email":null,"dob":null,"primaryAddress":{"address1":"PLOT NO 28","address2":"RAJIV NAGAR COLONY","address3":null,"city":"HYDERABAD","state":null,"postalCode":"500045","country":"IND","phone":"91 407802084","extension":null,"phoneCountryCode":null,"addressType":"Work"},"alternateAddresses":[],"clientCandidates":[{"clientId":74,"clientCandidateId":"SP2110037"},{"clientId":109,"clientCandidateId":"SP2110037"},{"clientId":135,"clientCandidateId":"SP2110037"}]}';
}  */
        
        
        System.debug('response:' + response);
        HttpResponse httpResp = new HttpResponse();
        httpResp.setBody(response);        
        return httpResp;
    }
}