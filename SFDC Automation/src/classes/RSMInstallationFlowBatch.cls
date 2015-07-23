//Batchable Class to update 'Request for Billing' field in vehicle as part of Installation flow
global class RSMInstallationFlowBatch implements Database.Batchable<SObject>{
    
    public String query;
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('query : '+query);
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Vehicle__c> scope){
        List<Vehicle__c> vehicleList=new List<Vehicle__c>();
        Set<String> vehicleSet=new Set<String>();
      
        for(Vehicle__c veh:scope){
            veh.RSM_Request_for_Billing__c='Send to Activate Billing';
            vehicleList.add(veh);          
        } 
 
        update vehicleList;
    }

    global void finish(Database.BatchableContext BC){
    }
}