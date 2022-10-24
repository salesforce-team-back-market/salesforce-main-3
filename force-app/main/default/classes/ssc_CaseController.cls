public with sharing class ssc_CaseController {
    @AuraEnabled
    public static List<caseMessage> getCaseMessages(String recordId) {
        List<caseMessage> messages = new List<caseMessage>();
        String sellerEmail = [SELECT ContactEmail FROM Case WHERE  Id = :recordId].ContactEmail;

        if(String.isBlank(sellerEmail)) sellerEmail = '';

        if(String.isBlank(recordId)) return messages;

        for(EmailMessage m : [SELECT id,TextBody,HtmlBody,CreatedDate,Incoming,FromName,FromAddress,ToAddress,CcAddress,BccAddress  from EmailMessage where parentId = :recordId and status != '5']) {
            if(
                m.FromAddress?.containsIgnoreCase(sellerEmail) ||
                m.ToAddress?.containsIgnoreCase(sellerEmail) ||
                (m.CcAddress != null && m.CcAddress?.containsIgnoreCase(sellerEmail)) ||
                (m.BccAddress != null && m.BccAddress?.containsIgnoreCase(sellerEmail))

            ) {
                caseMessage cm = new caseMessage();
                cm.id = m.id;
                cm.messageType = 'mail';
                cm.body = (m.htmlBody != null) ? m.HtmlBody : m.TextBody;
                cm.createdDateTime = m.createdDate;
                cm.createdByName = m.Incoming ? m.FromName : System.Label.ssc_CaseFeed_sellerSupport;
                messages.add(cm);
            }
        }    
        
        for(casecomment cc : [SELECT id,CommentBody,CreatedDate, CreatedBy.Name from casecomment where parentId = :recordId and IsPublished = true]) {
            caseMessage cm = new caseMessage();
            cm.id = cc.id;
            cm.messageType = 'comment';
            cm.body = cc.CommentBody;
            cm.createdDateTime = cc.createdDate;
            cm.createdByName = cc.createdby.name;
            messages.add(cm);
        }
        
        messages.sort();

        return messages;
    }
    
    @AuraEnabled
    public static void addComment(Id recordId, String comment) {
        insert new CaseComment(ParentId = recordId, IsPublished = true, CommentBody = comment);
    }
    
    @AuraEnabled
    public static void addFileComment(Id recordId, String fileNames) {
        insert new CaseComment(ParentId = recordId, IsPublished = false, CommentBody = System.Label.ssc_CaseFeed_sellerAddedFiles+' ' + fileNames);
    }
    
    
    public class caseMessage implements Comparable {
        @AuraEnabled public Id id;
        @AuraEnabled public String messageType;
        @AuraEnabled public String body;
        @AuraEnabled public String createdByName;
        @AuraEnabled public datetime createdDateTime;

        public Integer compareTo(Object compareTo) {
            caseMessage compareToMsg = (caseMessage)compareTo;
            return (createdDateTime > compareToMsg.createdDateTime) ? -1 : 1;
        }
    }
}