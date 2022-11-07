/**
 * @description       : Updating cases contacts before duplicated contacts deletion
 * @author            : Martin Lezer
 * @group             : Batch
 * @last modified on  : 11-07-2022
 * @last modified by  : Martin Lezer
**/
public class DeleteDuplicatedContactsBatch implements Database.Batchable<sObject>, Database.Stateful{ 
    private static final String DUPLICATED_STATUS = 'Spotted as duplicate coming from BO (will be deleted)';

    LogService logs = new LogService(String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'))); //sending current class name
    List<Case> casesToRemoveByPass = new List<Case>();
    List<Contact> contactsToDelete = new List<Contact>();

    public Database.QueryLocator start(Database.BatchableContext BC){       
        logs.addLog(LogService.LOG_TYPE.INFO, LogService.PROCESS.DUPLICATED_CONTACTS, new Set<Id>(), 'Process started');

        return Database.getQueryLocator('SELECT AccountId, Email, (SELECT Id FROM Cases) FROM Contact WHERE Status__c = \'' + DUPLICATED_STATUS + '\'');
    }
 
    public void execute(Database.BatchableContext BC, List<Contact> duplicatedContacts){
        logs.addLog(LogService.LOG_TYPE.INFO, LogService.PROCESS.DUPLICATED_CONTACTS, new Set<Id>(), 'Batch started');

        List<String> contactsEmails = new List<String>();
        List<Id> contactsAccountsIds = new List<Id>();
        for(Contact c : duplicatedContacts){
            contactsEmails.add(c.Email);
            contactsAccountsIds.add(c.AccountId);
        }

        Map<Id, Map<String, Contact>> contactsByAccountAndEmail = new Map<Id, Map<String, Contact>>();
        for(Contact contactToKeep : [SELECT AccountId, Email FROM Contact 
                                WHERE AccountId IN :contactsAccountsIds 
                                    AND Email IN :contactsEmails
                                    AND Status__c != :DUPLICATED_STATUS]){
            if(contactsByAccountAndEmail.containsKey(contactToKeep.AccountId) == false){
                Map<String, Contact> contactByEmail = new Map<String, Contact>();
                contactByEmail.put(contactToKeep.Email, contactToKeep);

                contactsByAccountAndEmail.put(contactToKeep.AccountId, contactByEmail);
            }else{
                contactsByAccountAndEmail.get(contactToKeep.AccountId).put(contactToKeep.Email, contactToKeep);
            }
        }

        Map<Id, Case> casesToUpdate = new Map<Id, Case>();
        for(Contact currentContact : duplicatedContacts){
            if(contactsByAccountAndEmail.containsKey(currentContact.AccountId)){
                if(contactsByAccountAndEmail.get(currentContact.AccountId).containsKey(currentContact.Email)){
                    Contact contactToAssign = contactsByAccountAndEmail.get(currentContact.AccountId).get(currentContact.Email);

                    for(Case c : currentContact.Cases){
                        c.ContactId = contactToAssign.Id;
                        c.ByPassVR__c = true;

                        casesToUpdate.put(c.Id, c);
                        casesToRemoveByPass.add(c);
                    }

                    this.contactsToDelete.add(currentContact);
                }
            }
        }     

        try{
            if(casesToUpdate.isEmpty() == false){
                update casesToUpdate.values();
                logs.addLog(LogService.LOG_TYPE.INFO, LogService.PROCESS.DUPLICATED_CONTACTS, casesToUpdate.keySet(), 'Cases contacts updated');
            }

            User[] portalUsers = [SELECT Id FROM User WHERE ContactId IN :this.contactsToDelete];
            if(portalUsers.isEmpty() == false){
                for(User u : portalUsers){
                    u.IsActive = false;
                }
                update portalUsers;
            }
        }catch(DmlException e){
            logs.addLog(LogService.LOG_TYPE.ERROR, LogService.PROCESS.DUPLICATED_CONTACTS, casesToUpdate.keySet(), e.getMessage());
        }
    }
 
    public void finish(Database.BatchableContext BC){
        delete contactsToDelete;
        logs.addLog(LogService.LOG_TYPE.INFO, LogService.PROCESS.DUPLICATED_CONTACTS, new Set<Id>(), 'Duplicated contacts deleted');

        if(this.casesToRemoveByPass.isEmpty() == false){
            for(Case c : this.casesToRemoveByPass){
                c.ByPassVR__c = false;
            }
            update this.casesToRemoveByPass;
        }

        logs.addLog(LogService.LOG_TYPE.INFO, LogService.PROCESS.DUPLICATED_CONTACTS, new Set<Id>(), 'Process ended');

        logs.publishLogs();
    }
 }