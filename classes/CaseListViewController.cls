global with sharing class CaseListViewController {

    public Case dummyCase {get; private set;}
    public String updateableCaseId { get; set;}

    private static Boolean canMassReassign;
    private static Boolean isCallCenterAgent;
    static {
    	//BW 5-20  switching to string on the user
    	string perstring = [select name, Primary_team_persona__c from User where id = :Userinfo.getUserId()].Primary_team_persona__c;
		list<string> mypersets = perstring.split(';');		
        String caseAssignProfiles = Org_Settings__c.getInstance().Case_Mass_Assign_Profiles__c;
        if ( !String.isBlank(caseAssignProfiles) ) {
         
         canMassReassign = false;  
			integer i = 0;
		try{
		while (canMassReassign == false && i<mypersets.size())
			{
				if(caseAssignProfiles.contains(mypersets[i]) || mypersets[i].contains('Mgmt')){
					canMassReassign = true;
				}
				i=i+1;
			}	
		}
		Catch(exception a)
			{
				System.debug('Exception Thrown::' + a);
			}



            // Do Profile-match
            String userProfile = [select Name from Profile where Id = :UserInfo.getProfileId()].Name;
           // if ( caseAssignProfiles.contains(userProfile + ',') || caseAssignProfiles.endsWith(userProfile) ) {
           //     canMassReassign = true;
        //   }
            // Do Permission-set match
            //else {
                
            //    List<PermissionSetAssignment> permSetAssignments = 
            //        [select PermissionSet.Name from PermissionSetAssignment where AssigneeId = :UserInfo.getUserId()];
                
           //     for ( PermissionSetAssignment psa : permSetAssignments ) {
           //         if ( caseAssignProfiles.contains(psa.PermissionSet.Name + ',') || caseAssignProfiles.endsWith(psa.PermissionSet.Name) ) {
          //              canMassReassign = true;
          //              break;
          //          }
          //          canMassReassign = false;
          //      }
          //  } //END: Match Permission Sets

            isCallCenterAgent = userProfile.toLowerCase() == 'call center agent';
        } //END: If ( Mass Assign Profiles custom setting exists)
    }

    public Boolean showAssignButton {

        get {

            if ( this.showAssignButton == null ) {
				this.showAssignButton = canMassReassign;
            } //END: If ( showAssignButton == null)

            return this.showAssignButton;
        }
        private set;
    }
    public CaseListViewController() { }
    
    public CaseListViewController(ApexPages.StandardSetController sc) {
        dummyCase = new Case();
    }

    @RemoteAction
	global static List<CaseAccess> getUserCaseAccess(String caseIdsStr){

        System.debug('caseIdsStr: ' + caseIdsStr);
        List<CaseAccess> cas = new List<CaseAccess>();
        if ( !String.isBlank(caseIdsStr) ) {

            List<ID> caseIds = caseIdsStr.split(',');
	        System.debug('caseIds: ' + caseIds);
            if ( !caseIds.isEmpty() ) {

                ID currUserId = UserInfo.getUserId();
                Set<ID> userGroupIds = new Set<ID>();
                for ( GroupMember grpMem : [select GroupId from GroupMember where UserOrGroupId = :currUserId] ) {
                	userGroupIds.add(grpMem.GroupId);
                }
                System.debug('userGroupIds: ' + userGroupIds);

                // Go another level up the group-hierarchy
                for ( GroupMember grpMem : [select GroupId from GroupMember where UserOrGroupId in :userGroupIds] ) {
                	userGroupIds.add(grpMem.GroupId);
                }
                System.debug('userGroupIds: ' + userGroupIds);

                String profileName = [select Name from Profile where Id = :UserInfo.getProfileId()].Name;
		        System.debug('profileName: ' + profileName);

                List<Case> cases =
                    [select Step__r.Personas_Can_Edit__c, Step__r.Personas_Can_Accept__c, Step__r.Personas_Can_Close__c,
                     	Owner.Type, IsClosed
                    from Case
                    where Id in :caseIds];
                Set<ID> ownerIds = new Set<ID>();
                for ( Case cs : cases ) {
                    ownerIds.add(cs.OwnerId);
                }
                System.debug('ownerIds: ' + ownerIds);

                Set<ID> taUserIds = new Set<ID>();
                Set<ID> callCenterUserIds = new Set<ID>();
                for ( User u : [select Profile.Name from User where Id in :ownerIds and (UserType != 'Standard' or Profile.Name = 'Call Center Agent')] ) {
                    if ( u.Profile.Name == 'Call Center Agent' ) {
                        callCenterUserIds.add(u.Id);
                    } else {
                        taUserIds.add(u.Id);
                    }
                }
                System.debug('taUserIds: ' + taUserIds);
                System.debug('callCenterUserIds: ' + callCenterUserIds);

                Map<ID, CaseAccess> caseAccessMap = new Map<ID, CaseAccess>();
                for ( Case cs : cases ) {

                    CaseAccess ca = new CaseAccess(cs.Id);
                    ca.canEdit = 
                        // Case NOT Closed, AND (User is Owner, OR member of Owner Queue, OR Internal user for TA-owned Case, OR Call center agent (CCA) for CCA-owned Case)
                        !cs.IsClosed && /*cs.Step__r.Personas_Can_Edit__c != null && cs.Step__r.Personas_Can_Edit__c.contains(profileName) &&*/
                        (cs.OwnerId == currUserId || 
                         	userGroupIds.contains(cs.OwnerId) || 
                        	(!isCallCenterAgent && UserInfo.getUserType() == 'Standard' && taUserIds.contains(cs.OwnerId)) ||
                        	(isCallCenterAgent && callCenterUserIds.contains(cs.OwnerId)));
                    /*
                    ca.canAccept = 
                        !cs.IsClosed && cs.Step__r.Personas_Can_Accept__c != null && 
                        cs.Step__r.Personas_Can_Accept__c.contains(profileName) && cs.Owner.Type != 'User';
					*/
                    //ca.canClose = !cs.IsClosed && cs.Step__r.Personas_Can_Close__c != null && cs.Step__r.Personas_Can_Close__c.contains(profileName);
                    ca.isClosed = cs.IsClosed;
					caseAccessMap.put(cs.Id, ca);
                } //END: For ( cases )

                // Iterate over the original caseIds list to populate the returnable
                // list (cas) in the same order as the input list (caseIdsStr)
                for ( ID cid : caseIds ) {
                    cas.add(caseAccessMap.get(cid));
                }
            } //END: If ( caseIds )
        } //END: If ( caseIdsStr )
        return cas;
    }

    @RemoteAction
	global static void reassignCases(String caseIdsStr, String selAssigneeId){

        //if ( canMassReassign ) {
            System.debug('caseIdsStr: ' + caseIdsStr);
            System.debug('selAssigneeId: ' + selAssigneeId);
            if ( !String.isBlank(caseIdsStr) || !String.isBlank(selAssigneeId) ) {
                
                List<ID> caseIds = caseIdsStr.split(',');
                System.debug('caseIds: ' + caseIds);
                List<Case> cases = new List<Case>();
                for ( ID caseId : caseIds ) {
                    cases.add(new Case(Id = caseId, OwnerId = selAssigneeId, Status__c = 'Working', Status = 'Working'));
                }
                System.debug('cases: ' + cases);
                update cases;
            } //END: If ( caseIdsStr )
        //}
    }

    global class CaseAccess{
        public ID caseId {get; set;}
        public Boolean canEdit {get; set;}
        public Boolean canAccept {get; set;}
        public Boolean canClose {get; set;}
        public Boolean isClosed {get; set;}
        public CaseAccess(ID cid) {
            this.caseId = cid;
            this.canEdit = false;
            this.canAccept = false;
            this.canClose = false;
            this.isClosed = false;
        }
    }
    
    public PageReference acceptCase(){

        update new Case(Id = updateableCaseId, OwnerId = Userinfo.getUserId(), Status = 'Working', Status__c = 'Working');
     	return new PageReference('/ta/500/o');
    }

    public PageReference closeCase(){

        update new Case(Id = updateableCaseId, Status = 'Closed', Status__c = 'Closed');
     	return new PageReference('/ta/500/o');
    }
}