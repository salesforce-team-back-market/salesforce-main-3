/********************************************************************************
 * Création : Rémy VULTAGGIO - 07/05/2019
 * Modif :
 *
 * Class allowing to test API REST callouts to the Back-Office.
 *
 * Purpose :
 * Cover at least 75% of the code from the classes DCE_<???>Trigger[Handler].
 ********************************************************************************/
@IsTest
private without sharing class DCE_TriggersTest {
    /**
     * Init data methods
     **/
    @testSetup
    private static void init() {
        DCE_CalloutsMock calloutsMock = new DCE_CalloutsMock();
        calloutsMock.needTest = false;

        Test.setMock(HttpCalloutMock.class, calloutsMock);

        TestFactory factory = new TestFactory();
        factory.setCustomSettings();

        Account acc = factory.getAccountFR('Merchant');
        acc.Back_Office_PK__c = 99999;
        acc.inputted_from__c = 'Back-Office';
        insert acc;

        Contact con = factory.getContact(acc.Id, 'Test', 'Test');
        con.Merchant_ID__c = '99999';
        insert con;

        insert new Targeted_Country__c(
            Merchant__c = acc.Id,
            Country__c='France',
            Online_Status__c = 'Selected',
            back_care__c = true
        );

        insert new EU_Back_Office_Settings__c(
            backoffice_url__c = 'test.backmarket.com',
            username__c = 'test_username',
            password__c = 'test_password'
        );
        insert new US_Back_Office_Settings__c(
            backoffice_url__c = 'testus.backmarket.com',
            username__c = 'test_username',
            password__c = 'test_password'
        );
    }

    /**
     * Tests methods
     **/
    @IsTest
    private static void testdoBackOfficeSyncAccount(){
        String accountName = 'Merchant';
        Set<String> accountfieldNames = Account.sObjectType.getDescribe().fields.getMap().keySet();

        Account account = Database.query('select ' + string.join((Iterable<String>)accountfieldNames, ',') + ' from Account where Name =:accountName');
        Account newAccount = Database.query('select ' + string.join((Iterable<String>)accountfieldNames, ',') + ' from Account where Name =:accountName');

        newAccount.trading_name__c = 'recommerce';
        newAccount.company_id_num__c = 'company';
        newAccount.story__c = '2';
        newAccount.commission__c = 8;
        newAccount.monthly_fees__c = 11;
        newAccount.buyback_stage__c = 'Live';
        newAccount.iban__c = 'iban-xxxx';
        newAccount.bic__c = 'bic-xxxx';
        newAccount.billingstreet = 'rue street';
        newAccount.klarna__c = 'Offline';
        newAccount.buyback_limitation__c = 10;
        newAccount.sales_limitation__c = 10;

        Map<ID, SObject> oldSObjectsMap = new Map<ID, SObject>{
            account.Id => account
        };

        List <Account> newSObjectsList = new List <Account>();
        newSObjectsList.add(newAccount);

        DCE_CalloutsMock calloutsMock = new DCE_CalloutsMock();
        calloutsMock.calloutType = DCE_CalloutsMock.DCE_CalloutType.BACKOFFICE_MERCHANT_UPDATE;

        Test.setMock(HttpCalloutMock.class, calloutsMock);
        Test.startTest();

        DCE_BackOfficeCallouts.doBackOfficeSync('Account', 'Update', oldSObjectsMap, newSObjectsList);

        Test.stopTest();
    }

    @IsTest
    private static void testdoBackOfficeSyncAccountInsert(){
        Account newAccount = new TestFactory().getAccountUS('MerchantUS');
        newAccount.Back_Office_PK__c = 99998;
        newAccount.inputted_from__c = 'Back-Office';

        DCE_CalloutsMock calloutsMock = new DCE_CalloutsMock();
        calloutsMock.calloutType = DCE_CalloutsMock.DCE_CalloutType.BACKOFFICE_MERCHANT_INSERT;

        Test.setMock(HttpCalloutMock.class, calloutsMock);
        
        Test.startTest();
        insert newAccount;
        Test.stopTest();
    }

    @IsTest
    private static void testdoBackOfficeSyncAccountInsertError(){
        Account newAccount = new TestFactory().getAccountUS('MerchantUS');
        newAccount.Back_Office_PK__c = 99998;
        newAccount.inputted_from__c = 'Back-Office';

        DCE_CalloutsMock calloutsMock = new DCE_CalloutsMock();
        calloutsMock.calloutType = DCE_CalloutsMock.DCE_CalloutType.BACKOFFICE_ERROR;

        Test.setMock(HttpCalloutMock.class, calloutsMock);
        
        Test.startTest();
        insert newAccount;

        Test.getEventBus().deliver(); 
        Test.stopTest();

        System.assertEquals(1, LogService.results.size());
        for(Database.SaveResult result : LogService.results){
            System.assertEquals(true, result.isSuccess());
        }
    }

    @IsTest
    private static void testdoBackOfficeSyncAccountInsertException(){
        Account newAccount = new TestFactory().getAccountUS('MerchantUS');
        newAccount.Back_Office_PK__c = 99998;
        newAccount.inputted_from__c = 'Back-Office';

        DCE_CalloutsMock calloutsMock = new DCE_CalloutsMock();
        calloutsMock.calloutType = DCE_CalloutsMock.DCE_CalloutType.BACKOFFICE_EXCEPTION;

        Test.setMock(HttpCalloutMock.class, calloutsMock);
        
        Test.startTest();
        insert newAccount;

        Test.getEventBus().deliver(); 
        Test.stopTest();

        System.assertEquals(1, LogService.results.size());
        for(Database.SaveResult result : LogService.results){
            System.assertEquals(true, result.isSuccess());
        }
    }


    @IsTest
    private static void testdoBackOfficeSyncAccountInsertHighVolume(){
        List<Account> accountsToInsert =  new List<Account>();
        for(Integer i = 0; i < TestFactory.LOAD_TEST_NUMBER; i++){
            Account newAccount = new TestFactory().getAccountUS('MerchantUS'+i);
            newAccount.Back_Office_PK__c = 99998;
            newAccount.inputted_from__c = 'Back-Office';

            accountsToInsert.add(newAccount);
        }

        DCE_CalloutsMock calloutsMock = new DCE_CalloutsMock();
        calloutsMock.calloutType = DCE_CalloutsMock.DCE_CalloutType.BACKOFFICE_MERCHANT_INSERT;

        Test.setMock(HttpCalloutMock.class, calloutsMock);
        
        Test.startTest();
        insert accountsToInsert;
        Test.stopTest();
    }

    @IsTest
    private static void testdoBackOfficeSyncTargetCountry(){
        Set<String> targetCountryFieldNames = Targeted_Country__c.sObjectType.getDescribe().fields.getMap().keySet();

        Targeted_Country__c targetCountry = Database.query('select ' + string.join((Iterable<String>)targetCountryFieldNames, ',') + ' from Targeted_Country__c limit 1');
        Targeted_Country__c newTargetCountry = Database.query('select ' + string.join((Iterable<String>)targetCountryFieldNames, ',') + ' from Targeted_Country__c limit 1');

        System.debug('Country__c ' + targetCountry.Country__c);
        System.debug('Merchant__c ' + targetCountry.Merchant__c);
        System.debug('Online_Status__c ' + targetCountry.Online_Status__c);
        
        newTargetCountry.online_status__c = 'Live';
        newTargetCountry.shipping_from__c = 'France';
        newTargetCountry.back_care__c = false;

        Map<ID, SObject> oldSObjectsMap = new Map<ID, SObject>{
            targetCountry.Id => targetCountry
        };

        List <Targeted_Country__c> newSObjectsList = new List <Targeted_Country__c>();
        newSObjectsList.add(newTargetCountry);

        DCE_CalloutsMock calloutsMock = new DCE_CalloutsMock();
        calloutsMock.calloutType = DCE_CalloutsMock.DCE_CalloutType.BACKOFFICE_TARGETEDCOUNTRY_UPDATE;

        Test.setMock(HttpCalloutMock.class, calloutsMock);
        Test.startTest();

        DCE_BackOfficeCallouts.doBackOfficeSync('Targeted_Country__c', 'Update', oldSObjectsMap, newSObjectsList);

        Test.stopTest();
    }

    @IsTest
    private static void testdoBackOfficeSyncContact(){
        Set<String> contactFieldNames = Contact.sObjectType.getDescribe().fields.getMap().keySet();

        Contact con = Database.query('select ' + string.join((Iterable<String>)contactFieldNames, ',') + ' from Contact limit 1');
        Contact newContact = Database.query('select ' + string.join((Iterable<String>)contactFieldNames, ',') + ' from Contact limit 1');
        
        newContact.MobilePhone = 'Test';

        Map<ID, SObject> oldSObjectsMap = new Map<ID, SObject>{
            con.Id => con
        };

        List <Contact> newSObjectsList = new List <Contact>();
        newSObjectsList.add(newContact);

        DCE_CalloutsMock calloutsMock = new DCE_CalloutsMock();
        calloutsMock.calloutType = DCE_CalloutsMock.DCE_CalloutType.BACKOFFICE_CONTACT_UPDATE;

        Test.setMock(HttpCalloutMock.class, calloutsMock);
        Test.startTest();

        DCE_BackOfficeCallouts.doBackOfficeSync('Contact', 'Update', oldSObjectsMap, newSObjectsList);

        Test.stopTest();
    }
}