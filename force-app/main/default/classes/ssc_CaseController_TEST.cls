@isTest class ssc_CaseController_TEST {
    @TestSetup
    static void makeData(){
        Case c = new Case(
            Subject = 'Test'
        );
        insert c;
        
        EmailMessage mail = New EmailMessage(
            FromAddress ='test@test.co', 
            ToAddress= 'testingit@gmail.com',
            Subject = 'Testing',
            TextBody = 'this his the message of the email',
            parentId = c.id
        );
        Insert mail;

        insert new CaseComment(ParentId = c.id, IsPublished = true, CommentBody = 'comment');
    }

    static testMethod void test_getCaseMessages() {
        Id caseId = [select id from case limit 1].id;

        List<ssc_CaseController.caseMessage> messages = ssc_CaseController.getCaseMessages(caseId);
    }

    static testMethod void test_addComment() {
        Id caseId = [select id from case limit 1].id;

        ssc_CaseController.addComment(caseId, 'test');
    }

    static testMethod void test_addFileComment() {
        Id caseId = [select id from case limit 1].id;

        ssc_CaseController.addFileComment(caseId, 'test.pdf');
    }
}