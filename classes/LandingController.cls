public with sharing class LandingController {

    private final Case newCase;  

    // The constructor passes in the standard controller defined
    // in the markup below
    
    public string dquery{get;set;}
   	
    	
    public LandingController(ApexPages.StandardSetController controller) {
        	this.newCase = (Case)controller.getRecord(); 
    		}    
    
    public ApexPages.StandardSetController caseRecords {    
		
        get {
        	
            if(caseRecords == null) {
            	if(dquery==null)
    				{dquery = 'SELECT id, casenumber, subject, Recordtype.name, status, Test_Center_Name__r.name FROM Case';
    							}
                caseRecords = new ApexPages.StandardSetController(
                    Database.getQueryLocator(dquery));
            }
            return caseRecords;
        }
        private set;
    }
    public List<Case> getLandingController() {
         return (List<Case>) CaseRecords.getRecords();
    } 
 public pagereference Create_Reg(){
 	 	
 	 	return null;
 }
 public pagereference Create_Site(){
 	
 		return null;
 }
 
}