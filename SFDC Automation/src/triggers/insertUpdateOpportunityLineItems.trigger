trigger insertUpdateOpportunityLineItems on OpportunityLineItem (after insert, after update) {
    if ((Trigger.isAfter && Trigger.isInsert) || (Trigger.isAfter && Trigger.isUpdate)) {
        DealSummaryRateSheetUtil.UpdateOpportunityTotalsForOpportunityLineItems(Trigger.newMap);
    }
}