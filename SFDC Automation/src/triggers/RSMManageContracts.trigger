trigger RSMManageContracts on RSM_Contract__c (after insert, after update)
{
    RSMManageContracts.ManageEqipmentRequisition(trigger.new, trigger.oldMap);
    if(trigger.isAfter && trigger.isInsert)
    {
        //RSMManageContracts.AccountSendEmail(trigger.new);
    }
}