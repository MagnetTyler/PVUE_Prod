public with sharing class DispatcherController {

    public DispatcherController(ApexPages.StandardSetController controller) {
        this.controller = controller;
    }

    public PageReference getRedir() {

        Pagereference PR = Page.Custom_case_listview;
        	if(userinfo.getusertype() == 'Standard')
        		{
        			PR = Page.CaseListView;
        		}
        
        return PR;

    }

    private final ApexPages.StandardSetController controller;

}