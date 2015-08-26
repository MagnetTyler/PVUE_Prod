public class VTS_Hold {
    public Long id {get; set;}
    public Long registrationID {get; set;}
    public map<string,string> registration {get;set;}
    public String holdTypeCode {get; set;}
    public String comment {get; set;}
    public Long vssTechID {get; set;}
    public Boolean isActive {get; set;}
    public Long createDate {get; set;}
    public VTS_Registration vregistration {get; set;}
}