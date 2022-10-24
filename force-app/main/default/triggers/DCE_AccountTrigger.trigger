trigger DCE_AccountTrigger on Account ( before insert, before update, after insert, after update ) {

    DCE_AccountTriggerHandler.handleTrigger( trigger.oldMap, trigger.new, trigger.operationType );
    
}