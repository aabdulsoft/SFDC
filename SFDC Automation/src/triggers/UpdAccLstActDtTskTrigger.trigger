trigger UpdAccLstActDtTskTrigger on Task (after update) {
    
    if(trigger.isAfter)
    {
        List<Task> lstRyderTask = new List<Task>();
        
        for(Task newRyderTask : trigger.new)
        {
            if(newRyderTask.RecordTypeId == LABEL.Ryder_Task_Record_ID){
                lstRyderTask.add(newRyderTask);
            }
        } 
        
        //UpdAccLstActDtTskTriggerHelper.UpdateAccount(trigger.new, trigger.oldMap, trigger.newMap);
        if(lstRyderTask != null && lstRyderTask.size()>0){
            UpdAccLstActDtTskTriggerHelper.UpdateAccount(lstRyderTask, trigger.oldMap, trigger.newMap);         
        }
    }
}