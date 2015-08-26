@istest(seealldata=false)

public with sharing Class importDataFromCSV_Test {
    
    
    public static Testmethod Void loaddata(){
        
        
        user u = datafactory.createUser();
        System.runas( new user( id = userinfo.getuserid()))
        {
            Routing__c r=Datafactory.createPowerOutageRouting();
            List<Step__c> steps=DataFactory.createPowerOutageRoutingSteps(r.Id);
        
        list<account> myaccounts = datafactory.createAccounts(5, true);
        
        case myparent = datafactory.createcase('Track validation',u,  steps[0]);
        
        
        blob myfile = datafactory.loadfile(myaccounts);
        
        test.starttest();
        pageReference pg = Page.importTool;
        test.setCurrentPage(pg);
        pg.getParameters().put('id',myparent.id);
        
        importDataFromCSVController mytest = new importDataFromCSVController();
        mytest.csvFileBody = myfile;
        mytest.importCSVFile();
        
        system.assertequals(true,mytest.rowswithselect[0].selected);
        
        system.assertnotequals(0,mytest.rowswithselect.size());
        mytest.createcases();
        mytest.attachtocase();
        
        test.stoptest();
        
        case c2 = [select casenumber, id, total_child_cases__c, total_closed_cases__c, status from case where ID = :myparent.id];
        
        
        list<case>insertchildren = new list<case>();
        insertchildren = [select casenumber, id, parentid from case where parentId =: myparent.id];
        system.assertequals(5,insertchildren.size());
        insertchildren[0].status = 'Update Successful';
        update(insertchildren[0]);
        //system.assertequals(1,c2.total_closed_cases__c);
        }
        
    }
    
    
}