/**
 * @description       : Service handling logs as platform events sent to Datadog
 * @author            : Martin Lezer
 * @group             : Utils
 * @last modified on  : 09-12-2022
 * @last modified by  : Martin Lezer
**/
global class LogService {
    @TestVisible
    private static List<Database.SaveResult> results;
    private List<SObject> logs;
    private String currentClassName;

    public Enum LOG_TYPE{
        INFO,
        WARNING,
        ERROR,
        SUCCESS
    }

    public Enum PROCESS{
        BACK_OFFICE_CALLOUT,
        ACCOUNT_BIZDEV_CHANGED,
        USER_MANAGER_CHANGED
    }

    public LogService(String currentClassName){
        this.logs = new List<SObject>();
        this.currentClassName = currentClassName;
    }

    public void addLog(LOG_TYPE type, PROCESS process, HttpRequest request, HttpResponse response, String message){
        this.logs.add(getLog(type, process, request, response, message, this.currentClassName));
    }

    public void addLog(LOG_TYPE type, PROCESS process, Set<Id> recordIds, String message){
        this.logs.add(getLog(type, process, recordIds, message, this.currentClassName));
    }

    private static API_Log__e getLog(LOG_TYPE type, PROCESS process, HttpRequest request, HttpResponse response, String message, String component){
        API_Log__e logEvent = new API_Log__e();
        logEvent.Body_Sent__c = request.getBody();
        logEvent.Url_called__c = request.getEndpoint();
        logEvent.Method__c = request.getMethod();
        logEvent.Body_Received__c = response?.getBody();
        logEvent.Status_Code__c = response?.getStatusCode();
        logEvent.Message__c = message;
        logEvent.Type__c = String.valueOf(type);
        logEvent.Process__c = String.valueOf(process);
        logEvent.Component__c = component;
        logEvent.User_Id__c = UserInfo.getUserId();
        logEvent.User_Name__c = UserInfo.getName();
        logEvent.User_Email__c = UserInfo.getUserEmail();

        return logEvent;
    }

    private static Log__e getLog(LOG_TYPE type, PROCESS process, Set<Id> recordIds, String message, String component){
        Log__e logEvent = new Log__e();
        logEvent.Message__c = message;
        logEvent.Process__c = String.valueOf(process);

        // taking the first x characters of the record ids because the field has a max length
        Integer recordIdsMaxLength = Schema.SObjectType.Log__e.fields.Record_Ids__c.getLength();
        String recordIdsStr = String.join(new List<Id>(recordIds), ',');
        logEvent.Record_Ids__c = recordIdsStr.length() > recordIdsMaxLength ? recordIdsStr.substring(0, recordIdsMaxLength) : recordIdsStr;

        logEvent.Type__c = String.valueOf(type);
        logEvent.Component__c = component;
        logEvent.User_Id__c = UserInfo.getUserId();
        logEvent.User_Name__c = UserInfo.getName();
        logEvent.User_Email__c = UserInfo.getUserEmail();

        return logEvent;
    }

    public static void log(LOG_TYPE type, PROCESS process, HttpRequest request, HttpResponse response, String message, String component){
        API_Log__e logEvent = getLog(type, process, request, response, message, component);
        
        publishLog(logEvent);
    }

    public static void log(LOG_TYPE type, PROCESS process, Set<Id> recordIds, String message, String component){
        Log__e logEvent = getLog(type, process, recordIds, message, component);
        
        publishLog(logEvent);
    }

    private static void publishLogs(List<SObject> logs){
        // Call method to publish events
        results = EventBus.publish(logs);

        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }       
        }
    }

    private static void publishLog(SObject log){
        publishLogs(new List<SObject>{log});
    }

    public void publishLogs(){
        publishLogs(this.logs);
    }

    /**
     * Method callable from flows to publish logs to Datadog
     */
    @InvocableMethod(label='Publish log' description='Send log to Datadog with specific informations' category='Log')
    public static void log(List<LogWrapper> logs){
        List<Log__e> logsToPublish = new List<Log__e>();

        for(LogWrapper log : logs){
            Log__e logEvent = new Log__e();
            logEvent.Message__c = log.message;
            logEvent.Process__c = log.process;
            logEvent.Record_Ids__c = log.recordId;
            logEvent.Type__c = log.type;
            logEvent.Component__c = log.component;
            logEvent.User_Id__c = UserInfo.getUserId();
            logEvent.User_Name__c = UserInfo.getName();
            logEvent.User_Email__c = UserInfo.getUserEmail();

            logsToPublish.add(logEvent);
        }

        publishLogs(logsToPublish);
    }

    global class LogWrapper{
        @InvocableVariable(label='Custom message' description='Custom message displayed as a title of the log' required=true)
        global String message;

        @InvocableVariable(label='Current business process' description='Current business process inside the flow' required=true)
        global String process;

        @InvocableVariable(label='Current record Id processed in the flow' description='The current record id processed by the flow')
        global String recordId;

        @InvocableVariable(label='Log type (values available: SUCCESS, INFO, WARNING or ERROR)' description='Values available : SUCCESS, INFO, WARNING, ERROR' required=true)
        global String type;

        @InvocableVariable(label='Current flow name' description='The current flow name' required=true)
        global String component;
    }
}