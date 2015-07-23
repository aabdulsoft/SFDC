//Batch class to update billing status in Account if atleast one vehicle is billing
global class RSMUpdateBillingStatusBatch implements Database.Batchable<SObject>{

  public String query;
  global Database.QueryLocator start(Database.BatchableContext BC){
      System.debug('query : '+query);
      return Database.getQueryLocator(query);
   }
   
   global void execute(Database.BatchableContext BC, List<Account> scope){
      Map<Id,Account> accountMap=new Map<Id,Account>();
      Map<Id,Account> updateAccountMap=new Map<Id,Account>();
      Map<Id,List<Vehicle__c>> acctVehiclesListMap=new Map<Id,List<Vehicle__c>>();
      Set<Id> accSet=new Set<Id>();
      
      for(Account ac:scope){
          accountMap.put(ac.Id,ac);    
      } 
      
      for(Customer_Branch__c cb: [select Id,Ryder_HQ_Account__c,(select Id,RSM_Billing_Status__c from Vehicles__r) from Customer_Branch__c where Ryder_HQ_Account__c in:accountMap.keyset()]){
          if(acctVehiclesListMap!=null && acctVehiclesListMap.get(cb.Ryder_HQ_Account__c)!=null){
              acctVehiclesListMap.get(cb.Ryder_HQ_Account__c).addAll(cb.Vehicles__r);
          }else{
              List<Vehicle__c> vList=new List<Vehicle__c>();
              vList.addAll(cb.Vehicles__r);
              acctVehiclesListMap.put(cb.Ryder_HQ_Account__c,vList);    
          }
      }
      for(Account ac:scope){
          Boolean billingFlag=false;
          if(acctVehiclesListMap!=null && acctVehiclesListMap.get(ac.Id)!=null && acctVehiclesListMap.get(ac.Id).size()>0){
              for(Vehicle__c v:acctVehiclesListMap.get(ac.Id)){
                  if(v.RSM_Billing_Status__c==true){        
                      billingFlag=true;
                      break;    
                  }   
              }
          }
          Account acc=new Account(Id=ac.Id,RSM_Billing__c=billingFlag);
          updateAccountMap.put(ac.Id,acc);
      }
      if(updateAccountMap!=null && updateAccountMap.values().size()>0){
          update updateAccountMap.values();
      }
 
   }

   global void finish(Database.BatchableContext BC){
   }
}