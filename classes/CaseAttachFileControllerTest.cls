@isTest
public class CaseAttachFileControllerTest {
    public static testMethod void testAttachCaseFiles(){
       
        Org_Settings__c orgSetting = new Org_Settings__c(	Max_File_Attach_Size__c = 250000000 );
        insert orgSetting;
       
        Case c =  testutil.createCase(true, [select id from recordtype where name = 'Exam delivery issue'].id);
        
        PageReference thePage =  Page.CaseAttachFile;
        thePage.getParameters().put('cid',c.id);
		
        test.setCurrentPage(thePage);
        CaseAttachFileController cntrl = new CaseAttachFileController();
        for( integer i = 0; i<10 ; i++)
        {
            thePage.getParameters().put(i+':inputfile:inputFile:file','AA Test Doc'+i);
            cntrl.attachments[i] = (Attachment) JSON.deserialize('{"BodyLength": 250000}', Attachment.class);
            cntrl.attachments[i].Parentid = c.id;
            cntrl.attachments[i].Name = 'AA Test Doc'+i;
            cntrl.attachments[i].Body = Blob.valueOf('Test Document '+i);
            
        }
        cntrl.attachCaseFiles();
        System.assertEquals(10, cntrl.attachments.size()); //As 10 documents are initially added to list
        
        LIST<Attachment> insertedAttachments = [SELECT Id, Name, Body, BodyLength, LastModifiedBy.Name, CreatedBy.Name, LastModifiedDate FROM Attachment 
                                       WHERE parentid =: c.id];
        System.assertEquals(10, insertedAttachments.size());
        
        String isUploaded = ApexPages.currentPage().getParameters().get('isUploaded');
        System.assertEquals('true', isUploaded);
        
        cntrl.refreshIframe();
        System.assertEquals(false, cntrl.isUploaded);
        
    }
    public static testMethod void testAttachCaseFilesWithoutParent(){
       
        Org_Settings__c orgSetting = new Org_Settings__c(	Max_File_Attach_Size__c = 250000000 );
        try{
            insert orgSetting;
            }
        catch (system.dmlexception concurrencty)
            {
                insert orgSetting;
            }    
        PageReference thePage =  Page.CaseAttachFile;
    
        test.setCurrentPage(thePage);
        CaseAttachFileController cntrl = new CaseAttachFileController();
        for( integer i = 0; i<10 ; i++)
        {
            thePage.getParameters().put(i+':inputfile:inputFile:file','AA Test Doc'+i);
            cntrl.attachments[i] = (Attachment) JSON.deserialize('{"BodyLength": 250000}', Attachment.class);
            cntrl.attachments[i].Name = 'AA Test Doc'+i;
            cntrl.attachments[i].Body = Blob.valueOf('Test Document '+i);
            
        }
        
        cntrl.attachCaseFiles();
        System.assertEquals(10, cntrl.attachments.size()); //As 10 documents are initially added to list
        
        LIST<Document> insertedDocuments = [SELECT Id, Name, Body, BodyLength, LastModifiedBy.Name, CreatedBy.Name, LastModifiedDate
                                            FROM Document 
                                            WHERE  FolderId =: userinfo.getUserId()];
        System.assertEquals(10, insertedDocuments.size());
        
        String isUploaded = ApexPages.currentPage().getParameters().get('isUploaded');
        System.assertEquals('true', isUploaded);
        
        cntrl.refreshIframe();
        System.assertEquals(false, cntrl.isUploaded);
        
    }
    
     public static testMethod void testAttachCaseFilesNegativeTest(){
       
         Org_Settings__c orgSetting = new Org_Settings__c(	Max_File_Attach_Size__c = 250000000 );
         insert orgSetting;
         
         PageReference thePage =  Page.CaseAttachFile;
         thePage.getParameters().put('error', 'true');
         
         
         test.setCurrentPage(thePage);
         CaseAttachFileController cntrl = new CaseAttachFileController();
         for( integer i = 0; i<10 ; i++)
         {
             thePage.getParameters().put(i+':inputfile:inputFile:file','AA Test Doc'+i);
             cntrl.attachments[i] = (Attachment) JSON.deserialize('{"BodyLength": 25000000}', Attachment.class);
             cntrl.attachments[i].Name = 'AA Test Doc'+i;
             cntrl.attachments[i].Body = Blob.valueOf('Test Document '+i);
             
         }
         cntrl.attachments[9].Name = null;
         cntrl.attachments[9].Body = null;
        
         cntrl.attachCaseFiles();
         System.assertEquals(10, cntrl.attachments.size()); //As 10 documents are initially added to list
         
         
         System.assertEquals(true,cntrl.has_size_error);
         
         String isUploaded = ApexPages.currentPage().getParameters().get('isUploaded');
         System.assertEquals('false', isUploaded);
         
        
    }
}