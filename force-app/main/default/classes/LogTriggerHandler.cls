/**
 * @description       : 
 * @author            : Martin Lezer
 * @group             : 
 * @last modified on  : 09-08-2022
 * @last modified by  : Martin Lezer
**/
public class LogTriggerHandler extends TriggerHandler {
    public override void afterInsert(List<SObject> newLogs, Map<Id, SObject> newLogsMap) {
        System.enqueueJob(new DatadogCallout(newLogs));
    }
}