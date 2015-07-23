/*************************************************************************************************
Created By:    Sunil Gupta
Date:          August 25, 2014
Description  : Lead Trigger
**************************************************************************************************/
trigger LeadTrigger on Lead (after insert, after update, before insert,before update) {
  
  // Create Solution Interest record.
  if(trigger.isAfter && trigger.isInsert){
    LeadTriggerHandler.createSolutionInterest(Trigger.newMap);
  }else if(trigger.isBefore && trigger.isInsert){
    LeadTriggerHandler.updateUTC(trigger.new,null,true);
  }
  
  
  // Create Solution Interest record When Lead Owner Profile is changed.
  if(trigger.isAfter && trigger.isUpdate){
    LeadTriggerHandler.createSolutionInterestOnProfileChanged(trigger.oldMap, trigger.new, trigger.newMap);
  }else if(trigger.isBefore && trigger.isUpdate){
    LeadTriggerHandler.updateUTC(trigger.new,trigger.oldMap,true);
  }
  
  // Appirio: Lead Assignment in the case of Employee Leads.
 // if(trigger.isbefore && trigger.isInsert){
 //   LeadTriggerHandler.assignEmployeeLeads(trigger.new);
 // }
  
}