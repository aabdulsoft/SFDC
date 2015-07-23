//Batch Class to update order Status in Account from PO
global class RSMUpdateOrderStatusBatch implements Database.Batchable<SObject>{

  public String query;
  global Database.QueryLocator start(Database.BatchableContext BC){
      System.debug('query : '+query);
      return Database.getQueryLocator(query);
   }
   
   global void execute(Database.BatchableContext BC, List<RSM_PO__c> scope){
      Map<Id,Vehicle__c> updateVehicleMap=new Map<Id,Vehicle__c>();
      
      for(RSM_PO__c po:scope){
          if(po.Unit_Number__c!=null){
              Vehicle__c v=new Vehicle__c(Id=po.Unit_Number__c);  
              if(po.DateReceived__c!=null){
                  v.RSM_Order_Status__c='Received';
              }else if(po.DateShipped__c!=null){
                  v.RSM_Order_Status__c='Shipped';
              }else if(po.DateOrdered__c!=null){
                  v.RSM_Order_Status__c='Ordered';
              }  
              updateVehicleMap.put(po.Unit_Number__c,v); 
          }
      }
      if(updateVehicleMap!=null && updateVehicleMap.values().size()>0){
          update updateVehicleMap.values();
      }
 
    }

   global void finish(Database.BatchableContext BC){
   }
}