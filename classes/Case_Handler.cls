public with sharing class Case_Handler {

	public static void BeforeInsert(list<case> mycases, map<Id,Case> Oldmap, map<Id,Case> newmap){
	
		list<string> regids = new list<string>();
		map<Id, Registration__c>regmap = new map<Id,Registration__c>();
		
		
		for(case each:mycases){
			regids.add(each.Registration_id__c);	
			
		}
		
		For(Registration__c each: [select name, id, VTS_Registration_ID__c from Registration__c where id in :regids]){
			regmap.put(each.id, each);
		}
		
		for(case each:mycases){
			if(each.recordtypeId == schema.SObjectType.Case.GetrecordtypeinfosbyName().get('Missing results').getRecordTypeId())
			{
				try{
					if(regmap.get(each.Registration_id__c).VTS_Registration_ID__c!=null)
						{
							each.Evt_folder_name__c = utility.returnhex(regmap.get(each.Registration_id__c).VTS_Registration_ID__c);	
						}
				}
				Catch(NullPointerException NPA){}				
			}
		}
	}


	public static void BeforeUpdate(list<case> mycases, map<Id,case> oldmap, map<Id,case> newmap){
		
		list<string> regids = new list<string>();
		map<Id, Registration__c>regmap = new map<Id,Registration__c>();
		
		for(case mc:mycases){
			regids.add(mc.Registration_id__c);	
			
		}
		
		For(Registration__c r: [select name, id, VTS_Registration_ID__c from Registration__c where id in :regids]){
			regmap.put(r.id, r);
		}
		
		for(case each: mycases){
		
            system.debug( 'AZ: 1 ' + each.recordtypeid + ' == ' + Schema.SObjectType.Case.getRecordtypeInfosbyName().get('Request to reschedule').getRecordTypeId() );
            system.debug( 'AZ: 2 ' + each.isclosed  );
       //     system.debug( 'AZ: 3 ' + each.Original_record_type__c + ' == ' +  Schema.SObjectType.Case.GetRecordTypeInfosById().get(each.RecordtypeId).getName() );
		// for records that the record type changed for reschedule -- change the record type back to the original once it is closed
			if(each.recordtypeid == Schema.SObjectType.Case.getRecordtypeInfosbyName().get('Request to reschedule').getRecordTypeId()
				 && each.isclosed == true 
				 && each.Original_record_type__c != Schema.SObjectType.Case.GetRecordTypeInfosById().get(each.RecordtypeId).getName()){
				
				each.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosbyName().get(each.Original_Record_Type__c).getRecordtypeId();
							
			}
			
		// translate the 	
		
		
			if(each.recordtypeId == schema.SObjectType.Case.GetrecordtypeinfosbyName().get('Missing results').getRecordTypeId()&& Oldmap.get(each.id).Registration_id__c != NewMap.get(each.id).registration_id__c)
			{
				try{
					if(regmap.get(each.Registration_id__c).VTS_Registration_ID__c!=null)
						{
							each.Evt_folder_name__c = utility.returnhex(regmap.get(each.Registration_id__c).VTS_Registration_ID__c);	
						}
					}
				Catch(NullPointerException NPA){}				
			}
		}
		
	}
	public static void afterupdate(list<case> mycases, map<Id,case> oldmap, map<Id,case> newmap){
		
		set<id> parentids = new set<id>();
		
		for(case each:mycases)
			{
				if(each.ParentId != null)
					{
						parentids.add(each.parentid);
					}
			}
		if(parentids.size()>0){
			utility.CaseAggregate(parentids);
		}	
	}

	public static void afterinsert(list<case> mycases, map<Id,case> newmap){
		
		set<id> parentids = new set<id>();
		
		for(case each:mycases)
			{
                system.debug('AZ: each.ParentId ' + each.ParentId );
				if(each.ParentId != null)
					{
						parentids.add(each.parentid);
					}
			}
		if(parentids.size()>0){
			utility.CaseAggregate(parentids);
		}	
	
		//this section of code is used to add all the Contacts to the contact role related list for a case
	//Added Brian Weers 12-16-2014
		system.debug('Begin Add ContactRole to Case Method on Case_Handler.afterinsert(mycases, newmap)');
		set<id>accountids = new set<id>();
		map<id,list<contact>> Contacts_for_account = new map<id,list<contact>>();
		list<casecontactrole> relatedcontacts_added = new list<casecontactRole>();
		
		for(case after_insert_case:mycases)
			{
				if(after_insert_case.accountid != null)
				{
					accountids.add(after_insert_case.accountid);
				}
			}
		
		for(Contact each_Contact_for_Account: [SELECT id, accountid FROM Contact 
											   WHERE accountid in:accountids AND accountid!=null
											   AND Status__c = 'Active'])
							
			{
				list<contact> mycontactlist = Contacts_for_account.get(each_contact_for_account.accountid);
				if(mycontactlist == null)
					{
						mycontactlist = new list<contact>();
					}
				mycontactlist.add(each_Contact_for_Account);
				Contacts_for_account.put(each_contact_for_account.accountid,mycontactlist);	
			}	
		
		for(case after_insert_case:mycases)			
			{
				list<contact> mylist = Contacts_for_account.get(after_insert_case.accountid);
				if(mylist!=null)
					{
						for (Contact eachcontact:mylist)				
						{
							CasecontactRole mynewcontactrole = new casecontactRole(Casesid = after_insert_case.id,
																	   contactid = eachcontact.id,
																	   role = 'Test Center Admin');
							relatedContacts_added.add(mynewcontactrole);										   	
						}
					}
			}		
		try
			{
				insert(relatedcontacts_added);	
			}
		catch(exception insertCaseContactRole_Exception)
			{
				system.debug('Case_Handler.After_Insert Exception Thrown during Insert CaseContactRole:' + insertCaseContactRole_Exception);
			}
	
	}

}