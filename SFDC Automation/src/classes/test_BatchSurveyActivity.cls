@isTest
private class test_BatchSurveyActivity{ 
    static testMethod void TestBatchSurveyActivity() { 
        
        Test.StartTest();
        
       
        // Call the Batch Apex method. 
        BatchAutoSurveyActivity bsa = new BatchAutoSurveyActivity(); 
        bsa.runTestMethod=true;    //CSI TEST
        ID batchprocessid = Database.executeBatch(bsa, 200); 
    
        Test.StopTest(); 

        AsyncApexJob async = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems from AsyncApexJob where Id = :batchprocessid]; 
        System.debug('Final results are ' + async); 
        System.AssertEquals(async.NumberOfErrors, 0); 
        
       System.abortJob(batchprocessid );
    }//close test method 

} //close test class