trigger DCE_ContactTrigger on Contact ( after insert, after update ) {

    DCE_ContactTriggerHandler.handleTrigger( trigger.oldMap, trigger.new, trigger.operationType );
    
}