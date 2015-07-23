/*Test class to provide test coverage for both Apex triggers - SurveyActivity_Insert and UpdateContactTaskAfterTrigger*/
@isTest
private class test_SurveyActivity_Insert{
    static testMethod void testActivityChange() {
    
        Task rectype = [Select RecordTypeId, who.id, what.id from Task where Type = 'Survey' and who.id <> null and what.id <> NULL LIMIT 1];
        
        Task sat= new Task();
        sat.whoId = rectype.who.id;
        sat.whatID = rectype.what.id;
        sat.Status = 'Not Started';
        sat.Priority = 'Low';
        sat.Type = 'Survey';
        sat.Subject = 'Customer Sat Survey';
        datetime myDateTime = datetime.newInstance(2061, 8, 30, 12, 30, 2);
        sat.Survey_Call_Date_Time__c = myDateTime;
        sat.recordtypeid = rectype.RecordTypeId;
        insert sat;
        
        Test.startTest();
        sat.Status = 'Completed';
        sat.Survey_Call_Result__c  = 'Refusal';
        sat.Survey_Opt_Out__c = 'Yes';
        sat.Survey_Opt_Out_Reason__c = 'Test Refusal';   
        update sat;
                
        sat.Status = 'Retry';
        sat.ActivityDate = System.Today();
        sat.Original_Due_Date__c = System.Today();
        sat.Survey_Call_Result__c  = 'Left Message';
        sat.Type = 'Survey';
        sat.Subject = 'Customer Sat Survey';
        update sat;
        
        sat.Status = 'Retry';
        sat.Survey_Call_Result__c  = 'Unavailable';
        sat.Type = 'Survey';
        sat.Subject = 'Customer Sat Survey';
        update sat;
        
        sat.Status = 'Retry';
        sat.ActivityDate = System.Today();
        sat.Survey_Call_Result__c  = 'Left Message';
        sat.Call_Attempts__c = 3;
        sat.Type = 'Survey';
        sat.Subject = 'Customer Sat Survey';
        update sat;
        
        sat.Status = 'Retry';
        sat.Survey_Call_Result__c  = 'Unavailable';
        sat.Call_Attempts__c = 3;
        sat.Type = 'Survey';
        sat.Subject = 'Customer Sat Survey';
        update sat;

         sat.Status = 'Deferred/Callback';
        sat.Survey_Call_Result__c  = 'Future Reschedule';
        sat.Survey_Call_Date_Time__c = System.Today().addDays(2);
        sat.Call_Attempts__c = 1;
        sat.Type = 'Survey';
        sat.Subject = 'Customer Sat Survey';
        update sat;
        
        sat.Status = 'Completed';
        sat.Survey_Call_Result__c  = 'Refusal - Too Busy';
        sat.Type = 'Survey';
        sat.Call_Attempts__c = 1;
        sat.Subject = 'Customer Sat Survey';
        update sat;


        sat.Status = 'Deferred/Callback';
        sat.Survey_Call_Result__c  = 'Same Day Reschedule';
        sat.Call_Attempts__c = 1;
        sat.Survey_Call_Date_Time__c = System.Now();
        sat.Type = 'Survey';
        sat.Subject = 'Customer Sat Survey';
        update sat;
       
        sat.Status = 'Completed';
        sat.Survey_Call_Result__c  = 'Hangup';
        sat.Survey_Call_Date_Time__c = NULL;
        sat.Call_Attempts__c = NULL;
        sat.Type = 'Survey';
        sat.Subject = 'Customer Sat Survey';
        update sat;
        
        sat.Status = 'Completed';
        sat.whoId = rectype.who.id;
        sat.whatID = rectype.what.id;
        sat.Survey_Call_Result__c  = 'Refusal';
        sat.Survey_Submission_Date__c = NULL;
        sat.Survey_Opt_Out__c = 'Yes';
        sat.Call_Attempts__c = 3;
        sat.Type = 'Survey';
        sat.Subject = 'Customer Sat Survey';
        update sat;
        
        sat.Status = 'Completed';
        sat.whoId = rectype.who.id;
        sat.whatID = rectype.what.id;
        sat.Survey_Call_Result__c  = 'Refusal';
        sat.Survey_Submission_Date__c = System.Today();
        sat.Survey_Opt_Out__c = 'No';
        sat.Call_Attempts__c = NULL;
        sat.Type = 'Survey';
        sat.Subject = 'Customer Sat Survey';
        update sat;
        
        Test.stopTest();

    }
}