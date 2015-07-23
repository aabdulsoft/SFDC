trigger RSMManageVehicle on Vehicle__c (after Insert, before Insert, before update, after Update)
{
    if(trigger.isInsert && trigger.isBefore)
    {
        RSMManageVehicle_Helper.PopulateUnitNumber(trigger.new);
    }
    if(trigger.isUpdate && trigger.isBefore)
    {
        RSMManageVehicle_Helper.CearteTaskIfApprovedAndInDemo(trigger.new, trigger.oldMap);
    }
    else if(trigger.isUpdate && trigger.isAfter)
    {
        RSMManageVehicle_Helper.UpdateAccount(trigger.new, trigger.oldMap);
    }
    if(trigger.IsAfter && (trigger.isInsert || trigger.isUpdate))
    {
        RSMManageVehicle_Helper.UpdateAccountOnExpirationDateChange(trigger.new, trigger.oldMap);
    }
    
    // Sunil: 9/10/2014; Chatter Update On Releated Opportunities.
    //if(trigger.isAfter && trigger.isUpdate){
      //VehicleTriggerHandler.updateOppChatter(trigger.oldMap, trigger.newMap);
    //} 
         
}