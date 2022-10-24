/**
 * @description       : User trigger handler tests
 * @author            : Martin Lezer
 * @group             : Tests
 * @last modified on  : 09-06-2022
 * @last modified by  : Martin Lezer
**/
@IsTest public class UserTriggerHandlerTest {
    private static final Integer NB_ACCOUNTS = 2;

    @IsTest
    static void testManagerChange(){
        TestFactory factory = new TestFactory();
        factory.insertAccounts(NB_ACCOUNTS)
                .insertAlertsBulk()
                .insertCasesBulk()
                .insertCountriesBulk()
                .insertMSPProcessesBulk()
                .insertMysteryOrdersBulk()
                .insertOnboardingProcessesBulk()
                .insertNMOProcessesBulk();
        User manager = factory.getUser();
        insert manager;
        manager.ManagerId = null;
        update manager;

        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        Test.startTest();
        currentUser.ManagerId = manager.Id;
        update currentUser;
        Test.stopTest();

        for(Account acc : [SELECT Manager_Sales__c FROM Account]){
            System.assertEquals(manager.Id, acc.Manager_Sales__c, 'Wrong manager related to account');
        }
    }

    @IsTest
    static void testManagerChangeWithBuybackRecords(){
        TestFactory factory = new TestFactory(true);
        factory.insertAccounts(NB_ACCOUNTS)
                .insertAlertsBulk()
                .insertCasesBulk()
                .insertCountriesBulk()
                .insertMSPProcessesBulk()
                .insertMysteryOrdersBulk()
                .insertOnboardingProcessesBulk()
                .insertNMOProcessesBulk();
        User manager = factory.getUser();
        insert manager;
        manager.ManagerId = null;
        update manager;

        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        Test.startTest();
        currentUser.ManagerId = manager.Id;
        update currentUser;
        Test.stopTest();

        for(Account acc : [SELECT Manager_Buyback__c FROM Account]){
            System.assertEquals(manager.Id, acc.Manager_Buyback__c, 'Wrong manager related to account');
        }
    }
}