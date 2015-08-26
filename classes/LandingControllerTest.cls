@isTest
public class LandingControllerTest {

    static testMethod void LandingPageControllerTest(){
        Case c = ( TestUtil.createCase(true, [select Id from RecordType where sObjectType = 'Case' limit 1].Id) );
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController( new list<Case>{ c } );
        LandingController controller = new LandingController(sc);
        system.assert( controller.caseRecords != null );
        controller.getLandingController();
        controller.Create_Reg();
        controller.Create_Site();
    }
}