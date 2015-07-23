/*************************************************************************************************
Created By:    Sunil Gupta
Date:          Sept 20, 2014
Description:   Quote Trigger
**************************************************************************************************/
trigger QuoteTrigger on Quote(before insert, after update) {
  // Hari Krishnan (12/29/2014): Added code to update UTC in Quote.
  if(trigger.isBefore && trigger.isInsert)
      QuoteTriggerHandler.updateUTC(trigger.new);
  // Insert BTR records and submit for approval
  if(trigger.isAfter && trigger.isUpdate){
    //QuoteTriggerHandler.createBTRApprovalProcess(trigger.oldMap, trigger.newMap);
    //Method added by Virendra
    QuoteTriggerHandler.SysnLIsBeforeUpdate(trigger.new,trigger.oldMap);
  }
  
 
  
}