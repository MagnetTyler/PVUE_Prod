@isTest
public class CaseCommentsComponentControllerTest {

    static testMethod void CaseCommentsComponentControllerUnitTest(){
        Case c = new Case();
        c.status = 'Working';
        insert c;
        executionControl.afternInserthasrun = false;
        CaseComment cc = new CaseComment();
        cc.ParentId = c.Id;
        insert cc;
        
        CaseCommentsComponentController controller = new CaseCommentsComponentController();
        controller.caseId = c.Id;
        controller.sortField = null;
        controller.sortDir = 'desc';
        controller.Caseclosed = true;
        
        system.assert(controller.Caseclosed);
        
        system.assert(controller.sortField != null);
        system.assert(controller.sortDir != null);
        
        system.assert(controller.comments != null);
        system.assert(controller.pagetype == null);
        
        executionControl.afterupdatehasrun = false;
        apexpages.currentPage().getparameters().put('CommentId_p' , cc.Id);
        controller.makePublicPrivate();
        
        controller.makePublicPrivate();
        
        controller.pagetype = 'Community';
        system.assert(controller.comments != null);
        
        apexpages.currentPage().getparameters().put('CommentId_d' , cc.Id);
        controller.deleteComment();
        controller.NewComment();
        
     
        User u =  testutil.createCommunityUser(true);
        System.runas(u)
        {
            c = new Case();
            c.status = 'Working';
            upsert  c;
            
            executionControl.afternInserthasrun = false;
            cc = new CaseComment();
            cc.ParentId = c.id;
            upsert cc;
            
        }
        
    }
}