trigger OpportunityManagement on Opportunity (before insert, after insert, before update, after update)
{
    // 10/19/2014 : MG : Price Book must be set on Opportunity creation as well. That's why adding before insert operation.
    if(trigger.isBefore && trigger.isInsert){
        OpportunityManagement_Helper.SetOpportunityDefaultPriceBook(trigger.new);
        OpportunityManagement_Helper.SynchronizeMissingCustProspect(trigger.new);
    }
    else if(trigger.isBefore && trigger.isUpdate)
    {
        OpportunityManagement_Helper.ManageOwnership(trigger.new, trigger.oldMap);        
    }
    else if(trigger.isAfter && trigger.isInsert)
    {
        OpportunityManagement_Helper.ManageOwnership(trigger.new, trigger.oldMap);
    }
}