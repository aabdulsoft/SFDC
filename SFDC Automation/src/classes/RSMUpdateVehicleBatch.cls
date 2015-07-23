//Batch Class to update fields RS Customer, Service level & RS contract Status in vehicle page
global class RSMUpdateVehicleBatch implements Database.Batchable<SObject>{

  public String query;
  global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }
   
   global void execute(Database.BatchableContext BC, List<RSM_ContractDetail__c> scope){

      boolean clearVal = false;
      Set<String> vehicleSet=new Set<String>();
      Map<String,Vehicle__c> vehicleMap=new Map<String,Vehicle__c>();
      Map<String,Vehicle__c> updateVehicleMap=new Map<String,Vehicle__c>();
      for(RSM_ContractDetail__c cd:scope){    
          vehicleSet.add(cd.Unit_Number__c); 
      }
      List<Vehicle__c> lstVehicle=[select Id,Unit__c from Vehicle__c where Id in:vehicleSet ];
      for(Vehicle__c  v: lstVehicle){     
          vehicleMap.put(v.Id,v);
      }    
     
      for(RSM_ContractDetail__c cd:scope){
          clearVal = false;
          system.debug('Saad 1 cd.Unit_Number__r.id = ' + cd.Unit_Number__c);
          if(cd.Action_Name__c != 'Cancel'){
            system.debug('Saad 2');          
              if(cd.Unit_Number__r.Account__c == cd.Contract_Number__r.Account__c)
              {
                  system.debug('Saad 3');
                  If(cd.Is_Current__c == true)
                  {
                      system.debug('Saad 4 cd.Service_Name__c = '+cd.Service_Name__c);
                      //Vehicle__c v=new Vehicle__c(Id=vehicleMap.get(cd.Unit_Number__c).Id,RSM_Customer__c=true,RSM_Service_Level__c=cd.Service_Name__c,RSM__c=cd.Contract_Number__r.Status_Name__c);
                      Vehicle__c v=new Vehicle__c(Id=cd.Unit_Number__r.id, RSM_Customer__c=true, RSM_Service_Level__c=cd.Service_Name__c,RSM__c=cd.Contract_Number__r.Status_Name__c);
                      updateVehicleMap.put(v.Id,v);
                  }
              }
              else
              {
                  system.debug('Saad 5');
                  clearVal = true;
              }
          } 
          else
          {
              system.debug('Saad 6');
              If(cd.Is_Current__c == true)
              {
                  system.debug('Saad 7');              
                  clearVal = true;
              }
          }
          if (clearVal == true)
          {
              system.debug('Saad 8');
              //Vehicle__c v=new Vehicle__c(Id=vehicleMap.get(cd.Unit_Number__c).Id,RSM_Customer__c=false,RSM_Service_Level__c='',RSM_Service_Level_Prior_value__c='',RSM__c=cd.Contract_Number__r.Status_Name__c,RSM_Additional_Services__c='',RSM_Service_Level_Change__c='',RSM_Service_level_Change_Date__c=NULL,RSM_Addition_Service_prior_count__c=0);
              Vehicle__c v=new Vehicle__c(Id=cd.Unit_Number__r.id,RSM_Customer__c=false,RSM_Service_Level__c='',RSM_Service_Level_Prior_value__c='',RSM__c=cd.Contract_Number__r.Status_Name__c,RSM_Additional_Services__c='',RSM_Service_Level_Change__c='',RSM_Service_level_Change_Date__c=NULL,RSM_Addition_Service_prior_count__c=0);
              
              updateVehicleMap.put(v.Id,v);
          }
     }
     system.debug('Saad 9');
     update updateVehicleMap.values();
     system.debug('Saad 10');     
   }

   global void finish(Database.BatchableContext BC){
   }
}