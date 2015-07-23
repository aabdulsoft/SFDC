global class ApproveLargeOppSchedule implements Schedulable {
        global void execute(SchedulableContext sc) {
        
        //Batchable class to create task for Approving Large Opportunities 
        ApproveLargeOppBatch OppBatch = new ApproveLargeOppBatch(); 
        //OppBatch.query='select Id, Name, Actual_Close_Date__c, AccountId, Account.Name, Approved__c, Approved_Date__c, StageName, Num_of_vehicles__c, Owner.Name, Owner.ManagerId from Opportunity where StageName = \'Booked\' and Num_of_vehicles__c >= ' + LABEL.ApproveLargeOppCount + ' and Actual_Close_Date__c > ' + LABEL.ApproveLargeOppDate + ' and Approved__c = NULL Order by Actual_Close_Date__c';
        OppBatch.query='select Id, Name, Actual_Close_Date__c, AccountId, Account.Name, Approved__c, Approved_Date__c, StageName, Num_of_vehicles__c, Owner.Name, Owner.ManagerId from Opportunity where Num_of_vehicles__c >= ' + LABEL.ApproveLargeOppCount + ' and Actual_Close_Date__c > ' + LABEL.ApproveLargeOppDate + ' and StageName in (' + LABEL.ApproveLargeOppStage + ') and Approved__c = NULL Order by Actual_Close_Date__c';        
        database.executebatch(OppBatch,100);
      }
}