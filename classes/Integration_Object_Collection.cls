public with sharing class Integration_Object_Collection {

	public Exam__c exam{get;set;}
	public Candidate__c candidate{get;set;}
	public Account  TestCenter{get;set;}
	
	public Integration_Object_Collection(VTS_Registration record){
		
		this.Exam = new Exam__c(VTS_Exam_ID__c = record.exam.id, Exam_Name__c = record.exam.name, 
									Exam_Series_code__c = record.exam.code);
									
		this.Candidate = new Candidate__c(VTS_Candidate_ID__c = record.candidate.Id, CCID__c = record.candidate.clientCandidateId,
											First_Name__c = Record.Candidate.firstname, 
											Last_name__c = record.Candidate.lastname);
		


		this.TestCenter = new Account();									
	}


}