public class importDataFromCSVController {
public Blob csvFileBody{get;set;}
public string csvAsString{get;set;}
public String[] csvFileLines{get;set;}
public map<string, list<string>> importeddata {get;set;}
public list<long> testcenterIDs = new list<long>();   
public list<string> headers{get;set;}

public map<long,DecoResult> Importmap{get{if(Importmap==null){
				Importmap = new  map<long,DecoResult>();}
				else{ Importmap = Importmap;} return Importmap;}set;}
public map<string,integer> positionmap = new map<string,integer>();
  public importDataFromCSVController(){
    csvFileLines = new String[]{};

  
  }
public list<DecoResult>rowswithselect{get{ if (rowswithselect == null){
			rowswithselect = importmap.values();} return rowswithselect;}set;}
			
			
public boolean loadcomplete {get{if( loadcomplete == null){ boolean lc = false; return lc;} else{loadcomplete=loadcomplete; return loadcomplete;}}set;}

/*public list<DecoResult> getrowswithselect(){
				list<decoresult> rowswithselect = new list<decoresult>();
				
					for(sObject each:TClist.getrecords()){
						Account a = (Account)each;
						Decoresult temp = importmap.get(a.VTS_Test_Center_ID__c);
						temp.TestCenter = a;
						importmap.put(a.VTS_Test_Center_ID__c, temp);
						rowswithselect.add(temp);
					}
				return rowswithselect;
				}	


public void setrowswithselect(list<decoResult> rowswithselect){
		this.rowswithselect = rowswithselect;}

	public apexPages.StandardSetController TCList{
	
		get{if(TClist==null){
			list<string> ids = importeddata.get('Test Center Id');
			 TClist = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Name, Id, VTS_Test_Center_ID__c FROM Account where VTS_Test_Center_ID__c!= null and VTS_Test_Center_ID__c in: ids]));
				this.TCList.setpagesize(10);
				this.TClist.setpagenumber(1);
		
			}
		return TCList;
		}
		set;
	}
*/
  
  public void importCSVFile(){
      // try{
       	if(importeddata==null){
       	this.importeddata = new map<string, list<string>>();
       		}
       		
       		
       		
       		
       	else{importeddata = importeddata;}
       		
      csvAsString = csvFileBody.toString();
           string linedelim ='\n';
           if(!csvAsString.contains('\n')){
           		linedelim = '\r';
           }
           csvFileLines = csvAsString.split(linedelim);            
           headers = csvFileLines[0].split(',');
           integer origsize = headers.size();
          
          
          //build a map to find the ID column later
 			for(integer x = 0; x<headers.size(); x++)
               		{
               		 if(headers[x]!=null)
               		 	{
               		 		positionmap.put(headers[x],x);
               			}
               		}
 		   integer idcol = positionmap.get('Test Center Id');
 		   
 		   if(idcol == null){idcol = 0;}

            
           for(Integer i=0;i<csvFileLines.size();i++){
               
               list<string> csvRecordData = csvFileLines[i].split(',');
               DecoResult thisrow = new DecoResult(csvRecordData);
               rowswithselect.add(thisrow);
           if(i!=0){importmap.put(decimal.valueOf(csvRecordData[idcol]).longvalue(), thisrow);
               testcenterids.add(decimal.valueOf(csvRecordData[idcol]).longvalue());}
 
              	

        }


       	for(account each: [select name, id, VTS_Test_Center_ID__c from Account where VTS_Test_Center_ID__c !=null AND VTS_Test_Center_ID__c in:testCenterIds]){
       		decoResult mydeco = importmap.get(each.VTS_Test_Center_ID__c.longValue());
       		mydeco.TestCenter = each;
       		mydeco.selected = true;
       		importmap.put(each.VTS_Test_Center_ID__c.longValue(), mydeco);      		
       	}
       	
       	
       //	rowswithselect = importmap.values();
       	rowswithselect.sort();
       
 //      }   
 //       catch (Exception e)
 //       {
 //           string err = e.getmessage();
  //          ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data Please make sure input csv file is correct'+err);
            
   //        ApexPages.addMessage(errorMessage);
            
   //     }  
  	}
  	
public pagereference cancel(){
	pageReference pr = apexpages.currentpage();
	pr.setredirect(true);
	return pr;
}

public void attachtocase(){
	blob fileready = utility.attachready(rowswithselect, headers);
	
	attachment completelist = new attachment();
	completelist.Body = fileready;
	completelist.name='Load Results.csv';
	completelist.ParentId = system.currentpagereference().getparameters().get('id');
	insert(completelist);
	
}
public pagereference done(){
	string urlpart = '/'+ system.currentpagereference().getparameters().get('id');
	 pagereference pr = new pagereference(urlpart);
	return pr;
}
public pagereference createcases(){
	loadcomplete = true;
	string parentid = system.currentpagereference().getparameters().get('id');
	string myquery = 'SELECT ' + utility.Editablefields('Case');
	string querysuffix = ' FROM Case WHERE id= :parentid';
	case parent  = database.query(myquery + querysuffix);
    System.debug('RK: psrent:'+parent);
	system.debug('controller-positionmap'+positionmap);									
	rowswithselect = utility.CreateCases(parent, importmap, positionmap);
	rowswithselect.sort();
	//headers.add(headers.size()-1,'CaseId');
		return null;
	}   
}