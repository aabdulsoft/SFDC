trigger UnresolvedTask on Task (after update) {
//Trigger is fired when the follow-up task is updated as Un-Resolved 
//It is used to send emails to the Account Management Team and create a Task 
//Saad Wali Jaan: Created on 04/20/2012.
Map<String, Id> surveyRecordTypes= CommonFunctions.getRecordType('Task');

    string objType = '';
    string surveyId = '';
    string surveyName = '';

    objType = 'Task';
    
    List<Task> TaskToInsert = new List<Task>();      
    
    for (Task tsk:Trigger.new)
    {
        if (tsk.RecordTypeId == surveyRecordTypes.get('Care360'))
        {
            if(tsk.Status == 'Not Resolved')
            {
                //Get the id of the survey 
                surveyId = tsk.SurveyID__c; 
                //Getting the email id of the account management team
                GetAcctMngID.GetDetails(surveyId, objType);
                //Creating a task 
                TaskToInsert.add(CreateTask.Care360Task(surveyId));
            }
        }
        else if (tsk.Status == 'Completed' && tsk.RecordTypeId == surveyRecordTypes.get('Credit Activity Task')){           
            EmailUtil.sendMailtoUsers('FromClose', Trigger.newMap);             
        }
        else if (tsk.Status != 'Completed' && tsk.RecordTypeId == surveyRecordTypes.get('Credit Activity Task')){           
            //if(tsk.CreatedDate != tsk.LastModifiedDate && tsk.Estimated_Completion__c != null){ //Compare date and time to make sure email is not sent twice.
                EmailUtil.sendMailtoUsers('FromUpdate', Trigger.newMap);
            //}
        }
     }          
    
    //Insert the new tasks if there are any
    if(TaskToInsert != null && TaskToInsert.size()>0) insert TaskToInsert;
}