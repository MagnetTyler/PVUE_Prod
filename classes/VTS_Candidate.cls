public class VTS_Candidate {

    public Long id {get; set;}
    public Long candidateId {get;set;}
    public Long clientId {get; set;}
    public String clientCandidateId {get; set;}
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String middleInitial {get; set;}
    public String middleName {get; set;}
    public String salutation {get; set;}
    public String suffix {get; set;}
    public String email {get; set;}
    public string dob {get; set;}


    public VTS_Address primaryAddress {get; set;}
    public List<VTS_Address> alternateAddresses {get; set;}
    public List<VTS_Candidate.ClientCandidate> clientCandidates {get; set;}

    //SK: For some API calls (e.g. Candidate Search), the response has Address fields on the Candidate 
    //    object. For some other API calls (e.g. GetCandidateByCandidateId), the address fields are on a
    //    a separate Address object on Candidate.
    public String addressLine1 {get; set;}
    public String addressLine2 {get; set;}
    public String addressLine3 {get; set;}
    public String city {get; set;}
    public String stateCode {get; set;}
    public String postalCode {get; set;}
    public String countryCode {get; set;}
    public String phone {get; set;}
    
        //additional fields BW 7-10  based on new build in VTS
    public string Statename{get;set;}
    public string Countryname {get;set;}

    public class ClientCandidate {
        public Long clientId {get; set;}
        public String clientCandidateId {get; set;}
    }

    public class SearchCriteria {
        public String clientID {get; set;}
        public String clientCandidateID {get; set;}
        public String firstName {get; set;}
        public String lastName {get; set;}
        public String postalCode {get; set;}
        public String email {get; set;}
        public String phone {get; set;}
        public Date birthDate {get; set;}
        public String city {get; set;}
        public String country {get; set;}
    }
}