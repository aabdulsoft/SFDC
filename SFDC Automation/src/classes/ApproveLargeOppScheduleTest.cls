@isTest
private Class ApproveLargeOppScheduleTest {
    static testmethod void unitTest()
    {
        Test.startTest();
        
        ApproveLargeOppBatch OppBatch = new ApproveLargeOppBatch();
        OppBatch.query='select Id, Name, Actual_Close_Date__c, AccountId, Account.Name, Approved__c, Approved_Date__c, StageName, Num_of_vehicles__c, Owner.Name, Owner.ManagerId from Opportunity where StageName =\'Booked\' and Num_of_vehicles__c >= ' + LABEL.ApproveLargeOppCount + ' and Actual_Close_Date__c > ' + LABEL.ApproveLargeOppDate + ' and Approved__c = NULL order by Actual_Close_Date__c';
        Id BatchprocessId = Database.executebatch(OppBatch);
        
        Test.StopTest();
    }
}