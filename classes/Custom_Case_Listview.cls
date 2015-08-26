public with sharing class Custom_Case_Listview {
	public string mytestcenter = [SELECT name, Contact.Accountid FROM User WHERE id = :Userinfo.getuserId()].contact.AccountId;
	public string Me = userinfo.getuserid();
	public string returnsize{get;set;}
	public string int_c{get;set;}
	public string int_e{get;set;}
	public string ext_c{get;set;}
	public boolean returnnotice {get
							{
								returnnotice = system.currentPageReference().getparameters().get('ownername') != null;
								return returnnotice;
							}
							set;
						}
	public string ownername {get
								{
									if (ownername == null || ownername == '')
										{
											ownername = system.currentpageReference().getParameters().get('ownername');
										}
									return ownername;
								}
								set;	
								}					
	public string editId {get;set;}
	public string prevown {get;set;}
	
	public string prevstat {get;set;}
public boolean Feedback {get
    	{
    		boolean feedback = system.currentPageReference().getParameters().get('feedback') != null;
    		return feedback;
    	}
    	set;
    }	
    public string comment
    	{
    		get
				{
					string comment = system.currentPageReference().getParameters().get('feedback');
					if(comment == 'caseDeleted')
						{
							comment = System.Label.Case + ' ' + system.currentpagereference().getParameters().get('deletedCaseNo') +' ' + System.label.Case_deleted ;
						}

					return comment;
				}
    		set;
		}

	public string viewId{get;set;}
	  // the current sort direction. defaults to asc
  	public String sortDir {
    		get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
    		set;
  		}


  // the current field to sort by. defaults to last name
  	public String sortField {
    		get  { 
    				
    				if (sortField == null) 
    					{sortField = 'default';}
    					 
    			 return sortField;  }
    		set;
  		}

  		
	public list<sObject> assignlist = new list<sObject>();
	public string querysuffix{get;set;}
	public CustomLIstView__c Selectedview {get;set;}
	
	public string getquerysuffix(){
			
				if(selectedview.search_criteria__c != null)
					{
						querysuffix = ' ' + SelectedView.Search_Criteria__c ;
					}
				return querysuffix;
				}
	public void setquerysuffix(string querysuffix)
		{				
			this.querysuffix = querysuffix;
		}			
	


	public string searchstring {
		get
			{ if(tablecolumns == null)
					{
						this.tablecolumns = getTablecolumns();
					}
					list<string> additionalfields = new list<string>{'External_test_Center__c','OwnerId','Owner.Name','IsClosed' , 'Status__c', 'Status', 'new_external_comment__c', 'New_Internal_Comment__c', 'New_Internal_Email__c' };
			 		searchstring = utility.getQueryFromFieldset(tablecolumns, sObject_Name, additionalfields);  //TO DO: move sObject string name to config record	
					

	
			return searchstring;
			}
		set;
	
	}

	public pagereference Editrecord()
		{
			PageReference mypage = new PageReference('/'+editId+'/e?retURL=%2Fa'+editId);
			
			
							mypage.getParameters().put('prevown', prevown);
							mypage.getParameters().put('prevstat', prevstat);
							mypage.getParameters().put('sourcepage', selectedview.id);
							
							mypage.getParameters().put('ext_c',ext_c);
							mypage.getParameters().put('int_c', int_c);
							mypage.getParameters().put('int_e', int_e);
            				mypage.getParameters().put('sortField', sortField);
            				mypage.getParameters().put('sortDir', sortDir);
            				mypage.getParameters().put('pageNo', string.valueof( pagenumber));
            
			return mypage;
		}

//items which come from the configuration record

	public list<selectOption> List_choices {
		get
			{
				list<selectOption> List_choices = new list<selectOption>();
				string listchoices_query = 'SELECT ' + utility.editablefields('CustomListView__c') + ' FROM CustomListView__c WHERE Object__c = \'Case\' Order by List_order__c ASC';
					//	SelectOption SO_Selectone = new SelectOption('','Select one');
					//	list_choices.add(SO_Selectone);
				for (CustomListView__c each: database.query(listchoices_query))
					{
						if (each.default__c == true && selectedView == null)
							{
								selectedview = each;
								viewid = each.id;
							}
						selectOption SO = new selectOption(each.id, each.List_view_name__c);
						List_choices.add(SO);
					}

				return list_choices;
			}
		set;
		
	}
			
//possibly move to custom setting or config record
public list<selectOption> ListSizes{
	get
		{
			this.listSizes = new list<selectOption>();
			if(selectedview.List_Size_Options__c== null)
				{
					//ListSizes.add(new SelectOption ('10','10 per page'));
					//ListSizes.add(new SelectOption ('20','20 per page'));
					//ListSizes.add(new SelectOption ('50','50 per page'));
				}
			else
				{
					for(string each:selectedview.List_Size_Options__c.split(';'))
						{listSizes.add(new SelectOption(each, each +' ' + label.List_View_Per_Page));}
				}	
			return listsizes;
		}
	set;
}


//config record for determining the listviews	
	public CustomListview__c getSelectedview() {
			
				string prevpage = system.currentpagereference().getParameters().get('sourcepage');
				if(prevpage != null && (viewId== null || viewId == ''))
					{
						viewId = prevpage;
					}
				selectedview = new customListview__c();
				string listquery = '';
				if(viewId != null && viewId != '')
					{
						listquery = 'SELECT ' + Utility.Editablefields('CustomListview__c') +' FROM CustomListview__c WHERE id= :viewid Order by List_Order__c Asc';						
					}
				else
					{
						listquery = 'SELECT ' + utility.editablefields('CustomListView__c') + ' FROM CustomListView__c where Default__c = true LIMIT 1';
					}
				selectedview = database.query(listquery);			
        System.debug('SK: selectedview: ' + selectedview);
				return selectedview;
			}	
			
	public void setselectedview(CustomListview__c selectedview){
			this.selectedview = selectedview;
	}
	
	public PageReference prepareReturnUrl()
    {
        PageReference thePage = Page.Custom_Case_Listview;
        
        thePage.getParameters().put('sourcepage',viewId);
        thePage.getParameters().put('sortField',sortField);
        thePage.getParameters().put('sortDir',sortDir);
        thePage.getParameters().put('pageNo', string.valueof(pagenumber));
        thePage.setRedirect(true);
        return thePage;
    }
	
	public string filter {get;set;}
	
	
	//table will be constructed from fieldset
	public list <Schema.fieldsetmember> tablecolumns {get;set;}	

	//method that can be called to make sure the tablecolumns are available
	public list <Schema.fieldsetmember> gettablecolumns()
		{
			if(tablecolumns == null)
				{
					this.tablecolumns = utility.getFieldsetmembers('External_list_view', sObject_Name);
				}
			return tablecolumns;	
		}
	public void setTablecolumns(list<schema.fieldsetmember> tablecolumns)
		{
			this.tablecolumns = tablecolumns;
		}
	//TO DO: move to config record
	public string sObject_Name = 'Case';

	//
	public map<string, Generic_Listview_Row> rowlibrary = new map<string,Generic_listview_row>();
	
	public list<Generic_listview_row>table_rows{get
		{
			System.debug('BEGIN list of table_rows getter');
			list<Generic_listview_row> theserows = new list<Generic_listview_row>();						
			string userid = userinfo.getUserId();
			//TO DO:  set querysuffix to config record
			string querysuffix = '';
		
		
			
//	Records retrieve from the set controller are checked against the map of all records to allow for tracking of the selected records
//  new records are decorated and placed in the map	
		
			for(sObject each_row:Setcontroller.getrecords())
			{
				Case mylineitem = (Case)each_row;
				if(!rowlibrary.containskey(each_row.id))
					{ 
						Generic_listview_row newrow = new Generic_listview_row();	
						newrow.myRecord = mylineitem;
						newrow.selected = false;	
						
						newrow.showselect = (newrow.myrecord.get('ownerid') != me && (newrow.myrecord.getsObject('Owner').get('Name') == 'Test Center' || mytestcenter == newrow.myrecord.get('External_test_Center__c'))
											 && newrow.myrecord.get('ISclosed') == false);
						newrow.showedit = (newrow.myrecord.get('ISclosed') == false && (newrow.myrecord.getsObject('owner').get('Name') == 'Test Center' ||  mytestcenter == newrow.myrecord.get('External_test_Center__c')));
																
						rowlibrary.put(mylineitem.id, newrow);
						theserows.add(newrow);
					}
				else
					{
						theserows.add(rowlibrary.get(mylineitem.id));	
					}			
			}

			System.debug('END list of controller_rows getter');
			return theserows;
		}
		set;
	}
	
	
	
	//item for pagination control. total number of pages in set
	public integer totalpages{get
								{
									integer listsize = 10;
									if(returnsize != null)
										{listsize = integer.valueof(returnsize);}
									
									System.debug('BEGIN totalpages.get()');
									decimal pagedec = decimal.valueof(setcontroller.getResultSize())/integer.valueof(listsize);
									pagedec = math.Ceil(pagedec);
									totalpages = pagedec.intvalue();
									system.debug('END totalpages.get');
									return totalpages;
								}	set;
							}
//item for pagination control. total current page number						
	public integer totalreturns{
		get
			{
				integer totalreturns = setcontroller.getResultSize();
				return totalreturns;
			}
		set;			
	}

	public integer Currentmin
		{
			get
				{
					integer listsize = 10;
					if(returnsize != null)
						{listsize = integer.valueof(returnsize);}
					integer Currentmin = ((pagenumber*listsize)-(listsize-1));	
					
					return currentmin;
				}
			set;	
		}
	public integer Currentmax
		{
			get
				{
					integer listsize = 10;
					if(returnsize != null)
						{listsize = integer.valueof(returnsize);}
					integer Currentmax = (pagenumber*listsize);	
					//integer total = setcontroller.getResultSize();
					if(currentmax > totalreturns)
						{currentmax = totalreturns;}
					return currentmax;
				}
			set;	
		}	
		
	public integer pagenumber {get
								{
									pagenumber = setcontroller.getpagenumber();
									return pagenumber;
								}
							   set;
							  }
							
//pagination							
	public boolean hasnext{get
							{
								if(setController!=null)
									{
										hasNext = this.setController.getHasNext();										
									}
								return hasNext;
							}	
						   set;
						  }	
//pagination
	public boolean hasprevious{get
							{
								if(setController!=null)
									{
										hasprevious = this.setController.getHasPrevious();										
									}
								return hasprevious;
							}	
						   set;
						  }
	
	
	
	
	//constructor
	public Custom_Case_listview(){
        //SK: Added this call here b/c the default List View was not being initialized and we needed
        //    it on the VF page upon initial load to fetch the new Custom_Buttons__c field
        sortField =  ApexPages.currentpage().getParameters().get('sortField');
        sortDir =    ApexPages.currentpage().getParameters().get('sortDir');
       	integer npagenumber = (ApexPages.currentpage().getParameters().get('pageNo') != null) ? integer.valueof(ApexPages.currentpage().getParameters().get('pageNo')): 1;
        getSelectedview();
        dofilter(npagenumber);
        
	}

	// set controller
	public apexpages.standardsetController Setcontroller
		{get
			{	
				system.debug('BEGIN apexpages.standardsetController Setcontroller GETTER');	
				
				getselectedview();		
				getquerysuffix();
				
				
				if(Setcontroller == null)				
					{	
						integer listsize = 10;
						
						if(returnsize != null)
							{listsize = integer.valueof(returnsize);}
						
						string finalquery = searchString;
						if(querysuffix != null && querysuffix != '')
							{finalquery = searchstring + ' WHERE ' + querysuffix;
								
							finalquery = getorderbyclause(finalquery);		
								
							system.debug('finalquery::'+finalquery);}
                        this.Setcontroller = new apexpages.Standardsetcontroller(database.query(finalquery));	
                        this.Setcontroller.setPageSize(listsize);
                        this.Setcontroller.setPageNumber(1);
                       
					}
					
				system.debug('END apexpages.standardsetController Setcontroller GETTER');			
				return Setcontroller;	
			}set;
		}

	private string getorderbyclause(string finalquery)
		{
			string orderbyclause = '';
			if(sortfield == 'default' || sortfield == '' || sortfield == null)
								{
									if(selectedview.order_by__c != null && selectedview.order_by__c != '')
										{
											orderbyClause = ' Order by ' + selectedview.order_by__c;										
										}
									if(selectedview.then_by__c != null && selectedview.then_by__c != '')	
										{
											orderbyClause += ', ' + selectedview.then_by__c+ ' NULLS Last';
										}
									else{orderbyClause +=' NULLS Last';}	
								}
							else
								{
									
									OrderbyClause = ' Order by ' + sortfield +' ' + sortdir + ' NULLS Last';
									if(sortfield == 'Casenumber_hyperlink__c')
										{OrderbyClause = OrderbyClause.replace('Casenumber_hyperlink__c','casenumber');}
								}
							if(orderbyclause != '')
								{
									finalquery = finalquery + Orderbyclause;
								}	
			return finalquery;						
		}
    public PageReference dofilter()
    {
       return dofilter(1);
    }
	public PageReference dofilter(integer pageNo)
		{	
				system.debug('BEGIN DoFilter');	
							
						
						integer listsize = 10;
						if(returnsize != null)
							{listsize = integer.valueof(returnsize);}
						string finalquery = searchString;
						getselectedview();
						getquerysuffix();
						if(querysuffix != null && querysuffix != '')
							{finalquery = searchstring + ' WHERE ' + querysuffix;
								finalquery = getorderbyclause(finalquery);
							system.debug('finalquery::'+finalquery);}
							
						
							
						this.Setcontroller = new apexpages.Standardsetcontroller(database.query(finalquery));	
						this.Setcontroller.setPageSize(listsize);
						this.Setcontroller.setPageNumber(pageNo);								
					
					
				system.debug('END DoFilter GETTER');	
            return prepareReturnUrl();

		}
	public PageReference toggleSort() {
	    // simply toggle the direction
	    sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
	    // run the query again
	  return  dofilter();
	  }
		
	public void Assign()
		{
			savepoint SP;
			SP = database.setsavepoint();
			
			for (Generic_listview_row each: rowlibrary.values())
				{
					if(each.selected == true)
						{
							each.myrecord.put('Status','Working');
							each.myrecord.put('Status__c', 'Working') ;
							each.myrecord.put('OwnerId', me);
							each.selected = false;
							rowlibrary.remove(each.myrecord.id);
							assignlist.add(each.myrecord);
						}
				}
			if(assignlist.size()>0)
				{
					try{
							update assignlist;
							dofilter();
					   }
					catch (Exception update_exception)
						{
							System.debug('Update error:' + update_exception);
							string errmessage = 'An unknown error occured while assigning lists to you.  Please try again or contact a system administrator' ;
							ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errmessage);
							apexpages.addMessage(myMsg);
							database.rollback(SP);
						}   	
				}	
		}	
//**************** BEGIN PAGINATION CONTROLS *********************//
			public PageReference doNext(){	
				this.setController.next();
                 return prepareReturnUrl();
				}
			public PageReference doPrevious(){
				this.setController.previous();
                 return prepareReturnUrl();
				}
			public PageReference dofirst(){
				this.setController.first();
                 return prepareReturnUrl();
				}
			public PageReference dolast(){
				this.setController.last();
                 return prepareReturnUrl();
				}
//**************** END PAGINATION CONTROLS *********************//			
		
}