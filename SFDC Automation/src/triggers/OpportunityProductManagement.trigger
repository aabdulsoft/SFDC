/*****************************************************************************************************
Date           Modified By                  Description
09/15/2014      Manisha Gupta               Sync Related Quote Line Items with Related Opp line items
                                            whenever an oppline item is updated.(T-319111)
******************************************************************************************************/
trigger OpportunityProductManagement on OpportunityLineItem (before insert, before update, after insert, after update)
{
    if(trigger.isBefore && trigger.isUpdate)
    {
        OpportunityProductManagement_Helper.ValidateOnUpdate(trigger.new, trigger.oldMap);
        //OpportunityProductManagement_Helper.ValidateRentalOpportunityVehicleCount(trigger.new, trigger.oldMap);
    }
    else if(trigger.isBefore && trigger.isInsert)
    {
        OpportunityProductManagement_Helper.ValidateOnInsert(trigger.new);
        //OpportunityProductManagement_Helper.ValidateRentalOpportunityVehicleCount(trigger.new, null);
        QLIOLISyncManager.UpdateOLIDescriptionField(trigger.new);
        QLIOLISyncManager.syncOppLineItemsOnInsert(trigger.new);
    }
    else if(trigger.isAfter && trigger.isUpdate){
        // 09/15/2014 : MG : Sync Related Quote Line Items with Opp line items whenever an oppline item is updated.(T-319111)
        System.debug('@@@###');
        if(!QLIOLISyncManager.isSynced){
          QLIOLISyncManager.syncQuoteLineItems(trigger.oldMap, trigger.newMap);
        }
    }
    if(trigger.isAfter)
    {
    	OpportunityProductManagement_Helper.ValidateRentalOpportunityVehicleCount(trigger.new, trigger.oldMap);
    }
}