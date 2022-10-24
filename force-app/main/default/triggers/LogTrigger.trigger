/**
 * @description       : Trigger on Log
 * @author            : Martin Lezer
 * @group             : Triggers
 * @last modified on  : 09-08-2022
 * @last modified by  : Martin Lezer
**/
trigger LogTrigger on Log__e (after insert) {
    new LogTriggerHandler().run(Trigger.new, Trigger.newMap);
}