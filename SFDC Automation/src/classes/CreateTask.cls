public with sharing class CreateTask {
//This class is used to create the task for failed surveys & unresolved follow up task
//Created on 04/03/2012 Saad Wali Jaan.
    
    Public static Task Care360Task(String surveyId)
    {
        date myDate = System.Today();
        system.debug('Saad - myDate + 60Days = ' + myDate.addDays(60));
        Map<String, Id> surveyRecordTypes= CommonFunctions.getRecordTypeMap('Task');
        List<Ryder_Surveys__c> rs = [Select r.Id, r.Name, r.Customer_Branch__c, r.Contact__c, r.CreatedDate from Ryder_Surveys__c r WHERE r.Id = :surveyId];
        system.debug('Saad - RyderSurvey = ' + rs);
        //Create a new Task           
        Task T = new Task();
        
        for(Ryder_Surveys__c r : rs)
        {
            T.OwnerId = RyderGlobalVariables.FOLLOWSURVEYUSER;//Assigned To
            T.WhatId = r.Customer_Branch__c;//Related To
            T.WhoId = r.Contact__c;//
            T.Orignal_Task_Date__c = r.CreatedDate;//Date on which survey was done
            //T.Survey_Submission_Date__c = r.CreatedDate;//Date on which survey was done
            T.Type = 'Phone Call';
            T.Subject = 'Follow up task for Dissatisfied CSI survey';
            T.ActivityDate = myDate.addDays(60);
            T.Description = 'Follow up task for Dissatisfied CSI survey';
            T.Status = 'Not Started';
            T.Priority = 'Normal';
            T.RecordTypeId = surveyRecordTypes.get('Care360');
            T.SurveyID__c = r.Id;//To store the Id of the Ryder Survey for which this task is created.
            T.Survey_Name__c = r.Name;//To store the Name of the Ryder Survey for which this task is created.
        }
        return T;
    }
    static testMethod void test_taskcreation(){
        Ryder_Surveys__c rs = new Ryder_Surveys__c();
        insert rs;
        Care360Task(rs.Id);
    }
}