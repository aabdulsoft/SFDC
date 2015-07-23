trigger insertUpdateRateSheet on Rate_Sheet__c (after insert, after update) {
    if ((Trigger.isAfter && Trigger.isInsert) || (Trigger.isAfter && Trigger.isUpdate)) {
    	if (!UserInfo.getUserName().contains(RyderConfig__c.getOrgDefaults().ETL_Username__c))
        	DealSummaryRateSheetUtil.UpdateOpportunityTotalsForRateSheet(Trigger.newMap);
    }
}