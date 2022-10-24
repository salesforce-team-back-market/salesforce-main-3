/**
 * @description       : Account trigger handler used to update accounts manager and related account records if the accounts bizdev is changed
 * @author            : Martin Lezer
 * @group             : TriggerHandler
 * @last modified on  : 09-12-2022
 * @last modified by  : Martin Lezer
**/
public class AccountTriggerHandler extends TriggerHandler{
    public override void beforeUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap, List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {
        // bizdev changed: handling merchant manager and recipient email depending on new bizdev
        Set<Id> usersIds = new Set<Id>();
        List<Account> accountsToUpdate = new List<Account>();
        List<Account> accountsBuybackToUpdate = new List<Account>();
        for(Account acc : (List<Account>) triggerNew){
            if(acc.OwnerId != ((Map<Id, Account>) triggerOldMap).get(acc.Id).OwnerId){
                usersIds.add(acc.OwnerId);
                accountsToUpdate.add(acc);
            }
            if(acc.BizDev_Buyback__c != ((Map<Id, Account>) triggerOldMap).get(acc.Id).BizDev_Buyback__c){
                usersIds.add(acc.BizDev_Buyback__c);
                accountsBuybackToUpdate.add(acc);
            }
        }

        if(accountsToUpdate.isEmpty() == false || accountsBuybackToUpdate.isEmpty() == false){
            Map<Id, User> usersById = new Map<Id, User>([SELECT ManagerId, Team_Email__c FROM User WHERE Id IN :usersIds]);

            for(Account acc : accountsToUpdate){
                User bizdev = usersById.get(acc.OwnerId);
                acc.Manager_Sales__c = bizdev.ManagerId;
                acc.Recipient_email_sales__c = bizdev.Team_Email__c;
            }

            for(Account acc : accountsBuybackToUpdate){
                User bizdev = usersById.get(acc.BizDev_Buyback__c);
                acc.Manager_Buyback__c = bizdev.ManagerId;
                acc.Recipient_email_buyback__c = bizdev.Team_Email__c;
            }
        }
    }

    public override void afterUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap, List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {
        //bizdev changed: updating related records bizdev and manager change
        //                onboarding processes
        //                NMO processes
        //                merchant special processes
        //                alerts
        //                mystery orders
        //                targeted countries
        LogService logs = new LogService(String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'))); //sending current class name

        Map<Id, Account> oldAccounts = (Map<Id, Account>) triggerOldMap;
        Set<Id> accountsBizDevUpdated = new Set<Id>();
        Set<Id> onlyBizDevUpdatedAccount = new Set<Id>();
        Set<Id> accountsOnboardingToUpdate = new Set<Id>();
        Set<Id> accountsNMOToUpdate = new Set<Id>();
        Set<Id> accountsMSPToUpdate = new Set<Id>();
        Set<Id> accountsAlertsToUpdate = new Set<Id>();
        Set<Id> onlyBizDevBuybackUpdatedAccount = new Set<Id>();
        Set<Id> accountsOnboardingBuybackToUpdate = new Set<Id>();
        Set<Id> accountsMSPBuybackToUpdate = new Set<Id>();
        Set<Id> accountsAlertsBuybackToUpdate = new Set<Id>();
        for(Account acc : (List<Account>) triggerNew){
            if(acc.OwnerId != oldAccounts.get(acc.Id).OwnerId || acc.Manager_Sales__c != oldAccounts.get(acc.Id).Manager_Sales__c){
                accountsBizDevUpdated.add(acc.Id);

                // for cases, mystery orders and targeted countries we only need the bizdev to be updated (manager not needed)
                if(acc.OwnerId != oldAccounts.get(acc.Id).OwnerId){
                    onlyBizDevUpdatedAccount.add(acc.Id);
                }

                if(acc.Number_of_onboarding_processes__c > 0){
                    accountsOnboardingToUpdate.add(acc.Id);
                }
                if(acc.Number_of_Ongoing_NMO_processes__c > 0){
                    accountsNMOToUpdate.add(acc.Id);
                }
                if(acc.Number_of_Ongoing_MSP__c > 0){
                    accountsMSPToUpdate.add(acc.Id);
                }
                if(acc.Ongoing_Alerts__c > 0){
                    accountsAlertsToUpdate.add(acc.Id);
                }
            }
            // buyback update
            if(acc.BizDev_Buyback__c != oldAccounts.get(acc.Id).BizDev_Buyback__c || acc.Manager_Buyback__c != oldAccounts.get(acc.Id).Manager_Buyback__c){
                accountsBizDevUpdated.add(acc.Id);

                // for cases, mystery orders and targeted countries we only need the bizdev to be updated (manager not needed)
                if(acc.BizDev_Buyback__c != oldAccounts.get(acc.Id).BizDev_Buyback__c){
                    onlyBizDevBuybackUpdatedAccount.add(acc.Id);
                }

                if(acc.Number_of_onboarding_processes__c > 0){
                    accountsOnboardingBuybackToUpdate.add(acc.Id);
                }
                if(acc.Number_of_Ongoing_MSP__c > 0){
                    accountsMSPBuybackToUpdate.add(acc.Id);
                }
                if(acc.Ongoing_Alerts__c > 0){
                    accountsAlertsBuybackToUpdate.add(acc.Id);
                }
            }
        }

        if(accountsBizDevUpdated.isEmpty() == false){
            logs.addLog(LogService.LOG_TYPE.INFO, LogService.PROCESS.ACCOUNT_BIZDEV_CHANGED, accountsBizDevUpdated, 'Process started');

            Map<Id, Account> newAccounts = (Map<Id, Account>) triggerNewMap;
            List<SObject> recordsToUpdate = new List<SObject>();
            // onboarding processes
            if(accountsOnboardingToUpdate.isEmpty() == false || accountsOnboardingBuybackToUpdate.isEmpty() == false){
                Map<Id, Onboarding_Process__c> onboardingsToUpdate = new Map<Id, Onboarding_Process__c>([SELECT Merchant__c, Is_Buyback__c FROM Onboarding_Process__c 
                                                                                                         WHERE (Merchant__c IN :accountsOnboardingToUpdate OR Merchant__c IN :accountsOnboardingBuybackToUpdate)]);

                logs.addLog(LogService.LOG_TYPE.INFO, LogService.PROCESS.ACCOUNT_BIZDEV_CHANGED, onboardingsToUpdate.keySet(), 'Updating onboardings');

                for(Onboarding_Process__c onboarding : onboardingsToUpdate.values()){
                    if(accountsOnboardingToUpdate.contains(onboarding.Merchant__c) && onboarding.Is_Buyback__c == false){
                        onboarding.Manager_for_Approval__c = newAccounts.get(onboarding.Merchant__c).Manager_Sales__c;
                        onboarding.Merchant_BizDev__c = newAccounts.get(onboarding.Merchant__c).OwnerId;

                        recordsToUpdate.add(onboarding);
                    }else if(accountsOnboardingBuybackToUpdate.contains(onboarding.Merchant__c) && onboarding.Is_Buyback__c == true){
                        onboarding.Manager_for_Approval__c = newAccounts.get(onboarding.Merchant__c).Manager_Buyback__c;
                        onboarding.Merchant_BizDev__c = newAccounts.get(onboarding.Merchant__c).BizDev_Buyback__c;

                        recordsToUpdate.add(onboarding);
                    }
                }
            }
            // NMO processes
            if(accountsNMOToUpdate.isEmpty() == false){
                Map<Id, NMO_Process__c> NMOToUpdate = new Map<Id, NMO_Process__c>([SELECT Merchant__c FROM NMO_Process__c 
                                                                                   WHERE Merchant__c IN :accountsNMOToUpdate 
                                                                                         AND Stage__c != 'Saved' AND Stage__c != 'Failed' 
                                                                                         AND Is_Buyback__c = false]);

                logs.addLog(LogService.LOG_TYPE.INFO, LogService.PROCESS.ACCOUNT_BIZDEV_CHANGED, NMOToUpdate.keySet(), 'Updating NMO');

                for(NMO_Process__c nmo : NMOToUpdate.values()){
                    nmo.Manager__c = newAccounts.get(nmo.Merchant__c).Manager_Sales__c;
                    nmo.BizDevApproval__c = newAccounts.get(nmo.Merchant__c).OwnerId;

                    recordsToUpdate.add(nmo);
                }
            }
            // merchant special processes
            if(accountsMSPToUpdate.isEmpty() == false || accountsMSPBuybackToUpdate.isEmpty() == false){
                Id MSPRecordTypeExitId = Schema.SObjectType.Merchant_Special_Process__c.getRecordTypeInfosByDeveloperName().get('Exit').getRecordTypeId();
                Id MSPRecordTypeExitUSId = Schema.SObjectType.Merchant_Special_Process__c.getRecordTypeInfosByDeveloperName().get('Exit_U_S').getRecordTypeId();
                Id MSPRecordTypeExitBuybackId = Schema.SObjectType.Merchant_Special_Process__c.getRecordTypeInfosByDeveloperName().get('Exit_buyback').getRecordTypeId();
                Map<Id, Merchant_Special_Process__c> MSPToUpdate = new Map<Id, Merchant_Special_Process__c>([SELECT Merchant__c, RecordTypeId, Stage__c FROM Merchant_Special_Process__c 
                                                                                                             WHERE (Merchant__c IN :accountsMSPToUpdate OR Merchant__c IN :accountsMSPBuybackToUpdate) 
                                                                                                                   AND Stage__c != 'Done' AND Stage__c != 'Cancelled' 
                                                                                                                   AND (RecordTypeId = :MSPRecordTypeExitId OR RecordTypeId = :MSPRecordTypeExitUSId OR RecordTypeId = :MSPRecordTypeExitBuybackId)]);

                logs.addLog(LogService.LOG_TYPE.INFO, LogService.PROCESS.ACCOUNT_BIZDEV_CHANGED, MSPToUpdate.keySet(), 'Updating MSP');
                                                            
                for(Merchant_Special_Process__c msp : MSPToUpdate.values()){
                    if(accountsMSPToUpdate.contains(msp.Merchant__c) && (msp.RecordTypeId == MSPRecordTypeExitId || msp.RecordTypeId == MSPRecordTypeExitUSId)){
                        msp.Customer_Champion_Manager__c = newAccounts.get(msp.Merchant__c).Manager_Sales__c;
                        msp.BizDev_for_Approval__c = newAccounts.get(msp.Merchant__c).OwnerId;

                        recordsToUpdate.add(msp);
                    }else if(accountsMSPBuybackToUpdate.contains(msp.Merchant__c) && msp.RecordTypeId == MSPRecordTypeExitBuybackId){
                        msp.Customer_Champion_Manager__c = newAccounts.get(msp.Merchant__c).Manager_Buyback__c;
                        msp.BizDev_for_Approval__c = newAccounts.get(msp.Merchant__c).BizDev_Buyback__c;

                        recordsToUpdate.add(msp);
                    }
                }
            }
            // alerts
            if(accountsAlertsToUpdate.isEmpty() == false || accountsAlertsBuybackToUpdate.isEmpty() == false){
                Map<Id, Alert__c> alertsToUpdate = new Map<Id, Alert__c>([SELECT Business_Name__c, Is_Buyback__c, Stage__c FROM Alert__c 
                                                                          WHERE (Business_Name__c IN :accountsAlertsToUpdate OR Business_Name__c IN :accountsAlertsBuybackToUpdate)
                                                                                AND (Stage__c = 'Monitoring Period' OR Stage__c = 'Last chance' OR Stage__c = 'In progress' OR Stage__c = 'Not compliant')]);

                logs.addLog(LogService.LOG_TYPE.INFO, LogService.PROCESS.ACCOUNT_BIZDEV_CHANGED, alertsToUpdate.keySet(), 'Updating alerts');

                for(Alert__c alert : alertsToUpdate.values()){
                    if(accountsAlertsToUpdate.contains(alert.Business_Name__c) && alert.Is_Buyback__c == false){
                        alert.Manager__c = newAccounts.get(alert.Business_Name__c).Manager_Sales__c;
                        alert.BizDev__c = newAccounts.get(alert.Business_Name__c).OwnerId;
                        alert.Recipient_email_sales__c = newAccounts.get(alert.Business_Name__c).Recipient_email_sales__c;

                        recordsToUpdate.add(alert);
                    }else if(accountsAlertsBuybackToUpdate.contains(alert.Business_Name__c) && alert.Is_Buyback__c == true && (alert.Stage__c == 'Monitoring Period' || alert.Stage__c == 'Last chance')){
                        alert.Manager__c = newAccounts.get(alert.Business_Name__c).Manager_Buyback__c;
                        alert.BizDev_Buyback__c = newAccounts.get(alert.Business_Name__c).BizDev_Buyback__c;
                        alert.Recipient_email_sales__c = newAccounts.get(alert.Business_Name__c).Recipient_email_sales__c;
                        alert.Recipient_email_buyback__c = newAccounts.get(alert.Business_Name__c).Recipient_email_buyback__c;

                        recordsToUpdate.add(alert);
                    }
                }
            }

            if(onlyBizDevUpdatedAccount.isEmpty() == false || onlyBizDevBuybackUpdatedAccount.isEmpty() == false){
                // cases
                Id caseQualityTestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Quality_Test').getRecordTypeId();
                Id caseLanguageTestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Quality_Test_Language_test').getRecordTypeId();
                Id caseBuyBackBillProcessRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('BuyBack_Bill_Process').getRecordTypeId();
                Id caseBuyBackBillProcess2RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('BuyBack_Bill_Process_V2').getRecordTypeId();
                Id caseQualityTestBuyBackRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Quality_Test_Buyback').getRecordTypeId();

                Map<Id, Case> casesToUpdate = new Map<Id, Case>([SELECT AccountId, RecordTypeId FROM Case 
                                                                 WHERE (AccountId IN :onlyBizDevUpdatedAccount OR AccountId IN :onlyBizDevBuybackUpdatedAccount) 
                                                                       AND Stage__c = 'Draft' 
                                                                       AND (RecordTypeId = :caseQualityTestRecordTypeId OR RecordTypeId = :caseLanguageTestRecordTypeId
                                                                           OR RecordTypeId = :caseBuyBackBillProcessRecordTypeId OR RecordTypeId = :caseQualityTestBuyBackRecordTypeId OR RecordTypeId = :caseBuyBackBillProcess2RecordTypeId)]);
                
                logs.addLog(LogService.LOG_TYPE.INFO, LogService.PROCESS.ACCOUNT_BIZDEV_CHANGED, casesToUpdate.keySet(), 'Updating cases');

                for(Case c : casesToUpdate.values()){
                    if(onlyBizDevUpdatedAccount.contains(c.AccountId) && (c.RecordTypeId == caseQualityTestRecordTypeId || c.RecordTypeId == caseLanguageTestRecordTypeId)){
                        c.Merchant_BizDev__c = newAccounts.get(c.AccountId).OwnerId;
                        c.Recipient_email_sales__c = newAccounts.get(c.AccountId).Recipient_email_sales__c;

                        recordsToUpdate.add(c);
                    }else if(onlyBizDevBuybackUpdatedAccount.contains(c.AccountId) && (c.RecordTypeId == caseBuyBackBillProcessRecordTypeId || c.RecordTypeId == caseQualityTestBuyBackRecordTypeId || c.RecordTypeId == caseBuyBackBillProcess2RecordTypeId)){
                        c.Merchant_BizDev__c = newAccounts.get(c.AccountId).BizDev_Buyback__c;
                        c.Recipient_email_buyback__c = newAccounts.get(c.AccountId).Recipient_email_buyback__c;
                        c.OwnerId = newAccounts.get(c.AccountId).BizDev_Buyback__c;

                        recordsToUpdate.add(c);
                    }
                }

                if(onlyBizDevUpdatedAccount.isEmpty() == false){
                    // mystery orders
                    Map<Id, Mystery_Order__c> ordersToUpdate = new Map<Id, Mystery_Order__c>([SELECT Merchant_Name__c FROM Mystery_Order__c 
                                                                                              WHERE Merchant_Name__c IN :onlyBizDevUpdatedAccount 
                                                                                                    AND (Stage__c = 'To do' OR Stage__c = 'Stand-by' OR Stage__c = 'Order made' OR Stage__c = 'Received' OR Stage__c = 'Check done')]);
                    
                    logs.addLog(LogService.LOG_TYPE.INFO, LogService.PROCESS.ACCOUNT_BIZDEV_CHANGED, ordersToUpdate.keySet(), 'Updating mystery orders');
                    
                    for(Mystery_Order__c order : ordersToUpdate.values()){
                        order.Current_BizDev__c = newAccounts.get(order.Merchant_Name__c).OwnerId;

                        recordsToUpdate.add(order);
                    }
                    // targeted countries
                    Map<Id, Targeted_Country__c> countriesToUpdate = new Map<Id, Targeted_Country__c>([SELECT Merchant__c FROM Targeted_Country__c 
                                                                                                       WHERE Merchant__c IN :onlyBizDevUpdatedAccount]);

                    logs.addLog(LogService.LOG_TYPE.INFO, LogService.PROCESS.ACCOUNT_BIZDEV_CHANGED, countriesToUpdate.keySet(), 'Updating targeted countries');

                    for(Targeted_Country__c country : countriesToUpdate.values()){
                        country.Recipient_email_sales__c = newAccounts.get(country.Merchant__c).Recipient_email_sales__c;

                        recordsToUpdate.add(country);
                    }
                }
            }

            Map<Id, SObject> recordsToUpdateById = new Map<Id, SObject>(recordsToUpdate);
            if(recordsToUpdateById.isEmpty() == false){
                try{
                    logs.addLog(LogService.LOG_TYPE.INFO, LogService.PROCESS.ACCOUNT_BIZDEV_CHANGED, recordsToUpdateById.keySet(), 'Update to database starting');

                    update recordsToUpdateById.values();

                    logs.addLog(LogService.LOG_TYPE.SUCCESS, LogService.PROCESS.ACCOUNT_BIZDEV_CHANGED, recordsToUpdateById.keySet(), 'Update to database finished');
                }catch(DmlException e){
                    logs.addLog(LogService.LOG_TYPE.ERROR, LogService.PROCESS.ACCOUNT_BIZDEV_CHANGED, recordsToUpdateById.keySet(), e.getMessage());
                }catch(Exception e){
                    logs.addLog(LogService.LOG_TYPE.ERROR, LogService.PROCESS.ACCOUNT_BIZDEV_CHANGED, recordsToUpdateById.keySet(), e.getMessage());
                }finally{
                    logs.publishLogs();
                }
            }
        }
    }
}