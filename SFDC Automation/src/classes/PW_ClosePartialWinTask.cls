public with sharing class PW_ClosePartialWinTask {
    
    public static void CloseTask(String opportunityId){
            
        //Get Task Id to update
        List<Task> currentTask = [Select Id From Task Where Type = 'Partial Win' and WhatId = :opportunityId];
        
        List<Task> lCloseTask = new List<Task>();
        for(Task tsk : currentTask){
            Task T = new Task();
            T.Id = tsk.Id;
            T.Status = 'Completed';
            lCloseTask.add(T);
        }
        if(lCloseTask.size() > 0)
            update lCloseTask;
    }
        
}