/*************************************************************************************************
Created By:    Sunil Gupta
Date:          September 11, 2014
Description  : QuoteLineItem Trigger

Date           Modified By                Description
09/15/2014     Manisha Gupta              Added the logic to sync quote line items with opp line items (T-319105)
09/17/2014     Nimisha Prashant     Add before insert Trigger to sync Quote Line Item with Opportunity Line Item (T-319823)
11/24/2014     Manisha Gupta        Move base calculation to trigger handler. and put null checks for Interest rate and term.
**************************************************************************************************/
trigger QuoteLineItemTrigger on QuoteLineItem(after insert, after update, before insert,before update) {

  // Create Quote Line Item History Records.
  if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){

    if(trigger.isUpdate){
        QuoteLineItemTriggerHandler.createHistoryRecords(Trigger.newMap, Trigger.oldMap);
        // 09/15/2014 : MG : sync quote line items with opp line items (T-319105)
        system.debug('-----------OLD MAP' + trigger.oldMap);
        system.debug('-----------NEW MAP' + trigger.newMap);
        if(!QLIOLISyncManager.isSynced){
            QLIOLISyncManager.syncOppLineItems(trigger.oldMap, trigger.newMap);
        }
    }

  }
  if(trigger.isBefore ){
    QuoteLineItemTriggerHandler.calculateBase(trigger.new);
  }
  // 09/17/2014 : NP : to sync Quote Line Item's custom fields with Opportunity Line Item's fields before iinsert (T-319823)
  if(trigger.isBefore && trigger.isInsert){
    QLIOLISyncManager.syncQuoteLineItemsOnInsert(trigger.new);
  }

}