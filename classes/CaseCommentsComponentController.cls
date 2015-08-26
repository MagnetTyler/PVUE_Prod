public with sharing class CaseCommentsComponentController {
    
    public Id caseId {get; set;}
    public string pagetype {get;set;}
    public boolean Caseclosed{get;set;}
    public String sortDir {
    		get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
    		set;
  		}
	//list of agents names in my test center to support mask for comment created by
	public list <string> myagents{
		get
			{if(myagents == null && userinfo.getusertype() != 'Standard')
				{	myagents = new list<string>();
					string myaccountid = [select contact.accountId from user where id = :userinfo.getUserId()].contact.accountId;
					for(user each:[select name, username, contact.accountId from user where contact.accountId = :myaccountid ])
						{
							myagents.add( each.name);
						}
				}
			return myagents;
			}
		set;	
	}

  // the current field to sort by. defaults to last name
  	public String sortField {
    		get  { 
    				
    				if (sortField == null) 
    					{sortField = 'default';}
    					 
    			 return sortField;  }
    		set;
  		}
    public cComments[] comments{
        get{
            List<cComments> comments = new List<cComments>();
            for(CaseComment comment : [Select LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name, IsPublished, CreatedDate, CreatedBy.Id, CreatedBy.Name, CommentBody From CaseComment c where ParentId = :caseId order by c.LastModifiedDate desc, c.CreatedDate desc])
            {
                cComments tempcComment = new cComments();
                tempcComment.cComment = comment;
                
                // Build String to display.
                tempcComment.commentText = '<b>Created By: ';
                if ( pagetype == 'Community' ) {
                	tempcComment.commentText += comment.CreatedBy.Name;
                } else {
                	tempcComment.commentText += '<a href=\'/' + comment.CreatedBy.Id + '\'>' + comment.CreatedBy.Name + '</a>';
                }
                tempcComment.commentText += ' (' + comment.CreatedDate.format() + ') </b><br>';
                //tempcComment.commentText += 'Last Modified By: <a href=\'/' + comment.LastModifiedBy.Id + '\'>' + comment.LastModifiedBy.Name + '</a> (' + comment.LastModifiedDate.format() + ')</b><br>';
                tempcComment.commentText += comment.CommentBody;
                
                if(comment.IsPublished)
                    tempcComment.PublicPrivateAction = 'Make Private';
                else
                    tempcComment.PublicPrivateAction = 'Make Public';
                //Add to list
                comments.add(tempcComment);	
            }
            return comments;
        }
        
        set;
    }
    
    public PageReference NewComment()
    {
        PageReference pr = new PageReference('/00a/e?parent_id='+ caseId + '&retURL=%2F' + caseId);
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference deleteComment()
    {
        Id commentId = ApexPages.currentPage().getParameters().get('CommentId_d');
        
        for(cComments Comment : comments)
        {
            
            if(Comment.cComment.Id == commentId)
            {	
                delete Comment.cComment;	
                break;
            }
        }
        
        PageReference pg = new PageReference('/' + caseId);
        pg.setRedirect(true);
        return pg;
    }	
    
    public PageReference makePublicPrivate()
    {
        Id commentId = ApexPages.currentPage().getParameters().get('CommentId_p');
        for(cComments Comment : comments)
        {
            if(Comment.cComment.Id == commentId)
            {	
                Comment.cComment.IsPublished = !Comment.cComment.IsPublished;
                if(Comment.cComment.IsPublished)
                    Comment.PublicPrivateAction = 'Make Private';
                else
                    Comment.PublicPrivateAction = 'Make Public';
                
                update Comment.cComment;	
                break;
            }
        }
        PageReference pg = new PageReference('/' + caseId);
        pg.setRedirect(true);
        return pg;
    }
    
    public class cComments {
        
        public CaseComment cComment {get; set;}
        public String commentText {get; set;}
        public String PublicPrivateAction {get; set;}
    }
}