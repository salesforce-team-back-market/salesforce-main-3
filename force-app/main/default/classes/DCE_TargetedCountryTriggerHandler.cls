/********************************************************************************
 * Creation : Rémy VULTAGGIO - 17/04/2019
 * Modifications :
 * Tests : DCE_TriggersTest
 * 
 * Class allowing to handle every required operation needed in the Targeted 
 * Country APEX Trigger.
 * 
 * Purpose : This class aim is to lighten the Targeted Country APEX Trigger by 
 * providing it a set of operations needed so the logic is outside of the Trigger 
 * and only one of it is necessary.
 ********************************************************************************/
public with sharing class DCE_TargetedCountryTriggerHandler {   
    /**
     * Public Methods
     **/   
    public static void handleTrigger ( Map < ID, Targeted_Country__c > oldTargetedCountriesMap, List < Targeted_Country__c > newTargetedCountriesList, System.TriggerOperation triggerEvent ) {
        Boolean byPassBo = [Select ByPass_BO_Callout__c  From User Where Id = :UserInfo.getUserId()][0].ByPass_BO_Callout__c ;
        switch on triggerEvent {        
            when BEFORE_INSERT {
                doUpdateRT(newTargetedCountriesList );
            }
            when AFTER_INSERT, AFTER_UPDATE {
                String operationType = ( triggerEvent.name().contains( 'INSERT' ) 
                                         ? 'Create'
                                         : 'Update' );
                if(byPassBo!=true) DCE_BackOfficeCallouts.doBackOfficeSync ( 'Targeted_Country__c', operationType, oldTargetedCountriesMap, newTargetedCountriesList );
            }
            when else {
                // NOTHING TO DO
            }
        }
    }
    
    private static void doUpdateRT(List < Targeted_Country__c > newTargetedCountriesList){
    
       for(Targeted_country__c t:newTargetedCountriesList){
            t.recordtypeId = ManageRecordtype.ManageRecordtype(t.MerchantRT__c,'Targeted_Country__c');
        }
    }
}