/**
 * @description       : Trigger on User
 * @author            : Martin Lezer
 * @group             : Triggers
 * @last modified on  : 09-06-2022
 * @last modified by  : Martin Lezer
**/
trigger UserTrigger on User (After update) {
    new UserTriggerHandler().run(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
}