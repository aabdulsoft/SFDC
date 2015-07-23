@isTest
private class test_BatchAutoSurveyActivity{ 
static testMethod void TestBatchAutoSurveyActivity() { 

        Task rectype = [select RecordTypeID, who.id from Task where type = 'Survey' and who.id <> null LIMIT 1];
        
        List <Account> accnt = new List <Account>();
        List <Customer_Branch__c> cb = new List <Customer_Branch__c>(); 
        List <Task> tasks = new List <Task>(); 

        Test.StartTest(); 
        //Create 1 Account
        Account acct = new Account(Name = 'Test Account');
        accnt.add(acct);
        insert accnt;
        
        // Create 8 CUstomer Branches 
        for (integer i=0; i<8; i++) { 
            Customer_Branch__c c = new Customer_Branch__c(Name ='Test Branch Insert', Ryder_HQ_Account__c = acct.id); 
            cb.add(c); 
        } //close for-loop 
        
        insert cb; 

        List <Customer_Branch__c> cb2 = [Select ID from Customer_Branch__c Where Name=:'Test Branch Insert' limit 8]; 
        // Create a Task for each Customer Branch inserted
        for (Integer i=0; i<8; i++) { 
            Task tsk = new Task(); 
            tsk.ActivityDate = System.today() - 15; 
            //if (i > 3){
            //tsk.OwnerID = aID;
            //} else tsk.OwnerID = bId;
            tsk.WhatId = cb2.get(i).Id; 
            tsk.Status = 'Completed'; 
            tsk.Type = 'Survey';
            tsk.Subject = 'Customer Sat Survey'; 
            //tsk.Recordtypeid = rectype;
            tasks.add(tsk); 
        } // close for-loop 
        try { 
            insert tasks; 
        } catch (System.DMLexception e) { 
        System.debug('Task List not inserted: ' + e); 
} 
// Call the Batch Apex method. 
BatchAutoSurveyActivity bsa = new BatchAutoSurveyActivity(); 
bsa.runTestMethod=true;    //CSI TEST
ID batchprocessid = Database.executeBatch(bsa); 
Test.StopTest(); 

AsyncApexJob async = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems from AsyncApexJob where Id = :batchprocessid]; 
System.debug('Final results are ' + async); 
System.AssertEquals(async.NumberOfErrors, 0); 
System.AssertEquals([Select count() from Customer_Branch__c Where Name ='Test Branch Insert'], 8);  
//System.AssertEquals([Select count() from Task Where Subject = 'Customer Sat Survey' and ActivityDate ], 4); 
} //close testmethod 
}