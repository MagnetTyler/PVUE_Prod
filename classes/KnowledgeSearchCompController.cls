/**
* Controller for Visual force Page.
* author SFDC
*/
public with sharing class KnowledgeSearchCompController{

    // Article types for which 'mandatory' articles will always appear at the top of the knowledge search results
    private static final List<String> MANDATORY_ARTICLE_TYPES = new List<String>{'Troubleshooting', 'How_to', 'FAQ', 'Documentation'};
    public static final Map<String, Integer> ARTICLE_TYPE_SORT_ORDER_MAP;
    static {
        ARTICLE_TYPE_SORT_ORDER_MAP = new Map<String, Integer>();
        Integer i = 0;
        for ( String articleType : MANDATORY_ARTICLE_TYPES ) {
            ARTICLE_TYPE_SORT_ORDER_MAP.put(articleType, i++);
        }
    }

	//Page Size
    private static Final Integer PAGE_SIZE = 4;

    //Exclude filter criteria for UI only
    private static final String EXCLUDE_CRITERIA_FILTER = 'All';

    private Boolean checkPreselectedArticles = true; 
    private List<DecoratedArticle> decoratedArticles; 
    
    //Search String used in ArticleList tag
    public String searchstring { get; set; }
    
    //attribute for component to affect the page search
    public string final_topic_filter {
        get;
        set {

            Boolean runSearch = false;
            // If Final Topic CHANGED, AND searchstring EQUALS previous final_topic_filter, then it means 
            // that searchString was initialized from final_topic_filter (NOT user entered string), and 
            // should be re-initialized with the newly selected Final Topic.
            // User-entered search-string should NOT be overwritten
            if ( this.final_topic_filter != value && this.searchstring == this.final_topic_filter ) {
                this.searchstring = value;
                runSearch = true;
            }
            this.final_topic_filter = value;

            /*
            // If final_topic_filter is NOT blank, AND final_topic_filter has CHANGED, 
            //    AND searchstring != this.final_topic_filter
            if ( !String.isBlank(this.final_topic_filter) && hasFinalTopicChanged && 
                this.searchstring != this.final_topic_filter ) {
                    this.searchstring = null;
                    runSearch = true;
                }
            */
            // Always run search if decoratedArticles IS NULL
            if ( runSearch || this.decoratedArticles == null ) {
                doSearch();
            }
        }
    }
    
	// Parent ID that can be sent as a Component parameter to attach the selected Articles to
    public ID parentId {get; set;} 

    // Used only for NEW Case (or other objects). Holds comma-separated list of KnowledgeArticle IDs 
    // that is eventually used by the including page to attach Knowledge Articles to newly created record.
    public String selectedKnowledgeArticleIds {
        get {
            if ( selectedKnowledgeArticleIds == null ) {
                selectedKnowledgeArticleIds = '';
            }
            return selectedKnowledgeArticleIds;
        }
        set;
    }

    // Putting this list in View-State so that the quries are not run every time the user executes a search
	private List<ID> mvpMandatoryDocKaIds = new List<ID>();
    // Will be used to compare with final_topic_filter to check whether or not it has changed
    private String prevMandatoryArticlesFinalCategory;

    // Keeps track of current page & max size of article list
    private Integer currentPage = 1;
    private Integer maxSize = 1;

    //Main method containing the meat of the search logic
    public PageReference doSearch() {

        this.decoratedArticles = new List<DecoratedArticle>();

        String categoryFilter = '';
        List<DataCategoryGroupInfo> dataCategoryGroups = getDataCategoryGroupInfo();
        for ( DataCategoryGroupInfo categoryGroup : dataCategoryGroups )  {
            
            String categoryType = System.currentPageReference().getParameters().get('categoryType_' + categoryGroup.getName());
            if ( categoryType != null && !categoryType.equals('NoFilter') )  {
                if(categoryFilter != '') {
                    categoryFilter += ' AND ';
                }
                categoryFilter += categoryGroup.getName() + '__c ABOVE_OR_BELOW ' + categoryType + '__c ';
            }
        }

		// If searchString is blank and final_topic_filter is NOT, initialize searchString w/ final_topic_filter
        if ( (String.isBlank(searchString) || searchString == 'Search Knowledge...') && !String.isBlank(final_topic_filter) ) {
            searchstring = final_topic_filter;
        }

        // Fetch 'mandatory' articles for this MVP/final_topic_filter that will appear at the top of the search results
        if ( !String.isBlank(final_topic_filter) ) {

            // If final_topic_filter changed, ONLY then execute the queries
	        if ( final_topic_filter != prevMandatoryArticlesFinalCategory ) {
                mvpMandatoryDocKaIds.clear();
                prevMandatoryArticlesFinalCategory = final_topic_filter;
                for ( String articleType : MANDATORY_ARTICLE_TYPES ) {
                    List<sObject> mandatoryArticles = getArticlesByFinalCategory(articleType, final_topic_filter);
                    for ( sObject article : mandatoryArticles ) {
                        mvpMandatoryDocKaIds.add( (ID)article.get('KnowledgeArticleId') );
                    }
                }
                System.debug('mvpMandatoryDocKaIds: ' + mvpMandatoryDocKaIds);
            }

            if ( !mvpMandatoryDocKaIds.isEmpty() ) {
                // Map of KnowledgeArticleId to KnowledgeArticleVersion; this is used later to insert 
                // KnowledgeArticleVersion objects in the pre-defined order into the decoratedArticles list
                Map<ID, KnowledgeArticleVersion> kaIdToKavMap = new Map<ID, KnowledgeArticleVersion>();
                for ( KnowledgeArticleVersion kav : 
                        [SELECT Id, KnowledgeArticleId, title, Summary, ArticleType, UrlName, articlenumber, LastPublishedDate, LastModifiedById 
                         FROM KnowledgeArticleVersion 
                         WHERE KnowledgeArticleId in :mvpMandatoryDocKaIds
                            AND PublishStatus = 'Online' 
                            // SK: Hard-coding the language b/c we only have English content for now, so can't risk
                            //     NOT showing any content if the user has chosen a different language on their profile
                            AND Language = 'en_US'] ) {

                    kaIdToKavMap.put(kav.KnowledgeArticleId, kav);
                }

                // Add KnowledgeArticleVersion objects in the pre-defined order into the decoratedArticles list
                for ( ID knowledgeArticleId : mvpMandatoryDocKaIds ) {
                    this.decoratedArticles.add(new DecoratedArticle(kaIdToKavMap.get(knowledgeArticleId)));
                }
            } //END: If ( mvpMandatoryDocKaIds )
        } //END: If ( final_topic_filter )
        System.debug('this.decoratedArticles: ' + this.decoratedArticles);
        
        // If a Search is needed
        List<KnowledgeArticleVersion> searchedArticles;
        if( (!String.isBlank(searchstring) && searchstring != 'Search Knowledge...') || !String.isBlank(final_topic_filter) )  {
            
            String searchQuery = 'FIND ';
            if( !String.isBlank(searchstring) && searchstring != 'Search Knowledge...') {
                searchQuery += ' \'*' + searchstring + '*\'';
            }
            // Can't do two search strings
            else if( !String.isBlank(final_topic_filter) ) {
                searchQuery += ' \'*' + final_topic_filter + '*\'';
            }
            
            searchQuery +=
                ' IN ALL FIELDS ' + 
                ' RETURNING KnowledgeArticleVersion(' + 
                'Id, KnowledgeArticleId, title, Summary, ArticleType, UrlName, articlenumber, LastPublishedDate, LastModifiedById ' +
                'WHERE PublishStatus =\'online\' and Language = \'en_US\') ';
            
            if ( categoryFilter != '' ) {
                searchQuery += 'WITH DATA CATEGORY ' + categoryFilter ;
            }
            system.debug('searchQuery: ' + searchQuery);
            
            List<List<SObject>> searchList = search.query(searchQuery);
            System.debug('searchList: ' + searchList);
            searchedArticles = (List<KnowledgeArticleVersion>) searchList[0];
        }
        // ELSE: NO search string - do simple query
        else {
            String qryString = 
                'SELECT Id, KnowledgeArticleId, title, Summary, ArticleType, UrlName, articlenumber,LastPublishedDate,LastModifiedById ' + 
                'FROM KnowledgeArticleVersion ' +
                'WHERE (PublishStatus = \'Online\' and Language = \'en_US\') ';
            
            if ( categoryFilter != '' ) {
                qryString += 'WITH DATA CATEGORY ' + categoryFilter ;
            }
            system.debug('qryString: ' + qryString);
            
            searchedArticles = Database.query(qryString);
        }

        if ( searchedArticles != null && !searchedArticles.isEmpty() ) {

            // Adding in a separate list to sort
        	List<DecoratedArticle> searchedDecoratedArticles = new List<DecoratedArticle>();

            // Ensure that an 'MVP Mandatory' article is not added twice to the decoratedArticles list if it was 
            // also returned from the keyword search.
            Set<ID> mvpMandatoryDocKaIdsSet = new Set<ID>(mvpMandatoryDocKaIds); // Convert List to Set for comparison
            for ( KnowledgeArticleVersion kav : searchedArticles ) {
                if ( !mvpMandatoryDocKaIdsSet.contains(kav.KnowledgeArticleId) ) {
                    searchedDecoratedArticles.add(new DecoratedArticle(kav));
                }
            }

            searchedDecoratedArticles.sort();
            this.decoratedArticles.addAll(searchedDecoratedArticles);
    	}
        this.maxSize = this.decoratedArticles.size() ;
        this.currentPage = 1;
        System.debug('maxSize: ' + maxSize);
        
        // Reset the flag so that the previously attached articles appear checked on the UI
        this.checkPreselectedArticles = true;
        return null;
    }

    public List<sObject> getArticlesByFinalCategory(String articleType, String finalCategoryName) {
        String query =
            'SELECT Id, KnowledgeArticleId' + //, title, Summary, ArticleType, UrlName, articlenumber, LastPublishedDate, LastModifiedById ' +
            ' FROM '+ articleType + '__kav' +
            ' WHERE PublishStatus = \'Online\' AND Language = \'en_US\' ' + 
            	' AND Final_Category_Name__c = \'' + finalCategoryName + '\''; 
        System.debug('query:' + query);
        return  Database.query(query);
    }
    
    //Returns array of Category Groups
    public DataCategoryGroupInfo[] getDataCategoryGroupInfo() {
        return DataCategoryUtil.getInstance().getAllCategoryGroups();
    }
    
    /*
//Returns category keyword required to filter articleList.
public String getCategoryKeyword() {

DataCategoryGroupInfo[] categoryGroups =DataCategoryUtil.getInstance().getAllCategoryGroups();
String categoryCondition = '';
for (DataCategoryGroupInfo categoryGroup : categoryGroups) 
{
String selectedCategoryName =
System.currentPageReference().getParameters().Get('categoryType_'+categoryGroup.getName());
if(selectedCategoryName != null && !selectedCategoryName.equals('NoFilter')) 
{
if(categoryCondition=='' && selectedCategoryName != null)
{
categoryCondition=categoryCondition+categoryGroup.getName() + ':' +
System.currentPageReference().getParameters().Get('categoryType_'+categoryGroup.getName());
}
else 
{
categoryCondition=categoryCondition + ',' +categoryGroup.getName() + ':' +
System.currentPageReference().getParameters().Get('categoryType_'+categoryGroup.getName());
}
}
}

String categoryFilter = '';
for (DataCategoryGroupInfo categoryGroup : categoryGroups) 
{
String categoryType =
System.currentPageReference().getParameters().Get('categoryType_'+categoryGroup.getName());
if(categoryType != null && !categoryType.equals('NoFilter')) 
{
if(categoryFilter == '')
{
categoryFilter = categoryGroup.getName() + '__c ABOVE_OR_BELOW ' + categoryType
+'__c';
} 
else 
{
categoryFilter = categoryFilter + ' AND ' + categoryGroup.getName() +'__c ABOVE_OR_BELOW ' + categoryType +'__c';
}
}
}

if(categoryFilter =='') {
//maxSize = 0;
categoryCondition = 'Client_Documents:All,Topic_Type:All,Language:All' ;
}
return categoryCondition;
}
*/
    
    
    public List<DecoratedArticle> getPageArticles() {
        
        // Check previously selected/attached articles; this can't be done in doSearch() (where it makes
        // the most sense) b/c the 'parentId' may not have been populated when doSearch() runs from the
        // final_topic_filter setter.
        if ( checkPreselectedArticles ) {
            
            Set<ID> knowledgeArticleIds = getPreAttachedArticleIds();
            System.debug('knowledgeArticleIds: ' + knowledgeArticleIds);
            for ( DecoratedArticle da : decoratedArticles ) {
                if ( knowledgeArticleIds.contains(da.article.KnowledgeArticleId) ) {
                    System.debug('da.article.KnowledgeArticleId: ' + da.article.KnowledgeArticleId);
                    da.isSelected = true;
                }
            }
            // Set to FALSE so that it is NOT executed again (so that selections are retained)
            checkPreselectedArticles = false;
        }
        
        List<DecoratedArticle> pageArticles = new List<DecoratedArticle>();
        if ( !this.decoratedArticles.isEmpty() ) {
            for ( Integer i = (currentPage - 1) * PAGE_SIZE; i < (currentPage * PAGE_SIZE) && i < maxSize; i++ ) {
                pageArticles.add(decoratedArticles.get(i));
            }
        }
        return pageArticles;
    }
    
    // Action call when the new list needs to be fetched
    public PageReference refreshSearchResult() {
        maxSize = currentPage = 1;
        doSearch();
        return null;
    }
    
    // Returns whether we need to see previous button or not
    public boolean getPrevRequired() {
        return currentPage > 1;
    }
    
    // Returns whether we need to see next button or not
    public boolean getNextRequired() {
        return currentPage * PAGE_SIZE < maxSize;
    }
    
    //Returns current page number
    public Decimal getCurrentPageNumber() {
        return this.currentPage;
    }
    
    //action for next click
    public PageReference next() 
    {
        if(maxSize > this.currentPage * PAGE_SIZE) 
        {
            this.currentPage = this.currentPage + 1;
        }
        return null;
    }
    //action for previous click
    
    
    public PageReference previous() 
    {
        if(this.currentPage > 1) {
            this.currentPage = this.currentPage - 1;
        }
        return null;
    }
    
    public Map<String, String> articleTypeNameToLabelMap {
        get {
            if ( this.articleTypeNameToLabelMap == null ) {
                
                String out = '\n';
                this.articleTypeNameToLabelMap = new Map<String, String>();
                Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
                for ( String objName : gd.keySet() ) {
                    out += objName + '\n';
                    if ( objName.endsWith('__kav') ) {
                        this.articleTypeNameToLabelMap.put(objName, gd.get(objName).getDescribe().getLabel());
                    }
                }
            } // END: If ( null )
            return this.articleTypeNameToLabelMap;
        }
        private set;
    }
    
    public PageReference attachArticles() {
        
        try {
            if ( this.parentId != null ) {
                // Extend to reuse the component with other SObject types
                if ( String.valueOf(this.parentId).startsWith('500') ) {
                    attachCaseArticles();
                }
            } else {
                //Prepare selected articles for attaching
                for ( DecoratedArticle da : this.decoratedArticles ) {
                    System.debug('da: ' + da);
                    if ( da.isSelected && !selectedKnowledgeArticleIds.contains(da.article.KnowledgeArticleId) ) {
                        selectedKnowledgeArticleIds += da.article.KnowledgeArticleId + ',';
                    }
                    else if ( !da.isSelected ) {
                        selectedKnowledgeArticleIds = selectedKnowledgeArticleIds.remove(da.article.KnowledgeArticleId + ',');
                    }
                }
                System.debug('selectedKnowledgeArticleIds: ' + selectedKnowledgeArticleIds);
            } //END: Else (ParentId is null)
        } catch(Exception e) {
            System.debug('e: ' + e);
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.FATAL, 
                    'Unable to process your request at this time.  Please contact your System Administrator.'));
        }
        return null;
    }
    
    public void attachCaseArticles() {
        
        //Attach selected articles
        List<CaseArticle> attachableArticles = new List<CaseArticle>();
        List<ID> deselectedArticleIds = new List<ID>();
        for ( DecoratedArticle da : this.decoratedArticles ) {
            System.debug('da: ' + da);
            if ( da.isSelected ) {
                attachableArticles.add(new CaseArticle(CaseId = parentId, KnowledgeArticleId = da.article.KnowledgeArticleId));
            } else {
                deselectedArticleIds.add(da.article.KnowledgeArticleId);
            }
        }
        
        insert attachableArticles;
        
        //Remove Articles that appeared in the list, but were deselected
        if ( !deselectedArticleIds.isEmpty() ) {
            delete [SELECT Id from CaseArticle where CaseId = :this.parentId and KnowledgeArticleId in :deselectedArticleIds];
        }
    }
    
    private Set<ID> getPreAttachedArticleIds() {
        
        Set<ID> kaIds = new Set<ID>();
        if ( this.parentId != null ) {
            // Extend to reuse the component with other SObject types
            if ( String.valueOf(this.parentId).startsWith('500') ) {
                for ( CaseArticle ca : [SELECT KnowledgeArticleId from CaseArticle where CaseId = :parentId] ) {
                    kaIds.add(ca.KnowledgeArticleId);
                }
            }
        }//END: If ( ParentId )
        //ELSE: No ParentId
        else  if ( !String.isBlank(selectedKnowledgeArticleIds) ) {
            for ( String kaId : selectedKnowledgeArticleIds.removeEnd(',').split(',') ) {
                kaIds.add(kaId);
            }
        }
        System.debug('kaIds: ' + kaIds);
        return kaIds;
    }
    
    public class DecoratedArticle implements Comparable {
        public boolean isSelected{get;set;}
        public KnowledgeArticleVersion article {get;set;}

        public DecoratedArticle(KnowledgeArticleVersion myarticle){
            this.article = myarticle;
            this.isSelected = false;
        }
 
        //bw imported the sortable interface for sorting the results
        public Integer compareTo(Object compareTo){

            Integer result = 0;
            Integer thisSortOrder = ARTICLE_TYPE_SORT_ORDER_MAP.get(this.article.ArticleType);
            Integer compareSortOrder = ARTICLE_TYPE_SORT_ORDER_MAP.get( ((DecoratedArticle)compareTo).article.ArticleType );
            
            if ( compareSortOrder == null || thisSortOrder < compareSortOrder ) {
                result = -1;
            } else if ( thisSortOrder > compareSortOrder ) {
                result = 1;
            }
            return result;
        }	

    }
    
}