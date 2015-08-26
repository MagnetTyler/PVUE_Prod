@isTest
private class Custom_Case_listview_test
{
	static user mycommunityuser = testutil.createCommunityUser(true);
	static permissionsetassignment psa = new permissionsetassignment(AssigneeId = mycommunityuser.id, PermissionSetId = [SELECT id, label from PermissionSet where Label = 'TA' limit 1].id);
       // update testuser; 
	static list<customListView__c> mylists = datafactory.createlistviews();
	static case test1 = new case(description = 'test1', 
		ownerid = [Select Id, Name, DeveloperName, Type from Group where Type = 'Queue' AND developername = :'Test_center'].id, 
		 status__c = 'Awaiting pickup', status = 'Awaiting pickup');

	
	public static testmethod void listviewtest()
	{	
		
		system.runAs(mycommunityuser)
			{
				test1.Test_center_name__c=[SELECT name, Contact.Accountid FROM User WHERE id = :mycommunityuser.id].contact.AccountId;
				
				insert(test1);
        		
        		Test.setCurrentPage(Page.Custom_Case_Listview);
        		Custom_case_listview CCL = new Custom_case_listview();
    			
				system.assertnotequals(null, CCL.me);
				system.assertequals(CCL.filter, null);
        		system.assertnotEquals(null, CCl.List_choices);
        		system.assertequals(CCL.mytestcenter, [SELECT name, Contact.Accountid FROM User WHERE id = :mycommunityuser.id].contact.AccountId);
    			try {
    			system.assertNotEquals(0, CCL.table_rows.size());
    				}
    				catch(system.nullpointerException a)
    				{}
    			system.assertequals(1, CCL.totalreturns);
    			system.assertequals(CCL.totalpages,1);
        		system.assertequals('10', CCL.Listsizes[0].getvalue());
        		ccl.doNext();
        		ccl.doPrevious();
        		ccl.togglesort();
        		CCL.dofirst();
        		CCL.dolast();
        		system.assertequals(false, CCL.hasnext);
        		system.assertequals(false, CCL.hasprevious);
        		pagereference mypr = system.currentPageReference();
        		mypr.getparameters().put('ownername', mycommunityuser.username);
        		
        		mypr.getparameters().put('feedback', 'caseDeleted');
        		mypr.getparameters().put('deletedCaseNo', '13344');
        		system.assertequals(true, CCL.returnNotice);
        		system.assertequals(mycommunityuser.username, CCL.ownername);
        		system.assertequals(CCL.comment, System.Label.Case + ' ' + system.currentpagereference().getParameters().get('deletedCaseNo') +' ' + System.label.Case_deleted );
        		system.assertequals(true, CCL.feedback);

        		CCL.editId = test1.id;
        		CCL.prevown = mycommunityuser.id;
        		Pagereference PR2 = CCL.EditRecord();
        		system.assertnotequals(null, PR2.getparameters().get('prevown'));
        		Mypr.getparameters().put('sourcepage', mylists[1].id);
        		CCL.getSelectedView();
        		

    		}
	}
}