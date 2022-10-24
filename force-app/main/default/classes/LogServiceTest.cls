/**
 * @description       : Test used to verify that the log service publish platform events
 * @author            : Martin Lezer
 * @group             : Tests
 * @last modified on  : 09-12-2022
 * @last modified by  : Martin Lezer
**/
@IsTest public class LogServiceTest {
    @IsTest
    static void testStatic(){
        // test api log
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://test.com');
        request.setBody('Test');
        HttpResponse response = new HttpResponse();
        response.setBody('Test');
        request.setMethod('POST');
        response.setStatusCode(404);
        LogService.log(LogService.LOG_TYPE.ERROR, LogService.PROCESS.BACK_OFFICE_CALLOUT, request, response, 'This is a test', 'LogServiceTest');

        System.assertEquals(1, LogService.results.size());
        for(Database.SaveResult result : LogService.results){
            System.assertEquals(true, result.isSuccess());
        }

        // test generic log
        LogService.log(LogService.LOG_TYPE.SUCCESS, LogService.PROCESS.ACCOUNT_BIZDEV_CHANGED, new Set<Id>{UserInfo.getUserId()}, 'This is a test', 'LogServiceTest');

        System.assertEquals(1, LogService.results.size());
        for(Database.SaveResult result : LogService.results){
            System.assertEquals(true, result.isSuccess());
        }
    }

    @IsTest
    static void testImpl(){
        LogService logs = new LogService('LogServiceTest');

        // test api log
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://test.com');
        request.setBody('Test');
        request.setMethod('POST');
        HttpResponse response = new HttpResponse();
        response.setBody('Test');
        response.setStatusCode(404);
        logs.addLog(LogService.LOG_TYPE.ERROR, LogService.PROCESS.BACK_OFFICE_CALLOUT, request, response, 'This is a test');

        // test generic log
        logs.addLog(LogService.LOG_TYPE.SUCCESS, LogService.PROCESS.ACCOUNT_BIZDEV_CHANGED, new Set<Id>{UserInfo.getUserId()}, 'This is a test');

        Test.startTest();
        logs.publishLogs();
        Test.stopTest();

        System.assertEquals(2, LogService.results.size());
        for(Database.SaveResult result : LogService.results){
            System.assertEquals(true, result.isSuccess());
        }
    }

    @IsTest
    static void testInvocable(){
        LogService.LogWrapper wrapper = new LogService.LogWrapper();
        wrapper.component = 'TestClass';
        wrapper.message = 'Test message';
        wrapper.process = 'Flow';
        wrapper.recordId = UserInfo.getUserId();
        wrapper.type = 'SUCCESS';

        Test.startTest();
        LogService.log(new List<LogService.LogWrapper>{wrapper});
        Test.stopTest();

        System.assertEquals(1, LogService.results.size());
        for(Database.SaveResult result : LogService.results){
            System.assertEquals(true, result.isSuccess());
        }
    }
}