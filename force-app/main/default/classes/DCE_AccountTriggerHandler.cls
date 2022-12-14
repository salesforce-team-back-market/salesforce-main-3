/********************************************************************************
 * Creation : Rémy VULTAGGIO - 01/04/2019
 * Modifications :
 * Tests : DCE_TriggersTest
 * 
 * Class allowing to handle every required operation needed in the Account APEX 
 * Trigger.
 * 
 * Purpose : This class aim is to lighten the Account APEX Trigger by providing it
 * a set of operations needed so the logic is outside of the Trigger and only one
 * of it is necessary.
 ********************************************************************************/
public with sharing class DCE_AccountTriggerHandler {
    /**
     * Public Methods
     **/    
    public static void handleTrigger ( Map < ID, Account > oldAccountsMap, List < Account > newAccountsList, System.TriggerOperation triggerEvent ) {
        Boolean byPassBo = [Select ByPass_BO_Callout__c  From User Where Id = :UserInfo.getUserId()][0].ByPass_BO_Callout__c ;
        switch on triggerEvent {
            when AFTER_INSERT, AFTER_UPDATE {
                String operationType = ( triggerEvent.name().contains( 'INSERT' ) 
                                         ? 'Create'
                                         : 'Update' );
                if(byPassBo!=true)  DCE_BackOfficeCallouts.doBackOfficeSync ( 'Account', operationType, oldAccountsMap, newAccountsList );
            }
            when else {
                // NOTHING TO DO
            }
        }
    }    
}