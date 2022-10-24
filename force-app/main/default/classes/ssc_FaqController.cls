public with sharing class ssc_FaqController {
    //return topic details
    @AuraEnabled(cacheable=true)
    public static topicDetail getTopic(String topicId){
        topicDetail result = new topicDetail();
        Map<Id,topicDetail> topics = new Map<Id,topicDetail>();
        Integer maxArticles = 0;
        ConnectApi.ManagedTopic topic = getManagedTopic(topicId);
        result.topicId = topicId;
        result.name = topic.topic.name;

        if(topic.children.size() > 0) { //is a Topic --> return subtopics with top 5 articles
            maxArticles = 5;
            for(ConnectApi.ManagedTopic t : topic.children) {
                topicDetail sd = new topicDetail();
                sd.topicId = t.topic.id;
                sd.name = t.topic.name;
                sd.articles = new List<Knowledge__kav>();
                sd.articleCount = 0;
                topics.put(t.topic.id, sd);
            }
        } else {//is a SubTopic --> return topic with all articles
            result.articles = new List<Knowledge__kav>();
            result.articleCount = 0;
            topics.put(topicId, result);
        }

        for(Knowledge__kav article : [SELECT Id, Title, UrlName, ArticleTotalViewCount, LastModifiedDate,
                                        (SELECT topicId FROM TopicAssignments WHERE EntityType = 'Knowledge' AND TopicId IN :topics.keySet()) 
                                        FROM Knowledge__kav 
                                        WHERE Language = :UserInfo.getLanguage()
                                        AND PublishStatus = 'Online' 
                                        AND Id IN (SELECT EntityId FROM TopicAssignment WHERE EntityType = 'Knowledge' AND TopicId IN :topics.keySet())
                                        ORDER BY ArticleTotalViewCount DESC]) {
             for(TopicAssignment ta : article.TopicAssignments) {
                topicDetail sd = topics.get(ta.TopicId);
                sd.articleCount += 1;
                sd.viewArticlesLink = String.format(System.Label.ssc_Faq_SeeAllArticles, new List<String>{ sd.articleCount.format() });
                if(maxArticles > 0 && sd.articleCount <= maxArticles || maxArticles == 0) sd.articles.add(article);
             }
        }

        if(topic.children.size() > 0) {
            result.topics = topics.values();
        } else {
            result.articles = topics.get(topicId).articles;
        }

        return result;
    }

    @AuraEnabled(cacheable=true)
    public static List<ContentDocument> getRelatedDocs(Id recordId){
        Set<Id> cdIds = new Set<Id>();
        for (ContentDocumentLink cdl : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId]) {
            cdIds.add(cdl.ContentDocumentId); 
        }
        return [SELECT Id, Title, FileType FROM ContentDocument WHERE Id IN :cdIds];
    }
     
    @AuraEnabled
    public static string getDocURL(Id docId){
        ContentVersion cv = [SELECT Id FROM ContentVersion WHERE ContentDocumentId = :docId AND IsLatest = true];
        return URL.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/' + cv.Id;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Integer> getArticleVotes(Id articleId){
        Map<String,Integer> result = new Map<String,Integer>{ 'Up' => 0, 'Down' => 0};
        for (AggregateResult ar : [SELECT Type, COUNT(Id) cnt FROM Vote WHERE ParentId = :articleId GROUP BY Type]) {
            result.put(String.valueOf(ar.get('Type')), Integer.valueOf(ar.get('cnt')));
        }
        return result;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Vote> getUserVote(Id articleId){
        return [SELECT Id, Type FROM Vote WHERE ParentId = :articleId AND CreatedById = :UserInfo.getUserId()];
    }

    @AuraEnabled
    public static Vote setUserVote(String userVote){
        Vote newVote = (Vote)JSON.deserialize(userVote, Vote.class);
        upsert newVote;
        return newVote;
    }

    private static ConnectApi.ManagedTopic getManagedTopic(String topicId) {
        ConnectApi.ManagedTopicCollection managedTopic = ConnectApi.ManagedTopics.getManagedTopics(
            Test.isRunningTest() ? [SELECT Id FROM Network LIMIT 1].Id : Network.getNetworkId(), 
            ConnectApi.ManagedTopicType.Navigational,
            2
        );

        for(ConnectApi.ManagedTopic t : managedTopic.managedTopics) {
            if(t.topic.id == topicId) {
                return t;
            } 

            for(ConnectApi.ManagedTopic c : t.children){
                if(c.topic.id == topicId) {
                    return c;
                } 
            }                              
        }

        return null;
    }

    public class topicDetail {
        @AuraEnabled public Id topicId;
        @AuraEnabled public String name;
        @AuraEnabled public Integer articleCount;
        @AuraEnabled public String viewArticlesLink;
        @AuraEnabled public List<topicDetail> topics;
        @AuraEnabled public List<Knowledge__kav> articles;
    }
    
}