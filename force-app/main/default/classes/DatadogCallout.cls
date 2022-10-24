/**
 * @description       : Used to call Datadog api to create logs from platform events
 * @author            : Martin Lezer
 * @group             : Callouts
 * @last modified on  : 09-12-2022
 * @last modified by  : Martin Lezer
**/
public class DatadogCallout implements Queueable, Database.AllowsCallouts {
    private List<SObject> logs;

    public DatadogCallout(List<SObject> logs){
        this.logs = logs;
    }

    public void execute(QueueableContext context) {
        System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
        String env = d.getSandboxName() == null ? 'prod' : d.getSandboxName();

        List<GenericLogWrapper> logsWrappers = new List<GenericLogWrapper>();
        for(SObject log : this.logs){
            if(log.getsObjectType() == Log__e.SObjectType){
                logsWrappers.add(new LogWrapper((Log__e)log, env));
            }else if(log.getsObjectType() == API_Log__e.SObjectType){
                logsWrappers.add(new APILogWrapper((API_Log__e)log, env));
            }
        }

        External_System_Method__mdt datadogLogsMethod = [SELECT External_System__r.Endpoint__c, Method__c, Url__c, (SELECT Label, Value__c FROM External_System_Headers__r) FROM External_System_Method__mdt WHERE External_System__r.DeveloperName = 'Datadog' AND DeveloperName = 'Logs'];
        HttpRequest request = new HttpRequest();
        request.setEndpoint(datadogLogsMethod.External_System__r.Endpoint__c + datadogLogsMethod.Url__c);
        request.setMethod(datadogLogsMethod.Method__c);
        for(External_System_Header__mdt header : datadogLogsMethod.External_System_Headers__r){
            request.setHeader(header.Label, header.Value__c);
        }
        request.setBody(JSON.serialize(logsWrappers));

        if(Test.isRunningTest() == false || DatadogCalloutMock.ACTIVATE_TEST == true){
            try{
                Http http = new Http();
                HttpResponse response = http.send(request);

                if(response.getStatusCode() != 202){
                    sendErrorEmail('Bad status code: ' + response.getStatusCode());
                }
            }catch(Exception e){
                sendErrorEmail('Exception message: ' + e.getMessage());
            }
        }
    }

    private static void sendErrorEmail(String message){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address='sellersupport@backmarket.com'];
        if(owea.size() > 0){
            mail.setOrgWideEmailAddressId(owea[0].Id);
        }else{
            mail.setSenderDisplayName('Salesforce Support');
        }

        List<String> toAddresses = new List<String>();
        for(ApexEmailNotification emailNotification : [SELECT User.Email FROM ApexEmailNotification]){
            toAddresses.add(emailNotification.User.Email);
        }
        mail.setToAddresses(toAddresses);
        if(Test.isRunningTest()){
            mail.setToAddresses(new List<String>{UserInfo.getUserEmail()});
        }

        mail.setSubject('Salesforce Error - Send log to Datadog');

        mail.setPlainTextBody(message);

        if(Test.isRunningTest() == false){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    private abstract class GenericLogWrapper{
        public String ddsource;
        public String ddtags;
        public String host;
        public String service;
        public UserWrapper usr;

        public String event_date;
        public String status;
        public String message;
        public String component;

        public GenericLogWrapper(SObject log, String environment){
            this.ddsource = 'salesforce';
            this.ddtags = 'env:' + environment;
            this.host = environment;
            this.service =  'salesforce';
            this.usr = new UserWrapper(log);

            this.event_date = String.valueOf(((DateTime)log.get('CreatedDate')).getTime());
            this.status = (String)log.get('Type__c');
            this.message = '['+ this.status +'] ' + '['+ ((String)log.get('Process__c')).toLowerCase().replace('_', '-') +'] ' + log.get('Message__c');
            this.component = (String)log.get('Component__c');
        }
    }

    private class LogWrapper extends GenericLogWrapper{
        public String records_ids;

        public LogWrapper(Log__e log, String environment){
            super(log, environment);

            this.records_ids = log.Record_Ids__c;
        }
    }

    private class APILogWrapper extends GenericLogWrapper{
        public String body_sent;
        public String body_received;
        public HttpWrapper http;

        public APILogWrapper(API_Log__e log, String environment){
            super(log, environment);

            this.body_received = log.Body_Received__c;
            this.body_sent = log.Body_Sent__c;
            this.http = new HttpWrapper(log);
        }
    }

    private class HttpWrapper{
        public String url;
        public String status_code;
        public String method;

        public HttpWrapper(API_Log__e log){
            this.method = log.Method__c;
            this.status_code = log.Status_Code__c?.format();
            this.url = log.Url_called__c;
        }
    }

    private class UserWrapper{
        public String id;
        public String name;
        public String email;

        public UserWrapper(SObject log){
            this.id = (String)log.get('User_Id__c');
            this.name = (String)log.get('User_Name__c');
            this.email = (String)log.get('User_Email__c');
        }
    }
}