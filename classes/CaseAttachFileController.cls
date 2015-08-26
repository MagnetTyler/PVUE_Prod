public with sharing class CaseAttachFileController {

    private ID caseId;
    public string sizerror {get;set;}
    public boolean has_size_error{get;set;}
    public LIST<Attachment> attachments {
        get { 
            if ( attachments == null ){
                attachments = new List<Attachment>();
                for ( Integer i=0; i<10; i++ ) {
                    attachments.add(new Attachment(ParentId = this.caseId));
                }
                //return attachments;
            }     
            return attachments;
        }
        set;
    }
	
    public Boolean isUploaded {get; set;}

    public CaseAttachFileController() {
        isUploaded = false;
        caseId = ApexPages.currentPage().getParameters().get('cid');
        
        has_size_error = ApexPages.currentPage().getParameters().get('error') == 'true';
        if(has_size_error == true)
        	{
        		sizerror = system.label.size_error;
        	}
        
        System.debug('cid:'+caseId);
    }

    public PageReference attachCaseFiles(){

        integer mysize = integer.valueof(Org_settings__c.getInstance().Max_file_attach_size__c);
		has_size_error = false;
        Map<Integer, String> attachmentMap = new Map<Integer, String>();
        for(String paramName: ApexPages.currentPage().getParameters().keyset())
        {
           
            if(paramName.endsWith('inputfile:inputFile:file'))
            {
                String index = paramName.split(':inputfile:inputFile:file')[0] ;
                attachmentMap.put( 
                    Integer.valueof( index.substring( index.lastIndexOf(':') + 1, index.length() )),
                    ApexPages.currentPage().getParameters().get(paramName)); 
            }
        }
        
        System.debug('attachments: ' + attachments + 'max::' + mysize);
        PageReference pr;
        if ( attachments != null && attachments.size() > 0) {

            List<Document> insertableDocs = new List<Document>();
            List<Attachment> insertableAttachments = new List<Attachment>();
            for(integer i = 0; i < attachments.size() ; i++){
                
                Attachment att = attachments[i];
                if ( att.Body != null && att.Name != null && mysize > att.bodylength && 
                    !String.isBlank(attachmentMap.get(i)) && att.Name.equalsIgnoreCase(attachmentMap.get(i)) ) {
                    //If CREATE Case
		            if ( this.caseId == null ) {
                        insertableDocs.add(
                            new Document(Name = 'CaseCreateTemp_' + att.Name, FolderId = UserInfo.getUserId(), Body = att.Body));
                    }
					// Else: VIEW/UPDATE Case
                    else {
                        insertableAttachments.add(att);
                    }
                }
           
	            else
	            {
                    if((att.Body != null && att.Name != null && att.bodylength > mysize)  ||
                       (att.Body == null && att.Name == null && !String.isBlank(attachmentMap.get(i)) ))
                    {
                        has_size_error = true;
                        sizerror = system.label.size_error;
                    }
	            }
             }
            if ( insertableDocs.size() > 0 ) {
                
                		WithoutSharingUtility.doInsert(insertableDocs);
               
            
            }
            if ( insertableAttachments.size() > 0 ) {

                	insert insertableAttachments;

            }
            pr = ApexPages.currentPage();
            pr.setRedirect(true);
            pr.getParameters().put('isUploaded', 'true');
            if ( caseId != null ) {
            	pr.getParameters().put('cid', caseId);
            }
            if(has_size_error == true)
            	{
            		 pr.setRedirect(true);
           			 pr.getParameters().put('isUploaded', 'false');
           			 pr.getParameters().put('error','true'); 
            	}
        }
    
        return pr;
    }
    
    public void refreshIframe(){
        isUploaded = false;
        attachments = null;
    }
}