public class SessionUtility {

    private static ID casAuthProviderId = Org_Settings__c.getInstance().CAS_Auth_Provider_ID__c;
    private static ID AssistAuthProviderId = Org_Settings__c.getInstance().Assist_Auth_Provider_ID__c;
    
    public static String getCASAccessToken() {
     // Old token        
     // String token = 'eyJ2ZXIiOiJ2MS4wIiwiaXNzQnkiOiJDQVMiLCJpc3NBdCI6MTQyMDQ4NDM1MTYxMiwiYXBwIjoiY2xpZW50UG9ydGFsIiwicmVhbG0iOiJQIiwidWlkIjoiMTY3MzYiLCJ1c2VyTmFtZSI6IkVTQlBPQyIsImZOYW1lIjoiRVNCIiwibU5hbWUiOm51bGwsImxOYW1lIjoiRVNCIiwicmVhbG1EZXRhaWwiOnt9LCJncmFudCI6IjEyOjE6QSIsImFjY2VzcyI6IjY0YWNiYjViLTBkMTAtNDQ4NC04NTVmLWQzMThkZjRkMWMyZCIsImFjY2Vzc0V4cCI6MTQyODI2MDM1MTYxMiwicmVmcmVzaCI6IjVjYTMyYjNiLTQyOTQtNDc5NS04OTlhLWZhNGIwODBiYTY4YSIsInJlZnJlc2hFeHAiOjE0MjA0ODc5NTEzMzEsInNpZ24iOiJFYkh6YU5SZ2s2RG9PWk1jcjZNVFpvNGVRSGgxTGQwQnpmWEtsU2VMckZvbnlDRzdMN1lqZFNwQkVWdCtHNVNtY0xTbXl2SUZFREMrbHhYdjBLeVlpMlVTMTV5aXJlNGRiY21kbnVjenFyV2lid0JLUjJweWVhNFEzNExka2VlN3Y5dUtxVTBKbFdHRlN5bmpENnNqc3BFMHVtZHRhdjZyK29RaTVwMi8wZUxaVkJyNDd6NEF6dEhVT1ZzR3doeWdyS2Z6WHdzRy9UbHR4RDB1UVFkSzIyOERvR3B2ZksvQVZDekk2bXpsQTlTYTlpQkJ3QS9oN1ZaS0dQUkhHaVZqZEVyYnA0Rkp1NkpNV2p0cnRLSUp3TFk4LzFBRDhFcnp3TXArR2hXWXZMYUhRWFJpcVJVVjV4YkpuMW5mY1h3NXBGRlJHQjh2aSsvaFJYN1NaUGZLWEE9PSJ9';
     
     //new token
     //   String token = 'eyJhbGciOiJSUzI1NiJ9.eyJ1aWQiOiIxNjA1MCIsInN1YiI6IjE2MDUwIiwiZ3JhbnQiOiIxMToxOkEiLCJ2ZXIiOiJ2MS4wIiwiZ2l2ZW5fbmFtZSI6IkthcmxhIiwiaWF0IjoiMTQyMzUxMTUyNzU4MCIsImZOYW1lIjoiS2FybGEiLCJ1c2VybmFtZSI6IndlYnRlc3RlcjAxIiwicmVhbG0iOiJQIiwibmFtZSI6IkthcmxhIENvbXN0b2NrIiwiZmFtaWx5X25hbWUiOiJDb21zdG9jayIsImNsaWVudF9pZCI6ImNsaWVudFBvcnRhbCIsImFwcCI6ImNsaWVudFBvcnRhbCIsIm1pZGRsZV9uYW1lIjpudWxsLCJpc3MiOiJDQVMiLCJsTmFtZSI6IkNvbXN0b2NrIiwiYWNjZXNzRXhwIjoiMTQzMTI4NzUyNzU3OSIsImlzc0J5IjoiQ0FTIiwiZXhwIjoiMTQzMTI4NzUyNzU3OSIsInJlYWxtRGV0YWlsIjp7fSwiaXNzQXQiOiIxNDIzNTExNTI3NTgwIiwiZW1haWwiOiJrYXJsYS5jb21zdG9ja0BwZWFyc29uLmNvbSIsInJlZnJlc2hFeHAiOiIxNDMxMjg3NTI3NTc5IiwiYXVkIjoiY2xpZW50UG9ydGFsIiwianRpIjoiZDQzYWY3ODItYzJjMS00ODA3LWE1ZDUtZTBkOWQyN2Q1ZTlkIiwibU5hbWUiOm51bGx9.z1WhkRM62sTi_Y5MX1RUz55JRctGAihk4h-CXJuie9SsiSy_pBQldCWqeWE1Ax68yZXeX2ixVHsqFkgmY87m81Pp_Edf1joR7ywX2Exs5GtZe4suD5hYdAKkq8zhXWV5gp7q4ju7SplBjUf-TBnxYA2YQ6dyM0Zz-PzWnfvfINz8p2IcAVIoHqrLSIzf68fd67sUmJGmA_r3yJvUsTunU-czugfOZI3U18Io9v0A6jqG6VG1UGlEW7OXpJ1k7GQpcWCMgMaZ9ZvbiZ5W2rvHmRHD1_mfj2b7DkFZYgBeYybLAgv9i6_3mt78jqgbHkFfgKX0B9n7D0vg1vDGlP9dtg';
     //for ST1   
      //     String token = 'eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiIxNjA1MCIsImdyYW50IjoiMTE6MTpBfDE1OjI6STo4NTAiLCJtaWRkbGVfbmFtZSI6bnVsbCwiaXNzIjoiQ0FTIiwiZ2l2ZW5fbmFtZSI6IkthcmxhIiwiaWF0IjoiMTQyOTEyMjQ4NDczMiIsInZlcnNpb24iOiJ2Mi4wIiwicmVhbG1EZXRhaWwiOnt9LCJleHAiOiIxNDM2ODk4NDg0NzMyIiwidXNlcm5hbWUiOiJ3ZWJ0ZXN0ZXIwMSIsInJlYWxtIjoiUCIsImVtYWlsIjoia2FybGEuY29tc3RvY2tAcGVhcnNvbi5jb20iLCJyZWZyZXNoRXhwIjoiMTQzNjg5ODQ4NDczMiIsIm5hbWUiOiJLYXJsYSBDb21zdG9jayIsImF1ZCI6ImNsaWVudFBvcnRhbCIsImZhbWlseV9uYW1lIjoiQ29tc3RvY2siLCJqdGkiOiI3ZjkxMjg0YS02NWEyLTQwMWYtYmViNi04OTZmN2VjMWZhYjQiLCJjbGllbnRfaWQiOiJjbGllbnRQb3J0YWwifQ.pNTHUsFmYy6rAXROz0rDcse1gAtp_t3lTPa20xUxNikzqOrKR3hVNthF_QYCWDEfjDV47BGEvObkffs2Us9hLyO0-mK-hUVb5HaNfi6Fe7LVwKXy5Fzi_8_Iu8dZf_gKjcvWWDX3xGJ1w1XJNCOY7NL8sSHhCX4_QTKkEqBc3AUJr_SS1S8SoVgmZ-8wFv2LmnKC-Ol3MvFvsKxwAFzTV29hm32_YUnzKyS_zbuDZK-__30M70Y09ID4o4ZrCZNI7YK4nh0ElQFW0mxHNSWKR3kn4ZvnCfXOzbzD69qzODa20TreTv8pXIL4G8cdekDaghu86owXIusXu8dUqxvO7w';
    //     String token = 'eyJhbGciOiJSUzI1NiJ9.eyJ2ZXJzaW9uIjoidjIuMCIsImlzcyI6IkNBUyIsImNsaWVudF9pZCI6ImNsaWVudFBvcnRhbCIsImlhdCI6MTQyOTEyMjQ4NDczMiwiZXhwIjo0MTAyNDQ0NzQwMDAwLCJyZWZyZXNoRXhwIjo0MTAyNDQ0NzQwMDAwLCJyZWFsbSI6IlAiLCJ1c2VybmFtZSI6IndlYnRlc3RlcjAxIiwiZ2l2ZW5fbmFtZSI6IkthcmxhIiwibmFtZSI6IkthcmxhIENvbXN0b2NrIiwiZmFtaWx5X25hbWUiOiJDb21zdG9jayIsImVtYWlsIjoia2FybGEuY29tc3RvY2tAcGVhcnNvbi5jb20iLCJncmFudCI6IjExOjE6QXwxNToyOkk6ODUwIiwic3ViIjoiMTYwNTAiLCJhdWQiOiJjbGllbnRQb3J0YWwiLCJqdGkiOiI3ZjkxMjg0YS02NWEyLTQwMWYtYmViNi04OTZmN2VjMWZhYjQiLCJyZWFsbURldGFpbCI6e319.M8DqEaNyPnwUFk4cKjzhQ8t0aceUsuK-aKlJdLS2lj8K_eTsgvVs9gtFEfjOXu0kwh2JebKi4SSD5EVXymC3pKvD2pqa1ez39SvQCDPeCdalj7UeCdQNsMZ5JJh6JWaiRum19tr2XzDfa_pE-DN4zRCoSzP3g7n9xnsSNo4y7bCTqL83tnZ5SzFx63p7oh7RFrrJK4aan80w7INyiisa2s23pl_6ARtFmbphQvYVsk8dilZUo29ED17MN-rXtusm_RI9Ca_J4Afwg0Z3P9RtqIHdqCDwthoC8I_UQCMlfQ_lW88euWrR4eTw--8bSFrhVlYTWa2uvfTxBBSGVmNNSg';    
    // for ST2
    //  String token = 'eyJhbGciOiJSUzI1NiJ9.eyJ1aWQiOiIzIiwic3ViIjoiMyIsImdyYW50IjoiMTI6MTpBfDE1OjI6STo4NTAiLCJ2ZXIiOiJ2Mi4wIiwiZ2l2ZW5fbmFtZSI6IkthcmxhIiwiaWF0IjoiMTQyOTEyMjM0OTAxNyIsImZOYW1lIjoiS2FybGEiLCJ1c2VybmFtZSI6IndlYnRlc3RlcjEiLCJyZWFsbSI6IlAiLCJuYW1lIjoiS2FybGEgVGVzdGVyIiwiZmFtaWx5X25hbWUiOiJUZXN0ZXIiLCJjbGllbnRfaWQiOiJjbGllbnRQb3J0YWwiLCJhcHAiOiJjbGllbnRQb3J0YWwiLCJtaWRkbGVfbmFtZSI6bnVsbCwiaXNzIjoiQ0FTIiwibE5hbWUiOiJUZXN0ZXIiLCJhY2Nlc3NFeHAiOiIxNDM2ODk4MzQ5MDE3IiwiaXNzQnkiOiJDQVMiLCJleHAiOiIxNDM2ODk4MzQ5MDE3IiwicmVhbG1EZXRhaWwiOnt9LCJpc3NBdCI6IjE0MjkxMjIzNDkwMTciLCJlbWFpbCI6ImthcmxhLmNvbXN0b2NrQHBlYXJzb24uY29tIiwicmVmcmVzaEV4cCI6IjE0MzY4OTgzNDkwMTciLCJhdWQiOiJjbGllbnRQb3J0YWwiLCJqdGkiOiJlNmQ0NGI2ZS0yMzE3LTRiYTctYmJkMS1iOGFkNTJmYzUwMTEiLCJtTmFtZSI6bnVsbH0.xWj8fCMaXpJKmT3gH6ftDfAABmLExLnZ9PG5S4wWXAe19z-4rhSkxT5DOESJXO9VNMWt7iC0l3eKueX81Vi3zpPBd1_6P8RVr0emSmAppkFentK7w2Neax_RxrpHwkSMweAtGbIw-JNgk0dYzAhaL9xzZhA0NCzEnxSdQKzHCvAOXmMAfRrGrkUqus0jxx4YjWlygBRfbQ96mKmozmVpm0bTTdwZBxcZpnV3gBa2NmwFlnTpxmgewUeN3jtoGz_NNy5rxOSzeYnGMe_XZbbTonkP6p9u5yfIyNBwUhakw4CsEYsfWQgniqLiUt0XX0ClFhD6Ly3wVISIerkwYCQwzA';
        
       string token = ''; 
      
      //with the addition of a second auth provider, test the usertype to decide which authprovider to use
        //TODO  improve scalability of this solution
   if(!test.isrunningTest()){
              
       if(userinfo.getusertype() == 'Standard')
           {
               token = Auth.AuthToken.getAccessToken(AssistAuthProviderId, 'Open ID Connect');
           }
               
       else
           {        
               token = Auth.AuthToken.getAccessToken(casAuthProviderId, 'Open ID Connect');
           }
      //end code change for multiple auth provider implementation  
      }
        return Test.isRunningTest() ? 'TESTTOKEN' : token;
    }

    public static String refreshCASAccessToken() {
        String newAccessToken;
        Map<String, String> result = new map<string,string>();
        
        
        //with the addition of a second auth provider, test the usertype to decide which authprovider to use
        //TODO  improve scalability of this solution
            
        if(userinfo.getusertype() == 'Standard')
           {
               result = Auth.AuthToken.refreshAccessToken(AssistAuthProviderId, 'Open ID Connect', getCASAccessToken());
           }
               
       else
           {        
               result = Auth.AuthToken.refreshAccessToken(casAuthProviderId, 'Open ID Connect', getCASAccessToken());
           }
        
       //end code change for multiple auth provider implementation
        
        System.debug('result: ' + result);
        
        
        if ( result != null ) { 
            newAccessToken = result.get('AccessToken');
        }
        return newAccessToken;
    }
}