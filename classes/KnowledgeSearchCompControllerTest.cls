@isTest(SeeAllData=true)
private class KnowledgeSearchCompControllerTest {

    static testMethod void testCaseCreate() {

        KnowledgeSearchCompController cntrlr = new KnowledgeSearchCompController();
        System.assert(!cntrlr.getDataCategoryGroupInfo().isEmpty());
        System.assert(!cntrlr.articleTypeNameToLabelMap.isEmpty());
        cntrlr.final_topic_filter = '';

        List<ID> fixedSearchResultIds = new List<ID>();
        for ( KnowledgeArticleVersion kav : 
				[SELECT Id FROM KnowledgeArticleVersion WHERE PublishStatus = 'Online' AND Language = 'en_US' limit 20] ) {
			fixedSearchResultIds.add(kav.Id);
        }
        Test.setFixedSearchResults(fixedSearchResultIds);

        cntrlr.final_topic_filter = '2003 Upload backup biometric';
        System.assertEquals(cntrlr.final_topic_filter, cntrlr.searchstring);

        cntrlr.searchstring = 'test';
        cntrlr.refreshSearchResult();

        System.assert(!cntrlr.getPageArticles().isEmpty());
        //System.assertEquals('Client_Documents:All,Topic_Type:All,Language:All', cntrlr.getCategoryKeyword());

        System.assert(!cntrlr.getPrevRequired());
        System.assertnotequals(null, cntrlr.getNextRequired());
        System.assertEquals(1, cntrlr.getCurrentPageNumber());

        cntrlr.next();
       //v System.assertEquals(2, cntrlr.getCurrentPageNumber());

        cntrlr.previous();
        System.assertEquals(1, cntrlr.getCurrentPageNumber());

        List<KnowledgeSearchCompController.DecoratedArticle> articles = cntrlr.getPageArticles();
        for ( KnowledgeSearchCompController.DecoratedArticle da : articles ) {
            da.isSelected = true;
        }
        cntrlr.attachArticles();

        System.assertNotEquals(null, cntrlr.selectedKnowledgeArticleIds);
        for ( KnowledgeSearchCompController.DecoratedArticle da : articles ) {
            System.assert(cntrlr.selectedKnowledgeArticleIds.contains(da.article.KnowledgeArticleId));
        }
    }

    static testMethod void testCaseViewEdit() {

        Case cs = new Case(Subject = 'test sub...');
        insert cs;

        List<ID> fixedSearchResultIds = new List<ID>();
        List<KnowledgeArticleVersion> kavs = 
            [SELECT KnowledgeArticleId 
             FROM KnowledgeArticleVersion 
             WHERE PublishStatus = 'Online' AND Language = 'en_US' limit 20];
        for ( KnowledgeArticleVersion kav : kavs ) {
			fixedSearchResultIds.add(kav.Id);
        }
        Test.setFixedSearchResults(fixedSearchResultIds);

        List<CaseArticle> caseArticles = new List<CaseArticle>();
        caseArticles.add(new CaseArticle(CaseId = cs.Id, KnowledgeArticleId = kavs[0].KnowledgeArticleId));
        caseArticles.add(new CaseArticle(CaseId = cs.Id, KnowledgeArticleId = kavs[0].KnowledgeArticleId));
        insert caseArticles;

        Test.startTest();
        KnowledgeSearchCompController cntrlr = new KnowledgeSearchCompController();
        System.assert(!cntrlr.getDataCategoryGroupInfo().isEmpty());
        System.assert(!cntrlr.articleTypeNameToLabelMap.isEmpty());
        cntrlr.final_topic_filter = '';
        cntrlr.parentId = cs.Id;

        cntrlr.searchstring = 'test';
        cntrlr.refreshSearchResult();

        List<KnowledgeSearchCompController.DecoratedArticle> articles = cntrlr.getPageArticles();
        articles[0].isSelected = true;
      //  articles[1].isSelected = true;
        cntrlr.attachArticles();

        System.assertEquals(1, [select count() from CaseArticle where CaseId = :cs.Id]);
        Boolean hasMore = false;
        do {
            for ( KnowledgeSearchCompController.DecoratedArticle article : cntrlr.getPageArticles() ) {
                article.isSelected = false;
            }
            if ( hasMore = cntrlr.getNextRequired() ) {
                cntrlr.next();
            }
        } while ( hasMore );
        cntrlr.attachArticles();

        System.assertEquals(0, [select count() from CaseArticle where CaseId = :cs.Id]);
    }

    static testMethod void testCaseCreateCategorySearch() {

        KnowledgeSearchCompController cntrlr = new KnowledgeSearchCompController();
        System.assert(!cntrlr.getDataCategoryGroupInfo().isEmpty());
        System.assert(!cntrlr.articleTypeNameToLabelMap.isEmpty());
        cntrlr.final_topic_filter = '';

        List<ID> fixedSearchResultIds = new List<ID>();
        for ( KnowledgeArticleVersion kav : 
				[SELECT Id FROM KnowledgeArticleVersion WHERE PublishStatus = 'Online' AND Language = 'en_US' limit 20] ) {
			fixedSearchResultIds.add(kav.Id);
        }
        Test.setFixedSearchResults(fixedSearchResultIds);

        System.currentPageReference().getParameters().put('categoryType_Language', 'English');
        System.currentPageReference().getParameters().put('categoryType_Dcoument_Type', 'Client_Guides');
        //System.assertEquals('Client_Documents:Client_Guides,Topic_Type:All,Language:English', cntrlr.getCategoryKeyword());

        cntrlr.final_topic_filter = '2003 Upload backup biometric';
        cntrlr.refreshSearchResult();

        System.assert(!cntrlr.getPageArticles().isEmpty());
    }

}