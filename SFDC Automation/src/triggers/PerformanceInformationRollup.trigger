trigger PerformanceInformationRollup on HQ_Visit__c (before insert, before update)
{
    private Set<String> accIdset=new Set<String>();
    private List<Vehicle__c> VehList = New List<Vehicle__c>();
    private Map<Id,List<Vehicle__c>> vMap=new Map<Id,List<Vehicle__c>>();
    private Map<Id,List<Vehicle__c>> vFSLMap=new Map<Id,List<Vehicle__c>>();
    private Map<Id,List<Vehicle__c>> vRPMMap=new Map<Id,List<Vehicle__c>>();
    
    for(HQ_Visit__c HQ:trigger.new){
        accIdset.add(HQ.Company_Name__c);
    }    
    
     if(accidset!=null && accidset.size()>0){
        for(Vehicle__c v:[select Id,Account__c,PRODUCT_LINE__c,Last_12_Months_Fixed_Cost__c,
                                Last_12_Months_Rated_Cost__c,Last_12_Months_Revenue__c,Life_to_Date_Fixed_Cost__c,
                                Life_to_Date_Rated_Cost__c,Life_to_Date_Revenue__c from Vehicle__c 
                                where Account__c in :accIdset]){
            if(vMap!=null && vMap.get(v.Account__c)!=null){
                vMap.get(v.Account__c).add(v);
            }else{
                vMap.put(v.Account__c,new List<Vehicle__c>{v});
            }
            if(v.PRODUCT_LINE__c=='FSL'){
                if(vFSLMap!=null && vFSLMap.get(v.Account__c)!=null){
                    vFSLMap.get(v.Account__c).add(v);
                }else{
                    vFSLMap.put(v.Account__c,new List<Vehicle__c>{v});
                }    
            }
            
            if(v.PRODUCT_LINE__c=='RPM'){
                if(vRPMMap!=null && vRPMMap.get(v.Account__c)!=null){
                    vRPMMap.get(v.Account__c).add(v);
                }else{
                    vRPMMap.put(v.Account__c,new List<Vehicle__c>{v});
                }    
            }
        }    
    }
    
    for(HQ_Visit__c hv:trigger.new)
    {
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
        
        if(vMap!=null && vMap.get(hv.Company_Name__c)!=null){
            for(Vehicle__c v:vMap.get(hv.Company_Name__c)){
                if(v.Last_12_Months_Fixed_Cost__c==null){
                    v.Last_12_Months_Fixed_Cost__c=0;    
                }
                if(v.Last_12_Months_Revenue__c==null){
                    v.Last_12_Months_Revenue__c=0;
                }
                if(v.Life_to_Date_Fixed_Cost__c==null){
                    v.Life_to_Date_Fixed_Cost__c=0;
                }
                if(v.Life_to_Date_Revenue__c==null){
                    v.Life_to_Date_Revenue__c=0;
                }
                if(v.Life_to_Date_Rated_Cost__c==null){
                    v.Life_to_Date_Rated_Cost__c=0;
                }
                if(v.Last_12_Months_Rated_Cost__c==null){
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
        
        if(vFSLMap!=null && vFSLMap.get(hv.Company_Name__c)!=null){
            for(Vehicle__c fslv:vFSLMap.get(hv.Company_Name__c)){
                if(fslv.Last_12_Months_Fixed_Cost__c==null){
                    fslv.Last_12_Months_Fixed_Cost__c=0;    
                }
                if(fslv.Last_12_Months_Revenue__c==null){
                    fslv.Last_12_Months_Revenue__c=0;
                }
                if(fslv.Life_to_Date_Fixed_Cost__c==null){
                    fslv.Life_to_Date_Fixed_Cost__c=0;
                }
                if(fslv.Life_to_Date_Revenue__c==null){
                    fslv.Life_to_Date_Revenue__c=0;
                }
                if(fslv.Life_to_Date_Rated_Cost__c==null){
                    fslv.Life_to_Date_Rated_Cost__c=0;
                }
                if(fslv.Last_12_Months_Rated_Cost__c==null){
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
        
        if(vRPMMap!=null && vRPMMap.get(hv.Company_Name__c)!=null){
            for(Vehicle__c rpmv:vRPMMap.get(hv.Company_Name__c)){
                if(rpmv.Last_12_Months_Fixed_Cost__c==null){
                    rpmv.Last_12_Months_Fixed_Cost__c=0;    
                }
                if(rpmv.Last_12_Months_Revenue__c==null){
                    rpmv.Last_12_Months_Revenue__c=0;
                }
                if(rpmv.Life_to_Date_Fixed_Cost__c==null){
                    rpmv.Life_to_Date_Fixed_Cost__c=0;
                }
                if(rpmv.Life_to_Date_Revenue__c==null){
                    rpmv.Life_to_Date_Revenue__c=0;
                }
                if(rpmv.Life_to_Date_Rated_Cost__c==null){
                    rpmv.Life_to_Date_Rated_Cost__c=0;
                }
                if(rpmv.Last_12_Months_Rated_Cost__c==null){
                    rpmv.Last_12_Months_Rated_Cost__c=0;
                }

                RPMlast12MonthsFixedCost=RPMlast12MonthsFixedCost+rpmv.Last_12_Months_Fixed_Cost__c;
                RPMlast12MonthsRevenue=RPMlast12MonthsRevenue+rpmv.Last_12_Months_Revenue__c;
                RPMlast12MonthsRatedCost=RPMlast12MonthsRatedCost+rpmv.Last_12_Months_Rated_Cost__c;
                RPMlifeToDateFixedCost=RPMlifeToDateFixedCost+rpmv.Life_to_Date_Fixed_Cost__c; 
                RPMlifeToDateRevenue=RPMlifeToDateRevenue+rpmv.Life_to_Date_Revenue__c; 
                RPMlifeToDateRatedCost=RPMlifeToDateRatedCost+rpmv.Life_to_Date_Rated_Cost__c;   
            }
        }
                
        hv.Last_12_Months_Fixed_Cost__c = last12MonthsFixedCost;
        hv.Last_12_Months_Revenue__c = last12MonthsRevenue;
        hv.Last_12_Months_Rated_Cost__c = last12MonthsRatedCost;
        hv.Life_to_Date_Fixed_Cost__c = lifeToDateFixedCost;
        hv.Life_to_Date_Revenue__c = lifeToDateRevenue;
        hv.Life_to_Date_Rated_Cost__c = lifeToDateRatedCost;
        
        hv.FSL_Last_12_Months_Fixed_Cost__c = FSLlast12MonthsFixedCost;
        hv.FSL_Last_12_Months_Revenue__c = FSLlast12MonthsRevenue;
        hv.FSL_Last_12_Months_Rated_Cost__c = FSLlast12MonthsRatedCost;
        hv.FSL_Life_to_Date_Fixed_Cost__c = FSLlifeToDateFixedCost; 
        hv.FSL_Life_to_Date_Revenue__c = FSLlifeToDateRevenue; 
        hv.FSL_Life_to_Date_Rated_Cost__c = FSLlifeToDateRatedCost;
        
        hv.RPM_Last_12_Months_Fixed_Cost__c = RPMlast12MonthsFixedCost;
        hv.RPM_Last_12_Months_Revenue__c = RPMlast12MonthsRevenue;
        hv.RPM_Last_12_Months_Rated_Cost__c = RPMlast12MonthsRatedCost;
        hv.RPM_Life_to_Date_Fixed_Cost__c = RPMlifeToDateFixedCost; 
        hv.RPM_Life_to_Date_Revenue__c = RPMlifeToDateRevenue; 
        hv.RPM_Life_to_Date_Rated_Cost__c = RPMlifeToDateRatedCost;
        
    }
}