@isTest(SeeAllData=true) class ssc_FaqController_TEST {
    static Id articleId;
    static {
        Knowledge__kav article = new Knowledge__kav(
            Title = 'TESTarticleTitle',
            Summary = 'TESTarticleBody',
            UrlName = 'TESTarticleUrlName',
            Language = 'en_US'
          );

        insert article;

        ContentVersion doc = new ContentVersion(
            Title = 'TEST',
            PathOnClient = 'TEST.pdf',
            VersionData = Blob.valueOf('Unit Test'),
            FirstPublishLocationId = article.Id,
            ContentLocation = 'S',
            IsMajorVersion = true
        );
        
        insert doc;

        articleId = article.Id;
    }

    static testMethod void test_getTopic() {
        ConnectApi.ManagedTopicCollection topics = ConnectApi.ManagedTopics.getManagedTopics(
            [SELECT Id FROM Network LIMIT 1].Id, 
            ConnectApi.ManagedTopicType.Navigational,
            1
        );

        ssc_FaqController.getTopic(topics.managedTopics[0].topic.id);
    }

    static testMethod void test_getArticleVotes() {
        ssc_FaqController.getArticleVotes(articleId);
    }

    static testMethod void test_getUserVote() {
        ssc_FaqController.getUserVote(articleId);
    }

    static testMethod void test_setUserVote() {
        Id knowledgeArticleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id = :articleId].knowledgeArticleId;
        ssc_FaqController.setUserVote(JSON.serialize(new Vote(ParentId = knowledgeArticleId, Type = 'Up')));
    }

    static testMethod void test_getRelatedDocs() {
        ssc_FaqController.getRelatedDocs(articleId);
    }

    static testMethod void test_getDocURL() {
        ssc_FaqController.getDocURL([SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :articleId].ContentDocumentId);
    }


}