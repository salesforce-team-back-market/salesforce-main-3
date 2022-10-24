/**
 * @description       : Account trigger handler tests
 * @author            : Martin Lezer
 * @group             : Tests
 * @last modified on  : 09-06-2022
 * @last modified by  : Martin Lezer
**/
@IsTest public class AccountTriggerHandlerTest {
    private static final Integer NB_ACCOUNTS = 2;

    @IsTest
    static void testBizDevChange(){
        TestFactory factory = new TestFactory();
        factory.insertAccounts(NB_ACCOUNTS)
                .insertAlertsBulk()
                .insertCasesBulk()
                .insertCountriesBulk()
                .insertMSPProcessesBulk()
                .insertMysteryOrdersBulk()
                .insertOnboardingProcessesBulk()
                .insertNMOProcessesBulk();
        User u = factory.getUser();
        insert u;

        Account[] accs = [SELECT Id FROM Account];

        Test.startTest();
        factory.updateBulk(TestFactory.RECORD_TYPE.Onboarding, 'Stage__c', 'Ongoing');

        for(Account acc : accs){
            acc.OwnerId = u.Id;
        }
        update accs;
        Test.stopTest();

        // check accounts
        Formula.recalculateFormulas(new List<User>{u});
        Set<String> recipientEmailSales = new Set<String>();
        for(Account acc : [SELECT Recipient_email_sales__c, Manager_Sales__c FROM Account WHERE Id IN :accs]){
            recipientEmailSales.add(acc.Recipient_email_sales__c);

            System.assertNotEquals(null, acc.Manager_Sales__c, 'Wrong manager related to account');
            System.assertEquals(u.ManagerId, acc.Manager_Sales__c, 'Wrong manager related to account');
            System.assertNotEquals(null, acc.Recipient_email_sales__c, 'Wrong recipient email related to account');
            System.assertEquals(u.Team_Email__c, acc.Recipient_email_sales__c, 'Wrong recipient email related to account');
        }

        // check related records
        System.assertEquals(TestFactory.LOAD_TEST_NUMBER * NB_ACCOUNTS, [SELECT Id FROM Alert__c WHERE BizDev__c = :u.Id].size(), 'Alerts bizdev was not updated.');
        System.assertEquals(TestFactory.LOAD_TEST_NUMBER * NB_ACCOUNTS, [SELECT Id FROM Onboarding_Process__c WHERE Merchant_BizDev__c = :u.Id].size(), 'Onboardings bizdev was not updated.');
        System.assertEquals(TestFactory.LOAD_TEST_NUMBER * NB_ACCOUNTS, [SELECT Id FROM NMO_Process__c WHERE BizDevApproval__c = :u.Id].size(), 'NMO processes bizdev was not updated.');
        System.assertEquals(TestFactory.LOAD_TEST_NUMBER * NB_ACCOUNTS, [SELECT Id FROM Merchant_Special_Process__c WHERE BizDev_for_Approval__c = :u.Id].size(), 'Merchant Special processes bizdev was not updated.');
        System.assertEquals(TestFactory.LOAD_TEST_NUMBER * NB_ACCOUNTS, [SELECT Id FROM Case WHERE Merchant_BizDev__c = :u.Id].size(), 'Cases bizdev was not updated.');
        System.assertEquals(TestFactory.LOAD_TEST_NUMBER * NB_ACCOUNTS, [SELECT Id FROM Mystery_Order__c WHERE Current_BizDev__c = :u.Id].size(), 'Mystery orders bizdev was not updated.');
        System.assertEquals([SELECT Id FROM Targeted_Country__c].size(), [SELECT Id FROM Targeted_Country__c WHERE Recipient_email_sales__c IN :recipientEmailSales].size(), 'Targeted countries recipient email sales was not updated.');
    }

    @IsTest
    static void testBizDevBuybackChange(){
        TestFactory factory = new TestFactory(true);
        factory.insertAccounts(NB_ACCOUNTS)
                .insertAlertsBulk()
                .insertCasesBulk()
                .insertCountriesBulk()
                .insertMSPProcessesBulk()
                .insertMysteryOrdersBulk()
                .insertOnboardingProcessesBulk()
                .insertNMOProcessesBulk();
        User u = factory.getUser();
        insert u;

        Account[] accs = [SELECT Id FROM Account];

        Test.startTest();
        factory.updateBulk(TestFactory.RECORD_TYPE.Onboarding, 'Stage__c', 'Business & Quality Prerequisites');
        factory.updateBulk(TestFactory.RECORD_TYPE.Alert, 'Stage__c', 'Monitoring Period');

        for(Account acc : accs){
            acc.OwnerId = u.Id;
        }
        update accs;
        Test.stopTest();

        // check accounts
        Formula.recalculateFormulas(new List<User>{u});
        for(Account acc : [SELECT Recipient_email_buyback__c, Manager_Buyback__c FROM Account WHERE Id IN :accs]){
            System.assertNotEquals(null, acc.Manager_Buyback__c, 'Wrong manager related to account');
            System.assertEquals(u.ManagerId, acc.Manager_Buyback__c, 'Wrong manager related to account');
            System.assertNotEquals(null, acc.Recipient_email_buyback__c, 'Wrong recipient email related to account');
            System.assertEquals(u.Team_Email__c, acc.Recipient_email_buyback__c, 'Wrong recipient email related to account');
        }

        // check related records
        System.assertEquals(TestFactory.LOAD_TEST_NUMBER * NB_ACCOUNTS, [SELECT Id FROM Alert__c WHERE BizDev_Buyback__c = :u.Id].size(), 'Alerts bizdev buyback was not updated.');
        System.assertEquals(TestFactory.LOAD_TEST_NUMBER * NB_ACCOUNTS, [SELECT Id FROM Onboarding_Process__c WHERE Merchant_BizDev__c = :u.Id].size(), 'Onboardings bizdev buyback was not updated.');
        System.assertEquals(TestFactory.LOAD_TEST_NUMBER * NB_ACCOUNTS, [SELECT Id FROM Merchant_Special_Process__c WHERE BizDev_for_Approval__c = :u.Id].size(), 'Merchant Special processes bizdev buyback was not updated.');
        System.assertEquals(TestFactory.LOAD_TEST_NUMBER * NB_ACCOUNTS, [SELECT Id FROM Case WHERE Merchant_BizDev__c = :u.Id].size(), 'Cases bizdev buyback was not updated.');
    }
}