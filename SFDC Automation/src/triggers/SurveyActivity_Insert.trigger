Trigger SurveyActivity_Insert on Task (after update){
/*Deployment - Customer Satisfaction
Purpose - If the survey activity resulted in a hangup, create another task for the following day.  The task should 
be assigned to the same owner of the existing task. Similarly, if the survey activity resulted in a same day reschedule,
a new task should be created for the same day and the task should be assigned to the same owner of the existing task.
If the agent leaves a voicemail or if the person is unavailable, the task will be created for the next day and assigned
for the following day. If the survey activity resulted in a future reschedule, automatically reschedule for the date 
that was provided by the survey respondent.

Build 2: If the survey respondent does not complete the survey with a response of Too Busy, create another task for 20 days later
to call the survey respondent again. Set the reminders to false automatically.  Update the Area Name and Availability on the subsequent
task to allow visibility in the call queue.

Build 3:  Added the survey sub type to categorize the different types of surveys that are being taken.

Build 1 - 2012: 
1) If retry occurs with a disposition of Leave Message or Unavailable after a third attempt, place in the queue in 90 days.
2) If refusal occurs, mark all subsequent activities as Prior Refusal.
3) If Refusal - Completed Survey Recently occurs, mark all subsequent activities as Prior Refusal.
4) If time zone is included in the original survey activity, include time zone in the newly created survey activity.*/

List<Task> listofTask = new List<Task>();
Decimal num_of_attempts;
Date ActivityDate;
Date NewSurveyActivityDate;

for (Task t : trigger.new)
{
    if (t.ActivityDate == null) 
    {
        ActivityDate = System.Today();
    }else ActivityDate = t.ActivityDate;
    
    if (t.Call_Attempts__c == null)
    {
        num_of_attempts = 1;
    }else num_of_attempts = t.Call_Attempts__c;
    
    if (t.Survey_Call_Date_Time__c == null)
    {
        NewSurveyActivityDate = Date.newInstance(System.Now().year(),System.Now().month(), System.Now().day());
    }else NewSurveyActivityDate = Date.newInstance(t.Survey_Call_Date_Time__c.year(),t.Survey_Call_Date_Time__c.month(),t.Survey_Call_Date_Time__c.day());
     
    if((t.Survey_Call_Result__c  == 'Hangup') && (trigger.OldMap.get(t.Id).Survey_Call_Result__c  != 'Hangup') && (num_of_attempts <> 3))
    {
        Task NT = new Task(OwnerId = t.OwnerID, WhoId = t.WhoId, WhatID = t.WhatId, Priority = t.Priority, Status = 'Not Started', Subject = t.Subject, Type = t.Type, ActivityDate = ActivityDate.addDays(1), RecordTypeId = t.RecordTypeId, Call_Attempts__c = num_of_attempts+1, IsReminderSet = false, Area_Name__c = t.Area_Name__c, Available_24_7__c = t.Available_24_7__c, Available_From__c = t.Available_From__c, Available_To__c = t.Available_To__c, Survey_Sub_Type__c = t.Survey_Sub_Type__c, Time_Zone__c = t.Time_Zone__c);
        listofTask.add(NT);
    }else if ((t.Survey_Call_Result__c  == 'Same Day Reschedule') && (trigger.OldMap.get(t.Id).Survey_Call_Result__c  != 'Same Day Reschedule') && (num_of_attempts <> 3))
    {
        Task NT = new Task(OwnerId = t.OwnerID, WhoId = t.WhoId, WhatID = t.WhatId, Priority = t.Priority, Status = 'Not Started', Subject = t.Subject, Type = t.Type, ActivityDate = ActivityDate, Survey_Call_Date_Time__c = t.Survey_Call_Date_Time__c, RecordTypeId = t.RecordTypeId, Call_Attempts__c = num_of_attempts+1, IsReminderSet = false, Area_Name__c = t.Area_Name__c, Available_24_7__c = t.Available_24_7__c, Available_From__c = t.Available_From__c, Available_To__c = t.Available_To__c, Survey_Sub_Type__c = t.Survey_Sub_Type__c, Time_Zone__c = t.Time_Zone__c);
        listofTask.add(NT);
    }
    else if ((t.Survey_Call_Result__c  == 'Unavailable') && (trigger.OldMap.get(t.Id).Survey_Call_Result__c  != 'Unavailable') && (num_of_attempts <> 3))
    {
        Task NT = new Task(OwnerId = t.OwnerID, WhoId = t.WhoId, WhatID = t.WhatId, Priority = t.Priority, Status = 'Not Started', Subject = t.Subject, Type = t.Type, ActivityDate = ActivityDate.addDays(1),RecordTypeId = t.RecordTypeId, Call_Attempts__c = num_of_attempts+1, IsReminderSet = false, Area_Name__c = t.Area_Name__c, Available_24_7__c = t.Available_24_7__c, Available_From__c = t.Available_From__c, Available_To__c = t.Available_To__c, Survey_Sub_Type__c = t.Survey_Sub_Type__c, Time_Zone__c = t.Time_Zone__c);
        listofTask.add(NT);
    }
    else if ((t.Survey_Call_Result__c  == 'Left Message') && (trigger.OldMap.get(t.Id).Survey_Call_Result__c  != 'Left Message') && (num_of_attempts <> 3))
    {
        Task NT = new Task(OwnerId = t.OwnerID, WhoId = t.WhoId, WhatID = t.WhatId, Priority = t.Priority, Status = 'Not Started', Subject = t.Subject, Type = t.Type, ActivityDate = ActivityDate.addDays(1), RecordTypeId = t.RecordTypeId, Call_Attempts__c = num_of_attempts+1, IsReminderSet = false, Area_Name__c = t.Area_Name__c, Available_24_7__c = t.Available_24_7__c, Available_From__c = t.Available_From__c, Available_To__c = t.Available_To__c, Survey_Sub_Type__c = t.Survey_Sub_Type__c, Time_Zone__c = t.Time_Zone__c);
        listofTask.add(NT);
    }
    else if ((t.Survey_Call_Result__c  == 'Refusal - Too Busy') && (trigger.OldMap.get(t.Id).Survey_Call_Result__c  != 'Refusal - Too Busy') && (num_of_attempts <> 3))
    {
        Task NT = new Task(OwnerId = t.OwnerID, WhoId = t.WhoId, WhatID = t.WhatId, Priority = t.Priority, Status = 'Not Started', Subject = t.Subject, Type = t.Type, ActivityDate = ActivityDate.addDays(20), RecordTypeId = t.RecordTypeId, Call_Attempts__c = num_of_attempts+1, IsReminderSet = false, Area_Name__c = t.Area_Name__c, Available_24_7__c = t.Available_24_7__c, Available_From__c = t.Available_From__c, Available_To__c = t.Available_To__c, Survey_Sub_Type__c = t.Survey_Sub_Type__c, Time_Zone__c = t.Time_Zone__c);
        listofTask.add(NT);
    }
    else if ((t.Survey_Call_Result__c  == 'Future Reschedule') && (trigger.OldMap.get(t.Id).Survey_Call_Result__c  != 'Future Reschedule') && (num_of_attempts <> 3))
    {
        Task NT = new Task(OwnerId = t.OwnerID, WhoId = t.WhoId, WhatID = t.WhatId, Priority = t.Priority, Status = 'Not Started', Subject = t.Subject, Type = t.Type, ActivityDate = NewSurveyActivityDate, Survey_Call_Date_Time__c = t.Survey_Call_Date_Time__c, RecordTypeId = t.RecordTypeId, Call_Attempts__c = num_of_attempts+1, IsReminderSet = false, Area_Name__c = t.Area_Name__c, Available_24_7__c = t.Available_24_7__c, Available_From__c = t.Available_From__c, Available_To__c = t.Available_To__c, Survey_Sub_Type__c = t.Survey_Sub_Type__c, Time_Zone__c = t.Time_Zone__c);
        listofTask.add(NT);
    }
    else if ((t.Survey_Call_Result__c  == 'Unavailable') && (trigger.OldMap.get(t.Id).Survey_Call_Result__c  != 'Unavailable') && (num_of_attempts == 3))
    {
        Task NT = new Task(OwnerId = t.OwnerID, WhoId = t.WhoId, WhatID = t.WhatId, Priority = t.Priority, Status = 'Not Started', Subject = t.Subject, Type = t.Type, ActivityDate = ActivityDate.addDays(90),RecordTypeId = t.RecordTypeId, Call_Attempts__c = 1, IsReminderSet = false, Area_Name__c = t.Area_Name__c, Available_24_7__c = t.Available_24_7__c, Available_From__c = t.Available_From__c, Available_To__c = t.Available_To__c, Survey_Sub_Type__c = t.Survey_Sub_Type__c, Time_Zone__c = t.Time_Zone__c);
        listofTask.add(NT);
    }
    else if ((t.Survey_Call_Result__c  == 'Left Message') && (trigger.OldMap.get(t.Id).Survey_Call_Result__c  != 'Left Message') && (num_of_attempts == 3))
    {
        Task NT = new Task(OwnerId = t.OwnerID, WhoId = t.WhoId, WhatID = t.WhatId, Priority = t.Priority, Status = 'Not Started', Subject = t.Subject, Type = t.Type, ActivityDate = ActivityDate.addDays(90), RecordTypeId = t.RecordTypeId, Call_Attempts__c = 1, IsReminderSet = false, Area_Name__c = t.Area_Name__c, Available_24_7__c = t.Available_24_7__c, Available_From__c = t.Available_From__c, Available_To__c = t.Available_To__c, Survey_Sub_Type__c = t.Survey_Sub_Type__c, Time_Zone__c = t.Time_Zone__c);
        listofTask.add(NT);
    }
    else if ((t.Survey_Call_Result__c  == 'Refusal') && (trigger.OldMap.get(t.Id).Survey_Call_Result__c  != 'Refusal') ||(t.Survey_Call_Result__c  == 'Refusal - Completed Survey Recently') && (trigger.OldMap.get(t.Id).Survey_Call_Result__c  != 'Refusal - Completed Survey Recently'))
    {
        Date todayDate = System.today();
        List <AggregateResult> otherTasks= [SELECT Count(ID) OtherTasks FROM Task WHERE whoId = :t.whoid AND ActivityDate > :todayDate AND Status = 'Not Started' and Type = 'Survey' and Subject = 'Customer Sat Survey'];
       integer otherTaskscount= integer.valueof(otherTasks[0].get('OtherTasks'));
        if (otherTaskscount != 0)
        {    
          List<Task> taskstoUpdate = [SELECT WhoId, WhatId, ActivityDate FROM Task WHERE whoId = :t.whoid AND ActivityDate > :todayDate AND Status = 'Not Started' and Type = 'Survey' and Subject = 'Customer Sat Survey'];
          for (Task tu: taskstoUpdate)
            {
                tu.Status = 'Completed';
                tu.Survey_Call_Result__c = 'Prior Refusal';
                System.Debug ('***New Status - tu.Status: ' + tu.Status);
                System.Debug ('***New Call Result- tu.Survey_Call_Result__c: ' + tu.Survey_Call_Result__c);
            }
            update taskstoUpdate;
        }
    }

}
        insert listofTask;
}