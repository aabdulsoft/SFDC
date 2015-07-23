@isTest
private class test_PW_ClosePartialWinTask {

    static testMethod void test_CloseTask()
    {
        /*Opportunity opp = new Opportunity();
        opp.Name = 'test opportunity';
        opp.Original_Decision_Maker__c = '00360000017VH3I';
        insert opp;*/
    
        Task T = new Task();
        T.OwnerId = '00560000001NgYw';
        T.WhatId = '0066000000PhB2fAAF';
        T.Orignal_Task_Date__c = System.Today();
        T.Subject = 'Subject';
        T.Description = 'Description';
        T.ActivityDate = System.Today();
        T.Status = 'Status';
        T.Priority = 'Priority';
        T.Type = 'Partial Win';
        T.Call_Attempts__c = 0;
        insert T;
        
        List<Task> currentTask = [Select Id From Task Where Type = 'Partial Win' and WhatId = :T.Id];
        
        for(Integer k =0; k<3; k++){
            Task T1 = new Task();
            T1.Id = T.Id;
            T1.Status = 'Completed';
            update T1;
        }
        
        Test.startTest();
        PW_ClosePartialWinTask.CloseTask('0066000000PhB2fAAF');
        Test.stopTest();
    }
    
}