//Baatch class to update Revenue in the account object from contract object
global class RSMUpdateAccountRevenueBatch implements Database.Batchable<SObject>{

   public String query;
   global Database.QueryLocator start(Database.BatchableContext BC){
      System.debug('query : '+query);
      return Database.getQueryLocator(query);
   } 
   
   global void execute(Database.BatchableContext BC, List<Account> scope){
      Map<Id,Account> accountMap=new Map<Id,Account>();
      List<Account> updateAccLst=new List<Account>();
            
      Map<Id,Double> accVehRevMap=new Map<Id,Double>();
      for(Account ac:scope){
          accountMap.put(ac.Id,ac);    
      } 
      //List<Customer_Branch__c> cbList=[select Id,Ryder_HQ_Account__c,(select Id,RSM_Billing_Status__c from Vehicles__r) from Customer_Branch__c where Ryder_HQ_Account__c in:accountMap.keyset()];    
      Set<Id> vehIds=new Set<Id>();
      
      for(Customer_Branch__c cb: [select Id,Ryder_HQ_Account__c,(select Id,RSM_Billing_Status__c from Vehicles__r) from Customer_Branch__c where Ryder_HQ_Account__c in:accountMap.keyset()]){
          for(Vehicle__c v:cb.Vehicles__r){
             vehIds.add(v.Id); 
          }
      }
      for(RSM_ContractDetail__c rc:[select Id,rate__c,Is_Current__c,Unit_Number__c,Unit_Number__r.Account__c from RSM_ContractDetail__c where Unit_Number__c in :vehIds and Is_Current__c=true]){
          if(accVehRevMap!=null && accVehRevMap.get(rc.Unit_Number__r.Account__c)!=null){
              accVehRevMap.put(rc.Unit_Number__r.Account__c,rc.rate__c+accVehRevMap.get(rc.Unit_Number__r.Account__c));
          }else{
               accVehRevMap.put(rc.Unit_Number__r.Account__c,rc.rate__c);
          }    
      }
      
      for(Id acId:accVehRevMap.keyset()){
          Account ac=new Account(Id=acId,RSM_Revenue__c=accVehRevMap.get(acId));
          updateAccLst.add(ac);    
      }
      if(updateAccLst!=null && updateAccLst.size()>0){
          update updateAccLst;
      }
 
   }

   global void finish(Database.BatchableContext BC){
   }
}