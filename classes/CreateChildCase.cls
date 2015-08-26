Global without sharing class CreateChildCase {
@InvocableMethod(label='Do Callout')
    
    global static void Childcase (list<DoCalloutActionRequest> requestdetails){
    	
        	doCaseCreate(requestdetails[0].ParentCaseID,requestDetails[0].VTS_Registration_Id, requestDetails[0].casetype,requestDetails[0].status);
        	
        //	DoCaseCreate(requestdetails[0].parentCaseId,registrationStatus[0], requestdetails[0].casetype);
      }
    
   
    
	global class DoCalloutActionRequest {
	
     @invocableVariable(required=false)
        public decimal VTS_Registration_Id;
	 @InvocableVariable(required=false)
		public Id ParentCaseId;

     @invocableVariable(required=false)
        public string CaseType;
     @invocableVariable(required=false)
        public string status;  
     
	}
   @future(callout=true)
    public static void doCaseCreate (id ParentId, decimal VTS_Registration_Id, string casetype, string status){
        
        	DAOFactory d = new DAOFactory();
            ESBDao dao = d.getEsbDao();
               
            VTS_Registration newcopy = dao.getRegistrationByRegistrationId(VTS_Registration_Id.longvalue());
        
        if(newcopy.processStateCode == null || newcopy.processStateCode == status){
        
        string casequery = 'SELECT ' + utility.editablefields('Case') + ' FROM case WHERE ID = :parentid';
        
    	case parent = database.query(casequery);
        
        if(parent != null)
        {	
            
               
                	Case childcase = parent.clone(false, true, false, false);
                    childcase.ParentId = parent.id;
                    
                    routing__c myrouting = utility.getRoutingandFirstStep(CaseType);
                    childcase.Routing__c = myrouting.id;
                    childcase.step__c = myrouting.steps__r[0].id;
                    childcase.Previous_Step__c = myrouting.steps__r[0].id;
                    childcase.Topic__c = 'System Generated';
                    childcase.Category__c = 'Escalation';
                    childcase.Final_Category__c = casetype;
                    step__c nextstep = utility.getnextstep(childcase, myrouting.steps__r[0]);
                    childcase.step__c = nextstep.id;
                    utility.setowner(nextstep,childcase,false);
                    
                    insert(childcase);
        		}   
        	}
    } 
}