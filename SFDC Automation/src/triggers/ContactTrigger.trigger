/*************************************************************************************************
Created By:    Sunil Gupta
Date:          August 28, 2014
Description  : Contact Trigger
**************************************************************************************************/
trigger ContactTrigger on Contact(after insert, after update) {
  
  // Create Solution Interest record.
  if(trigger.isAfter && trigger.isInsert){
    ContactTriggerHandler.createSolutionInterest(Trigger.newMap);
  }
  
 
  
}