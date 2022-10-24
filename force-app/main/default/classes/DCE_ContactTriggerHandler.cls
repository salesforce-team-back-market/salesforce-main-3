/********************************************************************************
 * Creation : Rémy VULTAGGIO - 22/05/2019
 * Modifications :
 * Tests : DCE_TriggersTest
 * 
 * Class allowing to handle every required operation needed in the Contact APEX 
 * Trigger.
 * 
 * Purpose : This class aim is to lighten the Contact APEX Trigger by providing it
 * a set of operations needed so the logic is outside of the Trigger and only one
 * of it is necessary.
 ********************************************************************************/
public with sharing class DCE_ContactTriggerHandler {
    
    
    /**
     * Public Methods
     **/
    
    public static void handleTrigger ( Map < ID, Contact > oldContactsMap, List < Contact > newContactsList, System.TriggerOperation triggerEvent ) {
        Boolean byPassBo = [Select ByPass_BO_Callout__c  From User Where Id = :UserInfo.getUserId()][0].ByPass_BO_Callout__c ;
        switch on triggerEvent {
            when AFTER_INSERT, AFTER_UPDATE {
                String operationType = ( triggerEvent.name().contains( 'INSERT' ) 
                                         ? 'Create'
                                         : 'Update' );
                if(byPassBo!=true) DCE_BackOfficeCallouts.doBackOfficeSync ( 'Contact', operationType, oldContactsMap, newContactsList );
            }
            when else {
                // NOTHING TO DO
            }
        }
    }
    
}