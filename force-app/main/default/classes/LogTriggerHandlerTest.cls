/**
 * @description       : Tests for publishing log platform events and datadog callout when received
 * @author            : Martin Lezer
 * @group             : Tests
 * @last modified on  : 09-12-2022
 * @last modified by  : Martin Lezer
**/
@IsTest public class LogTriggerHandlerTest {
    @IsTest static void testLog(){
        Account acc = new TestFactory().getAccountFR('Test');
        insert acc;

        Test.setMock(HttpCalloutMock.class, new DatadogCalloutMock());

        Test.startTest();
        LogService.log(LogService.LOG_TYPE.ERROR, LogService.PROCESS.ACCOUNT_BIZDEV_CHANGED, new Set<Id>{acc.Id}, 'Test message', 'LogTriggerHandlerTest');
        Test.stopTest();

        System.assertEquals(1, LogService.results.size());
        for(Database.SaveResult result : LogService.results){
            System.assertEquals(true, result.isSuccess());
        }
    }

    @IsTest static void testAPILog(){
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://test.com');
        request.setBody('{"test": "Test"}');
        request.setMethod('POST');

        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{}');

        Test.setMock(HttpCalloutMock.class, new DatadogCalloutMock());

        Test.startTest();
        LogService.log(LogService.LOG_TYPE.ERROR, LogService.PROCESS.BACK_OFFICE_CALLOUT, request, response, 'Test message', 'LogTriggerHandlerTest');
        Test.stopTest();

        System.assertEquals(1, LogService.results.size());
        for(Database.SaveResult result : LogService.results){
            System.assertEquals(true, result.isSuccess());
        }
    }

    @IsTest static void testError(){
        Account acc = new TestFactory().getAccountFR('Test');
        insert acc;

        DatadogCalloutMock mock = new DatadogCalloutMock();
        mock.testError = true;
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        LogService.log(LogService.LOG_TYPE.ERROR, LogService.PROCESS.ACCOUNT_BIZDEV_CHANGED, new Set<Id>{acc.Id}, 'Test message', 'LogTriggerHandlerTest');
        Test.stopTest();

        System.assertEquals(1, LogService.results.size());
        for(Database.SaveResult result : LogService.results){
            System.assertEquals(true, result.isSuccess());
        }
    }
}