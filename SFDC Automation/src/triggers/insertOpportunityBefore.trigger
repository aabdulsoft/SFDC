trigger insertOpportunityBefore on Opportunity (before insert) {
// Start - Hari Krishnan(12/29/2014): Added logic to populate UTC_Assigned__c.
    OpportunityTriggerHelper.updateUTC(Trigger.new);
    // End - Hari Krishnan(12/29/2014)
for(Opportunity o : Trigger.New )
  {
    if(o.Assign_To__c != null)
    o.OwnerId=o.Assign_To__c;
  }

}