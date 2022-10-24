/**
 * @description       : User trigger handler used to update related accounts manager when the user manager is changed 
 * @author            : Martin Lezer
 * @group             : TriggerHandler
 * @last modified on  : 09-13-2022
 * @last modified by  : Martin Lezer
**/
public class UserTriggerHandler extends TriggerHandler{
    public override void afterUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap, List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {
        Map<Id, User> oldUsers = (Map<Id, User>) triggerOldMap;
        Map<Id, Id> usersManagerUpdated = new Map<Id, Id>();
        LogService logs = new LogService(String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'))); //sending current class name

        for(User u : (List<User>) triggerNew){
            if(u.ManagerId != oldUsers.get(u.Id).ManagerId){
                usersManagerUpdated.put(u.Id, u.ManagerId);
            }
        }

        if(usersManagerUpdated.isEmpty() == false){
            logs.addLog(LogService.LOG_TYPE.INFO, LogService.PROCESS.USER_MANAGER_CHANGED, usersManagerUpdated.keySet(), 'Process started');

            Map<Id, Account> accs = new Map<Id, Account>([SELECT OwnerId, BizDev_Buyback__c FROM Account WHERE OwnerId IN :usersManagerUpdated.keySet() OR BizDev_Buyback__c IN :usersManagerUpdated.keySet()]);
            
            logs.addLog(LogService.LOG_TYPE.INFO, LogService.PROCESS.USER_MANAGER_CHANGED, usersManagerUpdated.keySet(), 'Accounts to update');

            for(Account acc : accs.values()){
                if(usersManagerUpdated.containsKey(acc.OwnerId)){
                    acc.Manager_Sales__c = usersManagerUpdated.get(acc.OwnerId);
                }
                if(usersManagerUpdated.containsKey(acc.BizDev_Buyback__c)){
                    acc.Manager_Buyback__c = usersManagerUpdated.get(acc.BizDev_Buyback__c);
                }
            }

            try{
                logs.addLog(LogService.LOG_TYPE.INFO, LogService.PROCESS.USER_MANAGER_CHANGED, accs.keySet(), 'Update on related accounts');

                update accs.values();

                logs.addLog(LogService.LOG_TYPE.SUCCESS, LogService.PROCESS.USER_MANAGER_CHANGED, accs.keySet(), 'Update on account records success');
            }catch(DmlException e){
                logs.addLog(LogService.LOG_TYPE.ERROR, LogService.PROCESS.USER_MANAGER_CHANGED, accs.keySet(), e.getMessage());
            }catch(Exception e){
                logs.addLog(LogService.LOG_TYPE.ERROR, LogService.PROCESS.USER_MANAGER_CHANGED, accs.keySet(), e.getMessage());
            }finally{
                logs.publishLogs();
            }
        }
    }
}