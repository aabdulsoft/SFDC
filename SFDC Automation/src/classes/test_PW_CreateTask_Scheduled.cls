@isTest
Private Class test_PW_CreateTask_Scheduled{
    static testmethod void unitTest(){
    Test.startTest();
    
    PW_CreateTask ruvb = new PW_CreateTask();
    //ruvb.query='SELECT Opportunity__c FROM PartialWinRateSheet__c WHERE CreatedDate = TODAY AND IsProcessed__c = false GROUP BY Opportunity__c';  
    Database.executeBatch(ruvb);
        
    PW_CreateTask_Scheduled Sb1 = new PW_CreateTask_Scheduled();
    SchedulableContext scq;
    Sb1.execute(scq);  
    
    Test.StopTest();
    }
}