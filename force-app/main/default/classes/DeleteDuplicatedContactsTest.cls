/**
 * @description       : Tests the duplicated contacts batch
 * @author            : Martin Lezer
 * @group             : Tests
 * @last modified on  : 11-04-2022
 * @last modified by  : Martin Lezer
**/
@isTest public with sharing class DeleteDuplicatedContactsTest {
    @isTest static void testMain(){
        TestFactory factory = new TestFactory();
        factory.insertAccounts(6)
                .insertContacts()
                .insertCases();

        Account[] accounts = [SELECT Id FROM Account LIMIT 3];
        Contact[] contacts = [SELECT Id FROM Contact];
        
        contacts[0].Email = 'test@test.com';
        contacts[0].AccountId = accounts[0].Id;

        contacts[1].Email = 'test@test.com';
        contacts[1].AccountId = accounts[0].Id;
        contacts[1].Status__c = 'Spotted as duplicate coming from BO (will be deleted)';

        contacts[2].Email = 'test@test.com';
        contacts[2].AccountId = accounts[1].Id;
        contacts[2].Status__c = 'Spotted as duplicate coming from BO (will be deleted)';

        contacts[3].Email = 'test2@test.com';
        contacts[3].AccountId = accounts[1].Id;

        contacts[4].Email = 'test@test.com';
        contacts[4].AccountId = accounts[2].Id;

        contacts[5].Email = 'test2@test.com';
        contacts[5].AccountId = accounts[2].Id;

        update contacts;

        Test.startTest();
        DeleteDuplicatedContactsSchedulable schedulable = new DeleteDuplicatedContactsSchedulable ();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, schedulable);

        Database.executeBatch(new DeleteDuplicatedContactsBatch());
        Test.stopTest();

        System.assertEquals(0, [SELECT Id FROM Contact WHERE Id = :contacts[1].Id].size(), 'Duplicated contact not deleted');
        System.assertEquals(2, [SELECT Id FROM Case WHERE ContactId = :contacts[0].Id].size(), 'Case not transferred to contact to keep');

        System.assertEquals(1, [SELECT Id FROM Contact WHERE Id = :contacts[2].Id].size(), 'Contact deleted and should not be');
        System.assertEquals(1, [SELECT Id FROM Contact WHERE Id = :contacts[3].Id].size(), 'Contact deleted and should not be');
        System.assertEquals(1, [SELECT Id FROM Contact WHERE Id = :contacts[4].Id].size(), 'Contact deleted and should not be');
        System.assertEquals(1, [SELECT Id FROM Contact WHERE Id = :contacts[5].Id].size(), 'Contact deleted and should not be');
        System.assertEquals(1, [SELECT Id FROM Case WHERE ContactId = :contacts[2].Id].size(), 'Case transferred and should not be');
        System.assertEquals(1, [SELECT Id FROM Case WHERE ContactId = :contacts[3].Id].size(), 'Case transferred and should not be');
        System.assertEquals(1, [SELECT Id FROM Case WHERE ContactId = :contacts[4].Id].size(), 'Case transferred and should not be');
        System.assertEquals(1, [SELECT Id FROM Case WHERE ContactId = :contacts[5].Id].size(), 'Case transferred and should not be');
    }
}