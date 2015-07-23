trigger updateOpportunity on Opportunity (after update) {
     //mph 2/3/11 - this is no longer needed since relationship is M-D, so do not need to update ownership
    //updateOpportunityTrigger.updateSplitOwnership(trigger.newmap, trigger.oldmap);
    /*
    System.debug(LoggingLevel.INFO, '++++++++++++++++++ user logged in is ' + UserInfo.getUserId());
    if (UserInfo.getUserId() == '005P0000000QLIyIAO') {
        System.debug(LoggingLevel.INFO, '++++++++++++++++++ user logged in is piyush');
        updateOpportunityTrigger.updateParentTotals(trigger.newmap);
    }
    */
    
    // Sunil : 9/15/2014: Set Vehicle's Sold_Flag__c to true.
    if(Trigger.isAfter && Trigger.isUpdate){
      OpportunityTriggerHelper.setSoldFlagOnVehicle(Trigger.oldMap, Trigger.newMap);
    }
    
    // Sunil : 10/14/2014: Fine UVS Lead and send email to Employee.
    if(Trigger.isAfter && Trigger.isUpdate){
      OpportunityTriggerHelper.sendEmailToEmployee(Trigger.oldMap, Trigger.newMap);
    }
    
    // Albert M : 4/16/2015: Opportunity Ownershiop Validation Case Creator
    if(Trigger.isAfter && Trigger.isUpdate){
      OpportunityOwnershipValidation.CreateCasesForValidOwnership(Trigger.oldMap, Trigger.newMap);
    }
}