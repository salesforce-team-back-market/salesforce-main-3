/**
 * @description       : Used to schedule the delete duplicated contacts batch
 * @author            : Martin Lezer
 * @group             : Schedulable
 * @last modified on  : 11-04-2022
 * @last modified by  : Martin Lezer
**/
global class DeleteDuplicatedContactsSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        DeleteDuplicatedContactsBatch b = new DeleteDuplicatedContactsBatch(); 
        database.executebatch(b);
    }
 }