global with sharing class AccountFSLRPMFieldCalculationBatch implements Database.Batchable<SObject>
{
	public String query = 'select Id, FSL_Last_12_Months_Fixed_Cost__c, '
						+ 'FSL_Last_12_Months_Rated_Cost__c, FSL_Life_to_Date_Fixed_Cost__c, '
						+ 'FSL_Life_to_Date_Rated_Cost__c, Last_12_months_FSL_revenue__c, '
						+ 'FSL_Life_to_Date_Revenue__c, Last_12_Months_Fixed_Cost__c, '
						+ 'Last_12_Months_Rated_Cost__c, Last_12_Months_Revenue__c, '
						+ 'Life_to_Date_Fixed_Cost__c, Life_to_Date_Rated_Cost__c, '
						+ 'Life_to_Date_Revenue__c, RPM_Last_12_Months_Fixed_Cost__c, '
						+ 'RPM_Last_12_Months_Rated_Cost__c, RPM_Last_12_Months_Revenue__c, '
						+ 'RPM_Life_to_Date_Fixed_Cost__c, RPM_Life_to_Date_Revenue__c, '
						+ 'RPM_Life_to_Date_Rated_Cost__c from Account where '
						+ 'UpdatedFSLRPMFields__c = true';
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<Account> lAccount)
	{
		Map<Id,List<Vehicle__c>> vMap=new Map<Id,List<Vehicle__c>>();
    	Map<Id,List<Vehicle__c>> vFSLMap=new Map<Id,List<Vehicle__c>>();
    	Map<Id,List<Vehicle__c>> vRPMMap=new Map<Id,List<Vehicle__c>>();
		Set<String> accIdset = new Set<String>();
		for(Account Acc : lAccount)
		{    
	    	accIdset.add(Acc.Id);	          
	    }
		if(accidset!=null && accidset.size()>0)
		{
	        for(Vehicle__c v:[select Id,Account__c,PRODUCT_LINE__c,Last_12_Months_Fixed_Cost__c,
	        						Last_12_Months_Rated_Cost__c,Last_12_Months_Revenue__c,Life_to_Date_Fixed_Cost__c,
	        						Life_to_Date_Rated_Cost__c,Life_to_Date_Revenue__c from Vehicle__c 
	        						where Account__c in :accIdset]){
	            if(vMap!=null && vMap.get(v.Account__c) != null){
	                vMap.get(v.Account__c).add(v);
	            }else{
	                vMap.put(v.Account__c,new List<Vehicle__c>{v});
	            }
	            if(v.PRODUCT_LINE__c != null && v.PRODUCT_LINE__c == 'FSL'){
	                if(vFSLMap!=null && vFSLMap.get(v.Account__c) != null){
	                    vFSLMap.get(v.Account__c).add(v);
	                }else{
	                    vFSLMap.put(v.Account__c,new List<Vehicle__c>{v});
	                }
	            }
	            
	            if(v.PRODUCT_LINE__c != null && v.PRODUCT_LINE__c == 'RPM'){
	                if(vRPMMap!=null && vRPMMap.get(v.Account__c) != null){
	                    vRPMMap.get(v.Account__c).add(v);
	                }else{
	                    vRPMMap.put(v.Account__c,new List<Vehicle__c>{v});
	                }    
	            }
	        }    
	    }
	    System.debug('Nitin---vMap->'+vMap);
	    System.debug('Nitin---vFSLMap->'+vFSLMap);
	    System.debug('Nitin---vRPMMap->'+vRPMMap);
	    for(Account Acc: lAccount)
	    {
	    	Acc.UpdatedFSLRPMFields__c = false;
	        Decimal last12MonthsFixedCost=0;
	        Decimal last12MonthsRevenue=0;
	        Decimal last12MonthsRatedCost=0;
	        Decimal lifeToDateFixedCost=0;
	        Decimal lifeToDateRevenue=0;
	        Decimal lifeToDateRatedCost=0;
	        
	        Decimal FSLlast12MonthsFixedCost=0;
	        Decimal FSLlast12MonthsRevenue=0;
	        Decimal FSLlast12MonthsRatedCost=0;
	        Decimal FSLlifeToDateFixedCost=0;
	        Decimal FSLlifeToDateRevenue=0;
	        Decimal FSLlifeToDateRatedCost=0;
	        
	        Decimal RPMlast12MonthsFixedCost=0;
	        Decimal RPMlast12MonthsRevenue=0;
	        Decimal RPMlast12MonthsRatedCost=0;
	        Decimal RPMlifeToDateFixedCost=0;
	        Decimal RPMlifeToDateRevenue=0;
	        Decimal RPMlifeToDateRatedCost=0;        
	        
	        if(vMap!=null && vMap.get(Acc.Id) !=null )
	        {
	            for(Vehicle__c v : vMap.get(Acc.Id))
	            {
	                if(v.Last_12_Months_Fixed_Cost__c == null){
	                    v.Last_12_Months_Fixed_Cost__c=0;    
	                }
	                if(v.Last_12_Months_Revenue__c == null){
	                    v.Last_12_Months_Revenue__c=0;
	                }
	                if(v.Life_to_Date_Fixed_Cost__c == null){
	                    v.Life_to_Date_Fixed_Cost__c=0;
	                }
	                if(v.Life_to_Date_Revenue__c == null){
	                    v.Life_to_Date_Revenue__c=0;
	                }
	                if(v.Life_to_Date_Rated_Cost__c == null){
	                    v.Life_to_Date_Rated_Cost__c=0;
	                }
	                if(v.Last_12_Months_Rated_Cost__c == null){
	                    v.Last_12_Months_Rated_Cost__c=0;
	                }
	                last12MonthsFixedCost=last12MonthsFixedCost+v.Last_12_Months_Fixed_Cost__c;
	                last12MonthsRevenue=last12MonthsRevenue+v.Last_12_Months_Revenue__c;
	                last12MonthsRatedCost=last12MonthsRatedCost+v.Last_12_Months_Rated_Cost__c;
	                lifeToDateFixedCost=lifeToDateFixedCost+v.Life_to_Date_Fixed_Cost__c; 
	                lifeToDateRevenue=lifeToDateRevenue+v.Life_to_Date_Revenue__c; 
	                lifeToDateRatedCost=lifeToDateRatedCost+v.Life_to_Date_Rated_Cost__c;   
	            }
	        }
	        
	        if(vFSLMap!=null && vFSLMap.get(Acc.Id)!=null)
	        {
	            for(Vehicle__c fslv:vFSLMap.get(Acc.Id))
	            {
	                if(fslv.Last_12_Months_Fixed_Cost__c == null){
	                    fslv.Last_12_Months_Fixed_Cost__c=0;    
	                }
	                if(fslv.Last_12_Months_Revenue__c == null){
	                    fslv.Last_12_Months_Revenue__c=0;
	                }
	                if(fslv.Life_to_Date_Fixed_Cost__c == null){
	                    fslv.Life_to_Date_Fixed_Cost__c=0;
	                }
	                if(fslv.Life_to_Date_Revenue__c == null){
	                    fslv.Life_to_Date_Revenue__c=0;
	                }
	                if(fslv.Life_to_Date_Rated_Cost__c == null){
	                    fslv.Life_to_Date_Rated_Cost__c=0;
	                }
	                if(fslv.Last_12_Months_Rated_Cost__c == null){
	                    fslv.Last_12_Months_Rated_Cost__c=0;
	                }
	                FSLlast12MonthsFixedCost=FSLlast12MonthsFixedCost+fslv.Last_12_Months_Fixed_Cost__c;
	                FSLlast12MonthsRevenue=FSLlast12MonthsRevenue+fslv.Last_12_Months_Revenue__c;
	                FSLlast12MonthsRatedCost=FSLlast12MonthsRatedCost+fslv.Last_12_Months_Rated_Cost__c;
	                FSLlifeToDateFixedCost=FSLlifeToDateFixedCost+fslv.Life_to_Date_Fixed_Cost__c; 
	                FSLlifeToDateRevenue=FSLlifeToDateRevenue+fslv.Life_to_Date_Revenue__c; 
	                FSLlifeToDateRatedCost=FSLlifeToDateRatedCost+fslv.Life_to_Date_Rated_Cost__c;   
	            } 
	        }
	        
	        if(vRPMMap!=null && vRPMMap.get(Acc.Id)!=null)
	        {
	            for(Vehicle__c rpmv:vRPMMap.get(Acc.Id))
	            {
	                if(rpmv.Last_12_Months_Fixed_Cost__c == null){
	                    rpmv.Last_12_Months_Fixed_Cost__c=0;    
	                }
	                if(rpmv.Last_12_Months_Revenue__c == null){
	                    rpmv.Last_12_Months_Revenue__c=0;
	                }
	                if(rpmv.Life_to_Date_Fixed_Cost__c == null){
	                    rpmv.Life_to_Date_Fixed_Cost__c=0;
	                }
	                if(rpmv.Life_to_Date_Revenue__c == null){
	                    rpmv.Life_to_Date_Revenue__c=0;
	                }
	                if(rpmv.Life_to_Date_Rated_Cost__c == null){
	                    rpmv.Life_to_Date_Rated_Cost__c=0;
	                }
	                if(rpmv.Last_12_Months_Rated_Cost__c == null){
	                    rpmv.Last_12_Months_Rated_Cost__c=0;
	                }
	
	                RPMlast12MonthsFixedCost = RPMlast12MonthsFixedCost+rpmv.Last_12_Months_Fixed_Cost__c;
	                RPMlast12MonthsRevenue = RPMlast12MonthsRevenue+rpmv.Last_12_Months_Revenue__c;
	                RPMlast12MonthsRatedCost = RPMlast12MonthsRatedCost+rpmv.Last_12_Months_Rated_Cost__c;
	                RPMlifeToDateFixedCost = RPMlifeToDateFixedCost+rpmv.Life_to_Date_Fixed_Cost__c; 
	                RPMlifeToDateRevenue = RPMlifeToDateRevenue+rpmv.Life_to_Date_Revenue__c; 
	                RPMlifeToDateRatedCost = RPMlifeToDateRatedCost+rpmv.Life_to_Date_Rated_Cost__c;   
	            }
	        }
	                
	        Acc.Last_12_Months_Fixed_Cost__c = last12MonthsFixedCost;
	        Acc.Last_12_Months_Revenue__c = last12MonthsRevenue;
	        Acc.Last_12_Months_Rated_Cost__c = last12MonthsRatedCost;
	        Acc.Life_to_Date_Fixed_Cost__c = lifeToDateFixedCost;
	        Acc.Life_to_Date_Revenue__c = lifeToDateRevenue;
	        Acc.Life_to_Date_Rated_Cost__c = lifeToDateRatedCost;
	        
	        Acc.FSL_Last_12_Months_Fixed_Cost__c = FSLlast12MonthsFixedCost;
	        Acc.Last_12_months_FSL_revenue__c = FSLlast12MonthsRevenue;
	        Acc.FSL_Last_12_Months_Rated_Cost__c = FSLlast12MonthsRatedCost;
	        Acc.FSL_Life_to_Date_Fixed_Cost__c = FSLlifeToDateFixedCost; 
	        Acc.FSL_Life_to_Date_Revenue__c = FSLlifeToDateRevenue; 
	        Acc.FSL_Life_to_Date_Rated_Cost__c = FSLlifeToDateRatedCost;
	        
	        Acc.RPM_Last_12_Months_Fixed_Cost__c = RPMlast12MonthsFixedCost;
	        Acc.RPM_Last_12_Months_Revenue__c = RPMlast12MonthsRevenue;
	        Acc.RPM_Last_12_Months_Rated_Cost__c = RPMlast12MonthsRatedCost;
	        Acc.RPM_Life_to_Date_Fixed_Cost__c = RPMlifeToDateFixedCost; 
	        Acc.RPM_Life_to_Date_Revenue__c = RPMlifeToDateRevenue;
	        Acc.RPM_Life_to_Date_Rated_Cost__c = RPMlifeToDateRatedCost;
	    }
	    System.debug('Nitin---lAccount201->'+lAccount);
	    update lAccount;
	}
	global void finish(Database.BatchableContext BC){
   }
}