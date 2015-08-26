public with sharing class DecisionMatrix2 {
	public static selectoption pleaseselect = new SelectOption('','Select one');
	public SiteObject MySiteObject {get;set;}
	public RegObject MyRegObject {get;set;}
	public CandidateObject myCandObject{get;set;}
	public static boolean SSO_In_Progress;

	public DecisionMatrix2(string personalist){
		
		//
		//	This class was written to facilitate the Case type selection matrix
		//		@param  The code needs an argument of Persona to build out the matrix. 
		//			    The persona is a comma delimited list of permission sets for the associated with a user	
		//		The object builds out a dynamic 2-three tier selection matrix for choosing a case type
		//
		//object has a SiteObject and RegObject;
		//Each of those objects contains a map<string,list<categoryObject>>
		//Each CategoryObject has:
		//   	a categorySelectOption
		// 	 	a set<selectOption> for Subcategories
		//		a set<selectoption for Topics
		//		boolean values indicating if their are subcategories,
		//
		//
				
		this.MySiteObject = new SiteObject();
		this.MyRegObject  = new RegObject();
		this.myCandObject = new CandidateObject();
		
		// select a group of Custom Setting records that represent the case record types that that user should be able to
		// create,  Persona is a comma separated list on the Case_Topic_and_Category__c record.  each of the returned objects
		// is turned into a class to be used on the page.
		


		
				
			
		if(userinfo.getusertype() =='Standard')
			{
				for(string persona:personalist.split(','))
					{
			
						for(Case_Topic_And_Category__c CTT:[select Category_Name__c, Has_Sub_Category__c, subcategories__c, Candidate_case__c,
							  topic__c, Community__c, persona__c, Site_Case__c, Registration_Case__c, Personas_that_work_the_case__c, name
							  FROM Case_Topic_And_Category__c where persona__c 
							  like :'%'+persona+'%' ])
							  	
						{	
							system.debug('start of CTT Loop'+CTT);	
							CategoryObject myco = new CategoryObject(CTT);
					
		//the created objects are added to the maps on the SiteObject and RegObject objects as appropriate
							if(myco.sitecase) 
								{
									system.debug('start of site loop'+myco);
									for(string mytopic:myco.topics)	
									{		
										list<categoryObject> sitelist = MySiteObject.sitemap.get(mytopic);
										
										if(sitelist == null) 
											{
												sitelist = new list<categoryObject>();
											}	
				
										sitelist.add(myco);														
										MySiteObject.sitemap.put(mytopic,sitelist);	
									}  //end topic loop
									mysiteobject.hasitems = true;
								} //end if myco.sitecase					
					
					if(myco.regcase) 
						{
							for(string mytopic:myco.topics)
								{	
									list<categoryObject> reglist = MyRegObject.regmap.get(mytopic);
									
									if(reglist == null) 
										{
											reglist = new list<categoryObject>();
										}
									reglist.add(myco);	
									MyRegObject.regmap.put(mytopic,reglist);
								} //end topics loop		
								myRegObject.hasitems = true;					
						}//end if myco.regcase
					if(myco.candcase) 
								{
									system.debug('start of candidate loop'+myco);
									for(string mytopic:myco.topics)	
									{		
										list<categoryObject> candlist = MyCandObject.candmap.get(mytopic);
										
										if(candlist == null) 
											{
												candlist = new list<categoryObject>();
											}	
				
										candlist.add(myco);														
										MyCandObject.candmap.put(mytopic,candlist);	
									}  //end topic loop
									myCandObject.hasitems = true;
								} //end if myco.candcase	
				} //End of SOQL loop for
			}  //End personalist split
		} // End of Standard user segment

	//Start of Community User segment
	else
		{
		for(string persona:personalist.split(','))
		
			{
				for(Case_Topic_And_Category__c CTT:[select Category_Name__c, Has_Sub_Category__c, subcategories__c, Candidate_case__c, 
									  topic__c, Community__c, persona__c, Site_Case__c, Registration_Case__c, Personas_that_work_the_case__c, name
									  FROM Case_Topic_And_Category__c where persona__c 
									  like :'%'+persona+'%' and Community__c = true])
							  	
				{	
					system.debug('start of CTT Loop'+CTT);	
					CategoryObject myco = new CategoryObject(CTT);
					
		//the created objects are added to the maps on the SiteObject and RegObject objects as appropriate
					if(myco.forCommunity) 
					{
						system.debug('start of site loop'+myco);
						for(string mytopic:myco.topics){		
							list<categoryObject> sitelist = MySiteObject.sitemap.get(mytopic);
							
							if(sitelist == null) 
								{
									sitelist = new list<categoryObject>();
								}	
	
							sitelist.add(myco);														
							MySiteObject.sitemap.put(mytopic,sitelist);	
						}
					}					
					
					if(myco.forCommunity) 
					{
						for(string mytopic:myco.topics){	
							list<categoryObject> reglist = MyRegObject.regmap.get(mytopic);
							
							if(reglist == null) 
								{
									reglist = new list<categoryObject>();
								}
							reglist.add(myco);	
							MyRegObject.regmap.put(mytopic,reglist);
						}						
					}
				}
			}
		}		
				system.debug('this is the constructed DM'+mysiteobject);			
	}


	public class categoryObject{
		//this class is the object that stores the core information for the topic and category process
		//a list of these objects is used in the decision matrix and a map of these objects is constructed in the CREATEPOC
		//controller streamline efficiency.
		//
		//@param  the constructor takes an argument of Case_topic_and_Category__c record which has all the data in flat format via 
		//	csv fields.  items are decompressed into the CategoryObject Object


		public Selectoption categoryoption{get;set;}
		public boolean has_subcategories{get;set;}
		public set<selectOption> subcategories{get;set;}
		public boolean forCommunity {get;set;}
		public boolean sitecase {get;set;}
		public boolean regcase{get;set;}
		public boolean candcase{get;set;}
		public set<string> Topics {get;set;}
		
		
		public categoryObject(Case_Topic_And_Category__c CS_Cat){
			
			system.debug('Start of CategoryObject Constructor');

			this.forCommunity = CS_Cat.Community__c;
			this.has_subcategories = CS_Cat.Has_Sub_Category__c;			
			this.categoryoption = new SelectOption(CS_Cat.Category_Name__c,CS_Cat.Category_Name__c);			
			this.sitecase = CS_Cat.Site_case__c;
			this.regcase = CS_Cat.Registration_Case__c; 
			this.candcase = CS_Cat.Candidate_Case__c;
			this.topics = new set<string>();
			
			if(CS_Cat.topic__c !=null){
				for(string top:CS_Cat.topic__c.split(',')){
					topics.add(top);
				}
			}
			//Construct the list of subcategories selectoptions
			
			this.subcategories = new set<selectOption>();	
			
			
			if(this.has_subcategories == true){
			
				for (string  subc:CS_Cat.subcategories__c.split(',')) 
					{
						SelectOption SO = new SelectOption(subc,subc);
						subcategories.add(SO);
					}					
				}
				
				
			system.debug('End of CategoryObject Constructor');
			//end of CategoryObjectConstructor
			}
		
		}
	

	public Class SiteObject{
		
		public map<string,list<categoryObject>> sitemap {get;set;}
		public boolean hasitems{get;set;}
		
		public SiteObject() 
			{
				this.sitemap = new map<string,list<categoryObject>>();
				this.hasitems = false;
			}
				
		}

	Public Class RegObject{
		public map<string,list<categoryObject>> RegMap{get;set;}
		public boolean hasitems{get;set;}
		public RegObject() 			
			{
				this.RegMap = new map<string,list<categoryObject>>(); 
				this.hasitems = false;
			}
		}
		
	Public Class CandidateObject{
		public map<string, list<categoryObject>> CandMap {get;set;}
		public boolean hasitems{get;set;}
		public CandidateObject()
			{
				this.CandMap = new map<string, list<categoryObject>>();
				this.hasitems = false;
			}

		}	

}