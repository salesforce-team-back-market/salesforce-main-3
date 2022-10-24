/**
 * @description       : Trigger on Account
 * @author            : Martin Lezer
 * @group             : Triggers
 * @last modified on  : 09-06-2022
 * @last modified by  : Martin Lezer
**/
trigger AccountTrigger on Account (before update, after update) {
    new AccountTriggerHandler().run(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
}