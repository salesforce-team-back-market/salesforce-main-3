/**
 * @description       : Test for generic trigger handler
 * @author            : Martin Lezer
 * @group             : Tests
 * @last modified on  : 09-06-2022
 * @last modified by  : Martin Lezer
**/
@isTest
private class TriggerHandlerTest {

  private static final String TRIGGER_CONTEXT_ERROR = 'Trigger handler called outside of Trigger execution';

  private static String lastMethodCalled;

  private static TriggerHandlerTest.TestHandler handler;

  static {
    handler = new TriggerHandlerTest.TestHandler();
    // override its internal trigger detection
    handler.isTriggerExecuting = true;
  }

  /***************************************
   * unit tests
   ***************************************/

  // contexts tests

  @isTest
  static void testBeforeInsert() {
    beforeInsertMode();
    handler.run(new List<SObject>(), new Map<Id, SObject>());
    System.assertEquals('beforeInsert', lastMethodCalled, 'last method should be beforeInsert');
  }

  @isTest
  static void testBeforeUpdate() {
    beforeUpdateMode();
    handler.run(new List<SObject>(), new Map<Id, SObject>());
    System.assertEquals('beforeUpdate', lastMethodCalled, 'last method should be beforeUpdate');
  }

  @isTest
  static void testBeforeDelete() {
    beforeDeleteMode();
    handler.run(new List<SObject>(), new Map<Id, SObject>());
    System.assertEquals('beforeDelete', lastMethodCalled, 'last method should be beforeDelete');
  }

  @isTest
  static void testAfterInsert() {
    afterInsertMode();
    handler.run(new List<SObject>(), new Map<Id, SObject>());
    System.assertEquals('afterInsert', lastMethodCalled, 'last method should be afterInsert');
  }

  @isTest
  static void testAfterUpdate() {
    afterUpdateMode();
    handler.run(new List<SObject>(), new Map<Id, SObject>());
    System.assertEquals('afterUpdate', lastMethodCalled, 'last method should be afterUpdate');
  }

  @isTest
  static void testAfterDelete() {
    afterDeleteMode();
    handler.run(new List<SObject>(), new Map<Id, SObject>());
    System.assertEquals('afterDelete', lastMethodCalled, 'last method should be afterDelete');
  }

  @isTest
  static void testAfterUndelete() {
    afterUndeleteMode();
    handler.run(new List<SObject>(), new Map<Id, SObject>());
    System.assertEquals('afterUndelete', lastMethodCalled, 'last method should be afterUndelete');
  }

  @isTest 
  static void testNonTriggerContext() {
    try{
      handler.run(new List<SObject>(), new Map<Id, SObject>());
      System.assert(false, 'the handler ran but should have thrown');
    } catch(TriggerHandler.TriggerHandlerException te) {
      System.assertEquals(TRIGGER_CONTEXT_ERROR, te.getMessage(), 'the exception message should match');
    } catch(Exception e) {
      System.assert(false, 'the exception thrown was not expected: ' + e.getTypeName() + ': ' + e.getMessage());
    }
  }

  // test bypass api

  @isTest
  static void testBypassAPI() {
    afterUpdateMode();

    // test a bypass and run handler
    TriggerHandler.bypass('TestHandler');
    handler.run(new List<SObject>(), new Map<Id, SObject>());
    System.assertEquals(null, lastMethodCalled, 'last method should be null when bypassed');
    System.assertEquals(true, TriggerHandler.isBypassed('TestHandler'), 'test handler should be bypassed');
    resetTest();

    // clear that bypass and run handler
    TriggerHandler.clearBypass('TestHandler');
    handler.run(new List<SObject>(), new Map<Id, SObject>());
    System.assertEquals('afterUpdate', lastMethodCalled, 'last method called should be afterUpdate');
    System.assertEquals(false, TriggerHandler.isBypassed('TestHandler'), 'test handler should be bypassed');
    resetTest();

    // test a re-bypass and run handler
    TriggerHandler.bypass('TestHandler');
    handler.run(new List<SObject>(), new Map<Id, SObject>());
    System.assertEquals(null, lastMethodCalled, 'last method should be null when bypassed');
    System.assertEquals(true, TriggerHandler.isBypassed('TestHandler'), 'test handler should be bypassed');
    resetTest();

    // clear all bypasses and run handler
    TriggerHandler.clearAllBypasses();
    handler.run(new List<SObject>(), new Map<Id, SObject>());
    System.assertEquals('afterUpdate', lastMethodCalled, 'last method called should be afterUpdate');
    System.assertEquals(false, TriggerHandler.isBypassed('TestHandler'), 'test handler should be bypassed');
    resetTest();
  }

  // instance method tests

  @isTest
  static void testLoopCount() {
    beforeInsertMode();
    
    // set the max loops to 2
    handler.setMaxLoopCount(2);

    // run the handler twice
    handler.run(new List<SObject>(), new Map<Id, SObject>());
    handler.run(new List<SObject>(), new Map<Id, SObject>());

    // clear the tests
    resetTest();

    try {
      // try running it. This should exceed the limit.
      handler.run(new List<SObject>(), new Map<Id, SObject>());
      System.assert(false, 'the handler should throw on the 3rd run when maxloopcount is 3');
    } catch(TriggerHandler.TriggerHandlerException te) {
      // we're expecting to get here
      System.assertEquals(null, lastMethodCalled, 'last method should be null');
    } catch(Exception e) {  
      System.assert(false, 'the exception thrown was not expected: ' + e.getTypeName() + ': ' + e.getMessage());
    }

    // clear the tests
    resetTest();

    // now clear the loop count
    handler.clearMaxLoopCount();

    try {
      // re-run the handler. We shouldn't throw now.
      handler.run(new List<SObject>(), new Map<Id, SObject>());
      System.assertEquals('beforeInsert', lastMethodCalled, 'last method should be beforeInsert');
    } catch(TriggerHandler.TriggerHandlerException te) {
      System.assert(false, 'running the handler after clearing the loop count should not throw');
    } catch(Exception e) {  
      System.assert(false, 'the exception thrown was not expected: ' + e.getTypeName() + ': ' + e.getMessage());
    }
  }

  @isTest
  static void testLoopCountClass() {
    TriggerHandler.LoopCount lc = new TriggerHandler.LoopCount();
    System.assertEquals(5, lc.getMax(), 'max should be five on init');
    System.assertEquals(0, lc.getCount(), 'count should be zero on init');

    lc.increment();
    System.assertEquals(1, lc.getCount(), 'count should be 1');
    System.assertEquals(false, lc.exceeded(), 'should not be exceeded with count of 1');

    lc.increment();
    lc.increment();
    lc.increment();
    lc.increment();
    System.assertEquals(5, lc.getCount(), 'count should be 5');
    System.assertEquals(false, lc.exceeded(), 'should not be exceeded with count of 5');

    lc.increment();
    System.assertEquals(6, lc.getCount(), 'count should be 6');
    System.assertEquals(true, lc.exceeded(), 'should not be exceeded with count of 6');
  }

  // private method tests

  @isTest 
  static void testGetHandlerName() {
    System.assertEquals('TestHandler', handler.getHandlerName(), 'handler name should match class name');
  }

  // test virtual methods
  
  @isTest
  static void testVirtualMethods() {
    TriggerHandler h = new TriggerHandler();
    h.beforeInsert(new List<SObject>());
    h.beforeUpdate(new List<SObject>(), new Map<Id, SObject>(), new List<SObject>(), new Map<Id, SObject>());
    h.beforeDelete(new List<SObject>(), new Map<Id, SObject>());
    h.afterInsert(new List<SObject>(), new Map<Id, SObject>());
    h.afterUpdate(new List<SObject>(), new Map<Id, SObject>(), new List<SObject>(), new Map<Id, SObject>());
    h.afterDelete(new List<SObject>(), new Map<Id, SObject>());
    h.afterUndelete(new List<SObject>(), new Map<Id, SObject>());
  }

  /***************************************
   * testing utilities
   ***************************************/

  private static void resetTest() {
    lastMethodCalled = null;
  }

  // modes for testing

  private static void beforeInsertMode() {
    handler.setTriggerContext('before insert', true);
  }

  private static void beforeUpdateMode() {
    handler.setTriggerContext('before update', true);
  }

  private static void beforeDeleteMode() {
    handler.setTriggerContext('before delete', true);
  }

  private static void afterInsertMode() {
    handler.setTriggerContext('after insert', true);
  }

  private static void afterUpdateMode() {
    handler.setTriggerContext('after update', true);
  }

  private static void afterDeleteMode() {
    handler.setTriggerContext('after delete', true);
  }

  private static void afterUndeleteMode() {
    handler.setTriggerContext('after undelete', true);
  }

  // test implementation of the TriggerHandler

  private class TestHandler extends TriggerHandler {

    public override void beforeInsert(List<SObject> triggerNew) {
      TriggerHandlerTest.lastMethodCalled = 'beforeInsert';
    }

    public override void  beforeUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap, List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {
      TriggerHandlerTest.lastMethodCalled = 'beforeUpdate';
    }

    public override void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {
      TriggerHandlerTest.lastMethodCalled = 'beforeDelete';
    }

    public override void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
      TriggerHandlerTest.lastMethodCalled = 'afterInsert';
    }

    public override void afterUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap, List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {
      TriggerHandlerTest.lastMethodCalled = 'afterUpdate';
    }

    public override void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {
      TriggerHandlerTest.lastMethodCalled = 'afterDelete';
    }

    public override void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
      TriggerHandlerTest.lastMethodCalled = 'afterUndelete';
    }

  }
	
}