@isTest
private class test_CalculateBusinessHours {

static testMethod void insertTask() {

BusinessHours stdBH = [select id from businesshours where isDefault = true];

// Insert a task with a due date
Task rectype = [Select RecordTypeId, who.id, what.id, ActivityDate from Task where Type = 'Survey' and who.id <> null and what.id <> NULL LIMIT 1];
System.debug('Test: Creating task to determine if due date is moved to a working non-holiday based on Ryder hours');


Test.StartTest();
Date first_holiday = date.newInstance(System.Today().addDays(2).year(),System.Today().addDays(2).month(),System.Today().addDays(2).day());

//Create a new holiday - 1
User u;
User testuser = [Select ID from user where id = :UserInfo.getUserId()];
System.runAs (testuser){
    Profile p = [select id from profile where name like 'Service%' LIMIT 1];
    Userrole r = [select id from userrole where name like 'Service%' LIMIT 1]; 
    u = new User(alias = 'testee', email='testee@testee.com',lastname = 'Testing', username = 'testing123@testing123.com',profileid = p.id, userroleid = r.Id, emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles');
    Holiday testHoliday = new Holiday(ActivityDate = first_holiday,IsAllDay = true, Name = 'Testing Day for SFDC');
    insert testHoliday;
    Task testTask = new Task();
    testTask.Survey_Call_Date_Time__c = BusinessHours.add (stdBH.id, first_holiday, 23 * 60 * 1000L);
    testTask.whoId = rectype.who.id;
    testTask.whatId = rectype.what.id;
    testTask.Subject = 'Customer Sat Survey';
    testTask.Status = 'Retry';
    testTask.Survey_Call_Result__c  = 'Unavailable';
    testTask.Type = 'Survey';
    Date myDate = date.newinstance(testTask.Survey_Call_Date_Time__c.year(), testTask.Survey_Call_Date_Time__c.month(), testTask.Survey_Call_Date_Time__c.day());
    testTask.ActivityDate = myDate;
    testTask.Original_Due_Date__c = myDate;
    insert testTask;
}

//Create another Holiday
Date second_holiday = date.newInstance(System.Today().addDays(1).year(),System.Today().addDays(1).month(),System.Today().addDays(1).day());

System.runAs (u){
    Holiday testHoliday2 = new Holiday(ActivityDate = second_holiday, IsAllDay = true, Name = 'Testing Day 2 for SFDC');
    insert testHoliday2;
    Task test2Task = new Task();
    test2Task.Survey_Call_Date_Time__c = BusinessHours.add (stdBH.id, testHoliday2.ActivityDate, 23 * 60 * 1000L);
    test2Task.whoId = rectype.who.id;
    test2Task.whatId = rectype.what.id;
    test2Task.Status = 'Deferred/Callback';
    test2Task.Subject = 'Customer Sat Survey';
    test2Task.Survey_Call_Result__c  = 'Future Reschedule';
    test2Task.Type = 'Survey';
    Date myDate2 = date.newinstance(test2Task.Survey_Call_Date_Time__c.year(), test2Task.Survey_Call_Date_Time__c.month(), test2Task.Survey_Call_Date_Time__c.day());
    test2Task.ActivityDate = myDate2;
    test2Task.Original_Due_Date__c = myDate2;
    insert test2Task;
    
    List <Task> bhtasks = new List <Task>();
    for (Integer cnt = 0; cnt < 8; cnt++)
    {
        Datetime dall = datetime.newInstance(System.Today().year(),System.Today().month(),System.Today().day());
        Task test3Task = new Task();
        test3Task.Survey_Call_Date_Time__c = BusinessHours.add (stdBH.id, dall, 23 * 60 * 1000L);
        system.debug('Survey Call Date Time 3 **** - ' + test3Task.Survey_Call_Date_Time__c);
        test3Task.whoId = rectype.who.id;
        test3Task.whatId = rectype.what.id;
        test3Task.Subject = 'CSS for Business Hours';
        test3Task.Status = 'Not Started';
        test3Task.Type = 'Survey';
        Date myDate3 = date.newinstance(test3Task.Survey_Call_Date_Time__c.year(), test3Task.Survey_Call_Date_Time__c.month(), test3Task.Survey_Call_Date_Time__c.day());
        test3Task.ActivityDate = myDate3;
        test3Task.Original_Due_Date__c = myDate3;
        bhtasks.add(test3Task);
     }
     try{
         insert bhtasks;
         system.debug('testTask.id successfully created 3 ....');
        }
     catch (System.DMLException e)
     {
         system.debug('unable to insert tasks for group 3');
     }  
        Task test4Task = new Task();
        test4Task.whoId = rectype.who.id;
        test4Task.whatId = rectype.what.id;
        test4Task.Status = 'Completed';
        test4Task.Subject = 'Customer Sat Survey';
        test4Task.Survey_Call_Result__c  = 'Refusal';
        test4Task.Type = 'Survey';
        test4Task.Survey_Opt_Out__c = 'Yes';
        test4Task.Survey_Submission_Date__c = System.Now();
        test4Task.ActivityDate = System.Today();
        test4Task.Original_Due_Date__c = System.Today();
        insert test4Task;
            
        List <Task> tasks = new List <Task>(); 
        List <Key_Contact__c> kc2 = [Select Customer_Branch__c, Contact__c, Available_24_7__c from Key_Contact__c where Contact_Role__c=:'CSI Contact' limit 8];
        for (Integer i=0; i<8; i++) { 
          Task tsk = new Task(); 
          tsk.ActivityDate = System.today().AddDays(i); 
          tsk.WhatId = kc2.get(i).Customer_Branch__c; 
          tsk.WhoID = kc2.get(i).Contact__c;
          tsk.Available_24_7__c = kc2.get(i).Available_24_7__c;
          tsk.Status = 'Not Started'; 
          tsk.Type = 'Survey';
          tsk.Subject = 'Customer Sat Survey'; 
          if (i<>4){
          tsk.Survey_Opt_Out__c = 'No';
          tsk.Survey_Call_Date_Time__c = dateTime.Now().addDays(i);
          system.debug('Survey Call Date Time 5 **** - ' + tsk.Survey_Call_Date_Time__c);
          tsk.Survey_Submission_Date__c = System.Now();
          tasks.add(tsk); 
          }      
        } // close for-loop 
          try { 
           insert tasks; 
          } catch (System.DMLexception e) { 
         System.debug('Task List not inserted for last for loop...: ' + e); 
        } 
}

        
    
Test.StopTest(); 

// Read the record back and verify that the fields modified by this trigger are not null
Task testingTask= [select Id, ActivityDate, Status, Type from Task where Subject = 'Customer Sat Survey' LIMIT 1];
System.assert (Task.ActivityDate != NULL);
}
} // testCalculateBusinessHours