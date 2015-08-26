public class VTS_Registration implements Comparable {

    public Long id {get; set;}
    public VTS_Registration.VTS_Time appointmentTime {get; set;}
    public String processStateCode {get; set;}
    public String disposition {get; set;}
    public String status {get; set;}
    public VTS_Exam exam {get; set;}
    public VTS_TestCenter testCenter {get; set;}
    public VTS_Candidate candidate {get; set;}
    public VTS_DeliveryMode deliveryMode {get; set;}

    //bw imported the sortable interface for sorting the results
	public Integer CompareTo(Object compareTo){
		
		VTS_Registration comparetoreg = (VTS_Registration)compareTo;		
			if( Candidate.firstName == compareToreg.candidate.firstname) 
				{
					if(appointmenttime.timestampInUTC == compareToreg.appointmenttime.timestampInUTC)return 0;
					if(appointmenttime.timestampInUTC > compareToreg.appointmenttime.timestampInUTC) return 1;
					return -1;
				}
			if(candidate.firstName> compareToreg.candidate.firstname) return 1;
			
			return -1;				
	}	

    public class VTS_Time {
        public Long timestampInUTC {get; set;}
        public String displayTimeZone {get; set;}
        public Long displayTimeZoneUTCOffset {get; set;}
        public String displayTimeZoneSource {get; set;}
    }

    public class VTS_DeliveryMode {
        public Long id {get; set;}
        public String name {get; set;}
        public VTS_RemoteMonitoring remoteMonitoring {get; set;}
    }

    public class VTS_RemoteMonitoring {
        public Long id {get; set;}
        public String name {get; set;}
    }
        
}