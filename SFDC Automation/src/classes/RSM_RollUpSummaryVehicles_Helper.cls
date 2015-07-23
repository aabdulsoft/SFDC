public with sharing class RSM_RollUpSummaryVehicles_Helper
{
	public Static void ProcessVehicleHistory(List<Vehicle__History> scope)
	{
		String sRSMValue = 'Approved';
        Set<String> sAccIds = new Set<String>();
        for(Vehicle__History vehcle : scope)
        {
            sAccIds.add(vehcle.Parent.Account__c);            
        }
        if(Test.isRunningTest())
        {
        	Set<ID> sVehIds = new Set<ID>();
        	for(Vehicle__History vehcle : scope)
        		sVehIds.add(vehcle.ParentId);
        	if(sVehIds.size() > 0)
        	{
        		List<Vehicle__c> lVeh = [Select Account__c from Vehicle__c where Id in: sVehIds];
        		for(Vehicle__c Veh : lVeh)
        			sAccIds.add(Veh.Account__c);  
        	}
        }
        
        if(sAccIds.size() > 0)
        {
            List<Account> lAccount = [select Id, RSM_Plus1_Total_Unit__c, RSM_Plus_Total_Unit__c, RSM_Account_Status__c,  
                                            RSM_STD_Total_Unit__c from Account where Id IN : sAccIds];
            if(lAccount != null && lAccount.size() > 0)
            {
                List<vehicle__c> lVehicle = [select Id, RSM__c, RSM_Service_Level__c, Account__c 
                                                from vehicle__c where RSM__c =: sRSMValue and 
                                                Account__c in : sAccIds];
                for(Account Acc : lAccount)
                {
                    if(lVehicle != null && lVehicle.size() > 0)
                    {                   
                        Boolean IsChanged = false;
                        Integer iPlus1 = 0;
                        Integer iPlus = 0;
                        Integer iStd = 0;
                        for(vehicle__c Vehcle : lVehicle)
                        {
                            if(Acc.Id == Vehcle.Account__c)
                            {
                                if(Vehcle.RSM_Service_Level__c == 'Plus 1')
                                {
                                    iPlus1++;
                                    IsChanged = true;
                                }
                                if(Vehcle.RSM_Service_Level__c == 'Plus')
                                {
                                    IsChanged = true;
                                    iPlus++;
                                }
                                if(Vehcle.RSM_Service_Level__c == 'STD')
                                {
                                    IsChanged = true;
                                    iStd++;
                                }
                            }
                        }
                        Acc.RSM_Plus1_Total_Unit__c = iPlus1;
                        Acc.RSM_Plus_Total_Unit__c = iPlus;
                        Acc.RSM_STD_Total_Unit__c = iStd;
                        if(IsChanged)
                        {
                            Acc.RSM_Account_Status__c = 'Customer';
                        }
                        else
                        {
                        	Acc.RSM_Account_Status__c = 'Prospect';
                        }
                    }
                    else
                        Acc.RSM_Account_Status__c = 'Prospect';
                }       
                update lAccount;    
            }
        } 
	}
}