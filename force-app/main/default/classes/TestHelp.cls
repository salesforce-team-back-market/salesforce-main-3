public class TestHelp {

    public static User createUser(){
        User u = new User(
                alias = 'standt',
                email='standarduser@testorg.com', 
                emailencodingkey='UTF-8',
                lastname='Testing',
                languagelocalekey='fr', 
                localesidkey='fr_FR',
                //profileId = Config__c.getValues('UserAdminProfile').Value__c,
                timezonesidkey='America/Los_Angeles',
                username=Math.random()+'test@testorg.com'
                //ByPassWorkflow__c = true,
                //ByPassValidationRules__c = true
            );
            return u;
        }
    
    public static User createCustomerChampionUser(){
        Id profileIdCustomerChampion = [Select Id From Profile Where Name='System Administrator'].Id;

        User u = new User(
                alias = 'standt',
                email='standarduser@testorg.com', 
                emailencodingkey='UTF-8',
                lastname='Testing',
                languagelocalekey='fr', 
                localesidkey='fr_FR',
                profileId = profileIdCustomerChampion,
                timezonesidkey='America/Los_Angeles',
                username=Math.random()+'test@testorg.com'
                //ByPassWorkflow__c = true,
                //ByPassValidationRules__c = true
            );
            return u;
        }
}