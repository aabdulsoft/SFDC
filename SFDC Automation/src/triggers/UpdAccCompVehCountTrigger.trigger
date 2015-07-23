/*
* 
*   Trigger to update the count of competitive vehicles on account
*
*   Author           |Author-Email                      |Date       |Comment
*   -----------------|----------------------------------|-----------|--------------------------------------------------
*   Saad Wali Jaan   |                                  |05.01.2015 |First draft
*
*/

trigger UpdAccCompVehCountTrigger on Competitor_Vehicle__c (after insert, after update, after delete) {
    
    system.debug('UpdAcc0.0');
    if (trigger.isInsert || trigger.isUpdate)
    {
        system.debug('UpdAcc0.1');
        UpdAccCompVehCountTriggerHelper.UpdateAccount(Trigger.new, trigger.oldMap);
    }
    if (trigger.isdelete)
    {
        system.debug('UpdAcc0.2');
        UpdAccCompVehCountTriggerHelper.UpdateAccountAfterDelete(Trigger.new, trigger.oldMap);
    }
}