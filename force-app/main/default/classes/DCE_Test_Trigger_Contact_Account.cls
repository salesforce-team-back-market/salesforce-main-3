/**********************************************
* CREATION : YBD 10/07/2019
* MODIFS :
* Permet de tester :    - Le trigger  DCE_AccountTrigger
*                       - Le trigger  DCE_ContactTrigger
* ******************************************/
@isTest
public class DCE_Test_Trigger_Contact_Account {

    @TestSetup
    static void makeData(){
        new TestFactory().setCustomSettings();

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
    
    @isTest
    public static void handleAccountTrigger_Test(){
        Account acc = new Account(Name='marchand test apex',Stage__c = 'Identification', BillingCountry = 'France', Country__c = 'France',Region__c ='Western Europe');
        insert acc;
        
        Account accResult = [SELECT 
                             Id,
                             Stage__c,
                             Type
                             FROM Account WHERE Id = :acc.Id
                            ];
                
        Id currentUser = UserInfo.getUserId();
        accResult.Zone__c = 'fr-fr';
        accResult.AccountSource = 'Entrant Lead';
        accResult.Profile__c = 'Classic';
        accResult.BizDev__c = currentUser;
        accResult.Fatness__c = 2;
        accResult.Stage__c = 'First-contact';
        update accResult;
    }
    
    @isTest
    public static void handleContactTrigger_Test(){
        
        Account acc = new Account(Name='marchand test apex',Stage__c = 'Identification',Back_Office_PK__c=99999,Inputted_from__c='Back-Office', BillingCountry = 'France', Country__c = 'France',Region__c ='Western Europe');
        insert acc;
       
        Contact ctc = new Contact(Lastname='contact test apex',Email='test@test.com',AccountId=acc.Id);
        insert ctc;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DCE_CalloutsMock());
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.httpMethod = 'PUT';  
        RestContext.request = req;
        RestContext.response = res;
        Test.stopTest();
        
    }

}