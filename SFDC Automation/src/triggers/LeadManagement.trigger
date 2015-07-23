trigger LeadManagement on Lead (after insert, after update)
{
    if(trigger.isAfter)
    {
        LeadManagement_Helper.ManageLeadOwner(trigger.new, trigger.oldMap);
    }
}