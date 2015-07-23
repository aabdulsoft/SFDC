trigger RSMManageContractDetail on RSM_ContractDetail__c (after insert, after update)
{
    if(trigger.isAfter)
    {
        Set<String> sContractIds = new Set<String>();
        for(RSM_ContractDetail__c RSM_ContractDetail : trigger.new)
        {
            if((trigger.OldMap != null && 
                trigger.OldMap.get(RSM_ContractDetail.Id).Is_Current__c != 
                RSM_ContractDetail.Is_Current__c) || (trigger.isInsert && RSM_ContractDetail.Is_Current__c))
                sContractIds.add(RSM_ContractDetail.Contract_Number__c);
        }
        if(sContractIds.size() > 0)
        {
            Set<ID> sAccIds = new Set<ID>();
            List<RSM_Contract__c> lRSM_Contract = [Select r.Id, r.Account__c From RSM_Contract__c r where Id in: sContractIds];
            if(lRSM_Contract != null && lRSM_Contract.size() > 0)
            {
                for(RSM_Contract__c Obj : lRSM_Contract)
                    sAccIds.add(Obj.Account__c);
            }
            if(sAccIds.size() > 0)
                RSMManageContracts.updateAccount(sAccIds);
        }
    }
}