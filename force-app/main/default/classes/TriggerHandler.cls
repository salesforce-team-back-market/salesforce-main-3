/**
 * @description       : Generic trigger handler : have to be extended by each trigger handler
 * @author            : Martin Lezer
 * @group             : TriggerHandler
 * @last modified on  : 11-09-2022
 * @last modified by  : Martin Lezer
**/
public virtual class TriggerHandler {

    // static map of handlername, times run() was invoked
    private static Map<String, LoopCount> loopCountMap;
    private static Set<String> bypassedHandlers;
  
    // the current context of the trigger, overridable in tests
    @TestVisible
    private TriggerContext context;
  
    // the current context of the trigger, overridable in tests
    @TestVisible
    private Boolean isTriggerExecuting;
  
    // static initialization
    static {
      loopCountMap = new Map<String, LoopCount>();
      bypassedHandlers = new Set<String>();
    }
    
    // constructor
    public TriggerHandler() {
      this.setTriggerContext();
    }
  
    /***************************************
     * public instance methods
     ***************************************/
  
    // main method that will be called during execution
    public void run(List<SObject> triggerNewOrOld, Map<Id, SObject> triggerNewOrOldMap, List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {
  
      if(!validateRun()) {
        return;
      }
  
      addToLoopCount();
  
      // dispatch to the correct handler method
      switch on this.context {
        when BEFORE_INSERT {
          this.beforeInsert(triggerNewOrOld);
        }
        when BEFORE_UPDATE {
          this.beforeUpdate(triggerNewOrOld, triggerNewOrOldMap, triggerOld, triggerOldMap);
        }
        when BEFORE_DELETE {
          this.beforeDelete(triggerOld ,triggerOldMap);
        }
        when AFTER_INSERT {
          this.afterInsert(triggerNewOrOld ,triggerNewOrOldMap);
        }
        when AFTER_UPDATE {
          this.afterUpdate(triggerNewOrOld ,triggerNewOrOldMap, triggerOld, triggerOldMap);
        }
        when AFTER_DELETE {
          this.afterDelete(triggerOld ,triggerOldMap);
        }
        when AFTER_UNDELETE {
          this.afterUndelete(triggerNewOrOld ,triggerNewOrOldMap);
        }
      }
    }
    public void run(List<SObject> sobjectList, Map<Id, SObject> sobjectMap) {
        this.run(sobjectList, sobjectMap, null, null);
    }
  
    public void setMaxLoopCount(Integer max) {
      String handlerName = getHandlerName();
      if(!TriggerHandler.loopCountMap.containsKey(handlerName)) {
        TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
      } else {
        TriggerHandler.loopCountMap.get(handlerName).setMax(max);
      }
    }
  
    public void clearMaxLoopCount() {
      this.setMaxLoopCount(-1);
    }
  
    /***************************************
     * public static methods
     ***************************************/
  
    public static void bypass(String handlerName) {
      TriggerHandler.bypassedHandlers.add(handlerName);
    }
  
    public static void clearBypass(String handlerName) {
      TriggerHandler.bypassedHandlers.remove(handlerName);
    }
  
    public static Boolean isBypassed(String handlerName) {
      return TriggerHandler.bypassedHandlers.contains(handlerName);
    }
  
    public static void clearAllBypasses() {
      TriggerHandler.bypassedHandlers.clear();
    }
  
    /***************************************
     * private instancemethods
     ***************************************/
  
    @TestVisible
    private void setTriggerContext() {
      this.setTriggerContext(null, false);
    }
  
    @TestVisible
    private void setTriggerContext(String ctx, Boolean testMode) {
      if(!Trigger.isExecuting && !testMode) {
        this.isTriggerExecuting = false;
        return;
      } else {
        this.isTriggerExecuting = true;
      }
      
      if((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
          (ctx != null && ctx == 'before insert')) {
        this.context = TriggerContext.BEFORE_INSERT;
      } else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
          (ctx != null && ctx == 'before update')){
        this.context = TriggerContext.BEFORE_UPDATE;
      } else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
          (ctx != null && ctx == 'before delete')) {
        this.context = TriggerContext.BEFORE_DELETE;
      } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
          (ctx != null && ctx == 'after insert')) {
        this.context = TriggerContext.AFTER_INSERT;
      } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
          (ctx != null && ctx == 'after update')) {
        this.context = TriggerContext.AFTER_UPDATE;
      } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
          (ctx != null && ctx == 'after delete')) {
        this.context = TriggerContext.AFTER_DELETE;
      } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
          (ctx != null && ctx == 'after undelete')) {
        this.context = TriggerContext.AFTER_UNDELETE;
      }
    }
  
    // increment the loop count
    @TestVisible
    private void addToLoopCount() {
      String handlerName = getHandlerName();
      if(TriggerHandler.loopCountMap.containsKey(handlerName)) {
        Boolean exceeded = TriggerHandler.loopCountMap.get(handlerName).increment();
        if(exceeded) {
          Integer max = TriggerHandler.loopCountMap.get(handlerName).max;
          throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
        }
      }
    }
  
    // make sure this trigger should continue to run
    @TestVisible
    private Boolean validateRun() {
      User currentUser = [SELECT ByPassTriggerHandler__c FROM User WHERE Id = :UserInfo.getUserId()];

      if(!this.isTriggerExecuting || this.context == null) {
        throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
      }

      String currentHandlerName = getHandlerName();
      return !TriggerHandler.bypassedHandlers.contains(currentHandlerName) && (currentUser.ByPassTriggerHandler__c == null ? true : !currentUser.ByPassTriggerHandler__c.contains(currentHandlerName));
    }
  
    @TestVisible
    private String getHandlerName() {
      return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    }
  
    /***************************************
     * context methods
     ***************************************/
  
    // context-specific methods for override
    @TestVisible
    protected virtual void beforeInsert(List<SObject> triggerNew){}
    @TestVisible
    protected virtual void beforeUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap, List<SObject> triggerOld, Map<Id, SObject> triggerOldMap){}
    @TestVisible
    protected virtual void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap){}
    @TestVisible
    protected virtual void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap){}
    @TestVisible
    protected virtual void afterUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap, List<SObject> triggerOld, Map<Id, SObject> triggerOldMap){}
    @TestVisible
    protected virtual void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap){}
    @TestVisible
    protected virtual void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap){}
  
    /***************************************
     * inner classes
     ***************************************/
  
    // inner class for managing the loop count per handler
    @TestVisible
    private class LoopCount {
      private Integer max;
      private Integer count;
  
      public LoopCount() {
        this.max = 5;
        this.count = 0;
      }
  
      public LoopCount(Integer max) {
        this.max = max;
        this.count = 0;
      }
  
      public Boolean increment() {
        this.count++;
        return this.exceeded();
      }
  
      public Boolean exceeded() {
        return this.max >= 0 && this.count > this.max;
      }
  
      public Integer getMax() {
        return this.max;
      }
  
      public Integer getCount() {
        return this.count;
      }
  
      public void setMax(Integer max) {
        this.max = max;
      }
    }
  
    // possible trigger contexts
    @TestVisible
    private enum TriggerContext {
      BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
      AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
      AFTER_UNDELETE
    }
  
    // exception class
    public class TriggerHandlerException extends Exception {}
  
  }