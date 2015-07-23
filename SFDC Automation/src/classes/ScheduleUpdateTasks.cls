global class ScheduleUpdateTasks implements Schedulable { 
    global void execute(SchedulableContext SC) { 
    BatchAutoSurveyActivity basa  = new BatchAutoSurveyActivity(); 
    database.executebatch(basa); 
} //close execute method 
} //close class