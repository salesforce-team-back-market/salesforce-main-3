/**
 * @description       : Generic test class used to create data for unit tests
 * @author            : Martin Lezer
 * @group             : Tests
 * @last modified on  : 11-09-2022
 * @last modified by  : Martin Lezer
**/
@IsTest public class TestFactory {
    public static final Integer LOAD_TEST_NUMBER = 50; //TODO increase to 200 when the CPU time problems are solved by switching flows to code
    public static final String USER_NAME_TEST = 'testuser@backmarket.com'; 

    private List<Account> accountsToInsert = new List<Account>();
    private List<Contact> contactsToInsert = new List<Contact>();
    private List<Mystery_Order__c> mysteryOrdersToInsert = new List<Mystery_Order__c>();
    private List<Onboarding_Process__c> onboardingProcesses = new List<Onboarding_Process__c>();
    private List<NMO_Process__c> NMOProcesses = new List<NMO_Process__c>();
    private List<Merchant_Special_Process__c> MSPProcesses = new List<Merchant_Special_Process__c>();
    private List<Alert__c> alerts = new List<Alert__c>();
    private List<Targeted_Country__c> countries = new List<Targeted_Country__c>();
    private List<Case> cases = new List<Case>();
    private List<Wallet__c> wallets = new List<Wallet__c>();
    private List<Wallet_Invoice__c> walletInvoices = new List<Wallet_Invoice__c>();
    
    private Boolean buyback;

    public Enum RECORD_TYPE{
        Onboarding,
        Alert
    }
    public Enum CASE_RECORD_TYPE{
        BackWatch_Merchant_contact,
        BuyBack_Bill_Process,
        BuyBack_Bill_Process_V2,
        Merchant_Claim,
        Qualification_Form,
        Quality_Support_Cases,
        Quality_Test_Buyback,
        Quality_Test_Language_test,
        Quality_Test,
        Quality_Test_US_Sales,
        After_Sales_Management,
        SSC_Back_Market_Services,
        SSC_Back_Office_Integrators_Technical_Support,
        SSC_Buyback_only_available_for_EU_sellers,
        SSC_Catalog,
        SSC_Finance_and_Legal,
        Quality_Sales_Performance,
        Support
    }

    public TestFactory(){
        this.buyback = false;
    }
    public TestFactory(Boolean buyback){
        this.buyback = buyback;
    }
    
    public void setCustomSettings(){
        Special_Process_Record_Types_Ids__c recordTypeIdsSettings = new Special_Process_Record_Types_Ids__c();
        recordTypeIdsSettings.Alert_Severe_Issue__c = Schema.SObjectType.Alert__c.getRecordTypeInfosByDeveloperName().get('Severe_Issue').getRecordTypeId();
        recordTypeIdsSettings.Back_Camp__c = Schema.SObjectType.Merchant_Special_Process__c.getRecordTypeInfosByDeveloperName().get('Back_Camp_U_S').getRecordTypeId();
        recordTypeIdsSettings.Business_Alerts__c = Schema.SObjectType.Alert__c.getRecordTypeInfosByDeveloperName().get('Business_Alerts').getRecordTypeId();
        recordTypeIdsSettings.Debit_note__c = Schema.SObjectType.Merchant_Special_Process__c.getRecordTypeInfosByDeveloperName().get('Debit_Note').getRecordTypeId();
        recordTypeIdsSettings.Exit__c = Schema.SObjectType.Merchant_Special_Process__c.getRecordTypeInfosByDeveloperName().get('Exit').getRecordTypeId();
        recordTypeIdsSettings.Exit_buyback__c = Schema.SObjectType.Merchant_Special_Process__c.getRecordTypeInfosByDeveloperName().get('Exit_buyback').getRecordTypeId();
        recordTypeIdsSettings.Exit_US__c = Schema.SObjectType.Merchant_Special_Process__c.getRecordTypeInfosByDeveloperName().get('Exit_U_S').getRecordTypeId();
        recordTypeIdsSettings.Financial_alerts__c = Schema.SObjectType.Alert__c.getRecordTypeInfosByDeveloperName().get('Financial_Issue').getRecordTypeId();
        recordTypeIdsSettings.Follow_Up__c = Schema.SObjectType.Merchant_Special_Process__c.getRecordTypeInfosByDeveloperName().get('Follow_Up').getRecordTypeId();
        recordTypeIdsSettings.Follow_Up_buyback__c = Schema.SObjectType.Merchant_Special_Process__c.getRecordTypeInfosByDeveloperName().get('Follow_Up_buyback').getRecordTypeId();
        recordTypeIdsSettings.Follow_up_US__c = Schema.SObjectType.Merchant_Special_Process__c.getRecordTypeInfosByDeveloperName().get('Follow_Up_U_S').getRecordTypeId();
        recordTypeIdsSettings.Invoice_Compliance_Audit__c = Schema.SObjectType.Alert__c.getRecordTypeInfosByDeveloperName().get('Invoice_Compliance_Audit').getRecordTypeId();
        recordTypeIdsSettings.Invoice_Compliance_Audit_del__c = Schema.SObjectType.Alert__c.getRecordTypeInfosByDeveloperName().get('Invoice_Compliance_Audit').getRecordTypeId();
        recordTypeIdsSettings.Lead_Seller_Qualification_Form__c = Schema.SObjectType.Merchant_Special_Process__c.getRecordTypeInfosByDeveloperName().get('NB_Lead_Qualification').getRecordTypeId();
        recordTypeIdsSettings.Merchant_EU__c = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('E_U').getRecordTypeId();
        recordTypeIdsSettings.Merchant_US__c = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('U_S').getRecordTypeId();
        recordTypeIdsSettings.Monitoring_Period_Buyback__c = Schema.SObjectType.Alert__c.getRecordTypeInfosByDeveloperName().get('Monitoring_Period_Buyback').getRecordTypeId();
        recordTypeIdsSettings.Monitoring_Period_Sales__c = Schema.SObjectType.Alert__c.getRecordTypeInfosByDeveloperName().get('Monitoring_Period_Sales').getRecordTypeId();
        recordTypeIdsSettings.MOP_Alert__c = Schema.SObjectType.Alert__c.getRecordTypeInfosByDeveloperName().get('MOP_alert').getRecordTypeId();
        recordTypeIdsSettings.Mystery_Order__c = Schema.SObjectType.Mystery_Order__c.getRecordTypeInfosByDeveloperName().get('Mystery_Order').getRecordTypeId();
        recordTypeIdsSettings.NMO__c = Schema.SObjectType.NMO_Process__c.getRecordTypeInfosByDeveloperName().get('NMO_E_U').getRecordTypeId();
        recordTypeIdsSettings.NMO_buyback__c = Schema.SObjectType.NMO_Process__c.getRecordTypeInfosByDeveloperName().get('NMO_E_U_buyback').getRecordTypeId();
        recordTypeIdsSettings.NMO_U_S__c = Schema.SObjectType.NMO_Process__c.getRecordTypeInfosByDeveloperName().get('NMO_U_S').getRecordTypeId();
        recordTypeIdsSettings.Onboarding__c = Schema.SObjectType.Onboarding_Process__c.getRecordTypeInfosByDeveloperName().get('E_U').getRecordTypeId();
        recordTypeIdsSettings.Onboarding_buyback__c = Schema.SObjectType.Onboarding_Process__c.getRecordTypeInfosByDeveloperName().get('E_U_Buyback').getRecordTypeId();
        recordTypeIdsSettings.Onboarding_Buyback_US__c = Schema.SObjectType.Onboarding_Process__c.getRecordTypeInfosByDeveloperName().get('U_S_Onboarding_Buyback').getRecordTypeId();
        recordTypeIdsSettings.Onboarding_JP__c = Schema.SObjectType.Onboarding_Process__c.getRecordTypeInfosByDeveloperName().get('JP_Onboarding').getRecordTypeId();
        recordTypeIdsSettings.Onboarding_US__c = Schema.SObjectType.Onboarding_Process__c.getRecordTypeInfosByDeveloperName().get('U_S').getRecordTypeId();
        recordTypeIdsSettings.Perf_data_Business__c = Schema.SObjectType.Performance_Data__c.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        recordTypeIdsSettings.Perf_data_Quality__c = Schema.SObjectType.Performance_Data__c.getRecordTypeInfosByDeveloperName().get('Quality').getRecordTypeId();
        recordTypeIdsSettings.PriceAndSelectionOpportunity__c = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Price_and_Selection').getRecordTypeId();
        recordTypeIdsSettings.Severe_Issue__c = Schema.SObjectType.Alert__c.getRecordTypeInfosByDeveloperName().get('Severe_Issue').getRecordTypeId();
        recordTypeIdsSettings.Targeted_Country_EU__c = Schema.SObjectType.Targeted_Country__c.getRecordTypeInfosByDeveloperName().get('E_U').getRecordTypeId();
        recordTypeIdsSettings.Targeted_Country_US__c = Schema.SObjectType.Targeted_Country__c.getRecordTypeInfosByDeveloperName().get('U_S').getRecordTypeId();
        recordTypeIdsSettings.XBorder__c = Schema.SObjectType.Merchant_Special_Process__c.getRecordTypeInfosByDeveloperName().get('NMO_Xborder').getRecordTypeId();
        insert recordTypeIdsSettings;

        UserID__c userIdSettings = new UserID__c();
        userIdSettings.API_BM_SF__c = [SELECT Id FROM User WHERE Name = 'BO Integration'].Id;
        insert userIdSettings;

        Services__c servicesSettings = new Services__c();
        servicesSettings.BackCareRecordType__c = Schema.SObjectType.Service__c.getRecordTypeInfosByDeveloperName().get('Back_Care').getRecordTypeId();
        servicesSettings.BackPackRecordType__c = Schema.SObjectType.Service__c.getRecordTypeInfosByDeveloperName().get('Back_Pack').getRecordTypeId();
        servicesSettings.BackPartsRecordType__c = Schema.SObjectType.Service__c.getRecordTypeInfosByDeveloperName().get('Back_Parts').getRecordTypeId();
        servicesSettings.BackRepairRecordType__c = Schema.SObjectType.Service__c.getRecordTypeInfosByDeveloperName().get('Back_Repair').getRecordTypeId();
        servicesSettings.BackShipRecordType__c = Schema.SObjectType.Service__c.getRecordTypeInfosByDeveloperName().get('Back_Ship').getRecordTypeId();
        servicesSettings.FBBMRecordType__c = Schema.SObjectType.Service__c.getRecordTypeInfosByDeveloperName().get('FBBM').getRecordTypeId();
        servicesSettings.ImpactChampionRecordType__c = Schema.SObjectType.Service__c.getRecordTypeInfosByDeveloperName().get('Impact_Champions').getRecordTypeId();
        servicesSettings.ManaRecordType__c = Schema.SObjectType.Service__c.getRecordTypeInfosByDeveloperName().get('Mana').getRecordTypeId();
        servicesSettings.RAASRecordType__c = Schema.SObjectType.Service__c.getRecordTypeInfosByDeveloperName().get('RAAS').getRecordTypeId();
        insert servicesSettings;

        EU_Back_Office_Settings__c boSettingsEU = new EU_Back_Office_Settings__c();
        boSettingsEU.Backoffice_URL__c = 'https://test.com';
        boSettingsEU.password__c = 'test';
        boSettingsEU.username__c = 'test';
        insert boSettingsEU;
    }

    public Account getAccountFR(String name){
        return new Account(
            Name = name,
            Zone__c = 'fr-fr',
            BillingCountry = 'France',
            BizDev__c = UserInfo.getUserId(),
            BizDev_Buyback__c = UserInfo.getUserId(),
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('E_U').getRecordTypeId()
        );
    }

    public Account getAccountUS(String name){
        return new Account(
            Name = name,
            Zone__c = 'en-us',
            BillingCountry = 'United States',
            BizDev__c = UserInfo.getUserId(),
            BizDev_Buyback__c = UserInfo.getUserId(),
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('U_S').getRecordTypeId()
        );
    }

    public Contact getContact(Id accId, String firstName, String lastName){
        return new Contact(
            FirstName = firstName,
            LastName = lastName,
            Email = firstName + '@' + lastName + '.com',
            AccountId = accId
        );
    }

    public Mystery_Order__c getMysteryOrder(Id accId){
        return new Mystery_Order__c(
            Merchant_Name__c = accId,
            Link_to_the_MO__c = 'https://test.com',
            Reason_for_failure__c = 'Device stolen / Produit déclaré volé'
        );
    }

    public Onboarding_Process__c getOnboarding(Id accId){
        return new Onboarding_Process__c(
            Merchant__c = accId,
            RecordTypeId = this.buyback ? Schema.SObjectType.Onboarding_Process__c.getRecordTypeInfosByDeveloperName().get('E_U_Buyback').getRecordTypeId()
                                        : Schema.SObjectType.Onboarding_Process__c.getRecordTypeInfosByDeveloperName().get('E_U').getRecordTypeId()
        );
    }

    public NMO_Process__c getNMOProcess(Id accId){
        return new NMO_Process__c(
            Merchant__c = accId
        );
    }

    public Merchant_Special_Process__c getMSPProcess(Id accId){
        return new Merchant_Special_Process__c(
            Merchant__c = accId,
            RecordTypeId = this.buyback ? Schema.SObjectType.Merchant_Special_Process__c.getRecordTypeInfosByDeveloperName().get('Exit_buyback').getRecordTypeId()
                                        : Schema.SObjectType.Merchant_Special_Process__c.getRecordTypeInfosByDeveloperName().get('Exit').getRecordTypeId()
        );
    }

    public Alert__c getAlert(Id accId){
        return new Alert__c(
            Business_Name__c = accId,
            RecordTypeId = this.buyback ? Schema.SObjectType.Alert__c.getRecordTypeInfosByDeveloperName().get('Monitoring_Period_Buyback').getRecordTypeId()
                                        : Schema.SObjectType.Alert__c.getRecordTypeInfosByDeveloperName().get('Monitoring_Period_Sales').getRecordTypeId()
        );
    }

    public Targeted_Country__c getCountry(Id accId, String country){
        return new Targeted_Country__c(
            Merchant__c = accId,
            Country__c = country
        );
    }

    public Case getCase(Id accId){
        return new Case(
            AccountId = accId,
            Stage__c = 'Draft',
            RecordTypeId = this.buyback ? Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(String.valueOf(CASE_RECORD_TYPE.Quality_Test_Buyback)).getRecordTypeId()
                                        : Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(String.valueOf(CASE_RECORD_TYPE.Quality_Test)).getRecordTypeId()
        );
    }
    public Case getCase(Id accId, Id contactId){
        Case c = getCase(accId);
        c.ContactId = contactId;
        return c;
    }
    public Case getCase(Id accId, CASE_RECORD_TYPE recordType){
        return new Case(
            AccountId = accId,
            Stage__c = 'Draft',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(String.valueOf(recordType)).getRecordTypeId()
        );
    }

    public TestFactory insertAccounts(){
        return this.insertAccounts(LOAD_TEST_NUMBER);
    }
    public TestFactory insertAccounts(Integer nbAccounts){
        this.accountsToInsert = new List<Account>();
        for(Integer i = 0; i < nbAccounts; i++){
            this.accountsToInsert.add(this.getAccountFR('Test' + i));
        }
        insert this.accountsToInsert;
        return this;
    }

    public TestFactory insertContacts(){
        if(this.accountsToInsert.size() == 0){
            throw new CustomException('You have to insert accounts first by using the insertAccounts method');
        }

        for(Integer i = 0; i < this.accountsToInsert.size(); i++){
            this.contactsToInsert.add(this.getContact(this.accountsToInsert[i].Id, 'FirstNameTest' + i, 'LastNameTest' + i));
        }
        insert this.contactsToInsert;
        return this;
    }

    private TestFactory insertMysteryOrders(Integer nbRecordsByAccount){
        if(this.accountsToInsert.size() == 0){
            throw new CustomException('You have to insert accounts first by using the insertAccounts method');
        }

        for(Integer i = 0; i < this.accountsToInsert.size(); i++){
            for(Integer j = 0; j < nbRecordsByAccount; j++){
                this.mysteryOrdersToInsert.add(this.getMysteryOrder(accountsToInsert[i].Id));
            }
        }
        insert this.mysteryOrdersToInsert;
        return this;
    }
    public TestFactory insertMysteryOrders(){
        return this.insertMysteryOrders(1);
    }
    public TestFactory insertMysteryOrdersBulk(){
        return this.insertMysteryOrders(LOAD_TEST_NUMBER);
    }

    private TestFactory insertOnboardingProcesses(Integer nbRecordsByAccount){
        if(this.accountsToInsert.size() == 0){
            throw new CustomException('You have to insert accounts first by using the insertAccounts method');
        }

        for(Integer i = 0; i < this.accountsToInsert.size(); i++){
            for(Integer j = 0; j < nbRecordsByAccount; j++){
                this.onboardingProcesses.add(this.getOnboarding(accountsToInsert[i].Id));
            }
        }
        insert this.onboardingProcesses;
        return this;
    }
    public TestFactory insertOnboardingProcesses(){
        return this.insertOnboardingProcesses(1);
    }
    public TestFactory insertOnboardingProcessesBulk(){
        return this.insertOnboardingProcesses(LOAD_TEST_NUMBER);
    }

    private TestFactory insertNMOProcesses(Integer nbRecordsByAccount){
        if(this.accountsToInsert.size() == 0){
            throw new CustomException('You have to insert accounts first by using the insertAccounts method');
        }

        for(Integer i = 0; i < this.accountsToInsert.size(); i++){
            for(Integer j = 0; j < nbRecordsByAccount; j++){
                this.NMOProcesses.add(this.getNMOProcess(accountsToInsert[i].Id));
            }
        }
        insert this.NMOProcesses;
        return this;
    }
    public TestFactory insertNMOProcesses(){
        return this.insertNMOProcesses(1);
    }
    public TestFactory insertNMOProcessesBulk(){
        return this.insertNMOProcesses(LOAD_TEST_NUMBER);
    }

    private TestFactory insertMSPProcesses(Integer nbRecordsByAccount){
        if(this.accountsToInsert.size() == 0){
            throw new CustomException('You have to insert accounts first by using the insertAccounts method');
        }

        for(Integer i = 0; i < this.accountsToInsert.size(); i++){
            for(Integer j = 0; j < nbRecordsByAccount; j++){
                this.MSPProcesses.add(this.getMSPProcess(accountsToInsert[i].Id));
            }
        }
        insert this.MSPProcesses;
        return this;
    }
    public TestFactory insertMSPProcesses(){
        return this.insertMSPProcesses(1);
    }
    public TestFactory insertMSPProcessesBulk(){
        return this.insertMSPProcesses(LOAD_TEST_NUMBER);
    }

    private TestFactory insertAlerts(Integer nbRecordsByAccount){
        if(this.accountsToInsert.size() == 0){
            throw new CustomException('You have to insert accounts first by using the insertAccounts method');
        }

        for(Integer i = 0; i < this.accountsToInsert.size(); i++){
            for(Integer j = 0; j < nbRecordsByAccount; j++){
                this.alerts.add(this.getAlert(accountsToInsert[i].Id));
            }
        }
        insert this.alerts;
        return this;
    }
    public TestFactory insertAlerts(){
        return this.insertAlerts(1);
    }
    public TestFactory insertAlertsBulk(){
        return this.insertAlerts(LOAD_TEST_NUMBER);
    }

    private TestFactory insertCountries(Boolean isBulk){
        if(this.accountsToInsert.size() == 0){
            throw new CustomException('You have to insert accounts first by using the insertAccounts method');
        }

        for(Integer i = 0; i < this.accountsToInsert.size(); i++){
            Schema.DescribeFieldResult objFieldDescribe = Targeted_Country__c.Country__c.getDescribe();
            List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
            if(isBulk){
                for (Schema.PicklistEntry objPickList : lstPickListValues) {
                    this.countries.add(this.getCountry(accountsToInsert[i].Id, objPickList.getValue()));
                }
            }else{
                this.countries.add(this.getCountry(accountsToInsert[i].Id, lstPickListValues[0].getValue()));
            }
        }
        insert this.countries;
        return this;
    }
    public TestFactory insertCountries(){
        return this.insertCountries(false);
    }
    public TestFactory insertCountriesBulk(){
        return this.insertCountries(true);
    }

    private TestFactory insertCases(Integer nbRecordsByAccount){
        if(this.accountsToInsert.size() == 0){
            throw new CustomException('You have to insert accounts first by using the insertAccounts method');
        }

        for(Integer i = 0; i < this.accountsToInsert.size(); i++){
            for(Integer j = 0; j < nbRecordsByAccount; j++){
                if(contactsToInsert?.size() > i){
                    this.cases.add(this.getCase(accountsToInsert[i].Id, contactsToInsert[i].Id));
                }else{
                    this.cases.add(this.getCase(accountsToInsert[i].Id));
                }
            }
        }
        insert this.cases;
        return this;
    }
    public TestFactory insertCases(){
        return this.insertCases(1);
    }
    public TestFactory insertCasesBulk(){
        return this.insertCases(LOAD_TEST_NUMBER);
    }

    public User getUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name='SSM']; 
        User u = new User(Alias = 'standt', Email='testuser@backmarket.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=USER_NAME_TEST, ManagerId = UserInfo.getUserId());
        return u;
    }

    public void updateBulk(RECORD_TYPE type, String field, Object value){
        switch on type {
            when Onboarding {
                for(Onboarding_Process__c onboarding : this.onboardingProcesses){
                    onboarding.put(field, value);
                }
                update this.onboardingProcesses;
            }
            when Alert {
                for(Alert__c alert : this.alerts){
                    alert.put(field, value);
                }
                update this.alerts;
            }
            when else {}
        }
    }

    public TestFactory insertWallets(){
        if(this.accountsToInsert.size() == 0){
            throw new CustomException('You have to insert accounts first by using the insertAccounts method');
        }

        this.accountsToInsert = [SELECT Id, TECH_P_K__c FROM Account WHERE Id IN :this.accountsToInsert];

        for(Integer i = 0; i < this.accountsToInsert.size(); i++){
            this.wallets.add(this.getWallet(accountsToInsert[i].Id, accountsToInsert[i].TECH_P_K__c));
        }
        insert this.wallets;
        return this;
    }

    public TestFactory insertWalletInvoices(){
        if(this.wallets.size() == 0){
            throw new CustomException('You have to insert wallets first by using the insertAccounts method');
        }

        for(Integer i = 0; i < this.wallets.size(); i++){
            this.walletInvoices.add(this.getWalletInvoice(this.wallets[i].Id, 'Past', this.wallets[i].PK__c));
        }
        for(Integer i = 0; i < this.wallets.size(); i++){
            this.walletInvoices.add(this.getWalletInvoice(this.wallets[i].Id, 'Coming', this.wallets[i].PK__c));
        }
        for(Integer i = 0; i < this.wallets.size(); i++){
            this.walletInvoices.add(this.getWalletInvoice(this.wallets[i].Id, 'Future', this.wallets[i].PK__c));
        }
        insert this.walletInvoices;
        return this;
    }

    public Wallet__c getWallet(Id accId, String pk){
        return new Wallet__c(
            All_wallets_snapshot__c = 10,
            Contact_Rate__c = 10,
            Currency__c = 'EUR',
            Defective_Rate__c = 10,
            Estimated_natural_deposit__c = 10,
            GMV_under_warranty__c = 10,
            PSP__c = 'ADYEN',
            Merchant__c = accId,
            Total_balance__c = 10,
            Total_payable_balance__c = 10,
            PK__c = pk,
            External_Id__c = pk+'EUR'+'ADYEN'
        );
    }

    public Wallet_Invoice__c getWalletInvoice(Id walletId, String type, String pk){
        return new Wallet_Invoice__c(
            Amount_paid__c = 10,
            Deferred_payout__c = 10,
            Currency__c = 'EUR',
            Deferred_payout_increase_decrease__c = 10,
            Future_refunds__c = 10,
            Payable_balance__c = 10,
            PSP__c = 'ADYEN',
            Wallet__c = walletId,
            Invoice_Type__c = type,
            External_Id__c = pk+'EUR'+'ADYEN'+type,
            PK__c = pk
        );
    }
}
