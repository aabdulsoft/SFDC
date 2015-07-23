global class RevenueRollupAccount implements Database.Batchable<SObject>
{
    public String query = 'Select a.Id, a.Update_Revenue__c, a.Remianing_Revenue__c, '
                            + 'a.Projected_Revenue__c From Account a where Update_Revenue__c = true';

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> lAccount)
    {
        Map<Id,List<Vehicle__c>> vMap=new Map<Id,List<Vehicle__c>>();
        Set<String> accIdset = new Set<String>();
        for(Account Acc : lAccount)
        {    
            accIdset.add(Acc.Id);             
        }
        if(accidset!=null && accidset.size()>0)
        {
            for(Vehicle__c v:[Select v.Id, v.Account__c, (Select r.Unit_Number__c, r.Remaining_Revenue__c, 
                                r.Projected_Revenu__c, r.Is_Current__c, r.Id 
                                From RSContractDetails__r r where Is_Current__c = true limit 1) 
                                From Vehicle__c v where Account__c in :accIdset]){
                if(vMap != null && vMap.get(v.Account__c) != null)
                {
                    vMap.get(v.Account__c).add(v);
                }
                else
                {
                    vMap.put(v.Account__c,new List<Vehicle__c>{v});
                }
            }
        }
        System.debug('---vMap->'+vMap);
        for(Account Acc: lAccount)
        {
            Acc.Update_Revenue__c = false;
            decimal dProjectedRevenue = 0;
            decimal dRemainingRevenue = 0;
            if(vMap != null && vMap.get(Acc.Id) != null )
            {
                for(Vehicle__c v : vMap.get(Acc.Id))
                {
                    RSM_ContractDetail__c RSContractDetail = null;                  
                    if(v.RSContractDetails__r != null && v.RSContractDetails__r.size() > 0)
                        RSContractDetail = v.RSContractDetails__r[0];
                    System.debug('---RSContractDetail->'+RSContractDetail);
                    if(RSContractDetail != Null)
                    {
                        if(RSContractDetail.Projected_Revenu__c != null)
                        {
                            dProjectedRevenue += RSContractDetail.Projected_Revenu__c;
                        }
                        if(RSContractDetail.Remaining_Revenue__c != null)
                        {
                            dRemainingRevenue += RSContractDetail.Remaining_Revenue__c;
                        }
                    }
                }
                System.debug('---dProjectedRevenue->'+dProjectedRevenue);
                System.debug('---dRemainingRevenue->'+dRemainingRevenue);
                Acc.Projected_Revenue__c = dProjectedRevenue;
                Acc.Remianing_Revenue__c = dRemainingRevenue;
            }
        }
        System.debug('---lAccount64->'+lAccount);
        update lAccount;
    }
    global void finish(Database.BatchableContext BC){
   }
}