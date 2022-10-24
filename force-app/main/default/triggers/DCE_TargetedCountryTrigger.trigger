trigger DCE_TargetedCountryTrigger on Targeted_Country__c (before insert, before update, after insert, after update) {
    
    DCE_TargetedCountryTriggerHandler.handleTrigger( trigger.oldMap, trigger.new, trigger.operationType );
    
}