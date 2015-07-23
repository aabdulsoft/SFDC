/*************************************************************************************************
Created By:    Sunil Gupta
Date:          Sept 25, 2014
Description:   BTR Trigger
**************************************************************************************************/
trigger BTRTrigger on BTR__c(after update) {
  
  // Change status of Related Quote record when BTR status is changed to closed.
  if(trigger.isAfter && trigger.isUpdate){
    BTRTriggerHandler.updateQuoteSatusToApproved(trigger.oldMap, trigger.newMap);
  }
  
 
  
}