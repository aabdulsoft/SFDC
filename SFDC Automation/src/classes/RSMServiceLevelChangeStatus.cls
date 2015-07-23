//Batch class to calculate the vehicle is Upgraded or Downgraded based on the Service level change and Additional service level
global class RSMServiceLevelChangeStatus implements Database.Batchable<SObject>{
    
    public String query;
    global Database.QueryLocator start(Database.BatchableContext BC){
          return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<RSM_ContractDetail__c> scope){
        
        Map<id,Vehicle__c> updateVehicleMap=new Map<id,Vehicle__c>();
        boolean clearVal = false;
             
        for(RSM_ContractDetail__c cd:scope){
        
            clearVal = false;
        
            if(cd.Action_Name__c != 'Cancel'){

                if(cd.Unit_Number__r.Account__c == cd.Contract_Number__r.Account__c){
    
                    if(cd.Unit_Number__r.RSM_Service_Level_Prior_value__c!=null && cd.Unit_Number__r.RSM_Service_Level__c!=cd.Unit_Number__r.RSM_Service_Level_Prior_value__c){
    
                        if(cd.Unit_Number__r.RSM_Service_Level__c=='Plus 1' && cd.Unit_Number__r.RSM_Service_Level_Prior_value__c=='Plus'){
    
                            Vehicle__c v = new Vehicle__c(Id=cd.Unit_Number__r.id,RSM_Service_Level_Change__c='Upgrade',RSM_Service_level_Change_Date__c=System.today());
                            updateVehicleMap.put(cd.Unit_Number__r.id,v);       
                            
                        }else if(cd.Unit_Number__r.RSM_Service_Level__c=='Plus 1' && cd.Unit_Number__r.RSM_Service_Level_Prior_value__c=='STD'){
    
                            Vehicle__c v = new Vehicle__c(Id=cd.Unit_Number__r.id,RSM_Service_Level_Change__c='Upgrade',RSM_Service_level_Change_Date__c=System.today());
                            updateVehicleMap.put(cd.Unit_Number__r.id,v);
                            
                        }else if(cd.Unit_Number__r.RSM_Service_Level__c=='Plus' && cd.Unit_Number__r.RSM_Service_Level_Prior_value__c=='STD'){
    
                            Vehicle__c v = new Vehicle__c(Id=cd.Unit_Number__r.id,RSM_Service_Level_Change__c='Upgrade',RSM_Service_level_Change_Date__c=System.today());
                            updateVehicleMap.put(cd.Unit_Number__r.id,v);
                            
                        }else if(cd.Unit_Number__r.RSM_Service_Level__c=='Plus' && cd.Unit_Number__r.RSM_Service_Level_Prior_value__c=='Plus 1'){
    
                            Vehicle__c v = new Vehicle__c(Id=cd.Unit_Number__r.id,RSM_Service_Level_Change__c='Downgrade',RSM_Service_level_Change_Date__c=System.today());
                            updateVehicleMap.put(cd.Unit_Number__r.id,v);
                            
                        }else if(cd.Unit_Number__r.RSM_Service_Level__c=='STD' && cd.Unit_Number__r.RSM_Service_Level_Prior_value__c=='Plus'){
    
                            Vehicle__c v = new Vehicle__c(Id=cd.Unit_Number__r.id,RSM_Service_Level_Change__c='Downgrade',RSM_Service_level_Change_Date__c=System.today());
                            updateVehicleMap.put(cd.Unit_Number__r.id,v);
                            
                        } else if(cd.Unit_Number__r.RSM_Service_Level__c=='STD' && cd.Unit_Number__r.RSM_Service_Level_Prior_value__c=='Plus 1'){
    
                            Vehicle__c v = new Vehicle__c(Id=cd.Unit_Number__r.id,RSM_Service_Level_Change__c='Downgrade',RSM_Service_level_Change_Date__c=System.today());
                            updateVehicleMap.put(cd.Unit_Number__r.id,v);
                        }     
                    }
                    else if(cd.Unit_Number__r.RSM_Add_Service_current_count__c>=0 && cd.Unit_Number__r.RSM_Addition_Service_prior_count__c>=0 && cd.Unit_Number__r.RSM_Add_Service_current_count__c!=cd.Unit_Number__r.RSM_Addition_Service_prior_count__c){
    
                        if(cd.Unit_Number__r.RSM_Add_Service_current_count__c > cd.Unit_Number__r.RSM_Addition_Service_prior_count__c){
    
                            Vehicle__c v = new Vehicle__c(Id=cd.Unit_Number__r.id,RSM_Service_Level_Change__c='Upgrade',RSM_Service_level_Change_Date__c=System.today());
                            updateVehicleMap.put(cd.Unit_Number__r.id,v);                               
                        }
                        else if(cd.Unit_Number__r.RSM_Add_Service_current_count__c < cd.Unit_Number__r.RSM_Addition_Service_prior_count__c){
    
                            Vehicle__c v = new Vehicle__c(Id=cd.Unit_Number__r.id,RSM_Service_Level_Change__c='Downgrade',RSM_Service_level_Change_Date__c=System.today());
                            updateVehicleMap.put(cd.Unit_Number__r.id,v);
                        }
                    }
                }
                else
                {
                    clearVal = true;
                }
            }
            else
            {
                clearVal = true;
            }
            if (clearVal == true)
            {
                //Note: Not able to update the RSM_Add_Service_current_count__c count as it is a formula field. Either we should upload 
                Vehicle__c v = new Vehicle__c(Id=cd.Unit_Number__r.id,RSM_Additional_Services__c='',RSM_Service_Level_Change__c='',RSM_Service_level_Change_Date__c=NULL,RSM_Addition_Service_prior_count__c=0);
                updateVehicleMap.put(cd.Unit_Number__r.id,v);       
            }         
        }
        update updateVehicleMap.values();
    }
    
    global void finish(Database.BatchableContext BC){
    }
}