/**
 * @description       : Mock used to simulate Datadog logs call
 * @author            : Martin Lezer
 * @group             : Mocks
 * @last modified on  : 09-12-2022
 * @last modified by  : Martin Lezer
**/
@IsTest
global class DatadogCalloutMock implements HttpCalloutMock {
    public static Boolean ACTIVATE_TEST = false;
    public Boolean testError;

    public DatadogCalloutMock(){
        ACTIVATE_TEST = true;
    }

    global HTTPResponse respond ( HTTPRequest request ) {
        HttpResponse response = new HttpResponse();
        if(this.testError == false){
            response.setStatusCode(202);
        }else{
            response.setStatusCode(400);
        }

        return response;
    }
}