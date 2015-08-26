public without sharing class WithoutSharingUtility {

    public static SObject doUpsert(SObject record) {
        upsert record;
        return record;
    }

    public static SObject doUpsertWithExternalKey(SObject record, Schema.SObjectField externalKeyField) {

        if ( record.getSObjectType() == Registration__c.sObjectType ) {
            Database.upsert((Registration__c) record, externalKeyField);
        }
        else if ( record.getSObjectType() == Candidate__c.sObjectType ) {
            Database.upsert((Candidate__c) record, externalKeyField);
        }
        else if ( record.getSObjectType() == Exam__c.sObjectType ) {
            Database.upsert((Exam__c) record, externalKeyField);
        }
        else if ( record.getSObjectType() == Account.sObjectType ) {
            Database.upsert((Account) record, externalKeyField);
        }
        return record;
    }
    //Clonned the previous function to avoid conflict if this function is used at anyother place
    public static LIST<SObject> doMultipleUpsertWithExternalKey(LIST<SObject> records, Schema.SObjectField externalKeyField) {

        //As list first record will identify the type of list that we are passing
        //that is why comparing only first record
        if ( records[0].getSObjectType() == Registration__c.sObjectType ) {
            Database.upsert((LIST<Registration__c>) records, externalKeyField);
        }
        else if ( records[0].getSObjectType() == Candidate__c.sObjectType ) {
            Database.upsert((LIST<Candidate__c>) records, externalKeyField);
        }
        else if ( records[0].getSObjectType() == Exam__c.sObjectType ) {
            Database.upsert((LIST<Exam__c>) records, externalKeyField);
        }
        else if ( records[0].getSObjectType() == Account.sObjectType ) {
            Database.upsert((LIST<Account>) records, externalKeyField);
        }
        return records;
    }
    public static List<Database.SaveResult> doInsert(List<SObject> records) {

        List<Database.SaveResult> results = Database.insert(records);
        return results;
    }

	public static case getpreviousvalue(case mycase)
		{
			system.debug('BEGIN GetPreviousValue::');
			case tempcaseforsave = new case(id=mycase.id);
			datetime mylastmodified = [select casenumber, id, lastmodifieddate from case where id =: mycase.id].lastModifiedDate;
			map<string, string> valuelist = new map<string,string>();
					for(casehistory each: [select field, oldvalue, newvalue from casehistory where caseid = :mycase.id and createddate = :mylastmodified])
						{
							valuelist.put(each.field.tolowercase(), string.valueof(each.oldvalue));
							system.debug(each);
							try{
									
									if(each.field == 'Owner' )
										{
											if(string.valueOf(each.newvalue).startsWith('00'))
												{
													tempcaseforsave.put('Ownerid', string.valueof(each.oldvalue));
												}
											else
												{
													tempcaseforsave.put('Owner_name__c', string.valueof(each.oldvalue));
												}	
										}
									else if(each.field == 'new_external_comment__c')
										{
											tempcaseforsave.New_External_Comment__c = (string.valueof(each.oldvalue)=='true');
										}
									
									else
										{
											tempcaseforsave.put(each.field, string.valueof(each.oldvalue));
										}	
								}
							catch(sObjectException a)
								{
									system.debug('field not found::' + Each.field +'--' +a);
								}
						}
					
					
					if(valuelist.get('status')!=null)
						{
							tempcaseforsave.status = valuelist.get('status');
							tempcaseforsave.status__c = valuelist.get('status');
						}
					if(valuelist.get('new_external_comment__c')!=null)
						{	
							tempcaseforsave.New_External_Comment__c = (valuelist.get('new_external_comment__c')=='true');
						}	
					/* if(valuelist.get('owner')!=null)
						{	
							tempcaseforsave.ownerid = valuelist.get('owner');
						}
					if(valuelist.get('owner')!=null)
						{	
							tempcaseforsave.ownerid = valuelist.get('owner');
						}
					if(valuelist.get('owner')!=null)
						{	
							tempcaseforsave.ownerid = valuelist.get('owner');
						}
						
				 */				
			return tempcaseforsave;		
		}

}