public class DecoResult implements Comparable{
 
 	public boolean selected{get;set;}
 	public Account TestCenter {get;set;}
 	public list<string> fieldlist {get;set;}
 	public case createdcase {get;set;}
 	public boolean created{get;set;}
 	public string details{get;set;}
 	

	public DecoResult(list<string> f_list){

		this.fieldlist = new list<string>(f_list);
		this.createdcase = new case();		
  }
  
  
  public Integer CompareTo(Object compareTo){
  	DecoResult comparetoDeco = (DecoResult)compareTo;
  	if(fieldlist[0] == comparetoDeco.fieldlist[0]) return 0;
  	if(fieldlist[0] > compareToDeco.fieldlist[0]) return 1;
  	return -1;
  }



}